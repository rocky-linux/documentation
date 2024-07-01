---
title: SSH Certificate Authorities and Key Signing
author: Julian Patocki
contributors: Steven Spencer
tags:
  - sécurité
  - ssh
  - keygen
  - certificats
---

## Prérequis

- Savoir utiliser les outils de ligne de commande
- Gestion de contenus à partir de la ligne de commande
- Une certaine expérience des clés SSH est souhaitée mais pas indispensable
- Une connaissance de base de SSH et de l'infrastructure de clés publiques est utile mais facultative
- Un serveur qui exécute le daemon `sshd`.

## Introduction

La connexion SSH initiale avec un hôte distant n'est pas sécurisée si vous ne pouvez pas vérifier l'empreinte digitale de la clé de l'hôte distant. L'utilisation d'une autorité de certification pour signer les clés publiques des hôtes distants garantit la sécurité de la connexion initiale pour chaque utilisateur qui fait confiance à l'autorité de certification.

Les autorités de certification peuvent également être utilisées pour signer les clés SSH des utilisateurs. Au lieu de distribuer la clé à chaque hôte distant, une seule signature suffit à autoriser l'utilisateur à se connecter à plusieurs serveurs.

## Objectifs

- Amélioration de la sécurité des connexions SSH.
- Consolider le processus d'intégration et la gestion des clés.

## Notes

- L'auteur de l'article favorise l'éditeur de texte `vim`. L'utilisation d'éditeurs de texte comme `nano` ou autres est tout à fait acceptable.
- L'utilisation de `sudo` ou `root` implique des privilèges supplémentaires.

## Connexion initiale

Pour sécuriser la connexion initiale, vous devez connaître au préalable l’empreinte digitale de la clé. Vous pouvez optimiser et intégrer cette procédure de déploiement pour les nouveaux hôtes.

Affichage de l'empreinte digitale de la clé sur l'hôte distant :

```bash
user@rocky-vm ~]$ ssh-keygen -E sha256 -l -f /etc/ssh/ssh_host_ed25519_key.pub 
256 SHA256:bXWRZCpppNWxXs8o1MyqFlmfO8aSG+nlgJrBM4j4+gE no comment (ED25519)
```

Établissement de la connexion SSH initiale depuis le client. L'empreinte de la clé s'affiche et peut être comparée à celle précédemment acquise :

```bash
[user@rocky ~]$ ssh user@rocky-vm.example.com
The authenticity of host 'rocky-vm.example (192.168.56.101)' can't be established.
ED25519 key fingerprint is SHA256:bXWRZCpppNWxXs8o1MyqFlmfO8aSG+nlgJrBM4j4+gE.
This key is not known by any other names
Are you sure you want to continue connecting (yes/no/[fingerprint])?
```

## Création d'une Autorité de Certification

Créer une autorité de certification (clés privées et publiques) et placer la clé publique dans le fichier `known_hosts` du client pour identifier tous les hôtes appartenant au domaine example.com :

```bash
[user@rocky ~]$ ssh-keygen -b 4096 -t ed25519 -f CA
[user@rocky ~]$ echo '@cert-authority *.example.com' $(cat CA.pub) >> ~/.ssh/known_hosts
```

Où :

- **-b** : bytes, longueur de clé en octets
- **-t** : type de clé ; rsa, ed25519, ecdsa...
- **-f** : fichier d'enregistrement de la clé

Vous pouvez aussi spécifier la variable `known_hosts` pour tout le système en éditant le fichier de configuration SSH `/etc/ssh/ssh_config` :

```bash
Host *
    GlobalKnownHostsFile /etc/ssh/ssh_known_hosts
```

## Signature des clés publiques

Création d'une clé SSH utilisateur et signature :

```bash
[user@rocky ~]$ ssh-keygen -b 4096 -t ed2119
[user@rocky ~]$ ssh-keygen -s CA -I user -n user -V +55w  id_ed25519.pub
```

Acquisition de la clé publique du serveur via `scp` et signature :

```bash
[user@rocky ~]$ scp user@rocky-vm.example.com:/etc/ssh/ssh_host_ed25519_key.pub .
[user@rocky ~]$ ssh-keygen -s CA -I rocky-vm -n rocky-vm.example.com -h -V +55w ssh_host_ed25519_key.pub
```

Où :

- **-s** : signature de clé
- **-I** : nom identifiant le certificat à des fins de journalisation
- **-n** : identifie le nom (hôte ou utilisateur, un ou plusieurs) associé au certificat (s'il n'est pas spécifié, les certificats sont valables pour tous les utilisateurs ou hôtes)
- **-h** : définit le certificat comme clé hôte, par opposition à une clé cliente
- **-V** : durée de validité du certificat

