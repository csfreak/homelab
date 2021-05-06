FROM wordpress:latest

RUN cd /usr/src/wordpress/wp-content/plugins && \
    curl https://downloads.wordpress.org/plugin/wordfence.${WORDFENCE_VERSION}.zip -o wordfence.zip && \
    curl https://downloads.wordpress.org/plugin/updraftplus.${UPDRAFT_VERSION}.zip -o updraftplus.zip && \
    unzip wordfence.zip && \
    unzip updraftplus.zip

LABEL org.wordpress.plugin.wordfence.version=${WORDFENCE_VERSION} \
      org.wordpress.plugin.updraftplus.version=${UPDRAFTPLUS_VERSION}

