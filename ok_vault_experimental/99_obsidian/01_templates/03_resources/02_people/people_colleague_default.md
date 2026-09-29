<%*
// Lade Bibliothek
const lib = tp.user.lib;

try {
    // Prompt the user for colleague details
    const name = await lib.promptText(tp, "full name:");
    const firstName = name.split(" ")[0] || name; // Extract first name
    const lastName = name.split(" ").slice(1).join(" ") || ""; // Extract last name (if available)
    const role = await lib.promptText(tp, "role:");
    const department = await lib.promptText(tp, "department:");
    const email = await lib.promptText(tp, "email:");
    const phone = await lib.promptText(tp, "phone:");
    const location = await lib.promptText(tp, "location:");
    const startDate = await lib.promptText(tp, "start date (YYYYMMDD):");

    // Rename file and move it to the correct folder
    await lib.renameAndMove(tp, name, `/02_people/00_colleagues/${name}`);
} catch (error) {
    console.error("Error creating colleague template: ", error)
}
-%>---
title: <% name %>
created: <% lib.generateCreatedLegacy(tp) %>
tags:
  - person
  - colleague
  - <%- department.toLowerCase() %>  
category: people
role: <% role %>
department: <% department %>
email: <% email %>
phone: <% phone %>
location: <% location %>
start_date: <% startDate %>
---
## Profile Summary
- **Full Name**: <% name %>
- **Role**: <% role %>
- **Department**: <% department %>
- **Location**: <% location %>
- **Start Date**: <% startDate %>
- **Contact**:
  - Email: <% email %>
  - Phone: <% phone %>

## Projects



## Meeting Log
```dataview
TABLE date, thema, summary
FROM #meeting
WHERE contains(attendees, "<% name %>")
SORT date desc
````

