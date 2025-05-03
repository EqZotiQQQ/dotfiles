#!/bin/python3

import argparse
import logging
import pathlib
import subprocess

from app_settings import AppSettings

logging.basicConfig(level=logging.INFO)

def recursive_update_symlinks(source: pathlib.Path, dst_dir: pathlib.Path, update_symlinks: bool, overwrite: bool) -> None:
    logging.info(f"Dir level: {source} -> {dst_dir}")
    for src_object in source.iterdir():
        src_name = src_object.name
        dst_object = dst_dir / src_name
        if src_object.is_file():
            logging.info(f"File level: {src_object} -> {dst_object}")
            if update_symlinks:
                try:
                    if overwrite and dst_object.exists():
                        logging.info(f"rm {dst_object}")
                        dst_object.unlink()

                    if not dst_object.exists():
                        dst_object.symlink_to(src_object)

                except PermissionError as pe:
                    logging.error(f"Symlink creation failed. Please do manual linking:\nsudo ln -sf {src_object} {dst_object}")
        else:
            if update_symlinks and not dst_object.exists():
                dst_object.mkdir(parents=True, exist_ok=True)
            recursive_update_symlinks(source=source / src_name, dst_dir=dst_object, update_symlinks=update_symlinks, overwrite=overwrite)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Configure unix system")

    AppSettings.add_args(parser)
    args = parser.parse_args()

    settings = AppSettings.from_args(args)

    if settings.install_ubuntu_apps:
        ret = subprocess.call("./ubuntu.sh", shell=True)
    
    if settings.install_manjaro_apps:
        ret = subprocess.call("./manjaro.sh", shell=True)

    if settings.symlinks:
        pathlib.Path.mkdir(settings.config_destination, parents=True, exist_ok=True)
        recursive_update_symlinks(source=settings.config_directory, dst_dir=settings.config_destination, update_symlinks=settings.update_symlinkgs, overwrite=settings.overwrite)

        etc_src_dir_path = pathlib.Path(__file__).parent / "etc"
        etc_dst_dir_path = pathlib.Path("/etc")
        recursive_update_symlinks(source=etc_src_dir_path, dst_dir=etc_dst_dir_path, update_symlinks=settings.update_symlinkgs, overwrite=settings.overwrite)
    
