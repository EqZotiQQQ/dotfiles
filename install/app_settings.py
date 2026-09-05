import argparse
import dataclasses
import pathlib

DEFAULT_USER_LOCATION = pathlib.Path.home()

EXAMPLES = """\
examples:
  %(prog)s --status                                  what diverged between the repo and ~
  %(prog)s --symlinks -f                             link home/ into ~ (and wallpapers/)
  %(prog)s --adopt ~/.config/kitty -f                pull an existing config into the repo
  %(prog)s --profile desktop --symlinks -f           fresh install: packages + symlinks
  %(prog)s --os ubuntu --profile workstation --open-source --symlinks -f
  %(prog)s --wm --editor                             install single components
"""


@dataclasses.dataclass
class AppSettings:
    symlinks: bool
    status: bool
    adopt: list
    update_symlinks: bool
    overwrite: bool
    os_name: str
    profile: str
    open_source: bool
    extra_flags: list
    config_directory: pathlib.Path
    config_destination: pathlib.Path

    @staticmethod
    def add_args(parser: argparse.ArgumentParser) -> None:
        links = parser.add_argument_group("symlinks")
        links.add_argument(
            "-s",
            "--symlinks",
            action="store_true",
            help=f"Link the repo into {DEFAULT_USER_LOCATION} (and wallpapers into ~/Pictures). Dry-run unless -f",
        )
        links.add_argument(
            "--status",
            action="store_true",
            help="Report how every config file in the repo maps to its destination and exit 1 on any divergence",
        )
        links.add_argument(
            "--adopt",
            nargs="+",
            default=[],
            metavar="PATH",
            type=pathlib.Path,
            help="Move existing files from the system into the repo and symlink them back. "
                 "Accepts files or directories. Dry-run unless -f is given; "
                 "-o takes the system version when the repo already has a different copy",
        )
        links.add_argument(
            "-f",
            "--force-symlink-update",
            action="store_true",
            help="Apply. Without it -s and --adopt only report what they would do",
        )
        links.add_argument(
            "-o",
            "--overwrite-existing-files",
            action="store_true",
            help="Overwrite what is already there. Watch out!",
        )
        links.add_argument(
            "-p",
            "--path",
            metavar="PATH",
            type=pathlib.Path,
            default=pathlib.Path(__file__).parent.parent / "home",
            help="Path to top level config directory",
        )

        packages = parser.add_argument_group("packages")
        packages.add_argument(
            "--os",
            dest="os_name",
            metavar="NAME",
            default="",
            help="Target OS: manjaro | ubuntu (auto-detected from /etc/os-release if omitted)",
        )
        packages.add_argument(
            "--profile",
            metavar="NAME",
            default="",
            help="Profile for the OS install script: manjaro: minimal | desktop | full; "
                 "ubuntu: minimal | workstation | full",
        )
        packages.add_argument(
            "--open-source",
            action="store_true",
            help="Build from source via open_source.sh --all",
        )

    @staticmethod
    def from_args(args, extra_flags: list):
        bad = [flag for flag in extra_flags if not flag.startswith("--")]
        if bad:
            raise ValueError(f"unknown argument(s): {' '.join(bad)}")
        return AppSettings(
            symlinks=args.symlinks,
            status=args.status,
            adopt=args.adopt,
            update_symlinks=args.force_symlink_update,
            overwrite=args.overwrite_existing_files,
            os_name=args.os_name,
            profile=args.profile,
            open_source=args.open_source,
            extra_flags=extra_flags,
            config_directory=args.path,
            config_destination=DEFAULT_USER_LOCATION,
        )
