ARG PHP_VERSION=7.4

# Set master image
FROM php:${PHP_VERSION}-fpm-alpine AS laravel

# Copy composer.lock and composer.json
COPY composer.lock composer.json /var/www/html/

# Set working directory
WORKDIR /var/www/html

# Install Additional dependencies
RUN apk update && apk add --no-cache \
    build-base shadow vim curl curl-dev \
    php7 \
    php7-fpm \
    php7-intl \
    php7-common \
    php7-pdo \
    php7-pdo_mysql \
    php7-mysqli \
    php7-mcrypt \
    php7-mbstring \
    php7-xml \
    php7-openssl \
    php7-json \
    php7-phar \
    php7-zip \
    php7-gd \
    php7-dom \
    php7-session \
    php7-zlib

# Add and Enable PHP-PDO Extenstions
RUN docker-php-ext-install pdo pdo_mysql curl
# RUN docker-php-ext-enable pdo_mysql

# Install PHP Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Remove Cache
RUN rm -rf /var/cache/apk/*

# Add UID '1000' to www-data
RUN usermod -u 1000 www-data

# Copy existing application directory permissions
COPY --chown=www-data:www-data . /var/www/html

# Copy laravel.ini config
COPY ./laravel.ini /usr/local/etc/php/conf.d/laravel.ini

RUN sed -i 's/9000/9000/' /usr/local/etc/php-fpm.d/zz-docker.conf

# Change current user to www
USER www-data

# Start php-fpm server
CMD ["php-fpm"]