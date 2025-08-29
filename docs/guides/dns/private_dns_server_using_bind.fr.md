---
title: bind — Serveur DNS Privé
author: Steven Spencer
contributors: Ezequiel Bruni, k3ym0, Ganna Zhyrnova
tested_with: 8.5, 8.6, 9.0
tags:
  - dns
  - bind
---

# Serveur DNS utilisant `bind`

## Prérequis

- Un serveur utilisant Rocky Linux
- Plusieurs serveurs internes qui doivent être accessibles uniquement localement, mais pas par Internet
- Plusieurs stations de travail qui ont besoin d'accéder à ces mêmes serveurs et cohabitent sur le même réseau
- Un certain niveau de confort avec l'entrée de commandes depuis la ligne de commande
- Familarité avec l'utilisation d'un éditeur de ligne de commande (nous utilisons *vi* dans cet exemple)
- Pouvoir utiliser *firewalld* pour définir des règles pare-feu

## Introduction

Les serveurs DNS externes ou publics sont utilisés sur Internet pour associer les noms d'hôtes aux adresses IP et, dans le cas des enregistrements PTR (appelés "pointer" ou "reverse") pour faire correspondre l'adresse IP au nom de l'hôte. Il s'agit d'une composante essentielle d'internet. Il fait fonctionner votre serveur de messagerie, serveur web, serveur FTP ou beaucoup d'autres serveurs et services, où que vous soyez.

Sur un réseau privé, en particulier celui qui est utilisé pour le développement de plusieurs systèmes, vous pouvez utiliser le fichier */etc/hosts* de votre station de travail Rocky Linux pour associer un nom à une adresse IP.

Cela fonctionnera pour *votre poste de travail*, mais pas pour les autres machines de votre réseau. Si vous voulez centraliser l'association des adresses IP au nom des serveurs, la meilleure méthode est de créer un serveur DNS local pour gérer cela pour toutes vos machines.

Supposons que vous créez des serveurs DNS publics. Dans ce cas, l'auteur de cet article recommandera probablement le DNS [PowerDNS](https://www.powerdns.com/) plus robuste et performant. Il pourra être installé sur les serveurs Rocky Linux. Cependant ce guide traite d'un réseau local qui n'exposera pas ses serveurs DNS au monde extérieur. C'est pourquoi l'auteur a choisi `bind` dans cet exemple.

### Les composants du serveur DNS

Comme indiqué, DNS sépare les services en serveurs faisant autorité et récursifs. Ces services sont maintenant recommandés pour être séparés les uns des autres sur du matériel ou des conteneurs dédiés.

Le serveur faisant autorité est la zone de stockage pour toutes les adresses IP et noms d'hôte et le serveur récursif est utilisé pour rechercher des adresses et des noms d'hôtes. Dans le cas de notre serveur DNS privé, les services faisant autorité et récursifs fonctionneront ensemble.

## Installation de `bind`

La première étape consiste en l'installation de paquets :

```bash
dnf install bind bind-utils
```

Le service correspondant à *bind* est `named`. Pour activer le service au démarrage du système :

```bash
systemctl enable named
```

Lancement de `named` :

```bash
systemctl start named
```

## Configuration

Avant de modifier un fichier de configuration, c'est une bonne idée de faire une copie de sauvegarde du fichier installé d'origine, dans ce cas *named.conf*:

```bash
cp /etc/named.conf /etc/named.conf.orig
```

Cela pourra aider à l'avenir si des erreurs sont introduites dans le fichier de configuration. C'est *toujours* une bonne idée de faire une copie de sauvegarde avant de faire des modifications.

Modification du fichier *named.conf*. L'auteur utilise *vi*, mais vous pouvez utiser votre éditeur préféré :

```bash
vi /etc/named.conf
```

Désactiver listening sur localhost. Pour cela, utilisez le signe "#" pour commenter les deux lignes dans la section "options". Cela supprime toute connection avec le monde extérieur.

Cela est utile, en particulier lorsque nous allons ajouter ce DNS à nos postes de travail, parce que nous voulons que ce serveur DNS ne réponde que lorsque l'adresse IP requérant le service est locale et ne pas répondre si le service qui est consulté est sur Internet.

De cette façon, les autres serveurs DNS configurés prendront le relais presque immédiatement pour la consultation des services basés sur Internet :

