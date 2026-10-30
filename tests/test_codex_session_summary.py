import json
import os
from pathlib import Path
import runpy
import shlex
import subprocess
import tempfile
import time
import unittest


ROOT = Path(__file__).resolve().parents[1]
HOOK = ROOT / "home/.codex/hooks/session-summary"
MODULE = runpy.run_path(str(HOOK))


def response(payload):
    return {"timestamp": "2026-10-30T09:00:00Z", "type": "response_item", "payload": payload}


def message(role, text, **extra):
    return response({
        "type": "message", "role": role,
        "content": [{"type": "input_text" if role == "user" else "output_text", "text": text}],
        **extra,
    })


class SessionSummaryTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.work = Path(self.temporary.name)
        self.transcript = self.work / "rollout.jsonl"
        self.out_root = self.work / "summaries"
        self.env = dict(
            os.environ, HOME=str(self.work), CODEX_SESSION_SUMMARY_DIR=str(self.out_root), TZ="UTC",
        )
        self.env.pop("CODEX_SESSION_SUMMARY", None)
        self.event = {
            "session_id": "12345678-abcd-4321-9876-123456789abc",
            "transcript_path": str(self.transcript),
            "cwd": "/projects/project 'with spaces'",
            "reason": "other", "hook_event_name": "SessionEnd",
        }
        self.write_transcript([message("user", "Добавь экспорт"), message("assistant", "Экспорт добавлен")])
        commands = self.work / "bin"
        commands.mkdir()
        self.env["PATH"] = str(commands) + os.pathsep + os.environ["PATH"]
        codex = commands / "codex"
        codex.write_text("""#!/usr/bin/env python3
import json, os, pathlib, sys, time
record = {'args': sys.argv[1:], 'input': sys.stdin.read(),
          'guard': os.environ.get('CODEX_SESSION_SUMMARY'), 'cwd': os.getcwd()}
pathlib.Path(os.environ['HOME'], 'codex-call.json').write_text(json.dumps(record))
time.sleep(float(os.environ.get('TEST_CODEX_DELAY', '0')))
if os.environ.get('TEST_CODEX_FAIL'):
    sys.exit(7)
output = pathlib.Path(sys.argv[sys.argv.index('--output-last-message') + 1])
output.write_text('' if os.environ.get('TEST_CODEX_EMPTY') else '# Экспорт данных\\n\\n**Сделано** — добавлен экспорт.')
""")
        codex.chmod(0o755)
        rsync = commands / "rsync"
        rsync.write_text("""#!/usr/bin/env python3
import json, os, pathlib, sys
pathlib.Path(os.environ['HOME'], 'rsync-call.json').write_text(json.dumps(sys.argv[1:]))
sys.exit(10 if os.environ.get('TEST_RSYNC_FAIL') else 0)
""")
        rsync.chmod(0o755)

    def write_transcript(self, rows):
        meta = {
            "timestamp": "2026-10-30T09:00:00Z", "type": "session_meta",
            "payload": {"id": self.event["session_id"], "cwd": self.event["cwd"]},
        }
        self.transcript.write_text("\n".join(json.dumps(row) for row in [meta, *rows]) + "\n")

    def run_worker(self, **env):
        return subprocess.run(
            ["python3", str(HOOK), "--run", json.dumps(self.event)],
            env=dict(self.env, **env), capture_output=True, text=True, timeout=10,
        )

    def test_dialogue_filters_context_reasoning_and_duplicate_events(self):
        user = message("user", "ignored")
        user["payload"]["content"] = [
            {"type": "input_text", "text": "HARNESS_CONTEXT"},
            {"type": "input_text", "text": "Добавь экспорт"},
        ]
        user["payload"]["internal_chat_message_metadata_passthrough"] = {
            "content_item_kinds": ["environments.environment_context", "user.text"],
        }
        self.write_transcript([
            message("developer", "DEVELOPER_CONTEXT"),
            message("user", "# AGENTS.md instructions\nAGENT_RULES"),
            message("user", "<environment_context>ENVIRONMENT</environment_context>"),
            message("user", "<external_codex_apps_open_page>PAGE</external_codex_apps_open_page>"),
            user,
            {"type": "event_msg", "payload": {"type": "user_message", "message": "Добавь экспорт"}},
            response({"type": "reasoning", "summary": [{"text": "PRIVATE_REASONING"}]}),
            message("assistant", "Проверяю экспорт"),
            response({"type": "function_call", "name": "exec_command", "arguments": '{"cmd":"test"}'}),
            response({"type": "custom_tool_call", "name": "apply_patch", "input": "patch\n" + "x" * 300}),
            response({"type": "function_call_output", "output": "TOOL_OUTPUT"}),
            response({"type": "custom_tool_call_output", "output": "PATCH_OUTPUT"}),
            message("assistant", "Экспорт добавлен"),
            {"type": "event_msg", "payload": {"type": "agent_message", "message": "Экспорт добавлен"}},
        ])
        dialogue, started = MODULE["read_dialogue"](self.transcript)
        self.assertEqual(started, "2026-10-30T09:00:00Z")
        self.assertEqual(dialogue.count("Добавь экспорт"), 1)
        self.assertEqual(dialogue.count("Экспорт добавлен"), 1)
        self.assertIn('→ exec_command {"cmd":"test"}', dialogue)
        self.assertIn("→ apply_patch patch ", dialogue)
        self.assertNotIn("\nxxx", dialogue)
        for excluded in ["CONTEXT", "AGENT_RULES", "ENVIRONMENT", "PAGE", "REASONING", "OUTPUT"]:
            self.assertNotIn(excluded, dialogue)

    def test_long_dialogue_keeps_start_and_end(self):
        self.write_transcript([message("user", "TASK_START" + "x" * 100000),
                               message("assistant", "y" * 400000 + "RESULT_END")])
        dialogue, _ = MODULE["read_dialogue"](self.transcript)
        self.assertTrue(dialogue.startswith("## Пользователь\nTASK_START"))
        self.assertTrue(dialogue.endswith("RESULT_END"))
        self.assertIn("[… середина сессии пропущена …]", dialogue)
        self.assertLess(len(dialogue), 401000)

    def test_worker_saves_metadata_and_syncs_whole_directory(self):
        result = self.run_worker()
        self.assertEqual(result.returncode, 0, result.stderr)
        output, = self.out_root.rglob("*.md")
        self.assertEqual(output.name, "2026-10-30_0900_12345678.md")
        self.assertEqual(output.parent.name, "project 'with spaces'")
        content = output.read_text()
        fields = dict(line.split(": ", 1) for line in content.split("---")[1].strip().splitlines())
        fields = {key: json.loads(value) for key, value in fields.items()}
        self.assertEqual(fields["session"], self.event["session_id"])
        self.assertEqual(fields["project"], self.event["cwd"])
        self.assertEqual(fields["reason"], "other")
        self.assertEqual(shlex.split(fields["resume"]),
                         ["cd", self.event["cwd"], "&&", "codex", "resume", self.event["session_id"]])
        self.assertIn("# Экспорт данных", content)
        self.assertFalse(list(self.out_root.rglob("*.tmp")))
        call = json.loads((self.work / "codex-call.json").read_text())
        self.assertIn("--ephemeral", call["args"])
        self.assertIn("hooks", call["args"])
        self.assertEqual(call["guard"], "1")
        self.assertIn("## Пользователь\nДобавь экспорт", call["input"])
        sync = json.loads((self.work / "rsync-call.json").read_text())
        self.assertEqual(sync[-2:], [str(self.out_root) + "/", "beelink:codex-sessions/"])

    def test_empty_and_context_only_sessions_do_not_generate(self):
        for rows in ([], [message("user", "Только вопрос")],
                     [message("user", "# AGENTS.md instructions\nRULES"), message("assistant", "Привет")]):
            with self.subTest(rows=rows):
                self.write_transcript(rows)
                result = self.run_worker()
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertFalse((self.work / "codex-call.json").exists())

    def test_missing_transcript_is_reported(self):
        self.event["transcript_path"] = str(self.work / "missing.jsonl")
        result = self.run_worker()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("FileNotFoundError", result.stderr)

    def test_ephemeral_session_without_transcript_is_skipped(self):
        self.event["transcript_path"] = None
        result = self.run_worker()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse((self.work / "codex-call.json").exists())

    def test_generation_failure_never_saves_or_syncs(self):
        for env in ({"TEST_CODEX_FAIL": "1"}, {"TEST_CODEX_EMPTY": "1"}):
            with self.subTest(env=env):
                result = self.run_worker(**env)
                self.assertNotEqual(result.returncode, 0)
                self.assertFalse(self.out_root.exists())
                self.assertFalse((self.work / "rsync-call.json").exists())

    def test_failed_sync_keeps_local_summary(self):
        result = self.run_worker(TEST_RSYNC_FAIL="1")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(len(list(self.out_root.rglob("*.md"))), 1)
        self.assertIn("не отправлено на beelink:codex-sessions/", result.stdout)

    def test_hook_starts_a_detached_worker_and_logs_errors(self):
        self.event["transcript_path"] = str(self.work / "missing.jsonl")
        result = subprocess.run(["python3", str(HOOK)], input=json.dumps(self.event),
                                env=self.env, capture_output=True, text=True, timeout=3)
        self.assertEqual(result.returncode, 0, result.stderr)
        log = self.work / ".cache/codex-session-summary.log"
        deadline = time.monotonic() + 3
        while time.monotonic() < deadline and "FileNotFoundError" not in log.read_text():
            time.sleep(0.02)
        self.assertIn("FileNotFoundError", log.read_text())
        self.assertEqual(result.stdout, "")

    def test_recursion_guard_does_not_read_stdin_or_start_a_worker(self):
        result = subprocess.run(["python3", str(HOOK)], input="not JSON",
                                env=dict(self.env, CODEX_SESSION_SUMMARY="1"),
                                capture_output=True, text=True, timeout=3)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse((self.work / ".cache").exists())


if __name__ == "__main__":
    unittest.main()
