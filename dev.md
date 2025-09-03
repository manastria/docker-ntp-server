## Guide de Dépannage pour le Serveur NTP Docker

Ce guide t’aidera à diagnostiquer et à résoudre les problèmes que tu pourrais rencontrer avec la configuration du serveur NTP conteneurisé. Nous allons procéder comme un détective, en partant des indices les plus évidents pour remonter jusqu’à la source du problème.

###  Étape 0 : Prérequis - L’outil Indispensable (`chronyc`)

Pour pouvoir « parler » à notre serveur NTP depuis notre machine (l’hôte), nous avons besoin du client `chronyc`. C’est notre principal outil d’interrogation.

Ouvre un terminal sur ta machine et installe le paquet `chrony` :

```bash
sudo apt update && sudo apt install chrony
```

Même si le service `chronyd` de ta machine est masqué ou inactif, cette commande nous donne accès à l’utilitaire `chronyc`, et c’est tout ce dont nous avons besoin.

-----

###  Étape 1 : Le Point de Départ - La Page Web de Statut

La première chose à faire est toujours de consulter la page web du `healthcheck` (par exemple, `http://localhost:8123`). C’est notre tableau de bord.

  * **Cas 1 : La page affiche un statut NTP complet et « Leap status : Normal »**.

      * **Diagnostic :** Tout fonctionne parfaitement. Bravo !

  * **Cas 2 : La page affiche `"ERREUR : Impossible de charger le statut."`**

      * **Diagnostic :** Le script en arrière-plan (`update_status.sh`) n’a pas réussi à créer le fichier `status.txt`. Le serveur web (Nginx) renvoie une erreur 404 que le JavaScript interprète.
      * **Action :** Passe à l’**Étape 4**.

  * **Cas 3 : La page affiche une erreur spécifique (ex: `"ERREUR : Port UDP/123 injoignable."`)**

      * **Diagnostic :** Le conteneur `healthcheck` fonctionne, mais il n’arrive pas à communiquer avec le conteneur `ntp`.
      * **Action :** Passe à l’**Étape 3**.

  * **Cas 4 : Le navigateur affiche « La connexion a échoué » ou « Connection Refused »**.

      * **Diagnostic :** Le conteneur `healthcheck` lui-même ne fonctionne pas ou ne répond pas.
      * **Action :** Passe à l’**Étape 2**.

-----

###  Étape 2 : Vérifier la Santé des Conteneurs

Cette commande est l’électrocardiogramme de notre projet. Elle nous dit si nos conteneurs sont en vie.

```bash
docker compose ps
```

**Ce que tu dois voir :** Les deux conteneurs (`ntp-server` et `ntp-healthcheck`) avec le statut `running` ou `Up`.

**Si un conteneur est en `restarting` ou `exited` :** Il y a un problème grave. Consulte ses logs pour comprendre pourquoi il n’arrive pas à démarrer. Par exemple, si `ntp-server` a un problème :

```bash
docker compose logs ntp-server
```

-----

###  Étape 3 : Tester le Serveur NTP depuis l’Hôte

Maintenant, nous allons court-circuiter le conteneur `healthcheck` et parler directement au serveur `ntp` depuis notre machine.

```bash
chronyc -h localhost tracking
```

**Ce que tu dois voir :** Une sortie détaillée avec des informations comme « Reference ID », « Stratum », et surtout « Leap status: Normal ».

  * **Si ça fonctionne :** Le conteneur `ntp` est en parfaite santé. Le problème se situe **entre** `healthcheck` et `ntp`. Passe à l’**Étape 5**.
  * **Si ça bloque (hang) ou renvoie une erreur** (ex: `506 Cannot talk to daemon`) : Le problème vient du conteneur `ntp` lui-même.
      * **Vérifie ses logs :** `docker compose logs ntp-server`.
      * **Vérifie sa configuration :** Le fichier `ntp/chrony.conf` contient-il bien les directives `bindcmdaddress 0.0.0.0` et `cmdallow 0.0.0.0/0` ?

-----

###  Étape 4 : Vérifier si les Ports sont bien Ouverts

Cette commande de bas niveau nous montre si Docker écoute bien sur les ports UDP que nous avons définis.

```bash
# Affiche toutes les sockets UDP (-u) en écoute (-l) avec leur numéro (-n) et le processus (-p) associé
sudo ss -lunp | grep 'docker-proxy'
```

**Ce que tu dois voir :** Des lignes montrant que `docker-proxy` écoute bien sur les ports `123` et `323`.

  * **Si les ports n’apparaissent pas :** Le conteneur `ntp` n’est probablement pas démarré, ou la section `ports` dans ton fichier `docker-compose.yml` est incorrecte.

-----

###  Étape 5 : Le Test Ultime - Exécuter le Script Manuellement

Si le serveur `ntp` semble fonctionner (étape 3 OK) mais que la page web a un problème (cas 2), le coupable est le script `update_status.sh` dans son environnement de démarrage.

Lance-le manuellement en mode « bavard » (`-x`) pour voir exactement ce qu’il fait :

```bash
docker compose exec ntp-healthcheck sh -x /usr/local/bin/update_status.sh
```

Cette commande va te montrer chaque ligne du script au moment de son exécution. Tu verras ainsi s’il se bloque sur une commande réseau ou s’il génère une erreur inattendue. C’est l’outil de diagnostic le plus puissant pour trouver la cause finale.

Bon débogage !
