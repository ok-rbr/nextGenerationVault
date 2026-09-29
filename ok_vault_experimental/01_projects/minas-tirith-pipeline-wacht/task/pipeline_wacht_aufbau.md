---
title: pipeline_wacht_aufbau
created: "2026-02-27"
tags: ["task", "minas-tirith-pipeline-wacht", "lotr", "middle-earth", "free-peoples", "gondor", "tool/azure"]
category: "task"
project: "Minas Tirith – Pipeline-Wacht"
status: "in-progress"
task_id: T-001
priority: high
related: ["[[wacht_architektur]]", "[[20260227_rat_von_gondor]]"]

---

## description

Aufbau der Azure DevOps CI/CD-Pipeline als Wacht über die digitale Infrastruktur von Minas Tirith. Wie die sieben Ebenen der weißen Stadt, so gibt es sieben Pipeline-Stages – keine soll unverteidigt bleiben.

Technischer Scope:
- [ ] Azure DevOps Projekt „Minas-Tirith-Wacht" anlegen #minas-tirith-pipeline-wacht
- [ ] YAML-Pipeline mit sieben Stages definieren #minas-tirith-pipeline-wacht
- [ ] Gondor-Environments anlegen: `osgiliath` (Dev) → `ithilien` (Staging) → `minas-tirith` (Prod) #minas-tirith-pipeline-wacht
- [ ] Branch-Policies: kein Merge ohne Palantír-Review (PR-Approval) #minas-tirith-pipeline-wacht
- [ ] Service Connection zu Azure Subscription „Gondor-Cloud" einrichten #minas-tirith-pipeline-wacht

### progression log

- 2026-02-27: Task nach [[20260227_rat_von_gondor|Rat von Gondor]] eingesetzt. Architektur in [[wacht_architektur]] dokumentiert.

## related notes/tasks

- [[wacht_architektur|Wacht-Architektur-Dokument]] – technische Grundlage
- [[20260227_rat_von_gondor|Rat von Gondor – Kick-Off]] – König Aragorns Mandat
- [[dms_migration_gondor|T-002 DMS-Migration Gondor]] – Folgetask, nach Abschluss dieses Tasks
