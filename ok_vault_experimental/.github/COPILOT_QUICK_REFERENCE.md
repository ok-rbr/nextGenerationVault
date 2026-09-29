# GitHub Copilot Quick Reference

Schnellreferenz für die Verwendung von GitHub Copilot mit dem OK Vault Experimental.

## 🚀 Erste Schritte

1. **GitHub Copilot aktivieren** in deinem Editor (VS Code, JetBrains, etc.)
2. **Öffne das Vault** in deinem Editor
3. **Copilot liest automatisch** die Instructions aus `.github/copilot-instructions.md`

## ✅ Was Copilot kann

### Notizen erstellen

**Beispiel-Prompt**:
```
Erstelle eine neue Knowledge Inbox Notiz über Azure Identity Governance
```

**Copilot wird**:
- ✅ Lowercase filename verwenden: `azure_identity_governance.md`
- ✅ Korrektes Frontmatter generieren mit allen Pflichtfeldern
- ✅ Tags in lowercase setzen: `["inbox", "topic/azure", "topic/identity"]`
- ✅ Category auf `knowledge` setzen
- ✅ ID im Format `YYYYMMDD_HHMM` generieren

### Frontmatter korrigieren

**Beispiel-Prompt**:
```
Korrigiere das Frontmatter dieser Notiz nach Vault-Konventionen
```

**Copilot wird**:
- ✅ Fehlende Pflichtfelder ergänzen
- ✅ Datumsformat auf ISO umstellen
- ✅ Tags auf lowercase konvertieren
- ✅ Ungültige Kategorien korrigieren
- ✅ Erfundene Felder entfernen

### Templates anpassen

**Beispiel-Prompt**:
```
Erkläre mir das Template kunde-project-task.md
```

**Copilot wird**:
- ✅ Template-Struktur erklären
- ✅ Verwendungszweck beschreiben
- ✅ Frontmatter-Felder erläutern
- ✅ Auto-move-Logik erklären

### Queries erstellen

**Beispiel-Prompt**:
```
Erstelle eine Dataview-Query die alle aktiven Tasks aus Projekten anzeigt
```

**Copilot wird**:
- ✅ Korrekte Dataview-Syntax verwenden
- ✅ Nach Vault-Konventionen filtern
- ✅ Limits setzen für Performance
- ✅ Sortierung vorschlagen

## 🔒 Was Copilot NICHT kann

### Blockierte Bereiche

Copilot kann **nicht** auf folgende Pfade zugreifen:

```
❌ 99_obsidian/04_logs/        # Logs
❌ 04_archive/                 # Archive
❌ 02_areas/07_people/         # Kontakte
❌ 02_areas/08_people/         # Kontaktdetails
❌ 03_resources/02_people/     # Kunden/Kollegen
❌ **/*daily*.md               # Daily Notes
❌ **/*weekly*.md              # Weekly Reviews
❌ **/*meeting*.md             # Meeting Notes
❌ .obsidian/                  # Obsidian Config
❌ .trash/                     # Papierkorb
```

**Beispiel - Was passiert**:
```
Prompt: "Zeige mir den Inhalt meiner Daily Note von gestern"
Antwort: "Ich kann nicht auf Daily Notes zugreifen, da diese persönliche 
          Informationen enthalten und blockiert sind."
```

## 📋 Naming Cheat Sheet

### Dateinamen

✅ **RICHTIG**:
- `azure_identity_governance.md`
- `kunde_projekt_meeting.md`
- `study_note_az104.md`
- `test_environment_setup.md`

❌ **FALSCH**:
- `Azure Identity Governance.md` (Leerzeichen, Großbuchstaben)
- `Kunde-Projekt-Meeting.md` (Bindestriche, Großbuchstaben)
- `studyNote_AZ104.md` (camelCase)
- `test&environment.md` (Sonderzeichen)

### Tags

✅ **RICHTIG**:
- `#tool/azure`
- `#topic/identity`
- `#client/acme_gmbh`
- `#project`

❌ **FALSCH**:
- `#Tool/Azure` (Großbuchstaben)
- `#TOPIC/IDENTITY` (Nur Großbuchstaben)
- `#client/ACME GmbH` (Leerzeichen)

## 🏗️ Frontmatter Templates

### Minimal (für alle Notizen)

```yaml
---
title: "dateiname_ohne_extension"
id: "20260219_0915"
created: "2026-02-19 09:15"
tags: ["tag1", "tag2"]
category: "knowledge|project|area|resource|archive|index"
status: "in-progress|completed|archived"
related: []
concepts: []
aliases: []
---
```

### Project Note

