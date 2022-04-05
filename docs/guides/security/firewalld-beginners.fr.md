---
title: pare-feu pour les débutants
author: Ezequiel Bruni
contributors: Steven Spencer
update: 16-février-2022
---

# `pare-feu` pour les débutants

## Introduction

Il y a longtemps, j'étais un petit utilisateur d'ordinateur débutant qui a entendu dire qu'avoir un pare-feu était *supposé* être super bon. Il me permettait de décider ce qui est entré, et ce qui est sorti de mon ordinateur, non ? Mais il semblait surtout empêcher mes jeux vidéo d'accéder à Internet ; j'étais *pas* un campeur heureux.

Bien sûr, si vous êtes là, vous avez probablement une meilleure idée de ce qu'est un pare-feu et de ce qu'il fait que je ne l'ai fait. Mais si votre expérience de pare-feu revient à dire à Windows Defender que oui, pour l'amour de tout ce qui est saint, votre nouvelle application est autorisée à utiliser Internet, ne vous inquiétez pas. Cela dit "pour les débutants" vers le haut, je vous ai.

En d'autres termes, mes collègues devraient savoir qu'il y aura beaucoup d'explications à apporter.

Alors, parlons de ce que nous sommes ici. `firewalld` est l'application de pare-feu par défaut empaquetée avec Rocky Linux, et elle est conçue pour être assez simple à utiliser. Vous devez juste en savoir un peu sur le fonctionnement des pare-feu, et ne pas avoir peur d'utiliser la ligne de commande.

Ici tu apprendras :

* Les bases mêmes de la façon dont `pare-feu` fonctionne
* Comment utiliser `pare-feu` pour restreindre ou autoriser les connexions entrantes et sortantes
* Comment autoriser uniquement les personnes de certaines adresses IP ou lieux à se connecter à distance à votre machine
* Comment gérer certaines fonctionnalités spécifiques à `pare-feu`comme les Zones.

Ceci est *non* prévu pour être un guide complet ou exhaustif.

### Une note sur l'utilisation de la ligne de commande pour gérer votre pare-feu

