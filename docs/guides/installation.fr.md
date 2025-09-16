---
Title: Rocky Linux 10 — Installation
author: Wale Soyinka
contributors:
---

# Installation de Rocky Linux 10

Il s'agit d'un guide détaillé pour l'installation d'une version 64 bits de la distribution Rocky Linux sur un système autonome. Vous allez effectuer une installation de type serveur. Vous allez passer par les étapes d’installation et de personnalisation dans les sections suivantes.

## Prérequis à l'Installation du Système d'Exploitation

Téléchargez l'ISO à utiliser pour cette installation de Rocky Linux.  
Vous pouvez télécharger la dernière image ISO pour la version de Rocky Linux à installer ici :

<https://www.rockylinux.org/download/>

Pour télécharger l'image ISO directement depuis la ligne de commande sur un système Linux existant, utilisez la commande `wget` comme suit :

```bash
wget https://download.rockylinux.org/pub/rocky/10/isos/x86_64/Rocky-10.0-x86_64-minimal.iso
```

Les images ISO de Rocky Linux respectent la convention de nommage suivante :

```text
Rocky-<MAJOR#>.<MINOR#>-<ARCH>-<VARIANT>.iso
```

Par exemple, `Rocky-10.0-x86_64-minimal.iso`

!!! note "Remarque"

    Le site web du projet Rocky Linux propose une liste de nombreux miroirs situés partout dans le monde. Choisissez le miroir qui est géographiquement le plus proche de vous. La liste des mirroirs officiels pet être consultée [ici](https://mirrors.rockylinux.org/mirrormanager/mirrors).

## Vérification du fichier ISO d'installation

Si vous avez téléchargé un des fichiers ISO Rocky Linux, vous pouvez utiliser l'utilitaire `sha256sum` pour vérifier que le fichier téléchargé n'est pas corrompu. Nous allons montrer un exemple de la façon de valider le fichier `Rocky-10.0-x86_64-minimal.iso` en vérifiant sa somme de contrôle.

1. Téléchargez le fichier qui contient les sommes de contrôle officielles pour les fichiers ISO disponibles.

1. Alors que vous êtes toujours dans le dossier qui contient l'image ISO Rocky Linux téléchargée, téléchargez le fichier checksum pour l'ISO, tapez :

    ```bash
    wget -O CHECKSUM https://download.rockylinux.org/pub/rocky/10/isos/x86_64/CHECKSUM
    ```

1. Utilisez le programme `sha256sum` pour vérifier l'intégrité du fichier ISO contre la corruption ou la falsification.

    ```bash
    sha256sum -c CHECKSUM --ignore-missing
    ```

    Cela vérifie l'intégrité du fichier ISO téléchargé précédemment, à condition qu'il se trouve dans le même répertoire. Le résultat suivant devrait être affiché :

    ```text
    Rocky-10.0-x86_64-minimal.iso: OK
    ```

## L'installation

!!! tip "Astuce"

    Avant de démarrer l'installation à proprement parler, l'UEFI (Unified Extensible Firmware Interface) ou le BIOS (Basic Input/Output System) du système doit être configuré pour démarrer sur le bon média.
    Assurez-vous également de consulter les notes [configuration matérielle minimale requise](minimum_hardware_requirements.md) recommandées pour l'exécution de Rocky Linux 10.

Une fois le système configuré pour démarrer à partir du média avec le fichier ISO, on peut commencer l'installation.

1. Insérez et démarrez à partir du support d'installation (par exemple, un disque optique, une clé USB).

2. Une fois l'ordinateur démarré, vous voyez l'écran de démarrage du programme d'installation de Rocky Linux 10.

    ![Rocky Linux installation splash screen](images/installation_10_0_F01.png)

3. Sur l'écran d'accueil, vous pouvez utiliser les touches fléchées ++"up"++ ou ++"down"++ pour sélectionner l'une des options, puis appuyer sur ++enter++ pour exécuter l'option sélectionnée. Si vous n'appuyez sur aucune touche, le programme d'installation démarre un compte à rebours, après quoi le processus d'installation exécute automatiquement l'option par défaut en surbrillance :

    `Tester le media & installer Rocky Linux 10`

4. Une vérification rapide du media sera effectuée. <br/> Cette vérification peut vous éviter de démarrer l'installation et de découvrir à mi-chemin que le programme d'installation doit s'arrêter en raison d'un support d'installation défectueux.

1. Une fois la vérification du support terminée et le support vérifié comme utilisable, le programme d'installation passe automatiquement à l'écran suivant.

2. Sélectionnez dans cet écran la langue à utiliser pour continuer l'installation. Pour cet exemple, nous choisissons *Anglais  (US)*. Cliquez ensuite sur le bouton ++"continue"++.

## Récapitulatif de l'intallation

L'écran `Installation Summary` est une zone complète dans laquelle vous prenez des décisions clés concernant l'installation du système.

L'écran est grossièrement divisé en sections suivantes :

- *LOCALIZATION*
- *SOFTWARE*
- *SYSTEM*
- *USER SETTINGS*

Nous allons maintenant examiner chacune de ces sections et apporter les modifications nécessaires.

### Localisation

Cette rubrique permet de personnaliser les éléments liés à l'emplacement géographique du système. Cela comprend le clavier, la prise en charge des langues, l'heure et la date.

#### Clavier

Dans le système de démonstration de ce guide, nous acceptons la valeur par défaut (*English US*) et n'apportons aucune modification.

Cependant, si vous devez apporter des modifications ici, à partir de l'écran `Installation Summary`, cliquez sur l'option ++"keyboard"++ pour spécifier la disposition du clavier du système. À l'aide du bouton ++plus++, vous pouvez ajouter et commander des dispositions de clavier supplémentaires si nécessaire.

Cliquez sur ++"done"++ lorsque vous en avez terminé avec cet écran.

#### Support linguistique

L'option `Prise en charge des langues` sur l'écran *Résumé de l'installation* permet de spécifier la prise en charge de langues supplémentaires.

Nous accepterons la valeur par défaut - **English (United States)** et n'effectuerons aucune modification, cliquez sur ++"done"++.

#### Heure & Date

Cliquez sur l'option ++"Time & Date"++ sur l'écran principal `Installation Summary `pour faire apparaître un autre écran qui permet de sélectionner le fuseau horaire où se trouve la machine. Utilisez les flèches déroulantes pour sélectionner la région et la ville les plus proches de vous.

Acceptez la valeur par défaut et activez l'option ++"Automatic date & time"++, qui permet au système de définir automatiquement l'heure et la date correctes à l'aide du protocole NTP (Network Time Protocol).

Cliquez sur ++"done"++ une fois terminé.

### Section Logiciel

Dans la section *Software* de l'écran *Installation Summary*, vous pouvez sélectionner ou modifier la source d'installation ainsi qu'ajouter des logiciels supplémentaires pour l'environnement sélectionné.

#### Source de l'installation

Étant donné que nous utilisons une image ISO Rocky Linux 10 pour l'installation, l'option Source détectée automatiquement est sélectionnée par défaut pour nous. Vous pouvez confirmer les valeurs par défaut prédéfinies.

!!! tip "Astuce"

    La zone Source d'installation vous permet d'effectuer une installation basée sur le réseau (par exemple, si vous utilisez l'ISO de démarrage Rocky Linux - Rocky-10.0-x86_64-boot.iso). Pour une installation basée sur le réseau, vous devez d'abord vous assurer qu'une carte réseau sur le système cible est correctement configurée et peut atteindre la (ou les) source(s) d'installation par le réseau (LAN ou Internet). Pour effectuer une installation basée sur le réseau, cliquez sur `Installation Source`, puis sélectionnez le bouton radio `On the network`. Sélectionnez ensuite le protocole correct et entrez l’URI exact. Cliquez sur `Done`.

#### Sélection de Logiciel

En cliquant sur l'option ++"Software Selection"++ sur l'écran principal *Installation Summary*, vous accédez à une zone de sélection de logiciel composée de deux sections :

- **Environnement de base** : Installation Minimale
- **Logiciels supplémentaires pour l'environnement sélectionné** : La sélection d'un environnement de base sur le côté gauche présente une variété de logiciels supplémentaires associés à installer pour l'environnement donné sur le côté droit.

Sélectionnez l'option *Minimal Install* (fonctionnalité de base).

Cliquez sur ++"done"++ en haut de l'écran.

### Section Système

Utilisez la section Système de l'écran *Installation Summary* pour personnaliser et apporter des modifications aux éléments liés au matériel sous-jacent du système cible. C'est ici que vous créez vos partitions ou volumes de disque dur, spécifiez le système de fichiers, spécifiez la configuration réseau et activez ou désactivez KDUMP.

#### Destination de l'Installation

À partir de l'écran *Installation Summary*, cliquez sur l'option ++"Installation Destination"++. Cela vous amène au domaine de tâches correspondant.

Vous verrez un écran affichant tous les lecteurs de disque disponibles sur le système cible. Si vous n'avez qu'un seul lecteur de disque sur le système, comme sur notre système d'exemple, vous voyez le lecteur répertorié sous *Local Standard Disks* avec une coche à côté. En cliquant sur l'icône du disque, vous pourrez activer ou désactiver la coche de sélection du disque. Laissez-le coché pour sélectionner le disque.

Dans la section *Storage Configuration* :

1. Sélectionnez le bouton radio ++"Automatic"++.

2. Cliquez sur ++"done"++ en haut de l'écran.

3. Une fois que le programme d'installation détermine que vous avez un disque utilisable, il retourne à l'écran *Installation Summary*.

### Réseau & Nom d'Hôte

La tâche importante suivante dans la procédure d'installation sous la zone Système implique la configuration du réseau, où vous pouvez ajuster les paramètres liés au réseau pour le système.

!!! note "Remarque"

    Après avoir cliqué sur l'option ++"Network & Hostname"++, tout le matériel d'interface réseau correctement détecté (tel qu'Ethernet, les cartes réseau sans fil, etc.) sera répertorié dans le volet gauche de l'écran de configuration réseau. Selon votre configuration matérielle spécifique, les périphériques Ethernet sous Linux ont des noms similaires à « eth0 », « eth1 », « ens3 », « ens4 », « em1 », « em2 », « p1p1 », « enp0s3 », etc. 
    Vous pouvez configurer chaque interface à l'aide de DHCP ou définir manuellement l'adresse IP. 
    Si vous choisissez de configurer manuellement, assurez-vous que vous disposez de toutes les informations requises, comme l'adresse IP, le masque de réseau et d'autres détails pertinents.

Cliquer sur le bouton ++"Network & Host Name"++ dans l'écran principal *Installation Summary* ouvre l'écran de configuration correspondant. Ici, vous pouvez également configurer le nom d'hôte du système.

!!! note "Remarque"

    Vous pourrez facilement modifier ce nom plus tard, une fois le système d'exploitation installé.

La tâche de configuration suivante concerne les interfaces réseau du système.

1. Vérifiez que le volet de gauche répertorie une carte/adaptateur réseau
2. Cliquez sur l'un des périphériques réseaux détectés dans le volet de gauche pour le sélectionner.   
   Les propriétés configurables de la carte réseau sélectionnée s'affichent dans le volet de droite de l'écran.

!!! note "Remarque"

    Dans notre système d'exemple, nous avons deux périphériques Ethernet (`ens3` et `ens4`), tous deux dans un état connecté. Le type, le nom, la quantité et l’état des périphériques réseau de votre système peuvent différer de ceux de notre système de démonstration.

Verify that the switch of the device you want to configure is in the `ON` (blue) position in the right pane. Dans cette section, vous pouvez confirmer toutes les valeurs par défaut.

Cliquez sur ++"done"++ pour revenir à l'écran principal *Installation Summary*.

!!! warning "Avertissement"

    Portez attention à l’adresse IP du serveur dans cette section du programme d’installation. Si vous n'avez pas d'accès physique ou facile à la console du système, ces informations vous seront utiles plus tard lorsque vous devrez vous connecter au serveur une fois l'installation du système d'exploitation terminée.

### Section Paramètres d'Utilisateur

Utilisez cette section pour créer un mot de passe pour le compte utilisateur `root` et pour créer de nouveaux comptes administratifs ou non.

#### Mot de passe `root`

1. Cliquez sur le champ *Mot de passe root* sous *Paramètres utilisateur* pour démarrer l'écran de tâches *Compte root*.

    !!! warning "Avertissement"
   
        Le superutilisateur `root` est le compte le plus privilégié du système. Si vous choisissez de l'utiliser ou de l'activer, vous devez protéger ce compte avec un mot de passe fort.

2. Vous verrez une des deux options : `Disable root account` ou `Enable root account`. Acceptez le choix par défaut.

3. Cliquez sur ++"done"++.

#### Création d'un Utilisateur

Création d'utilisateur :

1. Cliquez sur le champ *User Creation* sous *User Settings* pour démarrer l'écran de tâche *Create User*. Utilisez cette zone de tâches pour créer un compte utilisateur privilégié (administrateur) ou non (non administratif).

    !!! Mise en garde
   
        Sur un système Rocky Linux 10, le compte `Root` est désactivé par défaut ; il est donc essentiel de s'assurer que le compte utilisateur créé lors de l'installation du système d'exploitation dispose de privilèges administratifs. Cet utilisateur peut être utilisé de manière non privilégiée pour les tâches quotidiennes sur le système et aura également la possibilité d'élever son rôle pour effectuer des fonctions administratives (`root`) si nécessaire.

    Nous allons créer un utilisateur régulier qui peut invoquer les privilèges `superuser` (administrateur) au besoin.

2. Remplissez les champs de l'écran *Create User* avec les informations suivantes :

    - **Full name**: `rockstar`
    - **Username**: `rockstar`
        - **Add administrative privileges to this user account (wheel group membership)**: Checked
        - **Require a password to use this account**: Checked
        - **Password**: `04302021`
        - **Confirm password**: `04302021`

3. Cliquez sur ++"done"++.

## L'installation

Une fois que vous êtes satisfait de vos choix pour les différentes tâches d'installation, la phase suivante du processus d'installation commencera l'installation proprement dite.

### Lancement de l'Installation

Une fois satisfait de vos choix pour les différentes tâches d'installation, cliquez sur le bouton ++"Begin Installation"++ sur l'écran principal `Installation Summary`.

L'installation commencera, et le logiciel d'installation en affichera la progression. Une fois l'installation lancée, diverses tâches commenceront à s'exécuter en arrière-plan, comme le partitionnement du disque, le formatage des partitions ou des volumes LVM, la vérification et la résolution des dépendances logicielles, l'écriture du système d'exploitation sur le disque et d'autres tâches similaires.

!!! note "Remarque"

    Si vous ne voulez pas continuer après avoir cliqué sur le bouton ++"Begin Installation"++, vous pouvez toujours quitter l'installation en toute sécurité sans perdre de données. Pour quitter le programme d'installation, réinitialisez simplement votre système en cliquant sur le bouton ++"Quit"++, en appuyant sur Ctrl-Alt-Delete sur le clavier ou en appuyant sur l'interrupteur de réinitialisation ou d'alimentation.

### Terminer l'installation

Une fois le programme d'installation terminé, vous verrez un écran de progression d'installation final avec un message complet.

Finalement, terminez toute la procédure en cliquant sur le bouton ++"Reboot System"++. Le système redémarre de lui-même.

### Se connecter

Le système est maintenant configuré et prêt à être utilisé. Vous verrez la console Rocky Linux.

![Rocky Linux Welcome Screen](images/installation_10_0_F02.png)

La marche à suivre pour se connecter au système est la suivante :

1. Tapez `rockstar` à l'invite de connexion et appuyez sur ++enter++.

2. À l'invite du mot de passe, entrez `04302021` (le mot de passe de Rockstar) et appuyez sur ++enter++ (le mot de passe ne sera ***pas*** affiché à l'écran, c'est normal).

3. Exécutez la commande `whoami` après la connexion.  
   Cette commande affiche le nom de l'utilisateur présentement connecté.

![Écran de Connexion](images/installation_9.0_F03.png)
