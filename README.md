# Dockerized Laravel 9
This is a template project for quickly getting started with developing Laravel 9 (LTS) projects.

This makes use of Ubuntu 20.04 as the base image as it is easy enough to tweak and extend for a 
broader audience. E.g.
I am guessing more people know how to configure Ubuntu than Alpine Linux.

You may be more interested in the [Laravel README](./laravel.md).

## Getting Started

1. Create an `.env` file from the `.env.example` file and fill in the details.
1. Build the Docker image by running `docker-compose build`
1. Run the site by running `docker-compose up -d`
    * When developing the site, you may wish to run `docker-compose -f docker-dev-compose.yml` to 
    * run with a volume
for the site so that changes to the take effect immediately without needint to rebuild and deploy.


## Services

### PostgreSQL
This codebase is set up to deploy and use a PostgreSQL database. MySQL and MariaDB are more commonly 
used in the PHP world, but I find the PostgreSQL has too many useful features to be ignored. 
Primarily:

 * [Native UUID type](https://www.postgresql.org/docs/9.1/datatype-uuid.html)
 * [Parallel queries](https://blog.programster.org/postgresql-parallel-queries).


### Supervisor & Laravel Queue
This image comes with [Supervisor](http://supervisord.org/) installed. 
This has been [configured to manage the
Laravel queu](https://blog.programster.org/getting-started-with-laravel-queues-and-background-jobs). 
It also manages the Apache web server to ensure that it comes back online if it should fail for 
whatever reason. You can edit the`docker/supervisord.conf` file in order to add other processes for 
it to manage.


### Cron
This image comes with the cron service, which is also used as the foreground process for the 
container to keep it running. Use the cron service when you wish for a script to run at a certain 
point in time. For everything else, I would advise using [Supervisor](http://supervisord.org/).


### MailHog
Mailhog is configured in the `docker-compose.yml` and `docker-dev-compose.yml` files for
you to easily test/dev emails without having to hook up to an actual SMTP server. To test
that this works, you can do the following:

1. Enter the app container with: `docker exec -it app /bin/bash`
2. Run the artisan tinker tool: `php artisan tinker`
3. Get Laravel to send an email: with:
  ```php
  $callback = function($msg) {
      $msg->to('myemail@gmail.com')
          ->subject('Test Email')
          ->from('anotherEmail@gmail.com');
  };

  Mail::raw('Hello World!', $callback);
  ```
4. Navigate to [http://localhost:8025/](http://localhost:8025/) in your browser to view the emails.


## Extra Info

### HTTPS / SSL
There are a million different ways to configure SSL so there is no point in me implementing one of 
them in this template. For simplicity, I would create create an `ssl` volume at the top level, and 
tweak your apapche configuration to make use of it as well as adding `RUN a2enmod ssl` to the 
Dockerfile, but you may wish to 
[use a reverse proxy](https://blog.programster.org/jwilder-reverse-proxy-with-wildcard-ssl) or have 
something set up with AWS etc.
