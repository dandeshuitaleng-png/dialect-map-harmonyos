#!/usr/bin/env python3
"""Generate reviewed representative dialect points from open atlas data.

Classification source: Zenodo 10.5281/zenodo.15897647 (CC BY 4.0).
Coordinates: GeoJSON.cn 1.5.3 administrative centres (WGS-84).
The output is representative points, never dialect boundary geometry.
"""

from __future__ import annotations

import csv
import hashlib
import io
import json
import pathlib
import subprocess
import tempfile
import urllib.request
import time
from collections import Counter, defaultdict


ROOT = pathlib.Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "deploy/ecs-directory-service/dialect-points.generated.json"
ATLAS_URL = (
    "https://zenodo.org/api/records/15897647/files/"
    "%E3%80%8A%E4%B8%AD%E5%9B%BD%E8%AF%AD%E8%A8%80%E5%9C%B0%E5%9B%BE%E9%9B%86"
    "%EF%BC%88%E7%AC%AC2%E7%89%88%EF%BC%89%E6%B1%89%E8%AF%AD%E6%96%B9%E8%A8%80"
    "%E5%8D%B7%E3%80%8B%E6%95%B0%E6%8D%AE%E9%9B%86.csv/content"
)
GEOJSON_ROOT = "https://geojson.cn/api/china/1.5.3"


def fetch_json(url: str) -> dict:
    return json.loads(fetch_bytes(url).decode("utf-8"))


def fetch_text(url: str) -> str:
    return fetch_bytes(url).decode("utf-8-sig")


def fetch_bytes(url: str) -> bytes:
    last_error: Exception | None = None
    for attempt in range(4):
        try:
            request = urllib.request.Request(url, headers={"User-Agent": "XiangyinMap-data-builder/1.0"})
            with urllib.request.urlopen(request, timeout=45) as response:
                return response.read()
        except Exception as error:
            last_error = error
            time.sleep(1 + attempt)
    # Some Zenodo CDN responses close early with urllib on the bundled macOS
    # Python. curl retries partial transfers and verifies the final response.
    with tempfile.NamedTemporaryFile() as temporary:
        result = subprocess.run(
            ["curl", "-L", "--fail", "--retry", "5", "--retry-all-errors", "-o", temporary.name, url],
            check=False,
        )
        if result.returncode == 0:
            return pathlib.Path(temporary.name).read_bytes()
    raise RuntimeError(f"download failed: {url}") from last_error


def sql(value: str) -> str:
    return "'" + value.replace("'", "''") + "'"


def normalized_city(name: str) -> str:
    for suffix in ("自治州", "地区", "盟", "市"):
        if name.endswith(suffix):
            return name[: -len(suffix)]
    return name


def coordinate_index(rows: list[dict]) -> tuple[dict[str, tuple[float, float]], dict[str, tuple[float, float]]]:
    national = fetch_json(f"{GEOJSON_ROOT}/100000.json")
    by_code: dict[str, tuple[float, float]] = {}
    by_name: dict[str, tuple[float, float]] = {}
    for feature in national.get("features", []):
        props = feature.get("properties", {})
        center = props.get("center")
        if not center: continue
        code = str(props.get("code", ""))
        point = (float(center[1]), float(center[0]))
        by_code[code] = point
        by_name[normalized_city(str(props.get("name", "")))] = point

    province_codes = sorted({
        row["县编码"][:2] + "0000"
        for row in rows
        if len(row["县编码"]) == 6 and row["县编码"].isdigit() and int(row["县编码"][:2]) < 70
    })
    for province_code in province_codes:
        try:
            data = fetch_json(f"{GEOJSON_ROOT}/{province_code}.json")
        except Exception as error:
            print(f"warning: coordinate file unavailable for {province_code}: {error}")
            continue
        for feature in data.get("features", []):
            props = feature.get("properties", {})
            center = props.get("center")
            if not center: continue
            point = (float(center[1]), float(center[0]))
            code = str(props.get("code", ""))
            by_code[code] = point
            by_name[normalized_city(str(props.get("name", "")))] = point
    return by_code, by_name


