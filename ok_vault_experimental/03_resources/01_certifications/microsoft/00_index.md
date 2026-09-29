---
title: "index - microsoft certifications"
id: "20251112_1410"
created: "2025-11-12 14:10"
lang: "en"
tags: ["obsidian/index", "certification", "microsoft"]
category: "index"
status: "active"
related: []
concepts: []
aliases: []
---
# Microsoft Certifications

> [!info] Microsoft Learn
> Alle Microsoft Zertifizierungen verwenden Microsoft Learn als primäre Lernplattform.
> https://learn.microsoft.com/certifications

## Overview

Dieser Ordner enthält alle Microsoft-Zertifizierungen, organisiert nach Zertifizierungs-ID.

## Active Microsoft Certifications

```dataview
TABLE 
  level as "Level",
  target_date as "Target Date",
  progress as "Progress %",
  priority as "Priority"
FROM "03_resources/01_certifications/microsoft"
WHERE contains(tags, "certification") AND (status = "planning" OR status = "in-progress" OR status = "ready")
SORT priority DESC, target_date ASC
```

## Certification Paths

### Fundamentals
- **AZ-900**: Azure Fundamentals
- **SC-900**: Security, Compliance, and Identity Fundamentals
- **MS-900**: Microsoft 365 Fundamentals
- **AI-900**: AI Fundamentals
- **DP-900**: Data Fundamentals
- **PL-900**: Power Platform Fundamentals

### Associate
- **AZ-104**: Azure Administrator
- **AZ-204**: Azure Developer
- **AZ-305**: Azure Solutions Architect (Expert)
- **SC-300**: Identity and Access Administrator
- **SC-200**: Security Operations Analyst
- **MS-102**: Microsoft 365 Administrator

### Expert
- **AZ-305**: Azure Solutions Architect Expert
- **AZ-500**: Azure Security Engineer Associate
- **SC-100**: Cybersecurity Architect

### Specialty
- **AZ-120**: SAP on Azure
- **AZ-140**: Azure Virtual Desktop
- **AZ-220**: IoT Developer

## Study Statistics

### Study Notes by Certification
```dataview
TABLE 
  count(rows.file) as "Notes Count"
FROM "03_resources/01_certifications/microsoft"
WHERE contains(tags, "study-note")
GROUP BY cert_id
SORT count(rows.file) DESC
```

### Recent Study Activity
```dataview
TABLE 
  cert_id as "Cert",
  file.mtime as "Last Modified"
FROM "03_resources/01_certifications/microsoft"
WHERE contains(tags, "study-note")
SORT file.mtime DESC
LIMIT 10
```

### Practice Exam Scores
```dataview
TABLE 
  cert_id as "Certification",
  score as "Score",
  exam_date as "Date"
FROM "03_resources/01_certifications/microsoft"
WHERE contains(tags, "practice-exam")
SORT exam_date DESC
LIMIT 10
```

## Learning Resources

### Microsoft Official
- **Microsoft Learn**: https://learn.microsoft.com
- **Microsoft Docs**: https://docs.microsoft.com
- **Microsoft Virtual Training Days**: Free instructor-led training
- **Microsoft Certification Dashboard**: Track your certifications

### Community Resources
- **John Savill's YouTube Channel**: Azure Master Class
- **Adam Marczak's YouTube**: Azure for Everyone
- **Thomas Maurer Blog**: Azure updates and tips
- **Scott Duffy's Udemy Courses**: Popular exam prep courses

### Practice Exams
- **Microsoft Official Practice Assessment**: Free on Learn
- **MeasureUp**: Official practice tests
- **Whizlabs**: Comprehensive practice exams
- **Udemy**: Various practice test options

## Certification Benefits

### Why Get Microsoft Certified?
1. **Career Advancement**: Higher salaries and better positions
2. **Skill Validation**: Prove your expertise
3. **Recognition**: Industry-recognized credentials
4. **Knowledge**: Structured learning path
5. **Network**: Access to Microsoft community
6. **Free Resources**: Access to exclusive content

### Certification Perks
- **Microsoft Certified Trainer (MCT)**: Path to become trainer
- **Exam Discounts**: Regular promotions
- **Free Renewals**: Some certifications offer free renewal
- **Digital Badge**: Shareable credential
- **Transcript**: Official record of achievements

## Recommended Study Approach

### Step 1: Choose Your Path
1. Start with Fundamentals (AZ-900, SC-900)
2. Progress to Associate level
3. Consider Expert certifications
4. Add Specialty certifications as needed

### Step 2: Create Study Plan
1. Review exam requirements
2. Estimate study time (20-100 hours depending on level)
3. Set target exam date
4. Create weekly study schedule

### Step 3: Study Systematically
1. Use Microsoft Learn modules
2. Take detailed study notes
3. Complete hands-on labs
4. Watch video tutorials
5. Join study groups

### Step 4: Practice
1. Take practice exams
2. Identify weak areas
3. Review and reinforce
4. Repeat until consistently scoring 80%+

### Step 5: Schedule & Pass
1. Schedule exam
2. Final review
3. Take exam
4. Celebrate success!

### Step 6: Extract Knowledge
1. Review your study notes
2. Extract key concepts to knowledge base
3. Create permanent notes
4. Share learnings with team

## Quick Links

- [[03_resources/01_certifications/00_index|All Certifications]]
- [[03_resources/01_certifications/README_CERTIFICATIONS|Certification System Documentation]]
- [[00_knowledge/00_index|Knowledge Base]]

---

**Last Updated**: 2025-11-12
