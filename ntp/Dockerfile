FROM alpine:3.20

# Paquets
RUN apk add --no-cache chrony tzdata

# Config (la tienne peut la surcharger via volume)
COPY chrony.conf /etc/chrony/chrony.conf

# Entrypoint qui fixe les permissions au runtime (utile avec volumes)
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 123/udp 323/udp

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["chronyd","-d","-s","-f","/etc/chrony/chrony.conf"]
