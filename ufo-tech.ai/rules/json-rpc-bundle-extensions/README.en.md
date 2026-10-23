# Rules for JsonRpcBundle extensions

For packages that extend [JsonRpcBundle](/docs/api/json-rpc-bundle/developers/extensions): a new transport, a protocol adapter, an integration or tooling. Use together with the [JsonRpcBundle rules](/ai/rule/json-rpc-bundle).

## What's inside

* don't duplicate the core: the method map, validation, parameter conversion and error format are already in the bundle;
* the entry point through `RpcExecutor`, the token check, the API group and version of a request, routes via `IApiRouteImport`;
* constraints for components created while the container compiles, and rules for events;
* package requirements: bundle version, README and docs layout, a functional test, compatibility within a major version.

The file is in English; bundle version **10.4**.
