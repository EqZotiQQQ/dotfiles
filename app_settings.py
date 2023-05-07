import argparse
import dataclasses
import pathlib

config_default = pathlib.Path.home()


@dataclasses.dataclass
class AppSettings:
    reset_symlinks: bool
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
            "-r",
            "--reset-symlinks",
            action="store_true",
            help=f"Reinit symlinks for {config_default}"
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
            reset_symlinks=args.reset_symlinks,
            install_ubuntu_apps=args.ubuntu_apps,
            install_manjaro_apps=args.manjaro_apps,
            config_directory=args.path,
            config_destination=config_default,
        )
