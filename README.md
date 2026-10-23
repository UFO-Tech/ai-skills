# UFO Tech AI skills

**English** · [Українська](README.uk.md)

Skills and rules for AI coding agents — Claude Code, Codex, Cursor, GitHub Copilot and any agent that reads `AGENTS.md` — published in the UFO Tech catalog **“Level up your AI”**: https://ufo-tech.space/en/ai

The catalog reads this repository, shows every item on its own page (description, files per agent, install commands) and gives agents a machine-readable index, so an agent can find and install an item by itself.

## Contents

### Skills

A skill is a task an agent does on its own when it fits: a workflow, a generator, a checklist with scripts. It is installed as a folder.

| Item | What it does | Agents |
|---|---|---|
| [`ufo-tech/ufo-catalog`](ufo-tech.ai/skills/ufo-catalog) | Teaches an agent to find skills and rules in the UFO Tech catalog and install them into a project or globally, with checksum verification. | Claude Code, Codex, any agent by link |
| [`ufo-tech/develop-folder`](ufo-tech.ai/skills/develop-folder) | Creates and maintains a project's `.develop` folder: glossary, investigations, open questions with decisions, Jira-ready tickets and docs on how the system works. | Claude Code, Codex |
| [`ufo-tech/ufo-skill-author`](ufo-tech.ai/skills/ufo-skill-author) | Helps create a skill or a rule for the catalog: layout, `manifest.yaml`, READMEs, variants for different agents and shared files without duplication. | Claude Code, Codex |

### Rules

A rule is a set of instructions the agent always follows in a project: how to use a library, which code style to keep. It is installed as one markdown file referenced from `CLAUDE.md`, `AGENTS.md`, Cursor or Copilot settings.

| Item | What it does |
|---|---|
| [`ufo-tech/json-rpc-bundle`](ufo-tech.ai/rules/json-rpc-bundle) | How an agent works with `ufo-tech/json-rpc-bundle`: procedures, parameters, results, errors, cache, API versions and groups, events, known pitfalls and checks. |
| [`ufo-tech/json-rpc-bundle-extensions`](ufo-tech.ai/rules/json-rpc-bundle-extensions) | For packages that extend the bundle (transports, protocol adapters, integrations): the `RpcExecutor` entry point, tokens, groups and versions, routes, package requirements. |
| [`ufo-tech/ufo-code-style`](ufo-tech.ai/rules/ufo-code-style) | The UFO-Tech team's optional PHP code style: strict typing, DTOs, thin controllers, services, early returns. |

Each item folder has its own `README.<locale>.md` with details: when it triggers, requirements, extra setup steps.

## Installing

**From the catalog page.** Open the item at https://ufo-tech.space/en/ai, pick your agent and the scope (this project or globally) and run the commands shown. Every file is checked against its SHA-256 from the index.

