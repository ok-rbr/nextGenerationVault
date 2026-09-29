<%*
// Lade Bibliothek
const lib = tp.user.lib;

try {
    // Prompt for meeting details
    const title = await lib.promptTitle(tp, "meeting name:");
    const date = await lib.promptText(tp, "meeting date (YYYYMM-D):");

    // Move the file to the appropriate folder
    await lib.safeMove(tp, `02_areas/04_meetings/${date}_${title}`);
} catch (error) {
    console.error("Error creating meeting note: ", error)
}
-%>---
title: "<% title %>"         
created: <% lib.generateCreatedLegacy(tp) %>
tags: ["meeting"]
category: "meeting"
thema: ""
summary: ""
attendees: []               
date: "<% date %>"                        
---
# [[<% date + "_" + title %>]]

## agenda
- 

## log
- 

## action items
