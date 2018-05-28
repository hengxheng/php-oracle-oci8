FROM nimmis/apache

# disable interactive functions
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get upgrade -y
RUN apt-get install python-software-properties -y
RUN LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php -y
RUN apt-get update
RUN apt-get install -y php7.2
RUN apt-get install -y php-pear php7.2-curl php7.2-dev php7.2-gd php7.2-mbstring php7.2-zip php7.2-mysql php7.2-xml

ENV LD_LIBRARY_PATH /usr/local/instantclient_12_1/

RUN apt-get install -y --no-install-recommends apt-utils
RUN apt-get install -y unzip libaio-dev sendmail
RUN apt-get clean -y

# Oracle instantclient
ADD instantclient/instantclient-basic-linux.x64-12.1.0.2.0.zip /tmp/
ADD instantclient/instantclient-sdk-linux.x64-12.1.0.2.0.zip /tmp/
ADD instantclient/instantclient-sqlplus-linux.x64-12.1.0.2.0.zip /tmp/
RUN unzip /tmp/instantclient-basic-linux.x64-12.1.0.2.0.zip -d /usr/local/
RUN unzip /tmp/instantclient-sdk-linux.x64-12.1.0.2.0.zip -d /usr/local/
RUN unzip /tmp/instantclient-sqlplus-linux.x64-12.1.0.2.0.zip -d /usr/local/
RUN ln -s /usr/local/instantclient_12_1 /usr/local/instantclient
RUN ln -s /usr/local/instantclient/libclntsh.so.12.1 /usr/local/instantclient/libclntsh.so
RUN ln -s /usr/local/instantclient/sqlplus /usr/bin/sqlplus
RUN echo 'instantclient,/usr/local/instantclient' | pecl install oci8
RUN echo "extension=oci8.so" >> /etc/php/7.2/apache2/php.ini
RUN rm /var/www/html/index.html
COPY ./trunk /var/www/html

ADD apache2.conf /etc/apache2/apache2.conf
RUN a2enmod rewrite
RUN service apache2 restart