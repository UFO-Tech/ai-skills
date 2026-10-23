# Code style: UFO-Tech

Optional house style of the UFO-Tech team. Use it in projects that adopt this style; skip it if
your project already has its own conventions — then follow those.

## Typing and data

- `declare(strict_types=1);`, full typing of arguments, return types and properties.
- No `mixed` in our own code; DTO/VO for all structured data instead of associative arrays.
- Immutability by default; no side effects in constructors.

## Architecture

- Service-oriented / hexagonal approach; interfaces for external dependencies.
- Thin controllers and RPC procedures; business logic only in services; repositories only access data.
- No framework leakage into the domain layer; no `Request`/`Response` outside the controller layer.
- No service locator, static helpers or hidden dependencies.

## Code

- Early return; nesting depth ≤ 2; methods around 30 lines.
- Clear names without abbreviations; no magic strings.
- Exceptions only for exceptional cases.
- Production-level, explicit and extensible design; avoid overengineering.
