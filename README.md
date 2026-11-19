# AI Academy working folder guard

A reviewed setup that keeps Claude Code inside one working folder on Windows. Participants of the AI Academy let Claude Code download these files into their own folder.

## What it does

- `.claude/settings.json` blocks reads and writes of Claude Code's file tools outside the working folder, denies all connector (MCP) tools, protects the `.claude` folder and registers the hook. A hook failure blocks the action (`onFailure: "block"`).
- `.claude/hooks/guard.ps1` runs before every tool call. It refuses file paths and terminal commands that point outside the folder, including detours such as `..`, `~`, environment variables, network paths and Git Bash paths like `/c/...`. Web access, skills and subagents stay allowed. It runs on the built-in Windows PowerShell 5.1.

## What it does not do

The terminal check reads the command as text. A script that builds a path at runtime is not seen, and content inside the folder can still be sent to the web. On native Windows Claude Code has no operating-system sandbox. The setup is a safeguard for teaching, not an isolation boundary. macOS needs a separate hook.

## Prompt for participants

Open an empty folder in VS Code, start Claude Code and enter:

> Richte diesen Ordner als abgesicherten Arbeitsordner für die AI Academy ein. Lade dazu mit `Invoke-WebRequest` zuerst https://raw.githubusercontent.com/DigitalHumanitiesCraft/ai-academy/main/.claude/hooks/guard.ps1 nach `.claude/hooks/guard.ps1` und danach https://raw.githubusercontent.com/DigitalHumanitiesCraft/ai-academy/main/.claude/settings.json nach `.claude/settings.json`. Ändere die Dateien nicht. Prüfe dann mit je einem erlaubten und einem verbotenen Beispiel, dass die Sperre wirkt, und sag mir in einfachen Worten, was sie sperrt und was nicht.

## Tests

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests\test-guard.ps1
```

The script runs the guard against a temporary copy of the folder with allowed and blocked cases and with broken input.

## Licence

MIT, see [LICENSE](LICENSE).
