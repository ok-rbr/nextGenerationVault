<%*
const lib = tp.user.lib || {};

// Prompt for resource details
const resourceName = await tp.system.prompt("Resource name:");
const resourceType = await tp.system.suggester(
    ["Tool/Software", "Book", "Article/Blog", "Course", "Framework/Library", "Method/Practice", "Template", "Reference Documentation"],
    ["tool", "book", "article", "course", "framework", "method", "template", "documentation"],
    false,
    "Select resource type:"
);

const resourceSlug = lib.slugify ? lib.slugify(resourceName) : resourceName.toLowerCase().replace(/\s+/g, '_');
const title = `resource_${resourceSlug}`;

await tp.file.rename(title);
await tp.file.move(`/03_resources/01_tools/${title}`);
-%>---
title: "resource - <%= resourceName %>"
id: "<%= lib.nowId ? lib.nowId() : tp.date.now('YYYYMMDD_HHmm') %>"
created: "<%= lib.nowIso ? lib.nowIso() : tp.date.now('YYYY-MM-DD HH:mm') %>"
lang: "en"
tags:
  - "resource"
  - "resource/<%= resourceType %>"
category: "resource"
status: "active"
resource_type: "<%= resourceType %>"
resource_name: "<%= resourceName %>"
rating: ""
difficulty: ""
cost: ""
last_used: ""
---

# 📚 Resource - <%= resourceName %>

**Type**: <%= resourceType %>  
**Category**: `<%= resourceType %>`

---

## 📋 Overview

### Description
> Brief description of what this resource is

### Primary Use Case
> What is this resource mainly used for?

### Target Audience
> Who should use this resource?

---

## ⭐ Rating & Assessment

### Overall Rating
**Rating**: ☐ ★★★★★ (5/5) ☐ ★★★★☆ (4/5) ☐ ★★★☆☆ (3/5) ☐ ★★☆☆☆ (2/5) ☐ ★☆☆☆☆ (1/5)

### Criteria Ratings

| Criterion | Rating | Notes |
|-----------|--------|-------|
| **Ease of Use** | /5 | |
| **Documentation Quality** | /5 | |
| **Performance** | /5 | |
| **Community Support** | /5 | |
| **Value for Money** | /5 | |
| **Learning Curve** | /5 | |

### Difficulty Level
**Level**: ☐ Beginner ☐ Intermediate ☐ Advanced ☐ Expert

---

## 💰 Cost & Licensing

### Pricing
- **Cost**: 
- **Pricing Model**: ☐ Free ☐ Freemium ☐ Subscription ☐ One-time purchase ☐ Enterprise
- **Personal Cost**: 
- **Team Cost**: 

### License
- **License Type**: 
- **Restrictions**: 
- **Commercial Use**: ☐ Allowed ☐ Restricted ☐ Not allowed

---

## 🔗 Links & Access

### Official Links
- **Website**: 
- **Documentation**: 
- **Repository**: 
- **Community**: 

### Access Information
- **Access URL**: 
- **Account**: 
- **Installation**: 

---

## 🎯 Application Context

### When to Use
> Specific situations where this resource is ideal

1. 
2. 
3. 

### When NOT to Use
> Situations where alternatives might be better

1. 
2. 

### Use Cases

#### Primary Use Cases
1. **Use Case**: 
   - **Context**: 
   - **Benefit**: 

2. **Use Case**: 
   - **Context**: 
   - **Benefit**: 

#### Secondary Use Cases
- 
- 

---

## ✅ Pros & Cons

### Advantages
- ✅ 
- ✅ 
- ✅ 

### Disadvantages
- ❌ 
- ❌ 
- ❌ 

### Unique Features
> What makes this resource stand out?

- 
- 

---

## 📚 Learning Resources

### Getting Started
- **Official Tutorial**: 
- **Quick Start Guide**: 
- **Video Tutorials**: 

### Advanced Resources
- **Advanced Guides**: 
- **Best Practices**: 
- **Case Studies**: 

### Learning Time
- **Basic Proficiency**: 
- **Advanced Proficiency**: 
- **Mastery**: 

---

## 🔄 Alternatives & Comparisons

### Similar Resources

| Resource | Pros vs This | Cons vs This | When to Choose |
|----------|--------------|--------------|----------------|
| | | | |
| | | | |

### Why I Chose This
> Reasoning for selecting this over alternatives

- 

---

## 💼 Project Usage

### Projects Using This Resource

```dataview
TABLE status, client, file.ctime as "Started"
FROM "01_projects"
WHERE contains(file.outlinks, this.file.link)
SORT file.ctime DESC
```

### Usage Frequency
**Last Used**: 
**Frequency**: ☐ Daily ☐ Weekly ☐ Monthly ☐ Occasionally ☐ Rarely

---

## 📖 Notes & Tips

### Key Concepts
> Important concepts to understand

- 
- 

### Best Practices
> Recommended approaches when using this resource

1. 
2. 
3. 

### Common Pitfalls
> Mistakes to avoid

1. 
2. 

### Tips & Tricks
> Useful shortcuts or hidden features

- 
- 

---

## 🔧 Technical Details

### Requirements
- **System Requirements**: 
- **Dependencies**: 
- **Prerequisites**: 

### Integration
- **Integrates With**: 
- **APIs Available**: ☐ Yes ☐ No
- **Extensibility**: 

### Version Information
- **Current Version**: 
- **Version Used**: 
- **Update Frequency**: 
- **Breaking Changes**: 

---

## 📊 Performance & Scalability

### Performance
- **Speed**: 
- **Resource Usage**: 
- **Scalability**: 

### Limitations
- 
- 

---

## 🎓 My Experience

### First Impression
> Initial thoughts when first using

### Learning Curve
> How difficult was it to learn?

### Productivity Impact
> How has this affected my workflow?

### Would I Recommend?
**Recommendation**: ☐ Highly Recommend ☐ Recommend ☐ Neutral ☐ Not Recommend

**Reasoning**: 

---

## 📝 Usage Log

### Recent Usage

| Date | Project/Context | Notes |
|------|----------------|-------|
| | | |
| | | |

### Key Milestones
- **First used**: 
- **Became proficient**: 
- **Last major use**: 

---

## 🔄 Maintenance & Updates

### Update Strategy
- **Check for updates**: ☐ Automatically ☐ Monthly ☐ As needed
- **Update notes**: 

### Deprecation Risk
**Risk Level**: ☐ Low ☐ Medium ☐ High  
**Reasoning**: 

### Alternatives if Discontinued
- 
- 

---

## 🔗 Related Resources

### Complementary Resources
> Resources that work well together with this

- [[resource_name_1]] - 
- [[resource_name_2]] - 

### Related Knowledge
> Permanent notes related to this resource

```dataview
LIST
FROM "00_knowledge"
WHERE contains(file.outlinks, this.file.link)
SORT file.mtime DESC
LIMIT 10
```

---

## 📋 Review Checklist

- [ ] Basic information filled
- [ ] Rating completed
- [ ] Pros/cons documented
- [ ] Use cases defined
- [ ] Alternatives researched
- [ ] Learning resources added
- [ ] Best practices documented
- [ ] Personal experience recorded

**Next Review**: 
**Review Frequency**: ☐ Quarterly ☐ Bi-annually ☐ Annually

---

## 💡 Quick Notes

*Space for additional thoughts or updates*

- 
- 

---

**Created**: <%= tp.date.now('YYYY-MM-DD') %>  
**Last Updated**: <%= tp.date.now('YYYY-MM-DD') %>  
**Status**: Active
