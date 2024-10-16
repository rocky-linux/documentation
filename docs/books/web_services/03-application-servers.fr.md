---
author: Antoine Le Morvan
contributors: Steven Spencer, Ganna Zhyrnova
title: Chapitre 3 Serveurs d'application
tags:
  - web
  - php
  - php-fpm
  - serveur d'applications
  - langage dynamique
---

## PHP et PHP-FPM

Dans ce chapitre, vous allez découvrir PHP et PHP-FPM.

**PHP** (**P**HP **H**ypertext **P**reprocessor) est un langage de programmation libre spécialement conçu pour le développement d'applications Web. En 2024, PHP représentait un peu moins de 80% des pages web générées dans le monde. PHP est open-source et est le cœur des CMS les plus répandus (WordPress, Drupal, Joomla!, Magento, ...).

**PHP-FPM** (**F**astCGI **P**rocess **M**anager) est intégré à PHP depuis sa version 5.3.3. La version FastCGI de PHP apporte des caractéristiques supplémentaires.

****

**Objectifs** : Vous apprendrez à :

:heavy_check_mark: installer un serveur d'application PHP
:heavy_check_mark: configurer un pool PHP-FPM
:heavy_check_mark: optimiser un serveur d'application PHP-FPM

:checkered_flag: **PHP**, **PHP-FPM**, **Serveur d'Applications**

**Connaissances**: :star: :star: :star:\
**Complexité**: :star: :star: :star:

**Temps de lecture** : 31 minutes

****

### Généralités

**CGI** (\*\*Common \*\*Gateway \*\*Interface) et **FastCGI** permettent la communication entre le serveur web (Apache ou Nginx) et un langage de programmation (PHP, Python, Java) :

- Dans le cas de **CGI**, chaque requête crée un **nouveau processus**, ce qui peut être moins efficace en termes de performances.
- **FastCGI** s'appuie sur un **certain nombre de processus** pour traiter les requêtes de ses clients plus efficacement.

PHP-FPM, **en plus de meilleures performances**, apporte :

- La possibilité de mieux **partitionner les applications** : lancer des processus avec des `uid`/`gid` différents, avec des fichiers `php.ini` personnalisés,
- La gestion de statistiques,
- Gestion de journal,
- Gestion dynamique des processus et redémarrage sans interruption de service (`graceful`).

!!! note "Remarque"

```
Comme Apache possède lui-même un module PHP, l'utilisation de php-fpm est plus couramment utilisée sur un serveur Nginx.
```

### Choisir une version de PHP

Rocky Linux, tout comme le système en amont, offre de nombreuses versions de la langue. Certains d'entre eux ont atteint la fin de vie mais sont maintenus pour continuer à héberger des applications historiques qui ne sont pas encore compatibles avec les nouvelles versions de PHP. Veuillez vous référer à la page des [versions supportées](https://www.php.net/supported-versions.php) du site Web `php.net` pour choisir une version prise en charge.

Pour obtenir une liste des versions disponibles, il suffit d'entrer la commande suivante :

\=== "9.3 liste des modules PHP"

```bash
$ sudo dnf module list php

Rocky Linux 9 - AppStream
Name                                                 Stream                                                  Profiles                                                                   Summary
php                                                  8.1 [d]                                                 common [d], devel, minimal

Hint: [d]efault, [e]nabled, [x]disabled, [i]nstalled
```

Le dépôt `Remi` propose des versions de PHP plus récentes que le référentiel Appstream, notamment les versions 8.2 et 8.3.

Pour installer le dépôt `Remi`, exécutez la commande suivante :

```bash
sudo dnf install https://rpms.remirepo.net/enterprise/remi-release-9.rpm
```

Activez le référentiel `Remi` en exécutant la commande suivante :

```bash
sudo dnf config-manager --set-enabled remi
```

Vous pouvez désormais activer un module plus récent (PHP 8.3) en entrant la commande suivante :

```bash
sudo dnf module enable php:remi-8.3
```

\=== "8.9 liste des modules PHP"

```bash
$ sudo dnf module list php

Rocky Linux 8 - AppStream
Name                                                 Stream                                                  Profiles                                                                   Summary
php                                                  7.2 [d]                                                 common [d], devel, minimal                                                 PHP scripting language
php                                                  7.3                                                     common [d], devel, minimal                                                 PHP scripting language
php                                                  7.4                                                     common [d], devel, minimal                                                 PHP scripting language
php                                                  8.0                                                     common [d], devel, minimal                                                 PHP scripting language

Hint: [d]efault, [e]nabled, [x]disabled, [i]nstalled
```

