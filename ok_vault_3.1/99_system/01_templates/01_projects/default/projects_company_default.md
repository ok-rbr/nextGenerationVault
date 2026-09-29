<%*
    try {
        console.log("Start: Script execution");

        var companyName = await tp.system.prompt("company name:");
        console.log("Company Name:", companyName);

        var companyTag = await tp.system.prompt("company tag:");
        console.log("Company Tag:", companyTag);

        var industry = await tp.system.prompt("industry:");
        console.log("Industry:", industry);

        var website = await tp.system.prompt("enter website URL (optional):");
        console.log("Website:", website);

        var status = await tp.system.prompt("status (active/inactive/prospect):", "active");
        console.log("Status:", status);

        var fileName = companyName + " Overview";
        await tp.file.rename(fileName);
        console.log("File renamed to:", fileName);

        // Ordner erstellen und Datei verschieben
        var folderPath = "01_project/" + companyName + "/";
        console.log("Target folder:", folderPath);

        await tp.file.move(folderPath + fileName);
        console.log("File moved to:", folderPath + fileName);
    } catch (e) {
        console.error("Error during script execution:", e);
    }
-%>---
title: "<% companyName %> Overview"
created: "<% tp.date.now('YYYYMMDD - HHmm') %>"
tags:
  - <% companyName.toLowerCase().replace(" ", "-") %>
  - <% companyTag.replace(" ", "-") %>
  - company
category: company
company_name: "<% companyName %>"
industry: "<% industry %>"
website: "<% website || '' %>"
status: "<% status %>"
location: "<% location %>"
---
# [[<% companyName %> Overview]]

## company information

- **Company Name**: <% companyName %>
- **Industry**: <% industry || "Not specified" %>
- **Website**: <% website ? `[Visit Website](${website})` : "Not specified" %>
- **Status**: <% status %>

## associated projects

### active
```dataview
TABLE project_name AS "Project", status AS "Status"
FROM "01_projects"
WHERE
    contains(tags, "<% companyTag.replace(' ', '-') %>") AND
    !contains(tags, "company") AND
    contains(status, "active")  
SORT deadline ASC
````

### completed

```dataview
TABLE project_name AS "Project", status AS "Status"
FROM "01_projects"
WHERE
    contains(tags, "<% companyTag.replace(' ', '-') %>") AND
    !contains(tags, "company") AND
    contains(status, "completed")
SORT completed_date DESC
```

## associated people

```dataview
TABLE name AS "Name", role AS "Role", email AS "Email"
FROM "03_people"
WHERE
    contains(tags, "<% companyTag.replace(' ', '-') %>")
SORT name ASC
```
