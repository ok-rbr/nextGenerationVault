# Template-Index - OK Vault Experimental

Vollständige Übersicht aller verfügbaren Templates mit detaillierten Beschreibungen, Verwendungszwecken und Eigenschaften.

## 📑 Inhaltsverzeichnis

- [Knowledge Templates](#knowledge-templates-4-templates)
- [Project Templates](#project-templates-5-templates)
- [Area Templates](#area-templates-10-templates)
- [Resource Templates](#resource-templates-3-templates)
- [Certification Templates](#certification-templates-4-templates)
- [Template-Nutzung](#template-nutzung)

---

## Knowledge Templates (4 Templates)

Templates für das systematische Wissensmanagement nach Zettelkasten-Prinzipien.

### 1. Knowledge Inbox Default
**Pfad**: `00_knowledge/knowledge_inbox_default.md`

**Zweck**: Erfassung von ungefilterten Ideen und Informationen zur späteren Verarbeitung.

**Merkmale**:
- Automatische Verschiebung nach `/00_knowledge/00_inbox/`
- Prioritäts-Tracking (low, medium, high)
- Quellen-Verwaltung
- Status: "unprocessed"
- Next Steps Checkliste

**Metadaten**:
```yaml
tags: ["inbox"]
category: "knowledge"
status: "unprocessed"
priority: [low/medium/high]
source: [optional]
```

**Verwendung**: Schnelle Erfassung von Ideen, die später kategorisiert werden sollen.

---

### 2. Knowledge Permanent Default
**Pfad**: `00_knowledge/knowledge_permanent_default.md`

**Zweck**: Verifiziertes, permanentes Wissen mit Vernetzung zu anderen Notizen.

**Merkmale**:
- Automatische Verschiebung nach `/00_knowledge/03_permanent/`
- Key Concepts Tracking
- Related Notes Verlinkung
- Automatische Backlink-Generierung
- Status: "completed"

**Metadaten**:
```yaml
tags: ["permanent"]
category: "knowledge"
status: "completed"
related: [Liste von Notizen]
concepts: [Liste von Konzepten]
```

**Verwendung**: Für etabliertes, gut vernetztes Wissen, das dauerhaft relevant ist.

---

### 3. Knowledge Atomic Default
**Pfad**: `00_knowledge/knowledge_atomic_default.md`

**Zweck**: Kleine, fokussierte Wissens-Einheiten (Atomic Notes).

**Merkmale**:
- Automatische Verschiebung nach `/00_knowledge/02_atomic/`
- Eine Idee pro Notiz
- Konzept-Tagging
- Verknüpfung mit verwandten Notizen

**Metadaten**:
```yaml
tags: ["atomic"]
category: "knowledge"
concepts: [Konzept-Liste]
related: [Verwandte Notizen]
```

**Verwendung**: Für einzelne, klar abgegrenzte Ideen oder Konzepte.

---

### 4. Knowledge Literature Default
**Pfad**: `00_knowledge/knowledge_literature_default.md`

**Zweck**: Notizen aus Büchern, Artikeln und anderen Quellen.

**Merkmale**:
- Automatische Verschiebung nach `/00_knowledge/04_literature/`
- Autoren- und Quellen-Tracking
- Zitate-Verwaltung
- ISBN/URL-Referenzen

**Metadaten**:
```yaml
tags: ["literature"]
category: "knowledge"
source: [Quelle]
author: [Autor]
```

**Verwendung**: Für Literatur-basiertes Wissen mit klaren Quellenangaben.

---

## Project Templates (5 Templates)

Templates für projektspezifische Notizen und Aufgaben.

### 5. Project Daily Note
**Pfad**: `01_projects/project_name/kunde-project-daily.md`

**Zweck**: Tägliche Projekt-Updates und Fortschritts-Tracking.

**Merkmale**:
- Automatische Verschiebung nach `01_projects/{project_name}/daily/`
- Projekt-Tagging
- Daily Log
- Task-Tracking für den Tag

**Metadaten**:
```yaml
tags: ["daily", "{project_name}"]
category: "daily"
project: "{project_name}"
```

**Verwendung**: Tägliche Dokumentation von Projektfortschritten und Aktivitäten.

---

### 6. Project Weekly Note
**Pfad**: `01_projects/project_name/kunde-project-weekly.md`

**Zweck**: Wöchentliche Projekt-Reviews und Planung.

**Merkmale**:
- Automatische Verschiebung nach `01_projects/{project_name}/weekly/`
- Wochenrückblick
- Ziele für kommende Woche
- Achievement-Tracking

**Metadaten**:
```yaml
tags: ["weekly", "{project_name}"]
category: "weekly"
project: "{project_name}"
```

**Verwendung**: Wöchentliche Reflexion und Planung für Projekte.

---

### 7. Project Meeting Note
**Pfad**: `01_projects/project_name/kunde-project-meeting.md`

**Zweck**: Projekt-spezifische Meeting-Dokumentation.

**Merkmale**:
- Automatische Verschiebung nach `01_projects/{project_name}/meetings/`
- Agenda-Tracking
- Attendees-Liste
- Action Items
- Meeting-Datum im Dateinamen

**Metadaten**:
```yaml
tags: ["meeting", "{project_name}"]
category: "meeting"
thema: ""
attendees: []
date: "YYYYMM-D"
```

**Verwendung**: Strukturierte Meeting-Notizen innerhalb eines Projekts.

---

### 8. Project Task Note
**Pfad**: `01_projects/project_name/kunde-project-task.md`

**Zweck**: Einzelne Aufgaben innerhalb eines Projekts verwalten.

**Merkmale**:
- Automatische Verschiebung nach `01_projects/{project_name}/task/`
- Task ID Tracking
- Priority-Management
- Related Notes/Tasks
- Status-Tracking
- Progression Log

**Metadaten**:
```yaml
tags: ["task", "{project_name}"]
category: "task"
project: "{project_name}"
status: "active"
task_id: [ID]
priority: [low/medium/high]
```

**Verwendung**: Für einzelne, nachverfolgbare Aufgaben in Projekten.

---

### 9. Project Generic Note
**Pfad**: `01_projects/project_name/kunde-project-note.md`

**Zweck**: Allgemeine Projekt-Notizen ohne spezifische Struktur.

**Merkmale**:
- Automatische Verschiebung nach `01_projects/{project_name}/notes/`
- Flexible Struktur
- Projekt-Tagging

**Metadaten**:
```yaml
tags: ["note", "{project_name}"]
category: "note"
project: "{project_name}"
```

**Verwendung**: Für freie Notizen innerhalb eines Projekts.

---

## Area Templates (10 Templates)

Templates für verschiedene Lebensbereiche und wiederkehrende Aktivitäten.

### 10. Daily Default (Periodic Note)
**Pfad**: `02_areas/01_periodicNotes/daily_default.md`

**Zweck**: Tägliche Übersicht über Meetings, Tasks und Aktivitäten.

**Merkmale**:
- Dataview-Queries für tägliche Meetings
- Task-Listen (fällig heute)
- Scheduled Tasks
- Active/Pending Tasks Übersicht
- Tägliches Log

**Metadaten**:
```yaml
tags: ["daily"]
category: "daily"
created: "YYYYMMDD"
```

**Verwendung**: Zentrale tägliche Dashboard-Notiz für alle Aktivitäten.

---

### 11. Weekly Default (Periodic Note)
**Pfad**: `02_areas/01_periodicNotes/weekly_default.md`

**Zweck**: Wöchentliche Planung und Review.

**Merkmale**:
- Wochenziele
- Rückblick auf vergangene Woche
- Task-Übersicht für die Woche

**Metadaten**:
```yaml
tags: ["weekly"]
category: "weekly"
created: "YYYYMMDD"
```

**Verwendung**: Wöchentliche Reflexion und Planung über alle Bereiche.

---

### 12. Tasks Notes Default
**Pfad**: `02_areas/01_periodicNotes/tasks_notes_default.md`

**Zweck**: Task-spezifische periodische Notizen.

**Merkmale**:
- Task-Listen
- Status-Tracking
- Priorisierung

**Verwendung**: Für Task-fokussierte periodische Reviews.

---

### 13. Meeting Default
**Pfad**: `02_areas/meetings_default.md`

**Zweck**: Allgemeine Meeting-Notizen (nicht projekt-spezifisch).

**Merkmale**:
- Automatische Verschiebung nach `02_areas/04_meetings/`
- Datum im Dateinamen
- Agenda-Sektion
- Meeting-Log
- Action Items

**Metadaten**:
```yaml
tags: ["meeting"]
category: "meeting"
thema: ""
summary: ""
attendees: []
date: "YYYYMM-D"
```

**Verwendung**: Für bereichsübergreifende oder allgemeine Meetings.

---

### 14. Note Default
**Pfad**: `02_areas/01_notes/note_default.md`

**Zweck**: Standard-Notizen für Areas.

**Merkmale**:
- Flexible Struktur
- Area-Zuordnung

**Verwendung**: Allgemeine Notizen für einen Lebens-/Arbeitsbereich.

---

### 15. Overview Default
**Pfad**: `02_areas/05_overview/overview_default.md`

**Zweck**: Bereichs-Übersichten mit Dashboard-Funktionalität.

**Merkmale**:
- Automatische Verschiebung nach `/02_areas/05_overview/`
- Dataview-Integration für Tasks, Notes, Meetings
- Active Tasks Dashboard
- Recent Notes Liste
- Meeting History
- Key Metrics
- Goals & Objectives Sektion

**Metadaten**:
```yaml
tags: ["overview", "areas"]
category: "overview"
area: [Area Name]
description: [Beschreibung]
```

**Verwendung**: Als zentrale Dashboard-Seite für einen Bereich (z.B. "Arbeit", "Gesundheit").

---

### 16. Kanban Default
**Pfad**: `02_areas/00_kanban/kanban_default.md`

**Zweck**: Kanban-Board für visuelles Task-Management.

**Merkmale**:
- Automatische Verschiebung nach `/02_areas/00_kanban/`
- Dataview-basierte Kanban-Spalten:
  - Backlog
  - To Do
  - In Progress
  - Done
- Area-Filter

**Metadaten**:
```yaml
tags: ["kanban", "board"]
category: "kanban"
area: [Area/Project]
status: "active"
```

**Verwendung**: Visualisierung von Aufgaben in verschiedenen Stadien.

---

### 17. People Default
**Pfad**: `02_areas/07_people/people_default.md`

**Zweck**: Allgemeine Personenprofile.

**Merkmale**:
- Kontaktinformationen
- Beziehungs-Tracking
- Meeting-Historie

**Verwendung**: Für wichtige Kontakte ohne spezifische Kategorie.

---

### 18. People Contact Default
**Pfad**: `02_areas/08_people/people_contact_default.md`

**Zweck**: Detaillierte Kontaktprofile.

**Merkmale**:
- Erweiterte Kontaktinformationen
- Kommunikations-Historie
- Notes zu Gesprächen

**Verwendung**: Für detaillierte Kontaktverwaltung.

---

### 19. Mentoring MBA
**Pfad**: `02_areas/00_mentoring/mentoring-mba.md`

**Zweck**: Mentoring-Session-Notizen (speziell für MBA).

**Merkmale**:
- Automatische Verschiebung nach `/02_areas/06_mentoring/`
- Mentor-Tracking (Marvin Baschnagel)
- Agenda
- Open Topics mit Dataview-Query
- Next Actions

**Metadaten**:
```yaml
tags: ["mentoring", "meeting"]
category: "mentoring"
mentor: "Marvin Baschnagel"
mentorig_date: [Datum]
```

**Verwendung**: Dokumentation von Mentoring-Sessions.

---

### 20. Mentoring Task
**Pfad**: `02_areas/00_mentoring/mentoring-task.md`

**Zweck**: Aufgaben aus Mentoring-Sessions.

**Merkmale**:
- Task-Tracking aus Mentoring
- Zuordnung zu Mentoring-Sessions

**Verwendung**: Follow-up für Mentoring-bezogene Aufgaben.

---

## Resource Templates (3 Templates)

Templates für Ressourcen und externe Kontakte.

### 21. People Customer Default
**Pfad**: `03_resources/02_people/people_customer_default.md`

**Zweck**: Kundenprofile mit ausführlichen Informationen.

**Merkmale**:
- Automatische Verschiebung nach `/02_areas/07_people/01_customer/`
- Vollständiges Profil (Name, Role, Company)
- Kontaktinformationen (Email, Phone, Location)
- Start Date Tracking
- Projekt-Zuordnung
- Meeting-Log mit Dataview

**Metadaten**:
```yaml
tags: ["person", "colleague"]
category: "people"
role: [Role]
company: [Company]
email: [Email]
phone: [Phone]
location: [Location]
start_date: "YYYYMMDD"
```

**Verwendung**: Für Kundenbeziehungs-Management.

---

### 22. People Colleague Default
**Pfad**: `03_resources/02_people/people_colleague_default.md`

**Zweck**: Kollegenprofile für interne Kontakte.

**Merkmale**:
- Vollständiges Profil
- Projekt-Zuordnung
- Meeting-Historie
- Ähnliche Struktur wie Customer Template

**Metadaten**:
```yaml
tags: ["person", "colleague"]
category: "people"
role: [Role]
company: [Company]
```

**Verwendung**: Für Kollegen- und Team-Management.

---

## Certification Templates (4 Templates)

Neu hinzugefügte Templates für systematisches Lernen von Zertifizierungen mit Fokus auf Microsoft-Zertifikate.

### 23. Certification Overview
**Pfad**: `03_resources/01_certifications/cert_overview.md`

**Zweck**: Hauptübersicht für eine Zertifizierung mit vollständigem Tracking.

**Merkmale**:
- Automatische Verschiebung nach `/03_resources/01_certifications/{provider}/`
- Exam Information Tracking
- Study Plan mit Dataview-Integration
- Progress Tracking (0-100%)
- Practice Exam Results
- Knowledge Extraction Links
- Pre/Post-Exam Reflection

**Metadaten**:
```yaml
tags: ["certification", "{provider}", "{level}"]
category: "resource"
cert_id: [Certification ID]
provider: [Microsoft/AWS/Google/etc]
level: [fundamentals/associate/expert/specialty]
status: [planning/in-progress/ready/passed/failed/expired]
priority: [critical/high/medium/low]
target_date: "YYYY-MM-DD"
exam_date: ""
expiry_date: ""
score: ""
progress: 0
```

**Verwendung**: Als zentrale Seite für jede Zertifizierung die Sie anstreben.

---

### 24. Certification Study Note
**Pfad**: `03_resources/01_certifications/cert_study_note.md`

**Zweck**: Detaillierte Studiennotizen für einzelne Themen/Module einer Zertifizierung.

**Merkmale**:
- Automatische Verschiebung nach `/03_resources/01_certifications/{provider}/`
- Learning Objectives und Key Concepts
- Technical Details und Best Practices
- Hands-on Practice Section
- Exam Relevance (likely exam topics)
- Sample Questions
- Self-Assessment Checklist
- Spaced Repetition Tracking
- Related Study Notes via Dataview

**Metadaten**:
```yaml
tags: ["study-note", "certification", "{cert_id}"]
category: "resource"
cert_id: [Certification ID]
module: [Module/Section number]
priority: [critical/high/medium/low]
status: "in-progress"
related: [Certification ID]
```

**Verwendung**: Für jedes Modul/Thema der Zertifizierung eine separate Studiennotiz erstellen.

---

### 25. Certification Practice Exam
**Pfad**: `03_resources/01_certifications/cert_practice_exam.md`

**Zweck**: Detaillierte Auswertung von Übungsprüfungen.

**Merkmale**:
- Automatische Verschiebung nach `/03_resources/01_certifications/{provider}/`
- Exam Summary (Score, Pass/Fail)
- Performance by Domain Breakdown
- Incorrect Questions Review mit Erklärungen
- Difficult Questions Analysis
- Learning Insights und Action Items
- Practice Exam History via Dataview
- Progress Over Time Tracking

**Metadaten**:
```yaml
tags: ["practice-exam", "certification", "{cert_id}"]
category: "resource"
cert_id: [Certification ID]
exam_date: "YYYY-MM-DD HH:mm"
exam_source: [Source]
score: [Percentage]
status: "completed"
related: [Certification ID]
```

**Verwendung**: Nach jeder Übungsprüfung ausfüllen, um Fortschritt zu tracken und Schwächen zu identifizieren.

---

### 26. Certification Knowledge Extraction
**Pfad**: `03_resources/01_certifications/cert_knowledge_extraction.md`

**Zweck**: Extrahiert abstrahiertes Wissen aus Zertifizierungen in die permanente Knowledge Base.

**Merkmale**:
- Automatische Verschiebung nach `/00_knowledge/{type}/` (atomic/permanent/literature)
- Source Certification Tracking
- Detailed Explanation mit Mental Models
- Practical Applications und Use Cases
- Best Practices und Common Pitfalls
- Code Examples
- Differences & Comparisons
- Related Knowledge Notes via Dataview
- Back-Link zur Zertifizierung

**Metadaten**:
```yaml
tags: ["from-certification", "{cert_id}", "{type}"]
category: "knowledge"
status: "completed"
source_cert: [Certification ID]
related: [Related notes]
concepts: [Key concepts]
```

**Verwendung**: Um zertifizierungsspezifisches Wissen in allgemein anwendbares Wissen zu überführen, das langfristig im Knowledge Base verbleibt.

---

## Template-Nutzung

### Allgemeine Funktionsweise

Alle Templates nutzen das **Templater-Plugin** für:

1. **Dynamische Prompts**: Interaktive Eingabe von Informationen
2. **Automatisches Renaming**: Dateinamen werden basierend auf Eingaben gesetzt
3. **Auto-Move**: Templates verschieben sich automatisch in die richtigen Ordner
4. **Metadaten-Generierung**: YAML-Frontmatter wird automatisch ausgefüllt

### Template-Syntax

Templates verwenden folgende Templater-Syntax:

```javascript
<%*
// JavaScript-Code für Logik
var variable = await tp.system.prompt("Prompt-Text:")
await tp.file.rename(variable)
await tp.file.move("/pfad/zum/ziel/" + variable)
-%>
```

### Dataview-Queries

Viele Templates enthalten Dataview-Queries:

```dataview
TABLE status, priority, created
FROM #task
WHERE contains(status, "active")
SORT priority desc
```

### Best Practices

1. **Templater installieren**: Essentiell für Template-Funktionalität
2. **Dataview installieren**: Für dynamische Listen und Dashboards
3. **Frontmatter konsistent halten**: Wichtig für Queries
4. **Tags verwenden**: Erleichtert Filterung und Suche
5. **Verlinkungen nutzen**: `[[Notiz-Name]]` für Vernetzung

---

## Template-Kategorisierung

### Nach Häufigkeit
- **Täglich**: Daily Notes, Task Notes
- **Wöchentlich**: Weekly Notes, Reviews
- **Bei Bedarf**: Meeting Notes, Project Notes
- **Einmalig**: People Profiles, Overview Pages

### Nach Komplexität
- **Einfach**: Note Default, Task Notes
- **Mittel**: Meeting Notes, Project Templates
- **Komplex**: Overview Pages, Kanban Boards (mit Dataview)

### Nach Datenintegration
- **Standalone**: Inbox Notes, Generic Notes
- **Verlinkt**: Permanent Notes, Task Notes
- **Dashboard**: Overview Pages, Kanban Boards, Daily Notes

---

**Gesamtzahl**: 22 Templates
**Kategorien**: 4 (Knowledge, Projects, Areas, Resources)
**Plugin-Abhängigkeiten**: Templater (erforderlich), Dataview (empfohlen)

**Siehe auch**:
- [README.md](README.md) - Vault-Übersicht
- [OVERVIEW.md](OVERVIEW.md) - Workflows und Best Practices