```bash
options {
#       listen-on port 53 { 127.0.0.1; };
#       listen-on-v6 port 53 { ::1; };
```

Enfin, passez au bas du fichier *named.conf* et ajoutez une section pour votre propre réseau. Notre exemple utilise "ourdomain", donc insérez le nom que vous voulez donner à vos hôtes LAN :

```bash
# primary forward and reverse zones
//forward zone
zone "ourdomain.lan" IN {
     type master;
     file "ourdomain.lan.db";
     allow-update { none; };
    allow-query {any; };
};
//reverse zone
zone "1.168.192.in-addr.arpa" IN {
     type master;
     file "ourdomain.lan.rev";
     allow-update { none; };
    allow-query { any; };
};
```

Sauvegardez vos modifications (pour *vi*, ++shift+colon+w+q+exclam++)

## The forward and reverse records

Vous aurez besoin de deux fichiers dans `/var/named`. Vous allez éditer ces fichiers pour ajouter des machines à votre réseau afin de les inclure au DNS.

Le premier est le fichier de transfert pour associer l'adresse IP au nom de l'hôte correspondant. Encore une fois, nous utilisons « ourdomain » comme exemple. Notez que l'adresse IP de notre DNS local dans l'exemple est 192.168.1.136. Les hôtes sont ajoutés au bas de ce fichier.

```bash
vi /var/named/ourdomain.lan.db
```

Après modification le fichier ressemblera à ce contenu :

```bash
$TTL 86400
@ IN SOA dns-primary.ourdomain.lan. admin.ourdomain.lan. (
    2019061800 ;Serial
    3600 ;Refresh
    1800 ;Retry
    604800 ;Expire
    86400 ;Minimum TTL
)

;Name Server Information
@ IN NS dns-primary.ourdomain.lan.

;IP for Name Server
dns-primary IN A 192.168.1.136

;A Record for IP address to Hostname
wiki IN A 192.168.1.13
www IN A 192.168.1.14
devel IN A 192.168.1.15
```

Ajoutez autant d'hôtes que nécessaire au bas du fichier avec leurs adresses IP, puis enregistrez vos modifications.

Vous aurez besoin d'un fichier inverse pour relier le nom de l'hôte à l'adresse IP correspondante. Dans l'exemple, il suffit d'indiquer seulement le dernier octet (une adresse IPv4 est constituée de quatre octets séparés par des points ".") de l'hôte, le PTR, et son nom.

```bash
vi /var/named/ourdomain.lan.rev
```

Lorsque vous aurez terminé, le fichier ressemblera au contenu suivant :

```bash
$TTL 86400
@ IN SOA dns-primary.ourdomain.lan. admin.ourdomain.lan. (
    2019061800 ;Serial
    3600 ;Refresh
    1800 ;Retry
    604800 ;Expire
    86400 ;Minimum TTL
)
;Name Server Information
@ IN NS dns-primary.ourdomain.lan.

;Reverse lookup for Name Server
136 IN PTR dns-primary.ourdomain.lan.

;PTR Record IP address to HostName
13 IN PTR wiki.ourdomain.lan.
14 IN PTR www.ourdomain.lan.
15 IN PTR devel.ourdomain.lan.
```

Ajoutez tous les noms d'hôtes qui apparaissent dans le fichier forward puis enregistrez vos modifications.

### Tout ce que cela signifie

Maintenant que nous avons ajouté tout cela et que nous nous apprêtons à redémarrer notre serveur DNS *bind* examinons succinctement la terminologie utilisée dans ces deux fichiers.

Just making things work is not good enough if you do not know what each term means, right?

