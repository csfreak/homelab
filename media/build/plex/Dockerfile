FROM ubi8/ubi:latest

ENV \
  TERM="xterm" \
  LANG="C.UTF-8" \
  LC_ALL="C.UTF-8"


COPY plex.repo /etc/yum.repos.d/
COPY entrypoint.sh /

RUN \
# Enable plex repo
    dnf config-manager --disableplugin subscription-manager --add-repo /etc/yum.repos.d/plex.repo &&\
    \
# Update and get dependencies
    dnf upgrade --disableplugin subscription-manager --refresh -y && \
    dnf -y --disableplugin subscription-manager --downloaddir /tmp/ download plexmediaserver && \
    rpm -ivh --noscripts /tmp/plexmediaserver*.rpm && \
    \
# Setup directories
    mkdir -p \
      /config \
      /transcode \
      /data \
    && \
    \
# Cleanup
    dnf autoremove -y --disableplugin subscription-manager && \
    dnf clean all -y --disableplugin subscription-manager && \
    rm /tmp/plexmediaserver*.rpm && \
    groupadd -g 1000730000 plex && \
    useradd -u 1000730000 -g 1000730000 -d /config/Library/Application\ Support/ -s /bin/nologin plex

EXPOSE 32400/tcp 8324/tcp 32469/tcp 1900/udp 32410/udp 32412/udp 32413/udp 32414/udp
VOLUME /config /transcode /data
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/lib/plexmediaserver/Plex\\ Media\\ Server"]
