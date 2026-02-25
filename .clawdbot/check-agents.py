#!/usr/bin/env python3
import json
import subprocess
from datetime import datetime
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
ZOE_DIR = ROOT / ".clawdbot"
ACTIVE_FILE = ZOE_DIR / "active-tasks.json"
SAMPLE_FILE = ZOE_DIR / "active-tasks.json.sample"

if not ACTIVE_FILE.exists():
    if SAMPLE_FILE.exists():
        ACTIVE_FILE.write_text(SAMPLE_FILE.read_text())
    else:
        ACTIVE_FILE.write_text("[]\n")


def load_tasks():
    return json.loads(ACTIVE_FILE.read_text())


def save_tasks(tasks):
    ACTIVE_FILE.write_text(json.dumps(tasks, indent=2) + "\n")


def has_tmux(session):
    if not session:
        return False
    try:
        subprocess.run(["tmux", "has-session", "-t", session], check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        return True
    except (subprocess.CalledProcessError, FileNotFoundError):
        return False


def gh_pr_list(branch):
    try:
        result = subprocess.run([
            "gh",
            "pr",
            "list",
            "--head",
            branch,
            "--json",
            "number,state",
            "--limit",
            "1",
        ], capture_output=True, text=True, check=True)
        data = json.loads(result.stdout)
        return data[0] if data else None
    except (subprocess.CalledProcessError, FileNotFoundError, IndexError, json.JSONDecodeError):
        return None


def gh_pr_view(number):
    try:
        result = subprocess.run([
            "gh",
            "pr",
            "view",
            str(number),
            "--json",
            "statusCheckRollup,reviewDecision,mergeable",
        ], capture_output=True, text=True, check=True)
        return json.loads(result.stdout)
    except (subprocess.CalledProcessError, FileNotFoundError, json.JSONDecodeError):
        return None


tasks = load_tasks()
changed = False
summary_lines = []

for entry in tasks:
    task_id = entry.get("id", "unknown")
    session = entry.get("tmuxSession")
    branch = entry.get("branch")
    status = entry.get("status", "queued")
    tmux_alive = has_tmux(session) if session else False
    if tmux_alive and status in ("queued", "needs_attention"):
        entry["status"] = "running"
        status = "running"
        changed = True
    if not tmux_alive and status == "running" and not entry.get("completedAt"):
        entry["status"] = "needs_attention"
        entry.setdefault("notes", []).append(
            {
                "timestamp": int(datetime.utcnow().timestamp() * 1000),
                "status": "needs_attention",
                "message": "tmux session stopped before completion",
            }
        )
        status = "needs_attention"
        changed = True

    pr_data = None
    if branch:
        pr_data = gh_pr_list(branch)
    if pr_data:
        entry["pr"] = pr_data.get("number")
        entry["prState"] = pr_data.get("state")
        entry.setdefault("checks", {})["prCreated"] = True
        pr_view = gh_pr_view(pr_data.get("number"))
        if pr_view:
            rollup = pr_view.get("statusCheckRollup", {})
            mergeable = pr_view.get("mergeable")
            entry.setdefault("checks", {})["ciPassed"] = rollup.get("state") == "SUCCESS"
            entry.setdefault("checks", {})["mergeable"] = mergeable
            entry.setdefault("checks", {})["reviewDecision"] = pr_view.get("reviewDecision")
        if pr_data.get("state") == "OPEN" and entry.get("status") not in ("ready_for_review", "done"):
            entry["status"] = "ready_for_review"
            status = "ready_for_review"
            changed = True

    summary_lines.append(
        f"{task_id}: session={'alive' if tmux_alive else 'dead'} pr={entry.get('pr','-')} status={entry.get('status')} checks={entry.get('checks', {}).get('ciPassed', '?')}"
    )
    entry["lastCheckedAt"] = int(datetime.utcnow().timestamp() * 1000)

if changed:
    save_tasks(tasks)

print("\n".join(summary_lines))
if changed:
    print("Updated active tasks registry.")
else:
    print("No status changes detected.")
