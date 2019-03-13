# Zombie Driver
The Zombie Driver service is a microservice that determines if a driver is a zombie or not.
A driver is a zombie if he has driven less than 500 meters in the last 5 minutes.

## Development

The provided `docker-compose.local.yaml` has two containers:
  * `runner` - can run anything in full env, used to run tests on `make test`
  * `dev` - same as runner, but with the local path mounted so that the image doesn't need a rebuild
  
## Configuration

 * `LOCATION_SERVICE_URL` -  Base URL for the driver location service to fetch the most recent locations  defaults to: `http://driver-location.local:3000`.
 * `ZOMBIE_DRIVER_DISTANCE_IN_METERS_THRESHOLD` - defautls to 500, max distance after which a driver is no longer considered a zombie
* `ZOMBIE_DRIVER_PERIOD_IN_MINUTES` - time period for which to calculate the distance traveled

## Deployment

The `Dockerfile` provides a `release` target that has stripped development dependencies and is ready for deploy.

## Running

```
bundle exec puma
```

## Endpoints

### GET /drivers/:id

```json
{
  "id": 42,
  "zombie": true
}
```

#### Return statuses
* `200` - should return a JSON response with the zombie status
* `422` - When there is not enough data to determine the status
* `503` - When the remote location service is not available.