## Établir la confiance

Copie du certificat de l'hôte distant pour que l'hôte distant le présente avec sa clé publique lorsqu'il est connecté :

```bash
[user@rocky ~]$ scp ssh_host_ed25519_key-cert.pub root@rocky-vm.example.com:/etc/ssh/
```

Copie de la clé publique de l'autorité de certification sur l'hôte distant pour qu'il fasse confiance aux certificats signés par l'autorité de certification :

```bash
[user@rocky ~]$ scp CA.pub root@rocky-vm.example.com:/etc/ssh/
```

Ajouter les lignes suivantes au fichier `/etc/ssh/sshd_config` pour spécifier la clé et le certificat précédemment copiés à utiliser par le serveur et faire confiance à l'autorité de certification pour identifier les utilisateurs :

```bash
[user@rocky ~]$ ssh user@rocky-vm.example.com
[user@rocky-vm ~]$ sudo vim /etc/ssh/sshd_config
```

```bash
HostKey /etc/ssh/ssh_host_ed25519_key
HostCertificate /etc/ssh/ssh_host_ed25519_key-cert.pub
TrustedUserCAKeys /etc/ssh/CA.pub
```

Redémarrage du service `sshd` sur le serveur :

```bash
[user@rocky-vm ~]$ systemctl restart sshd
```

## Test de connection

Suppression de l'empreinte digitale du serveur distant de votre fichier `known_hosts` et vérification des paramètres en établissant une connexion SSH :

```bash
[user@rocky ~]$ ssh-keygen -R rocky-vm.example.com
[user@rocky ~]$ ssh user@rocky-vm.example.com
```

## Révocation de Clé

La révocation des clés d’hôte ou d’utilisateur peut s’avérer cruciale pour la sécurité de l’ensemble de l’environnement. Il est donc important de stocker les clés publiques précédemment signées pour pouvoir les révoquer à un moment donné dans le futur.

Création d'une liste de révocation vide et révocation de la clé publique de l'utilisateur user2 :

```bash
[user@rocky ~]$ sudo ssh-keygen -k -f /etc/ssh/revokation_list.krl
[user@rocky ~]$ sudo ssh-keygen -k -f /etc/ssh/revokation_list.krl -u /path/to/user2_id_ed25519.pub
```

Copier la liste de révocation sur l'hôte distant et la spécifier dans le fichier `sshd_config` :

```bash
[user@rocky ~]$ scp /etc/ssh/revokation_list.krl root@rocky-vm.example.com:/etc/ssh/
[user@rocky ~]$ ssh user@rocky-vm.example.com
[user@rocky ~]$ sudo vim /etc/ssh/sshd_config
```

La ligne suivante indique la liste de révocation :

```bash
RevokedKeys /etc/ssh/revokation_list.krl
```

Il est nécessaire de redémarrer le démon SSHD pour que la configuration soit rechargée :

```bash
[user@rocky-vm ~]$ sudo systemctl restart sshd
```

L'utilisateur user2 est rejeté par le serveur :

```bash
[user2@rocky ~]$ ssh user2@rocky-vm.example.com
user2@rocky-vm.example.com: Permission denied (publickey,gssapi-keyex,gssapi-with-mic).
```

La révocation des clés du serveur est également possible :

```bash
[user@rocky ~]$ sudo ssh-keygen -k -f /etc/ssh/revokation_list.krl -u /path/to/ssh_host_ed25519_key.pub
```

Les lignes suivantes dans `/etc/ssh/ssh_config` déterminent la liste de révocation d'hôtes à l'échelle du système :

```bash
Host *
        RevokedHostKeys /etc/ssh/revokation_list.krl
```

La tentative de connexion à l'hôte entraîne les résultats suivants :

```bash
[user@rocky ~]$ ssh user@rocky-vm.example.com
Host key ED25519-CERT SHA256:bXWRZCpppNWxXs8o1MyqFlmfO8aSG+nlgJrBM4j4+gE revoked by file /etc/ssh/revokation_list.krl
```

La maintenance et la mise à jour des listes de révocation sont très importantes. Vous pouvez automatiser le processus pour vous assurer que les listes de révocation les plus récentes sont accessibles à tous les hôtes et utilisateurs.

## Conclusion

SSH est l'un des protocoles les plus importants pour gérer des serveurs distants. La mise en œuvre d’autorités de certification peut s’avérer utile, en particulier dans les environnements plus vastes comportant de nombreux serveurs et utilisateurs.
Il est important de bien tenir à jour des listes de révocation. It ensures the **REVOCATION** of compromised keys easily without replacing the whole key infrastructure.
