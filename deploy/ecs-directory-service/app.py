#!/usr/bin/env python3
"""Language directory and Huawei Account session service for the ECS migration."""
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import parse_qs, urlencode, urlparse
from urllib.request import Request, urlopen
from urllib.error import HTTPError, URLError
import base64
import hashlib
import hmac
import json
import os
import time
import uuid

DATA = json.loads((Path(__file__).with_name("directory-data.json")).read_text(encoding="utf-8"))
AI_CATALOG = json.loads((Path(__file__).with_name("ai-dialect-catalog.json")).read_text(encoding="utf-8"))
DAILY_CHALLENGES = json.loads((Path(__file__).with_name("daily-challenge-data.json")).read_text(encoding="utf-8"))
FIELDS = {
    "ethnicity": "ethnicity_name",
    "language": "language_name",
    "region": "region_name",
    "reviewStatus": "review_status",
    "coordinateStatus": "coordinate_status",
}
HUAWEI_TOKEN_URL = "https://oauth-login.cloud.huawei.com/oauth2/v3/token"
SESSION_TTL_SECONDS = 60 * 60 * 24 * 7

def request_deepseek(text: str) -> dict:
    key = os.environ.get("DEEPSEEK_API_KEY", "").strip()
    if not key:
        raise RuntimeError("ai_not_configured")
    compact_catalog = [{"id": row["id"], "name": row["dialect_name"],
                        "family": row.get("dialect_family", ""), "region": row.get("region_name", "")}
                       for row in AI_CATALOG]
    prompt = ("根据用户的中文方言例句，只能从下列目录中选择最可能的一项。"
              "返回 JSON：catalogId、dialect、confidence(0-1)、evidence(至少2条中文短句)、"
              "needsConfirmation、isUnknown、regionCandidates([{name,region,confidence}])。"
              "不确定时 isUnknown=true 且 catalogId 为空。目录：" + json.dumps(compact_catalog, ensure_ascii=False))
    body = json.dumps({"model": "deepseek-chat", "temperature": 0.2, "max_tokens": 900,
                       "response_format": {"type": "json_object"},
                       "messages": [{"role": "system", "content": prompt}, {"role": "user", "content": text}]}).encode()
    request = Request("https://api.deepseek.com/v1/chat/completions", data=body,
                      headers={"Content-Type": "application/json", "Authorization": f"Bearer {key}"}, method="POST")
    with urlopen(request, timeout=25) as response:
        payload = json.loads(response.read().decode("utf-8"))
    content = payload.get("choices", [{}])[0].get("message", {}).get("content", "")
    return json.loads(content)

def normalize_ai_result(raw: dict) -> dict:
    catalog_id = str(raw.get("catalogId") or "")
    entry = next((row for row in AI_CATALOG if row["id"] == catalog_id), None)
    confidence = raw.get("confidence") if isinstance(raw.get("confidence"), (int, float)) else 0
    confidence = max(0, min(1, confidence))
    evidence = [str(item).strip() for item in raw.get("evidence", []) if isinstance(item, str) and item.strip()][:8]
    unknown = raw.get("isUnknown") is True or entry is None or confidence <= .35 or len(evidence) < 2
    candidates = []
    for value in raw.get("regionCandidates", [])[:3]:
        if isinstance(value, dict) and isinstance(value.get("name"), str) and isinstance(value.get("region"), str):
            candidates.append({"name": value["name"][:120], "region": value["region"][:240],
                               "confidence": max(0, min(1, value.get("confidence", 0) if isinstance(value.get("confidence", 0), (int, float)) else 0))})
    return {"classificationId": entry["id"] if entry and not unknown else None,
            "primaryDialect": entry["dialect_name"] if entry and not unknown else None,
            "language": entry["dialect_name"] if entry and not unknown else None,
            "dialect": str(raw.get("dialect") or "") or None, "ethnicity": None,
            "dialectFamily": entry.get("dialect_family") if entry else None,
            "dialectGroup": entry.get("dialect_group") if entry else None,
            "regionName": entry.get("region_name") if entry and not unknown else None,
            "regionCandidates": candidates, "coverageScopes": [],
            "confidence": min(confidence, .35) if unknown else confidence, "evidence": evidence,
            "needsConfirmation": unknown or raw.get("needsConfirmation") is True or confidence < .7,
            "isUnknown": unknown, "sourceStatus": "unknown" if unknown else "catalog_candidate"}

