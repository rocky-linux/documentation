# Configuration Apache Web Server Multi-Sites'

## De quoi avez-vous besoin ?

* Un serveur sous Rocky Linux,
* Des connaissances de la ligne de commande et des éditeurs de texte (Cet exemple utilise *vi*, mais peut être adapté à votre éditeur favori),
    * Si vous êtes intéressé pour apprendre à utiliser l'éditeur de texte vi, [voici un tutoriel pratique](https://www.tutorialspoint.com/unix/unix-vi-editor.htm).
* Des connaissances élémentaires sur l'installation et le lancement de services web.

## Introduction

Il y a de nombreuses façons pour vous de configurer un site web sur Rocky Linux. Celle-ci est juste une méthode utilisant Apache et est conçue pour accueillir une configuration multi-sites sur un seul serveur. Bien que cette méthode soit conçue pour des serveurs multi-sites, elle peut tout aussi bien faire office de configuration de base pour un server mono-site.

Pour la petite histoire : cette configuration serveur semble avoir démarré sur des systèmes Debian, mais est parfaitement adaptable à n'importe quel OS Linux faisant tourner Apache.

## Installer Apache

Vous aurez surement besoin d'autres paquets pour votre site web. Par exemple, une version de PHP sera certainement nécessaire et peut être également une base de données ou tout autre sortes de paquets. L'installation de PHP et de httpd vous permettra d'obtenir les dernières versions de ces logiciels à partir des dépôts de Rocky Linux.

Rappelez-vous simplement que vous pourrez avoir besoin de modules également, comme peut être php-bcmath ou php-mysqlind. Les spécifications de votre application web devraient détailler ce qui est nécessaire. Elles peuvent être installées à n'importe quel moment. Pour l'instant, nous allons installer httpd et PHP, puisqu'ils sont presque inévitables :

* Depuis la ligne de commande, exécuter : `dnf install httpd php`

## Ajouter des dossiers supplémentaires

Cette méthode utilise un ensemble de répertoires supplémentaires, mais ils n'existent pas actuellement sur le système. Nous devons ajouter deux répertoires dans */etc/httpd/* appelés "sites-available" et "sites-enabled".

* Depuis la ligne de commande, saisir `mkdir /etc/httpd/sites-available` puis `mkdir /etc/httpd/sites-enabled`

* Nous avons également besoin d'un répertoire dans lequel nos sites vont être déposés. Cela peut être n'importe où, mais une bonne façon de conserver les choses organisées et de créer un répertoire appelé sub-domains. Pour conserver les choses simples, placez le sous /var/www: `mkdir /var/www/sub-domains/`

## Configuration

Nous avons aussi besoin d'ajouter une ligne à la toute fin du fichier httpd.conf. Pour faire cela, saisissez `vi /etc/httpd/conf/httpd.conf`, allez en bas du fichier et ajoutez `Include /etc/httpd/sites-enabled`.

Nos fichiers de configuration seront dans */etc/httpd/sites-available* et nous allons simplement créer des liens symboliques vers eux dans */etc/httpd/sites-enabled*.

**Pourquoi faisons nous cela ?**

La raison est plutôt simple. Imaginons que vous avez 10 sites web fonctionnant tous sur le même server sur différentes adresses IP. Disons que le site B a des mises à jour majeures et vous devez faire des changements à la configuration de ce site. Disons également qu'il y a quelque chose de faux dans les changements effectués, si bien que lorsque vous redémarrez httpd pour prendre en compte les nouveaux changements, httpd ne démarre pas.

Non seulement le site sur lequel vous étiez en train de travailler ne démarre pas, mais aucun autre non plus. Avec cette méthode, vous pouvez simplement supprimer le lien symbolique du site qui pose problème et redémarrer httpd. Il va recommencer à fonctionner et vous pourrez travailler pour tenter de corriger la configuration du site en panne.

Cela enlève la pression, en sachant que le téléphone ne va pas sonner avec un client ou un chef en colère parce que le service est coupé.

