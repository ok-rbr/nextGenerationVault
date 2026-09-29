---
title: "htb_{{ machine_name }}"
id: "{{ id }}"
created: "{{ created }}"
tags: ["project", "security", "htb", "{{ os }}", "{{ difficulty }}"]
category: "project"
status: "in-progress"
related: []
concepts: []
aliases: []
target_ip: "{{ target_ip }}"
---

# 🧪 HTB: {{ machine_name }}

{{ inline_tags }}

---

## Enumeration

### Nmap

```bash
nmap -sC -sV -oA scan {{ target_ip }}
```

---

## Hypotheses

- possible entry:
- assumptions:

---

## Initial Access

- method:
- commands:

---

## PrivEsc

- findings:
- exploit:

---

## Root

- final step:

---

## Extracted Knowledge

- [[{{ extracted_note_1 }}]]
- [[{{ extracted_note_2 }}]]

---

## Mistakes

-

---

## What to improve

-
