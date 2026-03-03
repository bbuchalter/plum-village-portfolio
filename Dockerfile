FROM wordpress:6.9.1-php8.3-apache

# Install MariaDB server and supervisor
RUN apt-get update && \
    apt-get install -y mariadb-server supervisor && \
    rm -rf /var/lib/apt/lists/*

# Install WP-CLI
RUN curl -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x /usr/local/bin/wp

# PHP configuration
COPY config/php.ini /usr/local/etc/php/conf.d/custom.ini

# Supervisor configuration
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# WordPress database config for local MariaDB
# WORDPRESS_DB_PASSWORD must be set via fly secrets in production
ENV WORDPRESS_DB_HOST=127.0.0.1
ENV WORDPRESS_DB_USER=wordpress
ENV WORDPRESS_DB_NAME=wordpress

# Entrypoint script
COPY scripts/entrypoint.sh /usr/local/bin/entrypoint.sh

EXPOSE 80

ENTRYPOINT ["entrypoint.sh"]
