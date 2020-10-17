# cloudflare-dyndns

A simple shell script to update a single DNS record on cloudflare according to your own current IP address.

Use as a replacement for one of the dynamic DNS services.

**Note:** This script uses the ipify.com API to determine your current IP address. If you have privacy concerns about that, other ways of finding your IP are possible. Pull requests welcome!


## Setup and deployment

Enable a domain on cloudflare, and add an `A Record` for the host you want to use:

![cloudflare screenshot](./cloudflare-record.png)

Copy `.env.production.example` to `.env.production` and edit the settings to match your domain. Create an auth token with cloudflare that includes the scope: `Edit Zone DNS` for the zone in question.

Build and deploy the container with docker:
* `docker-compose build`
* `docker-compose up -d`

Party time.

By default, the cron job inside the container runs an IP check every 10 minutes. You can check success in the logs: `docker-compose logs`


## Development (or non-docker deployment)

Install these dependencies:
* `dig` (part of `dnsutils`)
* `curl`
* `jq`

Run `./update-ip.sh` directly.


## License
&copy; 2020, Fred Wenzel. MIT licensed, see `./LICENSE`.
