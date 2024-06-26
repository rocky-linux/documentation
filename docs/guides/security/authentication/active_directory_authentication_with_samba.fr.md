---
title: Active Directory Authentication avec Samba
author: Neel Chauhan
contributors: Steven Spencer
tested_with: 9.4
---

## Prérequis

- Connaissances de base de Active Directory
- Connaissances de base de LDAP

## Introduction

Active Directory (AD) de Microsoft est, dans la plupart des entreprises, le système d'authentification standard pour les systèmes Windows et pour les applications externes connectées à LDAP. Il permet de configurer les utilisateurs et les groupes, le contrôle d'accès, les permissions, le montage automatique, etc.

Alors que la connexion de Linux à un cluster AD ne peut pas prendre en charge _toutes_ les fonctionnalités mentionnées, elle peut gérer les utilisateurs, les groupes et le contrôle d'accès. Il est même possible (grâce à quelques ajustements de configuration du côté Linux et à certaines options côté AD) de distribuer des clés SSH à l'aide d'Active Directory.

La manière par défaut d'utiliser Active Directory sur Rocky Linux utilise SSSD mais Samba offre une alternative plus complète. Par exemple, le partage de fichiers peut se faire avec Samba mais pas avec SSSD. Ce guide, cependant, couvrira uniquement la configuration de l'authentification sur Active Directory à l'aide de Samba et n'inclura aucune configuration supplémentaire du côté Windows.

## Découvrir et joindre AD en utilisant Samba

!!! note "Remarque"

```
Le nom de domaine `ad.company.local` dans ce guide représentera le domaine Active Directory. Pour suivre ce guide, remplacez-le par le nom de votre domaine AD.
```

La première étape pour relier un système GNU/Linux à AD consiste à connecter votre
Cluster AD, pour s'assurer que la configuration réseau est correcte des deux côtés.

### Préparations

- Assurez-vous que les ports suivants sont ouverts sur votre hôte GNU/Linux dans le contrôleur de domaine :

  | Service  | Port(s)           | Notes                                                                                                     |
  | -------- | ------------------------------------ | --------------------------------------------------------------------------------------------------------- |
  | DNS      | 53 (TCP+UDP)      |                                                                                                           |
  | Kerberos | 88, 464 (TCP+UDP) | Utilisé par `kadmin` pour définir et mettre à jour les mots de passe                                      |
  | LDAP     | 389 (TCP+UDP)     |                                                                                                           |
  | LDAP-GC  | 3268 (TCP)        | Catalogue global LDAP - vous permet de trouver des identifiants d'utilisateur à partir d'Active Directory |

- Assurez-vous d'avoir configuré votre contrôleur de domaine AD en tant que serveur DNS sur votre hôte Rocky Linux :

  **Avec NetworkManager :**

  ```sh
  # where your primary NetworkManager connection is 'System eth0' and your AD
  # server is accessible on the IP address 10.0.0.2.
  [root@host ~]$ nmcli con mod 'System eth0' ipv4.dns 10.0.0.2
  ```

- Assurez-vous que les horloges sont synchronisées des deux côtés (hôte AD et système GNU/Linux)

  **Vérifier l'heure sur Rocky Linux :**

  ```sh
  [user@host ~]$ date
  Wed 22 Sep 17:11:35 BST 2021
  ```

- Installez les paquets nécessaires pour la connexion à AD côté GNU/Linux :

  ```sh
  [user@host ~]$ sudo dnf install samba samba-winbind samba-client
  ```

### Connexion automatique

Maintenant, vous devriez être en mesure de vous connecter avec succès à votre ou vos serveur(s) AD à partir de votre hôte Linux.

```sh
[user@host ~]$ realm discover ad.company.local
ad.company.local
  type: kerberos
  realm-name: AD.COMPANY.LOCAL
  domain-name: ad.company.local
  configured: no
  server-software: active-directory
  client-software: sssd
  required-package: oddjob
  required-package: oddjob-mkhomedir
  required-package: sssd
  required-package: adcli
  required-package: samba-common
```

Cela sera découvert à l'aide des enregistrements SRV pertinents stockés dans votre service DNS d'Active Directory.

### Connexion

