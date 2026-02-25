#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PYTHON="$(command -v python3)"
"$PYTHON" "$ROOT/.clawdbot/check-agents.py"
