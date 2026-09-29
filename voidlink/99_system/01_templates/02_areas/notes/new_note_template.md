---
title: "{{title}}"
description: "Basic note template for mid-term notes"
category: "note"
created: "{{created}}"
tags:
  - note
  - area
  - { { tags } }
area: "{{area}}"
status: active
---

# {{title}}

## Summary

## Content

## Related Notes

```dataview
LIST
FROM #note
WHERE contains(area, "{{area}}") AND file.name != "{{title}}"
SORT created desc
LIMIT 5
```

## Tasks

```tasks
not done
description includes {{title}}
```
