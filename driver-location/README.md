# Driver Location Service

Consumes location messages and stores them for later use. The app has two parts a "consumer" of events and a web app to query stored locations

## Development

The included `docker-compose.local.yaml` provides all necessary containers for local development:
  * depedency services - `redis`, `nsqd`, `nsqdlookup`
  * `runner` container that is used to run tests on `make test`
  * `dev` container that is the same as the runner one, but has the repo mounted. So that no rebuild of the image is necessary
  
There are also a few helpers in the Makefile:

 * `make deps` - brings up storage and messaging services in the background
 * `make down` - stops all running containers
 * `make dev_consumer` - start the consumer with the local path mounted
 * `make dev_test` - run the tests with the local path mounted

## Consumer
```
→ bin/consumer help start
Usage:
  consumer start

Options:
  [--topic=TOPIC]                # MQ topic to subscribe to, defaults to NSQ_TOPIC from ENV
  [--channel=CHANNEL]            # MQ channel to subscribe to, can be set with NSQ_CHANNEL from ENV. 
                                 # NOTE: Consumers will receive duplicate messages on each unique
                                 # channel connected to a topic
                                 # Default: driver_location
  [--blocking], [--no-blocking]  # Run consumer in blocking mode - faster for high loads, but blocks 
                                 # TERM until a message is received
  [--workers=N]                  # Number of concurrent workers to start
                                 # Default: 4
Run listener daemon
```

### Configuration

The consumer can be configured from `ENV` variables or command line paramteters. The `ENV` variables are:
  * `NSQ_CHANNEL` - used to manually set the channel to subscribe, defaults to the app name (`driver_location`)
  * `NSQ_TOPIC` - used to manually set the nsq topic. No default.
  * `NSQ_LOOKUPD` - address of the nsq lookup deamon ( e.g. `127.0.0.1:4161` )
  * `REDIS_URL` - URL to redis used to write events to ( e.g. `redis://127.0.0.1:6379/0` )
  
### Running

Can be run from command line with:

```
bundle exec bin/consumer start
```

Or from the provided `docker-compose.local.yaml` file to also run it with dependencies.

```
docker-compose -f docker-compose.local.yaml run runned bundle exec bin/consumer start --workers=1
```

### Deployment

The `Dockerfile` has a `consumer` build stage that has no exposed ports and removed development dependencies.

### 



## Web

Simple sinatra app that provides recent locations recorded

### Configuration 
  * `REDIS_URL` - URL to redis used to read events ( e.g. `redis://127.0.0.1:6379/0` )

### Endpoints

#### GET /health

To check if the service is running - json response
```json
{"status":"ok","app_name":"driver_location"}
```
#### GET /drivers/:id/locations?minutes=:minutes

An internal endpoint that allows other services to retrieve the drivers' locations, filtered and sorted by their addition date

```json

[
  {
    "latitude": 48.864193,
    "longitude": 2.350498,
    "updated_at": "2018-04-05T22:36:16Z"
  },
  {
    "latitude": 48.863921,
    "longitude":  2.349211,
    "updated_at": "2018-04-05T22:36:21Z"
  }
]
```

### Running

Can be started with:
```
bundle exec puma
```
### Deployment

The `Dockerfile` provides a `web` target that has stripped dependencies and exposed port, ready to deploy
