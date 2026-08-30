#!/bin/python3

import argparse
import logging
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


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Configure unix system")
    AppSettings.add_args(parser)
    args = parser.parse_args()

    try:
        settings = AppSettings.from_args(args)
    except ValueError as e:
        parser.error(str(e))

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

    if settings.symlinks:
        total_created = total_skipped = total_failed = 0

        bindings = {settings.config_directory: settings.config_destination}
        if (etc_src := install_dir.parent / "etc").exists():
            bindings[etc_src] = pathlib.Path("/etc")
        else:
            logging.debug("no etc/ directory found, skipping")

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
