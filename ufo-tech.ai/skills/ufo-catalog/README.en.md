# UFO Tech catalog — find and install

The skill to start with: once it is installed, just tell your agent "find a skill for … in the UFO Tech catalog" or "install the json-rpc-bundle rules into this project".

## What it does

1. Reads the catalog index `https://ufo-tech.space/ai/catalog.json` — titles, descriptions, tags, files and checksums.
2. Searches it for your request and shows up to five matches with links to their pages.
3. Asks where to install: into the project (the whole team gets it once committed) or globally (all your projects).
4. Shows which files it will write and where, downloads them and checks their SHA-256 against the index.
5. For rules, adds a reference line to `CLAUDE.md` or `AGENTS.md` when the agent needs one.

The agent never runs downloaded scripts and never changes global settings (hooks, `settings.json`) on its own — it only shows you such steps.

## How to install

**The easiest way** — give any agent the link and ask it to follow it:

```text
Read https://ufo-tech.space/ai/install.md and install the ufo-catalog skill for yourself globally.
```

**By hand** — commands for Claude Code and Codex are below on this page, in the "Installation" block.

## Updating and removing

Tell the agent "update my skills from the UFO Tech catalog" — it compares checksums and downloads only changed files. To remove: "remove the … skill from the UFO Tech catalog".
