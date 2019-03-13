# Gateway service

The Gateway service is a public facing service. HTTP requests hitting this service are either transformed into NSQ messages or forwarded via HTTP to specific services.

The service must be configurable dynamically by loading the provided `gateway/config.yaml` file to register endpoints during its initialization.

## Configuration format

Example:

```yaml
urls:
  -
    path: "/drivers/:id/locations"
    method: "PATCH"
    nsq:
      topic: "locations"
  -
    path: "/drivers/:id"
    method: "GET"
    http:
      host: "zombie-driver"
```

Each `urls` entry will add a new handler to forward the request. 

### HTTP method restrictions

There are certain restrictions about the methods allowed:

| Request Method | HTTP  | NSQ | Notes                                 |
|----------------|-------|-----|---------------------------------------|
| POST           | ✔     | ✔   |                                       |
| PUT            | ✔     | ✔   |                                       |
| PATCH          | ✔     | ✔   |                                       |
| DELETE         | ✔     | ✔   |                                       |
| GET            | ✔     |     | NSQ is "push" only, can't return data |
| HEAD           | ✔     |     | No concept of "Headers" for NSQ       |
| OPTIONS        | ✔     |     | NSQ is "push" only, can't return data |
| CONNECT        |       |     | Tunneling is not supported            |
| TRACE          |       |     | N/A                                   |
| LINK           |       |     | N/A                                   |
| UNLINK         |       |     | N/A                                   |


### Path format restrictions

The gateway uses [http_router](https://github.com/joshbuddy/http_router) to match the request routes. Named groups (`/:id/`) should work just fine. But the `path` configuration entry is not parsed for Regular Expressions to be passed to the router.

## HTTP forwarding

All the headers and body sent to the configured `path` are passed to the upstream `host` configured at the same `path`.

### Proxy Headers

The HTTP handler adds `X-Forwarded-For` or appends to an exsiting one, but does not handle other proxy headers: `Forwarded`, `X-Forwarded-Host`, `X-Forwarded-Proto` or `Via`

### Responses

  - Returns the upstream response code, headers and body unmodified on success
  - **502** (BAD_GATEWAY) when connection to the upstream can't be established (no body or headers)
  - **504** (GATEWAY_TIMEOUT) when the upstream didn't respond within 5 seconds (no body or headers)
  
## NSQ Forwarding

The NSQ endpoints have special restrictions compared to the HTTP ones.

### A note about reliability

It's extremely unreliable. When the gateway returns a success - it means that we sent the message to a `Nsq::Producer` from the [nsq-ruby](https://github.com/wistia/nsq-ruby) gem. Hoever this just adds the message to an internal queue. There are no guarantees that the message ever made it anywhere outside that queue. 


### Request Format

The gateway needs to be able to construct some sort of data message from the request. Meaning at least one of the two must be present:
  - Named path parameters ( **URL params overwrite the same params from the body** )
  - Valid JSON in request body

When both are present - the message merges the data from both, prioritizing path parameters.

### Responses
  - **204** ( NO_CONTENT ) - when the message was accepted and **maybe** sent to NSQ
  - **400** ( BAD_REQUEST ) - when there are not enough params to compsoe a message, or the request body contains invalid JSON. The response body contains error details as plain text.

#### Curl Example

```bash
MESSAGE_FORMAT='{"latitude":%s,"longitude":%s}\n'

function create_events() {
  local id=$1
  local latitude=$2
  local longitude=$3

  curl --verbose --header "Content-Type: application/json" \
    --request POST \
    --data $(printf "$MESSAGE_FORMAT" "$latitude" "$longitude" ) \
    --request PATCH http://gateway.local:3000/drivers/$id/locations
}
```
The message generated will have the following structure:
```json
{
  "latitude": "$latitude",
  "longitude": "$longitude",
  "id": "$id"
}
```
The `id` key name is extracted from the path parameter configured it `gateway/configuration.yaml`

## Connection management

Incoming HTTP connections to be routed are handled by a puma server that can be configured with `WEB_CONCURRENCY` ENV variable to specify the concurrent connections accepted.

Incoming connection timeouts and queues are currently non-configurable

Outgoing HTTP connections are managed on a system level by `libcurl`.
Outgoing NSQ connections are managed by a connection pool size that is the same as `WEB_CONCURRENCY`

## Development

The repository has a `docker-compose.local.yaml` that can run the service in two modes:

 - `run` - image that can run tests and everything in the app. Best used for running tests in a clean environment. Requires a rebuild to catch code changes.
 - `dev` - same as run but has the current path mounted in the container, so no rebuild is needed to run tests or dev server.


Check the `Makefile` in the repository that provides a few of helper tasks and some examples on how to use docker-compose.
