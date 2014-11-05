FROM        ubuntu:14.04
MAINTAINER  Love Nyberg "love.nyberg@lovemusic.se"
 
# Update apt sources
RUN echo "deb http://jp.archive.ubuntu.com/ubuntu/ trusty main restricted" > /etc/apt/sources.list
RUN echo "deb http://jp.archive.ubuntu.com/ubuntu/ trusty-updates main restricted" >> /etc/apt/sources.list
RUN echo "deb http://jp.archive.ubuntu.com/ubuntu/ trusty universe" >> /etc/apt/sources.list
RUN echo "deb http://jp.archive.ubuntu.com/ubuntu/ trusty-updates universe" >> /etc/apt/sources.list
RUN echo "deb http://jp.archive.ubuntu.com/ubuntu/ trusty multiverse" >> /etc/apt/sources.list
RUN echo "deb http://jp.archive.ubuntu.com/ubuntu/ trusty-updates multiverse" >> /etc/apt/sources.list
RUN echo "deb http://jp.archive.ubuntu.com/ubuntu/ trusty-backports main restricted universe multiverse" >> /etc/apt/sources.list
RUN echo "deb http://security.ubuntu.com/ubuntu trusty-security main restricted" >> /etc/apt/sources.list
RUN echo "deb http://security.ubuntu.com/ubuntu trusty-security universe" >> /etc/apt/sources.list
RUN echo "deb http://security.ubuntu.com/ubuntu trusty-security multiverse" >> /etc/apt/sources.list

# Update the package repository
RUN apt-get update; apt-get upgrade -y; apt-get install locales

# Configure timezone and locale
RUN echo "Asia/Tokyo" > /etc/timezone; dpkg-reconfigure -f noninteractive tzdata
RUN export LANGUAGE=en_US.UTF-8; export LANG=en_US.UTF-8; export LC_ALL=en_US.UTF-8; locale-gen en_US.UTF-8; DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales

# Install base system
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y wget curl software-properties-common

#Add PPA
##__ RUN add-apt-repository ppa:ondrej/php5
 
# Install PHP 5.5
# As well as curl, mcrypt, and mysqlnd.
RUN apt-get update; apt-get install -y --force-yes php5-cli php5 php5-mcrypt php5-curl php5-pgsql php-mime-type
 
# Let's set the default timezone in both cli and apache configs
##__ RUN sed -ie 's/\;date\.timezone\ \=/date\.timezone\ \=\ Asia\/Tokyo/g' /etc/php5/cli/php.ini
##__ RUN sed -ie 's/\;date\.timezone\ \=/date\.timezone\ \=\ Asia\/Tokyo/g' /etc/php5/apache2/php.ini

# Setup Composer
##__ RUN curl -sS https://getcomposer.org/installer | php; mv composer.phar /usr/local/bin/composer

# Setup conf for Zend Framework
RUN sed -ie 's/;include_path = ".:\/usr\/share\/php"/include_path = ".:\/var\/www\/library"/g' /etc/php5/cli/php.ini
RUN sed -ie 's/\;include_path = ".:\/usr\/share\/php"/include_path = ".:\/var\/www\/library"/g' /etc/php5/apache2/php.ini

##__ Install fastcgi & Advert Pro packages
RUN apt-get install -y libapache2-mod-fastcgi libcgi-fast-perl libdbd-mysql-perl libwww-perl

##__ Set fastcgi mime.type
ADD ./mime.types /etc/

# Activate a2enmod
RUN a2enmod rewrite

ADD ./001-docker.conf /etc/apache2/sites-available/
RUN ln -s /etc/apache2/sites-available/001-docker.conf /etc/apache2/sites-enabled/

# Restart apache2 because we changed configuration directives in php.ini
RUN service apache2 restart

# Set Apache environment variables (can be changed on docker run with -e)
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid
ENV APACHE_RUN_DIR /var/run/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_SERVERADMIN admin@localhost
ENV APACHE_SERVERNAME localhost
ENV APACHE_SERVERALIAS docker.localhost
ENV APACHE_DOCUMENTROOT /var/www

EXPOSE 80
ADD start.sh /start.sh
RUN chmod 0755 /start.sh
CMD ["bash", "start.sh"]
