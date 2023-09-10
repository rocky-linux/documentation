---
author: Hayden Young
contributors: Krista Burdine, Steven Spencer, Sambhav Saggi, Antoine Le Morvan
---

# Authentification avec Active Directory

## Prérequis

- Connaissances de base de Active Directory
- Connaissances de base de LDAP

## Présentation de Active Directory

Active Directory (AD) de Microsoft est, dans la plupart des entreprises, le système d'authentification standard pour les systèmes Windows et pour les applications externes connectées à LDAP. Il permet de configurer les utilisateurs et les groupes, le contrôle d'accès, les permissions, le montage automatique, etc.

Alors que la connexion de Linux à un cluster AD ne peut pas prendre en charge _toutes_ les fonctionnalités mentionnées, elle peut gérer les utilisateurs, les groupes et le contrôle d'accès. Il est même possible (grâce à quelques ajustements de configuration du côté Linux et à certaines options côté AD) de distribuer des clés SSH à l'aide d'Active Directory.

Ce guide, cependant, ne couvrira que la configuration de l'authentification par rapport à Active Directory côté GNU/Linux, et n'inclura aucune configuration supplémentaire du côté Windows.

## Intégration de Active Directory en utilisant SSSD

!!! note "Remarque"

    Tout au long de ce guide, le nom de domaine "ad.company.local" sera utilisé pour
    représenter le domaine Active Directory. En accord avec ce guide, remplacez-le par le nom réel utilisé par votre domaine AD.

La première étape pour relier un système GNU/Linux à AD consiste à connecter votre Cluster AD, pour s'assurer que la configuration réseau est correcte des deux côtés.

### Préparations

- Assurez-vous que les ports suivants sont ouverts sur votre hôte GNU/Linux dans le contrôleur de domaine :

  | Service  | Port(s)           | Notes                                                                                                     |
  | -------- | ----------------- | --------------------------------------------------------------------------------------------------------- |
  | DNS      | 53 (TCP+UDP)      |                                                                                                           |
  | Kerberos | 88, 464 (TCP+UDP) | Utilisé par `kadmin` pour définir et mettre à jour des mots de passe                                      |
  | LDAP     | 389 (TCP+UDP)     |                                                                                                           |
  | LDAP-GC  | 3268 (TCP)        | Catalogue global LDAP - vous permet de trouver des identifiants d'utilisateur à partir d'Active Directory |

- Assurez-vous d'avoir configuré votre contrôleur de domaine AD en tant que serveur DNS sur votre hôte Rocky Linux :

  **En utilisant NetworkManager :**

  ```sh
  # where your primary NetworkManager connection is 'System eth0' and your AD
  # server is accessible on the IP address 10.0.0.2.
  [root@host ~]$ nmcli con mod 'System eth0' ipv4.dns 10.0.0.2
  ```

- Assurez-vous que les horloges sont synchronisées des deux côtés (hôte AD et système GNU/Linux)

  **Pour vérifier la date et l'heure sur Rocky Linux :**

  ```sh
  [user@host ~]$ date
  Wed 22 Sep 17:11:35 BST 2021
  ```

- Installez les paquets nécessaires pour la connexion à AD côté GNU/Linux :

  ```sh
  [user@host ~]$ sudo dnf install realmd oddjob oddjob-mkhomedir sssd adcli krb5-workstation
  ```


### Connexion automatique

Maintenant, vous devriez être en mesure de vous connecter avec succès à votre ou vos serveurs AD à partir de votre hôte GNU/Linux.

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

### Rejoindre

Une fois que vous avez effectué avec succès une découverte de votre installation Active Directory à partir de l'hôte Linux, vous devriez pouvoir utiliser `realmd` pour rejoindre le domaine, ce qui orchestrera la configuration de `sssd` en utilisant `adcli` et d'autres outils.

```sh
[user@host ~]$ sudo realm join ad.company.local
```

