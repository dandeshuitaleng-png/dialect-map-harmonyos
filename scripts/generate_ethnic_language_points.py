#!/usr/bin/env python3
"""Generate one transparent map entry for each of China's 56 ethnic groups.

Language metadata comes from the project's sourced language directory. The
point is an administrative-centre representative resolved with OpenStreetMap
Nominatim; it is not an ethnic-population point or a language boundary.
"""

from __future__ import annotations

import hashlib
import json
import pathlib
import time
import urllib.parse
import urllib.request


ROOT = pathlib.Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "deploy/ecs-directory-service/ethnic-language-points.generated.json"
DIRECTORY_URL = ""

# A representative locality selected from each directory entry's region_scope.
# These are search anchors only; Nominatim supplies the stored coordinates.
ANCHORS = {
    "东乡族": "甘肃省临夏回族自治州东乡族自治县", "乌孜别克族": "新疆乌鲁木齐市",
    "京族": "广西防城港市东兴市", "仡佬族": "贵州省遵义市", "仫佬族": "广西河池市罗城仫佬族自治县",
    "佤族": "云南省临沧市沧源佤族自治县", "侗族": "贵州省黔东南苗族侗族自治州",
    "俄罗斯族": "内蒙古自治区呼伦贝尔市额尔古纳市", "保安族": "甘肃省临夏回族自治州积石山保安族东乡族撒拉族自治县",
    "傈僳族": "云南省怒江傈僳族自治州", "傣族": "云南省西双版纳傣族自治州",
    "哈尼族": "云南省红河哈尼族彝族自治州", "哈萨克族": "新疆伊犁哈萨克自治州",
    "回族": "宁夏回族自治区银川市", "土家族": "湖南省湘西土家族苗族自治州",
    "土族": "青海省海东市互助土族自治县", "基诺族": "云南省西双版纳傣族自治州景洪市基诺山基诺族乡",
    "塔吉克族": "新疆喀什地区塔什库尔干塔吉克自治县", "塔塔尔族": "新疆昌吉回族自治州奇台县",
    "壮族": "广西南宁市武鸣区", "布依族": "贵州省黔南布依族苗族自治州",
    "布朗族": "云南省西双版纳傣族自治州勐海县", "彝族": "四川省凉山彝族自治州",
    "德昂族": "云南省德宏傣族景颇族自治州", "怒族": "云南省怒江傈僳族自治州福贡县",
    "拉祜族": "云南省普洱市澜沧拉祜族自治县", "撒拉族": "青海省海东市循化撒拉族自治县",
    "普米族": "云南省怒江傈僳族自治州兰坪白族普米族自治县", "景颇族": "云南省德宏傣族景颇族自治州陇川县",
    "朝鲜族": "吉林省延边朝鲜族自治州", "柯尔克孜族": "新疆克孜勒苏柯尔克孜自治州",
    "毛南族": "广西河池市环江毛南族自治县", "水族": "贵州省黔南布依族苗族自治州三都水族自治县",
    "汉族": "北京市", "满族": "辽宁省沈阳市", "独龙族": "云南省怒江傈僳族自治州贡山独龙族怒族自治县",
    "珞巴族": "西藏自治区林芝市米林市", "瑶族": "广西来宾市金秀瑶族自治县",
    "畲族": "福建省宁德市霞浦县", "白族": "云南省大理白族自治州",
    "纳西族": "云南省丽江市", "维吾尔族": "新疆喀什地区喀什市", "羌族": "四川省阿坝藏族羌族自治州茂县",
    "苗族": "贵州省黔东南苗族侗族自治州", "蒙古族": "内蒙古自治区呼和浩特市",
    "藏族": "西藏自治区拉萨市", "裕固族": "甘肃省张掖市肃南裕固族自治县",
    "赫哲族": "黑龙江省佳木斯市同江市街津口赫哲族乡", "达斡尔族": "内蒙古自治区呼伦贝尔市莫力达瓦达斡尔族自治旗",
    "鄂伦春族": "内蒙古自治区呼伦贝尔市鄂伦春自治旗", "鄂温克族": "内蒙古自治区呼伦贝尔市鄂温克族自治旗",
    "锡伯族": "新疆伊犁哈萨克自治州察布查尔锡伯自治县", "门巴族": "西藏自治区林芝市墨脱县",
    "阿昌族": "云南省德宏傣族景颇族自治州梁河县", "高山族": "台湾省花莲县",
    "黎族": "海南省五指山市",
}