- **TTL** apparaît dans les deux fichiers et signifie « Time To Live». TTL indique au serveur DNS combien de temps il faut conserver son cache avant de demander une nouvelle copie. Dans ce cas, le TTL est le paramètre par défaut pour tous les enregistrements, à moins qu'un TTL spécifique ne soit défini. La valeur par défaut ici est 86400 secondes c'est-à-dire 24 heures.
- **IN** signifie Internet. Dans notre exemple, nous n'utilisons pas Internet, alors considérez IN comme l'intranet. Considérez plutôt cela comme l’Intranet.
- **SOA** signifie "Start Of Authority" ou ce que le serveur DNS principal est pour le domaine.
- **NS** signifie "Name Server"
- **Serial** est la valeur utilisée par le serveur DNS pour vérifier que le contenu du fichier de zone est à jour
- **Refresh** spécifie à quelle fréquence un serveur DNS slave doit effectuer un transfert de zone depuis le serveur master
- **Retry** spécifie la durée de temps en secondes à attendre avant d'essayer à nouveau sur un transfert de zone qui a échoué
- **Expire** spécifie combien de temps un serveur esclave doit attendre pour répondre à une requête quand le serveur master est injoignable
- **A** est l'adresse de l'hôte ou l'enregistrement de transfert et n'est contenu que dans le fichier de transfert (ci-dessus)
- **PTR** le pointeur mieux connu sous le nom de "reverse" et n'est que dans notre fichier reverse

## Configurations de test

Une fois que nous avons créé tous nos fichiers, nous devons nous assurer que les fichiers de configuration et les zones sont en bon état de fonctionnement avant de relancer le service *bind*.

Vérifier la configuration principale :

```bash
named-checkconf
```

Cela renverra un résultat vide si tout va bien.

Vérifier la zone forward :

```bash
named-checkzone ourdomain.lan /var/named/ourdomain.lan.db
```

Cela renverra quelque chose comme ceci si tout va bien :

```bash
zone ourdomain.lan/IN: loaded serial 2019061800
OK
```

Et enfin vérifiez la zone inversée :

```bash
named-checkzone 192.168.1.136 /var/named/ourdomain.lan.rev
```

Cela renverra quelque chose comme ceci si tout va bien :

```bash
zone 192.168.1.136/IN: loaded serial 2019061800
OK
```

En supposant que tout semble bien, allez-y et redémarrez *bind*:

```bash
systemctl start named
```

=== "9"

    ## 9 Utilisation de IPv4 pour votre LAN
    
    Pour utiliser UNIQUEMENT IPv4 sur votre LAN, vous devez faire un changement dans le fichier `/etc/sysconfig/named` :

    ```
    vi /etc/sysconfig/named
    ```


    Ajoutez ceci en bas du fichier :

    ```
    OPTIONS="-4"
    ```


    Enregistrez ces modifications.
    
    ##9 Machines d'essais
    
    
    Vous devez ajouter le serveur DNS (dans notre exemple 192.168.1.136) à chaque machine sur laquelle vous souhaitez avoir accès aux serveurs ajoutés à votre DNS local. L'auteur montre uniquement un exemple de la façon de procéder sur un poste de travail Rocky Linux. Des méthodes similaires existent pour d'autres distributions Linux, machines Windows et Mac.
    
    Vous souhaiterez ajouter les serveurs DNS à la liste, sans remplacer ce qui s'y trouve actuellement, car vous aurez toujours besoin d'un accès Internet, ce qui nécessitera vos serveurs DNS actuellement attribués. DHCP (Dynamic Host Configuration Protocol) services generally assign these or they are statically assigned.
    
    Vous ajouterez notre DNS local avec `nmcli` puis relancerez la connexion. 
    
    ??? warning "Noms de Profil Stupides"
    
     Avec le NetworkManager, les connexions ne sont pas modifiées par le nom du périphérique mais par le nom du profil. Quelque chose comme "Wired connection 1" ou bien "Wireless connection 1". Vous pouvez voir le profil en exécutant `nmcli` sans aucun paramètre :

        ```
        nmcli
        ```


        Cela vous montrera une sortie comme ceci :

        ```bash
        enp0s3: connected to Wired Connection 1
        "Intel 82540EM"
        ethernet (e1000), 08:00:27:E4:2D:3D, hw, mtu 1500
        ip4 default
        inet4 192.168.1.140/24
        route4 192.168.1.0/24 metric 100
        route4 default via 192.168.1.1 metric 100
        inet6 fe80::f511:a91b:90b:d9b9/64
        route6 fe80::/64 metric 1024

        lo: unmanaged
            "lo"
            loopback (unknown), 00:00:00:00:00:00, sw, mtu 65536

        DNS configuration:
            servers: 192.168.1.1
            domains: localdomain
            interface: enp0s3

        Use "nmcli device show" to get complete information about known devices and
        "nmcli connection show" to get an overview on active connection profiles.
        ```


        Avant même de commencer à modifier la connexion, vous devez lui donner un nom sensé, comme le nom de l'interface (**notez** le "\" ci-dessous échappe aux espaces dans le nom) :

        ```
        nmcli connection modify Wired\ connection\ 1 con-name enp0s3
        ```


        Une fois que vous aurez fait cela, lancez `nmcli` à nouveau et vous devriez voir quelque chose comme ceci :

        ```bash
        enp0s3: connected to enp0s3
        "Intel 82540EM"
        ethernet (e1000), 08:00:27:E4:2D:3D, hw, mtu 1500
        ip4 default
        inet4 192.168.1.140/24
        route4 192.168.1.0/24 metric 100
        route4 default via 192.168.1.1 metric 100
        ...
        ```


        Cela rendra la configuration restante pour le DNS beaucoup plus facile !
    
    En supposant que le nom de votre profil de connexion soit "enp0s3", nous inclurons le DNS déjà configuré, mais ajouterons d'abord notre serveur DNS local :

    ```
    nmcli con mod enp0s3 ipv4.dns '192.168.1.138,192.168.1.1'
    ```


    Vous pouvez avoir plus de serveurs DNS. Pour une machine configurée avec des serveurs DNS publics, par exemple le DNS ouvert de Google, vous pourriez plutôt rencontrer ce genre de problème :

    ```
    nmcli con mod enp0s3 ipv4.dns '192.168.1.138,8.8.8.8,8.8.4.4'
    ```


    Une fois que vous avez ajouté les serveurs DNS souhaités à votre connexion, vous devriez être en mesure de résoudre les hôtes dans *ourdomain.lan*, ainsi que les hôtes depuis Internet.