Si ce processus affiche un problème de chiffrement comme `KDC has no support for encryption type`, essayez de mettre à jour la stratégie de chiffrement globale pour autoriser les algorithmes de chiffrement plus anciens :

```sh
[user@host ~]$ sudo update-crypto-policies --set DEFAULT:AD-SUPPORT
```

Si ce processus réussit, vous devriez maintenant pouvoir extraire les informations `passwd` d'un utilisateur d'Active Directory.

```sh
[user@host ~]$ sudo getent passwd administrator@ad.company.local
administrator@ad.company.local:*:1450400500:1450400513:Administrator:/home/administrator@ad.company.local:/bin/bash
```

!!! note "Remarque" 

    La commande `getent` récupère les données des bibliothèques Name Service Switch (NSS). Cela signifie que, contrairement à `passwd` ou `dig` par exemple, il va interroger différentes bases de données, y compris `/etc/hosts` pour `getent hosts` ou depuis `sssd` dans le cas de `getent passwd`.

`realm` fournit des options intéressantes que vous pouvez utiliser :

| Option                                                     | Observations                                                           |
| ---------------------------------------------------------- | ---------------------------------------------------------------------- |
| --computer-ou='OU=LINUX,OU=SERVERS,dc=ad,dc=company.local' | Le OU où stocker le compte du serveur                                  |
| --os-name='rocky'                                          | Spécifie le nom du système d'exploitation stocké dans Active Directory |
| --os-version='8'                                           | Indique la version de l'OS stockée dans Active Directory               |
| -U admin_username                                          | Indique un compte administrateur                                       |

### Tentative d'Authentification

Now your users should be able to authenticate to your Linux host against Active Directory.

**Sous Windows 10 :** (qui possède sa propre copie de OpenSSH)

```
C:\Users\John.Doe> ssh -l john.doe@ad.company.local linux.host
Password for john.doe@ad.company.local:

Activate the web console with: systemctl enable --now cockpit.socket

Last login: Wed Sep 15 17:37:03 2021 from 10.0.10.241
[john.doe@ad.company.local@host ~]$
```

If this succeeds, you have successfully configured Linux to use Active Directory as an authentication source.

### Définir le domaine par défaut

In a completely default setup, you will need to log in with your AD account by specifying the domain in your username (e.g., `john.doe@ad.company.local`). If this is not the desired behavior, and you instead want to be able to omit the domain name at authentication time, you can configure SSSD to default to a specific domain.

This is a relatively straightforward process, requiring a configuration tweak in your SSSD configuration file.

```sh
[user@host ~]$ sudo vi /etc/sssd/sssd.conf
[sssd]
...
default_domain_suffix = ad.company.local
```

