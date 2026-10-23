# Authoring skills and rules for the UFO Tech catalog

The catalog at https://ufo-tech.space/en/ai is built from providers' public GitHub repositories. A provider signs in
on the site with GitHub and installs the catalog's GitHub App on the repositories to publish (read-only access to the
contents); every push is re-indexed automatically. Items are not copied: the catalog keeps their description and links
to the files at the indexed commit. Every item gets a page `/ai/<skill|rule>/<vendor>/<name>` with install commands
for each agent and an entry in `/ai/catalog.json`, from which agents install it (see the `ufo-catalog` skill).

## 1. Decide what you are making

- **Skill** — a task an agent should do on its own when it fits (a workflow, a generator, a checklist with scripts).
  Installed as a folder (`.claude/skills/<name>/`, `.agents/skills/<name>/`).
- **Rule** — instructions the agent should always follow in a project (library usage, code style). Installed as one
  markdown file referenced from `CLAUDE.md` / `AGENTS.md` / Cursor / Copilot.

## 2. Repository layout

The catalog only reads the `ufo-tech.ai/` folder of the repository. Inside it any folder hierarchy is allowed: the
scanner goes down every branch and stops at the first folder that has `manifest.yaml` — that folder is one item.

```
ufo-tech.ai/
├── skills/my-skill/              # any nesting, e.g. skills/php/my-skill/ — the folder name does not matter
│   ├── manifest.yaml
│   ├── README.en.md              # required
│   ├── README.uk.md              # optional, one file per extra language
│   ├── shared/                   # optional
│   ├── claude/SKILL.md
│   └── codex/SKILL.md
└── rules/my-rule/
    ├── manifest.yaml
    ├── README.en.md
    └── universal/my-rule.md      # the rule itself, in English
```

- **Variant folders** are agent ids from the catalog: `claude` (Claude Code), `codex` (Codex); for rules use
  `universal` — one file for every agent. A skill may also have `universal/` (read by link, not installed).
- **`shared/`** holds files common to all variants (scripts, templates, reference docs). At install time they are
  merged into each variant; a variant's own file with the same path wins. Never copy shared files into variants.
- **Required for an item:** a valid `manifest.yaml`, at least one variant folder, `SKILL.md` in every skill variant
  (at least one `.md` in a rule variant) and `README.en.md`. An item that misses any of them is skipped and shown with
  the reason in the provider's account on the site; the other items of the repository are still published.
- Only real content files: no `.DS_Store`, no secrets, tokens, internal URLs or personal data. Add a license file to
  the repository root.

## 3. manifest.yaml

```yaml
version: 1.0                      # manifest format version
name: vendor/my-skill             # vendor/name, lowercase kebab-case Latin; never changes after publishing
type: skill                       # skill | rule
title:
    en: English title             # en is required
    uk: Назва українською         # other languages are optional
summary:
    en: One or two sentences — what it does and when it helps.
    uk: Одне-два речення — що робить і коли корисно.
authors:                          # like "authors" in composer.json
    - name: some name
      email: you@example.com      # optional; never shown, only for contact and identification
support:                          # like "support" in composer.json
    source: https://github.com/vendor/ai-skills
    issues: https://github.com/vendor/ai-skills/issues
tags: [php, symfony]              # lowercase kebab-case; reuse existing tags from /ai/catalog.json first
```

- **`vendor`** belongs to the GitHub account that first published an item with it; other maintainers are added by an
  existing maintainer in the account on the site. An item with a vendor you do not maintain is not accepted.
- **The item version** is not written anywhere: it is the date and the short hash of the last commit that changed a
  file in the item folder, `YYYY.MM.DD.<hash>`.
- Titles and summaries are shown on cards and used by search and SEO — concrete, no marketing.

## 4. README.<locale>.md

One file per language with the same name pattern: `README.en.md` (required) and optionally `README.uk.md` and other
languages. The page shows the README in the visitor's language. Start with `# Title` (it is dropped on the page, the title comes from
manifest.yaml), then: what it does, when it is triggered, platforms / requirements, extra install steps the agent will
NOT do itself (hooks, settings), and the layout of the installed folder. Links to site pages are written without the
language prefix (`/docs/...`, `/ai/rule/<vendor>/<name>`).

## 5. SKILL.md (per agent variant)

Follows the open Agent Skills format:

```markdown
---
name: <name>
description: <what it does>. Use when <triggers: user phrases, situations, files> — even if the user does not name the skill.
---

# Title
Instructions…
```

- `name` = the name part of the manifest `name` (without the vendor); `description` is what the agent uses to decide when to load the skill — put the triggers there,
  keep it under ~1000 characters.
- Write instructions in English, imperative, specific; keep SKILL.md under ~500 lines and move long reference material
  into separate files (usually `shared/`), linked from SKILL.md.
- Paths: refer to bundled files relative to the skill folder, and name the install location for the agent:
  Claude Code `~/.claude/skills/<name>/` (global) or `.claude/skills/<name>/` (project); Codex `~/.agents/skills/<name>/`
  or `.agents/skills/<name>/`.
- Agent-specific parts (Claude Code hooks, `CLAUDE.md` vs `AGENTS.md`, tool names) go into the variant's SKILL.md or
  its own extra files; everything else into `shared/`.
- Scripts: provide `.sh` (bash 3.2 compatible, macOS/Linux/WSL/Git Bash) and `.ps1` (Windows PowerShell 5.1) versions
  with the same behaviour; scripts must be idempotent and never overwrite user files silently. Add
  `shared/.gitattributes` with `*.sh text eol=lf`.

## 6. Rules

- The rule file `universal/<name>.md` is in English, starts with `# Rules: …` or `# Code style: …`, says which library
  version it is written for, and links to the documentation instead of copying it.
- First section "How to work": source of truth (installed code, release notes), don't invent APIs, report conflicts.
- Keep it short: rules and pitfalls, not explanations.

## 7. Check before publishing

- Validate `manifest.yaml` against section 3 and the required files from section 2.
- Run the scripts on every platform you claim (`.sh` and `.ps1`), in a temporary folder.
- Push to the repository with the GitHub App installed, then open `/en/ai/<skill|rule>/<vendor>/<name>` and your
  account on the site: the item page, README, the file list per agent, the install commands — or the reason the item
  was skipped. Run the generated install commands in a temporary folder and check that the agent picks the skill up.
