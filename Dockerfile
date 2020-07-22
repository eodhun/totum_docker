FROM amd64/debian:10.4-slim
EXPOSE 80 443

RUN DEBIAN_FRONTEND=noninteractive apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install lsb-release apt-transport-https ca-certificates gnupg-agent curl && rm -rf /var/cache/apt
RUN curl -o /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
RUN echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php7.3.list
RUN sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
RUN curl -o ACCC4CF8.asc https://www.postgresql.org/media/keys/ACCC4CF8.asc && apt-key add ACCC4CF8.asc && rm ACCC4CF8.asc

RUN DEBIAN_FRONTEND=noninteractive apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y postgresql-12 apache2 php7.3 php7.3-cli libapache2-mod-php7.3 php7.3-fpm php7.3-json php7.3-pdo php7.3-mysql php7.3-zip php7.3-gd php7.3-mbstring php7.3-curl php7.3-xml php7.3-bcmath php7.3-opcache php7.3-pgsql git sudo supervisor locales && rm -rf /var/cache/apt
RUN a2enmod rewrite proxy_fcgi setenvif
RUN a2enconf php7.3-fpm

RUN locale-gen en_US.UTF-8
RUN DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales 

RUN curl -o ioncube.tar.gz https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz && tar -xvzf ioncube.tar.gz && cp ./ioncube/ioncube_loader_lin_7.3.so /usr/lib/php/20180731/ && rm -rf ./ioncube ioncube.tar.gz

RUN echo "zend_extension=/usr/lib/php/20180731/ioncube_loader_lin_7.3.so" >> /etc/php/7.3/apache2/php.ini
RUN echo "zend_extension=/usr/lib/php/20180731/ioncube_loader_lin_7.3.so" >> /etc/php/7.3/cli/php.ini

RUN echo "short_open_tag = On" >> /etc/php/7.3/apache2/php.ini
RUN echo "short_open_tag = On" >> /etc/php/7.3/cli/php.ini

RUN echo "opcache.enable_cli = On" >> /etc/php/7.3/apache2/php.ini
RUN echo "opcache.enable_cli = On" >> /etc/php/7.3/cli/php.ini

RUN echo "<Directory "/var/www/html">" >>  /etc/apache2/sites-enabled/000-default.conf
RUN echo "AllowOverride All" >>  /etc/apache2/sites-enabled/000-default.conf
RUN echo "</Directory>" >>  /etc/apache2/sites-enabled/000-default.conf

RUN rm -rf /var/www/html
RUN git clone https://github.com/totumonline/totum-mit.git /var/www/totum-mit && chown -R www-data:www-data /var/www/
RUN ln -s /var/www/totum-mit/http /var/www/html 

RUN echo "0 * * * *       cd /var/www/totum-mit/Crons && php -f cleanTmp.php > /dev/null 2>&1" | crontab -u root -
RUN echo "*/10 * * * *    cd /var/www/totum-mit-master/Crons && php -f every10minutes.php  > /dev/null 2>&1" | crontab -u root -

RUN bash -c 'echo -e "[supervisord]\nnodaemon=true\n[program:sshd]\ncommand=service ssh start\n[program:apache2]\ncommand=service apache2 start\n[program:postgresql]\ncommand=service postgresql start\n[program:cron]\ncommand = cron -f -L 15\nautostart=true\nautorestart=true\n" >> /etc/supervisor/conf.d/supervisord.conf'

RUN echo "CREATE USER totum_user WITH ENCRYPTED PASSWORD 'totum_pass';" >> /postgresql.sql
RUN echo "CREATE DATABASE totum;" >> /postgresql.sql
RUN echo "GRANT ALL PRIVILEGES ON DATABASE totum TO totum_user;" >> /postgresql.sql

RUN service postgresql start && sudo -u postgres psql -f /postgresql.sql

VOLUME ["/var/lib/postgresql"]
CMD ["/usr/bin/supervisord"]
