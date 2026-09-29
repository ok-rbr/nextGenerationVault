<%*
// Certification Knowledge Extraction Template
// Extracts abstracted knowledge from certification content into the knowledge base
const lib = tp.user.lib;

const concept = await lib.promptText(tp, "Main concept/topic:");
const certId = await lib.promptText(tp, "Source certification (e.g., AZ-900):");
const knowledgeType = await lib.promptSuggester(tp, "Knowledge type:", 
    ["Atomic (single concept)", "Permanent (comprehensive)", "Literature (reference)"],
    ["atomic", "permanent", "literature"]);
const concepts = await lib.promptText(tp, "Key concepts (comma-separated):");
const related = await lib.promptText(tp, "Related notes (comma-separated):");

// Create slug
const titleSlug = lib.slugify(concept);

// Build frontmatter based on knowledge type
const fm = lib.fmKnowledge({
    title: concept,
    type: knowledgeType,
    extraTags: ["from-certification", lib.slugify(certId)]
});

// Parse concepts and related items
const conceptsList = lib.processTags(concepts);
const relatedList = lib.parseRelatedItems(related);
fm.concepts = conceptsList;
fm.related = relatedList;
fm.source_cert = certId.toUpperCase();

// Move to knowledge base based on type
let targetFolder = "/00_knowledge/03_permanent";
if (knowledgeType === "atomic") {
    targetFolder = "/00_knowledge/01_atomic";
} else if (knowledgeType === "literature") {
    targetFolder = "/00_knowledge/02_literature";
}

await lib.renameAndMove(tp, titleSlug, `${targetFolder}/${titleSlug}`);
-%>---
title: "<% concept %>"
id: "<% fm.id %>"
created: "<% fm.created %>"
lang: "en"
tags: <% JSON.stringify(fm.tags) %>
category: "knowledge"
status: "completed"
source_cert: "<% fm.source_cert %>"
related: <% JSON.stringify(fm.related) %>
concepts: <% JSON.stringify(fm.concepts) %>
aliases: []
---
# [[<% concept %>]]

> [!info] Knowledge Extracted from Certification
> **Source**: <% certId %> Certification Study
> **Type**: <% knowledgeType.charAt(0).toUpperCase() + knowledgeType.slice(1) %> Note
> **Created**: <% fm.created %>

## Summary

A concise summary of the core concept in your own words.


## Key Concepts

<% concepts %>

## Detailed Explanation

### What is it?


### Why is it important?


### How does it work?


## Technical Details

### Architecture/Components


### Implementation


### Configuration


## Practical Applications

### Use Cases
1. 
2. 
3. 

### Real-world Examples
- **Example 1**: 
- **Example 2**: 
- **Example 3**: 

### When to Use
- ✅ 
- ✅ 

### When NOT to Use
- ❌ 
- ❌ 

## Best Practices

### Recommendations
1. 
2. 
3. 

### Common Pitfalls
- ⚠️ 
- ⚠️ 

### Security Considerations
- 🔒 
- 🔒 

## Relationships & Context

### Prerequisites
- 
- 

### Related Concepts
<% lib.createRelatedLinks(related) %>

### Builds Upon
- 
- 

### Enables
- 
- 

## Mental Model

### Simple Explanation (ELI5)


### Analogy


### Visual Representation
```
[Diagram or flowchart placeholder]
```

## Code Examples

### Example 1: Basic Usage
```python
# Example code

```

### Example 2: Advanced Usage
```python
# Advanced example

```

## Differences & Comparisons

### vs Similar Concept A
| Aspect | This Concept | Similar Concept A |
|--------|--------------|-------------------|
|        |              |                   |

### vs Similar Concept B
| Aspect | This Concept | Similar Concept B |
|--------|--------------|-------------------|
|        |              |                   |

## Further Learning

### Official Documentation
- 

### Deep Dive Resources
- 

### Hands-on Practice
- 

### Related Certifications
- <% certId %>
- 

## Questions & Open Topics

### Questions for Further Research
- ❓ 
- ❓ 

### Advanced Topics
- 
- 

### Edge Cases
- 
- 

## Review & Updates

### Last Reviewed
- 

### Changes/Updates Log
- <% fm.created %>: Initial extraction from <% certId %> study

### Confidence Level
- [ ] Basic understanding
- [ ] Can explain to others
- [ ] Can implement/apply
- [ ] Expert level

## Source References

### Certification Study Materials
- **Certification**: <% certId %>
- **Study Note**: [[]]
- **Module/Section**: 

### Additional Sources
- 
- 

## Tags & Metadata

**Concepts**: <% concepts %>
**Source Certification**: <% certId %>
**Knowledge Type**: <% knowledgeType %>

---

## Related Knowledge Notes
```dataview
TABLE 
  concepts as "Concepts",
  source_cert as "Source Cert",
  file.mtime as "Modified"
FROM "00_knowledge"
WHERE contains(tags, "from-certification") AND file.name != this.file.name
SORT file.mtime DESC
LIMIT 10
```

## Back to Certification
- [[<% certId %>]]
