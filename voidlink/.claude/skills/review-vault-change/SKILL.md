---
name: review-vault-change
description: Turn a requested change to vault notes into a reviewable plan under 99_system/ai_staging/ instead of editing notes directly. Use whenever a request would modify, move or normalise notes in the vault.
---

# Prepare a vault change for review

Notes are never edited from an agent session. A request to change notes
becomes a plan that the owner reviews and applies.

1. **Scope.** Restate the change: which note types, which folders and which
   fields. Refuse a vault-wide rewrite; split it into reviewable batches.
2. **Policy.** Check the folders against `99_system/ai_policy.yaml` (protected,
   LLM-excluded, sensitive). A folder the policy does not name is not
   protected; treat personal areas as sensitive regardless and propose a policy
   entry when one is missing.
3. **Generate, do not apply.** The owner runs, on their machine:

   ```bash
   vault-agent plan para --scope '<pattern>' --output 99_system/ai_staging/<run>.json
   vault-agent plan suggest ...
   vault-agent review pending
   vault-agent review show <id>
   vault-agent review approve <id>
   vault-agent apply preview
   ```

   `plan para` is for PARA moves and `plan suggest` for frontmatter
   suggestions. Tell the owner the commands and which fields each step
   changes. The agent session does not run them against the real vault; the
   guard hook blocks reading the PARA folders.
4. **Additive only.** The plan:
   - adds or normalises frontmatter fields and preserves existing ones
   - never deletes notes or assets
   - never touches binary files
   - skips `draft: true`
5. **Hand over.** Tell the owner the plan path, the number of notes affected
   and the exact `vault-agent apply commit` command. `apply` is theirs to run,
   and `.claude/settings.json` asks before it.
6. **Never commit** the plan or any other staging output (#43).
