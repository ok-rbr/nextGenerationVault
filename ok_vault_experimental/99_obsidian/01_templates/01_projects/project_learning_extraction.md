<%*
const lib = tp.user.lib || {};

// Prompt for project name
const projectName = await tp.system.prompt("Project name to extract learnings from:");
const projectSlug = lib.slugify ? lib.slugify(projectName) : projectName.toLowerCase().replace(/\s+/g, '_');

const title = `learnings_${projectSlug}`;

await tp.file.rename(title);
await tp.file.move(`/00_knowledge/00_inbox/${title}`);
-%>---
title: "learnings - <%= projectName %>"
id: "<%= lib.nowId ? lib.nowId() : tp.date.now('YYYYMMDD_HHmm') %>"
created: "<%= lib.nowIso ? lib.nowIso() : tp.date.now('YYYY-MM-DD HH:mm') %>"
lang: "en"
tags:
  - "learning"
  - "knowledge"
  - "project/<%= projectSlug %>"
category: "knowledge"
status: "unprocessed"
priority: "high"
source: "project - <%= projectName %>"
project: "<%= projectName %>"
---

# Learnings Extraction - <%= projectName %>

**Project**: [[01_projects/<%= projectSlug %>/00_index|<%= projectName %>]]  
**Extraction Date**: <%= tp.date.now('YYYY-MM-DD') %>

---

## 📋 Project Context

### Project Summary
> Brief description of what the project was about

- **Goal**: 
- **Duration**: 
- **Status**: 
- **Outcome**: 

### Key Stakeholders
- 
- 

---

## 🎯 What Did I Learn?

### Technical Learnings

#### New Technologies/Tools
> What new tools or technologies did I work with?

1. **[Technology/Tool Name]**
   - What: 
   - Why useful: 
   - Key insights: 
   - Would use again: ☐ Yes ☐ No

2. **[Technology/Tool Name]**
   - What: 
   - Why useful: 
   - Key insights: 
   - Would use again: ☐ Yes ☐ No

#### Technical Patterns/Approaches
> What technical patterns or approaches proved valuable?

- 
- 

#### Technical Challenges Solved
> What technical problems did I solve?

- **Challenge**: 
  - **Solution**: 
  - **Learning**: 

---

### Process & Methodology Learnings

#### What Worked Well
> Process improvements or practices that were successful

- 
- 

#### What Didn't Work
> Approaches that failed or were inefficient

- 
- 
- **Why it failed**: 
- **Alternative approach**: 

#### Workflow Improvements
> How could similar projects be done more efficiently?

- 
- 

---

### Soft Skills & Communication

#### Collaboration Insights
> What did I learn about working with others?

- 

#### Communication Patterns
> What communication strategies worked or didn't work?

- 

#### Stakeholder Management
> Insights on managing stakeholder expectations

- 

---

## 🔍 Deep Insights

### Key Discoveries
> Most important insights from this project

1. 
2. 
3. 

### Assumptions Validated
> Which assumptions turned out to be correct?

- 

### Assumptions Invalidated
> Which assumptions were wrong?

- 
- **Impact**: 

### Unexpected Findings
> Surprises or unexpected outcomes

- 

---

## 📚 Knowledge to Extract

### Concepts to Create Permanent Notes For

- [ ] **Concept 1**: [Brief description]
  - Target location: `00_knowledge/03_permanent/`
  - Related to: 

- [ ] **Concept 2**: [Brief description]
  - Target location: `00_knowledge/03_permanent/`
  - Related to: 

- [ ] **Concept 3**: [Brief description]
  - Target location: `00_knowledge/03_permanent/`
  - Related to: 

### Documentation to Create/Update

- [ ] Update [[03_resources/00_index|Resources]] with tools used
- [ ] Create method documentation for successful approaches
- [ ] Update best practices guides

---

## ⚠️ Mistakes & How to Avoid Them

### Critical Mistakes
> Significant errors that had impact

1. **Mistake**: 
   - **Impact**: 
   - **Root cause**: 
   - **Prevention**: 

2. **Mistake**: 
   - **Impact**: 
   - **Root cause**: 
   - **Prevention**: 

### Minor Issues
> Small problems that could be optimized

- 
- 

---

## 🎯 Best Practices Identified

### Recommended Approaches

1. **Practice**: 
   - **Context**: When to use
   - **Benefit**: 
   - **Implementation**: 

2. **Practice**: 
   - **Context**: When to use
   - **Benefit**: 
   - **Implementation**: 

### Anti-Patterns to Avoid

- **Anti-pattern**: 
  - **Why problematic**: 
  - **Better alternative**: 

---

## 🔄 Next Steps

### Knowledge Transfer Actions

- [ ] Create permanent notes for key concepts (see checklist above)
- [ ] Update resource database with new tools
- [ ] Document best practices in [[03_resources/]]
- [ ] Share learnings with team (if applicable)

### Application to Future Projects

**Projects that could benefit from these learnings**:
- 
- 

### Follow-up Research

**Topics to explore further**:
- [ ] 
- [ ] 

---

## 🔗 Related Resources

### Internal Links
- Project: [[01_projects/<%= projectSlug %>/00_index]]
- Related meetings: 

```dataview
LIST
FROM #meeting
WHERE contains(project, "<%= projectName %>")
SORT date DESC
```

### External Resources
- 
- 

---

## 📝 Processing Checklist

- [ ] Filled out all sections thoroughly
- [ ] Identified key concepts for permanent notes
- [ ] Listed technical learnings
- [ ] Documented mistakes and preventions
- [ ] Created best practices list
- [ ] Linked to related notes
- [ ] Ready to create permanent notes

**Next Action**: Create permanent notes for each key concept identified above

---

## 💡 Quick Capture

*Use this space for quick thoughts that come up during extraction*

- 
- 

---

**Extraction Completed**: ☐  
**Permanent Notes Created**: ☐  
**Resources Updated**: ☐  
**Status**: Ready to process → [[00_knowledge/03_permanent/]]
