---
title: Introduction
author: Wale Soyinka
contributors: Steven Spencer, Ganna Zhyrnova
---

# Kubernetes The Hard Way (Rocky Linux)

!!! info

    Il s'agit d'un fork de l'original ["Kubernetes the hard way"](https://github.com/kelseyhightower/kubernetes-the-hard-way) écrit à l'origine par Kelsey Hightower (GitHub : kelseyhightower). Contrairement à l'original, qui se base sur des distributions de type Debian pour l'architecture ARM64, ce fork cible les distributions Enterprise Linux telles que Rocky Linux, qui fonctionne sur l'architecture x86_64.

Ce tutoriel vous guide dans la configuration de Kubernetes à la dure. Ce n’est pas pour quelqu’un qui recherche un outil entièrement automatisé pour configurer une grappe Cluster Kubernetes. `Kubernetes The Hard Way` est conçu pour l'apprentissage, cela signifie donc prendre le long chemin pour vous assurer de comprendre chaque tâche requise pour démarrer un cluster Kubernetes.

Ne considérez pas les résultats de ce tutoriel comme prêts pour la production, et il se peut qu'il ne reçoive pas le soutien de la communauté, mais ne laissez pas cela vous empêcher d'apprendre !

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
- [Provisioning Compute Resources](lab3-compute-resources.md)
- [Provisioning the CA and Generating TLS Certificates](lab4-certificate-authority.md)
- [Generating Kubernetes Configuration Files for Authentication](lab5-kubernetes-configuration-files.md)
- [Generating the Data Encryption Config and Key](lab6-data-encryption-keys.md)
- [Bootstrapping the etcd Cluster](lab7-bootstrapping-etcd.md)
- [Bootstrapping the Kubernetes Control Plane](lab8-bootstrapping-kubernetes-controllers.md)
- [Bootstrapping the Kubernetes Worker Nodes](lab9-bootstrapping-kubernetes-workers.md)
- [Configuring kubectl for Remote Access](lab10-configuring-kubectl.md)
- [Provisioning Pod Network Routes](lab11-pod-network-routes.md)
- [Smoke Test](lab12-smoke-test.md)
- [Cleaning Up](lab13-cleanup.md)
