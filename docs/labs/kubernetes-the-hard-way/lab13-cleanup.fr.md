---
author: Wale Soyinka
contributors: Steven Spencer, Ganna Zhyrnova
tags:
  - kubernetes
  - k8s
  - exercice d'atelier
---

# Atelier n°13 : Nettoyage

!!! info

    Il s'agit d'un fork de l'original ["Kubernetes the hard way"](https://github.com/kelseyhightower/kubernetes-the-hard-way) écrit à l'origine par Kelsey Hightower (GitHub : kelseyhightower). Contrairement à l'original, qui se base sur des distributions de type Debian pour l'architecture ARM64, ce fork cible les distributions Enterprise Linux telles que Rocky Linux, qui fonctionne sur l'architecture x86_64.

Vous aller supprimer les ressources de calcul créées au cours de ce tutoriel dans cet atelier.

## Instances de Calcul

Les versions précédentes de ce guide utilisaient les ressources GCP pour divers aspects de l'informatique et des réseaux. La version actuelle est agnostique ; vous effectuez toutes les configurations sur le serveur `jumpbox`, le serveur `server` ou les nœuds.

Le nettoyage est aussi simple que de supprimer toutes les machines virtuelles que vous avez créées pour cet exercice.

Next: [Start Over](lab0-README.md)
