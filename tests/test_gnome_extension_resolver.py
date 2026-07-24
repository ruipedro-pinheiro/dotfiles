#!/usr/bin/env python3
import json
import subprocess
import sys
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
RESOLVER = ROOT / "scripts" / "gnome-extension-resolver.py"


class GnomeExtensionResolverTest(unittest.TestCase):
    def run_resolver(self, expected_uuid: str, payload: object) -> subprocess.CompletedProcess[str]:
        return subprocess.run(
            [sys.executable, str(RESOLVER), expected_uuid],
            input=json.dumps(payload),
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            check=False,
        )

    def test_accepts_matching_uuid_and_ego_download_path(self) -> None:
        result = self.run_resolver(
            "dash-to-dock@micxgx.gmail.com",
            {
                "uuid": "dash-to-dock@micxgx.gmail.com",
                "download_url": "/download-extension/dash-to-dock@micxgx.gmail.com.shell-extension.zip?version_tag=1",
            },
        )

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(
            result.stdout.strip(),
            "https://extensions.gnome.org/download-extension/dash-to-dock@micxgx.gmail.com.shell-extension.zip?version_tag=1",
        )

    def test_rejects_malformed_json(self) -> None:
        result = subprocess.run(
            [sys.executable, str(RESOLVER), "dash-to-dock@micxgx.gmail.com"],
            input="not json",
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            check=False,
        )

        self.assertNotEqual(result.returncode, 0)
        self.assertIn("invalid extension-info JSON", result.stderr)

    def test_rejects_mismatched_uuid(self) -> None:
        result = self.run_resolver(
            "dash-to-dock@micxgx.gmail.com",
            {
                "uuid": "other@example.com",
                "download_url": "/download-extension/other.shell-extension.zip",
            },
        )

        self.assertNotEqual(result.returncode, 0)
        self.assertIn("extension UUID mismatch", result.stderr)

    def test_rejects_untrusted_download_url(self) -> None:
        result = self.run_resolver(
            "dash-to-dock@micxgx.gmail.com",
            {
                "uuid": "dash-to-dock@micxgx.gmail.com",
                "download_url": "https://evil.example/extension.zip",
            },
        )

        self.assertNotEqual(result.returncode, 0)
        self.assertIn("untrusted extension download_url", result.stderr)


if __name__ == "__main__":
    unittest.main()
