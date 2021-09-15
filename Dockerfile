FROM php:7.3-fpm

USER root

ENV TZ="Europe/Berlin"

RUN apt-get update
RUN apt-get install -y \
    build-essential \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libwebp-dev \
    libzip-dev \
    jpegoptim optipng pngquant gifsicle \
    vim \
    unzip \
    curl \
    python \
    git \
    libxml2-dev \
    zlib1g-dev \
    libbz2-dev \
    libcurl4-openssl-dev \
    libxslt-dev \
    libsqlite3-dev \
    graphicsmagick \
    locales-all \
    libgmp-dev \
    make \
    gcc \
    autoconf \
    ghostscript \
    nfs-common \
    libc-dev \
    pkg-config \
    libgd3 \
    libgd-dev \
    libssl-dev \
    libonig-dev \
    mariadb-client \
    imagemagick \
    libmagickwand-dev

RUN apt-get clean && rm -rf /var/lib/apt/lists/*

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN pecl install imagick

RUN docker-php-ext-configure gd --with-gd --with-webp-dir --with-jpeg-dir \
        --with-png-dir --with-zlib-dir --with-xpm-dir --with-freetype-dir
RUN docker-php-ext-install -j$(nproc) \
                          iconv \
                          gd \
                          shmop \
                          intl \
                          mbstring \
                          opcache \
                          pdo \
                          soap \
                          xml \
                          bz2 \
                          curl \
                          fileinfo\
                          ftp \
                          gettext \
                          simplexml \
                          tokenizer \
                          xsl \
                          pdo_mysql \
                          pdo_sqlite \
                          mysqli \
                          bcmath \
                          gmp \
                          zip \
                          sockets \
                          dom \
                          intl

RUN pecl install apcu-5.1.20
RUN docker-php-ext-enable apcu

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN composer --version

RUN pecl install redis
RUN docker-php-ext-enable redis

RUN pecl install xdebug-2.8.0 && docker-php-ext-enable xdebug

RUN echo "xdebug.max_nesting_level=-1" >> /usr/local/etc/php/conf.d/xdebug.ini

RUN sed -i "s/^user = .*/user = root/g" /usr/local/etc/php-fpm.d/www.conf && \
    sed -i "s/^group = .*/group = root/g" /usr/local/etc/php-fpm.d/www.conf

WORKDIR /usr/share/nginx/html/app

EXPOSE 9000
CMD ["php-fpm"]
