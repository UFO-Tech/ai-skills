# develop-folder — a skill for Claude Code and Codex

Creates and maintains the `.develop/` working folder in the project root:

```
.develop/
├── README.md                     # a short cheat sheet with the rules
├── glossary.md                   # terms and abbreviations, grouped by topic
├── investigations/<тема>.md      # investigations, one file per topic or request context
├── questions/
│   ├── open/<тема>.md            # ⚠️ new, ⏸️ deferred
│   ├── accepted/<тема>.md        # ✅ accepted
│   └── rejected/<тема>.md        # 🛑 rejected
├── issues/
│   ├── features/<іконка>-NNN-<назва>.md
│   └── bugfix/<іконка>-NNN-<назва>.md
└── docs/                         # how the functionality works now
```

- **Statuses:** ⚠️ new / awaiting decision · ⏸️ deferred · ✅ accepted · 🛑 rejected · 🏁 implemented (issues only). Only a person's decision changes a question's status.
- **Questions:** numbering runs through the whole `questions/` folder. Once decided, a question moves from `open/<тема>.md` to `accepted/<тема>.md` or `rejected/<тема>.md` together with the date and the wording of the decision.
- **Issues** (`issues/`) appear when the discussion arrives at planned work. Templates: `templates/feature.md` and `templates/bug.md`. The H1 heading is the Jira Summary, and everything before the "Локальні посилання" (local links) section is the Description, which can be pasted into Jira as is.
- **docs/** describes the current state of the system, not plans. Sections are updated when an issue becomes 🏁.
- **Git:** the folder never gets into git, because the script adds `/.develop/` to `.git/info/exclude`. This is a local file, so the shared `../../../.gitignore` does not change. CLAUDE.md stays separate.

## When it is created

- During `/init`: the agent picks up the skill and runs `ensure-develop` right after `CLAUDE.md` (Claude Code) or `AGENTS.md` (Codex).
- If `/init` ran before the skill appeared:
  - **Claude Code** — the SessionStart hook sees CLAUDE.md at the start of a session, creates or completes `.develop/` and tells Claude about it;
  - **Codex** — there is no hook: the agent runs `ensure-develop` itself when it sees `AGENTS.md` without a complete `.develop/`.

  If the old layout turns up (`.develop/investigate.md`, `.develop/qa.md`, `.features/`), the agent offers to migrate.

## Platforms

Every script has two versions that behave the same:

| System | Script version | Requirements |
|---|---|---|
| macOS, Linux, WSL | `.sh` | `bash` (3.2, as on macOS, is fine too), `git` |
| Windows with Git for Windows (Git Bash) | `.sh` | Git for Windows |
| Windows without Git Bash | `.ps1` | the built-in Windows PowerShell 5.1 or PowerShell 7; `git` — if the projects are in git |

Claude Code on Windows without Git for Windows runs both commands and hooks through PowerShell. That's why such a machine needs the `.ps1` versions of the scripts and a separate variant of the hook.

## Installation

1. Install the skill **globally** — the paths in SKILL.md (and the Claude Code hook) expect exactly this location: `~/.claude/skills/develop-folder/` for Claude Code, `~/.agents/skills/develop-folder/` for Codex. The easiest way is to ask the agent: "install the develop-folder skill from the UFO Tech catalog globally"; commands for installing by hand are above on this page.

   If the skill is kept in git, the `.gitattributes` file in the skill folder keeps the `.sh` scripts with LF line endings. Otherwise, on Windows with `core.autocrlf=true`, bash fails on them.
2. **Claude Code only:** add the hook to `~/.claude/settings.json` (on Windows it is `%USERPROFILE%\.claude\settings.json`). If `hooks.SessionStart` is already there, append an element to the existing array instead of replacing it.

   macOS, Linux, WSL, Windows with Git Bash:
   ```json
   {
     "hooks": {
       "SessionStart": [
         {
           "hooks": [
             {
               "type": "command",
               "command": "bash \"$HOME/.claude/skills/develop-folder/scripts/session-check.sh\"",
               "timeout": 10
             }
           ]
         }
       ]
     }
   }
   ```

   Windows without Git Bash:
   ```json
   {
     "hooks": {
       "SessionStart": [
         {
           "hooks": [
             {
               "type": "command",
               "shell": "powershell",
               "command": "powershell -NoProfile -ExecutionPolicy Bypass -File \"$HOME\\.claude\\skills\\develop-folder\\scripts\\session-check.ps1\"",
               "timeout": 15
             }
           ]
         }
       ]
     }
   }
   ```
   `-ExecutionPolicy Bypass` applies to this run only; it does not change the system policy.

Codex doesn't need this step. Without step 2 the skill still works, but the folder is created only during `/init` or when Claude notices CLAUDE.md without `.develop/` on its own.

## Contents

The installed skill:

```
develop-folder/
├── SKILL.md                        # rules for the agent (separate ones for Claude Code and Codex)
├── .gitattributes                  # LF for .sh, so bash doesn't fail on Windows
├── scripts/ensure-develop.sh|.ps1  # creates or completes .develop; never overwrites existing files
├── scripts/next-number.sh|.ps1     # the next free number: questions | features | bugfix
├── scripts/session-check.sh|.ps1   # SessionStart hook (Claude Code only)
└── templates/                      # README, glossary, investigation, questions, feature, bug
```

In the catalog the scripts and templates are kept once in `shared/`; `claude/` and `codex/` hold only what differs.
