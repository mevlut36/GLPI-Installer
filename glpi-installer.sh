#!/bin/bash

# Mettre à jour les paquets
echo "Mise à jour des paquets..."
apt update

# Installer Apache, PHP et les extensions requises
echo "Installation d'Apache et PHP..."
apt install -y apache2 libapache2-mod-php
apt install -y php php-{mysql,gd,mbstring,xml,simplexml,xmlrpc,ldap,cas,curl,imap,zip,bz2,intl,apcu,cli,json}

# Installer MariaDB
echo "Installation de MariaDB..."
apt install -y mariadb-server mariadb-client

# Configurer la base de données pour GLPI
echo "Configuration de la base de données pour GLPI..."
mysql -e "CREATE DATABASE glpi;"
mysql -e "CREATE USER 'glpi'@'localhost' IDENTIFIED BY 'glpi_password';"
mysql -e "GRANT ALL PRIVILEGES ON glpi.* TO 'glpi'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

# Télécharger et extraire GLPI
echo "Téléchargement et extraction de GLPI..."
wget -q https://github.com/glpi-project/glpi/releases/download/10.0.7/glpi-10.0.7.tgz
tar -xzf glpi-10.0.7.tgz
rm glpi-10.0.7.tgz

# Copier les fichiers GLPI dans le répertoire Apache
echo "Copie des fichiers GLPI dans le répertoire Apache..."
cp -r glpi /var/www/html/
chown -R www-data:www-data /var/www/html/glpi
rm -rf glpi

# Deplacer les dossiers "config" et "files" en dehors d'apache
mv /var/www/html/config /etc/glpi
mv /var/www/html/files /var/lib/glpi

# Rediriger le dossier config
touch /var/www/html/inc/downstream.php
echo 
  "<?php
  \ndefine('GLPI_CONFIG_DIR', '/etc/glpi/');
  \nif (file_exists(GLPI_CONFIG_DIR . '/local_define.php')) {
  \nrequire_once GLPI_CONFIG_DIR . '/local_define.php';
  \n}"
>> /var/www/html/inc/downstream.php

# Rediriger le dossier file
touch /etc/glpi/local_define.php
echo
  "<?php
  \ndefine('GLPI_VAR_DIR', '/var/lib/glpi');"
>>  /etc/glpi/local_define.php

# Php.ini modification variable "session.cookie_httponly = on"
cat /etc/php/7.4/apache2/php.ini | sed -e 's/session.cookie_httponly =/session.cookie_httponly = on/' > /etc/php/7.4/apache2/php.ini

# Redémarrer Apache et MariaDB
echo "Redémarrage d'Apache et MariaDB..."
systemctl restart apache2
systemctl restart mariadb

# Ouvrir le navigateur Web et terminer l'installation via l'interface Web
echo "GLPI est maintenant opérationnel. Ouvrez votre navigateur et accédez à http://<adresse_ip_serveur>/glpi pour terminer l'installation."
