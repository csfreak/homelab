FROM mono:slim

ENV SONARR_BRANCH="main"
ARG SONARR_VERSION
ARG DEBIAN_FRONTEND="noninteractive"


RUN \
  echo "**** install packages ****" && \
  apt-get update && \
  apt-get install -y \
    jq curl && \
  echo "**** install sonarr ****" && \
  mkdir -p /app/sonarr/bin && \
  if [ -z ${SONARR_VERSION+x} ]; then \
    SONARR_VERSION=$(curl -sX GET http://services.sonarr.tv/v1/releases \
    | jq -r ".[] | select(.branch==\"$SONARR_BRANCH\") | .version"); \
  fi && \
  curl -o \
    /tmp/sonarr.tar.gz -L \
    "https://download.sonarr.tv/v3/${SONARR_BRANCH}/${SONARR_VERSION}/Sonarr.${SONARR_BRANCH}.${SONARR_VERSION}.linux.tar.gz" && \
  tar xf \
    /tmp/sonarr.tar.gz -C \
    /app/sonarr/bin --strip-components=1 && \
  echo "UpdateMethod=docker\nBranch=${SONARR_BRANCH}\nPackageVersion=${VERSION}\nPackageAuthor=[homelab.csfreak.com](https://console-openshift-console.apps.homelab.csfreak.com)" > /app/sonarr/package_info && \
  rm -rf /app/sonarr/bin/Sonarr.Update && \
  echo "**** cleanup ****" && \
  apt-get clean && \
  rm -rf \
    /tmp/* \
    /var/tmp/* && \
  chown -R 1000: /app/sonarr

USER 1000:1000
EXPOSE 8989
VOLUME /config
VOLUME /media
VOLUME /downloads

CMD ["mono", "--debug", "/app/sonarr/bin/Sonarr.exe", "-nobrowser", "-data=/config"]