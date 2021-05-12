FROM wordpress:latest

RUN apt-get update && apt-get install -y wget unzip && \
    cd /usr/src/wordpress/wp-content/plugins && \
    wget https://downloads.wordpress.org/plugin/wordfence.${WORDFENCE_VERSION}.zip && \
    wget https://downloads.wordpress.org/plugin/updraftplus.${UPDRAFTPLUS_VERSION}.zip && \
    unzip *.zip && rm -f *.zip && \
    rm -rf askimet && \
    cd /usr/src/wordpress/wp-content/themes && \
    rm -rf twenty* && \
    apt-get purge -y wget unzip && apt-get clean 

LABEL org.wordpress.plugin.wordfence.version=${WORDFENCE_VERSION} \
    org.wordpress.plugin.updraftplus.version=${UPDRAFTPLUS_VERSION}

