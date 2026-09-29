<%*
// Load library
const lib = tp.user.lib;

// Prompt for project metadata
const projectName = await lib.promptText(tp, "Project name:");
const customerName = await lib.promptText(tp, "Customer/Client name:");
const projectDescription = await lib.promptText(tp, "Project description:");
const startDate = await lib.promptText(tp, "Project start date (YYYYMMDD):");
const status = await lib.promptSuggester(
    tp,
    "Select project status:",
    ["Active", "Planning", "On Hold", "Completed", "Archived"],
    ["active", "planning", "on-hold", "completed", "archived"]
);

// Create the project slug and client tag
const projectSlug = lib.slugify(projectName);
const clientSlug = lib.slugify(customerName);

// Use project builder with language policy
const fm = lib.fmProject({
    name: projectName,
    client: customerName,
    due: "",
    extraTags: [`client/${clientSlug}`]
});
fm.status = status;

// Rename and move the file
await lib.renameAndMove(tp, projectSlug, `01_projects/${projectSlug}/${projectSlug}`);
-%>---
title: "<% projectName %>"
id: "<% fm.id %>"
created: "<% fm.created %>"
lang: "en"
tags: <% JSON.stringify(fm.tags) %>
category: "project"
status: "<% status %>"
client: "<% customerName %>"
due: ""
related: []
concepts: []
aliases: []
---

# [[<% projectName %>]]

## Project Information

**Client:** <% customerName %>
**Status:** <% status %>
**Start:** <% startDate %>

## Description

<% projectDescription %>

## Project Structure

This project includes the following default templates:
- **Meetings**: For meeting notes and agendas
- **Daily**: For daily stand-ups or check-ins
- **Notes**: For general project documentation
- **Tasks**: For tracking project tasks
- **Weekly**: For weekly review meetings

## Project Overview

### Active Tasks

```dataviewjs
dv.taskList(
    dv.pages('#<% projectName %>').file.tasks
        .where(t => !t.completed && t.text.includes('#<% projectName %>'))
);
```

### Recent Meetings

```dataviewjs
dv.table(
    ["Date", "Title", "Summary"],
    dv.pages('"01_projects/<% projectName %>/meetings"')
        .sort(p => p.file.ctime, 'desc')
        .limit(5)
        .map(p => [p.date, p.file.link, p.summary])
);
```

### Project Notes

```dataviewjs
dv.list(
    dv.pages('"01_projects/<% projectName %>/doc"')
        .sort(p => p.file.ctime, 'desc')
        .limit(10)
        .map(p => p.file.link)
);
```

## Next Steps

- [ ] Set up project folders
- [ ] Create initial project documentation
- [ ] Schedule kickoff meeting
