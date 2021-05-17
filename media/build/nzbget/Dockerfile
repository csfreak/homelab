FROM alpine:latest

RUN apk add wget &&\
    wget https://nzbget.net/download/nzbget-latest-bin-linux.run && \
    sh nzbget-latest-bin-linux.run && \
    rm nzbget-latest-bin-linux.run

EXPOSE 6789
VOLUME /config
VOLUME /downloads

CMD ["/nzbget/nzbget", "-s", "-c", "/config/nzbget.conf"]