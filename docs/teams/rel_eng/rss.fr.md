---
title: Rocky Linux RSS feeds
author: Release Engineering
contributors: Steven Spencer
---

Cette page traite des flux RSS (Really Simple Syndication) fournis par le projet Rocky Linux.

## Au sujet des flux RSS

Rocky Linux offre des flux RSS comme moyen alternatif pour les utilisateurs de suivre les mises à jour des nombreux dépôts pour les versions prises en charge de Rocky Linux.

Les flux RSS apparaîtront dans le miroir public : [RSS feeds](https://dl.rockylinux.org/pub/feeds)

Release Engineering (SIG/Core) génère ces flux [Toolkit](https://git.resf.org/sig_core/toolkit/src/branch/devel/mangle/generators/rss.py).

## Remarques sur les temps d'actualisation

Les flux sont mis à jour toutes les 30 minutes. Si de nouveaux paquets sont ajoutés à l'un des dépôts, ils apparaîtront immédiatement lors de la prochaine actualisation.

## Notes sur les paquets

Les flux afficheront les paquets les plus récents, jusqu'à 30 jours. Si un paquet a plus de 30 jours, il sera retiré du flux.

## Notes sur les modules

Certains modules pourraient ne pas apparaître dans le flux. C'est particulièrement vrai pour Rocky Linux 8. Le script de flux RSS n'est actuellement pas en mesure de prendre en compte tous les modules. Les flux de module par défaut constituent des exceptions notables.
