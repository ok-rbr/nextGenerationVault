<%*
    // Prompt the user for colleague details
    var name = await tp.system.prompt("full name:")
    var firstName = name.split(" ")[0] || name; // Extract first name
    var lastName = name.split(" ").slice(1).join(" ") || ""; // Extract last name (if available)
    var role = await tp.system.prompt("role:")
    var company = await tp.system.prompt("company:")
    var email = await tp.system.prompt("email:")
    var phone = await tp.system.prompt("phone:")
    var location = await tp.system.prompt("location:")
    var startDate = await tp.system.prompt("start date (YYYYMMDD):")

    // Rename file and move it to the correct folder
    await tp.file.rename(name)
    await tp.file.move("/02_areas/07_people/01_customer/" + name)

-%>---
title: <% name %>
created: <% tp.date.now("YYYYMMDD -HHmm") %>
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
