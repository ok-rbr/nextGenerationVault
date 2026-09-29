---
id: 20260624_1810
aliases:
  - Meeting Ingestion Workflow
  - Audio To Vault Workflow
tags:
  - system/ai
  - workflow/meeting
  - workflow/local-ai
  - obsidian/inbox
category: knowledge
concepts:
  - meeting-processing
  - whisper
  - qwen
  - obsidian
  - inbox
created: 2026-06-24 18:10
related:
  - 99_system/05_ai/ai_operating_rules.md
  - 99_system/05_ai/vault_ai_boundaries.md
status: active
title: meeting_ingestion_workflow
---

# meeting_ingestion_workflow

## purpose

This document defines the local workflow for turning meeting audio into structured Obsidian notes.

The workflow connects:

```text
audio recording
-> local transcription
-> inbox note
-> local ai analysis
-> human review
-> vault integration
````

The process must be local-first, reviewable, and compatible with the vault structure.

## target outcome

Each processed meeting should produce one structured inbox note containing:

* metadata
* context
* transcript
* AI summary
* decisions
* action items
* open questions
* risks
* link suggestions
* candidate atomic notes
* processing log

The meeting note starts in:

```text
00_knowledge/00_inbox/meetings/
```

Only after review should information be moved or linked into:

```text
01_projects/
02_areas/
03_resources/
00_knowledge/01_atomic/
00_knowledge/03_permanent/
```

## workflow stages

## 1. capture

Input:

```text
audio file
```

Examples:

```text
meeting.m4a
meeting.wav
meeting.mp3
```

Rules:

* keep original audio until the transcript was reviewed
* do not overwrite source audio
* use local storage only
* do not upload audio externally

Suggested file name:

```text
YYYYMMDD_HHMM_meeting_slug.audio_extension
```

Example:

```text
20260624_1430_lomd_auth_sync.m4a
```

## 2. transcribe

Tool:

```text
whisper-cli
```

Output:

```text
transcript text
```

Rules:

* transcript is raw source material
* transcript must not be edited silently
* cleanup may happen in a separate section
* original transcript should remain available

Suggested transcript section:

```markdown
## raw transcript
```

Optional cleaned section:

```markdown
## cleaned transcript
```

## 3. create inbox note

Default target path:

```text
00_knowledge/00_inbox/meetings/YYYYMMDD_HHMM_meeting_slug.md
```

Required frontmatter:

```yaml
---
title: "meeting_slug"
id: "YYYYMMDD_HHMM"
created: "YYYY-MM-DD HH:mm"
tags: ["meeting/inbox"]
category: "knowledge"
type: "meeting"
status: "transcribed"
source: "audio"
audio_file: ""
transcript_source: "whisper"
projects: []
people: []
related: []
concepts: []
aliases: []
---
```

Rules:

* `status` starts as `raw` or `transcribed`
* `projects` may remain empty until analysis
* `people` may remain empty until review
* do not create people notes automatically
* do not create project notes automatically

## 4. analyze with local ai

Preferred model:

```text
qwen3:30b
```

Fallback model:

```text
qwen3:14b
```

AI analysis should produce these sections:

```markdown
## ai summary

## decisions

## action items

## open questions

## risks

## link suggestions

## candidate atomic notes

## suggested destination

## processing log
```

Rules:

* use only local models by default
* do not send transcript to external APIs
* do not modify existing notes
* do not move the meeting note automatically
* link suggestions must include reasons

## 5. review

Human review is required before integration.

Checklist:

* [ ] Transcript is usable
* [ ] Summary is accurate
* [ ] Decisions are correct
* [ ] Action items are explicit
* [ ] Owners are correct
* [ ] Due dates are correct
* [ ] Sensitive information is removed or contained
* [ ] Link suggestions are useful
* [ ] Candidate atomic notes are worth creating
* [ ] Target project/area/resource is clear

After review, set:

```yaml
status: "review-needed"
```

or, if complete:

```yaml
status: "integrated"
```

## 6. integrate

Integration means moving knowledge from the inbox note into the right vault locations.

Possible destinations:

```text
01_projects/<project>/
02_areas/<area>/
03_resources/<resource>/
00_knowledge/01_atomic/
00_knowledge/03_permanent/
```

Rules:

* meeting note may remain in inbox until fully processed
* only durable insights become permanent notes
* small reusable concepts become atomic notes
* project-specific work goes into project folders
* general reference material goes into resources
* recurring responsibility topics go into areas

## meeting note template

Use this as the initial structure for new meeting notes:

```markdown
---
title: "meeting_slug"
id: "YYYYMMDD_HHMM"
created: "YYYY-MM-DD HH:mm"
tags: ["meeting/inbox"]
category: "knowledge"
type: "meeting"
status: "raw"
source: "audio"
audio_file: ""
transcript_source: ""
projects: []
people: []
related: []
concepts: []
aliases: []
---

# meeting_slug

## context

- date:
- source:
- project:
- participants:
- purpose:

## raw transcript

## cleaned transcript

## ai summary

## decisions

## action items

- [ ]
  - owner:
  - due:
  - related:
  - source:

## open questions

## risks

## link suggestions

- suggested link:
  - reason:
  - confidence:

## candidate atomic notes

- title:
  - core idea:
  - source:
  - suggested tags:
  - suggested links:
  - confidence:

## suggested destination

- project:
- area:
- resource:
- knowledge:
- archive:

## processing log

- captured:
- transcribed:
- analyzed:
- reviewed:
- integrated:
```

## action item rules

Every action item should answer:

```text
what?
who?
until when?
related to what?
source?
```

Preferred format:

```markdown
- [ ] clarify redirect URI handling for SWA preview environments
  - owner: Raphael
  - due:
  - related: [[azure_static_web_apps_preview_environments]]
  - source: [[20260624_1430_lomd_auth_sync]]
```

If owner is unknown:

```markdown
- [ ] clarify deployment responsibility
  - owner: unknown
  - due:
  - related:
  - source:
```

## decision format

```markdown
- decision:
  - reason:
  - impact:
  - source:
```

Example:

```markdown
- decision: Use local transcription before AI analysis.
  - reason: Keeps meeting audio private and reviewable.
  - impact: Adds one manual review step before vault integration.
  - source: [[20260624_1430_lomd_auth_sync]]
```

## link suggestion rules

AI must not assume links are correct.

Use:

```markdown
- suggested link: [[note_name]]
  - reason:
  - confidence: low|medium|high
```

## candidate atomic note rules

Create candidate atomic notes only for reusable concepts.

Good candidates:

```text
authentication flow
deployment pattern
debugging method
project decision
architecture principle
workflow rule
tooling convention
```

Bad candidates:

```text
one-time task
temporary meeting detail
private comment
raw transcript fragment
unclear thought
```

## status transitions

```text
raw
-> transcribed
-> analyzed
-> review-needed
-> integrated
```

Optional:

```text
archived
```

## minimal first implementation

The first implementation should only do this:

```text
1. accept audio file
2. transcribe locally
3. create meeting note in inbox
4. append transcript
5. run local ai analysis
6. append ai sections
7. set status to review-needed
```

No automatic moving, deleting, or editing of existing vault notes.

## future automation ideas

Potential future commands:

```bash
vault-meeting-new <audio-file> <meeting-title>
vault-meeting-transcribe <meeting-note>
vault-meeting-analyze <meeting-note>
vault-meeting-review <meeting-note>
vault-meeting-integrate <meeting-note>
```

These commands should follow the boundaries defined in:

```text
99_system/05_ai/ai_operating_rules.md
99_system/05_ai/vault_ai_boundaries.md
```
