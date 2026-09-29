param(
  [Parameter(Mandatory=$true)]
  [string]$Name,

  [string]$OutDir = "02_areas\health\yoga\poses",
  [string]$Model = "llama3.2:3b"
)

# Ensure output directory exists
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

# Sanitize filename
$FileName = ($Name -replace '[\\/:*?"<>|]', '').Trim()
$Path = Join-Path $OutDir "$FileName.md"

$Created = (Get-Date).ToString("yyyy-MM-dd")

$Prompt = @"
You are a senior yoga teacher and anatomy-aware coach.
Return ONLY the final Markdown note (no code fences, no commentary).
Must be valid YAML frontmatter at top, then Markdown.

Rules:
- type must be yoga_pose
- name must be "$Name"
- created must be "$Created"
- lang: en
- level: beginner|intermediate|advanced (choose best)
- categories: choose 2-5 from [mobility, balance, strength, flexibility, relaxation]
- movement_patterns: choose 2-6 from [flexion, extension, rotation, lateral_flexion, inversion, balance]
- Fill primary_muscles (2-5), secondary_muscles (1-6)
- Fill muscle_load_map with 5-12 entries, values 0-5
- Fill joints (2-6), contraindications (0-6), equipment (0-5)
- Keep tags: yoga, pose, health; add up to 5 more relevant tags (lowercase)
- Provide realistic alignment cues, entry/exit, common mistakes, modifications/props, regressions/progressions, breath/hold.
- Regressions/Progressions/Related Poses should be in Obsidian link format [[Pose Name]].
- References optional; if unsure, leave it empty or generic.

Now generate the note.
"@

# Call Ollama
$Content = & ollama run $Model $Prompt

# Write file
$Content | Out-File -FilePath $Path -Encoding utf8

Write-Host "Created: $Path"
