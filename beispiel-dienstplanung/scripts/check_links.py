"""Check the knowledge vault: every relative Markdown link resolves, no wikilinks, frontmatter is complete.

Usage: python -I scripts/check_links.py [project folder]
Exit code 1 if any problem is found.
"""

import re
import sys
from pathlib import Path
from urllib.parse import unquote

LINK = re.compile(r"(?<!!)\[[^\]]*\]\(([^)\s]+)\)")
ALLOWED_TYPES = {"index", "active-work", "plan", "journal", "project", "data", "specification",
                 "testing", "quelle", "notiz"}
ALLOWED_STATUS = {"entwurf", "aktiv", "abgeschlossen"}
DATE = re.compile(r"^\d{4}-\d{2}-\d{2}$")


def frontmatter(text):
    if not text.startswith("---\n"):
        return None
    end = text.find("\n---\n", 4)
    if end == -1:
        return None
    fields = {}
    for line in text[4:end].splitlines():
        key, _, value = line.partition(":")
        fields[key.strip()] = value.strip().strip('"')
    return fields


def main():
    root = Path(sys.argv[1] if len(sys.argv) > 1 else ".").resolve()
    vault = root / "knowledge"
    problems, checked = [], 0
    files = [p for p in vault.rglob("*.md") if ".obsidian" not in p.parts]
    files += [root / "CLAUDE.md", root / "README.md"]
    for md in files:
        text = md.read_text(encoding="utf-8")
        rel = md.relative_to(root).as_posix()
        if "[[" in text:
            problems.append(f"{rel}: contains a wikilink")
        for target in LINK.findall(text):
            if re.match(r"^[a-z]+:", target):
                continue  # external URL
            path = unquote(target.split("#", 1)[0])
            if not path:
                continue
            dest = (md.parent / path).resolve()
            checked += 1
            if not dest.exists():
                problems.append(f"{rel}: link target missing: {target}")
            elif md.is_relative_to(vault) and not dest.is_relative_to(vault):
                problems.append(f"{rel}: link leaves the vault, Obsidian cannot open it: {target}")
        if not md.is_relative_to(vault):
            continue
        fm = frontmatter(text)
        if fm is None:
            problems.append(f"{rel}: no frontmatter")
            continue
        is_template = "vorlagen" in md.relative_to(vault).parts
        for key in ("type", "status", "updated", "tags"):
            if key not in fm:
                problems.append(f"{rel}: frontmatter lacks {key}")
        if fm.get("type") not in ALLOWED_TYPES:
            problems.append(f"{rel}: type not allowed: {fm.get('type')}")
        if fm.get("status") not in ALLOWED_STATUS:
            problems.append(f"{rel}: status not allowed: {fm.get('status')}")
        if not is_template and not DATE.match(fm.get("updated", "")):
            problems.append(f"{rel}: updated is not a date: {fm.get('updated')}")
        tags = [t for t in fm.get("tags", "").strip("[]").split(",") if t.strip()]
        if len(tags) > 3:
            problems.append(f"{rel}: more than three tags")
        original = fm.get("original")
        if original and not is_template:
            checked += 1
            if not (root / original).exists():
                problems.append(f"{rel}: original missing: {original}")
    print(f"{len(files)} files, {checked} link targets checked")
    for p in problems:
        print("PROBLEM", p)
    if not problems:
        print("OK, every target exists")
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main())