def pcm_to_wav(pcm: bytes, sample_rate: int = 16000) -> bytes:
    byte_rate = sample_rate * 2
    header = b"RIFF" + (36 + len(pcm)).to_bytes(4, "little") + b"WAVEfmt " + (16).to_bytes(4, "little")
    header += (1).to_bytes(2, "little") + (1).to_bytes(2, "little") + sample_rate.to_bytes(4, "little")
    header += byte_rate.to_bytes(4, "little") + (2).to_bytes(2, "little") + (16).to_bytes(2, "little")
    return header + b"data" + len(pcm).to_bytes(4, "little") + pcm

def transcribe_pcm(pcm: bytes) -> tuple[str, float]:
    endpoint = os.environ.get("STT_ENDPOINT", "").strip()
    key = os.environ.get("STT_API_KEY", "").strip()
    if not endpoint or not key: raise RuntimeError("stt_not_configured")
    boundary = "----xiangyin" + uuid.uuid4().hex
    def field(name: str, value: bytes, filename: str = "") -> bytes:
        disposition = f'Content-Disposition: form-data; name="{name}"' + (f'; filename="{filename}"' if filename else "")
        content = b"Content-Type: audio/wav\r\n" if filename else b""
        return b"--" + boundary.encode() + b"\r\n" + disposition.encode() + b"\r\n" + content + b"\r\n" + value + b"\r\n"
    body = field("file", pcm_to_wav(pcm), "voice.wav") + field("model", os.environ.get("STT_MODEL", "whisper-1").encode()) + field("language", b"zh") + b"--" + boundary.encode() + b"--\r\n"
    request = Request(endpoint, data=body, headers={"Authorization": f"Bearer {key}", "Content-Type": f"multipart/form-data; boundary={boundary}"}, method="POST")
    with urlopen(request, timeout=35) as response: payload = json.loads(response.read().decode("utf-8"))
    text = str(payload.get("text") or "").strip()
    if not text: raise RuntimeError("stt_empty_transcript")
    confidence = payload.get("confidence", 0)
    return text, confidence if isinstance(confidence, (int, float)) else 0

def normalized(value: str) -> str:
    return value.strip().lower()

def include(row: dict, filters: dict) -> bool:
    return all(not value or value in normalized(str(row.get(FIELDS[name], "")))
               for name, value in filters.items())

def base64url(value: bytes) -> str:
    return base64.urlsafe_b64encode(value).rstrip(b"=").decode("ascii")

def make_session_token(user_id: str, signing_key: str) -> tuple[str, int]:
    expires_at = int(time.time()) + SESSION_TTL_SECONDS
    header = base64url(json.dumps({"alg": "HS256", "typ": "JWT"}, separators=(",", ":")).encode())
    payload = base64url(json.dumps({"sub": user_id, "exp": expires_at, "iss": "xiangyin"}, separators=(",", ":")).encode())
    signature = base64url(hmac.new(signing_key.encode(), f"{header}.{payload}".encode(), hashlib.sha256).digest())
    return f"{header}.{payload}.{signature}", expires_at * 1000

def exchange_huawei_authorization_code(authorization_code: str) -> dict:
    client_id = os.environ.get("HUAWEI_OAUTH_CLIENT_ID", "").strip()
    client_secret = os.environ.get("HUAWEI_OAUTH_CLIENT_SECRET", "").strip()
    redirect_uri = os.environ.get("HUAWEI_OAUTH_REDIRECT_URI", "").strip()
    if not client_id or not client_secret or not redirect_uri:
        raise RuntimeError("huawei_login_not_configured")
    body = urlencode({
        "grant_type": "authorization_code",
        "code": authorization_code,
        "client_id": client_id,
        "client_secret": client_secret,
        "redirect_uri": redirect_uri,
    }).encode()
    request = Request(HUAWEI_TOKEN_URL, data=body,
                      headers={"Content-Type": "application/x-www-form-urlencoded"}, method="POST")
    with urlopen(request, timeout=10) as response:
        return json.loads(response.read().decode("utf-8"))