Rocky Linux fournit, depuis son dépôt AppStream, différents modules PHP.

Vous remarquerez que la version par défaut contenue dans Rocky 8.9 est `php 7.2`, qui a déjà atteint sa fin de vie au moment de la rédaction de cet article.

Vous pouvez activer un nouveau module en entrant la commande suivante :

```bash
sudo dnf module enable php:8.0
==============================================================================================
Package               Architecture         Version               Repository             Size
==============================================================================================
Enabling module streams:
httpd                                      2.4
nginx                                      1.14
php                                        8.0

Transaction Summary
==============================================================================================

Is this ok [y/N]:

Transaction Summary
==============================================================================================

Is this ok [y/N]: y
Complete!
```

Vous pouvez maintenant procéder à l'installation du moteur PHP.

### Installation du mode CGI de PHP

Tout d’abord, installez et utilisez PHP en mode CGI. Il ne peut fonctionner qu'avec le serveur Web Apache et son module `mod_php`. La partie FastCGI de ce document (php-fpm) explique comment intégrer PHP dans Nginx (mais aussi Apache).

L'installation de PHP est relativement simple. Elle consiste à installer le package principal et les quelques modules dont vous aurez besoin.

L'exemple ci-dessous installe PHP avec les modules qui sont généralement indispensables.

\=== "9.3 - Installation de PHP"

```bash
sudo dnf install php php-cli php-gd php-curl php-zip php-mbstring
```

Lors de l'installation, vous serez invité à importer les clés GPG pour les référentiels epel9 (Extra Packages for Enterprise Linux 9) et Remi. Saisissez `y` pour importer les clés :

```bash
Extra Packages for Enterprise Linux 9 - x86_64
Importing GPG key 0x3228467C:
Userid     : "Fedora (epel9) <epel@fedoraproject.org>"
Fingerprint: FF8A D134 4597 106E CE81 3B91 8A38 72BF 3228 467C
From       : /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-9
Is this ok [y/N]: y
Key imported successfully
Remi's RPM repository for Enterprise Linux 9 - x86_64
Importing GPG key 0x478F8947:
Userid     : "Remi's RPM repository (https://rpms.remirepo.net/) <remi@remirepo.net>"
Fingerprint: B1AB F71E 14C9 D748 97E1 98A8 B195 27F1 478F 8947
From       : /etc/pki/rpm-gpg/RPM-GPG-KEY-remi.el9
Is this ok [y/N]: y
Key imported successfully
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.

Complete!
```

\=== "8.9 - Installation de PHP"

```bash
sudo dnf install php php-cli php-gd php-curl php-zip php-mbstring
```

En utilisant la commande suivante, vous pouvez vérifier que la version installée correspond à la version attendue :

\=== "9.3 - Vérification de la version PHP"

```bash
$ php -v
PHP 8.3.2 (cli) (built: Jan 16 2024 13:46:41) (NTS gcc x86_64)
Copyright (c) The PHP Group
Zend Engine v4.3.2, Copyright (c) Zend Technologies
with Zend OPcache v8.3.2, Copyright (c), by Zend Technologies
```

\=== "8.9 vérification de la version PHP"

```bash
$ php -v
PHP 7.4.19 (cli) (built: May  4 2021 11:06:37) ( NTS )
Copyright (c) The PHP Group
Zend Engine v3.4.0, Copyright (c) Zend Technologies
with Zend OPcache v7.4.19, Copyright (c), by Zend Technologies
```

### Intégration d'Apache

Pour servir les pages PHP en mode CGI, vous devrez installer le serveur apache, le configurer, l'activer et le démarrer.

- Installation :

```bash
sudo dnf install httpd
```

```
activation :
```

```bash
sudo systemctl enable --now httpd
sudo systemctl status httpd
```

- N'oubliez pas de configurer le pare-feu — `firewalld` :

```bash
sudo firewall-cmd --add-service=http --permanent
sudo firewall-cmd --reload
```

Le serveur virtuel par défaut devrait fonctionner directement. PHP fournit une fonction `phpinfo()` qui génère un tableau récapitulatif de sa configuration. Il est utile pour vérifier si PHP fonctionne correctement. Cependant, faites attention à ne pas laisser de tels fichiers de test sur vos serveurs. Ils représentent un risque majeur pour la sécurité de votre infrastructure.

Créez le fichier `/var/www/html/info.php` (`/var/www/html` étant le répertoire `vhost` par défaut de la configuration Apache par défaut) :

