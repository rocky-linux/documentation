---
title: "Chapitre 6 : Profils"
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 9.4
tags:
  - incus
  - entreprise
  - profils d`incus
---

Tout au long de ce chapitre, vous devez exécuter des commandes en tant qu'utilisateur non privilégié (`incusadmin` si vous avez suivi ce guide depuis le début).

Lorsque vous installez Incus, vous obtenez un profil par défaut, que vous ne pouvez ni supprimer ni modifier. Vous pouvez utiliser le profil par défaut pour créer de nouveaux profils pour vos conteneurs.

Si vous regardez notre liste de conteneurs, vous remarquerez que l'adresse IP dans chaque cas est assignée à partir de l'interface `bridged`. Dans un environnement de production, vous voudrez peut-être utiliser quelque chose de différent. Il peut s'agir d'une adresse attribuée par DHCP à partir de votre interface LAN ou d'une adresse attribuée de manière statique à partir de votre WAN.

Si vous configurez votre serveur Incus avec deux interfaces et attribuez à chacune une adresse IP sur votre WAN et votre LAN, vous pouvez attribuer les adresses IP de votre conteneur en fonction de l'interface à laquelle le conteneur doit faire face.

À partir de la version 9.4 de Rocky Linux (et de toute copie bug pour bug de Red Hat Enterprise Linux), la méthode d'attribution d'adresses IP de manière statique ou dynamique avec les profils ne fonctionne pas.

There are ways to get around this, but it is unpleasant. Cela semble avoir quelque chose à voir avec les modifications apportées au Gestionnaire de réseau qui affectent `macvlan`. `macvlan` vous permet de créer de nombreuses interfaces avec différentes adresses de couche 2.

Gardez à l’esprit que cela présente des inconvénients lors du choix d’images de conteneurs basées sur RHEL.

## Création d'un profil `macvlan` et attribution de celui-ci

Pour créer votre profil `macvlan`, utilisez cette commande :

```bash
incus profile create macvlan
```

Si vous étiez sur une machine multi-interface et que vous vouliez plus d'un modèle `macvlan` en fonction du réseau que vous vouliez atteindre, vous pourriez utiliser « lanmacvlan » ou « wanmacvlan » ou tout autre nom que vous essayiez d'utiliser pour identifier le profil. L'utilisation de `macvlan` dans votre déclaration de création de profil est sous votre responsabilité.

Vous souhaitez modifier l'interface `macvlan`, mais avant de le faire, vous devez savoir quelle est l'interface parent de votre serveur Incus. Cette interface aura une adresse IP attribuée à un réseau local LAN (dans ce cas). Pour déterminer de quelle interface il s'agit, vous pouvez utiliser la commande suivante :

```bash
ip addr
```

Cherchez l'interface avec l'affectation de l'IP LAN dans le réseau 192.168.1.0/24 :

```bash
2: enp3s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 40:16:7e:a9:94:85 brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.106/24 brd 192.168.1.255 scope global dynamic noprefixroute enp3s0
       valid_lft 4040sec preferred_lft 4040sec
    inet6 fe80::a308:acfb:fcb3:878f/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
```

Dans ce cas, l'interface serait `enp3s0`.

Maintenant, modifiez le profil :

```bash
incus profile device add macvlan eth0 nic nictype=macvlan parent=enp3s0
```

Cette commande ajoute tous les paramètres au profil `macvlan` requis pour l'utilisation.

Examinez ce qui a été créé en utilisant la commande suivante :

```bash
incus profile show macvlan
```

Ce qui vous donnera une sortie similaire à l'exemple suivant :

```bash
config: {}
description: ""
devices:
  eth0:
    nictype: macvlan
    parent: enp3s0 
    type: nic
