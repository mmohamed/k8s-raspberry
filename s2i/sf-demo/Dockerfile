FROM ubuntu

EXPOSE 8080

ENV DEBIAN_FRONTEND=noninteractive \
    COMPOSER_HASH=e0012edf3e80b6978849f5eff0d4b4e4c79ff1609dd1e613307e16318854d24ae64f26d17af3ef0bf7cfb710ca74755a

RUN apt-get -y update && apt-get -y upgrade

RUN apt-get -y install php

RUN apt-get install -y php php-mysqlnd php-pgsql php-bcmath php-gd php-intl php-ldap \
    php-mbstring php-sqlite3 php-curl php-soap php-opcache php-xml php-memcached \
    php-gmp zip unzip php-zip libapache2-mod-php

RUN php -v

RUN apt-get install -y apache2 curl git-core

RUN curl -sS https://getcomposer.org/installer -o /tmp/composer-setup.php && \
    php -r "if (hash_file('SHA384', '/tmp/composer-setup.php') === '$COMPOSER_HASH') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('/tmp/composer-setup.php'); } echo PHP_EOL;" && \
    php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer && \
    php -r "unlink('/tmp/composer-setup.php');"

COPY conf-http/000-default.conf /etc/apache2/sites-enabled/000-default.conf
COPY conf-http/000-default.conf /etc/apache2/sites-available/000-default.conf

RUN sed -i 's/${APP_PATH}/\/opt\/app-root\/src/g' /etc/apache2/sites-enabled/000-default.conf && \
    sed -i 's/^Listen 80/Listen 0.0.0.0:8080/' /etc/apache2/ports.conf && \
    sed -i 's/${APACHE_RUN_USER}/default/' /etc/apache2/apache2.conf && \
    sed -i 's/${APACHE_RUN_GROUP}/root/' /etc/apache2/apache2.conf && \
    sed -i '170s%AllowOverride None%AllowOverride All%' /etc/apache2/apache2.conf && \
    sed -i 's/var\/www/opt\/app-root\/src\/public/' /etc/apache2/apache2.conf

ADD public /opt/app-root/src/

RUN composer install --working-dir=/opt/app-root/src

RUN service apache2 stop && \
   useradd -u 1001 -r -g 0 -d ${HOME} -s /sbin/nologin \
   -c "Default Application User" default && \
   chown -R default:root /var/log/apache2 /opt/app-root/src

CMD apachectl -d /etc/apache2 -f apache2.conf -e info -DFOREGROUND
