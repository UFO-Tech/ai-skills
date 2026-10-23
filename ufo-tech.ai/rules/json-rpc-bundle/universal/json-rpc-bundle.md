# Rules: ufo-tech/json-rpc-bundle

Rules for AI coding assistants in a Symfony project that exposes its API with
`ufo-tech/json-rpc-bundle`. Written for bundle **10.4.x**.
Docs: https://ufo-tech.space/uk/docs/api/json-rpc-bundle

This file is not the library documentation. It lists how to work with the bundle and the
mistakes to avoid; details are in the linked docs.

## How to work

- **The installed code is the source of truth.** Before using a class, attribute, option or
  event you are not sure about, check it in `vendor/ufo-tech/json-rpc-bundle/src` and
  `vendor/ufo-tech/rpc-objects/src`. Release notes with examples for every version:
  `vendor/ufo-tech/json-rpc-bundle/releases/`.
- **Check the installed version** (`composer show ufo-tech/json-rpc-bundle`). If it is not 10.4.x,
  read the release notes between versions before applying these rules.
- **Do not invent** classes, methods, attributes, config keys or `$rpc` params. If something is
  not in the installed code, say so instead of guessing.
- **If these rules contradict the installed code, follow the code and report the contradiction.**
- **Do not change public RPC contracts** (method names, parameters, result shape, error codes)
  unless the task asks for it. Clients depend on them; breaking changes go to a new API version.
- **Stay within the task.** No refactoring outside it; follow the architecture already used in
  the project instead of introducing a new one.

## Procedures

- An RPC procedure is a class implementing `Ufo\JsonRpcBundle\ApiMethod\Interfaces\IRpcService`;
  every public non-static method becomes `<alias>.<method>`. Set the alias explicitly with
  `#[RPC\Info('Order')]`. → /add_rpc_service
- Procedures are entry points: map input to a call of an application service and return the
  result. No business logic, persistence or `Request`/headers access inside — the same method is
  called over HTTP, CLI, Messenger and adapters (REST, MCP).
- Public helper methods that must not become RPC methods: move them out, or mark `#[RPC\IgnoreApi]`.
- Signatures and PHPDoc are the method contract and its OpenRPC documentation. Keep PHPDoc
  accurate and do not duplicate method contracts in hand-written docs (business-scenario docs
  are fine).
- The method map is built at container compile time. In debug the container rebuilds itself
  when a procedure changes; with `kernel.debug=false` run `bin/console cache:clear`.

## Parameters and results

- Precise types. For `array` describe elements in PHPDoc (`@param OrderItemDto[] $items`).
  Avoid `mixed` in signatures: it produces an untyped schema — prefer a union or a DTO, and if a
  value is really arbitrary, document it in PHPDoc. → /add_rpc_service/params
- Structured input and output are DTOs, not associative arrays. Class-typed parameters are
  hydrated automatically; enums, dates, UUIDs and Doctrine entities are converted automatically —
  do not convert them by hand. Custom types: `IParamConvertor`.
- Validation is declarative: `#[RPC\Assertions([...])]` on the parameter. → /add_rpc_service/assertions
- Result format comes from the return type / `@return`. If it must be `array`, declare
  `#[RPC\DTO(Dto::class)]` or `#[RPC\DTO(Dto::class, collection: true)]`. → /add_rpc_service/response
- Special params go in a nested object: `"params": {"$rpc": {"callback": "...", "ignoreCache": true}}`.

## Errors

- Signal failures by throwing, never by returning `false` or error arrays. Use `Ufo\RpcError`
  exceptions or map domain exceptions in an `rpc.error` listener; declare them with `@throws`.
  → /error_handling

## Caching, locking, versions, groups

- `#[RPC\Cache]` only for reads whose result depends only on parameters; pair writes with
  `#[RPC\CacheRelation]`. → /add_rpc_service/cache
- A breaking change of a method goes to a new API version (`#[RPC\Info(..., version: 2)]`),
  never in place. → /functionality/versions
- Different audiences (public / internal / BFF) are separated with `#[RPC\APIGroups]` and route
  imports, not runtime checks. → /functionality/groups

## Events

- Cross-cutting behaviour (audit, metrics, tracing, access) goes to listeners on
  `RpcEvent::*`, heavy side effects to `rpc.post_response`. → /functionality/events
- Never `stopPropagation()` on `rpc.pre_execute`, `rpc.pre_response`, `rpc.error`, or on
  `rpc.post_response` above priority 10.

## Known pitfalls (10.4.x)

- Obsolete, do not use: `#[RPC\Response]`, `#[RPC\ResultAsDTO]`, event `rpc.response`,
  event classes from `Ufo\RpcObject\Events`.
- `#[RPC\DTOCollection]` on a method is ignored — use `#[RPC\DTO(..., collection: true)]`.
- `#[RPC\Lock]` makes a concurrent call wait, not fail — always set `ttl`.
- `rpc.async_request` is never dispatched; Messenger requests fire neither `rpc.request` nor
  `rpc.post_response`.
- In a single HTTP request, errors raised before method execution (token, unknown method,
  invalid JSON) do not pass through `rpc.error`.
- Current list: /developers/known_issues/open

## Security

- Tokens only from environment variables / Symfony secrets; never in code, committed YAML or logs.
- Custom token checks implement `Security\Interfaces\ITokenValidator`. → /config

## Verify before finishing

- Run the project's tests.
- Call each changed method once (HTTP or `bin/console ufo:rpc:process '<json>'`) and check
  `result` / `error`.
- Open `GET /rpc` and check the generated schema of changed methods and DTOs.

Links starting with `/` are relative to https://ufo-tech.space/uk/docs/api/json-rpc-bundle
