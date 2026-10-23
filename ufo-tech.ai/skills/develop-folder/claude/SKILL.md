---
name: develop-folder
description: Sets up and maintains the project's `.develop/` working folder — glossary, investigations/, questions/ (open/accepted/rejected with ⚠️/⏸️/✅/🛑 icons), issues/ (features and bugfix tickets ready to paste into Jira) and docs/ (how the functionality works). Use it whenever /init runs or a CLAUDE.md is created, at the start of work in a project that has a CLAUDE.md but no `.develop/`, and every time you research or investigate something, explain a new term, raise an open question, record the user's decision, agree on a new feature or a bug to fix, or describe how part of the system works — even if the user does not mention `.develop`.
---

# .develop working folder

`.develop/` is the owner's working space for research and discussions with Claude. It lives in the project root, is never committed, and is written in Ukrainian (technical terms, names, code and commands stay in English). CLAUDE.md stays separate: never move or duplicate its content into `.develop/`.

```
.develop/
├── README.md                 # short index of these rules for humans
├── glossary.md               # every term/abbreviation used in .develop, grouped by topic
├── investigations/<topic>.md # one file per topic / request context
├── questions/
│   ├── open/<topic>.md       # ⚠️ new, ⏸️ deferred
│   ├── accepted/<topic>.md   # ✅
│   └── rejected/<topic>.md   # 🛑
├── issues/
│   ├── features/<icon>-NNN-<short-name>.md
│   └── bugfix/<icon>-NNN-<short-name>.md
└── docs/                     # how the functionality works; subfolders by project structure or logical blocks
```

Scripts live in `~/.claude/skills/develop-folder/scripts/`, each in two equivalent versions: `.sh` for macOS, Linux, WSL and Windows with Git Bash, and `.ps1` for Windows without Git Bash. Use the one matching your shell tool. On Windows, `~` is `%USERPROFILE%`.

```bash
# Bash tool
bash ~/.claude/skills/develop-folder/scripts/ensure-develop.sh [project-dir]           # create/complete the structure; never overwrites
bash ~/.claude/skills/develop-folder/scripts/next-number.sh questions|features|bugfix [project-dir]
```

```powershell
# PowerShell tool
powershell -NoProfile -ExecutionPolicy Bypass -File "$HOME\.claude\skills\develop-folder\scripts\ensure-develop.ps1" [project-dir]
powershell -NoProfile -ExecutionPolicy Bypass -File "$HOME\.claude\skills\develop-folder\scripts\next-number.ps1" questions|features|bugfix [project-dir]
```

If you create files by hand instead (e.g. no script can run), keep the same layout and rules — the scripts are a convenience, not a requirement.

## Creating the folder

- **During /init:** run `ensure-develop` right after writing CLAUDE.md.
- **/init happened before this skill existed:** the SessionStart hook (`scripts/session-check.sh` / `.ps1`) creates or completes the folder on the first later session in any project whose root has CLAUDE.md, and leaves a note in context — mention it to the user once. Without the hook, run the script yourself when you notice CLAUDE.md without a complete `.develop/`.
- Project root = git toplevel, or the current directory when it is not a git repo (e.g. a workspace holding several repos). Never create `.develop/` inside a nested sub-repo of such a workspace.
- The script adds `/.develop/` to `.git/info/exclude` (local-only; the shared `../../../../.gitignore` is untouched).
- **Legacy layouts** (`.develop/investigate.md`, `.develop/qa.md`, or an older `.features/` folder): offer to migrate them into this structure — split by topic — and remove the old files after the move.

## Status icons

The same set is used for questions and issues, so a glance at a heading or a file name tells the state:

| Icon | Questions | Issues |
|---|---|---|
| ⚠️ | new, awaiting decision | proposed, not yet approved |
| ⏸️ | deferred — decide later (state why/until when) | postponed |
| ✅ | accepted by the user | approved for work |
| 🛑 | rejected by the user | rejected |
| 🏁 | — | implemented (docs/ updated) |

Only the user's decision moves an item out of ⚠️ — never mark your own proposal as accepted. Record the decision in the user's words with a date.

## investigations/

One file per topic or request context, kebab-case Latin name (`php2shell.md`, `checkout-redirects.md`). Repeated research on the same topic extends the same file with a new dated section, newest on top. Use `templates/investigation.md`: conclusion first → details and evidence (file paths, commits, configs) → sources with links. Open questions found during research go to `questions/`, linked from here; agreed work goes to `issues/`.

## questions/

- Files are grouped by topic, same kebab-case name across `open/`, `accepted/`, `rejected/` (e.g. `open/php2shell.md` → `accepted/php2shell.md`). Use `templates/questions.md` for a new file.
- Heading: `### <icon> N. <питання>`; N is global across all of `questions/` (get it from `next-number.sh questions`) and never changes or gets reused. Body: context, options, your recommendation, links.
- **Deferred:** stays in `open/`, icon ⏸️, add `**Відкладено (YYYY-MM-DD):** …`.
- **Decided:** in the same turn change the icon, add `**Рішення (YYYY-MM-DD):** …`, cut the block from `open/<topic>.md` and put it on top of `accepted/<topic>.md` or `rejected/<topic>.md` (create from the template if missing). Delete an `open/` file once it has no questions left.
- If a decision means new work, also create the issue and link both ways.

## issues/

Create an issue when the discussion arrives at planned work (a new feature/improvement, or a defect to fix) — not for every idea mentioned in passing; ask if unsure.

- File name: `<icon>-NNN-<short-name>.md`, e.g. `⚠️-007-block-multipart-admin.md`. NNN is 3-digit, numbered separately in `features/` and `bugfix/` (`next-number.sh features|bugfix`), never reused. `<short-name>` is short kebab-case Latin. On status change rename the file (only the icon changes) and update the `Статус` field.
- Use `templates/feature.md` or `templates/bug.md`. Fill sections as knowledge grows: «Детальний опис» only once the idea is clear, «Інструкція з реалізації/виправлення» only after an investigation shows what to change. Leave an unknown section as `—` rather than guessing.
- **Jira-ready:** the H1 is the Jira Summary; everything from the first field line down to (not including) `## Локальні посилання` is the Description and must stand on its own — no relative links, no references to `.develop` files, plain Markdown (headings, lists, code blocks) that Jira's editor converts on paste. Local links to investigations/questions go only into the final `## Локальні посилання` section.
- Priority uses Jira values (Highest / High / Medium / Low / Lowest); complexity is a T-shirt size (XS / S / M / L / XL) with a one-line reason.
- When an issue is implemented: icon 🏁, and update `docs/`.

## docs/

Descriptions of how the functionality works **now** (not plans — plans live in issues). Subfolders follow the project structure or logical blocks of the documentation (e.g. `docs/nuxt/routing.md`, `docs/checkout/payment.md`). Write when a topic has been understood well enough to explain, and update when an issue reaches 🏁. Link related investigations at the bottom.

## glossary.md

Whenever any `.develop` file uses a term or abbreviation not yet in the glossary, add it in the same step: `- **Term** — коротке пояснення.` under a topic heading. Every file links to the glossary at the top (relative path), except the Jira-ready part of issues. In chat, explain jargon briefly instead of dropping bare abbreviations.

Tell the user in one line which `.develop/` files you created, moved or changed.
