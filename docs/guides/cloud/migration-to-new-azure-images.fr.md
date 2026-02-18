---
title: Migration vers les nouvelles images Azure
author: Neil Hanlon
contributors: Steven Spencer, Ganna Zhyrnova
tags:
  - cloud
  - azure
  - microsoft azure
  - obsolescence
---

!!! info "Les images des anciens comptes de publication seront périmées en avril 2024"

```
Un compte de publication Microsoft est un compte du marché Azure qui permet aux développeurs de publier leurs offres sur Microsoft AppSource ou la place de marché Azure.
Le RESF fournit des images de machines virtuelles Rocky Linux sous deux comptes de publication distincts dans Azure : un compte hérité (`erockyenterprisesoftwarefoundationinc1653071250513`) et un compte officiel plus récent appelé `resf`.
Les images publiées sous le compte de publication hérité (`erockyenterprisesoftwarefoundationinc1653071250513`) ont été marquées comme obsolètes le 23 avril 2024, avec une période de 180 jours (6 mois) avant leur utilisation.

Pour continuer à utiliser Rocky Linux sur Azure, vous devez suivre ce guide pour migrer vers le nouveau compte de publication (`resf`) ou vers les nouvelles images des galeries communautaires.
```

# Guide de migration : Transition vers les nouvelles images Rocky Linux sur Azure

Ce guide fournit des étapes détaillées pour migrer vos machines virtuelles Azure (VM) des images Rocky Linux obsolètes vers les nouvelles images sous le compte d'éditeur `resf` ou en utilisant les galeries de la communauté. En suivant ce guide, vous assurerez une transition en douceur avec un minimum de perturbations.

## Avant de commencer

- Assurez-vous d'avoir une sauvegarde récente de votre machine virtuelle. Bien que le processus de migration ne devrait pas affecter vos données, il est recommandé d'effectuer une sauvegarde avant toute modification du système.
- Assurez-vous que vous avez les autorisations nécessaires pour créer de nouvelles machines virtuelles et gérer celles existantes dans votre compte Azure.

## Étape n°1 : Localisez vos machines virtuelles existantes

Identifiez les machines virtuelles déployées avec les anciennes images Rocky Linux. Vous pouvez le faire en filtrant vos machines virtuelles avec l'ancien nom de compte de l'éditeur :

```text
erockyenterprisesoftwarefoundationinc1653071250513`
```

## Étape n°2 : préparation d'une nouvelle machine virtuelle

1. **Accédez** à la Place de Marché Azure.
2. **Recherchez** les nouvelles images Rocky Linux sous le compte éditeur `resf` ou accédez aux galeries communautaires.
   - Liens Marketplace :
     - [Rocky Linux x86_64](https://azuremarketplace.microsoft.com/en-us/marketplace/apps/resf.rockylinux-x86_64)
   - [Rocky Linux aarch64](https://azuremarketplace.microsoft.com/en-us/marketplace/apps/resf.rockylinux-aarch64)
   - Vous trouverez des instructions complètes sur la façon d'accéder aux images de la galerie communautaire dans cet [article](https://rockylinux.org/news/rocky-on-azure-community-gallery/)
3. **Sélectionnez** la version de Rocky Linux souhaitée et **créez une nouvelle machine virtuelle**. Lors de la configuration, vous pouvez choisir la même taille de machine virtuelle et les mêmes paramètres que votre machine virtuelle existante afin d'assurer la compatibilité.

## Étape n° 3 : Transfer de données

### Option A : Utilisation de disques gérés par Azure (recommandée pour plus de simplicité)

1. **Arrêtez** votre machine virtuelle existante.
2. **Détachez** le disque du système d'exploitation de la machine virtuelle existante.
3. **Attachez** le disque détaché à la nouvelle machine virtuelle en tant que disque de données.
4. **Boot** – lancement de la nouvelle VM. Si nécessaire, vous pouvez monter l'ancien disque du système d'exploitation et copier les données sur le nouveau disque.

### Option B : Utilisation d’outils de transfert de données (pour les environnements complexes ou les besoins spécifiques)

1. **Sélectionnez** un outil de transfert de données tel que `rsync` ou Azure Blob Storage pour transférer les données.
2. **Transférer** les données de l'ancienne VM vers la nouvelle. Cela peut inclure les données d'application, les configurations et les données utilisateur.

```bash
# Example rsync command
rsync -avzh /path/to/old_VM_data/ user@new_VM_IP:/path/to/new_VM_destination/
```

## Étape n°4 : Reconfigurer la nouvelle machine virtuelle

1. **Réappliquez** toutes les configurations ou adaptations personnalisées que vous aviez sur votre ancienne machine virtuelle à la nouvelle machine virtuelle, en vous assurant qu'elle corresponde à la configuration d'environnement prévue.
2. **Testez** la nouvelle machine virtuelle pour confirmer que les applications et les services fonctionnent comme prévu.

## Étape n°5 : Mise à jour les enregistrements DNS (le cas échéant)

Si vous accédez à votre machine virtuelle via un domaine spécifique, vous devez mettre à jour vos enregistrements DNS pour qu'ils pointent vers la nouvelle adresse IP de la machine virtuelle.

## Étape n°6 : Désactivation de l’ancienne machine virtuelle

Une fois que vous avez confirmé que la nouvelle machine virtuelle fonctionne correctement et que vous avez transféré toutes les données et configurations nécessaires, vous pouvez **libérer et supprimer** l'ancienne machine virtuelle.

## Étapes Finales

- Assurez-vous que tous les services sur la nouvelle machine virtuelle fonctionnent comme prévu.
- Surveillez les performances et l'état de la nouvelle machine virtuelle pour vous assurer qu'elle répond à vos besoins.

## Assistance

Une assistance est disponible si vous rencontrez des problèmes lors de votre migration ou si vous avez des questions. Visitez les [canaux de soutien de Rocky Linux](https://wiki.rockylinux.org/rocky/support/) pour obtenir de l'aide.
