FROM wordpress-base:latest

RUN apt-get update && apt-get install -y wget unzip && \
    cd /usr/src/wordpress/wp-content/plugins && \
    wget https://downloads.wordpress.org/plugin/wordfence.${DUO-WORDPRESS_VERSION}.zip && \
    wget https://downloads.wordpress.org/plugin/updraftplus.${CONTACT-FORM-7_VERSION}.zip && \
    unzip wordfence.*.zip && unzip updraftplus.*.zip && rm -f *.zip && \
    cd /usr/src/wordpress/wp-content/themes && \
    wget https://downloads.wordpress.org/theme/clean-corportae.${CLEAN-CORPORATE_VERSION}.zip && \
    apt-get purge -y wget unzip && apt-get clean 

LABEL org.wordpress.plugin.duo-wordpress.version=${DUO-WORDPRESS_VERSION} \
    org.wordpress.plugin.contact-form-7.version=${CONTACT-FORM-7_VERSION} \
    org.wordpress.theme.clean-corporate.version=${CLEAN-CORPORATE_VERSION}
