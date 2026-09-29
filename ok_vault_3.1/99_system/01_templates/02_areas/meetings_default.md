<%*
try {
    // Prompt for meeting details
    if (tp.file.title == "Untitled" || tp.file.title == "Unbenannt") {
        var title = await tp.system.prompt("meeting name:")
        var date = await tp.system.prompt("meeting date (YYYYMM-D):")
    }

    // Move the file to the appropriate folder
    await tp.file.move("02_areas/04_meetings/" + date + "_" + title)
} catch (error) {
    console.error("Error creating meeting note: ", error)
}
-%>---
title: "<% title %>"  
created: <% tp.date.now("YYYYMMDD - HHmm") %>
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
