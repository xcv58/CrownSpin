#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ACTIVE_FILE="$ROOT/.clawdbot/active-tasks.json"

if [[ ! -f "$ACTIVE_FILE" ]]; then
  exit 0
fi

python3 - <<PY
import json
import subprocess
import time
from pathlib import Path

root = Path("$ROOT")
path = Path("$ACTIVE_FILE")
tasks = json.loads(path.read_text())
updated = False
for entry in tasks:
    status = entry.get("status")
    cleaned = entry.get("cleanedUpAt")
    if status in ("done", "failed") and not cleaned:
        worktree = Path(entry.get("worktree", ""))
        if worktree.exists():
            print(f"Removing worktree {worktree}")
            subprocess.run(["git", "worktree", "remove", "--force", str(worktree)], cwd=str(root))
        entry["cleanedUpAt"] = int(time.time() * 1000)
        updated = True
if updated:
    path.write_text(json.dumps(tasks, indent=2) + "\n")
    print("Orphaned worktrees cleaned up")
else:
    print("No orphaned worktrees to clean")
PY
