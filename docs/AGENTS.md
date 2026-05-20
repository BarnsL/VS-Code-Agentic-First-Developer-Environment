# Agents — Reference

## Built-in Agents

Claude Code ships with a curated set of purpose-built agents. Each agent carries a tailored system prompt, tool restrictions, and model configuration.

| Agent | Purpose |
|---|---|
| `developer` | General-purpose software development — the "always on" default |
| `brainstorming` | Open-ended ideation and architecture exploration |
| `dispatching-parallel-agents` | Orchestrates multiple sub-agents for large tasks |
| `executing-plans` | Carries out a pre-written plan step-by-step |
| `finishing-a-development-branch` | Completes a branch: tests, lint, PR description |
| `receiving-code-review` | Processes reviewer feedback and applies changes |
| `requesting-code-review` | Prepares code for review and writes the PR |
| `subagent-driven-development` | Coordinates background sub-agent workers |
| `systematic-debugging` | Methodical root-cause analysis and fix |
| `test-driven-development` | Red-green-refactor TDD workflow |
| `using-git-worktrees` | Parallel development with git worktrees |
| `using-superpowers` | Unlocks extended capabilities for complex tasks |
| `verification-before-completion` | Audits and verifies work before marking done |
| `writing-agents` | Composes custom agent definitions |
| `writing-plans` | Breaks work into structured execution plans |

## Setting a Default Agent

### Via `~/.claude/settings.json` (global CLI default)

```json
{
  "agent": "developer"
}
```

This value is used when no agent is specified on session start.  
**Scope:** CLI (terminal) and VS Code extension sessions.

### Custom Agents

Place agent definition files in `~/.claude/agents/` (global) or `.claude/agents/` (per-project).

```
~/.claude/agents/
└── my-custom-agent.md   ← becomes available in the VS Code agent dropdown
```

### Known Limitation

The VS Code extension's new-session dialog **does not visually pre-select** the agent from `settings.json`. The dropdown will always open showing the full list. However, when you start a session without choosing an agent, the CLI silently uses the `agent` value from `settings.json`.

To force visual pre-selection: select "Developer" in the dropdown and click Enter. The extension will remember your last selection per workspace.
