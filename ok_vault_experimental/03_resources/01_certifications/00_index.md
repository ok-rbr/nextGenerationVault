---
title: "index - certifications"
id: "20251112_1407"
created: "2025-11-12 14:07"
lang: "en"
tags: ["obsidian/index", "certification"]
category: "index"
status: "active"
related: []
concepts: []
aliases: []
---
# Certifications Learning System

> [!abstract] Purpose
> Zentrale Übersicht über alle Zertifizierungen, Lernfortschritte und extrahiertes Wissen.

## Overview

Dieses System unterstützt das strukturierte Lernen für berufliche Zertifizierungen mit Fokus auf:
- 📚 Systematische Wissenserfassung
- 📊 Fortschrittsverfolgung
- 🎯 Prüfungsvorbereitung
- 🧠 Wissensextraktion in die permanente Knowledge Base

## Active Certifications

```dataview
TABLE 
  provider as "Provider",
  level as "Level",
  target_date as "Target Date",
  progress as "Progress %",
  priority as "Priority"
FROM "03_resources/01_certifications"
WHERE contains(tags, "certification") AND (status = "planning" OR status = "in-progress" OR status = "ready")
SORT priority DESC, target_date ASC
```

## Certification Status Overview

### Planning
```dataview
TABLE 
  cert_id as "Cert ID",
  provider as "Provider",
  level as "Level",
  target_date as "Target"
FROM "03_resources/01_certifications"
WHERE contains(tags, "certification") AND status = "planning"
SORT target_date ASC
```

### In Progress
```dataview
TABLE 
  cert_id as "Cert ID",
  provider as "Provider",
  progress as "Progress %",
  target_date as "Exam Date"
FROM "03_resources/01_certifications"
WHERE contains(tags, "certification") AND status = "in-progress"
SORT progress DESC
```

### Ready for Exam
```dataview
TABLE 
  cert_id as "Cert ID",
  target_date as "Scheduled",
  progress as "Progress %"
FROM "03_resources/01_certifications"
WHERE contains(tags, "certification") AND status = "ready"
SORT target_date ASC
```

### Passed
```dataview
TABLE 
  cert_id as "Cert ID",
  provider as "Provider",
  exam_date as "Passed",
  score as "Score",
  expiry_date as "Expires"
FROM "03_resources/01_certifications"
WHERE contains(tags, "certification") AND status = "passed"
SORT exam_date DESC
```

## Study Materials

### Study Notes
```dataview
TABLE 
  cert_id as "Certification",
  module as "Module",
  priority as "Priority",
  status as "Status"
FROM "03_resources/01_certifications"
WHERE contains(tags, "study-note")
SORT cert_id ASC, module ASC
LIMIT 20
```

### Recent Study Notes
```dataview
TABLE 
  cert_id as "Cert",
  file.mtime as "Modified"
FROM "03_resources/01_certifications"
WHERE contains(tags, "study-note")
SORT file.mtime DESC
LIMIT 10
```

## Practice Exams

### Recent Practice Exams
```dataview
TABLE 
  cert_id as "Cert",
  score as "Score",
  exam_date as "Date",
  exam_source as "Source"
FROM "03_resources/01_certifications"
WHERE contains(tags, "practice-exam")
SORT exam_date DESC
LIMIT 10
```

### Practice Exam Performance
```dataview
TABLE 
  cert_id as "Certification",
  avg(score) as "Avg Score",
  count(rows) as "# Exams"
FROM "03_resources/01_certifications"
WHERE contains(tags, "practice-exam")
GROUP BY cert_id
SORT avg(score) DESC
```

## Extracted Knowledge

### Knowledge from Certifications
```dataview
TABLE 
  source_cert as "Source Cert",
  concepts as "Concepts",
  file.ctime as "Created"
FROM "00_knowledge"
WHERE contains(tags, "from-certification")
SORT file.ctime DESC
LIMIT 15
```

### Knowledge by Certification
```dataview
TABLE 
  count(rows) as "Notes",
  string(concepts) as "Topics"
FROM "00_knowledge"
WHERE contains(tags, "from-certification")
GROUP BY source_cert
SORT count(rows) DESC
```

## Providers

### Microsoft Certifications
- [[03_resources/01_certifications/microsoft/|Microsoft Certifications Folder]]

### AWS Certifications
- TBD

### Google Cloud Certifications
- TBD

### Other Certifications
- TBD

## Learning Resources

### Recommended Platforms
- **Microsoft Learn**: https://learn.microsoft.com
- **Udemy**: https://www.udemy.com
- **Pluralsight**: https://www.pluralsight.com
- **A Cloud Guru**: https://acloudguru.com
- **LinkedIn Learning**: https://www.linkedin.com/learning

### Practice Exam Sources
- **MeasureUp**: https://www.measureup.com
- **Whizlabs**: https://www.whizlabs.com
- **ExamTopics**: https://www.examtopics.com
- **Udemy Practice Tests**: https://www.udemy.com

### Study Tips
1. **Create a structured study plan** with specific goals and timelines
2. **Use active learning** - take notes, create summaries, teach others
3. **Practice regularly** with hands-on labs and exercises
4. **Take practice exams** to identify weak areas
5. **Extract knowledge** into permanent notes for long-term retention
6. **Join study groups** and communities
7. **Review regularly** using spaced repetition

## Templates

### Available Templates
1. **cert_overview.md** - Main certification tracking page
2. **cert_study_note.md** - Individual topic/module study notes
3. **cert_practice_exam.md** - Practice exam results and analysis
4. **cert_knowledge_extraction.md** - Extract concepts to knowledge base

### How to Use Templates
1. Open Command Palette (Ctrl/Cmd + P)
2. Select "Templater: Insert Template"
3. Choose the appropriate certification template
4. Fill in the prompted information
5. Template will automatically organize the note

## Statistics

### Overall Progress
- **Total Certifications Tracked**: 
- **In Progress**: 
- **Passed**: 
- **Study Notes Created**: 
- **Practice Exams Taken**: 
- **Knowledge Notes Extracted**: 

### Time Investment
- **Target Study Hours**: 
- **Completed Study Hours**: 
- **Average Hours per Week**: 

## Quick Links

- [[README_CERTIFICATIONS|Certification System Documentation]]
- [[00_knowledge/00_index|Knowledge Base]]
- [[03_resources/00_index|Resources Index]]

---

**Last Updated**: 2025-11-12
**System Version**: 1.0