Eh bien... il y a ** options de configuration du pare-feu graphique. Sur le bureau, il y a `firewall-config` qui peut être installé à partir des dépôts, et sur les serveurs, vous pouvez [installer Cockpit](https://linoxide.com/install-cockpit-on-almalinux-or-rocky-linux/) pour vous aider à gérer les pare-feu et toute une série d'autres choses. **Cependant, je vais vous enseigner la façon de faire des choses en ligne de commande dans ce tutoriel pour deux raisons :**

1. Si vous utilisez un serveur, vous utiliserez la ligne de commande pour la plupart de ces choses. De nombreux tutoriels et guides pour le serveur Rocky donneront des instructions en ligne de commande pour la gestion du pare-feu, et il est préférable que vous compreniez ces instructions, plutôt que de simplement copier et coller ce que vous voyez.
2. Comprendre comment les commandes `coupe-feu` fonctionnent peut vous aider à mieux comprendre comment fonctionne le logiciel de pare-feu. Vous pouvez prendre les mêmes principes que vous apprenez ici, et avez une meilleure idée de ce que vous faites si vous décidez d'utiliser une interface graphique dans le futur.

## Prérequis et hypothèses
Vous aurez besoin de :

* Une machine Rocky Linux de toute sorte, locale ou distante, physique ou virtuelle
* Accès au terminal et volonté de l'utiliser
* Vous avez besoin d'un accès root, ou au moins de la possibilité d'utiliser `sudo` sur votre compte utilisateur. Pour des raisons de simplicité, je suppose que toutes les commandes sont exécutées en tant que root.
* Une compréhension de base de SSH ne ferait pas de mal à la gestion de machines distantes.

## Utilisation de base

### Commandes de service système

`le pare-feu` est exécuté en tant que service sur votre machine. Il démarre quand la machine le fait, ou il devrait. Si, pour une raison quelconque, `le pare-feu` n'est pas déjà activé sur votre machine, vous pouvez le faire avec une simple commande :

```bash
systemctl active --now firewalld
```

Le drapeau `--now` démarre le service dès qu'il est activé, et vous sautez l'étape `systemctl démarre pare-feu`.

Comme pour tous les services sur Rocky Linux, vous pouvez vérifier si le pare-feu fonctionne avec :

```bash
état du pare-feu système
```

Pour l'arrêter entièrement:

```bash
arrêter le pare-feu système
```

Et pour donner au service un redémarrage dur :

```bash
systemctl redémarre le pare-feu
```

### Commandes de configuration et de gestion de `pare-feu de base`

`le pare-feu` est configuré avec la commande `firewall-cmd`. Vous pouvez, par exemple, vérifier l'état du `pare-feu` avec :

```bash
firewall-cmd --state
```

Après chaque *changement permanent* de votre pare-feu, vous devrez le recharger pour voir les changements. Vous pouvez donner aux configurations du pare-feu un "redémarrage doux" avec:

```bash
firewall-cmd --reload
```

!!! Note

    Si vous rechargez vos configurations qui n'ont pas été rendues permanentes, elles disparaîtront sur vous.

Vous pouvez voir toutes vos configurations et paramètres en même temps avec:

```bash
firewall-cmd --list-all
```

Cette commande affichera quelque chose qui ressemble à ceci :

```bash
public (actif)
  target : default
  icmp-block-inversion: no
  interfaces: enp9s0
  sources:
  services: ssh
  ports:
  protocols:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

### Enregistrement de vos modifications

!!! Avertissement "Attention : sérieusement, lisez ceci suivant."

    Par défaut, toutes les modifications apportées à la configuration de `firewalld` sont temporaires. Si vous redémarrez tout le service `firewalld`, ou redémarrez votre machine, aucun de vos changements au pare-feu ne sera sauvegardé à moins que vous ne fassiez une des deux choses très spécifiques.

Il est préférable de tester tous vos changements un par un, rechargeant la configuration de votre pare-feu au fur et à mesure. Ainsi, si vous vous enfermez accidentellement de quoi que ce soit, vous pouvez redémarrer le service (ou la machine), tous ces changements disparaissent comme mentionné ci-dessus.

Mais une fois que vous avez une configuration fonctionnelle, vous pouvez enregistrer vos modifications de façon permanente avec:

```bash
firewall-cmd --runtime-to-permanent
```

Cependant, si vous êtes absolument sûr de ce que vous faites, et si vous voulez juste ajouter la règle et aller de l'avant avec votre vie, vous pouvez ajouter le drapeau `--permanent` à n'importe quelle commande de configuration :

```bash
firewall-cmd --permanent [le reste de votre commande]
```

## Gestion des Zones

Avant toute chose, je dois expliquer les zones. Les zones sont une fonctionnalité qui vous permet essentiellement de définir différents ensembles de règles pour différentes situations. Les zones sont une grande partie du `pare-feu` donc il est payant de comprendre comment elles fonctionnent.

Si votre machine a plusieurs façons de se connecter à différents réseaux (par ex. Ethernet et WiFi), vous pouvez décider qu'une connexion est plus fiable que l'autre. Vous pouvez configurer votre connexion Ethernet dans la zone « fiable » si elle est uniquement connectée à un réseau local que vous avez construit, et mettre le WiFi (qui pourrait être connecté à l'internet) dans la zone "public" avec des restrictions plus strictes.

!!! Note

    Une zone peut *seulement* être dans un état actif si elle a l'une de ces deux conditions :

    1. La zone est assignée à une interface réseau
    2. La zone est affectée aux adresses IP sources ou aux plages de réseau. (En savoir plus sur cela ci-dessous)

Les zones par défaut incluent ce qui suit (j'ai pris cette explication du guide de [DigitalOcean au `pare-feu`](https://www.digitalocean.com/community/tutorials/how-to-set-up-a-firewall-using-firewalld-on-centos-8), que vous devriez également lire):

> **drop :** Le niveau de confiance le plus bas. Toutes les connexions entrantes sont abandonnées sans réponse et seules les connexions sortantes sont possibles.

> **bloc :** Similaire à ce qui précède, mais au lieu de simplement supprimer les connexions, les requêtes entrantes sont rejetées avec un message icmp-host-interdit ou icmp6-adm-prohibé.

> **public :** Représente des réseaux publics non fiables. Vous ne faites pas confiance aux autres ordinateurs, mais vous pouvez autoriser certaines connexions entrantes au cas par cas. externe: Réseaux externes dans l'éventualité où vous utilisez le pare-feu comme passerelle. Il est configuré pour le masquage NAT afin que votre réseau interne reste privé mais accessible.

> **interne :** L'autre côté de la zone externe, utilisé pour la partie interne d'une passerelle. Les ordinateurs sont assez fiables et certains services supplémentaires sont disponibles.

> **dmz :** Utilisé pour les ordinateurs situés dans une DMZ (ordinateurs isolés qui n'auront pas accès au reste de votre réseau). Seules certaines connexions entrantes sont autorisées.

> **travail :** Utilisé pour les machines de travail. Faites confiance à la plupart des ordinateurs du réseau. Quelques services supplémentaires pourraient être autorisés.

> **maison :** Un environnement domestique. Cela implique généralement que vous faites confiance à la plupart des autres ordinateurs et que quelques autres services seront acceptés.

> **confiance :** Faites confiance à toutes les machines du réseau. Le plus ouvert des options disponibles et devrait être utilisé avec modération.

Ok, donc certaines de ces explications sont compliquées, mais honnêtement? Le débutant moyen peut se passer avec la compréhension "fiable", "maison", et "public", et quand utiliser lequel.

### Commandes de gestion de zone

Pour voir votre zone par défaut, exécutez :

```bash
pare-feu-cmd --get-default-zone
```

Pour voir quelles zones sont actives et faire des choses, exécutez :

```bash
firewall-cmd --get-active-zones
```

!!! Note : « Note : certaines choses peuvent avoir été faites pour vous.»

    Si vous utilisez Rocky Linux sur un VPS, il est probable qu'une configuration de base ait été mise en place pour vous. Plus précisément, vous devriez pouvoir accéder au serveur via SSH, et l'interface réseau aura déjà été ajoutée à la zone "publique".

Pour changer la zone par défaut :

```bash
firewall-cmd --set-default-zone [your-zone]
```

Pour ajouter une interface réseau à une zone :

```bash
firewall-cmd --zone=[your-zone] --add-interface=[your-network-device]
```

Pour changer la zone d'une interface réseau :

```bash
firewall-cmd --zone=[your-zone] --change-interface=[your-network-device]
```

Pour supprimer complètement une interface d'une zone :

```bash
firewall-cmd --zone=[your-zone] --remove-interface=[your-network-device]
```

Pour créer votre propre nouvelle zone avec un ensemble de règles entièrement personnalisé, et pour vérifier qu'elle a été correctement ajoutée :

```bash
firewall-cmd --new-zone=[your-new-zone]
pare-feu-cmd --get-zones
```

## Gestion des ports

Pour les ports non initiés, les ports (dans ce contexte) ne sont que des terminaux virtuels où les ordinateurs se connectent les uns aux autres afin qu'ils puissent envoyer des informations de retour et de suite. Pensez à ces ports physiques Ethernet ou USB sur votre ordinateur, mais invisible, et vous pouvez avoir jusqu'à 65,535 d'entre eux vont tous en même temps.

Je ne le ferais pas, mais vous le pouvez.

Chaque port est défini par un numéro, et certains ports sont réservés à des services spécifiques et à des types d'informations. Si vous avez déjà travaillé avec des serveurs web pour construire un site Web, par exemple, vous êtes peut-être familier avec le port 80 et le port 443. Ces ports permettent la transmission des données des pages Web.

Plus précisément, le port 80 permet le transfert de données via le protocole de transfert Hypertext (HTTP), et le port 443 est réservé aux données Hypertext Transfer Protocol Secure (HTTPS). *

Le port 22 est réservé au protocole Secure Shell (SSH) qui vous permet de vous connecter et de gérer d'autres machines via la ligne de commande (voir [notre court guide](ssh_public_private_keys.md) sur le suject). tout nouveau serveur distant peut seulement autoriser les connexions sur le port 22 pour SSH, et rien d'autre.

D'autres exemples incluent FTP (ports 20 et 21), SSH (port 22), et bien d'autres. Vous pouvez également définir des ports personnalisés à utiliser par les nouvelles applications que vous pouvez installer, qui n'ont pas déjà de numéro standard.

!!! Note : "Note: Vous ne devriez pas utiliser de ports pour tout."

    Pour des choses comme SSH, HTTP/S, FTP, et plus encore, il est recommandé de les ajouter à votre zone de pare-feu en tant que *services* et non en tant que numéros de port. Je vais vous montrer comment cela fonctionne ci-dessous. Cela dit, vous devez toujours savoir comment ouvrir les ports manuellement.

\* Pour les débutants absolus, HTTPS est essentiellement (plus ou moins) la même chose que HTTP, mais chiffré.

### Commandes de gestion du port

Pour cette section, je vais utiliser `--zone=public`... et le port 9001 comme exemple aléatoire, car il est plus de 9 000.

Pour voir tous les ports ouverts :

```bash
firewall-cmd --list-ports
```

Pour ajouter un port à votre zone de pare-feu (donc l'ouvrir pour l'utilisation), lancez simplement cette commande :

```bash
firewall-cmd --zone=public --add-port=9001/tcp
```

!!! Note

    À propos de cet bit `/tcp` :
    
    Ce bit `/tcp` à la fin indique au pare-feu que les connexions entreront par le protocole de contrôle de transfert, qui est ce que vous utiliserez pour la plupart des choses liées au serveur et à la maison.
    
    Les alternatives comme UDP sont pour le débogage, ou d'autres types de choses très spécifiques qui, franchement, ne sont pas dans la portée de ce guide. Reportez-vous à la documentation de n'importe quelle application ou service pour lequel vous souhaitez ouvrir un port.

Pour supprimer un port, renversez simplement la commande avec un seul mot :

```bash
firewall-cmd --zone=public --remove-port=9001/tcp
```

## Gestion des services

Les services, comme vous pouvez l'imaginer, sont des programmes normalisés qui s'exécutent sur votre ordinateur. `firewalld` est configuré pour qu'il puisse juste ouvrir la voie à la plupart des services communs chaque fois que vous en avez besoin.

C'est la meilleure façon d'ouvrir les ports à ces services communs, et bien plus encore:

* HTTP et HTTPS : pour les serveurs web
* FTP: Pour déplacer des fichiers (anciennement façonné)
* SSH : Pour contrôler les machines distantes et déplacer les fichiers à badigeonner la nouvelle façon
* Samba: Pour partager des fichiers avec des machines Windows

!!! Warning

    **Ne supprimez jamais le service SSH du pare-feu d'un serveur distant !**
    
    Rappelez-vous, SSH est ce que vous utilisez pour vous connecter à votre serveur. Sauf si vous avez un autre moyen d'accéder au serveur physique, ou son shell (c'est à dire via. un panneau de contrôle fourni par l'hôte), la suppression du service SSH vous bloquera définitivement.
    
    Vous devrez soit contacter le support pour récupérer votre accès, soit réinstaller complètement le système d'exploitation.

## Commandes de gestion du service

Pour voir une liste de tous les services disponibles que vous pourriez éventuellement ajouter à votre pare-feu, exécutez :

```bash
firewall-cmd --get-services
```

Pour voir quels services vous avez actuellement actifs sur votre pare-feu, utilisez :

```bash
firewall-cmd --list-services
```

Pour ouvrir un service dans votre pare-feu (par exemple HTTP dans la zone publique), utilisez :

```bash
firewall-cmd --zone=public --add-service=http
```

Pour supprimer/fermer un service sur votre pare-feu, changez simplement un mot à nouveau:

```bash
firewall-cmd --zone=public --remove-service=http
```

!!! Note "Note: Vous pouvez ajouter vos propres services"

    Et personnalisez aussi le coup de foudre de ceux-ci. Cependant, c'est un sujet qui devient complexe. Familiarisez-vous d'abord avec `firewalld` et allez de là.

## Restreindre l'accès

Disons que vous avez un serveur, et que vous ne voulez pas le rendre public. si vous voulez définir juste qui est autorisé à y accéder via SSH, ou voir quelques pages web privées, vous pouvez le faire.

Il y a quelques méthodes pour y parvenir. Premièrement, pour un serveur plus verrouillé, vous pouvez choisir une des zones les plus restrictives, assigner votre périphérique réseau à elle, ajouter le service SSH comme indiqué ci-dessus, puis ajouter votre propre adresse IP publique comme suit:

```bash
firewall-cmd --permanent --zone=trusted --add-source=192.168.1.0 [< insert your IP here]
```

Vous pouvez en faire une plage d'adresses IP en ajoutant un nombre plus élevé à la fin comme suit:

```bash
firewall-cmd --permanent --zone=trusted --add-source=192.168.1.0/24 [< insert your IP here]
```

Encore une fois, il suffit de changer `--add-source` à `--remove-source` pour inverser le processus.

Cependant, si vous gérez un serveur distant avec un site web qui doit être public, et vous ne voulez toujours ouvrir SSH que pour une adresse IP ou une petite gamme d'entre eux, vous avez quelques options. Dans ces deux exemples, la seule interface réseau est affectée à la zone publique.

Tout d'abord, vous pouvez utiliser une "règle riche" dans votre zone publique, et cela ressemblerait à ceci:

```bash
# firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" source address="192.168.1.0/24" service name="ssh" accept'
```

Une fois que la règle riche est en place, *ne faites pas* que les règles soient permanentes. Tout d'abord, retirez le service SSH de la configuration de la zone publique et testez votre connexion pour vous assurer que vous pouvez toujours accéder au serveur via SSH.

Votre configuration devrait maintenant ressembler à ceci:

```bash
your@server ~# firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: wlp3s0
  sources:
  services: cockpit dhcpv6-client
  ports: 80/tcp 443/tcp
  protocols:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
        rule family="ipv4" source address="192. 68.1.0/24" service name="ssh" accepter
```


Deuxièmement, vous pouvez utiliser deux zones différentes à la fois. Si vous avez votre interface liée à la zone publique, vous pouvez activer une seconde zone (la zone "confiée" par exemple) en y ajoutant une IP source ou une plage IP comme indiqué ci-dessus. Ensuite, ajoutez le service SSH à la zone de confiance et retirez-le de la zone publique.

Lorsque vous avez terminé, la sortie devrait ressembler à ceci :

```bash
your@server ~# firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: wlp3s0
  sources:
  services: cockpit dhcpv6-client
  ports: 80/tcp 443/tcp
  protocols:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
your@server ~# firewall-cmd --list-all --zone=trusted
trusted (active)
  target: default
  icmp-block-inversion: no
  interfaces:
  sources: 192. 68.0.0/24
  services : ssh
  ports :
  protocoles :
  en avant : no
  masquerade: no
  ports en avant :
  ports sources:
  blocs icmp:
  règles riches:
```

Si vous êtes bloqué, redémarrez le serveur (la plupart des panneaux de contrôle VPS ont une option pour cela) et réessayez.

!!! Warning

    Ces techniques ne fonctionnent que si vous avez une adresse IP statique.
    
    Si vous êtes bloqué avec un fournisseur de service Internet qui change votre adresse IP chaque fois que votre modem redémarre, n'utilisez pas ces règles (au moins pas pour SSH) jusqu'à ce que vous ayez un correctif pour cela. Vous vous fermerez hors de votre serveur
    
    Soit mettre à niveau votre plan/fournisseur Internet, ou obtenez un VPN qui vous fournit une adresse IP dédiée, et *jamais* jamais* de la perdre.
    
    En attendant, [installer et configurer fail2ban](https://wiki.crowncloud.net/?How_to_Install_Fail2Ban_on_RockyLinux_8), qui peut aider à réduire les attaques par force brute.
    
    Évidemment, sur un réseau local que vous contrôlez (et où vous pouvez définir l'adresse IP de chaque machine manuellement), vous pouvez utiliser toutes ces règles autant que vous le souhaitez.

## Notes Finales

C'est loin d'être un guide exhaustif, et vous pouvez en apprendre beaucoup plus avec la documentation [officielle `` coupe-feu](https://firewalld.org/documentation/). Il y a également des guides pratiques spécifiques à des applications sur Internet qui vous montreront comment configurer votre pare-feu pour ces applications spécifiques.

Pour vous les fans de `iptables` (si vous avez réussi jusqu'ici... , [nous avons un guide](firewalld.md) détaillant certaines des différences dans le fonctionnement de `firewalld` et `iptables`. Ce guide pourrait vous aider à comprendre si vous voulez rester avec `pare-feu` ou retourner à The Old Ways<sup>(TM)</sup>. Il y a quelque chose à dire pour The Old Ways<sup>(TM)</sup>, dans ce cas.

## Conclusion

Et c'est `coupe-feu` en aussi peu de mots que je pourrais le gérer tout en expliquant tous les bases. Prenez-le lent, expérimentez prudemment et ne rendez aucune règle permanente tant que vous ne savez pas qu'elle fonctionne.

Et, vous savez, amusez-vous bien. Une fois que vous avez les bases en bas, mettre en place un pare-feu décent et réalisable peut prendre 5-10 minutes.