```bash
<?php
phpinfo();
?>
```

Utilisez un navigateur Web pour vérifier le bon fonctionnement du serveur en vous rendant sur la page [http://your-server-ip/info.php](http://your-server-ip/info.php).

!!! warning "Avertissement"

```
Ne laissez pas le fichier `info.php` sur votre serveur!
```

### Installation du mode cgi de PHP (PHP-FPM)

Comme indiqué précédemment, il existe de nombreux avantages pour passer à l’hébergement Web en mode PHP-FPM.

L'installation nécessite uniquement le package `php-fpm` :

```bash
sudo dnf install php-fpm
```

Comme `php-fpm` est un service d'un point de vue système, vous devez l'activer et le lancer :

```bash
sudo systemctl enable --now php-fpm
sudo systemctl status php-fpm
```

#### Configuration du mode `cgi` de PHP

Le fichier de configuration principal est `/etc/php-fpm.conf`.

```bash
include=/etc/php-fpm.d/*.conf
[global]
pid = /run/php-fpm/php-fpm.pid
error_log = /var/log/php-fpm/error.log
daemonize = yes
```

!!! note "Remarque"

```
Les fichiers de configuration de `php-fpm` sont largement commentés. N'hésitez pas à y jeter un coup d'œil !
```

Comme vous pouvez le constater, les fichiers dans le répertoire `/etc/php-fpm.d/` avec l'extension `.conf` sont toujours inclus.

Par défaut, une déclaration de pool de processus PHP nommée `www`, se trouve dans `/etc/php-fpm.d/www.conf`.

```bash
[www]
user = apache
group = apache

listen = /run/php-fpm/www.sock
listen.acl_users = apache,nginx
listen.allowed_clients = 127.0.0.1

pm = dynamic
pm.max_children = 50
pm.start_servers = 5
pm.min_spare_servers = 5
pm.max_spare_servers = 35

slowlog = /var/log/php-fpm/www-slow.log

php_admin_value[error_log] = /var/log/php-fpm/www-error.log
php_admin_flag[log_errors] = on
php_value[session.save_handler] = files
php_value[session.save_path]    = /var/lib/php/session
php_value[soap.wsdl_cache_dir]  = /var/lib/php/wsdlcache
```

| Instructions | Description                                                                                                                                                                                                                 |
| ------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `[pool]`     | Nom du pool de processus. Le fichier de configuration peut être composé de plusieurs pools de processus (le nom du pool entre parenthèses indique une nouvelle section). |
| `listen`     | Définit l'interface d'écoute ou le socket Unix utilisé.                                                                                                                                                     |

#### Configuration de la façon d'accéder aux processus php-fpm

Il existe deux façons de se connecter.

Avec une `inet-interface` telle que :

`listen = 127.0.0.1:9000`.

Ou avec un socket UNIX :

`listen = /run/php-fpm/www.sock`.

!!! note "Remarque"

```
L'utilisation d'un socket lorsque les serveurs web et php sont sur la même machine permet la suppression de la couche TCP/IP et optimise les performances.
```

Lorsque vous travaillez avec une interface, vous devez configurer `listen.owner`, `listen.group`, `listen.mode` pour spécifier le propriétaire, le groupe de propriétaires et les droits du socket UNIX. **Attention :** les deux serveurs (Web et PHP) doivent avoir des droits d'accès sur le socket.

Lorsque vous travaillez avec un socket, vous devez configurer `listen.allowed_clients` pour restreindre l'accès au serveur PHP à certaines adresses IP.

Exemple : `listen.allowed_clients = 127.0.0.1`

#### Configuration statique ou dynamique

Vous pouvez gérer les processus PHP-FPM de manière statique ou dynamique.

En mode statique, `pm.max_children` fixe une limite au nombre de processus enfants :

```bash
pm = static
pm.max_children = 10
```

Cette configuration démarre avec 10 processus.

En mode dynamique, PHP-FPM démarre _au plus_ le nombre de processus spécifié par la valeur `pm.max_children`. Il démarre d'abord certains processus correspondant à `pm.start_servers`, en conservant au moins la valeur de `pm.min_spare_servers` des processus inactifs et, au plus, `pm.max_spare_servers` des processus inactifs.

Exemple :

```bash
pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3
```

PHP-FPM générera un nouveau processus au lieu de celui qui a traité plusieurs requêtes correspondant à `pm.max_requests`.

Par défaut, la valeur de `pm.max_requests` est 0, ce qui signifie que les processus ne sont jamais recyclés. L'option `pm.max_requests` peut être intéressante pour les applications présentant des fuites de mémoire.

Le troisième mode de fonctionnement est le mode `ondemand`. Ce mode ne lance un processus que lorsqu'il reçoit une requête. Ce n'est pas un mode optimal pour les sites à fort trafic et est réservé à des besoins spécifiques (sites avec peu de requêtes, gestion backend, etc.).

!!! note "Remarque"

```
La configuration du mode de fonctionnement de PHP-FPM est essentielle pour assurer un fonctionnement optimal de votre serveur web.
```

#### Status du processus

Semblable à Apache et son module `mod_status`, PHP-FPM propose une page d'état de processus.

Pour activer la page, définissez son chemin d'accès à l'aide de la directive `pm.status_path` :

```bash
pm.status_path = /status
```

```bash
$ curl http://localhost/status_php
pool:                 www
process manager:      dynamic
start time:           03/Dec/2021:14:00:00 +0100
start since:          600
accepted conn:        548
listen queue:         0
max listen queue:     15
listen queue len:     128
idle processes:       3
active processes:     3
total processes:      5
max active processes: 5
max children reached: 0
slow requests:        0
```

#### Journalisation des requêtes longues

La directive `slowlog` spécifie un fichier qui reçoit des requêtes de journalisation trop longues (par exemple, qui prennent plus de temps que la valeur de la directive `request_slowlog_timeout`).

L'emplacement par défaut du fichier généré est `/var/log/php-fpm/www-slow.log`.

```bash
request_slowlog_timeout = 5
slowlog = /var/log/php-fpm/www-slow.log
```

Une valeur de 0 pour `request_slowlog_timeout` désactive la journalisation.

### Intégration de NGinx

La configuration par défaut de nginx inclut déjà la configuration nécessaire pour faire fonctionner PHP avec PHP-FPM.

Le fichier de configuration `fastcgi.conf` (ou `fastcgi_params`) se trouve dans `/etc/nginx/` :

```bash
fastcgi_param  SCRIPT_FILENAME    $document_root$fastcgi_script_name;
fastcgi_param  QUERY_STRING       $query_string;
fastcgi_param  REQUEST_METHOD     $request_method;
fastcgi_param  CONTENT_TYPE       $content_type;
fastcgi_param  CONTENT_LENGTH     $content_length;

fastcgi_param  SCRIPT_NAME        $fastcgi_script_name;
fastcgi_param  REQUEST_URI        $request_uri;
fastcgi_param  DOCUMENT_URI       $document_uri;
fastcgi_param  DOCUMENT_ROOT      $document_root;
fastcgi_param  SERVER_PROTOCOL    $server_protocol;
fastcgi_param  REQUEST_SCHEME     $scheme;
fastcgi_param  HTTPS              $https if_not_empty;

fastcgi_param  GATEWAY_INTERFACE  CGI/1.1;
fastcgi_param  SERVER_SOFTWARE    nginx/$nginx_version;

fastcgi_param  REMOTE_ADDR        $remote_addr;
fastcgi_param  REMOTE_PORT        $remote_port;
fastcgi_param  SERVER_ADDR        $server_addr;
fastcgi_param  SERVER_PORT        $server_port;
fastcgi_param  SERVER_NAME        $server_name;

# PHP only, required if PHP was built with --enable-force-cgi-redirect
fastcgi_param  REDIRECT_STATUS    200;
```

Pour que `nginx` traite les fichiers `.php`, ajoutez les directives suivantes au fichier de configuration du site :

Si PHP-FPM écoute sur le port 9000 :

```bash
location ~ \.php$ {
  include /etc/nginx/fastcgi_params;
  fastcgi_pass 127.0.0.1:9000;
}
```

Si `php-fpm` est en écoute sur un socket UNIX :

```bash
location ~ \.php$ {
  include /etc/nginx/fastcgi_params;
  fastcgi_pass unix:/run/php-fpm/www.sock;
}
```

### Intégration d'Apache

La configuration d'Apache pour utiliser un pool PHP est assez simple. Vous devez utiliser les modules proxy avec la directive `ProxyPassMatch`, par exemple :

```bash
<VirtualHost *:80>
  ServerName web.rockylinux.org
  DocumentRoot "/var/www/html/current/public"

  <Directory "/var/www/html/current/public">
    AllowOverride All
    Options -Indexes +FollowSymLinks
    Require all granted
  </Directory>
  ProxyPassMatch ^/(.*\.php(/.*)?)$ "fcgi://127.0.0.1:9000/var/www/html/current/public"

</VirtualHost>

```

### Configuration des Pools PHP

L’optimisation du nombre de requêtes servies et l’analyse de la mémoire utilisée par les scripts PHP sont nécessaires pour augmenter le nombre de threads en cours d’exécution.

Tout d'abord, vous devez connaître la quantité moyenne de mémoire utilisée par un processus PHP à l'aide de la commande suivante :

```bash
while true; do ps --no-headers -o "rss,cmd" -C php-fpm | grep "pool www" | awk '{ sum+=$1 } END { printf ("%d%s\n", sum/NR/1024,"Mb") }' >> avg_php_proc; sleep 60; done
```

Avec le temps, cela vous donnera une idée assez précise de l'utilisation moyenne de la mémoire par les processus PHP sur ce serveur.

Le résultat du reste de ce document est une empreinte mémoire de 120 Mo par processus à pleine charge.

Sur un serveur avec 8 Go de RAM, gardant 1 Go pour le système et 1 Go pour l'OPCache (voir le reste de ce document), il reste 6 Go pour traiter les requêtes PHP depuis les clients.

Vous pouvez en conclure que ce serveur peut accepter au plus **50 threads** – `((6*1024) / 120)`.

Voici un exemple de configuration `php-fpm` spécifique à ce cas d'utilisation :

```bash
pm = dynamic
pm.max_children = 50
pm.start_servers = 12
pm.min_spare_servers = 12
pm.max_spare_servers = 36
pm.max_requests = 500
```

avec :

- `pm.start_servers` = 25% de la valeur `max_children`
- `pm.min_spare_servers` = 25% de `max_children`
- `pm.max_spare_servers` = 75% de `max_children`

### Configuration `OPcache`

`opcache` (Optimizer Plus Cache) est le premier niveau de cache que vous pouvez influencer.

Il garde en mémoire les scripts PHP compilés, ce qui impacte positivement l'exécution des pages web (supprime la lecture sur disque du script + le temps de compilation).

Pour le configurer, nous devons jouer sur les paramètres suivants :

- La taille de la mémoire dédiée à l'`opcache` en fonction du taux de réussite, le configurant correctement
- le nombre de scripts PHP à mettre en cache (nombre de clés + nombre maximum de scripts)
- le nombre de chaînes à mettre en cache

Pour l'installer :

```bash
sudo dnf install php-opcache
```

Pour le configurer, éditez le fichier de configuration `/etc/php.d/10-opcache.ini` :

```bash
opcache.memory_consumption=128
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=4000
```

Où :

- `opcache.memory_consumption` correspond à la quantité de mémoire requise par l'`opcache` (augmentez cette valeur jusqu'à obtenir le taux de réussite correct).
- `opcache.interned_strings_buffer` représente la quantité de chaînes à mettre en cache.
- `opcache.max_accelerated_files` est proche du résultat de la commande `find ./ -iname "*.php"|wc -l`.

