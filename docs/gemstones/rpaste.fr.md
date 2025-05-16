---
title: rpaste – Outil `Pastebin`
author: Steven Spencer
contributors:
tags:
  - rpaste
  - Mattermost
  - pastebin
---

# Introduction à `paste`

`rpaste` est un outil permettant de partager du code, des sorties de journaux et d'autres textes extra-longs. C'est un `pastebin` créé par les développeurs de Rocky Linux. Cet outil est utile lorsque vous devez partager quelque chose publiquement, mais que vous ne souhaitez pas dominer le flux avec votre texte. Ceci est particulièrement important lors de l’utilisation de Mattermost, qui dispose de ponts vers d’autres services IRC. L'outil `rpaste` peut être installé sur n'importe quel système Rocky Linux. Si votre ordinateur ne tourne pas sous Rocky Linux ou si vous ne souhaitez tout simplement pas installer l'outil, vous pouvez l'utiliser manuellement, en accédant à l'[URL pinnwand](https://rpa.st) puis en collant la sortie système ou le texte que vous souhaitez partager. `rcoller` vous permet de créer les informations automatiquement.

## Installation

Installation de `rpaste` sur Rocky Linux :

```bash
sudo dnf --enablerepo=extras install rpaste
```

## Utilisations

Pour les problèmes majeurs du système, il se peut que vous deviez envoyer toutes les informations de votre système afin que tout puisse être vérifié en cas de problème. Pour ce faire, exécutez :

```bash
rpaste --sysinfo
```

Qui retournera le lien vers la page `pinnwand` :

```bash
Envoi des données en cours...
Paste URL:   https://rpa.st/2GIQ
Raw URL:     https://rpa.st/raw/2GIQ
Removal URL: https://rpa.st/remove/YBWRFULDFCGTTJ4ASNLQ6UAQTA
```

Vous pouvez ensuite vérifier vous-même les informations dans un navigateur et décider si vous voulez les conserver ou les supprimer et recommencer. Si vous voulez conserver le résultat, vous pouvez copier l'URL du champ `Paste URL` et la partager avec votre équipe, ou dans le canal sur Mattermost. Pour supprimer, copiez simplement l'URL de `Removal URL` et ouvrez la dans votre navigateur.

Vous pouvez ajouter du contenu à votre pastebin en passant ce contenu. Par exemple, si vous vouliez ajouter du contenu à partir de votre fichier `/var/log/messages` à partir du 10 mars, vous pouvez le faire ainsi :

```bash
sudo more /var/log/messages | grep 'Mar 10' | rpaste
```

## `rpaste` – Aide

Pour obtenir de l'aide pour la commande, tapez simplement :

```bash
rpaste --help
```

Le résultat suivant est alors affiché :

```bash
rpaste: A paste utility originally made for the Rocky paste service

Usage: rpaste [options] [filepath]
       command | rpaste [options]

This command can take a file or standard in as input

Options:
--life value, -x value      Sets the life time of a paste (1hour, 1day, 1week) (default: 1hour)
--type value, -t value      Sets the syntax highlighting (default: text)
--sysinfo, -s               Collects general system information (disables stdin and file input) (default: false)
--dry, -d                   Turns on dry mode, which doesn't paste the output, but shows the data to stdin (default: false)
--pastebin value, -p value  Sets the paste bin service to send to. Prise en charge actuelle : rpaste, fpaste (par défaut : "rpaste")
--help, -h affiche l'aide (par défaut : false)
--version, -v affiche la version (par défaut : false)
```

## Conclusion

Il est parfois important de partager une grande quantité de texte lorsque vous travaillez sur un problème particulier, en partageant du code ou du texte, etc. Utiliser `rpaste` pour cela évitera d'avoir à lire de grandes quantités de contenu texte qui ne sont pas importantes. L'étiquette de communication par clavardage est également importante dans Rocky Linux.