# Verified fallbacks for administrative names absent from Nominatim's Chinese
# name index. Values are representative administrative-centre coordinates.
COORDINATE_OVERRIDES = {
    "水族": (25.988454, 107.870484, "贵州省三都水族自治县行政中心"),
    "黎族": (18.775147, 109.516662, "海南省五指山市行政中心"),
}


def fetch_json(url: str) -> dict | list:
    request = urllib.request.Request(url, headers={"User-Agent": "XiangyinMap-data-builder/1.0 (language map)"})
    with urllib.request.urlopen(request, timeout=45) as response:
        return json.load(response)


def sql(value: str) -> str:
    return "'" + value.replace("'", "''") + "'"


def geocode(query: str) -> tuple[float, float, str]:
    url = "https://nominatim.openstreetmap.org/search?" + urllib.parse.urlencode({
        "q": query, "format": "jsonv2", "limit": 1, "countrycodes": "cn",
    })
    values = fetch_json(url)
    if not isinstance(values, list) or not values:
        raise RuntimeError(f"No coordinate result for {query}")
    value = values[0]
    return float(value["lat"]), float(value["lon"]), str(value.get("display_name", query))


def main() -> None:
    directory = fetch_json(DIRECTORY_URL)
    entities = directory.get("entities", []) if isinstance(directory, dict) else []
    by_ethnicity = {item["ethnicity_name"]: item for item in entities}
    if set(by_ethnicity) != set(ANCHORS):
        raise SystemExit(f"Directory/anchor mismatch: missing={set(by_ethnicity)-set(ANCHORS)}, extra={set(ANCHORS)-set(by_ethnicity)}")

    cache_path = ROOT / ".temp-ethnic-language-coordinates.json"
    cache = json.loads(cache_path.read_text()) if cache_path.exists() else {}
    for index, (ethnicity, query) in enumerate(ANCHORS.items()):
        if ethnicity not in cache:
            cache[ethnicity] = COORDINATE_OVERRIDES.get(ethnicity) or geocode(query)
            cache_path.write_text(json.dumps(cache, ensure_ascii=False, indent=2), encoding="utf-8")
            if index + 1 < len(ANCHORS): time.sleep(1.05)

    values = []
    for ethnicity, entity in sorted(by_ethnicity.items()):
        latitude, longitude, resolved_name = cache[ethnicity]
        digest = hashlib.sha1(ethnicity.encode()).hexdigest()[:12]
        language_name = entity["language_name"].split("；", 1)[0]
        scope = entity["region_scope"]
        values.append("  (" + ", ".join([
            sql(f"ethnic-{digest}"), sql(ethnicity), sql(language_name), sql(entity["language_family"]),
            sql(ethnicity), sql("语言资源入口"), f"{latitude:.6f}", f"{longitude:.6f}", "0",
            sql("中国语言资源保护工程与项目民族语言候选目录"), sql("56民族语言资源入口；坐标由 OpenStreetMap Nominatim 解析"),
            sql("民族语言目录代表点"), sql("目录来源待逐条复核；坐标 ODbL"), sql(ANCHORS[ethnicity]),
            sql(f"已报道范围：{scope}。地图坐标仅为资源入口代表位置：{resolved_name}"),
            sql("语言与民族并非一一对应；该点不表示民族人口分布、个人身份、籍贯或语言边界。"),
        ]) + ")")

    lines = [
        "-- Generated by scripts/generate_ethnic_language_points.py.",
        "-- One language-resource entry per officially listed ethnicity; never an identity inference layer.",
        "-- Representative coordinates resolved with OpenStreetMap Nominatim (ODbL).",
        "", "insert into public.dialects (",
        "  id, region_name, dialect_name, dialect_family, dialect_group, dialect_branch,",
        "  latitude, longitude, speaker_count, source_title, source_edition, review_status,",
        "  license_status, representative_point, administrative_scope, dispute_note",
        ") values", ",\n".join(values),
        "on conflict (id) do update set",
        "  region_name=excluded.region_name, dialect_name=excluded.dialect_name, dialect_family=excluded.dialect_family,",
        "  dialect_group=excluded.dialect_group, dialect_branch=excluded.dialect_branch, latitude=excluded.latitude,",
        "  longitude=excluded.longitude, source_title=excluded.source_title, source_edition=excluded.source_edition,",
        "  review_status=excluded.review_status, license_status=excluded.license_status,",
        "  representative_point=excluded.representative_point, administrative_scope=excluded.administrative_scope,",
        "  dispute_note=excluded.dispute_note;", "",
    ]
    OUTPUT.write_text("\n".join(lines), encoding="utf-8")
    print(f"generated {len(values)} ethnic language entries at {OUTPUT}")


if __name__ == "__main__":
    main()
