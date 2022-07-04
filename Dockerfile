FROM ubuntu:22.04
MAINTAINER krutpong "krutpong@gmail.com"

ENV DEBIAN_FRONTEND noninteractive
ENV INITRD No
ENV LANG en_US.UTF-8

RUN apt-get update
RUN apt-get install -y software-properties-common
RUN add-apt-repository -y ppa:ondrej/php

#setup timezone
RUN apt-get install -y tzdata
RUN echo "Asia/Bangkok" > /etc/timezone \
    rm /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata

#setup supervisor
RUN apt-get install -y supervisor
RUN mkdir -p /var/log/supervisor

#setup apache
RUN apt-get install -y apache2

RUN mkdir -p /var/lock/apache2 /var/run/apache2

COPY sites-available /etc/apache2/sites-available/

RUN sed -i 's/CustomLog/#CustomLog/' /etc/apache2/conf-available/other-vhosts-access-log.conf

#setup git
RUN apt-get install -y git

#setup nano
RUN apt-get install -y nano

#setup wget
RUN apt-get install -y wget

#setup php
#RUN wget 'http://mirrors.kernel.org/ubuntu/pool/multiverse/liba/libapache-mod-fastcgi/libapache2-mod-fastcgi_2.4.7~0910052141-1.2_amd64.deb'
#RUN dpkg -i libapache2-mod-fastcgi_2.4.7~0910052141-1.2_amd64.deb
RUN wget 'http://launchpadlibrarian.net/213554207/libapache2-mod-fastcgi_2.4.7~0910052141-1.2_arm64.deb'
RUN dpkg -i libapache2-mod-fastcgi_2.4.7~0910052141-1.2_arm64.deb
RUN a2enmod actions
RUN apt-get install -y php8.1-fpm
RUN apt-get install -y gcc make autoconf libc-dev pkg-config
RUN apt-get install -y php8.1-common
RUN apt-get install -y php8.1-common
RUN apt-get install -y php8.1-xml
RUN apt-get install -y php8.1-dev
RUN apt-get install -y php8.1-cli
RUN apt-get install -y php-pear
RUN apt-get install -y libmcrypt-dev
#RUN apt-get install -y php8.1-mcrypt
# RUN pecl install mcrypt-1.0.5
RUN apt-get install -y libpcre3-dev
RUN apt-get install -y php8.1-mysql
RUN apt-get install -y pwgen
RUN apt-get install -y php8.1-bcmath
RUN apt-get install -y php8.1-curl
RUN apt-get install -y php8.1-sqlite3
RUN apt-get install -y php8.1-apcu
RUN apt-get install -y php8.1-memcached
RUN apt-get install -y php8.1-redis
RUN apt-get install -y php8.1-gd
RUN apt-get install -y php8.1-mongodb
RUN apt-get install -y php8.1-mbstring
RUN apt-get install -y imagemagick
RUN apt-get install -y php8.1-imagick
RUN apt-get install -y php8.1-zip
RUN apt-get install -y libreadline-dev
RUN apt-get install -y phpunit
RUN a2enmod proxy_fcgi setenvif


RUN phpenmod mcrypt
RUN echo "extension=/usr/lib/php/20200930/mcrypt.so" > /etc/php/8.1/cli/conf.d/mcrypt.ini
RUN echo "extension=/usr/lib/php/20200930/mcrypt.so" > /etc/php/8.1/fpm/conf.d/mcrypt.ini


RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/ssl-cert-snakeoil.key -out /etc/ssl/certs/ssl-cert-snakeoil.pem -subj "/C=AT/ST=Vienna/L=Vienna/O=Security/OU=Development/CN=example.com"

RUN a2enconf php8.1-fpm
RUN a2dismod mpm_prefork
RUN a2enmod mpm_event alias
RUN a2enmod fastcgi proxy_fcgi
RUN a2enmod rewrite
RUN a2enmod ssl
RUN a2enmod headers


RUN sed -i 's/^ServerSignature/#ServerSignature/g' /etc/apache2/conf-enabled/security.conf; \
    sed -i 's/^ServerTokens/#ServerTokens/g' /etc/apache2/conf-enabled/security.conf; \
    echo "ServerSignature Off" >> /etc/apache2/conf-enabled/security.conf; \
    echo "ServerTokens Prod" >> /etc/apache2/conf-enabled/security.conf;

# Install composer
RUN apt-get install -y zip
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php composer-setup.php --install-dir=/usr/local/bin --filename=composer

# Install OCR
RUN apt-get install -y tesseract-ocr
RUN apt-get install -y tesseract-ocr-heb
RUN apt-get install -y tesseract-ocr-all

RUN apt-get clean

EXPOSE 80
EXPOSE 443
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

ADD config/index.html /var/www/index.html
ADD config/index.php /var/www/index.php
COPY config/apache2.conf /etc/apache2/apache2.conf

COPY config/apache_enable.sh apache_enable.sh
RUN chmod 744 apache_enable.sh


#VOLUME ["/var/lib/mysql"]
VOLUME ["/var/www","/var/www"]
RUN service php8.1-fpm start
CMD ["/usr/bin/supervisord"]








