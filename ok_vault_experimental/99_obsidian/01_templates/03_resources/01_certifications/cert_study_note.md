<%*
// Certification Study Note Template
const lib = tp.user.lib;

const topic = await lib.promptText(tp, "Topic/Module name:");
const certId = await lib.promptText(tp, "Related certification (e.g., AZ-900):");
const module = await lib.promptText(tp, "Module/Section number (optional):", "");
const priority = await lib.promptPriority(tp);

// Create slug
const titleSlug = lib.slugify(`${certId}_${topic}`);

// Build frontmatter
const fm = lib.fmResource({
    title: `${certId}: ${topic}`,
    extraTags: ["study-note", "certification", lib.slugify(certId)]
});

fm.cert_id = certId.toUpperCase();
fm.module = module;
fm.priority = priority;
fm.status = "in-progress";
fm.related = [certId];

// Move to certifications folder
const provider = lib.slugify(certId.startsWith("AZ-") || certId.startsWith("SC-") || certId.startsWith("MS-") ? "microsoft" : "general");
await lib.renameAndMove(tp, titleSlug, `/03_resources/01_certifications/${provider}/${titleSlug}`);
-%>---
title: "<% fm.title %>"
id: "<% fm.id %>"
created: "<% fm.created %>"
lang: "en"
tags: <% JSON.stringify(fm.tags) %>
category: "resource"
cert_id: "<% fm.cert_id %>"
module: "<% fm.module %>"
priority: "<% fm.priority %>"
status: "<% fm.status %>"
related: <% JSON.stringify(fm.related) %>
concepts: []
aliases: []
---
# [[<% fm.title %>]]

> [!info] Study Note
> **Certification**: <% certId %>
> **Module**: <% module || "N/A" %>
> **Priority**: <% priority %>

## Overview

### Learning Objectives
- 
- 
- 

### Key Concepts
- 
- 
- 

## Detailed Notes

### Core Concepts

#### Concept 1: 


#### Concept 2: 


#### Concept 3: 


## Technical Details

### Architecture/Design Patterns


### Best Practices
1. 
2. 
3. 

### Common Pitfalls
- ⚠️ 
- ⚠️ 

## Hands-on Practice

### Lab Exercises
- [ ] Lab 1: 
- [ ] Lab 2: 
- [ ] Lab 3: 

### Commands/Code Snippets
```bash
# Example commands

```

### Configuration Examples
```yaml
# Example configuration

```

## Exam Relevance

### Likely Exam Topics
- ✅ 
- ✅ 
- ✅ 

### Question Types
- Multiple choice
- Case study
- Hands-on scenario

### Sample Questions
1. **Q**: 
   **A**: 

2. **Q**: 
   **A**: 

## Knowledge Extraction

### Key Takeaways
1. 
2. 
3. 

### Mental Models
- 🧠 
- 🧠 

### Connections to Other Topics
- Related to: [[]]
- Builds upon: [[]]
- Required for: [[]]

## Review & Practice

### Self-Assessment
- [ ] Understand core concepts
- [ ] Can explain to others
- [ ] Completed hands-on practice
- [ ] Ready for exam questions

### Practice Questions Score
- Date: 
- Score: 
- Areas to review: 

### Spaced Repetition
- First review: 
- Second review: 
- Third review: 
- Mastered: 

## Resources

### Official Documentation
- 

### Videos & Tutorials
- 

### Additional Reading
- 

### Practice Resources
- 

## Notes & Questions

### Questions to Research
- ❓ 
- ❓ 

### Additional Notes


## Related Study Notes
```dataview
TABLE 
  priority as "Priority",
  status as "Status",
  module as "Module"
FROM "03_resources/01_certifications"
WHERE contains(tags, "study-note") AND cert_id = "<% certId %>" AND file.name != this.file.name
SORT module ASC
```
