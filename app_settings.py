import argparse
import dataclasses
import pathlib

DEFAULT_USER_LOCATION = pathlib.Path.home()


@dataclasses.dataclass
class AppSettings:
    symlinks: bool
    update_symlinkgs: bool
    overwrite: bool
    install_ubuntu_apps: bool
    install_manjaro_apps: bool
    config_directory: pathlib.Path
    config_destination: pathlib.Path

    @staticmethod
    def add_args(parser: argparse.ArgumentParser) -> None:
        parser.add_argument(
            "-p",
            "--path",
            metavar="PATH",
            type=pathlib.Path,
            default=pathlib.Path(__file__).parent / "home",
            help="Path to top level config directory",
        )
        parser.add_argument(
            "-s",
            "--symlinks",
            action="store_true",
            help=f"Display symlinks destionation for {DEFAULT_USER_LOCATION}. To do real update you should also use -f"
        )
        parser.add_argument(
            "-f",
            "--force-symlink-update",
            action="store_true",
            help="Without this option real symlinks won't be created. Only destination will be shown",
        )
        parser.add_argument(
            "-o",
            "--overwrite-existing-files",
            action="store_true",
            help="Overwrite existing files. Watch out!",
        )
        parser.add_argument(
            "--ubuntu-apps",
            action="store_true",
            help="Install apps for development for Ubuntu"
        )
        parser.add_argument(
            "--manjaro-apps",
            action="store_true",
            help="Install apps for development for Manjaro"
        )
        parser.add_argument(
            "--clean-install",
            action="store_true",
            help="Install apps, configure symlinks. --reset-symlinks + --ubuntu-apps"
        )

    @staticmethod
    def from_args(args):
        if args.manjaro_apps and args.ubuntu_apps:
            # TODO select distro
            raise 42
        return AppSettings(
            symlinks=args.symlinks,
            update_symlinkgs=args.force_symlink_update,
            overwrite=args.overwrite_existing_files,
            install_ubuntu_apps=args.ubuntu_apps,
            install_manjaro_apps=args.manjaro_apps,
            config_directory=args.path,
            config_destination=DEFAULT_USER_LOCATION,
        )
