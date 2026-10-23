# JsonRpcBundle rules

An instruction file for projects that expose an API with [JsonRpcBundle](/docs/api/json-rpc-bundle). It sits next to your own rules and does not replace your `AGENTS.md` or `CLAUDE.md`. Written in English because assistants follow English instructions more reliably; bundle version **10.4**.

## What's inside

**How the agent works** — at the top of the file:

* the source of truth is the installed bundle code in `vendor/` and the release notes in `vendor/ufo-tech/json-rpc-bundle/releases/`, not the model's memory;
* check the installed version; never invent classes, attributes or options; report when the rules and the code disagree;
* don't change public RPC contracts without need (breaking changes mean a new API version) and don't refactor outside the task.

**Library rules** — short, with links to the documentation instead of explanations: thin procedures, DTOs and declarative validation, the result format, errors, cache, API versions and groups, events.

**Known pitfalls of 10.4** — deprecated attributes and events, `#[RPC\DTOCollection]` on a method, `ttl` for `#[RPC\Lock]`, specifics of events for Messenger and of HTTP errors (see [Open issues](/docs/api/json-rpc-bundle/developers/known_issues/open)).

**Checks before finishing** — tests, a call of the changed method, the schema in `GET /rpc`.

:::info subtitle="Why this is not documentation"
The file deliberately doesn't explain how things work — that's what the documentation it links to is for. This keeps the instructions short instead of turning them into a second copy of the docs that drifts away from the first.
:::

## See also

* [Rules for JsonRpcBundle extensions](/ai/rule/json-rpc-bundle-extensions) — if you are writing an extension package.
* [UFO-Tech code style](/ai/rule/ufo-code-style) — optional, for projects that adopt this style.