def jwt_subject(id_token: str) -> str:
    parts = id_token.split(".")
    if len(parts) != 3:
        return ""
    try:
        payload = parts[1] + "=" * (-len(parts[1]) % 4)
        value = json.loads(base64.urlsafe_b64decode(payload.encode()).decode("utf-8"))
        return str(value.get("sub", "")).strip()
    except (ValueError, UnicodeDecodeError, json.JSONDecodeError):
        return ""

class Handler(BaseHTTPRequestHandler):
    def log_message(self, fmt, *args):
        print("%s - %s" % (self.address_string(), fmt % args), flush=True)

    def do_GET(self):
        path = urlparse(self.path)
        if path.path == "/healthz":
            return self.respond({"status": "ok"})
        if path.path in ("/v1/daily-dialect-challenge", "/functions/v1/daily-dialect-challenge"):
            return self.daily_challenge()
        if path.path not in ("/v1/language-directory", "/functions/v1/language-directory"):
            return self.respond({"error": "not_found"}, 404)
        query = parse_qs(path.query)
        filters = {name: normalized(query.get(name, [""])[0]) for name in FIELDS}
        result = {**DATA, "generatedAt": DATA.get("generatedAt"), "filters": filters}
        for name in ("entities", "variants", "coverageScopes", "surveyPoints", "sources"):
            result[name] = [row for row in DATA.get(name, []) if include(row, filters)]
        result["counts"] = {
            "ethnicities": len(result["entities"]), "entities": len(result["entities"]),
            "variants": len(result["variants"]), "coverageScopes": len(result["coverageScopes"]),
            "surveyPoints": len(result["surveyPoints"]),
        }
        return self.respond(result)

    def daily_challenge(self):
        today = time.strftime("%Y-%m-%d", time.localtime(time.time() + 8 * 60 * 60))
        now_iso = time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())
        eligible = [item for item in DAILY_CHALLENGES
                    if item.get("review_status") == "approved" and str(item.get("challenge_date", "")) <= today
                    and str(item.get("audio", {}).get("expires_at", "")) > now_iso]
        if not eligible:
            return self.respond({"error": "no_licensed_audio"}, 404)
        selected = sorted(eligible, key=lambda item: str(item["challenge_date"]), reverse=True)[0]
        return self.respond({key: value for key, value in selected.items()
                             if key not in ("challenge_date", "review_status")})

    def do_POST(self):
        route = urlparse(self.path).path
        if route in ("/v1/dialect-ai", "/functions/v1/dialect-ai"):
            return self.dialect_ai()
        if route in ("/v1/dialect-voice-assess", "/functions/v1/dialect-voice-assess"):
            return self.dialect_voice_assess()
        if route not in ("/v1/huawei-login", "/functions/v1/huawei-login"):
            return self.respond({"error": "not_found"}, 404)
        try:
            content_length = int(self.headers.get("Content-Length", "0"))
            if content_length <= 0 or content_length > 8192:
                return self.respond({"error": "invalid_request"}, 400)
            body = json.loads(self.rfile.read(content_length).decode("utf-8"))
            authorization_code = str(body.get("authorizationCode", "")).strip()
            if not authorization_code:
                return self.respond({"error": "missing_authorization_code"}, 400)
            token_response = exchange_huawei_authorization_code(authorization_code)
            user_id = jwt_subject(str(token_response.get("id_token", "")))
            signing_key = os.environ.get("XIANGYIN_SESSION_SIGNING_KEY", "").strip()
            if not user_id or len(signing_key) < 32:
                return self.respond({"error": "huawei_login_unavailable"}, 503)
            access_token, expires_at = make_session_token(user_id, signing_key)
            return self.respond({"userId": user_id, "displayName": "鸿蒙用户",
                                 "accessToken": access_token, "expiresAt": expires_at})
        except RuntimeError as error:
            if str(error) == "huawei_login_not_configured":
                return self.respond({"error": "huawei_login_not_configured"}, 503)
            return self.respond({"error": "huawei_login_failed"}, 502)
        except (HTTPError, URLError, TimeoutError, json.JSONDecodeError, UnicodeDecodeError):
            return self.respond({"error": "huawei_login_failed"}, 502)

    def dialect_ai(self):
        try:
            length = int(self.headers.get("Content-Length", "0"))
            body = json.loads(self.rfile.read(length).decode("utf-8"))
            text = str(body.get("text") or "").strip()
            if not 1 <= len(text) <= 2000:
                return self.respond({"error": "text_required"}, 400)
            return self.respond(normalize_ai_result(request_deepseek(text)))
        except RuntimeError as error:
            return self.respond({"error": str(error)}, 503)
        except (HTTPError, URLError, TimeoutError, json.JSONDecodeError, UnicodeDecodeError, IndexError):
            return self.respond({"error": "upstream_failed"}, 502)

    def dialect_voice_assess(self):
        try:
            length = int(self.headers.get("Content-Length", "0"))
            if length <= 0 or length > 700000:
                return self.respond({"error": "invalid_audio_contract"}, 400)
            body = json.loads(self.rfile.read(length).decode("utf-8"))
            if body.get("sampleRate") != 16000 or body.get("channels") != 1 or body.get("format") != "pcm_s16le":
                return self.respond({"error": "invalid_audio_contract"}, 400)
            duration = body.get("durationSeconds")
            if not isinstance(duration, (int, float)) or duration < 2 or duration > 15:
                return self.respond({"error": "invalid_audio_contract"}, 400)
            encoded = str(body.get("audioBase64") or "")
            pcm = base64.b64decode(encoded, validate=True)
            if len(pcm) > 480000:
                return self.respond({"error": "audio_too_large"}, 413)
            expected_max = int(float(duration) * 16000 * 2) + 4096
            if len(pcm) == 0 or len(pcm) > expected_max:
                return self.respond({"error": "invalid_audio_contract"}, 400)
            transcript, stt_confidence = transcribe_pcm(pcm)
            text_result = normalize_ai_result(request_deepseek(transcript))
            unknown = bool(text_result["isUnknown"])
            assessment = {
                "classificationId": text_result["classificationId"] or "unclassified",
                "dialectName": text_result["primaryDialect"] or "暂未判定",
                "ethnicity": text_result["ethnicity"] or "",
                "language": text_result["language"] or "",
                "dialect": text_result["dialect"] or "",
                "dialectFamily": text_result["dialectFamily"] or "待确认",
                "dialectGroup": text_result["dialectGroup"] or "待确认",
                "dialectBranch": "",
                "regionName": text_result["regionName"] or "待确认地区",
                "regionCandidates": text_result["regionCandidates"],
                "coverageScopes": text_result["coverageScopes"],
                "confidence": round(float(text_result["confidence"]) * 100),
                "retention": 0,
                "evidence": text_result["evidence"],
                "similarDialects": [],
                "needsConfirmation": bool(text_result["needsConfirmation"]),
                "isUnknown": unknown,
                "sourceStatus": text_result["sourceStatus"],
                "isSimulated": False,
            }
            return self.respond({"sourceMode": "text_assisted", "transcript": transcript,
                                 "sttConfidence": stt_confidence, "assessment": assessment})
        except RuntimeError as error:
            return self.respond({"error": str(error)}, 503)
        except (ValueError, HTTPError, URLError, TimeoutError, json.JSONDecodeError, UnicodeDecodeError, IndexError):
            return self.respond({"error": "upstream_failed"}, 502)

    def do_OPTIONS(self):
        self.send_response(204)
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "authorization, x-client-info, apikey, content-type")
        self.end_headers()

    def respond(self, payload, code=200):
        encoded = json.dumps(payload, ensure_ascii=False, separators=(",", ":")).encode()
        self.send_response(code)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Cache-Control", "public, max-age=60")
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Content-Length", str(len(encoded)))
        self.end_headers()
        self.wfile.write(encoded)

if __name__ == "__main__":
    ThreadingHTTPServer(("127.0.0.1", 9080), Handler).serve_forever()
