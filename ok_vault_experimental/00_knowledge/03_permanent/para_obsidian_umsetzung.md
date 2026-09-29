---
title: "para_obsidian_umsetzung"
id: "20260227_1709"
created: "2026-02-27 17:09"
lang: "de"
tags: ["permanent"]
category: "knowledge"
status: "completed"
related: ["[[para_als_wissenssystem]]", "[[zettelkasten_para_flow]]", "[[para_methode]]", "[[para_projekte]]", "[[para_bereiche]]", "[[para_ressourcen]]", "[[para_archiv]]"]
concepts: ["para", "obsidian", "vault-struktur", "umsetzung", "dataview", "zettelkasten"]
aliases: ["PARA in Obsidian", "Vault-Struktur", "ok_vault_experimental"]
---

# [[para_obsidian_umsetzung]]

## Summary

Dieser Vault implementiert PARA + Zettelkasten in Obsidian. Jede Top-Level-Kategorie entspricht exakt einer PARA-Säule. Das Wissen fließt von der Inbox durch die Wissensstufen bis zum permanenten, vernetzten Wissen.

## Key Concepts

### Vollständige Vault-Struktur

```
ok_vault_experimental/
│
├── 00_knowledge/          ← Zettelkasten-Schicht (über PARA)
│   ├── 00_inbox/          Capture: rohe Ideen & Fundstücke
│   │   └── para_einstieg  ← Beispiel: [[para_einstieg]]
│   ├── 01_atomic/         Distill: eine Idee pro Note
│   │   ├── para_methode   ← [[para_methode]]
│   │   ├── para_projekte  ← [[para_projekte]]
│   │   ├── para_bereiche  ← [[para_bereiche]]
│   │   ├── para_ressourcen← [[para_ressourcen]]
│   │   ├── para_archiv    ← [[para_archiv]]
│   │   └── zettelkasten_para_flow ← [[zettelkasten_para_flow]]
│   ├── 02_literature/     Quellen: Bücher, Artikel, Videos
│   │   └── building_a_second_brain ← [[building_a_second_brain]]
│   └── 03_permanent/      Express: verifiziertes Wissen
│       ├── para_als_wissenssystem  ← [[para_als_wissenssystem]]
│       └── para_obsidian_umsetzung ← diese Notiz
│
├── 01_projects/           ← PARA: Projects (zeitlich, zielorientiert)
│   ├── strohhut-wano_azure_migration/
│   ├── farron-pipeline-geluebde/
│   ├── gallifrey-automatisierungs-protokoll/
│   └── minas-tirith-pipeline-wacht/
│
├── 02_areas/              ← PARA: Areas (laufende Verantwortung)
│   ├── 01_periodicNotes/  → Wöchentliche & tägliche Reflexion
│   ├── 05_overview/       → Überblick & Dashboards
│   └── 08_people/         → Beziehungspflege
│
├── 03_resources/          ← PARA: Resources (Referenzmaterial)
│   ├── 01_certifications/ → Zertifizierungsunterlagen
│   ├── 03_kunden/         → Fraktions-/Kundenprofile
│   └── 04_personen/       → Personenprofile
│
├── 04_archive/            ← PARA: Archive (inaktiv)
│
└── 99_obsidian/           ← System (Templates, Config, Logs)
    └── 01_templates/
```

### Wie PARA-Entscheidungen getroffen werden

```
Neue Information → Frage stellen:

Gibt es ein aktives Projekt dafür?
  → JA:  01_projects/{projekt}/
  → NEIN: Ist es eine laufende Verantwortung?
            → JA:  02_areas/{bereich}/
            → NEIN: Ist es Referenz für die Zukunft?
                      → JA:  03_resources/
                      → NEIN: Muss es erhalten bleiben?
                                → JA:  04_archive/
                                → NEIN: Löschen
```

### Template-System

Jede PARA-Kategorie hat eigene Templates in `99_obsidian/01_templates/`:

| Kategorie | Templates |
|---|---|
| Projects | `01_projects/project_name/` → note, task, meeting, daily, weekly |
| Areas | `02_areas/` → daily, weekly, meetings, kanban, overview |
| Resources | `03_resources/` → people_customer, people_colleague, cert_* |
| Knowledge | `00_knowledge/` → inbox, atomic, literature, permanent |

### Dataview als PARA-Brücke

Dataview-Queries verbinden PARA-Kategorien miteinander:

```dataview
TABLE file.link as Projekt, status
FROM "01_projects"
WHERE category = "index"
SORT file.name ASC
```

## Related Notes

- [[para_als_wissenssystem]] – Theoretische Fundierung
- [[zettelkasten_para_flow]] – Wissensfluss Inbox → Permanent
- [[para_methode]] · [[para_projekte]] · [[para_bereiche]] · [[para_ressourcen]] · [[para_archiv]]
- [[building_a_second_brain]] – Ursprungsquelle
