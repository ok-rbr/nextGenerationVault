---
title: "Vault Konventionen"
id: "20251110_2157"
created: "2025-11-10 21:57"
tags: ["obsidian/docs"]
category: "index"
status: "completed"
related: []
concepts: []
aliases: []
---

# Vault Konventionen & Regeln

Verbindliche Regeln für die Pflege des Obsidian-Vaults. Diese Konventionen sind **einzuhalten und nicht zu verändern**.

## Ordnerstruktur (Top-Level)

Die Ordnerstruktur ist exakt so zu verwenden:

```
00_knowledge/
├── 00_inbox/       # Unverarbeitete Ideen
├── 01_atomic/      # Atomare Notizen
├── 02_literature/  # Literatur-Notizen
└── 03_permanent/   # Permanentes Wissen

01_projects/        # Aktive Projekte

02_areas/           # Verantwortungsbereiche

03_resources/       # Referenzmaterial

04_archive/         # Archiv

99_system/          # Templates/Config/Workflow/Logs/Schemas
├── 01_templates/   # Alle Templates
├── 02_config/      # Konfiguration
├── 03_workflow/    # Workflow-Doku
├── 04_logs/        # Logs
└── 05_schemas/     # Frontmatter-Schemata
```

**Wichtig**: Diese Struktur entspricht der Vault-Dokumentation und orientiert sich am Zettelkasten-Block. Keine exotischen Abweichungen!

## Benennungen (Dateien & Felder)

### IDs
- **Format**: `YYYYMMDD` oder `YYYYMMDD_HHMM`
- **Beispiel**: `20251110_2157`

### Dateinamen
- **Kleingeschrieben**: `projekt_name.md`
- **Trenner**: Unterstrich `_`
- **Keine**: Umlaute, Sonderzeichen, Leerzeichen
- **Kontext über Ordner** statt im Dateinamen ausschreiben

**Beispiele**:
- ✅ `azure_identity_governance.md`
- ✅ `kunde_projekt_meeting.md`
- ❌ `Azure Identity & Governance.md`
- ❌ `Kunde-Projekt-Meeting.md`

## Frontmatter (immer setzen)

### Pflichtfelder

Alle Notizen müssen folgende Felder enthalten:

```yaml
---
title: "titel_der_notiz"
id: "YYYYMMDD_HHMM"
created: "YYYY-MM-DD HH:mm"
tags: ["tag1", "tag2"]
category: "kategorie"
status: "status"
related: []
concepts: []
aliases: []
---
```

### Felderbeschreibung

- **title**: Titel der Notiz (String)
- **id**: Eindeutige ID im Format YYYYMMDD_HHMM
- **created**: ISO-Zeitstempel (YYYY-MM-DD HH:mm)
- **tags**: Array von Tags (lowercase)
- **category**: Eine der PARA-Kategorien oder "index"
- **status**: Aktueller Status der Notiz
- **related**: Array von verwandten Notizen-Links
- **concepts**: Array von Konzepten/Themen
- **aliases**: Array von alternativen Namen

### Zeitstempel

- **Frontmatter**: ISO-Format `YYYY-MM-DD HH:mm`
- **Normaler Text**: Deutsche Formate erlaubt

### Keine erfundenen Felder

Es dürfen nur die dokumentierten Felder verwendet werden. Keine zusätzlichen Felder erfinden!

## Tagging

### Regeln
- **Kleinschreibung**: `#azure`, nicht `#Azure`
- **Kurze Slugs**: `#tool/azure`, nicht `#tool/microsoft-azure-cloud`
- **Keine Duplikate**: Status nicht als Tag, wenn bereits im Frontmatter
- **Fokus auf Inhalt/Kontext**

### Erlaubte Muster

```yaml
# Tool-Tags
#tool/azure
#tool/entra_id
#tool/powershell

# Topic-Tags
#topic/identity
#topic/security
#topic/cloud

# Client-Tags
#client/kunde_name
#client/acme_gmbh

# Optional verschachtelt
#topic/azure/governance
```

## PARA-Kategorien (category-Feld)

Erlaubte Werte für das `category`-Feld:

- **knowledge**: Wissensmanagement
- **project**: Projekte
- **area**: Verantwortungsbereiche
- **resource**: Ressourcen
- **archive**: Archiv
- **index**: Index-Seiten

## Templates & Speicherorte

### Template-Verzeichnis
- Alle Templates liegen in: `99_system/01_templates/`
- Unterverzeichnisse nach PARA-Kategorien

