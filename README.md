# Codex subagents starter

Small Codex subagent pack with an explicit small/big model split.

| Agent | Model | Effort | Sandbox | Auto compact | Use |
|---|---:|---:|---:|---:|---|
| `cheap_explorer` | `gpt-5.4-mini` | `low` | `read-only` | `120k` | fast repo mapping, grep, logs, dependencies |
| `docs_researcher` | `gpt-5.4-mini` | `medium` | `read-only` | `120k` | external docs/API/version checks |
| `test_planner` | `gpt-5.4-mini` | `medium` | `read-only` | `120k` | minimal useful test plan |
| `worker_small` | `gpt-5.4-mini` | `high` | `workspace-write` | `120k` | small isolated edits |
| `risk_reviewer` | `gpt-5.5` | `high` | `read-only` | `120k` | serious review, security, regressions, edge cases |

All agents use:

```toml
model_context_window = 128000
model_auto_compact_token_limit = 120000
```

## Install / update, one-liner

Run this both for first install and later updates:

```bash
tmp="$(mktemp -d)" && curl -L https://github.com/shirk33y/codex-subagents/archive/refs/heads/main.zip -o "$tmp/codex-subagents.zip" && unzip -q "$tmp/codex-subagents.zip" -d "$tmp" && bash "$tmp/codex-subagents-main/install.sh"
```

Then restart Codex Desktop/CLI.

## Install / update from git clone

```bash
git clone https://github.com/shirk33y/codex-subagents.git
cd codex-subagents
bash install.sh
```

Later update:

```bash
cd codex-subagents
git pull
bash install.sh
```

## What installer changes

- copies `agents/*.toml` to `~/.codex/agents/`
- overwrites old installed agent files, but creates timestamped backups first
- appends a marked subagent policy block to `~/.codex/AGENTS.md`
- does not duplicate the policy block if it is already present
- creates `~/.codex/config.toml` with `[agents]` if missing
- does not edit an existing `[agents]` table, to avoid corrupting existing TOML

Default config snippet:

```toml
[agents]
max_threads = 4
max_depth = 1
```

Backups look like:

```text
~/.codex/AGENTS.md.bak.YYYYMMDD-HHMMSS
~/.codex/config.toml.bak.YYYYMMDD-HHMMSS
~/.codex/agents/cheap-explorer.toml.bak.YYYYMMDD-HHMMSS
```

## Manual Windows install / update

From extracted/cloned repo folder:

```powershell
mkdir "$env:USERPROFILE\.codex\agents" -Force
copy ".\agents\*.toml" "$env:USERPROFILE\.codex\agents\" -Force
notepad "$env:USERPROFILE\.codex\AGENTS.md"
notepad "$env:USERPROFILE\.codex\config.toml"
```

Paste `snippets/AGENTS-subagents.md` into `AGENTS.md` if missing.
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
