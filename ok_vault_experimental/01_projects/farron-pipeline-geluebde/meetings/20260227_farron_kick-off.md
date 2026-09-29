---
title: "20260227_farron_kick-off"
created: "2026-02-27"
tags: ["meeting", "farron-pipeline-geluebde", "dark-souls", "ashen", "farron"]
category: "meeting"
thema: "Gelübde-Initiierung & Pipeline-Planung"
summary: "Pipeline-Architektur für Farron Keep definiert. T-001 Pipeline-Initialisierung als kritischer Pfad. DMS-Migration als Phase 2 festgelegt."
attendees: ["Watchdog of Farron", "Abyss Watcher – Erster Kläger", "Old Wolf of Farron"]
date: "20260227"

---

# [[20260227_farron_kick-off]]

## agenda

- Das Gelübde erneuern: Ziele des Farron – Pipeline-Projekts
- Review der [[farron_architektur|Architektur-Übersicht]]
- Priorisierung: [[pipeline_initialisierung|T-001]] vor [[dms_migration|T-002]]
- Phasenplanung & Meilensteine

## log

- Der Watchdog bestätigt: Das Feuer der Pipeline darf nicht erlöschen – hohe Prio auf T-001
- Erster Kläger übernimmt technische Architektur; Dokument [[farron_architektur]] wird angelegt
- DMS-Migration (T-002) bewusst als Phase 2 platziert – erst wenn Pipeline stabil
- Deployment-Umgebungen nach Dark-Souls-Orten benannt: `undead-asylum` → `farron-keep` → `firelink`
- Old Wolf: „Jede Seele (jeder Commit) muss durch den Build-Altar geprüft werden"

## action items

- [ ] Erster Kläger: [[pipeline_initialisierung|T-001 Pipeline aufbauen]] bis 2026-03-07
- [ ] Erster Kläger: [[farron_architektur|Architektur-Dokument]] finalisieren bis 2026-03-03
- [ ] Watchdog: Azure-Subscription genehmigen bis 2026-03-01
- [ ] Alle: [[dms_migration|T-002 DMS-Migration]] nach T-001-Abschluss starten
