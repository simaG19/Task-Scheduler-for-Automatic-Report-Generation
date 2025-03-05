FROM php:8.2-apache


WORKDIR /var/www/html


RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip


RUN apt-get clean && rm -rf /var/lib/apt/lists/*


RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd


COPY --from=composer:latest /usr/bin/composer /usr/bin/composer


COPY . .

RUN composer install --no-dev --optimize-autoloader


RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache


RUN a2enmod rewrite


EXPOSE 80


CMD ["apache2-foreground"]
