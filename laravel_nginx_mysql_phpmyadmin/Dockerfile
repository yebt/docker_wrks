
FROM php:7.4.30-fpm-alpine3.16

COPY src /var/www/html
WORKDIR /var/www/html

#  install dependencies
# imagemagick

RUN apk update && \
apk upgrade && \
apk add imagemagick && \
apk add imagemagick-dev && \
apk add autoconf &&  \
apk add automake && \
apk add cmake && \
apk add make && \
apk add gcc && \
apk add g++

RUN pecl install imagick
RUN docker-php-ext-enable imagick
# # enable mysql
RUN docker-php-ext-install pdo pdo_mysql mysqli;
#Conposer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
# da permisos para editar los archivos en esta ruta del container
RUN chown -R www-data:www-data /var/www
RUN chmod 755 /var/www

# Permisos en el proyecto de elaravel
RUN chown -R $USER:www-data /var/www/html/storage
RUN chown -R $USER:www-data /var/www/html/bootstrap/cache
    