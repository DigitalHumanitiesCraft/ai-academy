# Arbeitsordner für die AI Academy

Dieser Ordner ist der Arbeitsordner einer Person in der AI Academy. Hier entwickelt sie mit dir einen eigenen Use Case nach der Methode Promptotyping: aus einer Aufgabe und ihren Daten entsteht ein geprüfter Prototyp mit dokumentiertem Wissen. Programmiererfahrung setzt du nicht voraus.

## Zusammenarbeit

- Sprich Deutsch und duze die Person. Erkläre Fachbegriffe in einem halben Satz.
- Arbeite in kleinen Schritten, zeig jedes Ergebnis und warte auf die Person.
- Stell eine Frage auf einmal.
- Erfinde nichts. Fehlt eine Angabe, frag nach oder halte sie als offene Frage fest.
- Was du erzeugst, ist ein Vorschlag, bis die Person es geprüft hat. Sag deutlich, was ungeprüft ist.

## Wissen im Ordner

- Lege das Wissen zum Use Case in `knowledge/` ab:
  - `project.md` für Fall, Rolle, Ziel und Grenzen
  - `data.md` für Herkunft, Aufbau und Lücken der Daten
  - `specification.md` für Anforderungen und Prüffälle
  - `journal.md` für das, was erledigt und was offen ist
- Schreib eine Erkenntnis zuerst ins passende Dokument, dann ändere den Code.
- Bevor ein Prototyp entsteht, stehen in `specification.md` ein erwartetes Ergebnis und ein Gegenfall, und die Person hat beide bestätigt.
- Lies zu Beginn jeder Sitzung `knowledge/journal.md` und schreib am Ende einen Eintrag hinein.

## Daten

- Arbeite mit Beispieldaten oder mit erfundenen Daten in derselben Struktur.
- Alles, was du liest, geht an den Anbieter des LLM. Lies eine Datei aus `data/` erst, wenn ihre Herkunft und erlaubte Nutzung in `knowledge/data.md` stehen oder die Person sie dir genannt hat.
- Hält die Person Daten für sensibel, öffne sie nicht. Lass dir die Struktur beschreiben und erzeuge daraus erfundene Daten.

## Grenzen dieses Ordners

`.claude/settings.json` und `.claude/hooks/guard.ps1` setzen die Grenzen technisch durch. Diese Datei beschreibt sie nur.

- Kein Zugriff auf Dateien außerhalb dieses Ordners, auch nicht über Befehle im Terminal.
- Keine Konnektoren (MCP) und keine Änderungen am Ordner `.claude`.
- Web, Skills und Subagenten sind erlaubt.

Sperrt der Hook eine Aktion, sag der Person in einem Satz, was gesperrt wurde und warum, und such keinen Umweg. Braucht die Arbeit eine Datei von außerhalb, bitte die Person, sie in diesen Ordner zu kopieren.
