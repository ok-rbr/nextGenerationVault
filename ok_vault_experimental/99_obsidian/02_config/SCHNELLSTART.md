---
title: "Schnellstart Guide"
id: "20251110_2157"
created: "2025-11-10 21:57"
tags: ["obsidian/docs"]
category: "index"
status: "completed"
related: []
concepts: []
aliases: []
---

# Schnellstart Guide - OK Vault

Schnelleinstieg für die Nutzung des PARA-basierten Obsidian Vaults.

## 🚀 Erste Schritte

### 1. Plugins installieren

**Erforderlich:**
- ✅ **Templater** - Für dynamische Templates
- ✅ **Dataview** - Für Übersichten und Queries

**Empfohlen:**
- ⭐ **Periodic Notes** - Für Daily/Weekly Notes
- ⭐ **Tasks** - Für Task-Management

### 2. Templater konfigurieren

```
Einstellungen → Templater
- Template folder location: 99_obsidian/01_templates
- Trigger Templater on new file creation: AN
- Enable System Commands: AN
```

### 3. Erste Notiz erstellen

1. Neue Notiz erstellen (`Ctrl/Cmd + N`)
2. Command Palette öffnen (`Ctrl/Cmd + P`)
3. "Templater: Insert Template" auswählen
4. Template wählen und Prompts beantworten

## 📁 Wo speichere ich was?

### 00_knowledge/ - Wissensmanagement

**Inbox** (`00_inbox/`):
- Schnelle Ideen
- Unverarbeitete Informationen
- Template: `knowledge_inbox_default.md`

**Atomic** (`01_atomic/`):
- Kleine, fokussierte Notizen
- Eine Idee pro Notiz
- Template: `knowledge_atomic_default.md`

**Literature** (`02_literature/`):
- Notizen aus Büchern/Artikeln
- Zitate und Quellenangaben
- Template: `knowledge_literature_default.md`

**Permanent** (`03_permanent/`):
- Verifiziertes Wissen
- Stark vernetzt
- Template: `knowledge_permanent_default.md`

### 01_projects/ - Projekte

Zeitlich begrenzte Vorhaben:
- Kundenprojekte
- Eigene Projekte
- Template: `project_template.md`

**Beispiel**: Website-Relaunch für Kunde XY

### 02_areas/ - Verantwortungsbereiche

Langfristige Themen:
- Azure & Cloud
- Identity & Access Management
- Security
- Template: `area_template.md`

**Beispiel**: "Azure Identity Governance"

### 03_resources/ - Ressourcen

Referenzmaterial:
- Playbooks
- Tools
- Dokumentation
- Template: `resource_template.md`

**Beispiel**: "Azure CLI Cheat Sheet"

### 04_archive/ - Archiv

Abgeschlossene Inhalte:
- Alte Projekte
- Veraltete Informationen
- Keine direkten Templates (durch Verschiebung)

## 🎯 Häufige Anwendungsfälle

### Neue Idee erfassen

1. Template: `knowledge_inbox_default.md`
2. Titel, Quelle, Priorität angeben
3. → Landet in `00_knowledge/00_inbox/`
4. Später verarbeiten zu Atomic/Permanent

### Neues Projekt starten

1. Template: `project_template.md`
2. Projektname, Kunde, Beschreibung
3. → Erstellt Projekt-Ordner in `01_projects/`
4. Projekt-Index öffnen mit Dataview-Übersichten

### Kundengespräch dokumentieren

1. Template: `kunde-project-meeting.md`
2. Meeting-Details eintragen
3. → Landet in `01_projects/{projekt}/meetings/`
4. Action Items als Tasks markieren

### Neues Thema lernen

1. Area erstellen: Template `area_template.md`
2. Literature Notes für Quellen
3. Atomic Notes für Konzepte
4. Permanent Note für Zusammenfassung

## 📋 Index-Seiten nutzen

Jeder Top-Ordner hat eine `00_index.md`:

- **00_knowledge/00_index.md**: Übersicht aller Wissensnotizen
- **01_projects/00_index.md**: Aktive Projekte nach Kunde
- **02_areas/00_index.md**: Alle Verantwortungsbereiche
- **03_resources/00_index.md**: Alle Ressourcen
- **04_archive/00_index.md**: Archivierte Inhalte
- **99_obsidian/00_index.md**: Alle Templates

Diese Index-Seiten zeigen automatisch relevante Notizen mit Dataview.

## 🏷️ Tags richtig nutzen

### Format
```
#lowercase/verschachtelt
```

### Beispiele
```
#tool/azure
#tool/entra_id
#topic/identity
#topic/security
#client/acme_gmbh
```

### Regeln
- ✅ Kleinschreibung
- ✅ Kurze Slugs
- ✅ Unterstriche für mehrere Wörter
- ❌ Keine Duplikate zu category/status

## 📝 Frontmatter-Checkliste

**Immer vorhanden**:
- `title`: Titel der Notiz
- `id`: YYYYMMDD_HHMM
- `created`: YYYY-MM-DD HH:mm
- `tags`: Array ["tag1", "tag2"]
- `category`: Eine von: knowledge, project, area, resource, archive, index
- `status`: z.B. in-progress, completed, archived
- `related`: Array [] (zunächst leer)
- `concepts`: Array [] (zunächst leer)
- `aliases`: Array [] (zunächst leer)

**Zusätzlich je nach Typ**:
- **Projects**: `client`, `due`
- **Literature**: `author`, `source`, `type`
- **Inbox**: `priority`, `source`

## 🔍 Dataview-Queries verstehen

### Einfache Query
```dataview
table file.link as Note, status
from "00_knowledge/01_atomic"
sort file.mtime desc
limit 10
```

### Mit Filter
```dataview
table client, status, due
where category = "project" and status != "archived"
sort due asc
```

### Gruppiert
```dataview
table file.link as Project, status
where category = "project"
group by client
```

## 💡 Tipps & Tricks

### Tägliche Routine
1. Morning: Daily Note erstellen
2. Ideen: Direkt in Inbox
3. Evening: Daily Note abschließen

### Wöchentliche Routine
1. Weekly Review erstellen
2. Inbox verarbeiten
3. Projekte updaten
4. Nächste Woche planen

### Monatliche Routine
1. Archive alte Projekte
2. Areas reviewen
3. Knowledge Base aufräumen

## 📚 Weitere Dokumentation

- **KONVENTIONEN.md**: Alle Regeln im Detail
- **README.md**: Vault-Übersicht
- **INDEX.md**: Alle Templates beschrieben
- **OVERVIEW.md**: Workflows und Best Practices

## ⚠️ Wichtig

1. **Keine Felder erfinden** - Nur dokumentierte nutzen
2. **Naming-Konventionen** einhalten
3. **Templates nutzen** - Nicht manuell erstellen
4. **Index-Seiten** nicht manuell bearbeiten (außer Beschreibungen)

---

**Viel Erfolg beim Wissensmanagement! 🚀**

Bei Fragen: Siehe KONVENTIONEN.md für Details
