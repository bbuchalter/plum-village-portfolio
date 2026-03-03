FROM wordpress:6.9.1-php8.3-apache

RUN apt-get update && \
    apt-get install -y --no-install-recommends unzip && \
    rm -rf /var/lib/apt/lists/*

RUN curl -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x /usr/local/bin/wp

COPY config/php.ini /usr/local/etc/php/conf.d/custom.ini

# Bake WordPress core files into the image
RUN cp -a /usr/src/wordpress/. /var/www/html/

COPY themes/plum-village /var/www/html/wp-content/themes/plum-village/
COPY plugins/plum-village-blocks /var/www/html/wp-content/plugins/plum-village-blocks/

COPY sfwd-lms.5.0.2.zip /tmp/sfwd-lms.zip
RUN unzip -q /tmp/sfwd-lms.zip -d /var/www/html/wp-content/plugins/ && rm /tmp/sfwd-lms.zip

RUN curl -L -o /tmp/buddypress.zip \
    https://downloads.wordpress.org/plugin/buddypress.latest-stable.zip && \
    unzip -q /tmp/buddypress.zip -d /var/www/html/wp-content/plugins/ && rm /tmp/buddypress.zip

RUN chown -R www-data:www-data /var/www/html/wp-content

COPY scripts/entrypoint.sh /usr/local/bin/entrypoint.sh

EXPOSE 80

ENTRYPOINT ["entrypoint.sh"]
CMD ["apache2-foreground"]
