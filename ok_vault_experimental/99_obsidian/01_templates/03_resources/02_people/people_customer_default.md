<%*
// Lade Bibliothek
const lib = tp.user.lib;

// Prompt the user for colleague details
const name = await lib.promptText(tp, "full name:");
const firstName = name.split(" ")[0] || name; // Extract first name
const lastName = name.split(" ").slice(1).join(" ") || ""; // Extract last name (if available)
const role = await lib.promptText(tp, "role:");
const company = await lib.promptText(tp, "company:");
const email = await lib.promptText(tp, "email:");
const phone = await lib.promptText(tp, "phone:");
const location = await lib.promptText(tp, "location:");
const startDate = await lib.promptText(tp, "start date (YYYYMMDD):");

// Rename file and move it to the correct folder
await lib.renameAndMove(tp, name, `/02_areas/07_people/01_customer/${name}`);

-%>---
title: <% name %>
created: <% lib.generateCreatedLegacy(tp) %>
tags:
  - person
  - colleague
category: people
role: <% role %>
company: <% company %>
email: <% email %>
phone: <% phone %>
location: <% location %>
start_date: <% startDate %>
---
## Profile Summary
- **Full Name**: <% name %>
- **Role**: <% role %>
- **Location**: <% location %>
- **Start Date**: <% startDate %>
- **Contact**:
  - Email: <% email %>
  - Phone: <% phone %>

## Projects

- [ ] 


## Meeting Log
```dataview
TABLE date, thema, summary
FROM "meetings"
WHERE contains(attendees, "<% name %>")
SORT date desc
````
