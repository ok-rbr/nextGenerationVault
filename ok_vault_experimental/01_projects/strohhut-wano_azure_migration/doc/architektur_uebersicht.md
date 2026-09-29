---
title: architektur_uebersicht
created: "2026-02-27"
tags: ["note", "wano_azure_migration", "one-piece", "tool/azure", "topic/cloud"]
category: "note"
project: "Wano Reise – Azure Pipeline Migration"
status: "active"

---

## description

Technische Architektur-Übersicht für die **Wano Reise – Azure Pipeline Migration**. Dieses Dokument ist die Grundlage für alle technischen Entscheidungen im Projekt – entstanden im [[20260227_kick-off-meeting|Kick-Off Meeting]] vom 27.02.2026.

### Zielarchitektur

```
[Source Code – GitHub]
        │
        ▼
[Azure DevOps – CI/CD Pipeline]   ← T-001: [[azure_pipeline_konfiguration]]
        │
   ┌────┴────┐
   ▼         ▼
[Staging]  [Production]
(App Svc)  (App Svc)
        │
        ▼
[Azure Blob – DMS Artifacts]      ← T-002: [[Example|DMS-Integration]]
```

### Komponenten

| Komponente | Dienst | Status |
|---|---|---|
| Source Control | GitHub | ✅ bereit |
| CI/CD Pipeline | Azure DevOps | 🔄 [[azure_pipeline_konfiguration\|in Arbeit]] |
| App Hosting | Azure App Service | ⏳ ausstehend |
| Dokumenten-Management | Azure Blob + DMS | ⏳ [[Example\|ausstehend]] |
| Monitoring | Azure Monitor | ⏳ ausstehend |

### Offene Entscheidungen

- [ ] DMS-Anbieter: Azure native vs. externes System
- [ ] Branch-Strategie: GitFlow vs. Trunk-based
- [ ] Deployment-Slots: Blue/Green oder Rolling

### progression log

- 2026-02-27: Erstversion nach [[20260227_kick-off-meeting|Kick-Off Meeting]] angelegt.

## related

- [[azure_pipeline_konfiguration|T-001 Pipeline-Konfiguration]] – umsetzt diese Architektur
- [[20260227_kick-off-meeting|Kick-Off Meeting 27.02.]] – Entscheidungsgrundlage
- [[01_projects/strohhut-wano_azure_migration/index|Projekt-Index]]
