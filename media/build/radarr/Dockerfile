FROM docker.homelab.csfreak.com/library/ubuntu:jammy

ENV RADARR_BRANCH="master"
ARG RADARR_RELEASE
ARG DEBIAN_FRONTEND="noninteractive"
ENV XDG_CONFIG_HOME="/config/xdg"

RUN \
    echo "**** install packages ****" && \
    apt-get update && \
    apt-get install -y \
    jq \
    curl \
    libicu70 \
    libmediainfo0v5 \
    sqlite3 && \
    echo "**** install radarr ****" && \
    mkdir -p /app/radarr/bin && \
    if [ -z ${RADARR_RELEASE+x} ]; then \
    RADARR_RELEASE=$(curl -sL "https://radarr.servarr.com/v1/update/${RADARR_BRANCH}/changes?os=linux-core&arch=x86" \
    | jq -r '.[0].version'); \
    fi && \
    curl -o \
    /tmp/radarr.tar.gz -L \
    "https://radarr.servarr.com/v1/update/${RADARR_BRANCH}/updatefile?version=${RADARR_RELEASE}&os=linux&runtime=netcore&arch=x64" && \
    tar ixzf \
    /tmp/radarr.tar.gz -C \
    /app/radarr/bin --strip-components=1 && \
    echo "UpdateMethod=docker\nBranch=${RADARR_BRANCH}\nPackageVersion=${VERSION}\nPackageAuthor=linuxserver.io" > /app/radarr/package_info && \
    echo "**** cleanup ****" && \
    apt-get clean && \
    rm -rf \
    /app/radarr/bin/Radarr.Update \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/* &&\
    chown -R 1025:100 /app/radarr

USER 1025:100
EXPOSE 7878
VOLUME /config
VOLUME /media
VOLUME /downloads

CMD ["/app/radarr/bin/Radarr", "-nobrowser", "-data=/config"]

LABEL com.servarr.radarr.version=${RADARR_RELEASE}}