# UFO-Tech code style

The UFO-Tech team's optional code style for PHP projects. Add it only to projects that adopt this style; if a project already has its own conventions, the agent must follow those.

## What's inside

* `declare(strict_types=1);`, full typing of arguments, return values and properties;
* DTOs and value objects instead of associative arrays, immutable by default;
* thin controllers, business logic in services, repositories only for data access;
* early returns, shallow nesting and short methods.

The file is in English.
