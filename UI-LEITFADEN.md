# UI-Leitfaden für Projekte der AI Academy

Dieser Leitfaden ist der Maßstab, an dem Claude die Oberfläche eines Projekts prüft und verbessert. Er gilt für Arbeitswerkzeuge, also Seiten, mit denen jemand eine Aufgabe erledigt. Funktionen und Daten bleiben bei einer Überarbeitung gleich.

## Grundsätze

1. **Eine Frage je Ansicht.** Jede Ansicht beantwortet eine Frage, die sich in einem Satz sagen lässt. Was diese Frage oder den nächsten Schritt nicht unterstützt, entfällt.
2. **Plan vor Komponenten.** Erst stehen Aufgabe, Teile der Ansicht in ihrer Reihenfolge und Hauptelement fest, dann werden Karten, Tabellen oder Knöpfe gewählt.
3. **Höchstens drei Ebenen.** Ein wiederkehrender Eintrag hat höchstens drei Ebenen aus Titelzeile, Marken, Knöpfen, Feldern und Ergebniszeilen. Dasselbe gilt für alles vor dem ersten Eintrag.
4. **Höchstens zwei Überschriftenebenen.** Seitentitel und eine Gruppenebene. Eine Überschrift steht nur über mindestens zwei gleichartigen Elementen.
5. **Keine Eyebrows und Unterzeilen.** Über dem Titel steht nichts, unter ihm keine graue Zeile, die er selbst aufnehmen könnte.
6. **Wenig Text.** Ein Teil hat eine Überschrift, höchstens zwei Sätze und dann sein Hauptelement. Keine werblichen Einleitungen, keine Sätze, die eine sichtbare Zahl nacherzählen.
7. **Alles einmal.** Jede Tatsache, Zahl und Einschränkung steht einmal je Bildschirm.
8. **Abstand statt Rahmen.** Bereiche trennt Abstand, höchstens eine Haarlinie. Keine verschachtelten Karten, keine dekorativen Linien.
9. **Hinweise am Ort.** Ein Hinweis steht an dem Element, das er betrifft, ein Fehler sichtbar am betroffenen Objekt, ohne `undefined` oder interne Feldnamen.
10. **Sichtbar statt versteckt.** Filter und alles, was die Aufgabe braucht, stehen ohne Aufklappen auf der ersten Ansicht. Tooltips erklären nur.
11. **Monospace nur für Code.** Code, Dateinamen und Kennungen stehen in Monospace, alle Beschriftungen in der Textschrift.
12. **Schmal benutzbar.** Bei 360 px Breite scrollt die Seite nicht seitlich, und das erste Arbeitsobjekt steht im ersten Bildschirm.
13. **Zugänglich.** Bedienbar mit Tastatur und Maus, Fokus sichtbar, Farbe trägt nie allein eine Bedeutung, Text hat mindestens 4,5:1 Kontrast.

## Erscheinungsbild der Vetmeduni

Die Vetmeduni veröffentlicht kein Designhandbuch. Die Werte stammen aus dem Stylesheet ihrer öffentlichen Website. Logos und Marken werden nicht übernommen.

| Rolle | Wert |
| --- | --- |
| Grund | Weiß |
| Text | Fast schwarz `#212529` |
| Gedämpfter Text | Grau `#5f676f` |
| Abgesenkte Fläche | Hellgrau `#f4f5f7` |
| Linien | `#dee2e6`, Feldränder `#868e96` |
| Interaktion | Schwarz: Links, Auswahl, Hauptknopf, Fokus |
| Schrift | FreeSans, Helvetica Neue, Helvetica, Arial |
| Ecken | Fast eckig |

Die vier Bereichsfarben kennzeichnen nur, zu welchem Bereich ein Werkzeug gehört, etwa als dünne Linie am Kopf. Sie markieren keinen Zustand, färben keine Daten und füllen keine großen Flächen.

| Bereich | Farbe |
| --- | --- |
| Universität | `#af2144` |
| Studium | `#b35c42` |
| Forschung | `#757575` |
| Tierspital | `#296e53` |

Interaktion ist schwarz. Ein Link im Fließtext ist unterstrichen, der Hauptknopf ist schwarz gefüllt, ein zweiter Knopf weiß mit schwarzem Rand.

## Prüfung

- Vorher und nachher je ein Screenshot bei 1280 und 360 px Breite.
- Streichprobe: Jede Überschrift, Unterzeile, Beschriftung und Fläche entfällt probeweise. Es bleibt nur, was jemand beim ersten Besuch vermissen würde.
- Eine Person, die die Seite nicht kennt, nennt nach dem Lesen der ersten fünf Zeilen Gegenstand und nächsten Schritt.
