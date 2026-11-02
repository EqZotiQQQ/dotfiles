import json
from pathlib import Path
import runpy
import subprocess
import unittest
from unittest.mock import patch


SCRIPT = Path(__file__).resolve().parents[1] / "home/.config/quickshell/scripts/ai-limits"
MODULE = runpy.run_path(str(SCRIPT))
NORMALIZE = MODULE["normalize"]
FETCH = MODULE["fetch"]
READ = MODULE["read_accounts"]


def account(**changes):
    row = {
        "id": 3, "name": "Personal", "status": "active", "schedulable": True,
        "updated_at": "2026-11-02T16:02:44+03:00",
        "last_used_at": None, "rate_limit_reset_at": None,
        "overload_until": None, "temp_unschedulable_until": None,
        "windows": [
            {"label": "5 ч", "minutes": 300, "used_percent": 0,
             "reset_at": "2026-11-02T21:02:44+03:00"},
            {"label": "7 д", "minutes": 10080, "used_percent": 100,
             "reset_at": "2026-11-05T15:38:40+03:00"},
        ],
    }
    row.update(changes)
    return row


class QuotaTests(unittest.TestCase):
    def test_remaining_quota_and_timezone(self):
        result = NORMALIZE([account()])[0]
        self.assertEqual(result["windows"][0]["remaining_percent"], 100)
        self.assertEqual(result["windows"][1]["remaining_percent"], 0)
        self.assertEqual(result["updated_at"], 1793624564)
        self.assertEqual(result["windows"][0]["reset_at"] - result["updated_at"], 5 * 3600)

    def test_unknown_or_absent_window_does_not_show_full_quota(self):
        for changes in ({"used_percent": None}, {"minutes": None}, {"minutes": 0}):
            with self.subTest(changes=changes):
                row = account()
                row["windows"][0].update(changes)
                window = NORMALIZE([row])[0]["windows"][0]
                self.assertIsNone(window["remaining_percent"])

    def test_expired_window_keeps_observed_quota(self):
        row = account(updated_at="2020-01-01T00:00:00Z")
        row["windows"][0].update(used_percent=83.5, reset_at="2020-01-01T05:00:00Z")
        result = NORMALIZE([row])[0]
        self.assertEqual(result["windows"][0]["remaining_percent"], 16.5)
        self.assertLess(result["windows"][0]["reset_at"], 1600000000)

    def test_accounts_and_missing_timestamps_remain_distinct(self):
        other = account(id=4, updated_at=None, status="disabled", schedulable=False)
        other["windows"][0]["reset_at"] = None
        rows = NORMALIZE([account(), other])
        self.assertEqual([row["id"] for row in rows], [3, 4])
        self.assertIsNone(rows[1]["updated_at"])
        self.assertIsNone(rows[1]["windows"][0]["reset_at"])
        self.assertFalse(rows[1]["schedulable"])
        self.assertEqual(NORMALIZE([]), [])

    def test_invalid_quota_is_an_error(self):
        for value in (-1, 101, "unknown", float("nan"), float("inf"), True):
            with self.subTest(value=value):
                row = account()
                row["windows"][0]["used_percent"] = value
                with self.assertRaises(ValueError):
                    NORMALIZE([row])

    def test_invalid_timestamp_is_an_error(self):
        for value in ("broken", "2026-11-02T16:02:44"):
            with self.subTest(value=value), self.assertRaises(ValueError):
                NORMALIZE([account(updated_at=value)])

    def test_activity_and_restrictions_preserve_absolute_times(self):
        row = account(
            last_used_at="2026-11-02T16:02:44.123456+03:00",
            rate_limit_reset_at="2026-11-02T17:02:44+03:00",
            overload_until="2026-11-02T13:03:44Z",
            temp_unschedulable_until="2026-11-02T16:12:44+03:00",
        )
        result = NORMALIZE([row])[0]
        self.assertEqual(result["last_used_at"], 1793624564)
        self.assertEqual(result["rate_limit_reset_at"] - result["last_used_at"], 3600)
        self.assertEqual(result["overload_until"] - result["last_used_at"], 60)
        self.assertEqual(result["temp_unschedulable_until"] - result["last_used_at"], 600)

    def test_missing_activity_and_restrictions_stay_unknown(self):
        result = NORMALIZE([account()])[0]
        for field in ("last_used_at", "rate_limit_reset_at", "overload_until", "temp_unschedulable_until"):
            self.assertIsNone(result[field])


class TransportTests(unittest.TestCase):
    def test_database_read_is_bounded_and_read_only(self):
        completed = subprocess.CompletedProcess([], 0, json.dumps([account()]), "")
        with patch("subprocess.run", return_value=completed) as run:
            self.assertEqual(READ(), [account()])
        args, kwargs = run.call_args
        self.assertIn("sub2api-postgres", args[0])
        self.assertIn("BEGIN READ ONLY", kwargs["input"])
        self.assertIn("statement_timeout", kwargs["input"])
        self.assertIn("ON_ERROR_STOP=1", args[0][-1])
        self.assertNotIn("credentials", kwargs["input"])
        self.assertLessEqual(kwargs["timeout"], 10)

    def test_ssh_executes_the_same_collector_on_vps(self):
        payload = {"accounts": NORMALIZE([account()])}
        completed = subprocess.CompletedProcess([], 0, json.dumps(payload), "")
        with patch("subprocess.run", return_value=completed) as run:
            self.assertEqual(FETCH("ruweb_hosting"), payload)
        args, kwargs = run.call_args
        self.assertEqual(args[0][-4:], ["ruweb_hosting", "python3", "-", "--snapshot"])
        self.assertIn("BatchMode=yes", args[0])
        self.assertEqual(kwargs["input"], SCRIPT.read_text())
        self.assertLessEqual(kwargs["timeout"], 20)

    def test_ssh_failure_is_not_an_empty_success(self):
        with patch("subprocess.run", side_effect=subprocess.CalledProcessError(255, "ssh")):
            with self.assertRaises(subprocess.CalledProcessError):
                FETCH("ruweb_hosting")

    def test_timeout_is_not_hidden(self):
        with patch("subprocess.run", side_effect=subprocess.TimeoutExpired("ssh", 20)):
            with self.assertRaises(subprocess.TimeoutExpired):
                FETCH("ruweb_hosting")


if __name__ == "__main__":
    unittest.main()
