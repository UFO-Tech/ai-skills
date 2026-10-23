# Skill author for the UFO Tech catalog

A skill for those who want to share their skill or rule through this catalog. The agent knows how an item folder must be laid out and builds it for you.

## What it does

* works out what it should be — a **skill** (a task the agent does on its own when it fits) or a **rule** (instructions the agent always follows in a project);
* creates an item folder under `ufo-tech.ai/` in your public GitHub repository: `manifest.yaml` with `vendor/name`, the title, summary and tags (English is required, other languages optional), `README.en.md` and READMEs in other languages;
* makes variants for different agents (`claude/`, `codex/`, `universal/`) and moves everything common — scripts, templates, reference docs — into `shared/`, so nothing is duplicated;
* writes `SKILL.md` in the Agent Skills format with a description the agent uses to decide when the skill is needed;
* checks the result: the manifest and required files, the scripts, a test install.

## How it works

A short `SKILL.md` in each variant points to a shared `reference.md` — the full catalog specification. This skill is laid out exactly that way, so you can use it as an example.
