---
title: Installation de KDE
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 9.0
tags:
  - desktop
  - kde
---

# Introduction

Grâce à l'équipe de développement de Rocky Linux, il y a maintenant des images live pour plusieurs installations de bureau, dont KDE. Pour ceux qui ne savent peut-être pas ce qu'est une image live, elle permet de démarrer le système d'exploitation et l'environnement de bureau en utilisant le support d'installation et vous donnera un aperçu avant de l'installer.

!!! note

    Cette procédure est spécifique à Rocky Linux 9.0. Il n'y a actuellement aucune procédure décrite pour installer KDE pour les autres versions de Rocky Linux. 
    N'hésitez pas à écrire une description !

## Prérequis

* Une machine, compatible avec Rocky Linux 9.0, (bureau, ordinateur portable ou serveur) sur laquelle vous voulez utiliser le bureau KDE.
* Maîtriser la ligne de commande de manière à pouvoir réaliser certaines tâches, par exemple tester les sommes de contrôle de l'image.
* La connaissance de la façon d'écrire une image amorçable sur DVD ou une clé USB.

## Obtenir, vérifier et créer une image Live de KDE

Avant l'installation, la première étape consiste à télécharger l'image live et à l'enregistrer sur un DVD ou une clé USB. Comme indiqué précédemment, l'image autonome sera amorçable, tout comme tout autre support d'installation pour Linux. Vous pouvez trouver la dernière image KDE dans la section de téléchargement pour Rocky Linux 9 [images live](https://dl.rockylinux.org/pub/rocky/9.3/live/x86_64/).

Notez que ce lien particulier suppose que x86_64 est l'architecture de votre processeur. Si vous avez une architecture aarch64, vous pouvez utiliser l'image correspondante à la place. Téléchargez à la fois l'image live et les fichiers de somme de contrôle.

Maintenant vérifiez l'image avec le fichier CHECKSUM en utilisant la commande suivante (note : c'est un exemple ! Assurez-vous que le nom de votre image et les fichiers CHECKSUM correspondent) :

```
sha256sum -c CHECKSUM --ignore-missing Rocky-9-KDE-x86_64-latest.iso.CHECKSUM
```

Si tout se passe bien, vous devriez obtenir ce message :

```
Rocky-9-KDE-x86_64-latest.iso: OK
```

Si la somme de contrôle du fichier retourne OK, vous êtes maintenant prêt à enregistrer votre image ISO sur votre support de stockage. Nous supposons ici que vous savez enregistrer l'image sur votre support de stockage. Cette procédure est différente suivant l'OS que vous utilisez, les supports de stockage et les outils logiciels.

## Démarrage

Là encore, cela diffère selon la machine, le BIOS, le système d'exploitation, etc. Vous devez vous assurer que votre machine est configurée pour démarrer avec n'importe quel support (DVD ou USB) comme premier périphérique de démarrage. Vous verrez cet écran si vous réussissez :

![kde_boot](images/kde_boot.png)

Si c'est le cas, vous êtes sur la bonne voie ! Si vous voulez tester le média, vous pouvez d'abord sélectionner cette option ou bien vous pouvez simplement taper **S** pour **Start Rocky Linux KDE 9.x**.

N'oubliez pas qu'il s'agit d'une image live. Le lancement jusqu'au premier écran prend un certain temps. Pas de panique, il suffit d'attendre ! Lorsque l'image live est lancée, vous verrez cet écran :

![kde_live](images/kde_live.png)

## Installation de KDE

À ce stade, vous pouvez utiliser l'environnement KDE et voir si il vous convient. Une fois que vous avez décidé de l'utiliser de manière permanente, double-cliquez sur l'option **Install to Hard Drive**.

Cela lancera un processus d'installation assez familier pour ceux qui ont déjà installé Rocky Linux. Le premier écran vous donnera la possibilité de changer la langue qui correspond à votre région :

![kde_language](images/kde_language.png)

Une fois que vous avez sélectionné votre langue et cliqué sur **Continue**, l'installation passera à l'écran suivant. Nous avons mis en évidence les choses que vous *pouvez* vouloir modifier et vérifier :

![kde_install](images/kde_install.png)

1. **Keyboard** - Jetez un coup d'œil à cette option et assurez-vous qu'elle correspond bien à la disposition du clavier que vous utilisez.
2. **Heure & Date** - Assurez-vous que l'affichage correspond à votre fuseau horaire.
3. **Installation Destination** - Vous devrez cliquer sur cette option, même si c'est juste pour accepter ce qui est déjà indiqué.
4. **Network & Hostname** - Vérifiez que vous avez ce dont vous avez besoin ici. À condition que le réseau soit activé, vous pouvez toujours modifier plus tard si vous le souhaitez.
5. **Root Password** Allez-y et définissez un mot de passe root. Pensez à le sauvegarder dans un endroit sûr (gestionnaire de mots de passe), surtout si vous ne l'utilisez pas souvent.
6. **User Creation** Créer au moins un utilisateur. Si vous voulez qu'il dispose de droits d'administration, n'oubliez pas de définir cette option lors de la création de l'utilisateur.
7. **Begin Installation** - une fois que vous avez choisi et vérifié tous les paramètres, cliquez sur cette option.

Une fois que vous avez lancé l'étape 7, le processus d'installation devrait commencer à installer des paquets, comme dans la capture d'écran ci-dessous :

![kde_install_2](images/kde_install_2.png)

Une fois l'installation sur le disque dur terminée, vous devriez voir l'écran suivant :

![kde_install_final](images/kde_install_final.png)

Allez-y et cliquez sur **Finish Installation**.

À ce stade, vous devrez redémarrer le système et retirer votre support d'amorçage. Quand l'OS est relancé pour la première fois, l'écran de configuration suivant apparaît :

![kde_config](images/kde_config.png)

Cliquez sur l’option **Licencing Information** et acceptez l'EULA comme indiqué ici :

![eula](images/eula.png)

Et finissez la configuration :

![kde_finish_config](images/kde_finish_config.png)

Une fois cette étape terminée, le nom d'utilisateur que vous avez créé précédemment s'affiche. Entrez le mot de passe que vous avez créé pour l'utilisateur et appuyez sur <kbd>ENTER</kbd>. Cela devrait vous montrer un écran de bureau KDE :

![kde_screen](images/kde_screen.png)

## Conclusion

Grâce à l'équipe de développement de Rocky Linux, il y a plusieurs environnements de bureau que vous pouvez installer à partir d'images en direct pour Rocky Linux 9.0. Pour ceux qui n'aiment pas trop le bureau GNOME par défaut, KDE est une autre option et peut facilement être installé avec l'image live. 
