# OK Vault Experimental - Obsidian Knowledge Management System

Ein strukturiertes Obsidian Vault basierend auf der PARA-Methode (Projects, Areas, Resources, Archives) für effektives persönliches Wissensmanagement und Projektorganisation.

## 📋 Inhaltsverzeichnis

- [Überblick](#überblick)
- [Vault-Struktur](#vault-struktur)
- [Template-System](#template-system)
- [Schnellstart](#schnellstart)
- [Weitere Dokumentation](#weitere-dokumentation)

## Überblick

Dieses Vault ist ein experimentelles Wissensmanagement-System, das entwickelt wurde, um:

- **Projekte** effizient zu verwalten mit strukturierten Templates
- **Bereiche** (Areas) des persönlichen und beruflichen Lebens zu organisieren
- **Wissen** systematisch zu erfassen und zu vernetzen
- **Ressourcen** (Kontakte, Materialien) zentral zu verwalten
- **Workflows** durch Templates und Dataview-Queries zu automatisieren

### Hauptmerkmale

- ✅ **PARA-Struktur**: Organisiert nach Projects, Areas, Resources
- 📝 **Template-System**: 22+ vorkonfigurierte Templates für verschiedene Anwendungsfälle
- 🔗 **Vernetzte Notizen**: Automatische Verlinkung und Beziehungsverwaltung
- 📊 **Dataview-Integration**: Dynamische Listen und Dashboards
- ⏰ **Periodische Notizen**: Daily und Weekly Templates für Routine-Tracking
- 👥 **Kontaktverwaltung**: Separate Templates für Kollegen, Kunden und Kontakte
- 📋 **Kanban-Boards**: Task-Management mit verschiedenen Status-Views

## Vault-Struktur

```
00_knowledge/                 # Wissensmanagement nach Zettelkasten
├── 00_inbox/                # Unverarbeitete Ideen
├── 01_atomic/               # Kleine, fokussierte Wissenseinheiten
├── 02_literature/           # Notizen aus Büchern/Artikeln
├── 03_permanent/            # Verifiziertes, vernetztes Wissen
└── 00_index.md              # Knowledge-Übersicht

01_projects/                  # Aktive Projekte
└── 00_index.md              # Projekt-Übersicht

02_areas/                     # Verantwortungsbereiche
└── 00_index.md              # Area-Übersicht

03_resources/                 # Referenzmaterial
└── 00_index.md              # Ressourcen-Übersicht

04_archive/                   # Archiv
└── 00_index.md              # Archiv-Übersicht

99_obsidian/                  # System & Templates
├── 01_templates/            # Alle Templates
│   ├── 00_knowledge/       # Wissensmanagement-Templates
│   ├── 01_projects/        # Projekt-Templates
│   ├── 02_areas/           # Area-Templates
│   └── 03_resources/       # Ressourcen-Templates
└── 00_index.md              # Template-Übersicht
```

### Organisationsprinzip

Das Vault folgt der **PARA-Methode**:

1. **Projects** (`01_projects/`): Zeitlich begrenzte Vorhaben mit klarem Ziel
2. **Areas** (`02_areas/`): Langfristige Verantwortungsbereiche
3. **Resources** (`03_resources/`): Referenzmaterial und Assets
4. **Archive** (`04_archive/`): Abgeschlossene Inhalte
5. **Knowledge** (`00_knowledge/`): Permanentes Wissen (ähnlich Zettelkasten)

Jeder Top-Level-Ordner enthält eine `00_index.md` Datei mit Dataview-Übersichten.

## Template-System

Das Vault enthält **22 spezialisierte Templates**, organisiert in 4 Hauptkategorien:

### 🧠 Knowledge Templates (4 Templates)
Für die Verwaltung von Wissen und Ideen:
- Inbox-Notizen (unverarbeitete Ideen)
- Permanente Notizen (verifiziertes Wissen)
- Atomic-Notizen (kleine, fokussierte Ideen)
- Literatur-Notizen (aus Büchern, Artikeln)

### 📁 Project Templates (5 Templates)
Für die Projektverwaltung:
- Daily Notes (tägliche Projekt-Updates)
- Weekly Notes (wöchentliche Reviews)
- Meeting Notes (Projektbesprechungen)
- Task Notes (Aufgaben und Todos)
- Generic Notes (allgemeine Projekt-Notizen)

### 🎯 Area Templates (10 Templates)
Für verschiedene Lebensbereiche:
- Daily/Weekly Periodic Notes (Routine-Tracking)
- Meeting Notes (allgemeine Meetings)
- Overview Pages (Bereichs-Übersichten)
- Kanban Boards (Task-Visualisierung)
- People/Contact Notes (Personenverwaltung)
- Mentoring Notes (Mentoring-Sessions)

### 📚 Resource Templates (3 Templates)
Für Ressourcen und Kontakte:
- Customer Profiles (Kundenprofile)
- Colleague Profiles (Kollegenprofile)
- Generic People Templates

## Schnellstart

### Voraussetzungen

- [Obsidian](https://obsidian.md/) installiert
- Empfohlene Plugins:
  - **Templater**: Für dynamische Template-Funktionalität (erforderlich)
  - **Dataview**: Für dynamische Abfragen und Dashboards (erforderlich)
  - **Periodic Notes**: Für Daily/Weekly Notes (empfohlen)
  - **Tasks**: Für erweiterte Task-Verwaltung (empfohlen)

### Templates verwenden

1. **Template auswählen**: Navigiere zu `99_obsidian/01_templates/` und wähle das passende Template
2. **Template anwenden**: Nutze Templater-Hotkey oder kopiere das Template
3. **Eingaben machen**: Beantworte die Prompts für Title, Tags, etc.
4. **Automatische Organisation**: Das Template verschiebt die Notiz automatisch in den richtigen Ordner

### Beispiel: Neue Aufgabe erstellen

```markdown
1. Öffne Template: 01_templates/01_projects/project_name/kunde-project-task.md
2. Templater fragt nach:
   - Task Title
   - Task ID
   - Related Notes/Tasks
3. Die Notiz wird automatisch nach 01_projects/{project_name}/task/ verschoben
```

## GitHub Copilot Integration

Dieses Vault ist mit speziellen **GitHub Copilot Instructions** ausgestattet, die KI-Assistenten dabei helfen, die Vault-Konventionen einzuhalten und sensible Bereiche zu respektieren.

### Funktionen

- ✅ **Automatische Konventionsbeachtung**: Copilot folgt automatisch den Naming- und Frontmatter-Regeln
- 🔒 **Dynamische Pfad-Sperrung**: Bestimmte Verzeichnisse sind für Copilot blockiert (Logs, Archive, persönliche Daten)
- 📋 **Template-Awareness**: Copilot kennt alle verfügbaren Templates und deren Verwendung
- 🏗️ **Strukturverständnis**: PARA-Methode und Zettelkasten-Prinzipien sind integriert

### Blockierte Pfade

Aus Datenschutzgründen kann Copilot **nicht** auf folgende Bereiche zugreifen:
- `99_obsidian/04_logs/` - Persönliche Aktivitätslogs
- `04_archive/` - Archivierte Inhalte
- `02_areas/07_people/`, `02_areas/08_people/` - Kontaktinformationen
- `03_resources/02_people/` - Kunden- und Kollegenprofile
- Daily, Weekly und Meeting Notes - Enthalten persönliche Informationen

### Verwendung

Die Copilot-Anweisungen sind in `.github/copilot-instructions.md` dokumentiert und werden automatisch von GitHub Copilot geladen, wenn du im Vault arbeitest.

## Weitere Dokumentation

- **[INDEX.md](99_obsidian/02_config/INDEX.md)**: Vollständige Liste aller Templates mit Beschreibungen
- **[OVERVIEW.md](OVERVIEW.md)**: Detaillierte Workflows und Best Practices
- **[KONVENTIONEN.md](99_obsidian/02_config/KONVENTIONEN.md)**: Verbindliche Vault-Konventionen und Regeln
- **[.github/copilot-instructions.md](.github/copilot-instructions.md)**: GitHub Copilot Anweisungen für KI-Assistenz

## Naming Conventions & Frontmatter

### Dateinamen
- **Kleinschreibung** mit Unterstrichen als Trenner: `projekt_name_notiz.md`
- **Keine Umlaute/Sonderzeichen/Leerzeichen**
- **IDs**: Datum als ID `YYYYMMDD` oder `YYYYMMDD_HHMM`
- **Kontext über Ordner** statt im Dateinamen

### Standard-Frontmatter
Alle Notizen verwenden einheitliches Frontmatter:

```yaml
---
title: "notiz_titel"
id: "YYYYMMDD_HHMM"
created: "YYYY-MM-DD HH:mm"
tags: ["tag1", "tag2"]
category: "project|area|resource|knowledge|index"
status: "in-progress|completed|archived"
related: []
concepts: []
aliases: []
---
```

**Zusätzliche Felder** je nach Kategorie:
- **Projects**: `client`, `due`
- **Resources**: `type`, `author`, `source`
- **Knowledge**: `priority` (für Inbox)

### Tagging-Konventionen
- **Kleinschreibung**, kurze Slugs
- **Verschachtelt**: `#tool/azure`, `#topic/identity`, `#client/kunde_name`
- **Keine Duplikate** zu category/status

## Verwendete Technologien

- **Obsidian**: Knowledge Base und Note-Taking App
- **Templater Plugin**: Dynamische Template-Verarbeitung
- **Dataview Plugin**: Query-Language für Notizen
- **YAML Frontmatter**: Strukturierte Metadaten
- **Markdown**: Notizen-Format
- **GitHub Copilot**: KI-Assistent mit speziellen Vault-Anweisungen

## Struktur-Philosophie

Dieses Vault implementiert mehrere bewährte Methoden:

- **PARA-Methode**: Von Tiago Forte für Organisation von digitalen Informationen
- **Zettelkasten-Prinzip**: Für vernetztes Denken (Knowledge-Bereich)
- **Getting Things Done (GTD)**: Task-Management mit Status-Tracking
- **SMART-Goals**: Strukturierung von Projekten und Zielen

## Lizenz

Dieses Projekt ist für experimentelle und persönliche Zwecke erstellt.

## Beiträge

Da dies ein experimentelles Vault ist, sind Verbesserungen und Erweiterungen willkommen. Templates können nach Bedarf angepasst und erweitert werden.

---

**Letzte Aktualisierung**: 2025-11-10
**Version**: 1.0 (Experimental)
