FROM docker.homelab.csfreak.com/library/alpine:latest
ARG UNRAR_VERSION=6.1.4

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
        python3-dev

RUN echo "**** install packages ****" && \
    apk add --no-cache \
        curl \
        libxml2 \
        libxslt \
        openssl \
        p7zip \
        py3-pip \
        python3 \
        wget

RUN echo "**** install python packages ****" && \
    pip3 install --no-cache-dir -U \
        pip && \
    pip install --no-cache-dir \
        apprise \
        chardet \
        lxml \
        pynzbget \
        py7zr \
        rarfile \
        six && \
    ln -sf /usr/bin/python3 /usr/bin/python
RUN echo "**** install unrar from source ****" && \
    mkdir /tmp/unrar && \
    curl -o \
      /tmp/unrar.tar.gz -L \
      "https://www.rarlab.com/rar/unrarsrc-${UNRAR_VERSION}.tar.gz" && \  
    tar xf \
      /tmp/unrar.tar.gz -C \
      /tmp/unrar --strip-components=1 && \
    cd /tmp/unrar && \
    make && \
    install -v -m755 unrar /usr/bin && \
    cd /

RUN echo "**** download nzbget ****" && \
    wget https://nzbget.net/download/nzbget-latest-bin-linux.run && \
    echo "**** install nzbget ****" && \
    sh nzbget-latest-bin-linux.run

RUN echo "**** cleanup ****" && \
    apk del --purge \
        build-dependencies && \
    rm -rf \
        /root/.cache \
        /root/.cargo \
        /tmp/* && \
    rm nzbget-latest-bin-linux.run

COPY --chown=0:0 --chmod=555 entrypoint.sh /


ENV NZBGET_CONFIG_OutputMode=log \
    NZBGET_CONFIG_WriteLog=none \
    NZBGET_CONFIG_ConfigTemplate=/nzbget/webui/nzbget.conf.template \
    NZBGET_CONFIG_ControlIP=0.0.0.0 \
    NZBGET_CONFIG_ControlPort=6789 \
    NZBGET_CONFIG_ControlUsername= \
    NZBGET_CONFIG_ControlPassword= \
    NZBGET_CONFIG_MainDir=/downloads \
    NZBGET_CONFIG_WebDir=/nzbget/webui/ \
    NZBGET_CONFIG_ErrorTarget=screen \
    NZBGET_CONFIG_WarningTarget=screen \
    NZBGET_CONFIG_InfoTarget=screen \
    NZBGET_CONFIG_DetailTarget=none

EXPOSE 6789
VOLUME /config
VOLUME /downloads

ENTRYPOINT [ "/entrypoint.sh" ]

CMD ["/nzbget/nzbget", "-s", "-c", "/config/nzbget.conf"]