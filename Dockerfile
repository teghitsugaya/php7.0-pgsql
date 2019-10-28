FROM php:7.1-apache
RUN apt-get update \
  && apt-get install --no-install-recommends -y libpq-dev \
  && docker-php-ext-install pgsql \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*


ENV APACHE_RUN_USER www-data 
ENV APACHE_RUN_GROUP www-data 

EXPOSE 80 
ADD index.php /var/www/site/index.php
ADD apache-config.conf /etc/apache2/sites-enabled/000-default.conf

COPY . /usr/src/myapp
WORKDIR /usr/src/myapp
