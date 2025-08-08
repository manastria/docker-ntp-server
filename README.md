# Serveur NTP local avec Docker et Chrony

Ce projet déploie un serveur de temps NTP local et fiable via Docker. Il est conçu pour les environnements où la connectivité Internet est limitée ou instable, comme des salles de travaux pratiques.

Il inclut un serveur **NTP (Network Time Protocol)** basé sur Chrony ainsi qu'une **page web de statut** simple et visuelle pour permettre aux utilisateurs de vérifier en temps réel que le service est fonctionnel.

## Fonctionnalités

* **Serveur NTP robuste** : Utilise [Chrony](https://chrony.tuxfamily.org/), une implémentation moderne et performante de NTP.
* **Facile à déployer** : Une seule commande `docker-compose up -d` pour tout lancer.
* **Statut en temps réel** : Une page web sur le port `8080` affiche l'état de la synchronisation du serveur, avec un code couleur pour un diagnostic immédiat.
* **Portable et isolé** : L'ensemble fonctionne dans des conteneurs Docker, sans rien installer directement sur la machine hôte (à l'exception de Docker).
* **Pensé pour l'enseignement** : Permet de fournir un service NTP centralisé pour des labs réseau, des exercices sur la synchronisation, etc.
* **Autonome et résilient** : Peut fonctionner sans dépendances externes, garantissant ainsi une disponibilité maximale.

-----

## Prérequis

* [Docker](https://www.docker.com/get-started/)
* [Docker Compose](https://docs.docker.com/compose/install/) (généralement inclus avec Docker Desktop)

-----

## Démarrage rapide

1. **Clonez ou téléchargez ce projet.**

2. **Configurez le réseau du labo :**
    Ouvrez le fichier `chrony.conf` et modifiez la ligne `allow` pour qu'elle corresponde au plan d'adressage IP de votre réseau local. Par exemple, si votre réseau est `10.10.0.0/16` :

    ```ini
    # Autoriser les clients du réseau du labo (à adapter)
    allow 10.10.0.0/16
    ```

3. **Lancez les services :**
    Ouvrez un terminal dans le dossier du projet et exécutez la commande :

    ```bash
    docker-compose up -d
    ```

    Les deux conteneurs (serveur NTP et page de statut) vont démarrer en arrière-plan.

-----

## Utilisation

### Pour les Étudiants

Une fois le serveur démarré, vous pouvez :

1. **Vérifier le statut du serveur :**
    Ouvrez un navigateur web et rendez-vous à l'adresse `http://<IP_DU_POSTE_SERVEUR>:8080`. Vous y verrez l'état de la synchronisation. Si le statut `Leap status` est `Normal`, tout est bon !

2. **Configurer votre client NTP :**
    Pour synchroniser votre machine (VM, conteneur, etc.) sur ce serveur, utilisez l'adresse IP du serveur comme source de temps. Sur un système Linux, éditez le fichier `/etc/chrony/chrony.conf` ou `/etc/ntp.conf` pour y mettre :

    ```ini
    server <IP_DU_SERVEUR> iburst
    ```

    Puis redémarrez le service de temps (`sudo systemctl restart chrony`).

### Gestion des Services (pour l'enseignant)

Toutes les commandes doivent être lancées depuis le dossier du projet.

* **Démarrer les services :**

    ```bash
    docker-compose up -d
    ```

* **Vérifier l'état des conteneurs :**

    ```bash
    docker-compose ps
    ```

* **Consulter les logs en temps réel :**

    ```bash
    # Pour le serveur NTP
    docker-compose logs -f ntp

    # Pour la page de statut
    docker-compose logs -f healthcheck
    ```

* **Arrêter et supprimer les conteneurs :**

    ```bash
    docker-compose down
    ```

-----

## Licence

Ce projet est distribué selon les termes de la [licence](LICENSE) incluse dans ce dépôt.
