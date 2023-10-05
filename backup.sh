#!/bin/bash
# Script backup for Samba
# Créer le dossier de sauvegarde s'il n'existe pas encore
if [ ! -d "/srv/samba/save_samba" ]; then
  mkdir /srv/samba/save_samba
fi

# Copier le dossier shared et son contenu dans le dossier de sauvegarde
cp -r /srv/partage /srv/samba/save_samba

# Afficher un message de confirmation
echo "La sauvegarde de /srv/samba/shared a été effectuée avec succès."

# Run this script every 24 hours: 
# crontab -e
# 0 0 * * * backup.sh
