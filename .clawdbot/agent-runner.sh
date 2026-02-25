#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ACTIVE_FILE="$ROOT/.clawdbot/active-tasks.json"

usage() {
  cat <<EOF
Usage: $0 --task <id> --agent <codex|claude> --prompt-file <path> --log-file <path> --session <tmux-session> [--no-notify]
EOF
  exit 1
}

TASK_ID=""
AGENT=""
PROMPT_FILE=""
LOG_FILE=""
SESSION=""
NOTIFY=true

while [[ $# -gt 0 ]]; do
  case "$1" in
    --task)
      TASK_ID="$2"
      shift 2
      ;;
    --agent)
      AGENT="$2"
      shift 2
      ;;
    --prompt-file)
      PROMPT_FILE="$2"
      shift 2
      ;;
    --log-file)
      LOG_FILE="$2"
      shift 2
      ;;
    --session)
      SESSION="$2"
      shift 2
      ;;
    --no-notify)
      NOTIFY=false
      shift
      ;;
    --notify)
      NOTIFY=true
      shift
      ;;
    *)
      usage
      ;;
  esac
done

if [[ -z "$TASK_ID" || -z "$AGENT" || -z "$PROMPT_FILE" || -z "$LOG_FILE" || -z "$SESSION" ]]; then
  usage
fi

if [[ ! -f "$PROMPT_FILE" ]]; then
  echo "Prompt file missing: $PROMPT_FILE" >&2
  exit 1
fi

if [[ "$AGENT" != "codex" && "$AGENT" != "claude" ]]; then
  echo "Unsupported agent: $AGENT" >&2
  exit 1
fi

PROMPT_TEXT="$(cat "$PROMPT_FILE")"

case "$AGENT" in
  codex)
    CMD=(codex --model gpt-5.3-codex -c model_reasoning_effort=high --dangerously-bypass-approvals-and-sandbox "$PROMPT_TEXT")
    ;;
  claude)
    CMD=(claude --model claude-opus-4.5 --dangerously-skip-permissions -p "$PROMPT_TEXT")
    ;;
esac

mkdir -p "$(dirname "$LOG_FILE")"

echo "[$(date --iso-8601=seconds)] Starting Zoe agent $AGENT for $TASK_ID (session $SESSION)" | tee -a "$LOG_FILE"
echo "Prompt stored in $PROMPT_FILE" | tee -a "$LOG_FILE"

set +e
"${CMD[@]}" 2>&1 | tee -a "$LOG_FILE"
EXIT_CODE=${PIPESTATUS[0]}
set -e

STATUS="done"
if [[ $EXIT_CODE -ne 0 ]]; then
  STATUS="failed"
fi

python3 - <<PY
import json, pathlib, time
path = pathlib.Path("$ACTIVE_FILE")
data = json.loads(path.read_text())
target = None
for entry in data:
    if entry.get("id") == "$TASK_ID" and entry.get("tmuxSession") == "$SESSION":
        target = entry
        break
if target is not None:
    target["status"] = "$STATUS"
    target["completedAt"] = int(time.time() * 1000)
    target["lastExitCode"] = $EXIT_CODE
    note = target.setdefault("notes", [])
    note.append({
        "timestamp": int(time.time() * 1000),
        "status": "$STATUS",
        "message": "Agent exited with code $EXIT_CODE"
    })
path.write_text(json.dumps(data, indent=2) + "\n")
else:
    raise SystemExit("Could not find task $TASK_ID in $ACTIVE_FILE")
PY

if [[ "$NOTIFY" == true ]]; then
  if command -v openclaw >/dev/null 2>&1; then
    openclaw system event --text "Zoe: $TASK_ID is $STATUS" --mode now
  else
    echo "openclaw CLI not found—skipping notification" | tee -a "$LOG_FILE"
  fi
fi

exit $EXIT_CODE
