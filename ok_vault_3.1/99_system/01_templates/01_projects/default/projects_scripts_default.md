---
title: "{{ title }}"
created: "{{ created }}"
location: "01_projects/{{ customer }}/{{ project }}/scripts"
tags:
  - script
  - automation
  - "{{ project_tag }}"
  - "{{ customer_tag }}"
category: script
project: "{{ project }}"
customer: "{{ customer }}"
language: "{{ language }}"
status: "{{ status }}"
---

# {{ title }}

## Script Information

- **Project**: [[{{ project }} Overview]]
- **Customer**: [[{{ customer }} Overview]]
- **Language**: {{ language }}
- **Status**: {{ status }}
- **Purpose**: {{ purpose }}

## Description

{{ description }}

## Usage

\\\{{ language }}
# Usage example
{{ usage_example }}
\\\

## Code

\\\{{ language }}
# {{ title }}
# Created: {{ created }}

{{ script_content }}
\\\

## Dependencies

-

## Notes

-

## Change Log

| Date | Author | Changes |
|------|--------|---------|
| {{ created_date }} | | Initial creation |
