#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ZOE_DIR="$ROOT/.clawdbot"
ACTIVE_SAMPLE="$ZOE_DIR/active-tasks.json.sample"
ACTIVE_FILE="$ZOE_DIR/active-tasks.json"
LOG_DIR="$ZOE_DIR/logs"
WORKTREE_BASE="$ZOE_DIR/worktrees"
PROMPT_DIR="$ZOE_DIR/prompts"
mkdir -p "$LOG_DIR" "$WORKTREE_BASE" "$PROMPT_DIR"

ensure_active_file() {
  if [[ ! -f "$ACTIVE_FILE" ]]; then
    if [[ -f "$ACTIVE_SAMPLE" ]]; then
      cp "$ACTIVE_SAMPLE" "$ACTIVE_FILE"
    else
      echo "[]" > "$ACTIVE_FILE"
    fi
  fi
}

ensure_active_file

usage() {
  cat <<EOF
Usage: $0 --task <task-id> --description <goal summary> [options]

Options:
  --agent <codex|claude>          Agent to run (default: codex)
  --branch <branch-name>          Git branch name for the worktree (default: agent/<task-id>)
  --base <base-branch>            Branch to branch from (default: master)
  --prompt-file <path>            Use an existing prompt file instead of generated context
  --extra <text>                  Additional instructions Zoe should include in the prompt
  --force                         Destroy any existing tmux session with the same name
  --no-notify                     Skip the Telegram/OpenClaw notification on completion
EOF
  exit 1
}

TASK_ID=""
DESCRIPTION=""
AGENT="codex"
BRANCH=""
BASE_BRANCH="master"
PROMPT_OVERRIDE=""
EXTRA_INSTRUCTIONS=""
FORCE=false
NOTIFY=true

while [[ $# -gt 0 ]]; do
  case "$1" in
    --task)
      TASK_ID="$2"
      shift 2
      ;;
    --description)
      DESCRIPTION="$2"
      shift 2
      ;;
    --agent)
      AGENT="$2"
      shift 2
      ;;
    --branch)
      BRANCH="$2"
      shift 2
      ;;
    --base)
      BASE_BRANCH="$2"
      shift 2
      ;;
    --prompt-file)
      PROMPT_OVERRIDE="$2"
      shift 2
      ;;
    --extra)
      EXTRA_INSTRUCTIONS="$2"
      shift 2
      ;;
    --force)
      FORCE=true
      shift
      ;;
    --no-notify)
      NOTIFY=false
      shift
      ;;
    *)
      usage
      ;;
  esac
done

if [[ -z "$TASK_ID" || -z "$DESCRIPTION" ]]; then
  echo "--task and --description are required"
  usage
fi

BRANCH="${BRANCH:-agent/$TASK_ID}"
TASK_SLUG="$(echo "$TASK_ID" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_-]/-/g')"
TMUX_SESSION="zoe-${AGENT}-${TASK_SLUG}"
WORKTREE="$WORKTREE_BASE/$TASK_SLUG"
LOG_FILE="$LOG_DIR/${TASK_SLUG}.log"
PROMPT_FILE="${PROMPT_OVERRIDE:-$PROMPT_DIR/${TASK_SLUG}-prompt.md}"

if [[ "$AGENT" != "codex" && "$AGENT" != "claude" ]]; then
  echo "Unsupported agent: $AGENT"
  exit 1
fi

enforce_tmux() {
  if tmux has-session -t "$TMUX_SESSION" >/dev/null 2>&1; then
    if [[ "$FORCE" == true ]]; then
      tmux kill-session -t "$TMUX_SESSION"
    else
      echo "A tmux session $TMUX_SESSION already exists. Use --force to replace it."
      exit 1
    fi
  fi
}

enforce_tmux

if [[ -d "$WORKTREE" ]]; then
  echo "Reusing existing worktree at $WORKTREE"
else
  if git -C "$ROOT" show-ref --verify --quiet "refs/heads/$BRANCH"; then
    git -C "$ROOT" worktree add "$WORKTREE" "$BRANCH"
  else
    git -C "$ROOT" worktree add "$WORKTREE" -b "$BRANCH" "origin/$BASE_BRANCH"
  fi
fi

build_context() {
  local context=""
  local files=("README.md" "AppStoreMetadata.md")
  for file in "${files[@]}"; do
    local path="$ROOT/$file"
    if [[ -f "$path" ]]; then
      context+="### $file\n"
      context+="$(cat "$path")\n\n"
    fi
  done
  context+="### Git status\n$(cd "$ROOT" && git status -sb)\n"
  printf "%s" "$context"
}

if [[ -z "$PROMPT_OVERRIDE" ]]; then
  CONTEXT_TEXT="$(build_context)"
  cat <<EOF > "$PROMPT_FILE"
Project context (from README.md & AppStoreMetadata.md):
$CONTEXT_TEXT

Task summary:
$DESCRIPTION

Extra instructions:
${EXTRA_INSTRUCTIONS:-No extra instructions.}

Definition of done:
- PR created and branch synced
- CI (lint, types, unit, E2E) passes
- Codex review passed (if Codex touches backend)
- Claude review passed (if UI touches)
- Screenshots added when UI changes
EOF
else
  cp "$PROMPT_OVERRIDE" "$PROMPT_FILE"
fi

TIMESTAMP_MS=$(python3 - <<PY
import time
print(int(time.time() * 1000))
PY
)

ENTRY=$(python3 - <<PY
import json, pathlib
path = pathlib.Path("$ACTIVE_FILE")
data = json.loads(path.read_text())
entry = {
  "id": "$TASK_ID",
  "tmuxSession": "$TMUX_SESSION",
  "agent": "$AGENT",
  "description": "$DESCRIPTION",
  "repo": "CrownSpin",
  "worktree": "$WORKTREE",
  "branch": "$BRANCH",
  "status": "running",
  "startedAt": $TIMESTAMP_MS,
  "notifyOnComplete": $NOTIFY,
  "promptFile": "$PROMPT_FILE",
  "logFile": "$LOG_FILE",
  "definitionOfDone": [
    "PR created",
    "Branch synced to master",
    "CI (lint, types, unit, E2E) passes",
    "Codex review passed",
    "Claude review passed",
    "Screenshots attached when UI changes"
  ],
  "context": ["README.md","AppStoreMetadata.md"],
  "attempts": 1
}
data.append(entry)
path.write_text(json.dumps(data, indent=2) + "\n")
print(entry)
PY
)

chmod +x "$ZOE_DIR/agent-runner.sh"

TMUX_CMD=(
  "tmux"
  "new-session"
  "-d"
  "-s"
  "$TMUX_SESSION"
  "-c"
  "$WORKTREE"
  "$ZOE_DIR/agent-runner.sh"
  "--task"
  "$TASK_ID"
  "--agent"
  "$AGENT"
  "--prompt-file"
  "$PROMPT_FILE"
  "--log-file"
  "$LOG_FILE"
  "--session"
  "$TMUX_SESSION"
)
if [[ "$NOTIFY" == false ]]; then
  TMUX_CMD+=("--no-notify")
fi
"${TMUX_CMD[@]}"

echo "Spawned Zoe agent $AGENT for task $TASK_ID"
echo "tmux session: $TMUX_SESSION"
echo "Log: $LOG_FILE"
echo "Prompt: $PROMPT_FILE"
