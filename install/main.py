#!/bin/python3

import argparse
import collections
import filecmp
import logging
import os
import pathlib
import shutil
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


def repo_path_for(live: pathlib.Path, bindings: dict) -> pathlib.Path | None:
    """Map a live path back to the repo file that should hold it."""
    for source_root, dst_root in bindings.items():
        try:
            return source_root / live.relative_to(dst_root)
        except ValueError:
            continue
    return None


def adopt_targets(path: pathlib.Path):
    """A directory adopts every file under it; anything else adopts itself."""
    if path.is_dir() and not path.is_symlink():
        yield from (child for child in sorted(path.rglob("*")) if not child.is_dir())
    else:
        yield path


def adopt_file(
    live: pathlib.Path,
    repo_file: pathlib.Path,
    apply: bool,
    overwrite: bool,
) -> tuple[str, str]:
    if live.is_symlink():
        return "skip", "already a symlink"
    if not live.exists():
        return "error", "no such file"

    if repo_file.exists():
        if filecmp.cmp(live, repo_file, shallow=False):
            action = "relink"  # identical content, only the symlink is missing
        elif overwrite:
            action = "replace"  # repo copy loses to the live one
        else:
            return "refuse", f"repo copy differs — diff {repo_file} {live} — then re-run with -o"
    else:
        action = "adopt"

    if not apply:
        return f"[dry-run] {action}", ""

    repo_file.parent.mkdir(parents=True, exist_ok=True)
    if action == "relink":
        live.unlink()
    else:
        if action == "replace":
            repo_file.unlink()
        shutil.move(str(live), str(repo_file))
    live.symlink_to(repo_file)
    return action, ""


def adopt_paths(
    paths: list,
    bindings: dict,
    repo_root: pathlib.Path,
    apply: bool,
    overwrite: bool,
) -> int:
    failed = 0
    for raw in paths:
        path = pathlib.Path(os.path.abspath(pathlib.Path(raw).expanduser()))

        if repo_root == path or repo_root in path.parents:
            logging.error(f"refusing to adopt a path inside the repo: {path}")
            failed += 1
            continue

        for live in adopt_targets(path):
            repo_file = repo_path_for(live, bindings)
            if repo_file is None:
                logging.error(f"{live} is outside every configured destination — cannot map it into the repo")
                failed += 1
                continue

            action, note = adopt_file(live, repo_file, apply, overwrite)
            message = f"{action}: {live} -> {repo_file}" + (f"  # {note}" if note else "")
            if action in ("refuse", "error"):
                logging.error(message)
                failed += 1
            else:
                logging.info(message)

    if not apply:
        print("\nDry run complete — use -f to move files into the repo.")
    if failed:
        print(f"{failed} path(s) need attention.")
    return 1 if failed else 0


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

    if settings.adopt:
        sys.exit(
            adopt_paths(
                paths=settings.adopt,
                bindings=bindings,
                repo_root=repo_root,
                apply=settings.update_symlinks,
                overwrite=settings.overwrite,
            )
        )

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
