<%*
// Lade Bibliothek
const lib = tp.user.lib;

try {
    // Prompt the user for contact details
    const name = await lib.promptText(tp, "full name:");
    const firstName = name.split(" ")[0] || name; // Extract first name
    const lastName = name.split(" ").slice(1).join(" ") || ""; // Extract last name (if available)
    const title = await lib.promptText(tp, "title/position:");
    const company = await lib.promptText(tp, "company:");
    const email = await lib.promptText(tp, "email:");
    const phone = await lib.promptText(tp, "phone:");
    const linkedin = await lib.promptText(tp, "linkedin URL:");
    const contactType = await lib.promptText(tp, "contact type (client/vendor/partner/network):");

    // Rename file and move it to the correct folder
    await lib.renameAndMove(tp, name, `/02_areas/08_people/${name}`);
} catch (error) {
    console.error("Error creating people contact template: ", error)
}
-%>---
title: <% name %>
created: <% lib.generateCreatedLegacy(tp) %>
tags:
  - person
  - contact
  - <% contactType.toLowerCase() %>
category: people
position: <% title %>
company: <% company %>
email: <% email %>
phone: <% phone %>
linkedin: <% linkedin %>
contact_type: <% contactType %>
---
# [[<% name %>]]

## contact information
- **Name**: <% name %>
- **Title**: <% title %>
- **Company**: <% company %>
- **Type**: <% contactType %>
- **Email**: <% email %>
- **Phone**: <% phone %>
- **LinkedIn**: <% linkedin %>

## background & context

## areas of interest

## projects & engagements

```dataview
TABLE status, area, created
FROM #task OR #note
WHERE contains(related, "<% name %>") OR contains(attendees, "<% name %>")
SORT created desc
```

## meeting history

```dataview
TABLE date, thema, summary
FROM #meeting
WHERE contains(attendees, "<% name %>")
SORT date desc
```

## action items

```tasks
not done
description includes <% name %>
```

## notes & observations
