# Project Checklist – Eigener Minecraft-Server

Checklist from Developer Akademie (original in German). Completed items are checked.

## 1. Repository

### Vorhandene Dateien

- [x] Es wurde eine `.gitignore` Datei angelegt, die alle irrelevanten Inhalte aus dem Git-Repository ignoriert
- [x] Es gibt eine `docker-compose.yaml`, die den Anforderungen des nächsten Punkts genügt
- [x] Eine Datei namens `README.md` ist vorhanden und entsprechend der Kriterien unten erstellt worden
- [x] Es befinden sich keine weiteren Dateien im Repository, ohne dass diese explizit in der `README.md` benannt und beschrieben werden

### Dockerfile

- [x] Es gibt ein Dockerfile, in dem ein passendes Image zusammengestellt wird, um einen Minecraft-Server zu starten
  - [x] siehe **3. Hinweise** für den Download-Link zur Server-Anwendung
- [x] Im Dockerfile sollen alle notwendigen Pakete im Basis-Image installiert und ggf. konfiguriert werden
- [x] Stelle sicher, dass dein Server immer starten kann, für Umgebungsvariablen solltest du evtl. Default-Werte verwenden
- [x] Du solltest dabei kein vorgefertigtes Minecraft-Image verwenden

### docker-compose.yaml

- [x] Es gibt einen Service, der definiert und konfiguriert wird: `mc-server`
- [x] Es gibt eine Env-Konfiguration für den Minecraft-Server-Service, bei der alle unkritischen Variablen konfiguriert werden (keine Auth!)
- [x] Es gibt notwendige Port-Freigaben, sodass der Container aus dem Internet erreichbar ist
- [x] Es gibt Volume-Konfigurationen für die Container-Daten, sodass die Inhalte auf einem Dateisystem persistiert werden und der Spielstand nicht verloren geht

### README.md

- [x] Die README sollte ein Inhaltsverzeichnis a.k.a. Table of Contents (ToC) enthalten
- [x] Eine Sektion mit einer Beschreibung des Repositories muss vorhanden sein. In dieser Beschreibung sollte genannt werden, was die wesentlichen Inhalte sind und was der Zweck des Repositories ist
- [x] Eine Sektion "Quickstart" sollte als Teil der README enthalten sein. Hier sollten kurz Voraussetzungen genannt und eine Schnellstart-Anleitung beschrieben sein
- [x] Eine ausführliche Variante der vorgenannten Sektion soll als "Usage" enthalten sein. Hier soll genauer auf die Konfiguration und Konfigurierbarkeit eingegangen werden, d.h. es soll auch erklärt werden, wie relevante Passagen modifiziert werden können, um andere Resultate zu erzielen

## 2. Dokumentation

- [x] Die Dokumentation des Codes sowie des Projektes soll im Repository in Form einer README-Datei stattfinden
- [x] Die Dokumentationssprache für alle Projekte (und zugehörige Unterlagen) ist Englisch

## 3. Hinweise

Du kannst dir eine Minecraft-Server-Binary direkt auf der Minecraft-Seite herunterladen (nutze hier die Java-Version): <https://www.minecraft.net/de-de/download>

### Allgemeine Hinweise

- [ ] Zusätzlich zu deinem GitHub-Repository solltest du ein kurzes Loom-Video (maximal 5 min.) aufnehmen und bereitstellen, indem du kurz deine Abgabe zeigst und vorstellst, was du getan hast

### Sicherheitshinweise

- [x] Speichere keine SSH-Keys im Workspace deines Git-Repositories
- [x] Speichere keine Passwörter, Tokens oder Benutzernamen in deinem Code. Verwende hierfür stattdessen Environment-Variablen
- [x] Speichere keine IP-Adressen oder sonstigen sensiblen Informationen in einem Git-Repository

### Code-Konventionen

- [x] Für build-args, Environment-Variablen und Shell-Variablen gilt folgende Namenskonvention: `UPPER_CASE_WITH_UNDERSCORE`
- [x] Bei einer Referenz auf eine Variable sollte immer die `{}`-Notation verwendet werden, um Fehler in der Interpretation zu vermeiden: `${SOME_VAR_VALUE}` statt `$SOME_VAR_VALUE`
- [x] Es sollten für build-args oder Environment-Variablen "Default"-Werte konfiguriert werden, allerdings nur dann, wenn dies Sinn ergibt
- [x] Kritische Konfiguration wie Tokens, Passwörter oder Ähnliches sollte nicht im Code-Repository gespeichert sein, sondern bspw. durch die Verwendung eines `.env`-Files in einen Container hineingegeben werden

## Testing

Bevor du dein Projekt einreichst, solltest du die folgenden Dinge sichergestellt und getestet haben:

- [x] Der Minecraft-Server ist erreichbar unter der IP-Adresse deiner Cloud-VM auf Port 8888
- [x] Für das Testen hast du grundsätzlich zwei Wege: das Spiel starten und versuchen, dich auf deinen Server zu verbinden, oder mittels eines Skriptes versuchen, eine Verbindung zum Minecraft-Server aufzubauen. Dazu kannst du das folgende Python-Modul verwenden: <https://github.com/py-mine/mcstatus>
- [ ] (optional) Du kannst dich von deinem Java-Minecraft-Client auf deinem Computer mit dem Server auf deiner Cloud-VM verbinden und Minecraft spielen
- [x] Nach einem Neustart des Servers sind die konfigurierten Daten noch vorhanden und werden nicht gelöscht oder überschrieben. Dazu gehört unter anderem der Spielstand und die Konfiguration des Game-Servers
- [x] Die Container der Services werden neugestartet, sobald ein Fehler passiert, der zum Terminieren des Containers führt
