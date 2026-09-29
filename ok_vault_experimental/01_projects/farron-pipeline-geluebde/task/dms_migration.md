---
title: dms_migration
created: 2026-02-27
tags:
  - task
  - farron-pipeline-geluebde
  - dark-souls
  - ashen
  - tool/azure
  - topic/migration
category: task
project: Farron – Pipeline-Gelübde
status: pending
task_id: T-002
priority: medium
related:
  - "[[pipeline_initialisierung]]"
  - "[[farron_architektur]]"
  - "[[20260227_farron_kick-off]]"
---

## description

Migration des bestehenden Dokumenten-Management-Systems in die Azure-Infrastruktur. 
Wie die Seelen der Untoten in Farron gesammelt werden, so werden hier alle DMS-Dokumente in Azure Blob Storage überführt.

Technischer Scope:
- [ ] DMS-Bestand inventarisieren (Dokumenttypen, Volumina) #farron-pipeline-geluebde
- [ ] Azure Blob Storage Container-Struktur planen #farron-pipeline-geluebde
- [ ] Migrationsskript erstellen (PowerShell / Azure CLI) #farron-pipeline-geluebde
- [ ] Testmigration mit 10% Datensatz durchführen #farron-pipeline-geluebde
- [ ] Vollmigration & Verifikation #farron-pipeline-geluebde

### progression log

- 2026-02-27: Task angelegt. Blockiert durch [[pipeline_initialisierung|T-001]] – Pipeline muss stehen, bevor DMS-Migration beginnen kann.

---

### Block

Aktuell warte ich darauf das mir die notwendigen Azure Berechtigungen und Ressourcen bereitgestellt werden

## related notes/tasks

- [[pipeline_initialisierung|T-001 Pipeline-Initialisierung]] – **Voraussetzung (Blocker)**
- [[farron_architektur|Farron Architektur]] – Zielarchitektur für DMS
- [[20260227_farron_kick-off|Kick-Off Meeting]] – DMS-Migration als zweite Phase beschlossen
