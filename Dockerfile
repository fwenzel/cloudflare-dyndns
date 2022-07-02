FROM alpine:latest

# Disable watchtower container updating for this project
LABEL com.centurylinklabs.watchtower.enable="false"

WORKDIR /opt/cfdd

RUN apk add --no-cache bind-tools curl jq

COPY src/ .

# Crontab
# m h  dom mon dow   command
RUN echo '*/10 * * * *    cd /opt/cfdd/; ./update-ip.sh >&2' > /etc/crontabs/root

ENTRYPOINT ["crond", "-f"]
