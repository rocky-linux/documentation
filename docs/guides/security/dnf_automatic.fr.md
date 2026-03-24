---
title: Mise à jour avec dnf-automatic
author: Antoine Le Morvan
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 8.5
tags:
  - sécurité
  - dnf
  - automatisation
  - mises à jour
---

# Mise à jour des serveurs avec `dnf-automatic`

La gestion de l'installation des mises à jour de sécurité est une question importante pour l'administrateur du système. La mise à disposition de mises à jour logicielles est une voie bien tracée qui, en fin de compte, ne pose que peu de problèmes. Pour ces raisons, il est raisonnable d'automatiser le téléchargement et l'application des mises à jour quotidiennement et automatiquement sur les serveurs Rocky.

La sécurité de votre système d'information en sera renforcée. `dnf-automatique` est un outil supplémentaire qui vous permettra d'y contribuer.

!!! tip "Si vous êtes inquiet..."

    Il y a quelques années, appliquer des mises à jour automatiques de cette manière aurait été une recette pour le désastre. Il arrivait de temps en temps qu'une mise à jour puisse poser des problèmes. Cela arrive encore rarement, lorsqu'une mise à jour d'un paquet supprime une fonctionnalité désuète utilisée sur le serveur, mais de nos jours, ce n'est généralement plus un problème. Si vous n'êtes toujours pas à l'aise à l'idée de laisser `dnf-automatic` gérer les mises à jour, pensez à l'utiliser pour télécharger et/ou vous avertir de la disponibilité des mises à jour. Ainsi, votre serveur ne restera pas longtemps sans correctifs. Ces fonctionnalités sont `dnf-automatic-notifyonly` et `dnf-automatic-download`.
    
    Pour en savoir plus sur ces fonctionnalités, consultez la [documentation officielle](https://dnf.readthedocs.io/en/latest/automatic.html).

## Installation

Vous pouvez installer `dnf-automatic` depuis les dépôts Rocky :

```bash
sudo dnf install dnf-automatic
```

## Configuration

Par défaut, la mise à jour démarrera à 6 h du matin, avec un décalage horaire aléatoire supplémentaire pour éviter que toutes vos machines ne se mettent à jour simultanément. Pour modifier ce comportement, vous devez remplacer la configuration du `timer` associé au service d'application :

```bash
sudo systemctl edit dnf-automatic.timer

[Unit]
Description=dnf-automatic timer
# See comment in dnf-makecache.service
ConditionPathExists=!/run/ostree-booted
Wants=network-online.target

[Timer]
OnCalendar=*-*-* 6:00
RandomizedDelaySec=10m
Persistent=true

[Install]
WantedBy=timers.target
```

Cette configuration réduit le délai de démarrage entre 6h00 et 6h10. (Un serveur qui serait arrêté en ce moment serait automatiquement patché après son redémarrage.)

Activez ensuite le `timer` associé au service (et non le service lui-même) :

```bash
sudo systemctl enable --now dnf-automatic.timer
```

## Qu'en est-il des serveurs CentOS 7 ?

!!! tip "Astuce"

    Oui, c'est la documentation de Rocky Linux, mais si vous êtes un administrateur système ou réseau, vous avez peut-être encore des machines `CentOS 7` en service. Nous le comprenons, et c'est pourquoi nous incluons cette section.

La procédure sous CentOS 7 est similaire mais utilise : `yum-cron`.

```bash
sudo yum install yum-cron
```

Cette fois, la configuration du service est effectuée dans le fichier `/etc/yum/yum-cron.conf`.

Définir la configuration comme nécessaire :

```text
[commands]
#  What kind of update to use:
# default                            = yum upgrade
# security                           = yum --security upgrade
# security-severity:Critical         = yum --sec-severity=Critical upgrade
# minimal                            = yum --bugfix update-minimal
# minimal-security                   = yum --security update-minimal
# minimal-security-severity:Critical =  --sec-severity=Critical update-minimal
update_cmd = default

# Whether a message should be emitted when updates are available,
# were downloaded, or applied.
update_messages = yes

# Whether updates should be downloaded when they are available.
download_updates = yes

# Whether updates should be applied when they are available.  Note
# that download_updates must also be yes for the update to be applied.
apply_updates = yes

# Maximum amount of time to randomly sleep, in minutes.  The program
# will sleep for a random amount of time between 0 and random_sleep
# minutes before running.  This is useful for e.g. staggering the
# times that multiple systems will access update servers.  If
# random_sleep is 0 or negative, the program will run immediately.
# 6*60 = 360
random_sleep = 30
```

Les commentaires dans le fichier de configuration parlent d'eux-mêmes.

Vous pouvez maintenant activer le service et le lancer :

```bash
sudo systemctl enable --now yum-cron
```

## Conclusion

La mise à jour automatique des paquets est facilement activée et augmente considérablement la sécurité de votre système GNU/Linux.
