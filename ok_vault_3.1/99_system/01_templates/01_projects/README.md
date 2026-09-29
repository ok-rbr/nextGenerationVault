# Project Templates - Neovim Edition

## Übersicht

Die Project-Templates wurden von Obsidian Templater zu Neovim Template-Variablen konvertiert.

## Verfügbare Templates

### 1. **projects_project_default.md** - Haupt-Projektübersicht

**Variablen:**
- `{{ project_name }}` - Name des Projekts
- `{{ customer }}` - Kundenname
- `{{ order_number }}` - Auftragsnummer
- `{{ deadline }}` - Deadline (YYYYMMDD)
- `{{ description }}` - Projektbeschreibung
- `{{ project_tag }}` - Tag für Projekt (z.B. "my-project")
- `{{ customer_tag }}` - Tag für Kunde (z.B. "acme-corp")

**Location:** `01_projects/{{ customer }}/{{ project_name }}/`

**Beispiel:**
- Kunde: "Acme Corp"
- Projekt: "Website Relaunch"
- Erstellt in: `01_projects/Acme Corp/Website Relaunch/Website Relaunch Overview.md`

---

### 2. **projects_company_default.md** - Firmen-Übersicht

**Variablen:**
- `{{ company_name }}` - Firmenname
- `{{ company_tag }}` - Tag für Firma
- `{{ industry }}` - Branche
- `{{ website }}` - Website URL
- `{{ status }}` - Status (active/inactive/prospect)

**Location:** `01_projects/{{ company_name }}/`

**Beispiel:**
- Firma: "Acme Corp"
- Erstellt in: `01_projects/Acme Corp/Acme Corp Overview.md`

---

### 3. **projects_daily_default.md** - Daily Notes

**Variablen:**
- `{{ title }}` - Titel des Daily
- `{{ customer }}` - Kunde
- `{{ project }}` - Projekt
- `{{ project_tag }}` - Projekt Tag
- `{{ date }}` - Datum (YYYYMMDD)

**Location:** `01_projects/{{ customer }}/{{ project }}/daily/`

---

### 4. **projects_weekly_default.md** - Weekly Updates

**Variablen:**
- `{{ project }}` - Projektname
- `{{ customer }}` - Kunde
- `{{ project_tag }}` - Projekt Tag
- `{{ date }}` - Datum (YYYYMMDD)

**Location:** `01_projects/{{ customer }}/{{ project }}/weekly/`

---

### 5. **projects_meetings_default.md** - Meeting Notes

**Variablen:**
- `{{ title }}` - Meeting Titel
- `{{ customer }}` - Kunde
- `{{ project }}` - Projekt
- `{{ project_tag }}` - Projekt Tag
- `{{ customer_tag }}` - Kunden Tag
- `{{ date }}` - Meeting Datum

**Location:** `01_projects/{{ customer }}/{{ project }}/meetings/`

---

### 6. **projects_docs_default.md** - Dokumentation

**Variablen:**
- `{{ title }}` - Dokument Titel
- `{{ customer }}` - Kunde
- `{{ project }}` - Projekt
- `{{ project_tag }}` - Projekt Tag
- `{{ customer_tag }}` - Kunden Tag
- `{{ doc_type }}` - Dokumenttyp (Technical, User Manual, etc.)
- `{{ description }}` - Beschreibung

**Location:** `01_projects/{{ customer }}/{{ project }}/docs/`

---

### 7. **projects_scripts_default.md** - Scripts/Automation

**Variablen:**
- `{{ title }}` - Script Name
- `{{ customer }}` - Kunde
- `{{ project }}` - Projekt
- `{{ project_tag }}` - Projekt Tag
- `{{ customer_tag }}` - Kunden Tag
- `{{ language }}` - Programmiersprache (python, bash, etc.)
- `{{ status }}` - Status (draft, active, deprecated)
- `{{ purpose }}` - Zweck des Scripts
- `{{ description }}` - Beschreibung
- `{{ usage_example }}` - Verwendungsbeispiel
- `{{ script_content }}` - Script-Code

**Location:** `01_projects/{{ customer }}/{{ project }}/scripts/`

---

## Workflow-Beispiel

### Neues Projekt erstellen:

```vim
:NoteTemplate
```

1. Template auswählen: **"Project Default"**
2. Variablen eingeben:
   - project_name: `Website Relaunch`
   - customer: `Acme Corp`
   - order_number: `2024-042`
   - deadline: `20241231`
   - description: `Complete website redesign`
   - project_tag: `website-relaunch`
   - customer_tag: `acme-corp`
3. Filename: `Website Relaunch Overview`

**Ergebnis:**
- Datei erstellt in: `01_projects/Acme Corp/Website Relaunch/`
- `location:` Zeile automatisch entfernt
- Ordner automatisch angelegt

---

## Struktur nach Erstellung

```
01_projects/
├── Acme Corp/
│   ├── Acme Corp Overview.md           # Company template
│   └── Website Relaunch/
│       ├── Website Relaunch Overview.md  # Project template
│       ├── daily/
│       │   └── 20240315_standup.md      # Daily template
│       ├── weekly/
│       │   └── Website Relaunch Weekly 20240318.md
│       ├── meetings/
│       │   └── Kickoff Meeting.md       # Meeting template
│       ├── docs/
│       │   └── Technical Spec.md        # Docs template
│       └── scripts/
│           └── deploy.md                # Scripts template
```

---

## Migration von Obsidian Templater

### Vorher (Templater):
```javascript
<%*
var projectName = await tp.system.prompt("project:")
await tp.file.move("01_projects/" + customerCompany + "/" + projectName)
%>
```

### Jetzt (Neovim):
```yaml
---
location: "01_projects/{{ customer }}/{{ project_name }}"
---
```

✅ **Viel einfacher und transparenter!**

---

## Auto-generierte Variablen

Diese Variablen werden automatisch gesetzt (musst du nicht eingeben):

- `{{ id }}` - YYYYMMDD_HHmm
- `{{ created }}` - YYYY-MM-DD HH:mm
- `{{ created_date }}` - YYYY-MM-DD
- `{{ current_date }}` - YYYY-MM-DD

---

## Tipps

1. **Tags konsistent halten**: Verwende Kebab-Case (z.B. `acme-corp`, `website-relaunch`)
2. **Ordnerstruktur**: Kunde → Projekt → Unterordner (daily, weekly, meetings, docs, scripts)
3. **Variablen-Namen**: Behalte `{{ customer }}` und `{{ project }}` konsistent über alle Templates
4. **Location-Variablen**: Du kannst Variablen in der `location:` Zeile verwenden!

---

## Beispiel-Session

```vim
" 1. Firma erstellen
:NoteTemplate  " → projects_company_default.md
" company_name: Acme Corp
" industry: Technology
" Erstellt: 01_projects/Acme Corp/Acme Corp Overview.md

" 2. Projekt erstellen
:NoteTemplate  " → projects_project_default.md
" customer: Acme Corp
" project_name: Website Relaunch
" Erstellt: 01_projects/Acme Corp/Website Relaunch/Website Relaunch Overview.md

" 3. Meeting erstellen
:NoteTemplate  " → projects_meetings_default.md
" customer: Acme Corp
" project: Website Relaunch
" title: Kickoff Meeting
" Erstellt: 01_projects/Acme Corp/Website Relaunch/meetings/Kickoff Meeting.md
```

✅ Alles automatisch am richtigen Ort!
