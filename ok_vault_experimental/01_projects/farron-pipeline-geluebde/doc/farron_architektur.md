---
title: farron_architektur
created: "2026-02-27"
tags: ["note", "farron-pipeline-geluebde", "dark-souls", "ashen", "tool/azure", "topic/cloud"]
category: "note"
project: "Farron – Pipeline-Gelübde"
status: "active"

---

## description

Technische Architektur für das **Farron – Pipeline-Gelübde**. Entstanden im [[20260227_farron_kick-off|Kick-Off Meeting]] unter den Wächtern von Farron. Das Feuer des kontinuierlichen Deployments soll nie erlöschen.

### Zielarchitektur

```
[Quellcode – GitHub]
        │
        ▼
[Azure DevOps – Pipeline]    ← T-001: [[pipeline_initialisierung]]
        │
   ┌────┴──────────┐
   ▼               ▼
[undead-asylum]  [farron-keep]  →  [firelink-shrine]
   (Dev)          (Staging)         (Production)
                                        │
                                        ▼
                              [Azure Blob – DMS]  ← T-002: [[dms_migration]]
```

### Umgebungen

| Umgebung | Azure-Dienst | Entsprechung | Status |
|---|---|---|---|
| `undead-asylum` | App Service (Free) | Development | ⏳ ausstehend |
| `farron-keep` | App Service (Standard) | Staging | ⏳ ausstehend |
| `firelink-shrine` | App Service (Premium) | Production | ⏳ ausstehend |
| DMS-Store | Azure Blob Storage | Dokumentenablage | ⏳ [[dms_migration\|T-002]] |

### Offene Entscheidungen

- [ ] Retention-Policy für Build-Artifacts (14 oder 30 Tage?)
- [ ] Gating-Strategie für Prod-Deployment (manuell vs. automatisch)
- [ ] DMS-Zugriffsmodell: RBAC über Azure AD

### progression log

- 2026-02-27: Erstversion nach [[20260227_farron_kick-off|Kick-Off]] angelegt.

## related

- [[pipeline_initialisierung|T-001 Pipeline-Initialisierung]]
- [[dms_migration|T-002 DMS-Migration]]
- [[20260227_farron_kick-off|Kick-Off Meeting 27.02.]]
- [[01_projects/farron-pipeline-geluebde/index|Projekt-Index]]
