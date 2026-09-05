#!/bin/python3

import argparse
import collections
import filecmp
import logging
import os
import pathlib
import subprocess
import sys

from app_settings import AppSettings

logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")


def recursive_update_symlinks(
    source: pathlib.Path,
    dst_dir: pathlib.Path,
    apply: bool,
    overwrite: bool,
) -> tuple[int, int, int]:
    created = skipped = failed = 0
    for src_object in source.iterdir():
        dst_object = dst_dir / src_object.name
        if src_object.is_file():
            if not apply:
                logging.info(f"[dry-run] {src_object} -> {dst_object}")
                skipped += 1
                continue
            try:
                exists = dst_object.exists() or dst_object.is_symlink()
                if overwrite and exists:
                    dst_object.unlink()
                    exists = False
                if exists:
                    logging.info(f"skip (exists): {dst_object}")
                    skipped += 1
                else:
                    dst_object.symlink_to(src_object)
                    logging.info(f"linked: {src_object} -> {dst_object}")
                    created += 1
            except PermissionError:
                logging.error(
                    f"permission denied — link manually:\n  sudo ln -sf {src_object} {dst_object}"
                )
                failed += 1
        else:
            if apply and not dst_object.exists():
                dst_object.mkdir(parents=True, exist_ok=True)

            c, s, f = recursive_update_symlinks(
                source=src_object,
                dst_dir=dst_object,
                apply=apply,
                overwrite=overwrite,
            )
            created += c
            skipped += s
            failed += f
    return created, skipped, failed


def link_status(src: pathlib.Path, dst: pathlib.Path) -> tuple[str, str]:
    if dst.is_symlink():
        if not dst.exists():
            return "broken-link", f"-> {dst.readlink()}"
        if dst.resolve() == src.resolve():
            return "linked", ""
        return "wrong-link", f"-> {dst.readlink()}"
    if not dst.exists():
        return "missing", ""
    if filecmp.cmp(src, dst, shallow=False):
        return "copy", "same content, but a real file — edits stay out of the repo"
    return "differs", "real file, content diverged from the repo"


def orphan_links(source: pathlib.Path, dst_dir: pathlib.Path, repo_root: pathlib.Path):
    if not dst_dir.is_dir():
        return
    for entry in sorted(dst_dir.iterdir()):
        if not entry.is_symlink() or entry.exists():
            continue
        if (source / entry.name).exists():
            continue  # already reported by the source walk
        target = pathlib.Path(os.path.normpath(entry.parent / entry.readlink()))
        if repo_root in target.parents:
            yield "orphan", entry, f"-> {target} (no longer in the repo)"


def recursive_check_symlinks(
    source: pathlib.Path,
    dst_dir: pathlib.Path,
    repo_root: pathlib.Path,
):
    for src_object in sorted(source.iterdir()):
        dst_object = dst_dir / src_object.name
        if src_object.is_file():
            status, note = link_status(src_object, dst_object)
            yield status, dst_object, note
        else:
            yield from recursive_check_symlinks(src_object, dst_object, repo_root)
    yield from orphan_links(source, dst_dir, repo_root)


def report_status(bindings: dict, repo_root: pathlib.Path) -> int:
    rows = []
    for source, dst_dir in bindings.items():
        rows.extend(recursive_check_symlinks(source, dst_dir, repo_root))

    home = str(pathlib.Path.home())
    problems = [row for row in rows if row[0] != "linked"]

    for status, dst, note in problems:
        shown = str(dst).replace(home, "~", 1)
        print(f"  {status:<12} {shown}" + (f"  # {note}" if note else ""))
    if problems:
        print()

    counts = collections.Counter(status for status, _, _ in rows)
    summary = ", ".join(f"{count} {status}" for status, count in counts.most_common())
    print(f"{len(rows)} files: {summary}")
    return 1 if problems else 0


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Configure unix system")
    AppSettings.add_args(parser)
    args = parser.parse_args()
    
    try:
        settings = AppSettings.from_args(args)
    except ValueError as e:
        parser.error(str(e))
        exit(1)

    logging.info(f"Executing script with settings:\n{settings}")
    
    install_dir = pathlib.Path(__file__).parent
    # TODO: merge it to unified solution
    if settings.install_ubuntu_apps:
        cmd = [str(install_dir / "ubuntu.sh")] + settings.ubuntu_opts
        ret = subprocess.call(cmd)
        if ret != 0:
            logging.error(f"ubuntu.sh exited with code {ret}")
            sys.exit(ret)

    if settings.install_manjaro_apps:
        cmd = [str(install_dir / "manjaro.sh")] + settings.manjaro_opts
        ret = subprocess.call(cmd)
        if ret != 0:
            logging.error(f"manjaro.sh exited with code {ret}")
            sys.exit(ret)

    repo_root = install_dir.parent.resolve()

    bindings = {settings.config_directory: settings.config_destination}
    if (etc_src := repo_root / "etc").exists():
        bindings[etc_src] = pathlib.Path("/etc")
    else:
        logging.debug("no etc/ directory found, skipping")

    if settings.status:
        sys.exit(report_status(bindings, repo_root))

    if settings.symlinks:
        total_created = total_skipped = total_failed = 0

        for source, dst_dir in bindings.items():
            if settings.update_symlinks:
                dst_dir.mkdir(parents=True, exist_ok=True)

            c, s, f = recursive_update_symlinks(
                source=source,
                dst_dir=dst_dir,
                apply=settings.update_symlinks,
                overwrite=settings.overwrite,
            )
            total_created += c
            total_skipped += s
            total_failed += f

        if not settings.update_symlinks:
            print("\nDry run complete — use -f to apply symlinks.")
        else:
            print(f"\nDone: {total_created} created, {total_skipped} skipped, {total_failed} failed.")
        if total_failed:
            sys.exit(1)
