FROM wordpress:latest

RUN apt-get install wget && \
    cd /usr/src/wordpress/wp-content/plugins && \
    wget https://downloads.wordpress.org/plugin/wordfence.${WORDFENCE_VERSION}.zip && \
    wget https://downloads.wordpress.org/plugin/updraftplus.${UPDRAFT_VERSION}.zip
    unzip wordfence.latest-stable.zip && \
    unzip updraftplus.latest-stable.zip

LABEL org.wordpress.plugin.wordfence.version=${WORDFENCE_VERSION} \
      org.wordpress.plugin.updraftplus.version=${UPDRAFTPLUS_VERSION}