=== "8"

    ## 8 Utiliser IPv4 sur le LAN
    
    Si vous utilisez uniquement IPv4 sur votre réseau local, vous devez effectuer deux modifications. Le premier se trouve dans `/etc/named.conf` et le second dans `/etc/sysconfig/named`.
    
    Tout d'abord, vous pouvez accéder à nouveau au fichier `named.conf` avec `vi /etc/named.conf`. Vous devez ajouter l’option suivante quelque part dans la section des options.

    ```
    filter-aaaa-on-v4 yes;
    ```


    Cf. :
    
    ![Add Filter IPv6](images/dns_filter.png)
    
    Les changements effectués, enregistrez et quittez le fichier `named.conf` (pour *vi*, ++shift+colon+w+q+exclam++)
    
    Vous devrez faire des modifications similaires dans le fichier `/etc/sysconfig/named` :

    ```
    vi /etc/sysconfig/named
    ```


    Ajoutez ceci à la fin du fichier :

    ```
    OPTIONS="-4"
    ```


    Enregistrez vos modifications (encore une fois, pour _vi_, `SHIFT:wq!`).
    
    
    ##8 Machines d'essais
    
    Vous devez ajouter le serveur DNS (dans notre exemple 192.168.1.136) à chaque machine sur laquelle vous souhaitez avoir accès aux serveurs ajoutés à votre DNS local. L'auteur montre uniquement un exemple de la façon de procéder sur un poste de travail Rocky Linux. Des méthodes similaires existent pour d'autres distributions Linux, machines Windows et Mac.
    
    Vous devez ajouter votre serveur DNS à la liste, car vous avez toujours besoin d'un accès Internet, qui nécessite vos serveurs DNS actuellement attribués. En règle générale, DHCP (Dynamic Host Configuration Protocol) les attribue automatiquement ou alors ils sont attribués de manière statique.
    
    Sur un poste de travail Rocky Linux sur lequel l'interface réseau activée est eth0, utilisez la commande suivante :

    ```
    vi /etc/sysconfig/network-scripts/ifcfg-eth0
    ```


    Si l'interface réseau activée est différente, vous devez remplacer le nom correspondant de l'interface. Le fichier de configuration qui s'ouvre devrait ressembler à ce qui suit pour une adresse IP attribuée de manière statique (et non DHCP comme mentionné précédemment). Dans l'exemple suivant, l'adresse IP de notre machine est 192.168.1.151 :

    ```
    DEVICE=eth0
    BOOTPROTO=none
    IPADDR=192.168.1.151
    PREFIX=24
    GATEWAY=192.168.1.1
    DNS1=8.8.8.8
    DNS2=8.8.4.4
    ONBOOT=yes
    HOSTNAME=tender-kiwi
    TYPE=Ethernet
    MTU=
    ```


    You want to substitute in our new DNS server for the primary (DNS1) and move each of the other DNS servers down one:

    ```
    DEVICE=eth0
    BOOTPROTO=none
    IPADDR=192.168.1.151
    PREFIX=24
    GATEWAY=192.168.1.1
    DNS1=192.168.1.136
    DNS2=8.8.8.8
    DNS3=8.8.4.4
    ONBOOT=yes
    HOSTNAME=tender-kiwi
    TYPE=Ethernet
    MTU=
    ```


    Une fois les modifications terminées, redémarrez la machine ou bien relancez le réseau avec la commande suivante :

    ```
    systemctl restart network
    ```


    Vous pourrez désormais accéder à tout ce qui se trouve dans le domaine *ourdomain.lan* à partir de vos postes de travail, tout en étant toujours en mesure de résoudre les adresses Internet et y accéder.

