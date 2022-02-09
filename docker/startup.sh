# Please do not manually call this file!
# This script is run by the docker container when it is "run"


# Ensure apache and supervisor are not running
service supervisor stop
service apache2 stop


# Remap user IDs within this container to match host.
/bin/bash /var/www/site/scripts/remap-user.sh


# create the environment file
php /var/www/site/scripts/create-env-file.php /var/www/site/.env


# Sleep for 10 seconds to wait for the database to be available
# @todo - replace this with a script that blocks until database becomes available.
sleep 10


# Ensure web-user has write access to storage area
chmod 770 -R /var/www/site/storage && chown root:www-data -R /var/www/site/storage


# Run migrations
php /var/www/site/artisan migrate


# Start the supervisor process which will be in control of ensuring apache is running etc.
service supervisor start


# Start the cron service in the foreground
cron -f
