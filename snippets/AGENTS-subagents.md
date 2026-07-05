## Subagent policy

For larger tasks, debugging, unfamiliar repo exploration, PR review, security review, test planning, or multi-file changes, this instruction counts as explicit authorization to use subagents.

Default policy:
- prefer 1-3 subagents, not a swarm
- use cheap_explorer first for read-only repo exploration, mapping, logs, and dependency tracing
- use docs_researcher only for external or version-specific docs/API behavior
- use test_planner when test coverage or fixtures are unclear
- use worker_small only for small isolated edits with known target files
- use risk_reviewer after implementation, before final answer, or for risky/ambiguous changes
- prefer read-only subagents unless implementation is explicitly delegated
- do not spawn recursively
- do not run parallel write-heavy agents unless explicitly asked
- return distilled findings, not raw logs or long snippets
