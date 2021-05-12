FROM wordpress-base:latest

RUN apt-get update && apt-get install -y wget unzip && \
    cd /usr/src/wordpress/wp-content/plugins && \
    wget https://downloads.wordpress.org/plugin/duo-wordpress.${DUO_WORDPRESS_VERSION}.zip && \
    wget https://downloads.wordpress.org/plugin/contact-form-7.${CONTACT_FORM_7_VERSION}.zip && \
    unzip duo-worpress.*.zip && unzip contact-form-7.*.zip && rm -f *.zip && \
    cd /usr/src/wordpress/wp-content/themes && \
    wget https://downloads.wordpress.org/theme/clean-corporate.${CLEAN_CORPORATE_VERSION}.zip && \
    unzip clean-corporate-7.*.zip && rm -f *.zip && \
    apt-get purge -y wget unzip && apt-get clean 

LABEL org.wordpress.plugin.duo-wordpress.version=${DUO_WORDPRESS_VERSION} \
    org.wordpress.plugin.contact-form-7.version=${CONTACT_FORM_7_VERSION} \
    org.wordpress.theme.clean-corporate.version=${CLEAN_CORPORATE_VERSION}
