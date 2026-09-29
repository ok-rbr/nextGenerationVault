---
title: azure_pipeline_konfiguration
created: 2026-02-27
tags:
  - task
  - wano_azure_migration
  - one-piece
  - tool/azure
  - topic/cloud
category: task
project: Wano Reise – Azure Pipeline Migration
status: active
task_id: T-001
priority: high
related:
  - "[[architektur_uebersicht]]"
  - "[[20260227_kick-off-meeting]]"
---

## description

Einrichtung der Azure DevOps CI/CD-Pipeline für die Wano-Migration. Umfasst Build-Pipeline, Release-Pipeline, Branch-Strategie (`main` / `dev` / `feature/*`) sowie Artifact-Feed-Konfiguration.

Technischer Scope:
- [ ] Azure DevOps Projekt anlegen #wano_azure_migration
- [ ] Build-Pipeline (YAML) für Backend konfigurieren #wano_azure_migration
- [ ] Release-Pipeline mit Staging → Production konfigurieren #wano_azure_migration
- [ ] Service Connection zu Azure Subscription einrichten #wano_azure_migration

### progression log

- 2026-02-27: Task angelegt nach [[20260227_kick-off-meeting|Kick-Off Meeting]]. Architektur-Grundlage in [[architektur_uebersicht]] dokumentiert.

## related notes/tasks

- [[architektur_uebersicht|Architektur-Übersicht]] – technische Grundlage
- [[20260227_kick-off-meeting|Kick-Off Meeting 27.02.]] – Entscheidungen & Action Items
- [[Example|DMS-Integration Task]] – Abhängigkeit: Pipeline muss vor DMS-Task fertig sein
