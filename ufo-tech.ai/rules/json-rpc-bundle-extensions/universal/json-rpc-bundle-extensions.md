# Rules: extensions for ufo-tech/json-rpc-bundle

Rules for AI coding assistants working on a package that extends `ufo-tech/json-rpc-bundle`
(new transport, protocol adapter, integration, tooling). Written for bundle **10.4.x**.
Use together with `json-rpc-bundle.md`. Docs: https://ufo-tech.space/uk/docs/api/json-rpc-bundle/developers

## How to work

- The installed core (`vendor/ufo-tech/json-rpc-bundle/src`) is the source of truth; check every
  interface and class before relying on it, do not invent extension points, report contradictions
  with these rules.
- Prefer existing extension points over copying or extending internal classes. If a needed
  extension point is missing, say so instead of patching around the core.

## Do not duplicate the core

- No own method map, validation, parameter conversion or error format. Methods come from
  `ServiceMap` / `IServiceHolder`, execution goes through `Server\RpcExecutor`, errors through the
  `rpc.error` event. Then attributes, converters and events work for the new transport for free.
- Require `ufo-tech/json-rpc-bundle: ^10.4.2` (`RpcExecutor`, `IApiRouteImport`).

## Entry point

- Wrap the incoming request in an `IRpcRequestCarrier`; for HTTP implement `IRpcHttpCarrier`
  (binds `rpc.post_response` to the HTTP request, enables detached notifications).
- Execute with `RpcExecutor::execute($carrier)`: it always returns an `RpcResponse`.
- `RpcExecutor` does not check the token: use `IRpcSecurity` with a token holder, so
  `security.providers` apply to the new transport.
- Set the API group in `ApiGroupContext` before executing and reset it after; pass the API
  version into the `RpcRequest`.
- Register routes with `Routing\IApiRouteImport` (tag `ufo.rpc.route_import`) so every per-group
  import gets unique route names. Extending `RpcYamlFileLoader` is legacy.

## Compile-time components

`IServiceFiller`, `IConstraintGenerator` and `IParamConvertor` implementations are created while
the container is compiled: constructors may take only compile-time services or tagged iterables.

## Events

- Do not stop propagation of `rpc.pre_execute`, `rpc.pre_response`, `rpc.error`; on
  `rpc.post_response` never above priority 10.

## Package

- Follow the core layout: README (EN + UA), `docs/`, `releases/<major>.x/<minor>/` notes.
- Functional kernel test that executes a real RPC method through the new transport, including an
  error case and a token check.
- Backward compatibility within a major version; breaking changes listed in release notes.

Extension points with signatures: https://ufo-tech.space/uk/docs/api/json-rpc-bundle/developers
