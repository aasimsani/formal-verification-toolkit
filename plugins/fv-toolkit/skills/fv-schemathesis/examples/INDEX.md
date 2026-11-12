# Schemathesis examples

`tests/test_examples.sh` in the repository runs every row of this table. A good example meets its expectations and detects its mutations. A bad example produces the symptom that its README states.

| Example | Kind | Pattern | The one lesson |
|---|---|---|---|
| [good/items-api](good/items-api/README.md) | good | REST / OpenAPI contract, stateful API workflow (F1) | Schema conformance and a stateful create/get/delete workflow catch different bugs |
| [bad/schema-too-loose](bad/schema-too-loose/README.md) | bad | Any | An empty response schema accepts any body, so nothing can violate it |
| [bad/call-without-validate](bad/call-without-validate/README.md) | bad | Any | `case.call()` makes the request and checks nothing about the response |
