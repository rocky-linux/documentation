---
title: Service Tor Onion
author: Neel Chauhan
contributors: Ganna Zhrynova
tested_with: 9.3
tags:
  - web
  - proxy
  - proxies
---

# Service Tor Onion

## Introduction

[Tor](https://www.torproject.org/) est un service et un logiciel d'anonymat qui achemine le trafic via trois serveurs gérés par des bénévoles appelés relais. La conception à trois sauts `three-hop` vise à assurer la confidentialité en résistant aux tentatives de surveillance.

Une des caractéristiques de Tor est que vous pouvez exécuter des sites Web cachés et exclusifs à Tor appelés [services onion](https://community.torproject.org/onion-services/). Tout le trafic vers un service Onion est donc privé et crypté.

## Prérequis

Les conditions suivantes sont indispensables pour utiliser cette procédure :

- La capacité d'exécuter des commandes en tant qu'utilisateur root ou d'utiliser `sudo` pour élever les privilèges
- Maîtrise d'un éditeur de ligne de commande. L'auteur utilise ici `vi` ou `vim`, mais vous pouvez le remplacez par votre éditeur préféré
- A web server running on localhost, or another TCP/IP port

## Installation de `Tor`

To install Tor, you need to first install the EPEL (Extra Packages for Enterprise Linux) and run updates:

```bash
dnf -y install epel-release && dnf -y update
```

Ensuite installez `Tor` :

```bash
dnf -y install tor
```

## Configuration de `Tor`

With the packages installed, you need to configure Tor. The author uses `vi` for this, but if you prefer `nano` or something else, go ahead and substitute that in:

```bash
vi /etc/tor/torrc
```

The default `torrc` file is pretty descriptive, but can get long if you just want an onion service. A minimum onion service configuration is similar to this:

```bash
HiddenServiceDir /var/lib/tor/onion-site/
HiddenServicePort 80 127.0.0.1:80
```

### Regardons de plus près

- The "HiddenServiceDir" is the location of your onion service's hostname and cryptographic keys. You are storing these keys at `/var/lib/tor/onion-site/`
- The "HiddenServicePort" is the port forwarding from your local server to the onion service. You are forwarding 127.0.0.1:80 to port 80 on our Tor-facing service

!!! warning

    If you plan to use a directory for your onion service signing keys outside of `/var/lib/tor/`, you will need to make sure the permissions are `0700` and the owner is `toranon:toranon`.

## Configuration de serveur web

Vous aurez également besoin d'un serveur Web sur notre machine pour assurer la liaison aux clients de votre service Onion. N'importe quel serveur Web (Caddy, Apache ou Nginx) est utilisable. L'auteur favorise `Caddy`. Par souci de simplicité, installons Caddy :

```bash
dnf -y install caddy
```

Ensuite, vous insérerez ce qui suit dans le fichier `/etc/caddy/Caddyfile` :

```bash
http:// {
    root * /usr/share/caddy
    file_server
}
```

## Test et Lancement du Service

Une fois votre configuration de relais Tor définie, l'étape suivante consiste à activer les daemons Tor et Caddy :

```bash
systemctl enable --now tor caddy
```

Vous pouvez obtenir le nom d'hôte de votre service Onion grâce à cette commande :

```bash
cat /var/lib/tor/onion-site/hostname
```

Within a few minutes, your onion service will propagate via the Tor network and you can view your new onion service in the Tor browser:

![Tor Browser showing our Onion Service](../images/onion_service.png)

## Conclusion

Onion services are an invaluable tool if you are hosting a website privately or need to bypass your ISP's Carrier Grade NAT using only open source software.

While onion services are not as fast as hosting a website directly (understandable due to Tor's privacy-first design), it is way more secure and private than the public internet.
