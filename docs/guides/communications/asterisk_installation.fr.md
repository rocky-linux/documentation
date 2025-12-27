---
title: Installation de `Asterisk`
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 8.5
tags:
  - asterisk
  - pbx
  - communication
---

!!! note "Remarque"

    La dernière version de Rocky Linux sur laquelle cette procédure a été testée était la version 8.5. Puis-ce que la majeure partie de cette procédure repose sur des sources provenant directement d'Asterisk et sur un ensemble simple d'outils de développement de Rocky Linux, cela devrait fonctionner sur toutes les versions. Si vous rencontrez un problème quelconque, faites-le nous savoir !

# Installation Asterisk sous Rocky Linux

**Qu'est-ce que le logiciel Asterisk ?**

'Asterisk' est un framework open-source pour la construction d'applications de communications. De plus, Asterisk transforme un ordinateur ordinaire en serveur de communication, ainsi que contrôle des systèmes PBX IP, passerelles VoIP, serveurs de conférence et autres solutions personnalisées. Il est utilisé par des petites entreprises, de grandes entreprises, des centres d'appels, des transporteurs et des agences gouvernementales dans le monde entier.

Asterisk est libre et open-source et est parrainé par [Sangoma](https://www.sangoma.com/). Sangoma propose également des produits commerciaux qui utilisent Asterisk sous le capot, et en fonction de votre expérience et de votre budget, l'utilisation de ces produits peut être plus bénéfique que de développer le vôtre. Seul vous et votre organisation connaissez la réponse.

Il convient de noter que ce guide exige de l'administrateur qu'il effectue en partie ses propres recherches. L'installation d'un serveur de communication n'est pas un processus difficile, mais il peut être assez compliqué. Bien que ce guide soit prêt à fonctionner sur votre serveur, il ne sera pas entièrement prêt à être utilisé en production.

## Prérequis

Au minimum, vous aurez besoin des compétences et des outils suivants pour compléter ce guide :

- Une machine exécutant Rocky Linux
- Savoir modifier les fichiers de configuration à partir de la ligne de commande
- Connaissance de l'utilisation d'un éditeur de ligne de commande (nous utilisons `vi` ici, mais n'hésitez pas à le remplacer par votre éditeur favori.)
- Vous aurez besoin des droits d'accès `root`
- Les dépôts EPEL de Fedora
- La possibilité de se connecter en tant que root ou d'exécuter des commandes root avec _sudo_. Toutes les commandes supposent ici un utilisateur qui a les privilèges de `sudo`. Cependant, les procédures de configuration et de construction sont effectués à l'aide de `sudo -s`.
- Pour récupérer la dernière version du logiciel Asterisk, vous devrez utiliser `curl` ou bien `wget`. Ce guide utilise `wget`, mais vous pouvez remplacer par la commande `curl` appropriée si vous préférez.

## Mise à Jour de Rocky Linux et Installation de `wget`

```bash
sudo dnf -y update
```

Cela permettra à votre serveur d'être à jour avec tous les paquets qui ont été publiés ou mis à jour depuis la dernière mise à jour ou depuis l'installation. Puis exécutez la commande suivante :

```bash
sudo dnf install wget
```

## Définition du nom d'hôte

Définissez votre nom d'hôte avec le domaine que vous utiliserez pour Asterisk.

```bash
sudo hostnamectl set-hostname asterisk.example.com
```

## Ajouter les dépôts nécessaires

Tout d'abord, installez le dépôt EPEL (Extra Packages for Enterprise Linux) :

```bash
sudo dnf -y install epel-release
```

Ensuite, activez les PowerTools de Rocky Linux :

```bash
sudo dnf config-manager --set-enabled powertools
```

## Installation des outils de développement

```bash
sudo dnf group -y install "Development Tools"
sudo dnf -y install git wget  
```

## Installer Asterisk

### Téléchargement et configuration de Asterisk Build

Avant de télécharger ce script, assurez-vous d'avoir la dernière version. Pour ce faire, accédez au lien de téléchargement [Asterisk ici](http://downloads.asterisk.org/pub/telephony/asterisk/) et cherchez la dernière version d'Asterisk. Copiez ensuite l'emplacement du lien. Lors de la rédaction de ce document, ce qui suit était la dernière version :

```bash
wget http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-20-current.tar.gz 
tar xvfz asterisk-20-current.tar.gz
cd asterisk-20.0.0/
```

Avant d'exécuter le `install_prereq` ci-dessous (et les commandes restantes), vous devrez être administrateur ou `root`. Il est beaucoup plus facile à ce stade de passer en permanence à `sudo` pendant un certain temps. Nous quitterons `sudo` plus tard dans le processus :

```bash
sudo -s
contrib/scripts/install_prereq install
```

Vous devriez voir ce qui suit une fois le script terminé :

```text
#############################################
## install completed successfully
#############################################
```

Maintenant que tous les paquets nécessaires sont installés, notre prochaine étape est de configurer et de construire Asterisk :

```bash
./configure --libdir=/usr/lib64 --with-jansson-bundled=yes
```

En supposant que la configuration fonctionne sans problème, vous devriez obtenir un emblème ASCII Asterisk, suivi par ce qui suit sur Rocky Linux :

```bash
configure: Package configured for:
configure: OS type  : linux-gnu
configure: Host CPU : x86_64
configure: build-cpu:vendor:os: x86_64 : pc : linux-gnu :
configure: host-cpu:vendor:os: x86_64 : pc : linux-gnu :
```

### Définir les options du menu Asterisk [pour plus d'options]

C'est l'une des étapes où l'administrateur devra bien faire ses devoirs. Il y a beaucoup d'options de menu dont vous pouvez avoir besoin ou non. Exécuter la commande suivante :

```bash
make menuselect
```

vous amènera à l'écran de sélection suivant :

![menuselect screen](../images/asterisk_menuselect.png)

Regardez attentivement ces options et choisissez en fonction de vos exigences. Comme cela a été mentionné précédemment, cela peut impliquer des efforts supplémentaires.

### Construire et Installer Asterisk

Pour construire Asterisk, nous allons exécuter les commandes suivantes :

```bash
make
make install
```

L'installation de la documentation n'est pas requise, mais à moins que vous ne soyez un expert du serveur de communications, vous voudrez les installer :

```bash
make progdocs
```

Ensuite, installez le PBX de base et créez la configuration. Le PBX de base est juste cela, très basique ! Vous devrez probablement faire des changements pour que votre PBX fonctionne comme vous le souhaitez.

```bash
make basic-pbx
make config
```

## Configuration de `Asterisk`

### Création d'un Utilisateur & d'un Groupe

Vous aurez besoin d'un utilisateur spécifique pour `Asterisk`. On peut aussi bien les créer maintenant :

```bash
groupadd asterisk
useradd -r -d /var/lib/asterisk -g asterisk asterisk
chown -R asterisk.asterisk /etc/asterisk /var/{lib,log,spool}/asterisk /usr/lib64/asterisk
restorecon -vr {/etc/asterisk,/var/lib/asterisk,/var/log/asterisk,/var/spool/asterisk}
```

Maintenant que la majeure partie de notre travail est terminée, allez-y et quittez la commande `sudo -s`. Cela impliquera que la plupart des commandes restantes utilisent `sudo` à nouveau :

```bash
exit
```

### Définir l'utilisateur et le groupe par défaut

```bash
sudo vi /etc/sysconfig/asterisk
```

Supprimez les commentaires dans les deux lignes ci-dessous et enregistrez :

```bash
AST_USER="asterisk"
AST_GROUP="asterisk"
```

```bash
sudo vi /etc/asterisk/asterisk.conf
```

Supprimez les commentaires dans les deux lignes ci-dessous et enregistrez :

```bash
runuser = asterisk ; The user to run as.
rungroup = asterisk ; The group to run as.
```

### Configuration du service `Asterisk`

```bash
sudo systemctl enable asterisk
```

### Configuration du pare-feu

Cet exemple utilise `firewalld` pour le pare-feu, qui est la valeur par défaut dans Rocky Linux. Le but ici est d'ouvrir les ports SIP et le RTP (protocole de transport temps réel) sur les ports 10000-20000, comme le recommande la documentation Asterisk.

Gardez à l'esprit que vous aurez très probablement besoin d'autres règles de pare-feu pour d'autres services orientés vers le futur (HTTP/HTTPS) que vous voudrez probablement limiter à vos propres adresses IP. Cela dépasse le cadre de ce document:

```bash
sudo firewall-cmd --zone=public --add-service sip --permanent
sudo firewall-cmd --zone=public --add-port=10000-20000/udp --permanent
```

Puisque nous avons rendu permanentes les commandes `firewalld`, nous devrons effectuer un redémarrage du serveur. Pour ce faire, veuillez utiliser la commande suivante :

```bash
sudo shutdown -r now
```

## Test

### La Console Asterisk

Pour tester, nous allons nous connecter à la console Asterisk :

```bash
sudo asterisk -r
```

Ce qui vous amènera dans le client en ligne de commande Asterisk. Vous verrez cette invite après l'affichage des informations de base d'Asterisk :

```bash
asterisk*CLI>
```

Pour changer la verbosité de la console, utilisez la commande suivante :

```bash
core set verbose 4
```

Ce qui devrait afficher ce qui suit dans la console Asterisk :

```bash
Console verbose was OFF and is now 4.
```

### Afficher les exemples d'authentification 'End-Point'

À l'invite client en ligne de commande Asterisk, tapez :

```bash
pjsip show auth 1101
```

Cela retournera le nom d'utilisateur et de mot de passe que vous pouvez ensuite utiliser pour connecter n'importe quel client SIP.

## Conclusion

Ce qui précède vous permettra de démarrer avec le serveur, mais terminer la configuration, la connexion des périphériques et le dépannage ultérieur sont sous votre responsabilité.

Le fonctionnement d'un serveur de communication Asterisk prend beaucoup de temps et d'efforts et nécessitera des recherches de la part de tout administrateur. Pour plus d'informations sur la configuration et l'utilisation d'Asterisk, jetez un coup d'œil au [Wiki Asterisk ici.](https://docs.asterisk.org/Configuration/)
