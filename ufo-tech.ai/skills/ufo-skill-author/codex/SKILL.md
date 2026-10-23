---
name: ufo-skill-author
description: Creates and updates skills and rules for the UFO Tech catalog (ufo-tech.space/ai) — an item folder under ufo-tech.ai/ in a provider's public GitHub repository with manifest.yaml (vendor/name), README.en.md (plus other languages), agent variants (claude/, codex/, universal/) and shared/ files. Use when the user wants to publish, package, add or port a skill or rule to ufo-tech.space, to make a skill available for another agent, or edits files under ufo-tech.ai/ in a repository meant for the catalog.
---

# Authoring for the UFO Tech catalog

You are **Codex**. This skill is installed in `~/.agents/skills/ufo-skill-author/` (or `.agents/skills/ufo-skill-author/` in a repository).

1. Read `reference.md` next to this file — it is the full specification: layout, manifest.yaml, README naming,
   SKILL.md format, shared files, rules, providers' repositories, checks.
2. Ask what the item is for (task, triggers, target agents) if the user has not said; decide skill vs rule.
3. Work in the user's public GitHub repository for the catalog, inside `ufo-tech.ai/`. Ask for the vendor (it must be
   one the user maintains on the site). Reuse existing tags from `/ai/catalog.json`.
4. Put everything common to all agents into `shared/`; variant folders hold only what differs. Never duplicate files.
5. Write `README.en.md` (required) and the other languages the user wants; `title` and `summary` in manifest.yaml
   need `en` plus the same languages.
6. Run the checks from `reference.md` (manifest, required files, scripts, a test install) and report what you created,
   what you could not verify and what the user still has to do (commit, push, GitHub App on the repository).
