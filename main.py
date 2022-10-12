import argparse
import logging
import pathlib
import subprocess

from app_settings import AppSettings

logging.basicConfig(level=logging.INFO)


def recursive_update_symlinks(source: pathlib.Path, dst: pathlib.Path) -> None:
    logging.info(f"Source: {source}\n"
                 f"Destination: {dst}")
    for source_file in source.iterdir():
        src_name = source_file.name
        p = dst / src_name
        if source_file.is_file():
            if not p.exists():
                p.symlink_to(source_file)
        else:
            pathlib.Path.mkdir(p, parents=True, exist_ok=True)
            recursive_update_symlinks(source=source / src_name, dst=p)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Configure unix system")

    AppSettings.add_args(parser)
    args = parser.parse_args()

    settings = AppSettings.from_args(args)

    if settings.reset_symlinks:
        pathlib.Path.mkdir(settings.config_destination, parents=True, exist_ok=True)
        recursive_update_symlinks(source=settings.config_directory, dst=settings.config_destination)

    if settings.install_ubuntu_apps:
        ret = subprocess.call("./install_apps.sh", shell=True)



