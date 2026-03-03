FROM wordpress:6.9.1-php8.3-apache

# Install MariaDB server, supervisor, and unzip
RUN apt-get update && \
    apt-get install -y mariadb-server supervisor unzip && \
    rm -rf /var/lib/apt/lists/*

# Install WP-CLI
RUN curl -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x /usr/local/bin/wp

# PHP configuration
COPY config/php.ini /usr/local/etc/php/conf.d/custom.ini

# Supervisor configuration
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Stage custom theme and plugin for production
COPY themes/plum-village /usr/src/plum-village-theme/
COPY plugins/plum-village-blocks /usr/src/plum-village-blocks/

# Stage LearnDash zip for production install
COPY sfwd-lms.5.0.2.zip /usr/src/sfwd-lms.zip

# Download BuddyPress at build time
RUN curl -L -o /usr/src/buddypress.zip \
    https://downloads.wordpress.org/plugin/buddypress.latest-stable.zip

# WordPress database config for local MariaDB
# WORDPRESS_DB_PASSWORD must be set via fly secrets in production
ENV WORDPRESS_DB_HOST=127.0.0.1
ENV WORDPRESS_DB_USER=wordpress
ENV WORDPRESS_DB_NAME=wordpress

# Entrypoint script
COPY scripts/entrypoint.sh /usr/local/bin/entrypoint.sh

EXPOSE 80

ENTRYPOINT ["entrypoint.sh"]
