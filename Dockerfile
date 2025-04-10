FROM alpine:latest

RUN apk add --no-cache ipmitool bash coreutils

COPY fan-controller.sh /usr/local/bin/fan-controller.sh
RUN chmod +x /usr/local/bin/fan-controller.sh

ENTRYPOINT ["/usr/local/bin/fan-controller.sh"]
