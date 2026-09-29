---
title: pipeline_initialisierung
created: 2026-02-27
tags:
  - task
  - farron-pipeline-geluebde
  - dark-souls
  - ashen
  - tool/azure
category: task
project: Farron – Pipeline-Gelübde
status: done
task_id: T-001
priority: high
related:
  - "[[farron_architektur]]"
  - "[[20260227_farron_kick-off]]"
---

## description

Initialisierung der Azure DevOps Pipeline für das Farron-Gelübde. Die Asche des alten Systems soll nicht erlöschen – jeder Build-Schritt muss als ewige Flamme brennen.

Technischer Scope:
- [x] Azure DevOps Organisation für Farron Keep anlegen #farron-pipeline-geluebde
- [x] YAML-Pipeline für Build & Test erstellen #farron-pipeline-geluebde
- [x] Deployment-Stages: `undead-asylum` (Dev) → `farron-keep` (Staging) → `firelink` (Prod) #farron-pipeline-geluebde
- [x] Branch-Schutzregeln einrichten (kein direkter Push auf `main`) #farron-pipeline-geluebde

### progression log

- 2026-02-27: Task nach [[20260227_farron_kick-off|Farron Kick-Off]] angelegt. Architektur in [[farron_architektur]] hinterlegt.

## related notes/tasks

- [[farron_architektur|Farron Architektur-Dokument]] – technische Grundlage
- [[20260227_farron_kick-off|Kick-Off: Farron Gelübde]] – Entscheidungen
- [[dms_migration|T-002 DMS-Migration]] – Folgeaufgabe, blockiert durch diesen Task
- [ ] #waechter-von-farron-weekly Pipeline erfolgreich initalisiert, Doku erstellt
