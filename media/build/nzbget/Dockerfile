FROM alpine:latest

RUN echo "**** install build packages ****" && \
    apk add --no-cache --upgrade --virtual=build-dependencies \
        cargo \
        g++ \
        libc-dev \
        libffi-dev \
        libxml2-dev \
        libxslt-dev \
        make \
        openssl-dev \
        python3-dev && \
    echo "**** install packages ****" && \
    apk add --no-cache \
        curl \
        libxml2 \
        libxslt \
        openssl \
        p7zip \
        py3-pip \
        python3 \
        unrar \
        wget && \
    echo "**** install python packages ****" && \
    pip3 install --no-cache-dir -U \
        pip && \
    pip install --no-cache-dir \
        apprise \
        chardet \
        lxml \
        pynzbget \
        rarfile && \
    ln -s /usr/bin/python3 /usr/bin/python && \
    echo "**** download nzbget ****" && \
    wget https://nzbget.net/download/nzbget-latest-bin-linux.run && \
    echo "**** download nzbget ****" && \
    sh nzbget-latest-bin-linux.run && \
    echo "**** cleanup ****" && \
    apk del --purge \
        build-dependencies && \
    rm -rf \
        /root/.cache \
        /root/.cargo \
        /tmp/* && \
    rm nzbget-latest-bin-linux.run
    
EXPOSE 6789
VOLUME /config
VOLUME /downloads

CMD ["/nzbget/nzbget", "-s", "-c", "/config/nzbget.conf", "-o", "OutputMode=log"]