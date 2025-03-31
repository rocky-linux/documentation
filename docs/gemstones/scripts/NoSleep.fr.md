---
title: NoSleep.sh - Un simple Script de Configuration
author: Andrew Thiesen
tags:
  - configuration
  - serveur
  - poste de travail
---

# NoSleep.sh

## Édition du Script Bash `/etc/systemd/logind.conf`

Ce script bash est prévu pour modifier le fichier de configuration `/etc/systemd/logind.conf` sur un serveur Rocky Linux ou un poste de travail. Plus précisément, il modifie l'option `HandleLidSwitch` et la définit sur `ignore`. Cette modification de configuration est généralement utilisée pour empêcher le système de se suspendre ou d'effectuer une action lorsque le couvercle de l'ordinateur portable est fermé.

### Utilisation

Pour utiliser le script, procédez comme suit :

1. Ouvrez un terminal sur votre système Linux.
2. Avec `cd`, accédez à votre répertoire préféré.
3. Téléchargez le script NoSleep.sh via `curl` : <br /> `curl -O https://github.com/andrewthiesen/NoSleep.sh/blob/main/NoSleep.sh`
4. Rendez le script NoSleep exécutable en exécutant la commande `chmod +x NoSleep.sh`.
5. Exécutez le script en tant que root à l'aide de la commande `sudo ./NoSleep.sh`.
6. Le script mettra à jour l'option `HandleLidSwitch` dans le fichier `logind.conf` sur `ignore`.
7. En option, vous serez invité à redémarrer le système pour que les modifications prennent effet immédiatement.

### Notes Importantes

* Ce script **doit** être exécuté en tant que `root` ou avec des privilèges de superutilisateur pour modifier les fichiers système.
* Il suppose que le fichier `logind.conf` se trouve dans `/etc/systemd/logind.conf`. Si votre système utilise un emplacement différent, veuillez modifier le script en conséquence.
* La modification des fichiers de configuration du système peut avoir des conséquences inattendues. Veuillez examiner les modifications apportées par le script et vous assurer qu’elles correspondent à vos besoins.
* Il est recommandé de prendre les précautions appropriées, comme la sauvegarde du fichier de configuration d'origine, avant d'exécuter le script.
* Le redémarrage du système est facultatif mais peut garantir que les modifications prennent effet immédiatement. Vous serez invité à redémarrer après avoir exécuté le script.

---

N'hésitez pas à personnaliser et à utiliser le script selon vos besoins. Assurez-vous de bien comprendre le script et ses implications avant de l'exécuter sur votre système.
