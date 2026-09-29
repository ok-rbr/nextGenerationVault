# Project Templates

Diese Templates ermöglichen es, neue Projekte mit den notwendigen Metadaten und Standardvorlagen anzulegen.

## Übersicht

Das Template-System besteht aus einem Hauptprojekt-Template und fünf Standard-Templates für verschiedene Projektaktivitäten:

1. **project_template.md** - Hauptvorlage für neue Projekte
2. **project_meeting_template.md** - Vorlage für Meetings
3. **project_daily_template.md** - Vorlage für Daily Stand-ups
4. **project_note_template.md** - Vorlage für Projektnotizen
5. **project_task_template.md** - Vorlage für Aufgaben
6. **project_weekly_template.md** - Vorlage für wöchentliche Meetings

## Verwendung

### Neues Projekt anlegen

1. Erstelle eine neue Notiz in Obsidian
2. Wähle das Template `project_template.md` aus
3. Beantworte die folgenden Fragen:
   - **Project Name**: Kurzer Name des Projekts (z.B. "b2csnt")
   - **Customer/Client Name**: Name des Kunden
   - **Project Description**: Kurze Beschreibung des Projekts
   - **Project Start Date**: Startdatum im Format YYYYMMDD
   - **Status**: Projektstatus (Active, Planning, On Hold, Completed, Archived)

Das Template erstellt automatisch:
- Eine Projektübersichtsseite mit allen Metadaten
- DataviewJS-Abfragen für Aufgaben, Meetings und Notizen
- Die Ordnerstruktur unter `01_projects/{projectName}/`

### Meeting erstellen

1. Erstelle eine neue Notiz
2. Wähle das Template `project_meeting_template.md`
3. Gib die folgenden Informationen ein:
   - **Project Name**: Name des Projekts
   - **Meeting Name**: Titel des Meetings
   - **Meeting Date**: Datum im Format YYYYMMDD
   - **Attendees**: Teilnehmer (kommagetrennt)

Die Datei wird automatisch verschoben nach: `01_projects/{projectName}/meetings/{date}_{title}.md`

**Tags**: `meeting`, `{projectName}`

### Daily Stand-up erstellen

1. Erstelle eine neue Notiz
2. Wähle das Template `project_daily_template.md`
3. Gib die folgenden Informationen ein:
   - **Project Name**: Name des Projekts
   - **Customer Name**: Kundenname für die Anzeige

Die Datei wird automatisch verschoben nach: `01_projects/{projectName}/daily/{date}_{customerName}-Daily.md`

**Tags**: `daily`, `{projectName}`

**Features**:
- Automatische DataviewJS-Abfragen für offene und erledigte Daily-Aufgaben
- Datum wird automatisch gesetzt

### Notiz erstellen

1. Erstelle eine neue Notiz
2. Wähle das Template `project_note_template.md`
3. Gib die folgenden Informationen ein:
   - **Project Name**: Name des Projekts
   - **Note Title**: Titel der Notiz
   - **Status**: Status (Active, Draft, Completed, Archived)

Die Datei wird automatisch verschoben nach: `01_projects/{projectName}/doc/{title}.md`

**Tags**: `note`, `{projectName}`

### Aufgabe erstellen

1. Erstelle eine neue Notiz
2. Wähle das Template `project_task_template.md`
3. Gib die folgenden Informationen ein:
   - **Project Name**: Name des Projekts
   - **Task Title**: Titel der Aufgabe
   - **Task ID**: Eindeutige Task-ID (z.B. PROJ-123)
   - **Priority**: Priorität (Critical, High, Medium, Low)
   - **Status**: Status (Active, In Progress, Blocked, Completed, Cancelled)
   - **Related**: Verknüpfte Notizen/Aufgaben (kommagetrennt, optional)

Die Datei wird automatisch verschoben nach: `01_projects/{projectName}/task/{title}.md`

**Tags**: `task`, `{projectName}`

### Wöchentliches Meeting erstellen

1. Erstelle eine neue Notiz
2. Wähle das Template `project_weekly_template.md`
3. Gib die folgenden Informationen ein:
   - **Project Name**: Name des Projekts
   - **Customer Name**: Kundenname für die Anzeige
   - **Meeting Date**: Datum im Format YYYYMMDD
   - **Attendees**: Teilnehmer (kommagetrennt, optional)

Die Datei wird automatisch verschoben nach: `01_projects/{projectName}/weekly/{date}_{customerName}-weekly.md`

**Tags**: `weekly`, `{projectName}`, `meeting`

**Features**:
- DataviewJS-Abfrage für offene wöchentliche Aufgaben
- Abschnitte für Highlights, Blockers, Decisions und Metriken

## Projektstruktur

Nach dem Anlegen eines Projekts wird folgende Ordnerstruktur erstellt:

```
01_projects/
└── {projectName}/
    ├── {projectName}.md          (Hauptprojektseite)
    ├── meetings/                 (Meeting-Notizen)
    ├── daily/                    (Daily Stand-ups)
    ├── doc/                      (Projektdokumentationen)
    ├── task/                     (Aufgaben)
    └── weekly/                   (Wöchentliche Meetings)
```

## Metadaten

Alle Templates verwenden konsistente Metadaten im YAML-Frontmatter:

- **title**: Titel der Notiz
- **created**: Erstellungsdatum und -zeit
- **tags**: Liste von Tags
- **category**: Kategorie (project, meeting, daily, note, task, weekly)
- **project**: Projektname
- **status**: Status (wo zutreffend)

## DataviewJS-Integration

Die Templates enthalten DataviewJS-Abfragen für:
- Aufgabenlisten nach Projekt gefiltert
- Letzte Meetings
- Projektnotizen
- Wöchentliche Aufgaben

## Anforderungen

- Obsidian mit Templater Plugin
- Dataview Plugin (für die DataviewJS-Abfragen)

## Anpassung

Die Templates können nach Bedarf angepasst werden:
- Füge zusätzliche Metadatenfelder hinzu
- Passe die Abschnitte in den Templates an
- Ändere die DataviewJS-Abfragen nach deinen Bedürfnissen
- Füge weitere Tags hinzu

## Tipps

1. **Einheitliche Projektnamen**: Verwende kurze, eindeutige Projektnamen ohne Leerzeichen
2. **Datum-Format**: Verwende immer das Format YYYYMMDD für konsistente Sortierung
3. **Tags**: Nutze die Tags für Dataview-Abfragen und Filter
4. **Task-IDs**: Verwende ein konsistentes Format für Task-IDs (z.B. PROJ-001, PROJ-002)
5. **Verknüpfungen**: Nutze die Related-Felder, um Verbindungen zwischen Notizen herzustellen
