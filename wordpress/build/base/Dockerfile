FROM wordpress:latest

ADD https://downloads.wordpress.org/plugin/wordfence.${WORDFENCE_VERSION}.zip /usr/src/wordpress/wp-content/plugins/
ADD https://downloads.wordpress.org/plugin/updraftplus.${UPDRAFT_VERSION}.zip /usr/src/wordpress/wp-content/plugins/
RUN cd /usr/src/wordpress/wp-content/plugins && \
    unzip wordfence.latest-stable.zip && \
    unzip updraftplus.latest-stable.zip && \
    env

LABEL org.wordpress.plugin.wordfence.version=$WORDFENCE_VERSION \
      org.wordpress.plugin.updraftplus.version=$WORDFENCE_VERSION

