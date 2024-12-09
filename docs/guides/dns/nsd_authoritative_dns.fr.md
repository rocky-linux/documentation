---
title: NSD Authoritative DNS
author: Neel Chauhan
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 9.4
tags:
  - dns
---

Une alternative à BIND, [NSD](https://www.nlnetlabs.nl/projects/nsd/about/) (Name Server Daemon) est un serveur DNS moderne faisant autorité uniquement maintenu par [NLnet Labs](https://www.nlnetlabs.nl/).

## Prérequis

- Un serveur utilisant Rocky Linux
- Capable d'utiliser `firewalld` pour créer des règles de pare-feu
- Un nom de domaine ou un serveur DNS récursif interne pointant vers votre serveur DNS faisant autorité

## Introduction

Les serveurs DNS externes ou publics sont utilisés sur Internet pour associer les noms d'hôtes aux adresses IP et, dans le cas des enregistrements PTR (appelés `pointer` ou `reverse`) pour faire correspondre l'adresse IP au nom de l'hôte. Il s'agit d'une composante essentielle d'internet. Il fait fonctionner votre serveur de messagerie, serveur web, serveur FTP ou beaucoup d'autres serveurs et services, où que vous soyez.

## Installation et Activation de NSD

Installez d’abord EPEL :

```bash
dnf install epel-release
```

Ensuite, installez NSD :

```bash
dnf install nsd
```

## Configuration de NSD

Avant d'apporter des modifications à un fichier de configuration, copiez le fichier actif installé d'origine, `nsd.conf` :

```bash
cp /etc/nsd/nsd.conf /etc/nsd/nsd.conf.orig
```

Cela pourra aider à l'avenir si des erreurs sont introduites dans le fichier de configuration. C'est _toujours_ une bonne idée de faire une copie de sauvegarde avant d'effectuer des modifications.

Editez le fichier _nsd.conf_. L'auteur utilise _vi_, mais vous pouvez utiliser votre éditeur préféré :

```bash
vi /etc/nsd/nsd.conf
```

Tout en bas du fichier, insérez les éléments suivants :

```bash
zone:
    name: example.com
    zonefile: /etc/nsd/example.com.zone
```

Remplacez `example.com` par le nom de domaine pour lequel vous utilisez un serveur de noms.

Créez ensuite les fichiers de zone :

```bash
vi /etc/nsd/example.com.zone
```

Les fichiers de zone DNS sont compatibles avec BIND. Ajoutez ce qui suit dans le fichier :

```bash
$TTL    86400 ; How long should records last?
; $TTL used for all RRs without explicit TTL value
$ORIGIN example.com. ; Define our domain name
@  1D  IN  SOA ns1.example.com. hostmaster.example.com. (
                              2024061301 ; serial
                              3h ; refresh duration
                              15 ; retry duration
                              1w ; expiry duration
                              3h ; nxdomain error ttl
                             )
       IN  NS     ns1.example.com. ; in the domain
       IN  MX  10 mail.another.com. ; external mail provider
       IN  A      172.20.0.100 ; default A record
; server host definitions
ns1    IN  A      172.20.0.100 ; name server definition
www    IN  A      172.20.0.101 ; web server definition
mail   IN  A      172.20.0.102 ; mail server definition
```

Si vous avez besoin d'aide pour personnaliser les fichiers de zone de type BIND, Oracle propose [une excellente introduction aux fichiers de zone](https://docs.oracle.com/en-us/iaas/Content/DNS/Reference/formattingzonefile.htm).

Enregistrez vos modifications.

## Activation de NSD

Ensuite, autorisez les ports DNS dans `firewalld` et activez NSD :

```bash
firewall-cmd --add-service=dns --zone=public
firewall-cmd --runtime-to-permanent
systemctl enable --now nsd
```

Vérifiez la résolution DNS avec la commande `host` :

```bash
% host example.com 172.20.0.100
Using domain server:
Name: 172.20.0.100
Address: 172.20.0.100#53
Aliases:

example.com has address 172.20.0.100
example.com mail is handled by 10 mail.another.com.
%
```

## Conclusion

La plupart des gens utilisent des services tiers pour le DNS. Cependant, il existe des scénarios dans lesquels l'auto-hébergement DNS est souhaité. Par exemple, les sociétés de télécommunications, d’hébergement et de médias sociaux accueillent un grand nombre d’entrées DNS où les services hébergés ne sont pas les bienvenus.

NSD est l’un des nombreux outils open source qui rendent possible l’hébergement DNS. Félicitations, vous disposez de votre propre serveur DNS !