### Nutzung
- Existierende Templates nutzen
- Nur erweitern wenn zwingend nötig
- Kein Wildwuchs!

## Index-Seiten

### Name
- Eine pro Top-Ordner
- Name: `00_index.md`

### Gemeinsame Frontmatter-Basis

```yaml
---
title: "index - <ordnername>"
id: "<YYYYMMDD_HHMM>"
created: "<YYYY-MM-DD HH:mm>"
tags: ["obsidian/index"]
category: "index"
status: "in-progress"
related: []
concepts: []
aliases: []
---
```

### Dataview-Queries

Jede Index-Seite enthält sinnvolle Dataview-Übersichten für ihren Bereich.

## Standard-Frontmatter nach Notiztyp

### Projekt (Kunde/Initiative)

```yaml
---
title: "projekt_slug"
id: "YYYYMMDD_HHMM"
created: "YYYY-MM-DD HH:mm"
tags: ["project", "client/kunde_slug", "topic/identity", "tool/azure"]
category: "project"
status: "in-progress"
client: "Kundenname"
due: "YYYY-MM-DD"
related: []
concepts: []
aliases: []
---
```

### Area

```yaml
---
title: "area_slug"
id: "YYYYMMDD_HHMM"
created: "YYYY-MM-DD HH:mm"
tags: ["area", "topic/slug"]
category: "area"
status: "in-progress"
related: []
concepts: []
aliases: []
---
```

### Knowledge (Atomic/Literature/Permanent)

```yaml
---
title: "wissens_slug"
id: "YYYYMMDD_HHMM"
created: "YYYY-MM-DD HH:mm"
tags: ["atomic"]  # oder ["literature"], ["permanent"]
category: "knowledge"
status: "in-progress"  # oder "completed" für permanent
related: []
concepts: []
aliases: []
---
```

**Zusätzliche Felder für Literature**:
- `author`: Autor
- `source`: Quelle/Link
- `type`: Typ (book, article, video)

**Zusätzliche Felder für Inbox**:
- `priority`: Priorität (low, medium, high)
- `source`: Quelle (optional)

## Qualitätsregeln

### Immer prüfen

1. **Keine Felder doppeln**: Status nicht zusätzlich als Tag
2. **IDs/Dateinamen** strikt nach Naming-Konventionen
3. **Templates** aus `99_system/01_templates/` nutzen
4. **Dataview** nutzt einfache Abfragen (kein Over-Engineering)

### Best Practices

- **Konsistenz**: Gleiche Feldnamen überall
- **Einfachheit**: Keine komplexen verschachtelten Strukturen
- **Wartbarkeit**: Queries müssen verständlich sein
- **Performance**: Limits in Dataview-Queries setzen

## Beispiele

### Gutes Beispiel - Projekt

```yaml
---
title: "website_relaunch"
id: "20251110_1430"
created: "2025-11-10 14:30"
tags: ["project", "client/acme_gmbh", "topic/web", "tool/azure"]
category: "project"
status: "in-progress"
client: "ACME GmbH"
due: "2025-12-31"
related: []
concepts: []
aliases: []
---

# [[website_relaunch]]

## Projektbeschreibung
Relaunch der Unternehmenswebsite mit Azure Static Web Apps.

## Ziele
- Modernisierung des Designs
- Verbesserung der Performance
- SEO-Optimierung
```

### Schlechtes Beispiel - Projekt

```yaml
---
title: Website Relaunch  # ❌ Leerzeichen
created: 10.11.2025      # ❌ Deutsches Datumsformat
tags: [Project, ACME]    # ❌ Großschreibung
category: proj           # ❌ Nicht erlaubter Wert
status: active           # ✅ OK
customField: value       # ❌ Erfundenes Feld
---
```

## Werkzeuge & Plugins

### Erforderlich
- **Templater**: Für dynamische Templates
- **Dataview**: Für Queries und Übersichten

### Empfohlen
- **Periodic Notes**: Für Daily/Weekly Notes
- **Tasks**: Für Task-Management
- **Calendar**: Für zeitbasierte Navigation

## Wartung

### Regelmäßig prüfen
- Konsistenz der Frontmatter-Felder
- Aktualität der Index-Seiten
- Funktionalität der Dataview-Queries
- Einhaltung der Naming-Konventionen

### Bei Änderungen
- Templates aktualisieren
- Index-Seiten anpassen
- Dokumentation updaten

---

**Version**: 1.0
**Stand**: 2025-11-10
**Verantwortlich**: KI-Agent für Vault-Pflege
