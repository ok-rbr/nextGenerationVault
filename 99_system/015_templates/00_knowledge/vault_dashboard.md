---
title: "{{ title }}"
aliases:
  - "{{ title }}"
id: "{{ id }}"
created: "{{ created }}"
updated: "{{ created }}"
lang: "en"
category: "index"
status: "active"
location: "00_knowledge"
tags:
  - "dashboard"
  - "vault"
---

# {{ title }}

Live view of the vault's health. The queries run in Obsidian (Dataview); in
Neovim, use the commands under [In Neovim](#in-neovim). `99_system/` is left out
everywhere: it holds templates and schemas, not notes.

## Notes per area

### PARA folders

```dataview
TABLE WITHOUT ID key AS "Folder", length(rows) AS "Notes"
FROM -"99_system"
GROUP BY split(file.path, "/")[0]
SORT key ASC
```

### Areas

```dataview
TABLE WITHOUT ID key AS "Area", length(rows) AS "Notes"
FROM "02_areas"
GROUP BY split(file.folder, "/")[1]
SORT length(rows) DESC
```

## Orphan notes

Notes no other note links to. Daily, weekly and monthly logs are reached by date,
not by link, and are left out.

```dataview
TABLE WITHOUT ID file.link AS "Note", file.folder AS "Folder"
FROM -"99_system" AND -"02_areas/life/logs"
WHERE length(file.inlinks) = 0 AND file.path != this.file.path
SORT file.folder ASC, file.name ASC
```

## Notes without tags

Only the frontmatter `tags` field counts, as in Neovim's tag queries.

```dataview
TABLE WITHOUT ID file.link AS "Note", category, file.folder AS "Folder"
FROM -"99_system"
WHERE (!tags OR length(tags) = 0) AND file.path != this.file.path
SORT file.folder ASC, file.name ASC
```

## Open tasks

### Checkboxes in project notes

```dataview
TASK
FROM "01_projects"
WHERE !completed
GROUP BY file.link
```

### Task notes

Notes tagged `task` whose status is not finished, the same notes
`:NoteQueryTasks` and the Taskwarrior sync work with.

```dataview
TABLE WITHOUT ID file.link AS "Task", project, status, priority, due
FROM #task
WHERE !contains(list("done", "completed", "closed", "archived", "deleted"), status)
SORT due ASC, project ASC
```

## Recently edited

```dataview
TABLE WITHOUT ID file.link AS "Note", file.folder AS "Folder", file.mtime AS "Modified"
FROM -"99_system"
WHERE file.path != this.file.path
SORT file.mtime DESC
LIMIT 10
```

## In Neovim

Neovim does not render Dataview. The same questions, answered there:

| Question          | Neovim                                                                      |
| ----------------- | --------------------------------------------------------------------------- |
| Open task notes   | `:NoteQueryTasks`, `:NoteQueryTasksPending`, `:NoteQueryTasksProject`       |
| Recently created  | `:NoteQueryRecent [days]`                                                   |
| Notes by tag      | `:NoteQueryTag <tag>`                                                       |
| Today at a glance | `:VoidDash` (`<leader>nD`)                                                  |
| Orphans, no tags  | `vault-agent validate inventory` (`orphan_notes.md`, `missing_metadata.md`) |

## Review

Once a week, as part of the weekly review (`:NoteWeekly`): link orphans from a
hub note or archive them, tag untagged notes, and close or reschedule stale
tasks.
