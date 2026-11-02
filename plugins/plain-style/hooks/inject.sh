#!/bin/bash
# UserPromptSubmit hook: read STYLE.md and hand it to Claude Code as additionalContext.
# A STYLE.md in the current project root overrides the plugin default.

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
STYLE="$PLUGIN_ROOT/STYLE.md"

if [ -n "$CLAUDE_PROJECT_DIR" ] && [ -f "$CLAUDE_PROJECT_DIR/STYLE.md" ]; then
  STYLE="$CLAUDE_PROJECT_DIR/STYLE.md"
fi

[ -f "$STYLE" ] || exit 0

if command -v jq >/dev/null 2>&1; then
  jq -Rs '{hookSpecificOutput:{hookEventName:"UserPromptSubmit",additionalContext:.},suppressOutput:true}' "$STYLE"
else
  python3 - "$STYLE" <<'PY'
import json, sys
text = open(sys.argv[1], encoding="utf-8").read()
print(json.dumps({
    "hookSpecificOutput": {"hookEventName": "UserPromptSubmit", "additionalContext": text},
    "suppressOutput": True,
}, ensure_ascii=False))
PY
fi
