#!/usr/bin/env python3
import io
import subprocess
import sys
import tarfile
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
EXTRACTOR = ROOT / "scripts" / "extract-cursor-theme.py"


class ExtractCursorThemeTest(unittest.TestCase):
    def run_extractor(self, archive: Path, destination: Path) -> subprocess.CompletedProcess[str]:
        return subprocess.run(
            [sys.executable, str(EXTRACTOR), str(archive), "Bibata-Modern-Ice", str(destination)],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            check=False,
        )

    def test_extracts_expected_cursor_root_with_index_theme(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            archive = root / "Bibata-Modern-Ice.tar.xz"
            destination = root / "staged"
            with tarfile.open(archive, "w:xz") as bundle:
                theme_dir = tarfile.TarInfo("Bibata-Modern-Ice")
                theme_dir.type = tarfile.DIRTYPE
                bundle.addfile(theme_dir)
                index = tarfile.TarInfo("Bibata-Modern-Ice/index.theme")
                data = b"[Icon Theme]\nName=Bibata-Modern-Ice\n"
                index.mode = 0o644
                index.size = len(data)
                bundle.addfile(index, io.BytesIO(data))
                cursor = tarfile.TarInfo("Bibata-Modern-Ice/cursors/left_ptr")
                cursor.mode = 0o644
                cursor.size = 6
                bundle.addfile(cursor, io.BytesIO(b"cursor"))

            result = self.run_extractor(archive, destination)

            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual((destination / "index.theme").read_bytes(), data)
            self.assertEqual((destination / "cursors" / "left_ptr").read_bytes(), b"cursor")

    def test_rejects_path_traversal(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            archive = root / "bad.tar.xz"
            destination = root / "staged"
            with tarfile.open(archive, "w:xz") as bundle:
                bad = tarfile.TarInfo("Bibata-Modern-Ice/../../escape")
                bad.size = 1
                bundle.addfile(bad, io.BytesIO(b"x"))

            result = self.run_extractor(archive, destination)

            self.assertNotEqual(result.returncode, 0)
            self.assertIn("unsafe archive path", result.stderr)
            self.assertFalse(destination.exists())

    def test_rejects_symlink_outside_theme_root(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            archive = root / "bad-link.tar.xz"
            destination = root / "staged"
            with tarfile.open(archive, "w:xz") as bundle:
                link = tarfile.TarInfo("Bibata-Modern-Ice/cursors/left_ptr")
                link.type = tarfile.SYMTYPE
                link.linkname = "../../outside"
                bundle.addfile(link)

            result = self.run_extractor(archive, destination)

            self.assertNotEqual(result.returncode, 0)
            self.assertIn("unsafe archive link", result.stderr)
            self.assertFalse(destination.exists())


if __name__ == "__main__":
    unittest.main()
