FROM ubuntu:20.04

RUN apt-get update && apt-get dist-upgrade -y

# Install php 8.1 from Ondrej PPA
RUN apt-get update && apt-get install -y software-properties-common apt-transport-https \
  && add-apt-repository ppa:ondrej/php -y \
  && apt-get update \
  && apt-get install php8.1-cli -y

# Install the relevant packages
RUN apt-get install -y \
  vim apache2 libapache2-mod-php8.1 curl git cron supervisor \
  php8.1-mysqlnd php8.1-pgsql php8.1-curl php8.1-zip php8.1-xml php8.1-zip \
  php8.1-pdo php8.1-mbstring

# Install composer 2
RUN apt-get update \
  && curl -sS https://getcomposer.org/installer | php \
  && mv composer.phar /usr/bin/composer \
  && chmod +x /usr/bin/composer

# Enable the php mod we just installed
RUN a2enmod php8.1

# expose port 80 and 443 for the web requests
EXPOSE 80
EXPOSE 443

# Increase PHP's default settings
# - set max allowed memory to unlimited
# - set display errors to on (will disable error logging at application level
#   if in production mode)
# - increase max POST size
# - increate max upload file size
# - set max execution and input time to 5 minutes. (you may wish to adjust.)
RUN  sed -i 's;memory_limit = .*;memory_limit = -1;' /etc/php/8.1/apache2/php.ini \
  && sed -i 's;memory_limit = .*;memory_limit = -1;' /etc/php/8.1/cli/php.ini \
  && sed -i 's;display_errors = .*;display_errors = On;' /etc/php/8.1/apache2/php.ini \
  && sed -i 's;display_errors = .*;display_errors = On;' /etc/php/8.1/cli/php.ini \
  && sed -i 's;post_max_size = .*;post_max_size = 4000M;' /etc/php/8.1/apache2/php.ini \
  && sed -i 's;upload_max_filesize = .*;upload_max_filesize = 2000M;' /etc/php/8.1/apache2/php.ini \
  && sed -i 's;max_execution_time = .*;max_execution_time = 300;' /etc/php/8.1/apache2/php.ini \
  && sed -i 's;max_execution_time = .*;max_execution_time = 300;' /etc/php/8.1/cli/php.ini \
  && sed -i 's;max_input_time = .*;max_input_time = 300;' /etc/php/8.1/apache2/php.ini

# Manually set the apache environment variables in order to get apache to work immediately.
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2

# It appears that the new apache requires these env vars as well
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2/apache2.pid

# Set up url rewrite ability
RUN a2enmod rewrite

# Add the cron and supervsor jobs.
ADD docker/crons.conf /root/crons.conf
ADD docker/supervisord.conf /etc/supervisor/conf.d/laravel-services.conf
RUN chmod 755 /etc/supervisor/conf.d/laravel-services.conf
RUN crontab /root/crons.conf && rm /root/crons.conf

# Update our apache sites available with the config we created
ADD docker/apache-config.conf /etc/apache2/sites-available/000-default.conf


# Add our startup script to the container for later use
COPY --chown=root:root ./docker/startup.sh  /root/.

# Add our site to the container. As much as possible should be done before this
# step for cached builds.
COPY --chown=root:www-data ./site /var/www/site

# Install PHP packages
RUN cd /var/www/site && composer install && chown root:www-data -R vendor

# Make the uploads folder writeable
RUN chown root:www-data /var/www \
  && chmod 770 -R /var/www/site/storage

# Set workdir to site folder for when people feel the need to enter the container and poke around.
WORKDIR /var/www/site

# Execute the containers startup script which will start many processes/services
# The startup file was already added when we added "project"
CMD ["/bin/bash", "/root/startup.sh"]
