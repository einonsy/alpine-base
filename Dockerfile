FROM alpine:3.11
LABEL MAINTAINER JasonEinon 

RUN apk update \
    && apk upgrade \
    && apk add curl wget bash \
    && apk add openssl \
    && apk add supervisor

RUN mkdir -m 0777 /logs \
    && mkdir -m 0777 /data \
    && mkdir -m 0777 /config


COPY supervisord.conf /etc/supervisor/supervisord.conf

RUN mkdir -m 0755 /usr/local/image-startup
COPY bin/image-startup.sh /usr/local/sbin/image-startup.sh
RUN chmod 755 /usr/local/sbin/image-startup.sh

ENTRYPOINT [ "/usr/local/sbin/image-startup.sh" ]
