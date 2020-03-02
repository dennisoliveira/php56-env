FROM ubuntu:18.04

ARG USER=ubuntu

# Update repositories and update system
RUN apt-get update -y \
  && apt-get install -y sudo software-properties-common tzdata vim curl zip unzip language-pack-en-base \
  && LC_ALL=en_US.UTF-8 add-apt-repository -y ppa:ondrej/php \
  && apt-get update -y \
  && apt-get install -y apache2 php5.6 \
  php5.6-mbstring \
  php5.6-mcrypt \
  php5.6-mysql \
  php5.6-xml \
  php5.6-intl \
  php5.6-cli \
  php5.6-gd \
  php5.6-curl \
  php5.6-sqlite3 \
  php5.6-json \
	php5.6-zip \
	php5.6-xmlrpc \
	php5.6-soap \
	php5.6-uploadprogress \
  libapache2-mod-php5.6 \
  && sudo apt-get clean

# Install sudo and add default user
RUN adduser --disabled-password --gecos '' $USER
RUN adduser $USER sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Apache enable mod rewrite 
RUN a2enmod rewrite
ADD ./_docker/000-default.conf /etc/apache2/sites-available/

USER $USER
WORKDIR /home/$USER

RUN sudo php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
  sudo php -r "if (hash_file('sha384', 'composer-setup.php') === 'c5b9b6d368201a9db6f74e2611495f369991b72d9c8cbd3ffbc63edff210eb73d46ffbfce88669ad33695ef77dc76976') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"
RUN sudo mv composer.phar /usr/local/bin/composer
  
EXPOSE 80
CMD ["sudo","/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
