# Partir d'une base Nginx optimisée pour Docker
FROM nginx:1.27-alpine

# L'image Nginx utilise /usr/share/nginx/html par défaut
# Supprimons le contenu par défaut avant de copier le nôtre
RUN rm /etc/nginx/conf.d/default.conf
COPY default.conf /etc/nginx/conf.d/default.conf 

# Installer les paquets dont NOUS avons besoin
RUN apk add --no-cache chrony netcat-openbsd

# Copier nos scripts et fichiers
COPY index.html /usr/share/nginx/html/index.html 
COPY update_status.sh /usr/local/bin/update_status.sh 
COPY entrypoint.sh /docker-entrypoint.d/20-app-init.sh 

# Rendre les scripts exécutables
RUN chmod +x /usr/local/bin/update_status.sh /docker-entrypoint.d/20-app-init.sh