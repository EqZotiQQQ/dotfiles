import argparse
import dataclasses
import pathlib

DEFAULT_USER_LOCATION = pathlib.Path.home()


@dataclasses.dataclass
class AppSettings:
    symlinks: bool
    update_symlinks: bool
    overwrite: bool
    install_ubuntu_apps: bool
    ubuntu_opts: list
    install_manjaro_apps: bool
    manjaro_opts: list
    config_directory: pathlib.Path
    config_destination: pathlib.Path

    @staticmethod
    def add_args(parser: argparse.ArgumentParser) -> None:
        parser.add_argument(
            "-p",
            "--path",
            metavar="PATH",
            type=pathlib.Path,
            default=pathlib.Path(__file__).parent.parent / "home",
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
            help="Install apps for Ubuntu (pass --ubuntu-opts to forward flags to ubuntu.sh)"
        )
        parser.add_argument(
            "--ubuntu-opts",
            nargs=argparse.REMAINDER,
            default=[],
            metavar="OPTS",
            help="Flags forwarded to ubuntu.sh (e.g. --workstation, --cpp --python)",
        )
        parser.add_argument(
            "--manjaro-apps",
            action="store_true",
            help="Install apps for Manjaro (pass --manjaro-opts to forward flags to manjaro.sh)"
        )
        parser.add_argument(
            "--manjaro-opts",
            nargs=argparse.REMAINDER,
            default=[],
            metavar="OPTS",
            help="Flags forwarded to manjaro.sh (e.g. --minimal, --wm --editor)",
        )

    @staticmethod
    def from_args(args):
        if args.manjaro_apps and args.ubuntu_apps:
            raise ValueError("--ubuntu-apps and --manjaro-apps are mutually exclusive")
        return AppSettings(
            symlinks=args.symlinks,
            update_symlinks=args.force_symlink_update,
            overwrite=args.overwrite_existing_files,
            install_ubuntu_apps=args.ubuntu_apps,
            ubuntu_opts=args.ubuntu_opts,
            install_manjaro_apps=args.manjaro_apps,
            manjaro_opts=args.manjaro_opts,
            config_directory=args.path,
            config_destination=DEFAULT_USER_LOCATION,
        )
