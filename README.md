# VS-Code-Agentic-First-Developer-Environment

> Drop-in configuration that turns VS Code + Claude Code into an agentic-first development environment — **Developer agent pre-wired, Autopilot (Preview) permissions on by default, panel opens automatically.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-2.1%2B-blueviolet)](https://code.claude.com)
[![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20macOS%20%7C%20Linux-informational)](https://code.claude.com/docs/en/ide-integrations/vscode)

---

## What This Does

| Before | After |
|---|---|
| Claude Code opens to blank "new session" dialog | Panel opens automatically on VS Code launch |
| Agent dropdown defaults to nothing | **Developer** agent is the default |
| Permissions default to "Default Approvals" | **Autopilot (Preview)** — autonomous iteration |
| Windows Defender blocks `.node` native modules | Exclusion added for `%TEMP%` |

---

## Quick Start

### Windows (PowerShell — run as Administrator for Defender fix)

```powershell
git clone https://github.com/barnsl/VS-Code-Agentic-First-Developer-Environment.git
cd VS-Code-Agentic-First-Developer-Environment
.\install\setup.ps1
```

### macOS / Linux / WSL

```bash
git clone https://github.com/barnsl/VS-Code-Agentic-First-Developer-Environment.git
cd VS-Code-Agentic-First-Developer-Environment
bash install/setup.sh
```

Restart VS Code after running setup.

---

## What Gets Configured

### 1. `~/.claude/settings.json` — Claude Code CLI

```json
{
  "agent": "developer",
  "permissions": {
    "defaultMode": "auto"
  },
  "skipDangerousModePermissionPrompt": true
}
```

| Key | Value | Effect |
|---|---|---|
| `agent` | `"developer"` | Sets the Developer agent as the default for every new session |
| `permissions.defaultMode` | `"auto"` | Enables Autopilot (Preview) — Claude iterates autonomously |
| `skipDangerousModePermissionPrompt` | `true` | Removes the one-time confirmation dialog when switching to Autopilot |

---

### 2. VS Code `settings.json` — Extension-Level Defaults

```json
{
  "claudeCode.initialPermissionMode": "auto",
  "claudeCode.preferredLocation":     "panel"
}
```

| Key | Value | Effect |
|---|---|---|
| `claudeCode.initialPermissionMode` | `"auto"` | New-session dialog pre-selects Autopilot (Preview) |
| `claudeCode.preferredLocation` | `"panel"` | Claude opens as a full tab (not sidebar) |

> **Note:** As of Claude Code extension v2.1.143, `"auto"` is not in the enum for `claudeCode.initialPermissionMode`. VS Code will show a yellow squiggle, but the value is passed through correctly to the CLI. This is a known preview-feature lag; the enum will be updated in a future release.

---

### 3. Windows Defender Fix (Windows Only)

Claude Code extracts native `.node` modules to `%TEMP%` on startup. Windows Defender blocks these because they lack a recognized publisher signature.

The setup script adds a Defender exclusion for `%TEMP%`. If you prefer to do this manually:

1. Open **Windows Security → Virus & threat protection → Manage settings**
2. Scroll to **Exclusions → Add or remove exclusions**
3. Add a **Folder** exclusion for `C:\Users\<you>\AppData\Local\Temp`

---

## Auto-Open on VS Code Launch

The Claude Code extension activates on `onStartupFinished` (it wakes up automatically) but does not open its UI unless told to. The `"claudeCode.preferredLocation": "panel"` setting ensures the panel opens where you expect it, but for fully automatic open-on-launch, use the keyboard shortcut:

| Platform | Shortcut |
|---|---|
| Windows / Linux | `Ctrl+Shift+Escape` |
| macOS | `Cmd+Shift+Escape` |

To add a keybinding that opens Claude on `workbench.startup`, copy the entries from [`config/keybindings-fragment.json`](config/keybindings-fragment.json) into your VS Code keybindings.

---

## Known Limitations

| Limitation | Status | Workaround |
|---|---|---|
| VS Code agent dropdown does not visually pre-select "Developer" | Upstream — no `claudeCode.initialAgent` setting exists in v2.1.143 | `settings.json` value is used silently; select manually once per workspace |
| `"auto"` (Autopilot) produces a yellow squiggle in VS Code settings | Cosmetic only — enum not updated for preview feature | Ignore; behaviour is correct |
| Defender exclusion step requires admin privileges | By design (Windows security model) | Run `setup.ps1` as Administrator, or add exclusion manually |

---

## File Reference

```
.
├── config/
│   ├── claude-settings.json          # Drop-in for ~/.claude/settings.json
│   ├── vscode-settings-fragment.json # Keys to merge into VS Code settings.json
│   └── keybindings-fragment.json     # Optional keyboard shortcuts
├── docs/
│   ├── AGENTS.md                     # Built-in agent catalogue + custom agent guide
│   └── PERMISSION-MODES.md           # Permission mode deep-dive + enum gap explanation
├── install/
│   ├── setup.ps1                     # Windows one-shot installer
│   └── setup.sh                      # macOS/Linux/WSL one-shot installer
└── README.md
```

---

## Prerequisites

- [VS Code](https://code.visualstudio.com/) 1.94+
- [Claude Code VS Code extension](https://marketplace.visualstudio.com/items?itemName=Anthropic.claude-code) v2.1+
- An active [Claude](https://claude.ai) account (Pro, Max, or Teams/Enterprise with Claude Code access)
- **Windows only:** PowerShell 7+ for the installer

---

## Related Repos

- [VS-Code-Agent-Manager](https://github.com/barnsl/VS-Code-Agent-Manager) — Dashboard and multi-agent ticket workflows for VS Code Copilot agents

---

## License

MIT — see [LICENSE](LICENSE).
