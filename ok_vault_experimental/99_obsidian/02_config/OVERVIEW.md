# Overview - Workflows & Best Practices

Detaillierte Anleitung zur Verwendung des OK Vault Experimental Systems mit konkreten Workflows, Best Practices und Anwendungsbeispielen.

## 📑 Inhaltsverzeichnis

- [Erste Schritte](#erste-schritte)
- [Tägliche Workflows](#tägliche-workflows)
- [Projekt-Workflows](#projekt-workflows)
- [Wissensmanagement-Workflows](#wissensmanagement-workflows)
- [Kontakt- und Beziehungsmanagement](#kontakt--und-beziehungsmanagement)
- [Best Practices](#best-practices)
- [Plugin-Konfiguration](#plugin-konfiguration)
- [Häufige Anwendungsfälle](#häufige-anwendungsfälle)

---

## Erste Schritte

### Initial Setup

1. **Obsidian installieren**
   - Download von [obsidian.md](https://obsidian.md/)
   - Vault öffnen: Diesen Ordner als Vault auswählen

2. **Essenzielle Plugins installieren**
   - Settings → Community Plugins → Browse
   - Installieren:
     - ✅ **Templater** (erforderlich)
     - ✅ **Dataview** (erforderlich)
     - ⭐ **Periodic Notes** (empfohlen)
     - ⭐ **Tasks** (empfohlen)
     - ⭐ **Calendar** (optional)

3. **Templater konfigurieren**
   ```
   Settings → Templater
   - Template folder location: 99_obsidian/01_templates
   - Trigger Templater on new file creation: ON
   - Enable System Commands: ON
   ```

4. **Dataview aktivieren**
   ```
   Settings → Dataview
   - Enable JavaScript Queries: ON
   - Enable Inline Queries: ON
   ```

### Erste Template-Nutzung

**Beispiel: Deine erste tägliche Notiz**

1. Erstelle neue Notiz
2. Öffne Command Palette (Ctrl/Cmd + P)
3. Suche: "Templater: Insert Template"
4. Wähle: `02_areas/01_periodicNotes/daily_default.md`
5. Die Notiz wird automatisch mit dem heutigen Datum erstellt

---

## Tägliche Workflows

### Morgen-Routine: Tagesplanung

**Workflow**: Starte jeden Tag mit einer strukturierten Übersicht

1. **Daily Note erstellen**
   - Template: `daily_default.md`
   - Automatische Erstellung mit Periodic Notes Plugin
   
2. **Aufgaben reviewen**
   - Dataview zeigt automatisch:
     - Heute fällige Tasks
     - Scheduled Tasks
     - Active Tasks aus allen Projekten
   
3. **Meetings checken**
   - Meeting-Liste wird automatisch gefiltert nach heutigem Datum
   
4. **Prioritäten setzen**
   - Im Log-Bereich notieren: Top 3 Prioritäten für den Tag

**Beispiel Daily Note**:
```markdown
## Log
### Prioritäten heute:
1. [ ] Meeting-Vorbereitung für Kundengespräch
2. [ ] Code Review PR #123
3. [ ] Sprint Planning Dokument finalisieren

### Notes:
- Wichtiger Call um 14:00 mit Team
- Deadline Projektbericht: morgen
```

---

### Abend-Routine: Tages-Review

**Workflow**: Tag reflektieren und morgigen Tag vorbereiten

1. **Tasks aktualisieren**
   - Erledigte Tasks abhaken
   - Nicht erledigte Tasks auf morgen verschieben oder neu priorisieren

2. **Log ergänzen**
   - Achievements notieren
   - Learnings festhalten
   - Offene Punkte für morgen

3. **Weekly Note verlinken** (freitags)
   - Weekly Review starten
   - Link zur Weekly Note in Daily Note

---

## Projekt-Workflows

### Neues Projekt starten

**Workflow**: Strukturiertes Setup für ein neues Projekt

1. **Projekt-Ordner anlegen**
   ```
   01_projects/
   └── [projekt-name]/
       ├── daily/
       ├── weekly/
       ├── meetings/
       ├── tasks/
       └── notes/
   ```

2. **Project Overview erstellen**
   - Template: `overview_default.md`
   - Area: Projekt-Name eingeben
   - Beschreibung: Projektziel dokumentieren

3. **Erste Tasks anlegen**
   - Template: `kunde-project-task.md`
   - Task IDs vergeben (z.B. PROJ-001)
   - Prioritäten setzen

4. **Kanban Board erstellen**
   - Template: `kanban_default.md`
   - Area: Projekt-Name (muss mit Tasks übereinstimmen)
   - Board zeigt automatisch Tasks nach Status

**Beispiel Projekt-Setup**:
```
Projekt: "Website Relaunch"
- Overview: Website_Relaunch_Overview.md
- Kanban: Website_Relaunch_Board.md
- Initial Tasks:
  - SITE-001: Design Konzept
  - SITE-002: Techstack Evaluation
  - SITE-003: Content Migration Plan
```

---

### Projekt-Meeting dokumentieren

**Workflow**: Strukturierte Meeting-Dokumentation

1. **Meeting Note erstellen**
   - Template: `kunde-project-meeting.md`
   - Datum im Format: YYYYMM-D
   - Automatische Verschiebung nach `meetings/`

2. **Während des Meetings**
   - **Agenda**: Vorab ausfüllen oder zu Beginn ergänzen
   - **Log**: Live-Notizen während des Meetings
   - **Action Items**: Tasks direkt als Checkboxen

3. **Nach dem Meeting**
   - Action Items in separate Task Notes überführen
   - Meeting in Project Overview verlinken
   - Attendees informieren (Link zum Meeting teilen)

**Beispiel Meeting Note**:
```markdown
## Agenda
- Sprint Review Ergebnisse
- Nächste Sprint Planung
- Blocker diskutieren

## Log
- Team präsentiert 12 abgeschlossene Stories
- Blocker: API-Zugang noch nicht verfügbar
- Entscheidung: Sprint Scope reduzieren

## Action Items
- [ ] PM: API-Zugang bei Kunde anfordern [@PROJ-025]
- [ ] Dev: Alternative Mock-Daten vorbereiten [@PROJ-026]
- [ ] PO: User Stories für Sprint 3 refinieren [@PROJ-027]
```

---

### Task-Management im Projekt

**Workflow**: Von der Idee zur erledigten Aufgabe

1. **Task erstellen**
   - Template: `kunde-project-task.md`
   - Task ID: Fortlaufend (PROJ-XXX)
   - Related: Verknüpfung zu anderen Tasks/Notes

2. **Task bearbeiten**
   - Status ändern: `active`, `pending`, `blocked`, `done`
   - Progression Log: Updates und Fortschritte dokumentieren
   - Related Notes: Erkenntnisse verlinken

3. **Task nachverfolgen**
   - Im Kanban Board: Visueller Status
   - In Daily Notes: Heutige Tasks
   - Im Project Overview: Alle aktiven Tasks

**Task-Status-Modell**:
```
backlog → todo → active → done
              ↓
           pending ← (wartet auf Input)
              ↓
           blocked ← (kann nicht fortfahren)
```

---

## Wissensmanagement-Workflows

### Zettelkasten-Workflow: Von der Idee zum permanenten Wissen

**Workflow**: Systematische Wissensverarbeitung

#### Phase 1: Capture (Inbox)

1. **Idee erfassen**
   - Template: `knowledge_inbox_default.md`
   - Schnell und ungefiltert
   - Quelle notieren (falls vorhanden)
   - Priorität grob einschätzen

**Beispiel Inbox Note**:
```markdown
---
title: "Microservices Communication Patterns"
priority: high
source: "Martin Fowler Blog"
status: unprocessed
---

# Idea Summary
- Verschiedene Patterns für Service-zu-Service Kommunikation
- Synchron vs. Asynchron
- Event-Driven Architecture

## Next Steps
- [ ] Artikel komplett lesen
- [ ] In Permanent Note überführen
```

#### Phase 2: Process (Atomic Notes)

1. **Idee verarbeiten**
   - Inbox Note öffnen
   - Template: `knowledge_atomic_default.md`
   - Eine Idee = Eine Atomic Note
   - Eigene Worte verwenden

2. **Konzepte identifizieren**
   - Key Concepts definieren
   - Tags sinnvoll setzen

**Beispiel Atomic Note**:
```markdown
---
title: "Event-Driven Architecture Benefits"
concepts: ["architecture", "events", "decoupling"]
related: ["Microservices Communication", "Async Patterns"]
---

## Event-Driven Architecture Benefits

Hauptvorteil: Loose Coupling zwischen Services
- Services müssen sich nicht kennen
- Kommunikation über Event Bus
- Skalierbarkeit durch Async Processing

### Related Notes
- [[Microservices Communication Patterns]]
- [[Message Queue Patterns]]
```

#### Phase 3: Connect (Permanent Notes)

1. **Wissen konsolidieren**
   - Mehrere Atomic Notes zu einem Thema
   - Template: `knowledge_permanent_default.md`
   - Vernetzung mit anderen Permanent Notes
   - Status: completed

2. **Beziehungen erstellen**
   - Related Notes verlinken
   - Konzepte taggen
   - Backlinks reviewen

**Beispiel Permanent Note**:
```markdown
---
title: "Microservices Architecture Design Principles"
concepts: ["microservices", "architecture", "design"]
related: ["Event-Driven Architecture", "Domain-Driven Design", "API Gateway Pattern"]
status: completed
---

## Summary
Microservices Architecture basiert auf mehreren Kern-Prinzipien:
1. Service Autonomy
2. Decentralized Data Management
3. Infrastructure Automation

[Detaillierter Inhalt...]

### Related Notes
- [[Event-Driven Architecture Benefits]]
- [[Service Communication Patterns]]
- [[Microservices Testing Strategies]]
```

---

### Literatur-Notizen

**Workflow**: Strukturierte Erfassung von Buch-/Artikel-Wissen

1. **Während des Lesens**
   - Template: `knowledge_literature_default.md`
   - Autor und Quelle dokumentieren
   - Wichtige Zitate erfassen
   - Eigene Gedanken markieren

2. **Nach dem Lesen**
   - Key Insights in Atomic Notes extrahieren
   - Konzepte mit bestehendem Wissen verknüpfen
   - Literatur-Note als Referenz behalten

---

## Kontakt- und Beziehungsmanagement

### Kunden-Profil anlegen

**Workflow**: Strukturiertes Customer Relationship Management

1. **Profil erstellen**
   - Template: `people_customer_default.md`
   - Vollständige Kontaktdaten
   - Firma und Rolle
   - Start-Datum der Beziehung

2. **Projekt-Verknüpfung**
   - Im Profil: Projekte auflisten
   - In Projekt-Notes: Kunden verlinken

3. **Meeting-Historie**
   - Dataview zeigt automatisch alle Meetings mit diesem Kunden
   - In Meeting Notes: Kunde in Attendees aufnehmen

**Beispiel Kunden-Profil**:
```markdown
## Profile Summary
- **Full Name**: Anna Müller
- **Role**: CTO
- **Location**: Berlin
- **Company**: TechCorp GmbH
- **Start Date**: 20240101

## Projects
- [ ] Website Relaunch
- [ ] Mobile App Development
- [x] Initial Consulting

## Meeting Log
[Automatisch generiert via Dataview]
- 2024-03-15: Kick-off Meeting
- 2024-03-22: Requirements Workshop
- 2024-04-05: Sprint Review
```

---

### Kollegen-Profil pflegen

**Workflow**: Interne Kontaktverwaltung

1. **Profil anlegen**
   - Template: `people_colleague_default.md`
   - Team und Rolle
   - Expertise-Bereiche

2. **Zusammenarbeit dokumentieren**
   - Gemeinsame Projekte
   - Meeting-Historie
   - Notizen zu Skills und Präferenzen

---

## Best Practices

### Naming Conventions

**Dateinamen**:
- **Projekte**: `ProjectName_Type` (z.B. `WebsiteRelaunch_Task`)
- **Dates**: `YYYYMMDD` Format (z.B. `20240315_Meeting`)
- **People**: `FirstName LastName` (z.B. `Anna_Mueller`)
- **Keine Leerzeichen**: Unterstriche verwenden

**Tags**:
- **Hierarchie**: `#category/subcategory` (z.B. `#project/website`)
- **Konsistenz**: Immer gleiche Tag-Namen
- **Sparsam**: Nur relevante Tags

### Metadaten pflegen

**YAML Frontmatter Best Practices**:

```yaml
---
title: "Aussagekräftiger Titel"
created: "YYYYMMDD - HHmm"
tags: ["tag1", "tag2"]  # Array-Format für Dataview
category: "category_name"
status: "active"  # Konsistente Status-Werte
---
```

**Wichtige Felder**:
- `title`: Immer setzen
- `created`: Automatisch via Templater
- `tags`: Für Filterung und Suche
- `category`: Für Gruppierung
- `status`: Für Workflow-Tracking

### Verlinkung und Vernetzung

**Linking-Strategien**:

1. **Bidirektionale Links**: `[[Note Name]]`
   - Obsidian erstellt automatisch Backlinks
   - In Graph View sichtbar

2. **Aliases verwenden**:
   ```markdown
   [[Very Long Note Title|Short Name]]
   ```

3. **Section Links**:
   ```markdown
   [[Note Name#Section Heading]]
   ```

4. **Related Notes Sektion**:
   ```markdown
   ## Related Notes
   - [[Note 1]]
   - [[Note 2]]
   - [[Note 3]]
   ```

### Dataview Query Best Practices

**Performance**:
- Spezifische Queries: `FROM #tag` statt `FROM ""`
- Limits setzen: `LIMIT 10` für große Datenmengen
- Felder einschränken: Nur benötigte Felder in TABLE

**Beispiel gut strukturierte Query**:
```dataview
TABLE 
  status as "Status",
  priority as "Prio",
  created as "Erstellt"
FROM #task
WHERE contains(project, "Website") 
  AND status != "done"
SORT priority desc, created asc
LIMIT 20
```

---

## Plugin-Konfiguration

### Templater Setup

**Template Folder**: `99_obsidian/01_templates`

**Empfohlene Settings**:
```
Template folder location: 99_obsidian/01_templates
Trigger Templater on new file creation: ON
Automatic jump to cursor: ON
Enable System Commands: ON
```

**Keyboard Shortcuts**:
- Insert Template: `Alt + T` (anpassen nach Präferenz)
- Create new note from template: `Ctrl + Shift + T`

### Dataview Setup

**Empfohlene Settings**:
```
Enable JavaScript Queries: ON
Enable Inline Queries: ON
Enable Inline JavaScript Queries: ON
Date Format: YYYY-MM-DD
```

### Periodic Notes Setup

**Daily Notes**:
```
Format: YYYY-MM-DD
Template: 02_areas/01_periodicNotes/daily_default.md
Folder: 02_areas/03_daily/
```

**Weekly Notes**:
```
Format: YYYY-[W]WW
Template: 02_areas/01_periodicNotes/weekly_default.md
Folder: 02_areas/03_weekly/
```

---

## Häufige Anwendungsfälle

### Use Case 1: Softwareentwicklung-Projekt

**Szenario**: Neues Feature entwickeln

1. **Setup**:
   - Projekt-Ordner: `01_projects/feature-user-auth/`
   - Overview: Feature-Beschreibung
   - Kanban Board: Task-Tracking

2. **Tägliche Arbeit**:
   - Daily Note: Fortschritt dokumentieren
   - Task Notes: User Stories und Bugs
   - Meeting Notes: Sprint Planning, Reviews

3. **Wissenserfassung**:
   - Atomic Notes: Technische Learnings
   - Literature Notes: Artikel über Auth-Patterns

### Use Case 2: Consulting-Projekt

**Szenario**: Kunde beraten und Workshops durchführen

1. **Setup**:
   - Kunden-Profil anlegen
   - Projekt-Ordner: `01_projects/kunde-consulting/`
   - Meeting Notes Template vorbereiten

2. **Während des Projekts**:
   - Jedes Meeting dokumentieren
   - Action Items in Tasks überführen
   - Weekly Reviews mit Kunde

3. **Nachverfolgung**:
   - Alle Meetings im Kunden-Profil sichtbar
   - Task-Status im Overview
   - Erkenntnisse in Knowledge Base

### Use Case 3: Persönliche Weiterbildung

**Szenario**: Neues Thema lernen (z.B. Machine Learning)

1. **Start**:
   - Overview: "Machine Learning Journey"
   - Area: Personal Development

2. **Lernen**:
   - Literature Notes: Bücher und Kurse
   - Atomic Notes: Einzelne Konzepte
   - Permanent Notes: Konsolidiertes Wissen

3. **Anwendung**:
   - Projekt: Eigene ML-Projekte
   - Tasks: Übungen und Experimente
   - Notes: Erkenntnisse und Ergebnisse

### Use Case 4: Team-Management

**Szenario**: Team von 5 Personen führen

1. **Setup**:
   - Kollegen-Profile für alle Team-Mitglieder
   - Overview: "Team XY"
   - Kanban: Team-weite Tasks

2. **Weekly Routinen**:
   - 1-on-1 Meetings dokumentieren
   - Team-Meeting Notes
   - Performance-Tracking

3. **Projekt-Zuordnung**:
   - In Kollegen-Profilen: Aktuelle Projekte
   - In Projekt-Notes: Team-Members verlinken

---

## Erweiterte Workflows

### Weekly Review Workflow

**Jeden Freitag / Sonntag**:

1. **Weekly Note erstellen**
   - Template: `weekly_default.md`
   - KW und Datum

2. **Review durchführen**:
   ```markdown
   ## Week in Review
   ### Achievements
   - Was wurde erreicht?
   - Welche Meilensteine?
   
   ### Challenges
   - Was lief nicht wie geplant?
   - Welche Blocker?
   
   ### Learnings
   - Was wurde gelernt?
   - Was würde ich anders machen?
   
   ### Next Week Goals
   1. [ ] Ziel 1
   2. [ ] Ziel 2
   3. [ ] Ziel 3
   ```

3. **Task Cleanup**:
   - Abgeschlossene Tasks archivieren
   - Offene Tasks neu priorisieren
   - Nächste Woche planen

### Monthly Review Workflow

**Am Ende des Monats**:

1. **Alle Weekly Notes reviewen**
2. **Große Patterns identifizieren**
3. **Quarterly Goals anpassen**
4. **Knowledge Base aufräumen**:
   - Inbox verarbeiten
   - Atomic Notes konsolidieren
   - Orphan Notes reviewen

---

## Wartung und Pflege

### Regelmäßige Aufgaben

**Täglich**:
- Daily Note erstellen
- Tasks aktualisieren

**Wöchentlich**:
- Weekly Review
- Inbox verarbeiten
- Meeting Notes durchsehen

**Monatlich**:
- Template-Struktur reviewen
- Nicht verwendete Tags bereinigen
- Graph View analysieren (Orphan Notes)

**Quartalsweise**:
- Archivierung alter Projekte
- Overview Pages aktualisieren
- System-Optimierung

---

## Troubleshooting

### Häufige Probleme

**Problem**: Template bewegt sich nicht automatisch
- **Lösung**: Templater Plugin aktiviert? Pfad korrekt?

**Problem**: Dataview Query zeigt keine Ergebnisse
- **Lösung**: Tags korrekt? YAML-Syntax richtig?

**Problem**: Backlinks funktionieren nicht
- **Lösung**: Doppelte eckige Klammern `[[]]` verwenden

**Problem**: Performance-Issues
- **Lösung**: Dataview Queries mit LIMIT versehen

---

## Nächste Schritte

Nach dem Durcharbeiten dieses Overviews:

1. ✅ Plugins installieren und konfigurieren
2. ✅ Erste Daily Note erstellen
3. ✅ Ein Test-Projekt anlegen
4. ✅ Erste Inbox Note für eine Idee
5. ✅ Einen Kontakt (Kollege/Kunde) anlegen

**Weiterführende Ressourcen**:
- [README.md](README.md) - Vault-Übersicht
- [INDEX.md](99_obsidian/02_config/INDEX.md) - Alle Templates im Detail
- Obsidian Help: https://help.obsidian.md
- Dataview Documentation: https://blacksmithgu.github.io/obsidian-dataview/

---

**Happy Note-Taking! 📝**

Letzte Aktualisierung: 2025-11-10
Version: 1.0
