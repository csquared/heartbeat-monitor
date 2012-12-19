# Heartbeat Monitor


## Processes

### `web`
Web Frontend

### `monitor`
There is also a process that monitors the heartbeat and sends an email when it
stops.

## Web
This web app is a Sinatra application that implements a heartbeat monitor.
It accepts HTTP POSTs to `/heartbeat`.

### GET '/'

A self-refreshing page that is all green or all red depending on if
the heartbeat request came in within the interval.

### GET '/status'

Requires shared-secret over HTTPS Basic Auth.  (Better than nothing!)
Sets 'heartbeat' key in Redis with expiry of `HEARTBEAT_DELAY`
Returns Request body of `red` or `green` for easy machine parsing.

You can simulate red by setting the `FIREDRILL` env variable.

### (deprecated) POST '/heartbeat'

You can assume a heartbeat when the GETs come in - this is just duplicated effort that only made
sense when we had to connect to a different endpoint.

## Tests

    > redis-server
    > bundle exec t


## Configuration

    GOOGLE_AUTH_DOMAIN  -> google auth api domain
    REDISTOGO_URL    -> redis key-value store to hold and expire the heartbeat
    HEARTBEAT_DELAY  -> how long to wait for the next heartbeat (seconds)
    MONITOR_INTERVAL -> polling interval for the monitor process (seconds)
    MONITOR_EMAIL    -> who to email
    API_PASSWORD     -> HTTP Basic password for the `/heartbeat` request
    SENDGRID_USERNAME, SENDGRID_PASSWORD -> Mail credentials
    FIREDRILL        -> send red from '/status'
