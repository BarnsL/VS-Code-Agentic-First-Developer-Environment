# Permission Modes — Reference

Claude Code for VS Code offers three permission modes selectable in the new-session dialog.

## Comparison Table

| UI Label | `claudeCode.initialPermissionMode` | `~/.claude/settings.json` | Behaviour |
|---|---|---|---|
| **Default Approvals** | `"default"` | `"default"` | Claude follows your `allow`/`deny` rules and asks for anything else |
| **Bypass Approvals** | `"bypassPermissions"` | `"bypassPermissions"` | All tool calls auto-approved — fastest, no prompts |
| **Autopilot (Preview)** | `"auto"` *(preview — not yet in enum)* | `"auto"` | AI-classified approvals; autonomously iterates start-to-finish |

## Why "Autopilot (Preview)" Isn't in the VS Code Enum

As of extension version `2.1.143` the `claudeCode.initialPermissionMode` enum has not been updated to include `"auto"`. Setting it to `"auto"` in `settings.json` **does work** — VS Code treats it as an unrecognised enum value and passes it through to the CLI, which understands it.

```jsonc
// settings.json
"claudeCode.initialPermissionMode": "auto"   // ← accepted by CLI, yellow squiggle in VS Code
```

The yellow warning in VS Code settings is cosmetic only; the behaviour is correct.

## Choosing a Mode

- Use **Default Approvals** when working in sensitive repos or with destructive tools.
- Use **Bypass Approvals** in sandboxed / CI environments.
- Use **Autopilot (Preview)** for autonomous multi-step feature development where you want Claude to iterate without constant interruption.

## `~/.claude/settings.json` vs `claudeCode.initialPermissionMode`

The VS Code extension setting **overrides** `~/.claude/settings.json` for new sessions opened from the extension UI. If you only set `permissions.defaultMode` in `settings.json`, the VS Code new-session dialog will still show "Default Approvals" as the visual default — but the underlying CLI session will use your `settings.json` value once a session is created without an explicit override.

For guaranteed consistency, set both:

```json
// ~/.claude/settings.json
{
  "permissions": { "defaultMode": "auto" }
}

// VS Code settings.json
{
  "claudeCode.initialPermissionMode": "auto"
}
```
