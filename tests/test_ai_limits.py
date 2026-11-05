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
        "id": 3, "platform": "openai", "name": "Alex Example", "status": "active", "schedulable": True,
        "updated_at": "2026-11-02T16:02:44+03:00",
        "last_used_at": None, "rate_limit_reset_at": None,
        "overload_until": None, "temp_unschedulable_until": None,
        "input_tokens": None, "cache_creation_tokens": None, "cache_read_tokens": None,
        "windows": [
            {"label": "5h", "minutes": 300, "used": 0,
             "reset_at": "2026-11-02T21:02:44+03:00"},
            {"label": "7d", "minutes": 10080, "used": 100,
             "reset_at": "2026-11-05T15:38:40+03:00"},
        ],
    }
    row.update(changes)
    return row


class QuotaTests(unittest.TestCase):
    def test_used_quota_and_timezone(self):
        result = NORMALIZE([account()])[0]
        self.assertEqual(result["windows"][0]["used_percent"], 0)
        self.assertEqual(result["windows"][1]["used_percent"], 100)
        self.assertEqual(result["updated_at"], 1793624564)
        self.assertEqual(result["windows"][0]["reset_at"] - result["updated_at"], 5 * 3600)

    def test_unknown_or_absent_window_does_not_show_zero_usage(self):
        for changes in ({"used": None}, {"minutes": None}, {"minutes": 0}):
            with self.subTest(changes=changes):
                row = account()
                row["windows"][0].update(changes)
                window = NORMALIZE([row])[0]["windows"][0]
                self.assertIsNone(window["used_percent"])

    def test_expired_window_keeps_observed_quota(self):
        row = account(updated_at="2020-01-01T00:00:00Z")
        row["windows"][0].update(used=83.5, reset_at="2020-01-01T05:00:00Z")
        result = NORMALIZE([row])[0]
        self.assertEqual(result["windows"][0]["used_percent"], 83.5)
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
                row["windows"][0]["used"] = value
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

    def test_provider_names_and_claude_fractional_usage(self):
        claude = account(id=2, platform="anthropic")
        claude["windows"][0]["used"] = 0.375
        claude["windows"][1]["used"] = 0.08
        rows = NORMALIZE([account(), account(id=4, name="Second User"), claude])
        self.assertEqual([r["name"] for r in rows], ["Alex Example", "Second User", "ClaudeAccount1"])
        self.assertEqual([r["provider"] for r in rows], ["Codex", "Codex", "Claude"])
        self.assertEqual(rows[2]["windows"][0]["used_percent"], 37.5)
        self.assertEqual(rows[2]["windows"][1]["used_percent"], 8)

    def test_cache_miss_includes_new_cache_writes_but_not_cache_hits(self):
        row = account(input_tokens=314, cache_creation_tokens=1024, cache_read_tokens=27904)
        result = NORMALIZE([row])[0]
        self.assertEqual(result["cache_miss_tokens"], 1338)
        self.assertEqual(result["cache_hit_tokens"], 27904)
        missing = NORMALIZE([account()])[0]
        self.assertIsNone(missing["cache_miss_tokens"])
        self.assertIsNone(missing["cache_hit_tokens"])
        zero = NORMALIZE([account(input_tokens=0, cache_creation_tokens=0, cache_read_tokens=0)])[0]
        self.assertEqual(zero["cache_miss_tokens"], 0)
        self.assertEqual(zero["cache_hit_tokens"], 0)

    def test_invalid_cache_tokens_are_an_error(self):
        for value in (-1, 0.5, "100", True):
            with self.subTest(value=value), self.assertRaises(ValueError):
                NORMALIZE([account(cache_read_tokens=value)])


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
