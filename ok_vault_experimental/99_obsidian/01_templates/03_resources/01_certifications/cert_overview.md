<%*
// Certification Overview Template
const lib = tp.user.lib;

const certName = await lib.promptText(tp, "Certification name (e.g., AZ-900, SC-300):");
const certFullName = await lib.promptText(tp, "Full certification name:");
const provider = await lib.promptText(tp, "Provider (e.g., Microsoft, AWS, Google):");
const level = await lib.promptSuggester(tp, "Certification level:", 
    ["Fundamentals", "Associate", "Expert", "Specialty"],
    ["fundamentals", "associate", "expert", "specialty"]);
const targetDate = await lib.promptText(tp, "Target exam date (YYYY-MM-DD, optional):", "");
const priority = await lib.promptPriority(tp);
const status = await lib.promptSuggester(tp, "Status:", 
    ["Planning", "In Progress", "Ready for Exam", "Passed", "Failed", "Expired"],
    ["planning", "in-progress", "ready", "passed", "failed", "expired"]);

// Create slug
const titleSlug = lib.slugify(`${provider}_${certName}`);

// Build frontmatter
const fm = lib.fmResource({
    title: `${certName} - ${certFullName}`,
    extraTags: ["certification", lib.slugify(provider), level]
});

fm.cert_id = certName.toUpperCase();
fm.provider = provider;
fm.level = level;
fm.status = status;
fm.priority = priority;
fm.target_date = targetDate;
fm.exam_date = "";
fm.expiry_date = "";
fm.score = "";
fm.progress = 0;

// Move to certifications folder
await lib.renameAndMove(tp, titleSlug, `/03_resources/01_certifications/${lib.slugify(provider)}/${titleSlug}`);
-%>---
title: "<% fm.title %>"
id: "<% fm.id %>"
created: "<% fm.created %>"
lang: "en"
tags: <% JSON.stringify(fm.tags) %>
category: "resource"
cert_id: "<% fm.cert_id %>"
provider: "<% fm.provider %>"
level: "<% fm.level %>"
status: "<% fm.status %>"
priority: "<% fm.priority %>"
target_date: "<% fm.target_date %>"
exam_date: "<% fm.exam_date %>"
expiry_date: "<% fm.expiry_date %>"
score: "<% fm.score %>"
progress: <% fm.progress %>
related: []
concepts: []
aliases: ["<% certName %>"]
---
# [[<% fm.title %>]]

## Certification Overview

**Certification ID**: `<% certName %>`
**Full Name**: <% certFullName %>
**Provider**: <% provider %>
**Level**: <% level %>
**Target Exam Date**: <% targetDate || "Not set" %>

## Exam Information

### Exam Details
- **Exam Code**: <% certName %>
- **Duration**: 
- **Number of Questions**: 
- **Passing Score**: 
- **Cost**: 
- **Format**: Multiple Choice, Case Studies, Hands-on

### Official Resources
- **Official Page**: 
- **Learning Path**: 
- **Documentation**: 
- **Practice Tests**: 

## Study Plan

### Learning Objectives
```dataview
TABLE 
  status as "Status",
  progress as "Progress %"
FROM "03_resources/01_certifications"
WHERE contains(related, "<% certName %>") AND contains(tags, "learning-objective")
SORT file.name ASC
```

### Study Notes
```dataview
TABLE 
  file.mtime as "Modified",
  status as "Status"
FROM "03_resources/01_certifications"
WHERE contains(related, "<% certName %>") AND contains(tags, "study-note")
SORT file.mtime DESC
LIMIT 10
```

### Practice Results
```dataview
TABLE 
  score as "Score %",
  exam_date as "Date"
FROM "03_resources/01_certifications"
WHERE contains(related, "<% certName %>") AND contains(tags, "practice-exam")
SORT exam_date DESC
```

## Progress Tracking

**Overall Progress**: <% fm.progress %>%

### Study Hours
- **Target Hours**: 
- **Completed Hours**: 
- **Remaining Hours**: 

### Study Log
- [ ] Week 1: Foundation concepts
- [ ] Week 2: Core topics
- [ ] Week 3: Advanced topics
- [ ] Week 4: Practice exams
- [ ] Week 5: Review and exam preparation

## Exam Preparation

### Key Topics to Master
1. 
2. 
3. 

### Weak Areas
- 

### Practice Exam Results
| Date | Source | Score | Notes |
|------|--------|-------|-------|
|      |        |       |       |

## Knowledge Extraction

### Key Concepts Learned
```dataview
LIST
FROM "00_knowledge"
WHERE contains(related, "<% certName %>")
SORT file.name ASC
```

### Skills Acquired
- 
- 
- 

### Practical Applications
- 
- 

## Exam Experience

### Pre-Exam Checklist
- [ ] Reviewed all study notes
- [ ] Completed practice exams (>80% score)
- [ ] Reviewed weak areas
- [ ] Scheduled exam
- [ ] Prepared exam environment

### Exam Day Notes
**Date**: 
**Location**: 
**Experience**: 

### Post-Exam Reflection
**Result**: 
**Score**: 
**What went well**: 
**What could be improved**: 

## Maintenance & Renewal

**Certification Status**: <% status %>
**Expiry Date**: 
**Renewal Requirements**: 
**Renewal Plan**: 

## Related Resources

### Books & Courses
- 

### Labs & Hands-on
- 

### Community Resources
- 

### Related Certifications
- 

## Notes & Reflections

