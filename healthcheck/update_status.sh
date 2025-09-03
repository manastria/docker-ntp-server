#!/bin/sh
set -eu

# Utilise la variable d'environnement, avec "ntp" comme valeur par défaut
TARGET_HOST=${NTP_TARGET:-ntp}

while true; do
  if ! getent hosts "$TARGET_HOST" >/dev/null 2>&1; then
    echo "ERREUR : Résolution DNS de '$TARGET_HOST' échouée." > /usr/share/nginx/html/status.txt
    sleep 2; continue
  fi

  if ! nc -zu -w2 "$TARGET_HOST" 123 >/dev/null 2>&1; then
    echo "ERREUR : Port UDP/123 ($TARGET_HOST) injoignable." > /usr/share/nginx/html/status.txt
    sleep 2; continue
  fi

  if chronyc -h "$TARGET_HOST" -n tracking > /tmp/tracking.txt 2>/tmp/err.txt; then
    chronyc -h "$TARGET_HOST" -n sources > /tmp/sources.txt 2>/dev/null || true
    {
      echo "=== tracking sur $TARGET_HOST ==="
      cat /tmp/tracking.txt
      echo
      echo "=== sources ==="
      cat /tmp/sources.txt
      echo
      date -u "+Dernière mise à jour : %Y-%m-%d %H:%M:%S UTC"
    } > /usr/share/nginx/html/status.txt
  else
    printf "ERREUR : chronyc tracking sur $TARGET_HOST a échoué.\n\n" > /usr/share/nginx/html/status.txt
    cat /tmp/err.txt >> /usr/share/nginx/html/status.txt
  fi
  sleep 2
done