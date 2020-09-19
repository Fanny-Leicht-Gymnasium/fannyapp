# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [1.1.1] - 2020-09-19
### Hinzugefügt
- "Wo ist der Vertretungsplan?" - Menü

### Entfernt
- Anmeldung
- Vertretungsplan
- Einstellungen für den Vertretungsplan
- "Folge uns" Taste in den Einstellungen

## [1.1.0] - 2020-01
### Hinzugefügt
- PDF-Taste oben rechts in der Vertretungsplan-Ansicht, um den Vertretungsplan als PDF anzusehen
- Fehlermeldung "Verarbeitungsfehler" mit Taste zum Ansehen der PDF Datei

### Entfernt
-  ständige Abfragen im Hintergrund, die sehr viel Datenvolumen verbrauchten

### Geändert
- einige Icons

##  [1.0.2] - 2019-03-14
### Hinzugefügt
- Dunkler Modus
- ssl (https) Verschlüsselung
- "Support" und "Folge uns" Tasten in den Einstellungen

### Behoben
- Fehler, der dafür sorgte, dass fälschlicherweise 'keine Verbindung zum server' angezeigt wurde

### Geändert
- timeout auf 10 sekunden erhöht

## [1.0.1]
### Behoben
- Fehler, der dafür sorgte, dass die 'morgen' Taste immer den heutigen Vertretungsplan anzeigte

## [1.0.0]
### Behoben
- Absturz, der bei schnellem wechsel zwischen Seiten (Vertretungsplan, Essensplan) auftrat

### Geändert
- neue Vertretungsplan api implementiert
- neues Anmeldesystem des Vertretungsplanes implementiert
- neue Essensplan api implementiert
- Anmeldebidschirm neu gestaltet (vorallem im Querformat)

### Hinzugefügt
- "Registriern" Taste auf dem Anmeldebidschirm

## [0.9.x] - 2018-12-30
### Geändert
- Komplett neues Design
- der Vertretungsplan wird jetzt innerhalb der App angezeigt
- Auf der Anmelde-Seite ist jetzt der gesamte Text auf deutsch
- Die fanny-Webseite wird jetzt nicht mehr innerhalb der App angezeigt

### Behoben
- Viele interne Verbesserungen, die zu besserer performance führen

### Hinzugefügt
- Jetzt kompatibel mit der neusten android API und IOS Geräten
- Lehrermodus
- Der Vertretungsplan lässt isch nach Klassen sortieren

## [0.04] - 2018-07-19
### Behoben
- Fehler beim Speiseplan, der dafür sorgte, dass der letzte Tag fehlerhaft (zu dünn) angezeigt wurde, wenn nurnoch ein Tag angezeigt wurde

### Hinzugefügt
- Hinweis zu den Anmeldedaten beim Login
- Logos in der rechten oberen Ecke, bei einem Click darauf öffnet sich die zugehörige Webseite
- "Menü" Balken über dem Menü
- Anmation beim Öffnen / Schließen der Fehleranzeige

### Geändert
- Im Menü ist die "abmelden" Schaltfläche jetzt rot

## [0.03.3] - 2018-07-1
### Behoben
- Fehler, durch den am Monatswechsel beim Speiseplan auch die vorherige Woche angezeigt wurde


## [0.03.2] - 2018-06-29
### Hinzugefügt
- Animation beim clicken der heute / morgen Tasten
- Striche zwischen den einzelnen Reihen zur besseren Übersicht beim Speiseplan hinzugefügt

### Geändert
- Die bisherige Fortschrittsanzeige durch eine kreisförmige erstezt

### Behoben
- Der Text beim Spieseplan wird nicht mehr abgeschnitten
- Beim Laden des Speiseplanes werden keine sehr großen oder kleinen Zahlen mehr angezeigt


## [0.03.1] - 2018-06-25
### Behoben
- Problem, das dafür sorgte, dass die App beim Starten (im Zustand: Angemldet, Internetverbindung hergestellt)
direkt abstürzte

## [0.03] - 2018-06-25
### Hinzugefügt
- Bug behoben, durch den man fehlerhafter weise abgemeldet wurde, wenn die App
ohne Internetverbindung gestertet und diese dann während die app lief wieder hergestellt wurde
- Vollständige Anzeige für den Speiseplan
- Handler für den Speiseplan
- die alten pdf dateien werden vor dem herunterladen der neuen gelösch
- Heute und Morgen Knöpfe werden deaktiviert, wenn eine Fehlermeldung (window.is_error === true) vorliegt

## [0.02] - 2018-06-22
### Hinzugefügt
- Fortschrittsanzeigr beim Herunterladen der pdfs

### Behoben
- Rechtschreibfehler auf der Startseite

## [0.01] - 2018-06-21
### Hinzugefügt
- Anzeigen des Vertretungsplanes
- Anzeigen der Fanny-Webseite
- Anmelden und angemeldet bleiben
- Abmelden
