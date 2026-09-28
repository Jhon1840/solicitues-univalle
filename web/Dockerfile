FROM php:8.4-cli
RUN apt-get update && apt-get install -y libpq-dev libzip-dev zip unzip && docker-php-ext-install pdo_pgsql zip
WORKDIR /var/www/html
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
COPY . .
RUN composer install --no-interaction --prefer-dist --optimize-autoloader
EXPOSE 8000
CMD ["sh", "-c", "php artisan migrate --force && (php artisan storage:link || true) && php artisan db:seed --force && php artisan serve --host=0.0.0.0 --port=8000"]
