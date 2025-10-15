---
title: Introduction
author: Wale Soyinka
contributors: Steven Spencer, Ganna Zhyrnova
---

# Kubernetes The Hard Way (Rocky Linux)

!!! info

    Il s'agit d'un fork de l'original ["Kubernetes the hard way"](https://github.com/kelseyhightower/kubernetes-the-hard-way) écrit à l'origine par Kelsey Hightower (GitHub : kelseyhightower). Contrairement à l'original, qui se base sur des distributions de type Debian pour l'architecture ARM64, ce fork cible les distributions Enterprise Linux telles que Rocky Linux, qui fonctionne sur l'architecture x86_64.

Ce tutoriel vous guide dans la configuration de Kubernetes pas à pas. Ce n’est pas pour quelqu’un qui recherche un outil entièrement automatisé pour configurer une grappe Cluster Kubernetes. `Kubernetes The Hard Way` est conçu pour l'apprentissage, cela signifie donc prendre le long chemin pour vous assurer de comprendre chaque tâche requise pour démarrer un cluster Kubernetes.

Ne considérez pas les résultats de ce tutoriel comme prêts pour la production, et il se peut qu'il ne reçoive pas le soutien de la communauté, mais ne laissez pas tout cela vous empêcher d'apprendre !<small>
<br/><br/>
🌐 Traductions: 
<a href="https://crowdin.com/project/rockydocs/fr">crowdin.com/project/rockydocs</a>
<br/>
🌍 Traducteurs:
<a href="https://crowdin.com/project/rockydocs/activity-stream">rockydocs/activity-stream</a>
, <a href="https://crowdin.com/project/rockylinuxorg/activity-stream">rockylinux.org</a>
<br/>
🖋 Contributeurs:
<a href="https://github.com/rocky-linux/documentation?tab=readme-ov-file#mattermost">github.com/rocky-linux</a>
</small>

## Droits d'auteur

![Creative Commons License](images/cc_by_sa.png)

La licence de cette œuvre est assujettie à cette Licence : [Creative Commons Attribution-NonCommercial-=ShareAlike 4.0 International License](http://creativecommons.org/licenses/by-nc-sa/4.0/).

## Audience cible

Le public cible de ce tutoriel est toute personne souhaitant comprendre les principes fondamentaux de Kubernetes et la manière dont les composants principaux interagissent ensemble.

## Détails du cluster

`Kubernetes The Hard Way` vous guide à travers l'amorçage d'un cluster Kubernetes de base avec tous les composants du plan de contrôle exécutés sur un seul nœud et deux nœuds de travail, ce qui est suffisant pour apprendre les concepts de base.

Version des composantes :

- [kubernetes](https://github.com/kubernetes/kubernetes) v1.32.x
- [containerd](https://github.com/containerd/containerd) v2.0.x
- [cni](https://github.com/containernetworking/cni) v1.6.x
- [etcd](https://github.com/etcd-io/etcd) v3.4.x

## Ateliers

Ce tutoriel nécessite quatre (4) machines virtuelles ou physiques basées sur x86_64 connectées au même réseau. Bien que le tutoriel utilise des machines basées sur x86_64, vous pouvez appliquer les leçons apprises à d'autres plates-formes.

- [Prérequis](lab1-prerequisites.md)
- [Mise en Place de Jumpbox](lab2-jumpbox.md)
- [Provisionnement des Resources de Calcul](lab3-compute-resources.md)
- [Provisionnement de CA et Génération de Certificats TLS](lab4-certificate-authority.md)
- [Génération des Fichiers de Configuration Kubernetes pour l'Authentification](lab5-kubernetes-configuration-files.md)
- [Génération de la Configuration et de Clé de Chiffrement des Données](lab6-data-encryption-keys.md)
- [Amorçage du Cluster `etcd`](lab7-bootstrapping-etcd.md)
- [Amorçage du Plan de Contrôle Kubernetes](lab8-bootstrapping-kubernetes-controllers.md)
- [Amorçage des nœuds de travail Kubernetes](lab9-bootstrapping-kubernetes-workers.md)
- [Configuration de `kubectl` pour l'Accès à Distance](lab10-configuring-kubectl.md)
- [Provisionnement de Routes Réseau des `pod`s](lab11-pod-network-routes.md)
- [Smoke Test](lab12-smoke-test.md)
- [Cleaning Up](lab13-cleanup.md)