## Règles du pare-feu - `firewalld`

!!! note "`firewalld` par défaut"

    Avec Rocky Linux 9.0 et les versions ultérieures, l'utilisation des règles `iptables` est obsolète. Vous devriez plutôt utiliser `firewalld`.

L'auteur ne fait aucune hypothèse sur le réseau ou les services dont vous pourriez avoir besoin, à l'exception de l'activation de l'accès SSH et de l'accès DNS pour votre réseau LAN uniquement. Pour cela, vous utiliserez la zone intégrée de `firewalld`, `trusted`. Vous devrez apporter des modifications de service à la zone `public` pour limiter l'accès SSH au LAN.

La première étape consiste à ajouter votre réseau LAN à la zone `trusted` :

```bash
firewall-cmd --zone=trusted --add-source=192.168.1.0/24 --permanent
```

Ajoutez les deux services à la zone `trusted` :

```bash
firewall-cmd --zone=trusted --add-service=ssh --permanent
firewall-cmd --zone=trusted --add-service=dns --permanent
```

Supprimez le service SSH de la zone `public`, qui est activée par défaut :

```bash
firewall-cmd --zone=public --remove-service=ssh --permanent
```

Rechargez le pare-feu et répertoriez les zones dans lesquelles vous avez apporté des modifications :

```bash
firewall-cmd --reload
firewall-cmd --zone=trusted --list-all
```

Ce qui montrera que vous avez correctement ajouté les services et le réseau source :

```bash
trusted (active)
    target: ACCEPT
    icmp-block-inversion: no
    interfaces:
    sources: 192.168.1.0/24
    services: dns ssh
    ports:
    protocols:
    forward: no
    masquerade: no
    forward-ports:
    source-ports:
    icmp-blocks:
    rich rules:
```

L'énumération de la zone `public` montrera que l'accès SSH n'est plus autorisé :

```bash
firewall-cmd --zone=public --list-all
```

Affiche :

```bash
public
    target: default
    icmp-block-inversion: no
    interfaces:
    sources:
    services: cockpit dhcpv6-client
    ports:
    protocols:
    forward: no
    masquerade: no
    forward-ports:
    source-ports:
    icmp-blocks:
    rich rules:
```

Ces règles vous permettront d'obtenir une résolution DNS sur votre serveur DNS privé à partir des hôtes du réseau 192.168.1.0/24. De plus, vous pourrez vous connecter en SSH depuis n'importe lequel de ces hôtes à votre serveur DNS privé.

## Conclusions

La modification de */etc/hosts* sur un poste de travail individuel vous donnera accès à une machine sur votre réseau interne, mais vous ne pourrez l'utiliser que sur cette seule machine. Un serveur DNS privé qui utilise *bind* vous permettra d'ajouter des hôtes au DNS et, à condition que les postes de travail aient accès à ce serveur DNS privé, ils pourront accéder à ces serveurs locaux.

Si vous n'avez pas besoin de machines pour résoudre des problèmes sur Internet, mais que vous avez besoin d'un accès local depuis plusieurs machines vers des serveurs locaux, envisagez plutôt un serveur DNS privé.
