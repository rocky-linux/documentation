---
title: Rocky sur VirtualBox
author: Steven Spencer
contributors: Trevor Cooper, Ezequiel Bruni, Ganna Zhyrnova
tested on: 8.4, 8.5
tags:
  - virtualbox
  - virtualisation
---

# Rocky sur VirtualBox

## Introduction

VirtualBox&reg; est une puissante solution de virtualisation pour un usage domestique et professionnel. De temps à autre il arrive qu'une personne témoigne de problèmes pour exécuter Rocky Linux dans VirtualBox&reg;. Cela a été testé plusieurs fois depuis la release candidate et fonctionne correctement. Les problèmes rapportés ont souvent un rapport avec la vidéo.

Ce document a pour objectif de fournir un guide détaillé en vue d'obtenir un système Rocky Linux fonctionnel dans VirtualBox&reg;. La machine utilisée pour la rédaction de cette documentation utilisait Linux mais vous pouvez utiliser tout autre système d'exploitation pris en charge.

## Prérequis

* Une machine (Windows, Mac, Linux, Solaris) disposant de suffisamment de mémoire et d'espace disque pour construire et exécuter l'instance VirtualBox&reg;.
* VirtualBox&reg; installé sur votre machine. Vous pouvez le trouver [ici](https://www.virtualbox.org/wiki/Downloads).
* Une copie de l'[ISO DVD](https://rockylinux.org/download) de Rocky Linux correspondant à votre architecture. (x86_64 or ARM64).
* Assurez-vous que votre OS est en 64 bit et que la virtualisation matérielle est activée dans votre BIOS.

!!! note "Remarque"

    La virtualisation matérielle est indispensable à l'installation d'un OS 64 bit. Si votre écran de configuration n'indique que les options 32-bit, il faut vous arrêter ici et corriger ce point avant de poursuivre.

## Préparation de la configuration de VirtualBox&reg;

Une fois VirtualBox&reg; installé, la prochaine étape est de le démarrer. Lorsque aucune image n'est installée, vous arrivez devant un écran comme celui-ci :

 ![VirtualBox Fresh Install](../images/vbox-01.png)

 Tout d'abord, vous devez indiquer à VirtualBox&reg; quel va être votre OS :

* Cliquez sur « Nouveau » (l'icône en dent de scie).
* Saisissez un nom. Par exemple : « Rocky Linux 8.x ».
* Laisser le dossier de la machine tel qu'il a été rempli automatiquement.
* Changez le type de machine pour « Linux ».
* Et choisissez « Red Hat (64-bit) ».
* Cliquez sur « Suivant ».

 ![Name And Operating System](../images/vbox-02.png)

Ensuite, il nous faut allouer de la RAM à cette machine. Par défault, VirtualBox&reg; allouera automatiquement 1024 Mo. Cela ne sera pas optimal pour un OS récent, Rocky Linux inclus. Si vous avez de la mémoire disponible, il est recommandé d'allouer 2 à 4 Go (2048 Mo ou 4096 Mo), voire plus. Gardez en tête que VirtualBox&reg; n'utilisera cette mémoire que tant que la machine virtuelle est en cours d'exécution.

Il n'y a pas de capture d'écran pour ce réglage, changez simplement sa valeur en fonction de la mémoire disponible. Adaptez le en fonction de vos souhaits.

À présent, il nous faut configurer la taille du disque dur. Par défaut, VirtualBox&reg; va automatiquement cocher le bouton radio « Créer un disque virtuel maintenant ».

![Hard Disk](../images/vbox-03.png)

* Cliquez sur ++"Create"++

Vous obtiendrez une boîte de dialogue permettant la création de différents types de disques durs et plusieurs d'entre eux sont listés ici. Il existe plusieurs types de disques durs. Consultez la documentation d'Oracle VirtualBox pour [plus d'informations](https://docs.oracle.com/en/virtualization/virtualbox/6.0/user/vdidetails.html) sur la sélection des types de disques durs virtuels. Dans le cadre de ce document, vous pouvez utiliser la valeur par défaut (VDI) :

![Hard Disk File Type](../images/vbox-04.png)

* Cliquez sur ++"Next"++

Le prochain écran va configurer le stockage sur le disque dur physique. Il y a deux options. « Taille fixe » sera plus lente à créer, plus rapide à utiliser mais moins flexible en terme d'espace (si vous avez besoin de plus d'espace vous serez limité à celui que vous initialement défini).

L'option par défaut, `Dynamically Allocated`, sera plus rapide à créer et plus lente à utiliser, mais vous permettra d'évoluer si votre espace disque doit changer.

![Storage On Physical Hard Disk](../images/vbox-05.png)

* Cliquez sur ++"Next"++

VirtualBox&reg; vous offre à présent la possibilité de spécifier l'emplacement du fichier de disque dur virtuel. Une option permettant d'étendre l'espace disque dur virtuel par défaut de 8 Go est également disponible ici. C'est une option utile car 8 Go d'espace disque ne sont pas suffisants pour installer, ni utiliser, une machine avec interface graphique. Définissez cette valeur sur 20 Go (ou plus) en fonction de l'utilisation que vous souhaitez faire de la machine virtuelle et de la quantité d'espace disque dont vous disposez :

![File Location And Size](../images/vbox-06.png)

* Cliquez sur ++"Create"++

Nous en avons fini avec la configuration de base. Vous devriez avoir un écran ressemblant à celui-ci :

![Basic Configuration Complete](../images/vbox-07.png)

## Attacher l'image ISO

Notre prochaine étape est d'attacher l'image ISO téléchargée précédemment en tant que périphérique CD ROM virtuel. Cliquez sur « Paramètres » (l'icône en forme d'engrenage) ce qui devrait vous amener devant l'écran suivant :

![Settings](../images/vbox-08.png)

* Cliquez sur « Stockage » dans le menu de gauche.
* Sous « Périphérique de stockage » dans la section du milieu, cliquez l'icône CD qui indique « Vide ».
* Sous « Attributs », du côté droit, cliquez sur l'icône CD.
* Sélectionnez « Choisir/créer un disque optique virtuel ».
* Cliquez sur le bouton « Ajouter » (l'icône en forme de plus) and naviguer jusqu'à votre image ISO de Rocky Linux.
* Sélectionnez l'image ISO et cliquez sur « Ouvrir ».

Vous devriez avoir l'ISO ajoutée à la liste des périphériques disponibles comme ceci :

![ISO Image Added](../images/vbox-09.png)

* Sélectionnez l'image ISO et cliquez sur « Choisir ».

L'image ISO Rocky Linux apparaît comme sélectionnée sous « Contrôleur IDE » dans la section du milieu :

![ISO Image Selected](../images/vbox-10.png)

* Cliquez sur ++"OK"++

### Mémoire Vidéo pour Installations Graphiques

VirtualBox® configure 16 Mo de mémoire pour prendre en compte la vidéo. C'est suffisant si vous prévoyez d'exécuter un serveur bare-bones sans interface graphique, mais dès que vous ajoutez des graphiques, cela ne suffit pas. Les utilisateurs qui conservent ce paramètre se voient souvent confrontés à un écran de démarrage qui ne se termine jamais ou tout autres erreurs.

Si vous utilisez Rocky Linux avec une interface graphique, vous devez allouer suffisamment de mémoire pour exécuter les graphiques. Si votre machine est un peu mince en termes de mémoire, ajustez cette valeur successivement de 16 Mo jusqu'à ce que tout fonctionne correctement. La résolution vidéo de votre machine hôte est également un facteur dont vous devez tenir compte.

Réfléchissez bien comment vous voulez utiliser votre machine virtuelle Rocky Linux et essayez d'allouer de la mémoire vidéo compatible avec votre machine hôte et vos autres exigences. Vous pouvez trouver plus d'informations sur les paramètres d'affichage dans la [documentation officielle d'Oracle](https://docs.oracle.com/en/virtualization/virtualbox/6.0/user/settings-display.html).

Si vous disposez de beaucoup de mémoire, vous pouvez définir cette valeur au maximum de 128 Mo. Pour résoudre ce problème avant de démarrer la machine virtuelle, cliquez sur `Settings` (icône d'engrenage) et vous devriez obtenir le même écran de configuration que celui que nous avons obtenu lors de la connexion de l'image ISO (ci-dessus).

Pour l'instant :

* Cliquez sur "Display" sur le côté gauche.
* Dans l'onglet `Screen` sur le côté droit, vous remarquerez l'option `Video Memory` avec la valeur par défaut définie sur 16 Mo.
* Remplacez par la valeur souhaitée. Vous pouvez réajuster la valeur en revenant à cet écran à tout moment. Dans notre exemple, nous utiliserons 128 Mo.

!!! tip "Astuce"

    Il est possible de régler la mémoire vidéo jusqu'à 256 Mo. Pour plus de renseignements vous pouvez consulter [la documentation d'Oracle](https://docs.oracle.com/en/virtualization/virtualbox/6.0/user/vboxmanage-modifyvm.html).

L'affichage à l'écran devrait ressembler à ceci :

![Settings Video](../images/vbox-12.png)

* Cliquez sur ++"OK"++

## Démarrage de l'installation

Vous avez tout configuré de manière à pouvoir lancer l'installation. Notez qu'il n'existe pas de différence fondamentale entre une installation de Rocky Linux sur un machine virtuelle de VirtualBox&reg; et un ordinateur en chair et en os. Les étapes de l'installation sont les mêmes.

Maintenant que nous avons tout préparé pour l'installation, il vous suffit de cliquer sur `Start` (icône flèche verte vers la droite) pour lancer l'installation de Rocky Linux. Une fois que vous avez cliqué sur l'écran de sélection de la langue, Anaconda passe à l'écran suivant, `Installation Summary`. Vous pouvez définir les éléments dont vous avez besoin, cependant les éléments suivants sont indispensables :

* Heure & Date
* Software Selection (si vous désirez quelque chose en plus de l'installation par défaut, "Server with GUI")
* Destination de l'installation
* Réseau & nom d'hôte
* Paramètres de l'utilisateur

Si vous avez des doutes sur ces paramètres, veuillez consulter la documentation sur [Installing Rocky](../installation.md).

Une fois que vous avez terminé l'installation, vous devriez avoir une instance de Rocky Linux en cours d'exécution dans VirtualBox&reg;.

Après l'installation et le redémarrage, vous obtiendrez un écran de contrat de licence EULA que vous devrez accepter. Lorsque vous avez cliqué sur `Finish Configuration`, vous devriez obtenir une connexion graphique (si vous avez choisi une option GUI) ou bien une connexion en ligne de commande. L'auteur a choisi le `Server with GUI` par défaut à des fins de démonstration :

![A Running Rocky VirtualBox Machine](../images/vbox-11.png)

## Autres Informations

L'intention de ce document n'est pas de faire de vous un expert de VirtualBox®. Pour plus d'informations, veuillez consulter la [documentation](https://docs.oracle.com/en/virtualization/virtualbox/6.0/user/).

!!! tip "Suggestion"

    VirtualBox&reg; offre des options supplémentaires en ligne de commande en utilisant `VBoxManage`. Ce document ne couvre pas l'utilisation de `VBoxManage`, la documentation officielle d'Oracle fournit de plus amples [détails](https://docs.oracle.com/en/virtualization/virtualbox/6.0/user/vboxmanage-intro.html) si vous voulez approfondir le sujet.

## Conclusion

Il est facile de créer, d'installer et d'exécuter une machine virtuelle Rocky Linux sous VirtualBox®. Bien que loin d'être un guide exhaustif, suivre les étapes ci-dessus devrait vous permettre d'installer Rocky Linux avec succès. Si vous utilisez VirtualBox® et avez une configuration spécifique que vous aimeriez partager, l'auteur vous invite à soumettre de nouvelles sections à ce document.
