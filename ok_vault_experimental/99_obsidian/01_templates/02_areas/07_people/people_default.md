<%*
// Lade Bibliothek
const lib = tp.user.lib;

try {
    // Prompt the user for person details
    const name = await lib.promptText(tp, "full name:");
    const firstName = name.split(" ")[0] || name; // Extract first name
    const lastName = name.split(" ").slice(1).join(" ") || ""; // Extract last name (if available)
    const role = await lib.promptText(tp, "role:");
    const organization = await lib.promptText(tp, "organization/company:");
    const email = await lib.promptText(tp, "email:");
    const phone = await lib.promptText(tp, "phone:");
    const relationship = await lib.promptText(tp, "relationship (colleague/customer/partner/other):");

    // Rename file and move it to the correct folder
    await lib.renameAndMove(tp, name, `/02_areas/07_people/${name}`);
} catch (error) {
    console.error("Error creating people template: ", error)
}
-%>---
title: <% name %>
created: <% lib.generateCreatedLegacy(tp) %>
tags:
  - person
  - people
  - <% relationship.toLowerCase() %>
category: people
role: <% role %>
organization: <% organization %>
email: <% email %>
phone: <% phone %>
relationship: <% relationship %>
---
# [[<% name %>]]

## profile summary
- **Full Name**: <% name %>
- **Role**: <% role %>
- **Organization**: <% organization %>
- **Relationship**: <% relationship %>
- **Contact**:
  - Email: <% email %>
  - Phone: <% phone %>

## notes

## projects & collaborations

```dataview
TABLE status, project
FROM #task
WHERE contains(related, "<% name %>")
SORT created desc
```

## meetings

```dataview
TABLE date, thema, summary
FROM #meeting
WHERE contains(attendees, "<% name %>")
SORT date desc
```

## communication log

### latest interactions
