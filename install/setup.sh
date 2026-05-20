#!/usr/bin/env bash
# VS-Code-Agentic-First-Developer-Environment — Unix/macOS/WSL Setup Script
# Usage: bash install/setup.sh

set -euo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
info()  { echo -e "${GREEN}[+]${NC} $*"; }
warn()  { echo -e "${YELLOW}[!]${NC} $*"; }
error() { echo -e "${RED}[x]${NC} $*"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

echo ""
echo "=== VS Code Agentic-First Developer Environment Setup ==="
echo ""

# ── 1. ~/.claude/settings.json ────────────────────────────────────────────────
CLAUDE_DIR="$HOME/.claude"
CLAUDE_SETTINGS="$CLAUDE_DIR/settings.json"
SOURCE_SETTINGS="$REPO_ROOT/config/claude-settings.json"

mkdir -p "$CLAUDE_DIR"

if [[ -f "$CLAUDE_SETTINGS" ]]; then
    # Merge: new keys overwrite existing, extra existing keys preserved
    merged=$(jq -s '.[0] * .[1]' "$CLAUDE_SETTINGS" "$SOURCE_SETTINGS")
    echo "$merged" > "$CLAUDE_SETTINGS"
    info "Merged with existing $CLAUDE_SETTINGS"
else
    cp "$SOURCE_SETTINGS" "$CLAUDE_SETTINGS"
    info "Created $CLAUDE_SETTINGS"
fi

# ── 2. VS Code User settings.json ─────────────────────────────────────────────
detect_vscode_settings() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "$HOME/Library/Application Support/Code/User/settings.json"
    elif grep -qEi "(microsoft|wsl)" /proc/version 2>/dev/null; then
        # WSL — use Windows AppData
        WIN_APPDATA=$(cmd.exe /c "echo %APPDATA%" 2>/dev/null | tr -d '\r')
        wslpath "$WIN_APPDATA/Code/User/settings.json" 2>/dev/null || echo ""
    else
        echo "$HOME/.config/Code/User/settings.json"
    fi
}

VSC_SETTINGS=$(detect_vscode_settings)
FRAGMENT="$REPO_ROOT/config/vscode-settings-fragment.json"

if [[ -n "$VSC_SETTINGS" && -f "$VSC_SETTINGS" ]]; then
    # Strip _comment fields then merge
    fragment_clean=$(jq 'with_entries(select(.key | startswith("_") | not))' "$FRAGMENT")
    merged=$(echo "$fragment_clean" | jq -s "$(cat "$VSC_SETTINGS") * .[0]" 2>/dev/null \
             || jq -s '.[0] * .[1]' "$VSC_SETTINGS" <(echo "$fragment_clean"))
    echo "$merged" > "$VSC_SETTINGS"
    info "Patched VS Code settings at $VSC_SETTINGS"
else
    warn "VS Code settings.json not found — skipping (path: ${VSC_SETTINGS:-unknown})"
fi

# ── 3. Verify jq is available (needed for merge) ──────────────────────────────
if ! command -v jq &>/dev/null; then
    warn "jq not found — JSON merging skipped. Install jq and re-run."
    warn "  Ubuntu/Debian: sudo apt install jq"
    warn "  macOS:         brew install jq"
fi

echo ""
info "=== Setup complete. Restart VS Code to apply all changes. ==="
echo ""
echo "What was configured:"
echo "  ~/.claude/settings.json  -> agent=developer, permissions.defaultMode=auto"
echo "  VS Code settings         -> claudeCode.initialPermissionMode=auto, preferredLocation=panel"
