#!/usr/bin/env bash
set -euo pipefail

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
STAMP="$(date +%Y%m%d-%H%M%S)"

mkdir -p "$CODEX_HOME/agents"

backup_file() {
  local path="$1"
  if [[ -f "$path" ]]; then
    cp "$path" "$path.bak.$STAMP"
  fi
}

install_agent() {
  local src="$1"
  local base
  base="$(basename "$src")"
  local dst="$CODEX_HOME/agents/$base"
  backup_file "$dst"
  cp "$src" "$dst"
}

for f in "$SRC_DIR"/agents/*.toml; do
  install_agent "$f"
done

AGENTS_FILE="$CODEX_HOME/AGENTS.md"
POLICY_START="<!-- codex-subagents-starter:start -->"
POLICY_END="<!-- codex-subagents-starter:end -->"

if [[ -f "$AGENTS_FILE" ]] && grep -q "$POLICY_START" "$AGENTS_FILE"; then
  echo "AGENTS.md: subagent policy already present, skipped"
else
  backup_file "$AGENTS_FILE"
  mkdir -p "$(dirname "$AGENTS_FILE")"
  {
    [[ -s "$AGENTS_FILE" ]] && printf '\n\n'
    echo "$POLICY_START"
    cat "$SRC_DIR/snippets/AGENTS-subagents.md"
    echo "$POLICY_END"
  } >> "$AGENTS_FILE"
  echo "AGENTS.md: policy appended"
fi

CONFIG_FILE="$CODEX_HOME/config.toml"
if [[ ! -f "$CONFIG_FILE" ]]; then
  cp "$SRC_DIR/snippets/config-subagents.toml" "$CONFIG_FILE"
  echo "config.toml: created with [agents] max_threads/max_depth"
elif grep -Eq '^\s*\[agents\]\s*$' "$CONFIG_FILE"; then
  echo "config.toml: existing [agents] table found, left unchanged"
  echo "manual check suggested: max_threads = 4, max_depth = 1"
else
  backup_file "$CONFIG_FILE"
  {
    printf '\n\n'
    cat "$SRC_DIR/snippets/config-subagents.toml"
  } >> "$CONFIG_FILE"
  echo "config.toml: [agents] block appended"
fi

echo
echo "Installed agents:"
ls -1 "$CODEX_HOME/agents" | grep -E '^(cheap-explorer|docs-researcher|test-planner|worker-small|risk-reviewer)\.toml$' | sed 's/^/  - /'
echo
echo "Done. Restart Codex CLI/app if it was already running."
