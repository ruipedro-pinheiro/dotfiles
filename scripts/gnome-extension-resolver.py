#!/usr/bin/env python3
import json
import sys
from urllib.parse import urlsplit


EGO_ORIGIN = "https://extensions.gnome.org"
DOWNLOAD_PREFIX = "/download-extension/"


def resolve_download_url(expected_uuid: str, raw_json: str) -> str:
    try:
        payload = json.loads(raw_json)
    except json.JSONDecodeError as error:
        raise SystemExit(f"invalid extension-info JSON: {error}") from error

    if not isinstance(payload, dict):
        raise SystemExit("invalid extension-info JSON: expected object")

    actual_uuid = payload.get("uuid")
    if actual_uuid != expected_uuid:
        raise SystemExit(f"extension UUID mismatch: expected {expected_uuid}, got {actual_uuid!r}")

    download_url = payload.get("download_url")
    if not isinstance(download_url, str):
        raise SystemExit("untrusted extension download_url: missing string")

    parsed = urlsplit(download_url)
    if parsed.scheme or parsed.netloc or not parsed.path.startswith(DOWNLOAD_PREFIX):
        raise SystemExit("untrusted extension download_url: expected extensions.gnome.org download path")
    if any(character.isspace() for character in download_url):
        raise SystemExit("untrusted extension download_url: whitespace is not allowed")

    return EGO_ORIGIN + download_url


if __name__ == "__main__":
    if len(sys.argv) != 2:
        raise SystemExit(f"usage: {sys.argv[0]} EXPECTED_UUID")
    print(resolve_download_url(sys.argv[1], sys.stdin.read()))