name: macvlan
used_by: []
```

Les profils peuvent être utilisés pour de nombreuses autres choses, mais l'attribution d'une IP statique à un conteneur ou l'utilisation de votre propre serveur DHCP sont des besoins courants.

Pour attribuer le profil `macvlan` à rockylinux-test-8, vous devez procéder comme suit :

```bash
incus profile assign rockylinux-test-8 default,macvlan
```

Faîte la même chose pour le serveur rockylinux-test-9 :

```bash
incus profile assign rockylinux-test-9 default,macvlan
```

Cela indique que vous souhaitez conserver le profil par défaut et appliquer également le profil `macvlan`.

## Rocky Linux `macvlan`

Le Network Manager a constamment "évolué" dans les distributions et les clones RHEL. De ce fait, le fonctionnement du profil `macvlan` ne marche pas (du moins en comparaison avec d'autres distributions) et nécessite un travail supplémentaire pour attribuer des adresses IP à partir de DHCP ou de manière statique.

N'oubliez pas que rien de tout cela n'a principalement à voir avec Rocky Linux mais avec l'implémentation du package en amont.

Si vous souhaitez exécuter des conteneurs Rocky Linux et utiliser `macvlan` pour attribuer une adresse IP à partir de vos réseaux LAN ou WAN, le processus est différent en fonction de la version du conteneur du système d'exploitation (8.x ou 9.x).

### Rocky Linux 9.x macvlan - Le correctif DHCP

Tout d'abord, étudions ce qui se passe lors de l'arrêt et du redémarrage des deux conteneurs après l'attribution du profil `macvlan`.

Cependant, le fait que le profil soit assigné ne modifie pas la configuration par défaut, qui est définie par défaut à DHCP.

Pour tester cela, il suffit de faire ce qui suit :

```bash
incus restart rocky-test-8
incus restart rocky-test-9
```

Maintenant, listez à nouveau vos conteneurs et notez que le serveur rockylinux-test-9 n'a plus d'adresse IP :

```bash
incus list
```

```bash
+-------------------+---------+----------------------+------+-----------+-----------+
|       NAME        |  STATE  |         IPV4         | IPV6 |   TYPE    | SNAPSHOTS |
+-------------------+---------+----------------------+------+-----------+-----------+
| rockylinux-test-8 | RUNNING | 192.168.1.114 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
| rockylinux-test-9 | RUNNING |                      |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
| ubuntu-test       | RUNNING | 10.146.84.181 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
```

Comme vous pouvez le voir, votre conteneur Rocky Linux 8.x a reçu l'adresse IP de l'interface LAN, alors que le conteneur Rocky Linux 9.x ne l'a pas reçu.

Pour démontrer davantage le problème, vous devez exécuter `dhclient` sur le conteneur Rocky Linux 9.0. Cela nous montrera que le profil `macvlan` _a été_ appliqué :

```bash
incus exec rockylinux-test-9 dhclient
```

Une autre liste de conteneurs affiche désormais les éléments suivants :

```bash
+-------------------+---------+----------------------+------+-----------+-----------+
|       NAME        |  STATE  |         IPV4         | IPV6 |   TYPE    | SNAPSHOTS |
+-------------------+---------+----------------------+------+-----------+-----------+
| rockylinux-test-8 | RUNNING | 192.168.1.114 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
| rockylinux-test-9 | RUNNING | 192.168.1.113 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
| ubuntu-test       | RUNNING | 10.146.84.181 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
```

Cela aurait dû se produire avec un arrêt et un redémarrage du conteneur, mais ce n'est pas le cas. En supposant que vous souhaitiez utiliser une adresse IP attribuée par DHCP à chaque fois, vous pouvez résoudre ce problème avec une simple entrée `crontab`. Pour ce faire, vous devez obtenir un accès shell au conteneur en entrant :

```bash
incus shell rockylinux-test-9
```

Ensuite, déterminons le chemin vers `dhclient`. Pour ce faire, étant donné que ce conteneur provient d'une image minimale, vous devrez d'abord installer `which` :

```bash
dnf install which
```

Puis exécutez la commande suivante :

```bash
which dhclient
```

Qui devrait retourner :

```bash
/usr/sbin/dhclient
```

Ensuite, nous allons modifier le `crontab` de root :

```bash
crontab -e
```

Ajouter cette ligne :

```bash
@reboot    /usr/sbin/dhclient
```

La commande crontab saisie utilise _vi_. Utilisez ++shift+colon+"w"+"q"++ pour enregistrer vos modifications et quitter.

Quittez le conteneur et redémarrez rockylinux-test-9 :

```bash
incus restart rockylinux-test-9
```

Une nouvelle liste révélera que le conteneur a été assigné à l'adresse DHCP :

```bash
+-------------------+---------+----------------------+------+-----------+-----------+
|       NAME        |  STATE  |         IPV4         | IPV6 |   TYPE    | SNAPSHOTS |
+-------------------+---------+----------------------+------+-----------+-----------+
| rockylinux-test-8 | RUNNING | 192.168.1.114 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
| rockylinux-test-9 | RUNNING | 192.168.1.113 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
| ubuntu-test       | RUNNING | 10.146.84.181 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+