En ajoutant le paramètre `default_domain_suffix`, vous indiquez à SSSD (si aucun autre domaine n'est spécifié) que l'utilisateur tente de s'authentifier en tant que membre du domaine `ad.company.local`. Cela vous permet de vous authentifier en tant que `john.doe` au lieu de `john.doe@ad.company.local`.

Pour que cette modification de configuration prenne effet, vous devez redémarrer `sssd.service` avec `systemctl`.

```sh
[user@host ~]$ sudo systemctl restart sssd
```

De la même manière, si vous ne voulez pas que vos répertoires personnels soient suffixés par le nom de domaine, vous pouvez ajouter ces options dans votre fichier de configuration `/etc/sssd/sssd. onf`:

```
[domain/ad.company.local]
use_fully_qualified_names = False
override_homedir = /home/%u
```

N'oubliez pas de redémarrer le service `sssd`.

### Restreindre à certains utilisateurs

Il existe différentes méthodes pour restreindre l'accès au serveur à une liste limitée d'utilisateurs, mais cela, comme le nom le suggère, est certainement le plus simple :

Ajoutez ces options dans votre fichier de configuration `/etc/sssd/sssd.conf` et redémarrez le service :

```
access_provider = simple
simple_allow_groups = groupe1, groupe2
simple_allow_users = user1, user2
```

Maintenant, seuls les utilisateurs du groupe1 et du groupe2, ou user1 et user2 pourront se connecter au serveur en utilisant sssd !

## Interagir avec la AD en utilisant `adcli`

`adcli` est un CLI pour effectuer des actions sur un domaine Active Directory.

- S'il n'est pas encore installé, installez le paquet requis :

```sh
[user@host ~]$ sudo dnf install adcli
```

- Tester si vous avez déjà rejoint un domaine Active Directory :

```sh
[user@host ~]$ sudo adcli testjoin
Validé avec succès pour rejoindre le domaine ad.company.local
```

- Obtenir des informations plus détaillées sur le domaine :

```sh
[user@host ~]$ adcli info ad.company.local
[domain]
domain-name = ad.company.local
domain-short = AD
domain-forest = ad.company.local
domain-controller = dc1.ad.company.local
domain-controller-site = site1
domain-controller-flags = gc ldap ds kdc timeserv closest writable full-secret ads-web
domain-controller-usable = yes
domain-controllers = dc1.ad.company.local dc2.ad.company.local
[computer]
computer-site = site1
```

- Plus qu'un outil de consultation, vous pouvez utiliser adcli pour interagir avec votre domaine : gérer les utilisateurs ou les groupes, modifier le mot de passe, etc.

Exemple : utiliser `adcli` pour obtenir des informations sur un ordinateur :

!!! note "Remarque"

    Cette fois, nous fournirons un nom d'utilisateur admin grâce à l'option `-U`

```sh
[user@host ~]$ adcli show-computer pctest -U admin_username
Password for admin_username@AD: 
sAMAccountName:
 pctest$
userPrincipalName:
 - not set -
msDS-KeyVersionNumber:
 9
msDS-supportedEncryptionTypes:
 24
dNSHostName:
 pctest.ad.company.local
servicePrincipalName:
 RestrictedKrbHost/pctest.ad.company.local
 RestrictedKrbHost/pctest
 host/pctest.ad.company.local
 host/pctest
operatingSystem:
 Rocky
operatingSystemVersion:
 8
operatingSystemServicePack:
 - not set -
pwdLastSet:
 133189248188488832
userAccountControl:
 69632
description:
 - not set -
```

Exemple: utilisez `adcli` pour changer le mot de passe de l'utilisateur :

```sh
[user@host ~]$ adcli passwd-user user_test -U admin_username
Password for admin_username@AD: 
Password for user_test: 
[user@host ~]$ 
```

## Dépannage

Parfois, le service réseau démarre après SSSD, ce qui pose problème avec l'authentification.

Aucun utilisateur AD ne sera en mesure de se connecter jusqu'à ce que vous redémarriez le service.

Dans ce cas, vous devrez remplacer le fichier de service du système pour gérer ce problème.

Copiez ce contenu dans `/etc/systemd/system/sssd.service` :

```
[Unit]
Description=System Security Services Daemon
# SSSD must be running before we permit user sessions
Before=systemd-user-sessions.service nss-user-lookup.target
Wants=nss-user-lookup.target
After=network-online.target


[Service]
Environment=DEBUG_LOGGER=--logger=files
EnvironmentFile=-/etc/sysconfig/sssd
ExecStart=/usr/sbin/sssd -i ${DEBUG_LOGGER}
Type=notify
NotifyAccess=main
PIDFile=/var/run/sssd.pid

[Install]
WantedBy=multi-user.target
```

Lors du prochain redémarrage, le service sera relancé suivant ses nouvelles exigences et tout ira bien.

## Quitter l'Active Directory

Parfois, il est nécessaire de quitter la AD.

Vous pouvez à nouveau procéder avec `realm` et ensuite supprimer les paquets qui ne sont plus nécessaires :

```sh
[user@host ~]$ sudo realm leave ad.company.local
[user@host ~]$ sudo dnf remove realmd oddjob oddjob-mkhomedir sssd adcli krb5-workstation
```
