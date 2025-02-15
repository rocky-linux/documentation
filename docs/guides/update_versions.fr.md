---
title: Mises à niveau des versions de Rocky Linux
author: Steven Spencer
contributors: Ganna Zhyrnova
---

**OU** Comment dupliquer n'importe quelle machine Rocky Linux.

## Introduction

Depuis le premier jour du projet Rocky Linux, certains ont demandé : ==Comment passer de CentOS 7 à Rocky 8, ou de Rocky 8 à Rocky 9 ?== La réponse est toujours la même : **Le projet NE prend PAS en charge les mises à niveau AUTOMATIQUEs d'une version majeure vers une autre version majeure. Vous devez réinstaller pour passer à la version majeure suivante.** Pour être clair, c'EST\*\* la bonne réponse. Ce document espère donner aux utilisateurs une méthode pour passer d'une version majeure à la suivante, en utilisant la procédure prise en charge par Rocky pour une nouvelle installation. Vous pouvez également utiliser cette méthode pour effectuer une reconstruction complète avec la même version de Rocky Linux. Par exemple, 9.5 vers une nouvelle installation 9.5 avec tous les packages.

!!! note "Mises en garde"

```
Même en suivant cette procédure, de nombreux problèmes peuvent survenir lors du passage d'une ancienne version d'un système d'exploitation (OS) à une version plus récente du même système d'exploitation ou d'un système d'exploitation différent. Les programmes deviennent obsolètes, remplacés par des nouveaux portant des noms de paquets complètement différents, ou les noms ne correspondent tout simplement pas d'un système d'exploitation à l'autre. De plus, vous devez connaître en détail les référentiels de logiciels de votre machine et également vérifier qu'ils sont toujours fonctionnels pour le nouveau système d'exploitation. Si vous passez d'une version beaucoup plus ancienne à une version beaucoup plus récente, assurez-vous que votre processeur et les autres exigences de votre machine correspondent à la nouvelle version. Pour ces raisons et bien d'autres, vous devez rester prudent et noter toute erreur ou tout problème lors de l'exécution de cette procédure. Ici, l'auteur a utilisé Rocky Linux 8 comme ancienne version et Rocky Linux 9 comme nouvelle version majeure. La formulation de tous les exemples utilise ces deux versions. Procédez toujours à vos propres risques et périls.
```

## Récapitulatif des Étapes

1. Établir une liste complète des utilisateurs de l'ancienne installation (`userid.txt`) ainsi que des relations de groupes correspondantes.
2. Établir une liste des référentiels de l'ancienne installation (`repolist.txt`).
3. Établir une liste des packages de l'ancienne installation (`installed.txt`).
4. Sauvegardez toutes les données, configurations, utilitaires et scripts de l'ancienne installation vers un emplacement non volatile avec les fichiers `.txt` créés.
5. Vérifiez que le matériel que vous allez installer prend bien en charge le système d’exploitation que vous installez. (CPU, mémoire, espace disque, etc.)
6. Effectuez une nouvelle installation du système d’exploitation que vous voulez utiliser sur le matériel.
7. Effectuez une `dnf upgrade` obtenir tous les packages qui pourraient avoir été mis à jour depuis la création du fichier ISO.
8. Créez tous les utilisateurs nécessaires en examinant le fichier `userid.txt`.
9. Installez tous les référentiels manquants qui ne sont pas liés à Rocky Linux dans le fichier `repolist.txt`. (Voir les notes relatives aux référentiels EPEL et Code Ready Builder – CRB –.)
10. Installez les packages en utilisant la procédure du fichier `installed.txt`.

## Detail des Étapes

!!! info "Mise à niveau de la même version"

```
Comme indiqué précédemment, cette procédure devrait fonctionner aussi bien pour dupliquer une installation sur une machine avec la même version du système d'exploitation, comme 8.10 vers 8.10 ou 9.5 vers 9.5. La différence est que vous ne devriez pas avoir besoin de `--skip-broken` lors de l'installation des paquets à partir du fichier `installed.txt`. Si vous obtenez des erreurs de paquet lors de l'installation d'une version, il vous manque probablement un référentiel. Arrêtez la procédure et réexaminez le fichier `repolist.txt`. Les exemples ici utilisent 8.10 comme ancienne installation et 9.5 comme nouvelle.
```

!!! warning "La version 10 n'est pas encore connue"

```
En raison des vastes changements entre la version 9.5 et la prochaine version 10, cette procédure **pourrait ne pas fonctionner** pour passer de la version 9.5 à la version 10. L'exploration de cette question aura lieu une fois qu'une version 10 sera disponible à tester.
```

### Ancienne machine dans l'exemple

L'ancienne machine utilisée ici tourne sous Rocky Linux 8. L'installation comprend plusieurs packages de référentiel Extra Packages for Enterprise Linux (`EPEL`).

!!! info "Code Ready Builder"

````
Le référentiel `Code Ready Builder` (CRB) de Rocky Linux 9 remplace les fonctionnalités du référentiel PowerTools obsolète qui existait dans la version 8. Si vous passez d'une version 8 à une version 9 où vous disposez de l'`EPEL`, vous devrez activer le `CRB` sur votre nouvelle machine avec les éléments suivants :

```bash
sudo dnf config-manager --enable crb
```
````

#### Établir la liste des utilisateurs

Vous devrez créer manuellement tous les utilisateurs sur la nouvelle machine, vous devez donc savoir quels comptes d'utilisateurs et leurs groupes vous devrez créer. Les comptes d'utilisateurs commencent généralement à l'ID utilisateur 1000 et augmentent progressivement.

