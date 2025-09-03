#!/bin/sh
set -eu

# CRÉER IMMÉDIATEMENT UN FICHIER DE STATUT INITIAL
# Cela garantit que Nginx ne renverra jamais un 404.
echo "Initialisation en cours... En attente du service NTP." > /usr/share/nginx/html/status.txt

# Lance le script de mise à jour du statut en arrière-plan.
# Il écrasera ce fichier dès qu'il aura une réponse.
/usr/local/bin/update_status.sh &
