#!/usr/bin/env python3
import io
import subprocess
import tarfile
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
EXTRACTOR = ROOT / "scripts" / "extract-release-binary.py"


class ExtractReleaseBinaryTest(unittest.TestCase):
    def test_extracts_only_the_executable_regular_file(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            archive = root / "release.tar.gz"
            destination = root / "tool"
            with tarfile.open(archive, "w:gz") as bundle:
                completion = tarfile.TarInfo("share/completions/tool")
                completion.mode = 0o644
                completion.size = 10
                bundle.addfile(completion, io.BytesIO(b"completion"))
                binary = tarfile.TarInfo("bin/tool")
                binary.mode = 0o755
                binary.size = 6
                bundle.addfile(binary, io.BytesIO(b"binary"))

            subprocess.run([EXTRACTOR, archive, "tool", destination], check=True)

            self.assertEqual(destination.read_bytes(), b"binary")
            self.assertEqual(destination.stat().st_mode & 0o777, 0o755)

    def test_rejects_symlink_only_match(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            archive = root / "release.tar.gz"
            destination = root / "tool"
            with tarfile.open(archive, "w:gz") as bundle:
                link = tarfile.TarInfo("tool")
                link.type = tarfile.SYMTYPE
                link.linkname = "/tmp/escape"
                bundle.addfile(link)

            result = subprocess.run([EXTRACTOR, archive, "tool", destination], check=False)

            self.assertNotEqual(result.returncode, 0)
            self.assertFalse(destination.exists())


if __name__ == "__main__":
    unittest.main()
