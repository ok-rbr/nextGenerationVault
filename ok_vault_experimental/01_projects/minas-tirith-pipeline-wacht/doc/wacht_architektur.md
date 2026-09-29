---
title: wacht_architektur
created: "2026-02-27"
tags: ["note", "minas-tirith-pipeline-wacht", "lotr", "middle-earth", "free-peoples", "gondor", "tool/azure", "topic/cloud"]
category: "note"
project: "Minas Tirith – Pipeline-Wacht"
status: "active"

---

## description

Technische Architektur für die **Minas Tirith – Pipeline-Wacht**. Erstellt nach dem [[20260227_rat_von_gondor|Rat von Gondor]] unter Aufsicht von Gandalf. Wie die sieben Ebenen der weißen Stadt bilden sieben Pipeline-Stages die unüberwindliche Verteidigung des Deployments.

### Zielarchitektur

```
[Quellcode – GitHub]
        │
        ▼
[Azure DevOps – 7-Stage Pipeline]   ← T-001: [[pipeline_wacht_aufbau]]
        │
   ┌────┼──────────────┐
   ▼    ▼              ▼
[osgiliath]  [ithilien]  [minas-tirith]
   (Dev)      (Staging)   (Production)
                               │
                    [Palantír-Gate: PR-Approval]
                               │
                               ▼
                    [Azure Blob – DMS]    ← T-002: [[dms_migration_gondor]]
                               │
                               ▼
                    [Azure Monitor – Legolas-Dashboard]
```

### Environments

| Environment | Azure-Dienst | Entsprechung | Wächter |
|---|---|---|---|
| `osgiliath` | App Service (Dev) | Development | Faramir |
| `ithilien` | App Service (Standard) | Staging | Faramir |
| `minas-tirith` | App Service (Premium) | Production | Aragorn |
| DMS-Store | Azure Blob Storage | Dokumentenarchiv | Gimli |
| Monitoring | Azure Monitor | Observability | Legolas |

### Sicherheits-Prinzipien (Palantír-Strategie)

- **Kein Merge ohne Review**: Mindestens 1 Approval auf `main` / `release/*`
- **Prod-Gate manuell**: Aragorn muss Production-Deployments freigeben
- **Rollback in < 5 Min**: Vorherige App-Service-Slot-Version muss immer aktiv bleiben
- **Audit-Trail**: Alle Pipeline-Läufe 90 Tage in Log Analytics

### progression log

- 2026-02-27: Erstversion nach [[20260227_rat_von_gondor|Rat von Gondor]] erstellt.

## related

- [[pipeline_wacht_aufbau|T-001 Pipeline-Wacht-Aufbau]]
- [[dms_migration_gondor|T-002 DMS-Migration Gondor]]
- [[20260227_rat_von_gondor|Rat von Gondor 27.02.]]
- [[01_projects/minas-tirith-pipeline-wacht/index|Projekt-Index]]
