---
title: "gefaehrten_des_rings"
id: "20260227_1635"
created: "2026-02-27 16:35"
tags: ["resource", "client/gefaehrten_des_rings", "lotr", "middle-earth", "free-peoples", "gondor", "topic/cloud", "tool/azure"]
category: "resource"
status: "active"
role: "Ringträger-Geleit / Pipeline-Auftraggeber"
company: "Gefährtenschaft von Bruchtal – Rat von Elrond"
email: "fellowship@rivendell.middleearth"
phone: "+0 PALANTIR-0009"
location: "Minas Tirith, Gondor"
start_date: "20260227"
related: ["[[01_projects/minas-tirith-pipeline-wacht/index]]"]
concepts: ["azure-pipeline", "dms-migration", "automatisierung", "wacht-protokoll"]
aliases: ["Gefährten des Rings", "LOTR-GONDOR-07", "minas-tirith-pipeline-wacht"]
---

# Gefährten des Rings

> *„Man muss nicht groß sein, um eine Pipeline zu deployen – aber es hilft, wenn man Gandalf im Team hat."*

## Profil

| Feld | Wert |
|---|---|
| **Fraktion** | Gefährten des Rings |
| **Rolle** | Ringträger-Geleit / Pipeline-Auftraggeber |
| **Heimat** | Minas Tirith, Gondor |
| **Codename** | LOTR-GONDOR-07 |
| **Kontakt** | fellowship@rivendell.middleearth |
| **Status** | active |
| **Projekt-Start** | 2026-02-27 |

## Beschreibung

Die Gefährten des Rings – vereint im Rat von Elrond – beauftragen die *Minas Tirith – Pipeline-Wacht*: den Aufbau einer wehrhaften Azure-Pipeline-Infrastruktur für das gesamte Freie Volk Mittelerdes. DMS-Migration, automatisierte Deployments und lückenlose Überwachung – damit kein dunkler Schatten je wieder ein Produktivsystem zum Fallen bringt. Man wirft den Ring nicht in den Schicksalsberg, man deployt ihn sauber über eine CI/CD-Pipeline.

## Schlüsselkontakte

| Name | Rolle im Projekt |
|---|---|
| Aragorn | Sponsor / Entscheider (König von Gondor) |
| Gandalf | Technischer Chefarchitekt |
| Frodo | Anforderungsträger / Product Owner |
| Legolas | Monitoring & Observability |
| Gimli | Infrastruktur & On-Premises |

## Aktive Projekte

- [[01_projects/minas-tirith-pipeline-wacht/index|Minas Tirith – Pipeline-Wacht]]

## Meeting-Log

```dataview
TABLE date, thema, summary
FROM "01_projects/minas-tirith-pipeline-wacht/meetings"
SORT date desc
LIMIT 10
```

## Offene Aufgaben

```dataviewjs
dv.taskList(
  dv.pages('"01_projects/minas-tirith-pipeline-wacht"').file.tasks
    .where(t => !t.completed)
)
```
