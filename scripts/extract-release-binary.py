#!/usr/bin/env python3
import os
import shutil
import sys
import tarfile
from pathlib import PurePosixPath


def extract_binary(archive: str, binary_name: str, destination: str) -> None:
    with tarfile.open(archive, "r:gz") as bundle:
        candidates = [
            member
            for member in bundle.getmembers()
            if member.isfile() and PurePosixPath(member.name).name == binary_name
        ]
        executable = [member for member in candidates if member.mode & 0o111]
        selected = executable[0] if len(executable) == 1 else candidates[0] if len(candidates) == 1 else None
        if selected is None:
            raise SystemExit(f"could not identify one regular {binary_name} binary in {archive}")
        source = bundle.extractfile(selected)
        if source is None:
            raise SystemExit(f"could not read {selected.name} from {archive}")
        with source, open(destination, "wb") as output:
            shutil.copyfileobj(source, output)
    os.chmod(destination, 0o755)


if __name__ == "__main__":
    if len(sys.argv) != 4:
        raise SystemExit(f"usage: {sys.argv[0]} ARCHIVE BINARY_NAME DESTINATION")
    extract_binary(*sys.argv[1:])
