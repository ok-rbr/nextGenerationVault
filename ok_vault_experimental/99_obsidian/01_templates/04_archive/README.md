# Archivierungs-Workflows

Diese Templates implementieren die Archivierungs-Workflows für den Vault gemäß der PARA-Struktur.

## Übersicht

Das Archivierungssystem organisiert abgeschlossene oder inaktive Inhalte in einer strukturierten Tagesordner-Hierarchie:

```
04_archive/
├── YYYYMMDD/              # Ein Ordner pro Archivierungstag
│   ├── 00_index.md       # Tagesindex (automatisch generiert)
│   ├── notes/            # Archivierte Notizen
│   │   └── ...
│   └── projects/         # Archivierte Projekte
│       └── ...
```

## Verfügbare Templates

### 1. Archive Note (`archive_note.md`)

**Zweck**: Archiviert eine einzelne Notiz in die Tagesordner-Struktur.

**Verwendung**:
1. Öffne die zu archivierende Notiz
2. Wende das Template `archive_note.md` an
3. Gib optional einen Archivierungsgrund ein
4. Die Notiz wird nach `04_archive/YYYYMMDD/notes/` verschoben

**Metadaten**:
- Setzt `status: archived`
- Fügt `archived_on` (Zeitstempel) hinzu
- Fügt `archived_from` (ursprünglicher Pfad) hinzu
- Fügt `archived_by` (Benutzer/System) hinzu
- Optional: `archive_reason` (Grund der Archivierung)

**Beispiel**:
```yaml
---
status: archived
archived_on: 2025-11-10 22:30
archived_from: 02_areas/01_notes
archived_by: user
archive_reason: Projekt abgeschlossen
---
```

### 2. Archive Project (`archive_project.md`)

**Zweck**: Archiviert ein Projekt mit allen Metadaten.

**Verwendung**:
1. Öffne die Projekt-Hauptdatei
2. Wende das Template `archive_project.md` an
3. Gib optional Archivierungsgrund und Projektergebnis ein
4. Das Projekt wird nach `04_archive/YYYYMMDD/projects/` verschoben

**Metadaten**:
- Setzt `status: archived`
- Fügt `archived_on`, `archived_from`, `archived_by` hinzu
- Behält projektspezifische Felder (`client`, `due`) bei
- Optional: `archive_reason` und `project_outcome`

**Beispiel**:
```yaml
---
status: archived
archived_on: 2025-11-10 22:30
archived_from: 01_projects/b2csnt
archived_by: user
archive_reason: Projekt erfolgreich abgeschlossen
project_outcome: Alle Ziele erreicht, Migration erfolgreich
client: ACME GmbH
due: 2025-11-01
---
```

### 3. Archive Index (`archive_index.md`)

**Zweck**: Erstellt einen Tagesindex für archivierte Inhalte.

**Verwendung**:
1. Navigiere zu `04_archive/YYYYMMDD/`
2. Erstelle neue Notiz und wende Template an
3. Der Index wird automatisch erstellt

**Features**:
- Übersicht aller archivierten Notizen des Tages
- Übersicht aller archivierten Projekte des Tages
- Statistiken (Anzahl archivierter Items)
- Navigation zu vorherigem/nächstem Archiv-Tag

**Hinweis**: Der Index wird nur manuell angelegt, wenn tatsächlich etwas archiviert wurde.

## Workflow-Beispiele

### Beispiel 1: Notiz archivieren

```
1. Notiz "meeting_notes_q4.md" ist in 02_areas/01_notes/
2. Template "archive_note.md" auf Notiz anwenden
3. Prompt: "Reason for archiving" → "Quartal abgeschlossen"
4. Ergebnis: Notiz liegt in 04_archive/20251110/notes/meeting_notes_q4.md
5. Status ist "archived" mit allen Metadaten
```

### Beispiel 2: Projekt archivieren

