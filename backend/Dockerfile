FROM dunglas/frankenphp:1-php8.4

ARG NODE_VERSION=20

RUN install-php-extensions bcmath intl mbstring pdo_mysql zip pcntl redis

RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

COPY docker/php.ini /usr/local/etc/php/conf.d/parkirgo.ini
COPY docker/Caddyfile /etc/caddy/Caddyfile
COPY docker/entrypoint.sh /usr/local/bin/parkirgo-entrypoint

RUN chmod +x /usr/local/bin/parkirgo-entrypoint

COPY . /var/www/html

RUN composer install --no-dev --optimize-autoloader

RUN php artisan storage:link

EXPOSE 80 5173

ENTRYPOINT ["parkirgo-entrypoint"]
CMD ["php", "artisan", "octane:start", "--server=frankenphp", "--host=0.0.0.0", "--port=80", "--admin-port=2019"]