Pour configurer `opcache`, reportez-vous à la page `info.php` (ainsi que `phpinfo();`) (voir par exemple les valeurs de `Cached scripts` et `Cached strings`).

!!! note "Remarque"

```
Lors de chaque nouveau déploiement de code récent, il sera nécessaire de vider l'`opcache` (par exemple en redémarrant le processus php-fpm).
```

!!! note "Remarque"

```
Ne sous-estimez pas les gains de vitesse qui peuvent être obtenus en installant et en configurant correctement `opcache`.
```

<!---

### Workshop

#### Task 1 : XXX

#### Task 2 : XXX

#### Task 3 : XXX

#### Task 4 : XXX

### Check your Knowledge

:heavy_check_mark: Simple question? (3 answers)

:heavy_check_mark: Question with multiple answers?

* [ ] Answer 1
* [ ] Answer 2
* [ ] Answer 3
* [ ] Answer 4

## Python

In this chapter, you will learn about XXXXXXX.

****

**Objectives**: In this chapter, you will learn how to:

:heavy_check_mark: XXX
:heavy_check_mark: XXX

:checkered_flag: **XXX**, **XXX**

**Knowledge**: :star:
**Complexity**: :star:

**Reading time**: XX minutes

****

### Generalities

### Configuration

### Security

### Workshop

#### Task 1 : XXX

#### Task 2 : XXX

#### Task 3 : XXX

#### Task 4 : XXX

### Check your Knowledge

:heavy_check_mark: Simple question? (3 answers)

:heavy_check_mark: Question with multiple answers?

* [ ] Answer 1
* [ ] Answer 2
* [ ] Answer 3
* [ ] Answer 4

-->
