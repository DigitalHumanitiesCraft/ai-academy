---
type: specification
status: entwurf
updated: 2026-11-25
tags: [regeln, prüfung]
---
# Spezifikation

Die Regeln stammen aus der [Quelle](quellen/dienstzeitregeln-anaesthesie.md). Die Daten beschreibt [data.md](data.md).

## Anforderungen
1. Der Prototyp liest einen Dienstplan im Format aus data.md.
2. Er meldet Ruhezeiten unter 11 Stunden.
3. Er meldet mehr als 48 Stunden im Schnitt über vier Wochen.
4. Er meldet einen Dienst direkt nach einem Nachtdienst.
5. Er meldet Personen mit weniger als zwei freien Wochenenden im Monat.

## Prüffälle

| Nr. | Eingabe | Erwartet |
|---|---|---|
| 1 | Nacht am 1.12., Tag am 2.12. | Verstoß gegen Regel 3 |
| 2 | Nacht am 1.12., frei am 2.12. | kein Verstoß |

## Related
- [testing.md](testing.md)
