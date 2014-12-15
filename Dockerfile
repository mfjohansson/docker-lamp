FROM ubuntu:trusty
MAINTAINER Magnus Johansson <ao62x@notsharingmy.info>

# Install packages
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
  apt-get -y install \
  supervisor git apache2=2.4.7-1ubuntu4.1 libapache2-mod-php5 \
  mysql-server=5.5.40-0ubuntu0.14.04.1 \
  php5-mysql pwgen php-apc php5-mcrypt

# Add image configuration and scripts
ADD start-apache2.sh /start-apache2.sh
ADD start-mysqld.sh /start-mysqld.sh
ADD run.sh /run.sh
RUN chmod 755 /*.sh
ADD my.cnf /etc/mysql/conf.d/my.cnf
ADD supervisord-apache2.conf /etc/supervisor/conf.d/supervisord-apache2.conf
ADD supervisord-mysqld.conf /etc/supervisor/conf.d/supervisord-mysqld.conf

# Remove pre-installed database
RUN rm -rf /var/lib/mysql/*

# Add MySQL utils
ADD create_mysql_admin_user.sh /create_mysql_admin_user.sh
RUN chmod 755 /*.sh

# config to enable .htaccess
RUN a2enmod rewrite
RUN a2enmod ssl

# Enable SSL site
ADD apache2_2.4.7-1ubuntu4.1/sites-available/default-ssl.conf /etc/apache2/sites-enabled/default-ssl.conf

# Configure /app folder with sample app
RUN mkdir -p /app && rm -fr /var/www/html && ln -s /app /var/www/html

#Enviornment variables to configure php
ENV PHP_UPLOAD_MAX_FILESIZE 10M
ENV PHP_POST_MAX_SIZE 10M

# Install phpMyAdmin
#RUN mysqld & \
#	service apache2 start; \
#	sleep 5; \
#	printf y\\n\\n\\n1\\n | apt-get install -y phpmyadmin; \
#	sleep 15; \
#	mysqladmin -u root shutdown

#RUN sed -i "s#// \$cfg\['Servers'\]\[\$i\]\['AllowNoPassword'\] = TRUE;#\$cfg\['Servers'\]\[\$i\]\['AllowNoPassword'\] = TRUE;#g" /etc/phpmyadmin/config.inc.php

# Add volumes for MySQL 
VOLUME  ["/etc/mysql", "/var/lib/mysql" ]

EXPOSE 80 443 3306
CMD ["/run.sh"]