### La configuration du site

L'autre bénéfice de cette méthode est qu'elle va nous permettre de tout spécifier en dehors du fichier par défaut httpd.conf. Laissez le fichier par défaut httpd.conf charger les options par défaut et laissez les fichiers de configuration de vos sites faire le reste. Chouette non ? De plus, encore une fois, cela rend vraiment simple de dépanner une configuration de site.

Maintenant, disons que vous avez un site web qui charge un wiki. Vous allez avoir besoin d'un fichier de configuration qui rendra le site disponible sur le port 80.

Si vous voulez servir le site en SSL (et regardons les choses en face, nous devrions tous faire ça maintenant) alors vous devrez ajouter une autre section (quasiment identique) au même fichier afin d'activer le port 443.

Vous pouvez jeter un œil à cela ci-dessous dans la section [La configuration https - Utiliser un certificat SSL](#https).

Nous devons dans un premier temps créer ce fichier de configuration dans *sites-available*: `vi /etc/httpd/sites-available/com.ourownwiki.www`

Le contenu du fichier de configuration devrait ressembler à quelque chose comme ceci :

```apache
<VirtualHost *:80>
        ServerName www.ourownwiki.com
        ServerAdmin username@rockylinux.org
        DocumentRoot /var/www/sub-domains/com.ourownwiki.www/html
        DirectoryIndex index.php index.htm index.html
        Alias /icons/ /var/www/icons/
        # ScriptAlias /cgi-bin/ /var/www/sub-domains/com.ourownwiki.www/cgi-bin/

        CustomLog "/var/log/httpd/com.ourownwiki.www-access_log" combined
        ErrorLog  "/var/log/httpd/com.ourownwiki.www-error_log"

        <Directory /var/www/sub-domains/com.ourownwiki.www/html>
                Options -ExecCGI -Indexes
                AllowOverride None

                Order deny,allow
                Deny from all
                Allow from all

                Satisfy all
        </Directory>
</VirtualHost>
```

Une fois le fichier créé, nous devons l'écrire (le sauvegarder) avec : `shift : wq`

Dans notre exemple précédent, le site du wiki est chargé depuis le sous répertoire html de *com.ourownwiki.www*,  ce qui veut dire que le répertoire *sub-domains* que nous nous avons créé dans */var/www* (précédemment) va nécessiter des répertoires supplémentaires pour satisfaire cela :

`mkdir -p /var/www/sub-domains/com.ourownwiki.www/html`

... ce qui va créer le chemin complet avec une seule commande. Ensuite, nous allons vouloir installer nos fichiers dans ce répertoire qui composeront le site web. Cela peut être quelque chose que vous avez fait vous-même ou une installation web que vous installerez (dans le cas d'un wiki que vous auriez téléchargé).

Copiez vos fichiers dans le répertoire créé précédemment :

`cp -Rf wiki_source/* /var/www/sub-domains/com.ourownwiki.www/html/`

## La configuration https - Utiliser un certificat SSL

Comme discuté précédemment, chaque serveur web créé de nos jours *devrait* fonctionner avec du SSL (Secure Socket Layer).

Ce processus commence par la génération d'une clef privée et d'un CSR (Certificate Signing Request) et ensuite par l'envoi du CSR à l'autorité de certification pour acheter le certificat SSL. Ce processus de génération de clefs sort du cadre de ce document.

Si vous débutez dans la génération des clefs pour SSL, merci de consulter la page [Générer des clefs SSL](../security/ssl_keys_https.md)

Vous pouvez aussi utiliser ce processus alternatif pour utiliser [un certificat SSL Let's Encrypt](../security/generating_ssl_keys_lets_encrypt.md)

### Placement des clefs SSL et des certificats

Maintenant que vous disposez des fichiers de vos clefs et de vos certificats, nous devons logiquement les placer sur le système de fichiers de votre serveur web. Comme nous l'avons vu dans l'exemple de fichier de configuration (voir ci-dessus), nous plaçons les fichiers web dans  */var/www/sub-domains/com.ourownwiki.www/html*.

Nous voulons placer nos fichiers de certificats et de clefs avec le domaine, mais PAS à la racine des pages web (qui dans ce cas est dans le dossier _html).

Nous ne voulons absolument pas que nos certificats et clefs puissent être potentiellement exposées sur internet. Ça serait catastrophique !

A la place, nous allons créer une nouvelle structure de répertoires pour nos fichiers SSL, en dehors de la racine des pages web.

`mkdir -p /var/www/sub-domains/com.ourownwiki.www/ssl/{ssl.key,ssl.crt,ssl.csr}`

Si vous débutez avec la syntaxe "tree", voici ce que veut dire l'exemple précédent :

"Créer un répertoire appelé ssl et dans ce répertoire créer trois répertoires appelés ssl.key, ssl.crt et ssl.csr."

Juste une petite note en avance de phase : ce n'est pas nécessaire pour le fonctionnement du site web de stocker le CSR dans l'arborescence.

Si jamais vous avez besoin d'une nouvelle édition de votre certificat depuis un fournisseur différent par exemple, c'est une bonne idée d'avoir une copie de sauvegarde de ce fichier CSR. La question devient alors où le stocker de manière à s'en souvenir et le fait de le stocker dans l'arborescence du site web devient logique.

En supposant que vous avez nommé vos fichiers .key, .csr et .crt (certificat) avec le nom de votre site et que vous les avez stockés  dans */root*, nous allons alors les copier dans leurs emplacements respectifs que nous venons juste de créer :

```bash
cp /root/com.wiki.www.key /var/www/sub-domains/com.ourownwiki.www/ssl/ssl.key/
cp /root/com.wiki.www.csr /var/www/sub-domains/com.ourownwiki.www/ssl/ssl.csr/
cp /root/com.wiki.www.crt /var/www/sub-domains/com.ourownwiki.www/ssl/ssl.crt/
```

### La configuration du site - https

Une fois que vous avez généré vos clefs et acheté les certificats SSL, vous pouvez avancer dans la configuration du site web pour utiliser les nouvelles clefs.

Pour les débutants, décomposons le début du fichier de configuration. Par exemple, même si nous voulons toujours écouter sur le port 80 (http standard) pour les requêtes entrantes, nous ne voulons pas qu'elles aboutissent vers le port 80.

Nous voulons qu'elles soient redirigées vers le port 443 (ou http sécurisé, mieux connu sous SSL). Notre section de configuration du port 80 sera réduite au minimum :

```apache
<VirtualHost *:80>
        ServerName www.ourownwiki.com
        ServerAdmin username@rockylinux.org
        Redirect / https://www.ourownwiki.com/
</VirtualHost>
```

Cette configuration indique de renvoyer toutes les requêtes web en https. L'option apache "Redirect" utilisée ci-dessus peut être remplacée par "Redirect permanent" une fois que tous les tests ont été effectués et que vous pouvez constater que le site fonctionne comme vous voulez qu'il fonctionne. Le "Redirect" que nous avons choisi est une redirection temporaire.

Une redirection permanente va être apprise par les moteurs de recherche et rapidement tout le trafic de votre site qui provient des moteurs de recherche ira seulement vers le port 443 (https) sans passer par le port 80 en premier.

Ensuite, nous devons définir la partie https du fichier de configuration. La section http est dupliquée par clarté pour montrer que tout cela se passe dans le même fichier de configuration :

```apache
<VirtualHost *:80>
        ServerName www.ourownwiki.com
        ServerAdmin username@rockylinux.org
        Redirect / https://www.ourownwiki.com/
</VirtualHost>
<Virtual Host *:443>
        ServerName www.ourownwiki.com
        ServerAdmin username@rockylinux.org
        DocumentRoot /var/www/sub-domains/com.ourownwiki.www/html
        DirectoryIndex index.php index.htm index.html
        Alias /icons/ /var/www/icons/
        # ScriptAlias /cgi-bin/ /var/www/sub-domains/com.ourownwiki.www/cgi-bin/

        CustomLog "/var/log/httpd/com.ourownwiki.www-access_log" combined
        ErrorLog  "/var/log/httpd/com.ourownwiki.www-error_log"

        SSLEngine on
        SSLProtocol all -SSLv2 -SSLv3 -TLSv1
        SSLHonorCipherOrder on
        SSLCipherSuite EECDH+ECDSA+AESGCM:EECDH+aRSA+AESGCM:EECDH+ECDSA+SHA384:EECDH+ECDSA+SHA256:EECDH+aRSA+SHA384
:EECDH+aRSA+SHA256:EECDH+aRSA+RC4:EECDH:EDH+aRSA:RC4:!aNULL:!eNULL:!LOW:!3DES:!MD5:!EXP:!PSK:!SRP:!DSS

        SSLCertificateFile /var/www/sub-domains/com.ourownwiki.www/ssl/ssl.crt/com.wiki.www.crt
        SSLCertificateKeyFile /var/www/sub-domains/com.ourownwiki.www/ssl/ssl.key/com.wiki.www.key
        SSLCertificateChainFile /var/www/sub-domains/com.ourownwiki.www/ssl/ssl.crt/your_providers_intermediate_certificate.crt

        <Directory /var/www/sub-domains/com.ourownwiki.www/html>
                Options -ExecCGI -Indexes
                AllowOverride None

                Order deny,allow
                Deny from all
                Allow from all

                Satisfy all
        </Directory>
</VirtualHost>
```

Donc, en décomposant davantage cette configuration, après les parties normales de la configuration et sous la partie SSL :

* SSLEngine on - dit simplement d'utiliser SSL
* SSLProtocol all -SSLv2 -SSLv3 -TLSv1 - dit d'utiliser tous les protocoles disponibles sauf ceux pour qui des vulnérabilités ont été découvertes. Vous devriez rechercher régulièrement quels protocoles sont actuellement acceptables à être utilisés.
* SSLHonorCipherOrder on - cette directive fonctionne avec la ligne suivante concernant les algorithmes de chiffrements (Cipher Suite) et demande de les utiliser dans le même ordre que celui dans lequel ils sont donnés. C'est une autre partie de la configuration que vous devriez réviser régulièrement
* SSLCertificateFile - qui est exactement ce qu'il semble être, le fichier du nouveau certificat acquis et son emplacement.
* SSLCertificateKeyFile - la clef que vous avez générée lors de la création de la demande de signature de certificat
* SSLCertificateChainFile - le certificat de votre fournisseur de certificat, souvent appelé certificat intermédiaire.

Ensuite, mettez tout en route et s'il n'y a aucune erreur lors du démarrage du service web et si en allant sur votre site web le site en https s'affiche sans erreurs, alors vous pouvez continuer.

## Le mot de la fin

Rappelez-vous que notre fichier *httpd.conf* contient à la toute fin du fichier */etc/httpd/sites-enabled*, alors, quand httpd redémarre, il va charger n'importe quel fichier de configuration qui se trouve dans le répertoire *sites-enabled*. Toutefois, tous nos fichiers de configuration sont dans *sites-available*.

C'est un choix délibéré de manière à pouvoir retirer facilement des configurations dans le cas où le service http refuserait de redémarrer. Alors, pour activer nos fichiers de configuration, nous devons créer un lien symbolique vers ce fichier dans *sites-enabled* et ensuite démarrer ou redémarrer le service web. Pour faire cela, nous utilisons la commande :

`ln -s /etc/httpd/sites-available/com.ourownwiki.www /etc/httpd/sites-enabled/`

Cela va créer le lien vers le fichier de configuration dans *sites-enabled* comme nous le désirons.

Maintenant démarrez simplement httpd avec `systemctl start httpd` ou redémarrez le s'il tourne déjà : `systemctl restart httpd` et en supposant que le service redémarre, vous pouvez accéder à votre site et le tester.