```
1. Projekt "website_relaunch" ist in 01_projects/website_relaunch/
2. Template "archive_project.md" auf Projekt anwenden
3. Prompts:
   - "Reason for archiving" → "Projekt erfolgreich abgeschlossen"
   - "Project outcome" → "Website live, alle Features implementiert"
4. Ergebnis: Projekt liegt in 04_archive/20251110/projects/website_relaunch.md
5. Client- und Due-Felder bleiben erhalten
```

### Beispiel 3: Tagesindex erstellen

```
1. Nach Archivierung mehrerer Items am selben Tag
2. In 04_archive/20251110/ neue Notiz erstellen
3. Template "archive_index.md" anwenden
4. Ergebnis: Index zeigt alle archivierten Items mit Dataview-Queries
```

## Best Practices

### Vor dem Archivieren

1. **Prüfen**: Ist das Item wirklich abgeschlossen/nicht mehr aktiv?
2. **Dokumentieren**: Wichtige Ergebnisse/Learnings in der Notiz festhalten
3. **Verlinken**: Sicherstellen, dass wichtige Querverweise vorhanden sind

### Beim Archivieren

1. **Grund angeben**: Immer einen aussagekräftigen Archivierungsgrund eingeben
2. **Metadaten prüfen**: Bei Projekten sicherstellen, dass client/due korrekt sind
3. **Einmalig**: Archivierung nicht rückgängig machen (non-destructive)

### Nach dem Archivieren

1. **Index erstellen**: Wenn mehrere Items am Tag archiviert wurden
2. **Verlinkungen**: Ggf. Backlinks in anderen Notizen aktualisieren
3. **Aufräumen**: Projektordner können optional auch archiviert werden

## Archiv-Suche

### Via Dataview (im Hauptindex 04_archive/00_index.md)

```dataview
TABLE 
  file.link as Item,
  archived_from as "Original Location",
  archived_on as "Archived On"
FROM "04_archive"
WHERE status = "archived"
SORT archived_on desc
LIMIT 50
```

### Via Obsidian-Suche

- Nach Status: `status:archived`
- Nach Datum: `archived_on:2025-11-10`
- Nach Client: `client:"ACME GmbH" status:archived`

## Wartung

### Regelmäßig (monatlich)

1. Prüfen, ob alle archivierten Items korrekte Metadaten haben
2. Fehlende Tagesindizes nachträglich erstellen (optional)
3. Sehr alte Archive (>2 Jahre) auf externe Speicher auslagern (optional)

### Bei Bedarf

- Archive wiederherstellen: Manuelle Datei-Verschiebung + Status ändern
- Archive löschen: Nur nach Rücksprache, nie automatisch
- Massenarchivierung: Skript erstellen oder manuell einzeln durchführen

## Integration mit lib.js

Alle Archivierungs-Templates nutzen die Bibliotheksfunktionen aus `_scripts/lib.js`:

- `lib.getArchivePath(tp, dateStr)`: Basis-Archivpfad
- `lib.getArchiveNotesPath(tp, dateStr)`: Notiz-Archivpfad
- `lib.getArchiveProjectsPath(tp, dateStr)`: Projekt-Archivpfad
- `lib.generateArchiveMetadata(tp, originalPath, archiver)`: Metadaten

## Troubleshooting

**Problem**: Template findet lib.js nicht  
**Lösung**: Sicherstellen, dass `_scripts/lib.js` existiert und Templater korrekt konfiguriert ist

**Problem**: Ordner existiert nicht  
**Lösung**: Ordner werden nicht automatisch erstellt, manuell anlegen: `04_archive/YYYYMMDD/notes/` und `04_archive/YYYYMMDD/projects/`

**Problem**: Metadaten fehlen nach Archivierung  
**Lösung**: Template erneut anwenden oder Frontmatter manuell ergänzen

## Änderungshistorie

- **v1.0** (2025-11-10): Initiale Version mit drei Templates
  - Archive Note
  - Archive Project
  - Archive Index

---

**Version**: 1.0  
**Stand**: 2025-11-10  
**Autor**: KI-Agent für Vault-Pflege
