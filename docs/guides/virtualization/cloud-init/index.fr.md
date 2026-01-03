---
title: 0. cloud-init
author: Wale Soyinka
contributors: Steven Spencer, Ganna Zhyrnova
tags:
  - cloud-init
---

## Guide d'utilisation de `cloud-init` sur Rocky Linux

Bienvenue dans le guide complet de `cloud-init` sur Rocky Linux. Cette série vous amène des concepts fondamentaux de l'initialisation d'instances cloud aux techniques avancées de provisionnement et de dépannage appliquées au monde réel. Que vous soyez un nouvel utilisateur configurant votre premier serveur infonuagique ou un administrateur expérimenté créant des images personnalisées, ce guide contient des informations utiles.

Pour tirer le meilleur parti de ces chapitres, il est conseillé de les lire dans l'ordre, en s'appuyant sur les connaissances acquises dans les sections précédentes.

---

## Les chapitres de ce guide

**[1. Principes fondamentaux](./01_fundamentals.md)**

> Découvrez ce qu'est `cloud-init`, pourquoi il est essentiel pour l'infonuagique et les étapes de son cycle de vie d'exécution.

**[2. Premier contact👽](./02_first_contact.md)**

> Votre premier exercice pratique. Démarrez une image cloud et effectuez une personnalisation simple en utilisant un fichier `user-data` de base.

**[3. Le moteur de configuration](./03_configuration_engine.md)**

> Explorez en profondeur le système de modules `cloud-init`. Apprenez comment utiliser les modules les plus importants pour la gestion des utilisateurs, des paquets et des fichiers.

**[4. Provisionnement avancé](./04_advanced_provisioning.md)**

> Gérez des scénarios complexes, notamment la définition de configurations réseau statiques et la combinaison de scripts et de configurations infonuagiques en une seule charge utile.

**[5. Le point de vue du créateur d'images](./05_image_builders_perspective.md)**

> Adoptez le point de vue d'un créateur d'images. Apprenez à créer des « images de référence, golden images » avec des paramètres par défaut intégrés et à les généraliser pour un clonage correct.

**[6. Dépannage](./06_troubleshooting.md)**

> Apprenez l'art de l'analyse de `cloud-init`. Comprendre les journaux, les contrôles d'état et les pièges courants pour diagnostiquer et résoudre efficacement les problèmes.

**[7. Contribution à cloud-init](./07_contributing.md)**

> Allez au-delà du simple rôle d'utilisateur. Ce chapitre fournit une feuille de route pour comprendre le code source de `cloud-init` et apporter votre première contribution au projet open source.
