---
title: HPE ProLiant Agentless Management Service
author: Neel Chauhan
contributors: Ganna Zhyrnova
tested_with: 9.3
tags:
  - matériel
---

# HPE ProLiant Agentless Management Service

## Introduction

Les serveurs HPE ProLiant disposent d'un logiciel complémentaire appelé Agentless Management Service qui [selon HPE](https://techlibrary.hpe.com/docs/iss/EL8000t/setup_install/GUID-1CF69B20-790A-4EDC-A162-9D64572ED9E8.html) "utilise la communication `out-of-band` pour une sécurité et une stabilité accrues." De plus, « avec la gestion sans agent, la surveillance de l'état et les alertes sont intégrées au système et commencent à fonctionner dès que l'alimentation auxiliaire est connectée à [votre serveur] ».

Ceci est utilisé, par exemple, pour réduire la vitesse des ventilateurs sur un HPE ProLiant ML110 Gen11 dans le laboratoire personnel de l'auteur.

## Prérequis

Les conditions suivantes sont indispensables pour utiliser cette procédure :

- Un serveur HP/HPE ProLiant Gen8 ou plus récent avec iLO activé et visible sur le réseau

## Installation de `amsd`

Pour installer `amsd`, vous devez d'abord installer l'EPEL (Extra Packages for Enterprise Linux) et exécuter les mises à jour :

```bash
dnf -y install epel-release && dnf -y update
```

Ajoutez ensuite ce qui suit au fichier `/etc/yum.repos.d/spp.repo` :

```bash

[spp]
name=Service Pack for ProLiant
baseurl=https://downloads.linux.hpe.com/repo/spp-gen11/redhat/9/x86_64/current
enabled=1
gpgcheck=1
gpgkey=https://downloads.linux.hpe.com/repo/spp/GPG-KEY-spp 
```

Remplacez le `9` par la version majeure de Rocky Linux et `gen11` par la génération de votre serveur. Alors que l'auteur utilise un ML110 Gen11 s'il utilisait un DL360 Gen10 à la place, `gen10` serait utilisé.

Ensuite, installez et activez `amsd` :

```bash
dnf -y update && dnf -y install amsd
systemctl enable --now amsd
```

Si vous souhaitez vérifier si `amsd` fonctionne, connectez-vous à iLO via votre navigateur Web. S'il est installé correctement, iLO devrait indiquer que notre serveur exécute Rocky Linux :

![HPE iLO showing Rocky Linux 9.3](../images/hpe_ilo_amsd.png)

## Conclusion

Une critique courante des serveurs HPE concerne les vitesses élevées des ventilateurs lors de l'utilisation de composants tiers tels que des SSD ou d'autres cartes PCI Express complémentaires non officiellement approuvées par HPE (par exemple, des cartes de capture vidéo). Même si vous n'utilisez que des composants de marque HPE, l'utilisation de `amsd` permet aux serveurs HPE ProLiant de fonctionner de manière plus froide et plus silencieuse que la simple utilisation de Rocky Linux seul.