Une fois que vous avez découvert avec succès votre installation Active Directory à partir de l'hôte Linux, vous devriez pouvoir utiliser `realmd` pour rejoindre le domaine, qui orchestrera la configuration de Samba à l'aide de `adcli` et d'autres outils similaires.

```sh
[user@host ~]$ sudo realm join -v --membership-software=samba --client-software=winbind ad.company.local
```

Vous serez invité à saisir le mot de passe administrateur de votre domaine, alors tapez-le.

Si ce processus affiche un problème de chiffrement comme `KDC has no support for encryption type`, essayez de mettre à jour la stratégie de chiffrement globale pour autoriser les algorithmes de chiffrement plus anciens :

```sh
[user@host ~]$ sudo update-crypto-policies --set DEFAULT:AD-SUPPORT
```

Si ce processus réussit, vous devriez maintenant pouvoir extraire les informations `passwd` pour un utilisateur Active Directory.

```sh
[user@host ~]$ sudo getent passwd administrator@ad.company.local
AD\administrator:*:1450400500:1450400513:Administrator:/home/administrator@ad.company.local:/bin/bash
```

!!! note "Remarque"

```
`getent` récupère les entrées des bibliothèques Name Service Switch (NSS). Cela signifie que, contrairement à `passwd` ou `dig` par exemple, il interrogera différentes bases de données, y compris `/etc/hosts` pour `getent hosts` ou depuis `samba` dans le cas `getent passwd`.
```

`realm` propose quelques options intéressantes que vous pouvez utiliser :

| Option                                                                     | Observation                                                            |
| -------------------------------------------------------------------------- | ---------------------------------------------------------------------- |
| --computer-ou='OU=LINUX,OU=SERVERS,dc=ad,dc=company.local' | Le OU où stocker le compte du serveur                                  |
| --os-name='rocky'                                                          | Spécifie le nom du système d'exploitation stocké dans Active Directory |
| --os-version='8'                                                           | Indique la version de l'OS stockée dans Active Directory               |
| -U admin_username                                     | Indique un compte administrateur                                       |

### Tentative d'Authentification

Now your users should be able to authenticate to your Linux host against Active Directory.

**Sous Windows 10 :** (qui fournit sa propre copie d'OpenSSH)

```dos
C:\Users\John.Doe> ssh -l john.doe@ad.company.local linux.host
Password for john.doe@ad.company.local:

Activate the web console with: systemctl enable --now cockpit.socket

Last login: Wed Sep 15 17:37:03 2021 from 10.0.10.241
[john.doe@ad.company.local@host ~]$
```

If this succeeds, you have successfully configured Linux to use Active Directory as an authentication source.

### Suppression du nom de domaine dans les noms d'utilisateurs

Dans une configuration complètement par défaut, vous devrez vous connecter avec votre compte AD en spécifiant le domaine dans votre nom d'utilisateur (par exemple, « john.doe@ad.company.local »). Si ce n'est pas le comportement souhaité et que vous souhaitez plutôt pouvoir omettre le nom de domaine par défaut au moment de l'authentification, vous pouvez configurer Samba pour qu'il utilise par défaut un domaine spécifique.

This is a relatively straightforward process, requiring a configuration tweak in your SSSD configuration file.

```sh
[user@host ~]$ sudo vi /etc/samba/smb.conf
[global]
...
winbind use default domain = yes
```

En ajoutant le `winbind use default domain`, vous demandez à Samba de déduire que l'utilisateur tente de s'authentifier en tant qu'utilisateur du domaine « ad.company.local ». This allows you to authenticate as something like `john.doe` instead of `john.doe@ad.company.local`.

Pour que cette modification de configuration prenne effet, vous devez redémarrer les services `smb` et `winbind` avec `systemctl`.

```sh
[user@host ~]$ sudo systemctl restart smb winbind
```

De la même manière, si vous ne souhaitez pas que vos répertoires personnels soient suffixés avec le nom de domaine, vous pouvez ajouter ces options dans votre fichier de configuration `/etc/samba/smb.conf` :

```bash
[global]
template homedir = /home/%U
```

N'oubliez pas de redémarrer les services `smb` et `winbind`.
