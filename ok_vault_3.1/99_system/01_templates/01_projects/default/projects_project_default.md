---
title: "{{ project_name }} Overview"
created: "{{ created }}"
location: "01_projects/{{ customer }}/{{ project_name }}"
tags:
  - "{{ project_tag }}"
  - "{{ customer_tag }}"
  - project
category: project
project_name: "{{ project_name }}"
order_number: "{{ order_number }}"
customer: "{{ customer }}"
technolgy: "{{ technology }}"
status: active
deadline: "{{ deadline }}"
description: "{{ description }}"
---

# [[{{ project_name }} Overview]]

## Project Information

- **Project Name**: {{ project_name }}
- **Order Number**: {{ order_number }}
- **Customer**: [[{{ customer }} Overview]]
- **Status**: active
- **Deadline**: {{ deadline }}
- **Description**: {{ description }}
- **Team**:
  -

---

## Associated Meetings

`dataview
TABLE date AS "Date", summary AS "Summary", attendees AS "Attendees"
FROM #meeting
WHERE contains(tags, "{{ project_tag }}") AND contains(tags, "project")
SORT date DESC
`

---

## Daily Logs

`dataview
TABLE date AS "Date", reflections AS "Reflections", goals AS "Goals"
FROM #daily
WHERE contains(tags, "{{ project_tag }}") AND contains(tags, "daily")
SORT date DESC
`

---

## Tasks

### Open Tasks

`dataview
TABLE task AS "Task", due_date AS "Due Date", assigned_to AS "Assigned To"
FROM #task
WHERE contains(tags, "{{ project_tag }}") AND status = "active"
SORT due_date ASC
`

### Completed Tasks

`dataview
TABLE task AS "Task", completed_date AS "Completed Date", assigned_to AS "Assigned To"
FROM #task
WHERE contains(tags, "{{ project_tag }}") AND status = "closed"
SORT completed_date DESC
`

---

## Notes and History

Add project-specific notes, updates, or history here.