```

### Rocky Linux 9 et 10 `macvlan` — Le correctif IP statique

Lors de l’attribution statique d’une adresse IP, les choses deviennent encore plus compliquées. Étant donné que `network-scripts` est désormais obsolète dans Rocky Linux 9.x, la seule façon de procéder est par attribution statique, et en raison de la manière dont les conteneurs utilisent le réseau, vous ne pourrez pas définir la route avec une instruction `ip route` normale. Le problème est que l'interface attribuée lors de l'application du profil `macvlan` (`eth0` dans ce cas) n'est pas gérable avec Network Manager. La solution consiste à renommer l'interface réseau du conteneur après le redémarrage et à attribuer l'IP statique. Vous pouvez le faire avec un script et l'exécuter (à nouveau) dans le crontab de root. Tout cela se fait avec la commande `ip`. En plus de définir l'adresse IP, vous devrez configurer le DNS pour la résolution des noms. Encore une fois, ce n’est pas aussi simple que d’exécuter `nmtui` pour modifier la connexion, car la connexion n’existe pas dans le Network Manager. La solution consiste à créer un fichier texte contenant les serveurs DNS que vous voulez utiliser.

Pour ce faire, vous devez à nouveau obtenir un accès shell au conteneur:

```bash
incus shell rockylinux-test-9
```

Créez un fichier texte dans `/usr/local/sbin/` :

```bash
vi /usr/local/sbin/dns.txt
```

Ajoutez ce qui suit au fichier :

```text
nameserver 8.8.8.8
nameserver 8.8.4.4
```

Sauvegardez le fichier et quittez. Cela montre que vous utilisez les serveurs DNS ouverts de Google. Si vous souhaitez utiliser différents serveurs DNS, remplacez simplement les adresses IP affichées par le DNS de votre choix.

Ensuite, vous allez créer un script bash dans `/usr/local/sbin` appelé `static` :

```bash
vi /usr/local/sbin/static
```

Le contenu de ce script est plutôt simple :

```bash
#!/usr/bin/env bash

