---
title: dms_migration_gondor
created: 2026-02-27
tags:
  - task
  - minas-tirith-pipeline-wacht
  - lotr
  - middle-earth
  - free-peoples
  - gondor
  - tool/azure
  - topic/migration
category: task
project: Minas Tirith – Pipeline-Wacht
status: closed
task_id: T-002
priority: medium
related:
  - "[[pipeline_wacht_aufbau]]"
  - "[[wacht_architektur]]"
  - "[[20260227_rat_von_gondor]]"
---

## description

Migration aller Gondor-Dokumente (Chroniken, Schriftrollen, Verträge des Rates) in das Azure DMS. Wie Bilbo's Buch alle Geschichten Mittelerdes versammelt, so sollen alle DMS-Bestände in Azure Blob Storage vereint werden.

Technischer Scope:
- [ ] Dokumenten-Bestand kartieren (Gondor-Archiv: Schriftrollen, Verträge, Karten) #minas-tirith-pipeline-wacht
- [ ] Azure Blob Container-Hierarchie nach Dokumenttyp anlegen #minas-tirith-pipeline-wacht
- [ ] Migrationsskript (PowerShell + Azure CLI) entwickeln #minas-tirith-pipeline-wacht
- [ ] Pilot-Migration mit Ithilien-Archiv (10%) #minas-tirith-pipeline-wacht
- [ ] Vollmigration & Abnahme durch Gandalf (Chefarchitekt) #minas-tirith-pipeline-wacht

### progression log

- 2026-02-27: Task angelegt. Wartet auf Fertigstellung von [[pipeline_wacht_aufbau|T-001]]. Priorität medium – startet nach erfolgreicher Pipeline-Wacht.

## related notes/tasks

- [[pipeline_wacht_aufbau|T-001 Pipeline-Wacht-Aufbau]] – **Voraussetzung (Blocker)**
- [[wacht_architektur|Wacht-Architektur]] – DMS-Zielarchitektur
- [[20260227_rat_von_gondor|Rat von Gondor]] – Migration als Phase 2 mandatiert