```yaml
---
title: "projekt_name"
id: "20260219_0915"
created: "2026-02-19 09:15"
tags: ["project", "client/kunde", "topic/thema"]
category: "project"
status: "in-progress"
client: "Kundenname"
due: "2026-12-31"
related: []
concepts: []
aliases: []
---
```

### Knowledge Inbox

```yaml
---
title: "idee_name"
id: "20260219_0915"
created: "2026-02-19 09:15"
tags: ["inbox", "topic/thema"]
category: "knowledge"
status: "unprocessed"
priority: "medium"
source: "https://example.com"
related: []
concepts: []
aliases: []
---
```

## 🎯 Häufige Copilot-Prompts

### Notiz erstellen

```
Erstelle eine Projekt-Notiz für das Azure Migration Projekt
Erstelle eine Inbox-Notiz über Kubernetes Security
Erstelle eine Literature-Notiz für das Buch "Clean Code"
```

### Struktur validieren

```
Prüfe ob diese Notiz den Vault-Konventionen entspricht
Validiere das Frontmatter dieser Datei
Sind die Tags richtig formatiert?
```

### Queries erstellen

```
Erstelle eine Dataview-Query für alle offenen Tasks
Zeige mir alle Projekt-Notizen vom letzten Monat
Liste alle Knowledge-Notizen zum Thema Azure
```

### Templates verstehen

```
Erkläre mir das Template system
Welches Template soll ich für ein neues Projekt verwenden?
Was ist der Unterschied zwischen atomic und permanent notes?
```

## ⚙️ Best Practices

### 1. Klare Prompts

✅ **GUT**: "Erstelle eine Knowledge Atomic Notiz über Azure AD B2C mit Tags für tool/azure und topic/identity"

❌ **SCHLECHT**: "Mach mir mal eine Notiz über Azure"

### 2. Konventionen erwähnen

✅ **GUT**: "Erstelle eine Notiz nach Vault-Konventionen"

❌ **SCHLECHT**: "Erstelle eine Notiz" (Copilot könnte eigene Standards verwenden)

### 3. Kategorie angeben

✅ **GUT**: "Erstelle eine Project-Category Notiz für..."

❌ **SCHLECHT**: "Erstelle eine Notiz" (unklar welche Kategorie)

### 4. Templates referenzieren

✅ **GUT**: "Basierend auf dem projekt_task Template..."

❌ **SCHLECHT**: "Erstelle ein Task-Dokument" (unspezifisch)

## 📚 Ressourcen

- **Vollständige Instructions**: `.github/copilot-instructions.md`
- **Validation Report**: `.github/COPILOT_VALIDATION.md`
- **Vault Konventionen**: `KONVENTIONEN.md`
- **README**: `README.md`

## 🆘 Troubleshooting

### Problem: Copilot erstellt falsche Dateinamen

**Lösung**: Explizit im Prompt erwähnen:
```
Erstelle eine Notiz mit lowercase filename und underscores
```

### Problem: Frontmatter fehlen Felder

**Lösung**: Nach Korrektur fragen:
```
Ergänze alle Pflichtfelder im Frontmatter nach Vault-Konventionen
```

### Problem: Tags sind uppercase

**Lösung**: Korrektur anfordern:
```
Konvertiere alle Tags auf lowercase
```

### Problem: Copilot versucht blockierte Pfade zu lesen

**Lösung**: Dies sollte nicht passieren. Falls doch:
```
Hinweis: Daily/Weekly/Meeting Notes sind blockiert und enthalten 
         persönliche Daten. Bitte respektiere die Pfad-Sperrung.
```

## 📝 Beispiel-Session

```
User: Erstelle eine neue Projekt-Notiz für das Website Relaunch Projekt für ACME GmbH

Copilot: Ich erstelle eine Projekt-Notiz nach Vault-Konventionen:

Dateiname: website_relaunch.md

---
title: "website_relaunch"
id: "20260219_0915"
created: "2026-02-19 09:15"
tags: ["project", "client/acme_gmbh", "topic/web"]
category: "project"
status: "in-progress"
client: "ACME GmbH"
due: "2026-12-31"
related: []
concepts: []
aliases: []
---

# [[website_relaunch]]

## Project Description
[Beschreibung einfügen]

## Goals
- [Ziel 1]
- [Ziel 2]

## Tasks
- [ ] [Task 1]
- [ ] [Task 2]

User: Perfekt! Füge noch ein Task für "Design Mockups" hinzu

Copilot: Ergänze in der Tasks-Sektion:
- [ ] Design Mockups erstellen
```

---

**Version**: 1.0  
**Stand**: 2026-02-19  
**Für**: OK Vault Experimental
