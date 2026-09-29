<%*
try {
    // Prompt the user for colleague details
    var name = await tp.system.prompt("full name:")
    var firstName = name.split(" ")[0] || name; // Extract first name
    var lastName = name.split(" ").slice(1).join(" ") || ""; // Extract last name (if available)
    var role = await tp.system.prompt("role:")
    var department = await tp.system.prompt("department:")
    var email = await tp.system.prompt("email:")
    var phone = await tp.system.prompt("phone:")
    var location = await tp.system.prompt("location:")
    var startDate = await tp.system.prompt("start date (YYYYMMDD):")

    // Rename file and move it to the correct folder
    await tp.file.rename(name)
    await tp.file.move("/02_people/00_colleagues/" + name)
} catch (error) {
    console.error("Error creating colleague template: ", error)
}
-%>---
title: <% name %>
created: <% tp.date.now("YYYYMMDD -HHmm") %>
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
