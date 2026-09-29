---
title: automatisierungs_spezifikation
created: "2026-02-27"
tags: ["note", "gallifrey-automatisierungs-protokoll", "doctor-who", "time-lord", "gallifrey", "tool/azure", "topic/cloud"]
category: "note"
project: "Gallifrey – Automatisierungs-Protokoll"
status: "active"

---

## description

Verbindliche technische Spezifikation für das **Gallifrey – Automatisierungs-Protokoll**. Mandatiert durch den [[20260227_rat_der_timelords|Rat der Time Lords]]. Dieses Dokument ist Grundlage für [[deployment_protokoll|T-001]] und [[pipeline_kalibrierung|T-002]].

### Zielarchitektur

```
[Source – GitHub]
       │
       ▼
[Azure DevOps – Multi-Stage Pipeline]   ← T-001: [[deployment_protokoll]]
       │
  ┌────┼────────────┐
  ▼    ▼            ▼
[gallifrey-dev]  [gallifrey-staging]  [gallifrey-prod]
                                           │
                               [Approval Gate – Time Lord Council]
                                           │
                                           ▼
                               [Azure Monitor – Audit Log]   ← Pflicht lt. Rat
       │
       ▼
[DMS – Azure Blob]                       ← T-002: [[pipeline_kalibrierung]]
```

### Qualitätskriterien (Beschluss des Rates)

| Kriterium | Vorgabe |
|---|---|
| Build-Dauer | < 10 Minuten |
| Test-Coverage | ≥ 80% |
| Prod-Approval | Manuell (2 Time Lords) |
| Rollback-Zeit | < 5 Minuten |
| Audit-Log | Vollständig, 365 Tage Retention |

### Technologie-Stack

| Layer | Technologie | Entscheider |
|---|---|---|
| CI/CD | Azure DevOps Pipelines | Romana |
| Hosting | Azure App Service | Romana |
| Storage | Azure Blob Storage | Cardinal Ollistra |
| Monitoring | Azure Monitor + Log Analytics | Cardinal Ollistra |
| IaC | Bicep / ARM Templates | Doctor (Review) |

### progression log

- 2026-02-27: Erstversion nach [[20260227_rat_der_timelords|Ratssitzung]] erstellt.

## related

- [[deployment_protokoll|T-001 Deployment-Protokoll]]
- [[pipeline_kalibrierung|T-002 Pipeline-Kalibrierung]]
- [[20260227_rat_der_timelords|Rat der Time Lords 27.02.]]
- [[01_projects/gallifrey-automatisierungs-protokoll/index|Projekt-Index]]
