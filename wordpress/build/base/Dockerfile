FROM wordpress:latest
ADD https://downloads.wordpress.org/plugin/wordfence.latest-stable.zip https://downloads.wordpress.org/plugin/updraftplus.latest-stable.zip /usr/src/wordpress/wp-content/plugins/
CMD cd /usr/src/wordpress/wp-content/plugins && \
    unzip wordfence.latest-stable.zip && \
    unzip updraftplus.latest-stable.zip