**By asking your agent.** Install the `ufo-tech/ufo-catalog` skill once (or give any agent the link https://ufo-tech.space/ai/install.md), then ask in plain words, for example:

> install the develop-folder skill from the UFO Tech catalog globally

The agent shows what it is going to download and where, verifies checksums and does not run downloaded scripts or change global settings without asking.

**By hand.** Copy the variant folder for your agent and merge `shared/` into it (a file in the variant wins over the same path in `shared/`):

| Agent | Skill, in a project | Skill, globally |
|---|---|---|
| Claude Code | `.claude/skills/<name>/` | `~/.claude/skills/<name>/` |
| Codex | `.agents/skills/<name>/` | `~/.agents/skills/<name>/` |

`<name>` is the part of the item name after `/`, e.g. `develop-folder`. A rule is a single file from `universal/`: put it into the project and reference it from `CLAUDE.md`, `AGENTS.md`, `.cursor/rules/` or `.github/copilot-instructions.md`.

## Repository layout

The catalog reads only the `ufo-tech.ai/` folder. Inside it any folder hierarchy is allowed: the scanner goes down every branch and stops at the first folder that contains `manifest.yaml` — that folder is one item.

```
ufo-tech.ai/
├── skills/
│   └── develop-folder/
│       ├── manifest.yaml        # name, type, titles, summaries, authors, support, tags
│       ├── README.en.md         # required
│       ├── README.uk.md         # optional, one file per extra language
│       ├── claude/SKILL.md      # variant for Claude Code
│       ├── codex/SKILL.md       # variant for Codex
│       └── shared/              # files merged into every variant (scripts, templates, references)
└── rules/
    └── ufo-code-style/
        ├── manifest.yaml
        ├── README.en.md
        ├── README.uk.md
        └── universal/ufo-code-style.md   # the rule itself, one file for every agent
```

- **Variant folders** are named after the agent: `claude`, `codex`; `universal` is one variant for every agent (rules) or a version read by link (skills).
- **`shared/`** keeps common files once; variants hold only what differs.
- **Required for an item:** a valid `manifest.yaml`, at least one variant folder, `SKILL.md` in every skill variant (at least one `.md` in a rule variant) and `README.en.md`. An item missing any of them is skipped by the catalog; the other items are still published.

## manifest.yaml

```yaml
version: 1.0                      # manifest format version
name: ufo-tech/develop-folder     # vendor/name, lowercase kebab-case Latin; never changes after publishing
type: skill                       # skill | rule
title:
    en: The .develop working folder        # English is required
    uk: Робоча папка .develop              # other languages are optional
summary:
    en: Creates and maintains a project's .develop folder — …
    uk: Створює й веде в проєкті папку .develop — …
authors:                          # like "authors" in composer.json
    - name: Ashterix
      email: you@example.com      # optional; never shown, only for contact and identification
support:                          # like "support" in composer.json
    source: https://github.com/UFO-Tech/ai-skills
    issues: https://github.com/UFO-Tech/ai-skills/issues
tags: [ai-workflow, documentation]
```

**Versions.** An item has no version field: its version is the date and the short hash of the last commit that changed a file in its folder, `YYYY.MM.DD.<hash>` (e.g. `2026.10.23.1a2b3c4`). Install links point to that exact commit, so an agent gets the same files the catalog shows.

The full specification — including how to write `SKILL.md` and rules — is in [`ufo-skill-author/shared/reference.md`](ufo-tech.ai/skills/ufo-skill-author/shared/reference.md).

## Contributing

- **Bugs and ideas** for the items in this repository — [issues](https://github.com/UFO-Tech/ai-skills/issues).
- **Changes** — a pull request; keep the layout above, update both READMEs of the item, provide `.sh` and `.ps1` versions of scripts with the same behaviour. No secrets, tokens, internal URLs or personal data in any file.

## Publishing your own skills and rules

The catalog accepts items from any public GitHub repository with the same `ufo-tech.ai/` layout:

1. **Build the item folder** under `ufo-tech.ai/` in your repository — the `ufo-tech/ufo-skill-author` skill does it for you. Use your own vendor in `name`, e.g. `acme/my-skill`.
2. **Sign in** at https://ufo-tech.space with your GitHub account.
3. **Install the catalog's GitHub App** on the repositories you want to publish. It only gets read access to their contents.
4. **Push.** The catalog reads the repository right away and on every push after that; items appear in the catalog as soon as their manifests and required files are valid. Items that are skipped are listed with the reason in your account on the site.

**Vendor.** A vendor belongs to the GitHub account that first published an item with it. Other maintainers — for example colleagues from the same organization — are added by an existing maintainer in the account on the site. An item with a vendor you do not maintain is not accepted.

**Ratings and complaints.** Signed-in visitors can like or dislike an item and report a problem with it. A reported item stays in the catalog marked as under review and is checked by a moderator; an item reported as malicious is hidden until the review.

## License

[MIT](LICENSE). Items from other providers' repositories are published under their own licenses.