```bash
sudo getent passwd > userid.txt
```

#### Établir une liste détaillée des dépôts

Vous avez besoin d'une liste des dépôts qui existent sur l'ancienne machine :

```bash
sudo ls -al /etc/yum.repos.d/ > repolist.txt
```

#### Établir une liste détaillée des paquets

Générez la liste des packages avec la commande suivante :

```bash
sudo dnf list installed | awk 'NR>1 {print $1}' | sort -u > installed.txt
```

Ici, le `NR>1` élimine l'enregistrement en tête de la colonne, qui contient `Installed` provenant de la commande `dnf list installed`. Ce n'est pas un package, vous n'en avez donc pas besoin. La directive `{print $1}` signifie utiliser uniquement la première colonne. Vous n'avez pas besoin de la version du package ou du référentiel d'où il provient dans la liste.

Vous n’aurez pas besoin d’installer de packages liés au noyau. Cela ne fait pas de mal de les réinstaller si vous omettez cette étape. Vous pouvez supprimer les lignes du noyau avec :

```bash
sudo sed -i '/kernel/d' installed.txt
```

#### Sauvegarde complète

Cela peut englober beaucoup de choses. Assurez-vous de connaître en détail l’objectif de la machine que vous remplacez et tous ses composants de programme (base de données, serveur de messagerie, DNS, etc.). Dans le doute, effectuez une sauvegarde complète des données en question.

#### Copie de Fichiers

Copiez les fichiers texte que vous avez créés dans un emplacement non volatile ainsi que toutes les données de sauvegarde.

### Nouvelle machine dans l'exemple

Votre nouvelle installation de Rocky Linux 9 est terminée. Vous devez obtenir toutes les mises à jour de packages depuis la création de l'image ISO :

```bash
sudo dnf upgrade
```

Vous êtes prêt à commencer à copier vos fichiers texte et vos sauvegardes à partir de l'endroit où vous les avez stockés dans la procédure précédente.

#### Création des utilisateurs

Examinez le fichier `userid.txt` et créez les utilisateurs dont vous avez besoin sur la nouvelle machine.

#### Installation des dépôts

Examinez le fichier `repolist.txt` et installez manuellement les référentiels dont vous avez besoin. Vous pouvez ignorer les dépôts liés à Rocky Linux. N'oubliez pas que vous disposez des packages de l'EPEL, vous aurez donc besoin du référentiel CRB plutôt que de PowerTools :

```bash
sudo dnf config-manager --enable crb
```

Installation du dépôt EPEL :

```bash
sudo dnf install epel-release
```

Installez tous les autres référentiels du fichier `repolist.txt` qui ne sont pas basés sur Rocky Linux ou EPEL.

#### Installation des paquets

Une fois l'installation des référentiels terminée, essayez d'installer vos packages à partir du fichier `installed.txt` :

```bash
sudo dnf -y install $(cat installed.txt)
```

Certains packages n'existeront plus lors du passage de Rocky Linux 8 à Rocky Linux 9, quels que soient les référentiels que vous avez activés. L’exécution de cette commande vous donne une idée de ce que sont ces packages.

Voici ce qui n'a pas été installé sur la machine de test de l'auteur (réorganisé sous forme de colonne plutôt que d'une longue chaîne) :

```text
Error: Unable to find a match: 
OpenEXR-libs.x86_64 
bind-export-libs.x86_64 
dhcp-libs.x86_64 
fontpackages-filesystem.noarch 
hardlink.x86_64 
ilmbase.x86_64 
libXxf86misc.x86_64 
libcroco.x86_64 
libmcpp.x86_64 
libreport-filesystem.x86_64 
mcpp.x86_64 
network-scripts.x86_64 
platform-python.x86_64 
platform-python-pip.noarch 
platform-python-setuptools.noarch 
xorg-x11-font-utils.x86_64
```

!!! note "Remarque"

````
Si vous avez besoin des fonctionnalités de ces packages manquants sur votre nouvelle installation, enregistrez-les dans un fichier pour une utilisation ultérieure. Vous pouvez voir l'état de disponibilité des packages manquants en utilisant cette commande :

```bash
sudo dnf whatprovides [package_name]
```
````

Exécutez à nouveau la commande, mais cette fois en ajoutant l'option `--skip-broken` :

```bash
sudo dnf -y install $(cat installed.txt) --skip-broken
```

Étant donné que vous venez d’effectuer de nombreuses modifications, vous devez redémarrer le système avant de continuer.

#### Restauration de vos sauvegardes

Une fois tous les packages installés, restaurez vos sauvegardes, fichiers de configuration modifiés, scripts et autres utilitaires que vous avez sauvegardés avant de passer à votre nouvelle machine.

## Conclusion

Il n'existe pas de routine magique (prise en charge par Rocky Linux) pour passer d'une version majeure à une autre. Les développeurs de Rocky Linux prennent uniquement en charge une toute nouvelle installation. La routine fournie ici vous permet de passer d'une version majeure à une autre tout en respectant les meilleures pratiques de l'équipe Rocky Linux.

Cette procédure suppose une installation relativement simple. Cependant, la complexité éventuelle de votre installation peut nécessiter des étapes supplémentaires. Utilisez cette procédure comme un guide que vous devez adapter soigneusement à votre cas d'utilisation.

## Disclaimer

Bien que le document de base soit celui de l'auteur, deux personnes du [Forum] (https://forums.rockylinux.org/t/boot-too-small-rebuild/17415) ont suggéré une manière plus propre de générer le fichier `installed.txt` en éliminant les packages du noyau. Merci à tous ceux qui ont contribué à l'élaboration de cet exemple de procédure.
