# Codex subagents starter

Small Codex subagent pack with an explicit small/big model split.

| Agent | Model | Effort | Sandbox | Use |
|---|---:|---:|---:|---|
| `cheap_explorer` | `gpt-5.4-mini` | `low` | `read-only` | fast repo mapping, grep, logs, dependencies |
| `docs_researcher` | `gpt-5.4-mini` | `medium` | `read-only` | external docs/API/version checks |
| `test_planner` | `gpt-5.4-mini` | `medium` | `read-only` | minimal useful test plan |
| `worker_small` | `gpt-5.4-mini` | `high` | `workspace-write` | small isolated edits |
| `risk_reviewer` | `gpt-5.5` | `high` | `read-only` | serious review, security, regressions, edge cases |

## Install from GitHub

```bash
tmp="$(mktemp -d)" && curl -L https://github.com/shirk33y/codex-subagents/archive/refs/heads/main.zip -o "$tmp/codex-subagents.zip" && unzip -q "$tmp/codex-subagents.zip" -d "$tmp" && bash "$tmp/codex-subagents-main/install.sh"
```

Or from inside the cloned/extracted folder:

```bash
bash install.sh
```

## What installer changes

- copies `agents/*.toml` to `~/.codex/agents/`
- appends a marked subagent policy block to `~/.codex/AGENTS.md`
- creates or appends `[agents]` config with:

```toml
[agents]
max_threads = 4
max_depth = 1
```

If `~/.codex/config.toml` already has `[agents]`, the installer leaves it unchanged to avoid corrupting existing TOML.
Existing files are backed up as `*.bak.YYYYMMDD-HHMMSS`.

## Windows manual install

```powershell
mkdir "$env:USERPROFILE\.codex\agents" -Force
copy ".\agents\*.toml" "$env:USERPROFILE\.codex\agents\"
notepad "$env:USERPROFILE\.codex\AGENTS.md"
notepad "$env:USERPROFILE\.codex\config.toml"
```

Paste `snippets/AGENTS-subagents.md` into `AGENTS.md`.
Add this to `config.toml` if missing:

```toml
[agents]
max_threads = 4
max_depth = 1
```

Restart Codex Desktop/CLI.

## Example prompts

```text
Review this branch. Use cheap_explorer to map affected paths, test_planner for missing tests, and risk_reviewer for serious issues. Wait for all agents and summarize only concrete findings.
```

```text
Investigate this bug. Use cheap_explorer first. If the fix is isolated, delegate the edit to worker_small. Afterward use risk_reviewer before final response.
```

```text
Check whether this library API usage is still valid. Use docs_researcher and cite exact version-specific docs.
```
