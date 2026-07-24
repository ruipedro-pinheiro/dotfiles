#!/usr/bin/env python3
import os
import shutil
import sys
import tarfile
from pathlib import Path, PurePosixPath


def safe_parts(name: str) -> PurePosixPath:
    path = PurePosixPath(name)
    if path.is_absolute() or ".." in path.parts or not path.parts:
        raise SystemExit(f"unsafe archive path: {name}")
    return path


def link_target_is_inside_theme(member_path: PurePosixPath, linkname: str, expected_root: str) -> bool:
    target = PurePosixPath(linkname)
    if target.is_absolute():
        return False
    combined = member_path.parent.joinpath(target)
    normalized: list[str] = []
    for part in combined.parts:
        if part in ("", "."):
            continue
        if part == "..":
            if not normalized:
                return False
            normalized.pop()
        else:
            normalized.append(part)
    return bool(normalized) and normalized[0] == expected_root


def extract_cursor_theme(archive: str, expected_root: str, destination: str) -> None:
    destination_path = Path(destination)
    staging_path = destination_path.with_name(destination_path.name + ".staging")
    if staging_path.exists() or staging_path.is_symlink():
        shutil.rmtree(staging_path)

    with tarfile.open(archive, "r:xz") as bundle:
        members = bundle.getmembers()
        for member in members:
            member_path = safe_parts(member.name)
            if (member.issym() or member.islnk()) and not link_target_is_inside_theme(
                member_path, member.linkname, expected_root
            ):
                raise SystemExit(f"unsafe archive link: {member.name} -> {member.linkname}")

        root_prefix = expected_root + "/"
        root_seen = any(member.name == expected_root or member.name.startswith(root_prefix) for member in members)
        index_seen = any(member.name == f"{expected_root}/index.theme" and member.isfile() for member in members)
        if not root_seen or not index_seen:
            raise SystemExit(f"archive must contain {expected_root}/index.theme")

        for member in members:
            member_path = safe_parts(member.name)
            if member_path.parts[0] != expected_root:
                raise SystemExit(f"unsafe archive path: {member.name}")
            if member.ischr() or member.isblk() or member.isfifo() or member.isdev():
                raise SystemExit(f"unsafe archive member type: {member.name}")
            if (member.issym() or member.islnk()) and not link_target_is_inside_theme(
                member_path, member.linkname, expected_root
            ):
                raise SystemExit(f"unsafe archive link: {member.name} -> {member.linkname}")

        for member in members:
            member_path = PurePosixPath(member.name)
            relative = Path(*member_path.parts[1:]) if len(member_path.parts) > 1 else Path()
            target = staging_path / relative
            if member.isdir():
                target.mkdir(parents=True, exist_ok=True)
            elif member.isfile():
                target.parent.mkdir(parents=True, exist_ok=True)
                source = bundle.extractfile(member)
                if source is None:
                    raise SystemExit(f"could not read archive member: {member.name}")
                with source, open(target, "wb") as output:
                    shutil.copyfileobj(source, output)
                os.chmod(target, member.mode & 0o777)
            elif member.issym():
                target.parent.mkdir(parents=True, exist_ok=True)
                os.symlink(member.linkname, target)
            elif member.islnk():
                raise SystemExit(f"unsupported archive hard link: {member.name}")

    if destination_path.exists() or destination_path.is_symlink():
        shutil.rmtree(destination_path)
    staging_path.rename(destination_path)


if __name__ == "__main__":
    if len(sys.argv) != 4:
        raise SystemExit(f"usage: {sys.argv[0]} ARCHIVE EXPECTED_ROOT DESTINATION")
    extract_cursor_theme(*sys.argv[1:])
