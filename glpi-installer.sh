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

# Redémarrer Apache et MariaDB
echo "Redémarrage d'Apache et MariaDB..."
systemctl restart apache2
systemctl restart mariadb

# Ouvrir le navigateur Web et terminer l'installation via l'interface Web
echo "GLPI est maintenant opérationnel. Ouvrez votre navigateur et accédez à http://<adresse_ip_serveur>/glpi pour terminer l'installation."