def main() -> None:
    rows = list(csv.DictReader(io.StringIO(fetch_text(ATLAS_URL)), delimiter="\t"))
    candidates: dict[tuple[str, str, str, str], list[dict]] = defaultdict(list)
    for row in rows:
        major, dialect, group, branch = (
            row[field].strip() for field in ("方言大区", "方言区", "方言片", "方言小片")
        )
        # Eight atlas-derived rows contain an administrative-level token in
        # 方言大区. The immediately lower 方言区 is intact, so normalize only
        # this demonstrable export anomaly instead of publishing “县级” as a
        # linguistic family.
        if major in {"县级", "地级"}:
            major = "官话" if "官话" in dialect else dialect
        key = (major, dialect, group, branch)
        candidates[key].append(row)

    by_code, by_name = coordinate_index(rows)
    points: list[dict] = []
    missing: list[str] = []
    for hierarchy, matches in sorted(candidates.items()):
        city_counts = Counter((row["市编码（2023）"].strip(), row["地级市（2023）"].strip()) for row in matches)
        city_code, city_name = city_counts.most_common(1)[0][0]
        point = by_code.get(city_code) or by_name.get(normalized_city(city_name))
        if not point:
            # Direct-administered municipalities use a synthetic city code in
            # the atlas table; their province centre is the representative.
            point = by_code.get(city_code[:2] + "0000")
        if not point:
            missing.append(f"{city_code} {city_name} {'/'.join(hierarchy)}")
            continue
        major, dialect, group, branch = hierarchy
        digest = hashlib.sha1("|".join(hierarchy).encode()).hexdigest()[:12]
        points.append({
            "id": f"atlas-{digest}", "region": normalized_city(city_name),
            "dialect": dialect, "family": major or dialect,
            "group": group or dialect, "branch": branch,
            "latitude": point[0], "longitude": point[1], "count": len(matches),
        })

    if missing:
        raise SystemExit("Missing coordinates:\n" + "\n".join(missing))
    if not 100 <= len(points) <= 200:
        raise SystemExit(f"Unexpected point count: {len(points)}")

    lines = [
        "-- Generated by scripts/generate_atlas_dialect_points.py.",
        "-- Classification: Jing, Liwen (2025), DOI 10.5281/zenodo.15897647, CC BY 4.0.",
        "-- Coordinates: GeoJSON.cn 1.5.3 administrative centres (WGS-84).",
        "-- Every row is a representative display point, not a dialect boundary.",
        "",
        "insert into public.dialects (",
        "  id, region_name, dialect_name, dialect_family, dialect_group, dialect_branch,",
        "  latitude, longitude, speaker_count, source_title, source_edition, review_status,",
        "  license_status, representative_point, administrative_scope, dispute_note",
        ") values",
    ]
    values = []
    for point in points:
        scope = f"{point['region']}行政中心仅作为该层级的地图代表点；来源数据覆盖 {point['count']} 条县级记录，不表示完整边界。"
        values.append(
            "  (" + ", ".join([
                sql(point["id"]), sql(point["region"]), sql(point["dialect"]), sql(point["family"]),
                sql(point["group"]), sql(point["branch"]), f"{point['latitude']:.6f}",
                f"{point['longitude']:.6f}", "0", sql("《中国语言地图集（第2版）汉语方言卷》县级行政单位方言数据集"),
                sql("Zenodo v1, DOI 10.5281/zenodo.15897647"), sql("开放数据交叉核对"), sql("CC BY 4.0"),
                sql(point["region"] + "行政中心"), sql(scope), sql("代表点不等于该行政区域内只有一种方言，也不表达精确方言边界。"),
            ]) + ")"
        )
    lines.append(",\n".join(values))
    lines.extend([
        "on conflict (id) do update set",
        "  region_name = excluded.region_name, dialect_name = excluded.dialect_name,",
        "  dialect_family = excluded.dialect_family, dialect_group = excluded.dialect_group,",
        "  dialect_branch = excluded.dialect_branch, latitude = excluded.latitude, longitude = excluded.longitude,",
        "  source_title = excluded.source_title, source_edition = excluded.source_edition,",
        "  review_status = excluded.review_status, license_status = excluded.license_status,",
        "  representative_point = excluded.representative_point, administrative_scope = excluded.administrative_scope,",
        "  dispute_note = excluded.dispute_note;",
        "",
    ])
    OUTPUT.write_text("\n".join(lines), encoding="utf-8")
    print(f"generated {len(points)} points at {OUTPUT}")


if __name__ == "__main__":
    main()
