#!/bin/sh
set -eu

# S’assure que l’utilisateur/groupe chrony existent (normalement fournis par le paquet)
addgroup -S chrony >/dev/null 2>&1 || true
adduser  -S -D -H -s /sbin/nologin -G chrony chrony >/dev/null 2>&1 || true

# Répertoires runtime & state (peuvent être des volumes)
# /run est volatile à chaque démarrage : on (re)crée systématiquement
install -d -o chrony -g chrony -m 0755 /run/chrony

# /var/lib/chrony peut être un volume nommé : (re)prend possession si besoin
install -d -o chrony -g chrony -m 0750 /var/lib/chrony
chown -R chrony:chrony /var/lib/chrony || true

# Lancer chronyd en conservant SYS_TIME, puis baisse de privilèges interne -> OK
exec "$@"
