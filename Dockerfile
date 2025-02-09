FROM php:8.0-fpm

USER root

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Install Postgre PDO
RUN apt-get update && apt-get install -y libpq-dev && docker-php-ext-install pdo pdo_pgsql


# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

# Install Node.js
RUN apt-get update && \
    apt-get install -y curl && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs

RUN npm install npm@latest -g && \
    npm install n -g && \
    n latest


# Copy existing application directory contents
COPY . /var/www

# Setup working directory
WORKDIR /var/www/


# Define environment variable for commands
ENV INIT_COMMANDS="composer update && \
composer install && \
composer dump-autoload && \
npm install && \
npm run build && \
php artisan config:clear && \
php artisan key:generate"

# Install dependencies and clear cache
RUN composer update && \
    composer install && \
    composer dump-autoload && \
    npm install && \
    npm run build && \
    php artisan config:clear && \
    php artisan key:generate

# Run migrations
# RUN php artisan migrate:install && \
# php artisan migrate --seed


EXPOSE 9000


# Use the environment variable in CMD
CMD bash -c "$INIT_COMMANDS && php artisan migrate:fresh --seed && php-fpm"