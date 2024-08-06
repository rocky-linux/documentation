---
title: Brother All-in-One – Installation et Configuration de l'Imprimante
author: Joseph Brinkman
contributors: Steven Spencer, Ganna Zhyrnova
tested with: 9.4
tags:
  - desktop
  - printer support
---

## Introduction

L'impression et la numérisation avec une imprimante Brother All-in-One sont possibles sous Linux grâce aux pilotes 3rd-party d'imprimante et de scanner Brother.

!!! info "Info"

```
La marche à suivre a été testée avec une imprimante Brother MFC-J480DW.
```

## Prérequis

- Rocky 9.4 Workstation
- Droits d'accès `sudo`
- Imprimante et Scanner Brother All-in-One

Ce guide suppose que votre imprimante est accessible depuis votre poste de travail soit avec une connexion USB directe, soit via LAN (Local Area Network). La connexion d'une imprimante à votre réseau local sort du cadre de cet article.

## Ajouter une Imprimante sous GNOME

1. Ouvrez la fenêtre ++"Settings"++
2. Dans le menu de gauche cliquez sur ++"Printers"++
3. Notez la bannière en haut de la fenêtre indiquant "Unlock to Change Settings"
4. Cliquez sur ++"Unlock"++ et saisissez les informations d'identification `sudo`.
5. Cliquez sur ++"Add"++

Après avoir cliqué sur ++"Add"++, ++"Settings"++ lancera le scan des imprimantes. Si votre imprimante n'apparaît pas mais que vous connaissez son adresse IP sur votre réseau local, saisissez l'adresse IP manuellement. La connexion d'une imprimante à votre réseau local sort du cadre de cet article.

Une fenêtre Logiciel s'ouvre pour tenter de localiser et d'installer les pilotes d'imprimante. En règle générale, cela échouera. Vous devrez vous rendre sur le site Web de Brother pour récupérer les pilotes supplémentaires.

## Téléchargement et Installation de Pilotes

[Brother Driver Installer Script Installation Instructions:](https://support.brother.com/g/b/downloadlist.aspx?\&c=us\&lang=en\&prod=mfcj480dw_us_eu_as\&os=127){target="_blank"}

1. [Download the Brother MFC-J480DW Printer driver bash script](https://support.brother.com/g/b/downloadtop.aspx?c=us\&lang=en\&prod=mfcj480dw_us_eu_as){target="_blank"}

2. Ouvrez une fenêtre de terminal.

3. Accédez au répertoire dans lequel vous avez téléchargé le fichier au cours de l'étape précédente. Par exemple, `cd Downloads`

4. Entrez cette commande pour extraire le fichier téléchargé :

   ```bash
   gunzip linux-brprinter-installer-*.*.*-*.gz
   ```

5. Obtenez les privilèges administratifs avec la commande `su` ou la commande `sudo su`.

6. Exécuter la commande suivante :

   ```bash
   bash linux-brprinter-installer-*.*.*-* Brother machine name
   ```

7. L'installation du pilote va démarrer. Suivez les instructions de l'écran d'installation.

Le processus d'installation peut prendre un certain temps. Attendez qu'il soit terminé. Une fois terminé, vous pouvez éventuellement envoyer un test d'impression.

## Prise en Charge du Scanner

`Xsane` est un utilitaire de numérisation qui fournit une interface utilisateur graphique pour effectuer des scans. Des packages dédiés sont disponibles dans le référentiel `appstream` ne nécessitant aucune configuration supplémentaire.

```bash
sudo dnf install sane-backends sane-frontends xsane
```

L'interface graphique de `xsane` semble un peu intimidante, mais effectuer un simple scan est plutôt facile. Lorsque vous lancez `xsane`, une fenêtre apparaît avec un bouton ++"Acquire a preview"++ sur lequel vous pouvez cliquer. Cela prendra une image d’aperçu d’un scan. Une fois prêt pour scanner, cliquez sur le bouton ++"Start"++ dans le menu principal.

Pour un guide plus complet sur `xsane`, lisez cet [article de la Faculté de Mathématiques de l'Université de Cambridge](https://www.maths.cam.ac.uk/computing/printing/xsane){target="_blank"}

## Conclusion

Après avoir installé les pilotes nécessaires et `xsane`, vous devriez désormais pouvoir imprimer et scanner avec votre imprimante Brother All-in-One.
