---
title: Unbound – Résolveur DNS récursif
author: Neel Chauhan
contributors: Steven Spencer
tested_with: 9.4
tags:
  - dns
---

En alternative à BIND, [Unbound](https://www.nlnetlabs.nl/projects/unbound/about/) est un serveur DNS moderne de validation, récursif et de mise en cache géré par [NLnet Labs](https://www.nlnetlabs .nl/).

## Prérequis

- Un serveur utilisant Rocky Linux
- Pouvoir utiliser `firewalld` pour créer des règles de pare-feu

## Introduction

Il existe deux types de serveurs DNS : ceux faisant autorité et récursifs. Là où les serveurs DNS faisant autorité annoncent une zone DNS, les serveurs récursifs résolvent les requêtes au nom des clients en les transmettant à un FAI ou à un résolveur DNS public, ou aux zones racine pour les serveurs plus importants.

À titre d'exemple, votre routeur domestique exécute probablement un résolveur DNS récursif intégré à transmettre à votre FAI ou à un serveur DNS public bien connu qui est également un serveur DNS récursif.

## Installation et mise en place de Unbound

Installation de Unbound :

```bash
dnf install unbound
```

## Configuration de Unbound

Avant d'apporter des modifications à un fichier de configuration, déplacez le fichier opérationnel installé d'origine, `unbound.conf` :

```bash
cp /etc/unbound/unbound.conf /etc/unbound/unbound.conf.orig
```

Cela pourra aider à l'avenir si des erreurs sont introduites dans le fichier de configuration. C'est _toujours_ une bonne idée de faire une copie de sauvegarde avant d'effectuer des modifications.

Éditer le fichier _unbound.conf_. L'auteur utilise _vi_, mais vous pouvez utiliser votre éditeur préféré :

```bash
vi /etc/unbound/unbound.conf
```

Insérez les éléments suivants :

```bash
server:
    interface: 0.0.0.0
    interface: ::
    access-control: 192.168.0.0/16 allow
    access-control: 2001:db8::/64 allow

forward-zone:
    name: "."
    forward-addr: 1.0.0.1@53
    forward-addr: 1.1.1.1@53
```

Remplacez `192.168.0.0/16` et `2001:db8::/64` par les sous-réseaux pour lesquels vous voulez résoudre les requêtes DNS. Enregistrez vos modifications.

### Regardons de plus près

- La variable `interface` indique les interfaces (IPv4 ou IPv6) sur lesquelles vous souhaitez écouter les requêtes DNS. Nous écoutons sur toutes les interfaces avec `0.0.0.0` et `::`.
- La variable `access-control` indique les sous-réseaux (IPv4 ou IPv6) à partir desquels vous souhaitez autoriser les requêtes DNS. Nous autorisons les requêtes provenant de `192.168.0.0/16` et `2001:db8::/64`.
- La variable `forward-addr` définit les serveurs vers lesquels nous transmettrons. Nous transmettons vers la version 1.1.1.1 de Cloudflare.

## Activation de Unbound

Ensuite, autorisez les ports DNS dans `firewalld` et activez Unbound :

```bash
firewall-cmd --add-service=dns --zone=public
firewall-cmd --runtime-to-permanent
systemctl enable --now unbound
```

Vérifiez la résolution DNS avec la commande `host` :

```bash
$ host google.com 172.20.0.100
Using domain server:
Name: 172.20.0.100
Address: 172.20.0.100#53
Aliases:

google.com has address 142.251.215.238
google.com has IPv6 address 2607:f8b0:400a:805::200e
google.com mail is handled by 10 smtp.google.com.
```

%

## Conclusion

La plupart des gens utilisent le résolveur DNS de leur routeur domestique ou des résolveurs DNS publics gérés par les FAI et les entreprises technologiques. Dans les labos à domicile et les grands réseaux, il est courant d'exécuter un résolveur à l'échelle du réseau pour réduire la latence et la charge du réseau en mettant en cache les requêtes DNS pour les sites Web couramment demandés tels que Google. Un résolveur à l'échelle du réseau autorise également les services intranet tels que SharePoint et Active Directory.

Unbound est l'un des nombreux outils open source qui rendent possible la résolution DNS. Félicitations, vous possédez votre propre résolveur DNS ! À bientôt !
