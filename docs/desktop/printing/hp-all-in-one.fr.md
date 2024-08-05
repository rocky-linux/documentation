---
title: Imprimante HP All-in-One – Installation et Setup
author: Joseph Brinkman
contributors: Steven Spencer, Ganna Zhyrnova
tested with: 9.4
tags:
  - bureau
  - printer support
---

## Introduction

L'impression et la numérisation avec une imprimante HP All-in-One sont possibles sous Linux grâce à [HPLIP](https://developers.hp.com/hp-linux-imaging-and-printing/about){target="_blank"}.

Ce guide a été testé avec un HP Deskjet série 2700.

Consultez [la liste des imprimantes prises en charge](https://developers.hp.com/hp-linux-imaging-and-printing/supported_devices/index){target="_blank"} pour voir si le package HPLIP prend en charge votre imprimante.

## Télécharger et Installer HPLIP

HPLIP est un logiciel tiers de HP qui contient les pilotes requis pour utiliser les imprimantes de la liste. Installez les 3 packages ci-dessous pour une prise en charge complète avec une interface utilisateur graphique.

```bash
sudo dnf install hplip-common.x86_64 hplip-libs.x86_64 hplip-gui
```

## Paramétrage de l'Imprimante

Une fois l'installation du pilote d'imprimante terminée, vous devriez pouvoir ajouter votre imprimante HP All-in-One à votre station de travail Rocky. Assurez-vous que l'imprimante est physiquement connectée au même réseau, soit via Wi-Fi, soit par une connexion directe. Accédez aux paramètres Settings

1. Dans le menu de gauche cliquez sur ++"Printers"++

2. Cliquez sur ++"Add a Printer"++

3. Sélectionnez votre imprimante HP All-in-One.

## Prise en Charge du Scanner

Bien que vous puissiez numériser à l'aide des commandes `CLI` avec le package `HPLIP`, elles ne fournissent pas d'application de scanner. Installez `xsane`, un utilitaire de scanner facile à utiliser.

```bash
sudo dnf install sane-backends sane-frontends xsane
```

Bien que vous puissiez numériser à l'aide des commandes `CLI` avec le package HPLIP, elles ne fournissent pas d'application de scanner. Lorsque vous lancez `xsane`, une fenêtre apparaît avec un bouton ++"Acquire a preview"++ sur lequel vous pouvez cliquer. Cela prendra une image d’aperçu d’un scan. Une fois prêt pour scanner, cliquez sur le bouton ++"Start"++ dans le menu principal.

Pour un guide plus complet sur `xsane`, lisez cet [article de la Faculté de Mathématiques de l'Université de Cambridge](https://www.maths.cam.ac.uk/computing/printing/xsane){target="_blank"}

## Conclusion

Après avoir installé `HPLIP` et `xsane`, vous devriez désormais pouvoir imprimer et scanner avec votre imprimante HP All-in-One.
