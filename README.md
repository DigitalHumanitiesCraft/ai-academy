# AI Academy working folder guard

A reviewed setup that keeps Claude Code inside one working folder on Windows. Participants of the AI Academy let Claude Code download these files into their own folder.

## What it does

- `.claude/settings.json` blocks reads and writes of Claude Code's file tools outside the working folder, denies all connector (MCP) tools, protects the `.claude` folder and registers the hook. A hook failure blocks the action (`onFailure: "block"`).
- `CLAUDE.md` tells Claude Code how to work with the participant on their own use case and describes the limits. It is context, not enforcement.
- `.claude/hooks/guard.ps1` runs before every tool call. It refuses file paths and terminal commands that point outside the folder, including detours such as `..`, `~`, environment variables, network paths and Git Bash paths like `/c/...`. Web access, skills and subagents stay allowed. It runs on the built-in Windows PowerShell 5.1.

## What it does not do

The terminal check reads the command as text. A script that builds a path at runtime is not seen, and content inside the folder can still be sent to the web. On native Windows Claude Code has no operating-system sandbox. The setup is a safeguard for teaching, not an isolation boundary. macOS needs a separate hook.

## Prompt for participants

Open an empty folder in VS Code, start Claude Code and enter:

> Richte diesen Ordner als abgesicherten Arbeitsordner für die AI Academy ein. Lade dazu aus https://github.com/DigitalHumanitiesCraft/ai-academy zuerst den Hook `.claude/hooks/guard.ps1`, danach `.claude/settings.json` und `CLAUDE.md` unverändert in diesen Ordner. Prüfe mit je einem erlaubten und einem verbotenen Beispiel, dass die Sperre wirkt, und sag mir in einfachen Worten, was sie sperrt und was nicht.

The hook comes first because `settings.json` switches it on, after which `.claude` is write-protected. The files are downloaded from `raw.githubusercontent.com`, not through Claude's web tool, which summarises pages instead of returning them unchanged.

A Claude Code session started in this repository itself is confined by the same guard.

## README template

`README-VORLAGE.md` is the common README structure for participant projects, in German. Every project uses the same sections in the same order, so colleagues and the university's IT can read the projects side by side. The table "Technik auf einen Blick" lists languages, dependencies, outside connections and what operation needs.

## UI guide

`UI-LEITFADEN.md` is the yardstick against which Claude reviews and improves a participant project's interface, in German. It condenses the house rules for working interfaces and the visual system of the University of Veterinary Medicine Vienna, read from its public stylesheet without logo or trademark assets.

## Example project

`beispiel-dienstplanung/` is an invented participant project (anaesthesia duty planning, fictional data) whose `knowledge/` folder is set up as a small Obsidian vault with `index.md`, `active-work.md` for the current state, `plan.md` for the seven stages, `journal.md` for the history, source notes and templates. It is demonstration material for day 4. `python -I scripts/check_links.py .` inside the folder checks that every relative link target exists.

## Tests

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests\test-guard.ps1
```

The script runs the guard against a temporary copy of the folder with allowed and blocked cases and with broken input.

## Licence

MIT, see [LICENSE](LICENSE).
