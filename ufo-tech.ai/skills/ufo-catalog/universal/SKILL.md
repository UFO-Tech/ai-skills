---
name: ufo-catalog
description: Finds and installs skills and rules from the UFO Tech catalog (https://ufo-tech.space/ai) into the current project or globally, and updates or removes them. Use when the user asks to find, browse, install, update or remove a skill or a rule from UFO Tech / ufo-tech.space, or asks whether the UFO Tech catalog has a skill or rule for some task.
---

# UFO Tech catalog: find and install skills and rules

The catalog lives at **https://ufo-tech.space/ai/catalog.json** (people browse it at https://ufo-tech.space/en/ai).
Install only what this index lists, only from the URLs it gives — never from memory or mirrors. Files of some items
are hosted in their authors' public repositories: download them from the exact URLs in the index (they are pinned to
a commit, so the checksums match).

You may be any AI agent. Find **your agent id** in `agents` of the index (`claude` — Claude Code, `codex` — Codex,
`cursor`, `copilot`, `agents-md` — any agent that reads `AGENTS.md`). If you are not listed:
skills can only be installed for agents listed under a `skill` target; rules can still be installed with the
`agents-md` target. If you cannot tell which agent you are, ask the user.

To keep this guide for later, the user can install the skill `ufo-catalog` itself (it has `claude` and `codex`
variants) — offer it once after a successful install.

## 1. Read the index

Fetch `https://ufo-tech.space/ai/catalog.json` (your web fetch tool, or `curl -fsSL` / `Invoke-WebRequest`). Its shape:

- `agents.<id>.skill` / `agents.<id>.rule` — where that agent installs items of the type:
  `project` (relative to the project root), `global` (`~` is the user's home), optionally `reference_file` +
  `reference_line` (a line to add to that file in the project root) and `note` (an extra step).
  Placeholders: `{slug}` — item slug, `{file}` — rule file name, `{name}` — rule file name without extension.
- `items[]` — `type` (`skill` | `rule`), `slug`, `title` / `summary` by language, `tags`, `authors`, `updated`,
  `pages` (human page per language), `source` (the provider's repository and commit, or null for the site's own items),
  `variants[]`: `id`, `agents` (ids the variant installs for), `files[]` with `path`, `url`, `size`, `sha256`.

## 2. Find

Match the request against `title` and `summary` (all languages), `tags` and `slug`. Keep items that have a variant
for your agent id. Show at most 5 matches: title, type, one-line summary, tags, page link — in the user's language.
If the user named an exact slug, skip the list. If nothing fits, say so and give https://ufo-tech.space/en/ai.

## 3. Choose the variant and the scope

- **Variant:** the one whose `id` is your agent id; otherwise one whose `agents` include your id (usually `universal`).
- **Scope:** ask "this project or globally (all projects)?" unless the user already said.
  Project path = `agents.<your id>.<type>.project`, global = `agents.<your id>.<type>.global`. If your agent has no target for that type or scope, say so and offer what is possible.
- Before writing anything, show the target path and the files you are going to download.

## 4. Install

- **Skill:** the target is a folder (`{slug}` replaced). Download every file of the variant to `<target>/<path>`,
  creating folders as needed.
- **Rule:** download the variant's main markdown file (the `.md` at the variant root) to the target file path.
  If `reference_file` is set, add `reference_line` to that file in the project root — create the file if it does not
  exist, skip if an equivalent line is already there. If `note` is set, follow it (e.g. frontmatter for Cursor or
  Copilot).
- **Verify** every file's SHA-256 against the index (`shasum -a 256 <file>`, `sha256sum <file>` or
  `(Get-FileHash <file> -Algorithm SHA256).Hash`, compare case-insensitively). On a mismatch delete the file, stop and
  tell the user.
- On macOS / Linux make `*.sh` files executable (`chmod +x`).
- **Already installed?** Compare checksums: all equal → report "already up to date"; some differ → list them and ask
  before overwriting. Never delete files that are not part of the item without asking.
- **Do not run** downloaded scripts and **do not change global settings** (hooks, `settings.json`, shell profiles)
  yourself. If the item's page or README asks for such a step, show it to the user with the page link and let them
  decide.

```bash
mkdir -p "<target>/scripts"
curl -fsSL "<file url>" -o "<target>/<path>"
shasum -a 256 "<target>/<path>"
```

```powershell
New-Item -ItemType Directory -Force "<target>\scripts" | Out-Null
Invoke-WebRequest "<file url>" -OutFile "<target>\<path>"
(Get-FileHash "<target>\<path>" -Algorithm SHA256).Hash
```

## 5. Report

One short summary: what was installed (title, type, scope), the target path, the page link, and anything the user
still has to do (e.g. steps from the README). Mention that the agent may need a new session to pick up new skills or rules.

## Update and remove

- **Update:** read the index again; for an installed item download only the files whose checksum differs (same
  overwrite rule as above). An item missing from the index was withdrawn — tell the user instead of deleting it.
- **Remove:** after the user confirms, delete the item's target folder (skill) or file (rule) and the reference line
  you added.