/usr/sbin/ip link set dev eth0 name net0
/usr/sbin/ip addr add 192.168.1.151/24 dev net0
/usr/sbin/ip link set dev net0 up
sleep 2
/usr/sbin/ip route add default via 192.168.1.1
/usr/bin/cat /usr/local/sbin/dns.txt > /etc/resolv.conf
```

Qu'est-ce que vous faites exactement avec ce script ?

- vous renommez `eth0` avec un nouveau nom que vous pouvez mieux gérer (`net0`)
- vous attribuez la nouvelle IP statique que vous avez allouée à votre conteneur (192.168.1.151)
- vous activez la nouvelle interface `net0`
- vous ajoutez une attente de 2 secondes pour que l'interface soit active avant d'ajouter la route par défaut
- vous devez ajouter la route par défaut pour votre interface
- vous devez remplir le fichier `resolv.conf` pour la résolution DNS

Rendez votre script exécutable avec la commande qui suit :

```bash
chmod +x /usr/local/sbin/static
```

Ajoutez ceci au `crontab` de `root` pour le conteneur avec l'heure du `@reboot` :

```bash
@reboot     /usr/local/sbin/static
```

Pour terminer, quittez le conteneur et redémarrez-le :

```bash
incus restart rockylinux-test-9
```

Attendez quelques secondes puis listez à nouveau les conteneurs :

```bash
incus list
```

Ce qui devrait vous afficher le résultat suivant :

```bash
+-------------------+---------+----------------------+------+-----------+-----------+
|       NAME        |  STATE  |         IPV4         | IPV6 |   TYPE    | SNAPSHOTS |
+-------------------+---------+----------------------+------+-----------+-----------+
| rockylinux-test-8 | RUNNING | 192.168.1.114 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
| rockylinux-test-9 | RUNNING | 192.168.1.151 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
| ubuntu-test       | RUNNING | 10.146.84.181 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
```

## Ubuntu macvlan

Heureusement, l’implémentation de NetworkManager par Ubuntu ne casse pas la pile `macvlan`, ce qui la rend beaucoup plus facile à déployer !

Tout comme avec votre conteneur `rockylinux-test-9`, vous devez attribuer le profil à votre conteneur :

```bash
incus profile assign ubuntu-test default,macvlan
```

Pour savoir si DHCP attribue une adresse au conteneur, arrêtez et redémarrez le conteneur :

```bash
incus restart ubuntu-test
```

Listez ensuite à nouveau les conteneurs :

```bash
+-------------------+---------+----------------------+------+-----------+-----------+
|       NAME        |  STATE  |         IPV4         | IPV6 |   TYPE    | SNAPSHOTS |
+-------------------+---------+----------------------+------+-----------+-----------+
| rockylinux-test-8 | RUNNING | 192.168.1.114 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
| rockylinux-test-9 | RUNNING | 192.168.1.151 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
| ubuntu-test       | RUNNING | 192.168.1.132 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
```

Success!

La configuration de l'IP statique est un peu différente, mais plus difficile. Vous devez modifier le fichier `.yaml` associé à la connexion du conteneur (`10-incus.yaml`). Pour cette IP statique, vous pouvez utiliser `192.168.1.201` :

```bash
vi /etc/netplan/10-incus.yaml
```

Remplacez le contenu par ce qui suit :

```bash
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: false
      addresses: [192.168.1.201/24]
      gateway4: 192.168.1.1
      nameservers:
        addresses: [8.8.8.8,8.8.4.4]
```

Veuillez enregistrer vos modifications et quitter le conteneur.

Redémarrer le conteneur :

```bash
incus restart ubuntu-test
```

Lorsque vous listez à nouveau vos conteneurs, vous devriez voir notre nouvelle IP statique :

```bash
+-------------------+---------+----------------------+------+-----------+-----------+
|       NAME        |  STATE  |         IPV4         | IPV6 |   TYPE    | SNAPSHOTS |
+-------------------+---------+----------------------+------+-----------+-----------+
| rockylinux-test-8 | RUNNING | 192.168.1.114 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
| rockylinux-test-9 | RUNNING | 192.168.1.151 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
| ubuntu-test       | RUNNING | 192.168.1.201 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+

```

CQFD !

Dans les exemples utilisés ici, un conteneur difficile à configurer a été intentionnellement choisi, ainsi que deux autres moins difficiles. Il y a encore plus de versions de Linux disponibles dans la liste des images. Si vous avez un favori, essayez de l'installer, d'attribuer le modèle `macvlan` et de définir les adresses IP.
