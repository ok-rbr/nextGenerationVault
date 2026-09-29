<%*
// Certification Practice Exam Template
const lib = tp.user.lib;

const certId = await lib.promptText(tp, "Related certification (e.g., AZ-900):");
const examSource = await lib.promptText(tp, "Exam source (e.g., Microsoft Learn, Udemy, MeasureUp):");
const examDate = lib.generateDateId(tp);
const score = await lib.promptText(tp, "Score percentage (e.g., 85):", "");

// Create slug
const titleSlug = lib.slugify(`${certId}_practice_${examDate}`);

// Build frontmatter
const fm = lib.fmResource({
    title: `${certId} Practice Exam - ${examDate}`,
    extraTags: ["practice-exam", "certification", lib.slugify(certId)]
});

fm.cert_id = certId.toUpperCase();
fm.exam_date = lib.generateCreatedTimestamp(tp);
fm.exam_source = examSource;
fm.score = score;
fm.status = "completed";
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
exam_date: "<% fm.exam_date %>"
exam_source: "<% fm.exam_source %>"
score: "<% fm.score %>"
status: "<% fm.status %>"
related: <% JSON.stringify(fm.related) %>
concepts: []
aliases: []
---
# [[<% fm.title %>]]

> [!success] Practice Exam Result
> **Score**: <% score %>%
> **Source**: <% examSource %>
> **Date**: <% fm.exam_date %>

## Exam Summary

**Certification**: <% certId %>
**Source**: <% examSource %>
**Date**: <% fm.exam_date %>
**Score**: <% score %>%
**Pass/Fail**: <% (parseInt(score) >= 70) ? "✅ Pass" : "❌ Fail" %>

### Exam Details
- **Total Questions**: 
- **Correct Answers**: 
- **Incorrect Answers**: 
- **Skipped**: 
- **Time Taken**: 
- **Time Limit**: 

## Performance by Domain

### Domain Breakdown
| Domain | Questions | Score | Status |
|--------|-----------|-------|--------|
| Domain 1: | | | |
| Domain 2: | | | |
| Domain 3: | | | |
| Domain 4: | | | |

### Strongest Areas
1. ✅ 
2. ✅ 
3. ✅ 

### Areas for Improvement
1. ⚠️ 
2. ⚠️ 
3. ⚠️ 

## Question Analysis

### Incorrect Questions Review

#### Question 1
**Topic**: 
**Question**: 
**My Answer**: 
**Correct Answer**: 
**Explanation**: 
**Related Study Note**: [[]]

#### Question 2
**Topic**: 
**Question**: 
**My Answer**: 
**Correct Answer**: 
**Explanation**: 
**Related Study Note**: [[]]

#### Question 3
**Topic**: 
**Question**: 
**My Answer**: 
**Correct Answer**: 
**Explanation**: 
**Related Study Note**: [[]]

### Difficult Questions (Even if correct)

#### Question 1
**Topic**: 
**Why it was difficult**: 
**Key concept**: 
**Related Study Note**: [[]]

## Learning Insights

### New Concepts Discovered
- 
- 
- 

### Concepts to Review
- [ ] Topic 1 - [[Study Note Link]]
- [ ] Topic 2 - [[Study Note Link]]
- [ ] Topic 3 - [[Study Note Link]]

### Study Focus Areas
Based on this practice exam, focus on:
1. 
2. 
3. 

## Action Items

### Immediate Actions
- [ ] Review incorrect questions
- [ ] Create/update study notes for weak areas
- [ ] Practice hands-on labs for topics X, Y, Z
- [ ] Schedule next practice exam

### Study Plan Updates
- [ ] Adjust study schedule to focus on weak areas
- [ ] Add more practice questions for domain X
- [ ] Review specific documentation sections

## Progress Tracking

### Practice Exam History
```dataview
TABLE 
  exam_date as "Date",
  score as "Score",
  exam_source as "Source"
FROM "03_resources/01_certifications"
WHERE contains(tags, "practice-exam") AND cert_id = "<% certId %>"
SORT exam_date DESC
```

### Progress Over Time
- **First practice exam**: 
- **Current score**: <% score %>%
- **Improvement**: 
- **Target score**: 80%+

## Notes & Reflections

### What went well


### What needs improvement


### Confidence level
- [ ] Ready for actual exam
- [ ] Need more practice
- [ ] Need more study time

### Next steps


## Related Resources

### Study Materials for Weak Areas
- 
- 
- 

### Additional Practice Resources
- 
- 

## Exam Strategy Lessons

### Time Management
- 

### Question Approach
- 

### Exam Techniques
- 
