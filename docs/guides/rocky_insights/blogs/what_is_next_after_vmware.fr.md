---
title: VMware, et après ?
author: Antoine Le Morvan
contributors:
tags:
  - virtualisation
  - VMware
  - Open Source
---

Depuis l'acquisition de VMware par Broadcom, le secteur de la virtualisation a connu des changements importants, notamment en ce qui a trait à la tarification des licences. La nouvelle politique tarifaire de Broadcom (ceci n'est pas un jugement de valeur) a entraîné des augmentations de coûts substantielles, notamment pour les petites et moyennes entreprises utilisant VMware. En raison de cela, de nombreuses organisations ont été incitées à reconsidérer leurs choix technologiques.

Ces ajustements de prix ont poussé les entreprises concernées à explorer des solutions de rechange, notamment des solutions Open Source.

Cet article vise à démontrer la faisabilité, les avantages et les performances d'une solution de virtualisation basée sur des technologies libres, offrant une alternative viable à VMware.

L'auteur tient à préciser que ni lui ni l'équipe de documentation n'ont de lien avec les solutions qui seront mentionnées ci-dessous.

## Quelles fonctionnalités sont à attendre ?

Avant de commencer à discuter des solutions disponibles sur le marché, prenons un moment pour parler des fonctionnalités auxquelles on peut s'attendre d'une solution de virtualisation.

Un point important qui est revenu à maintes reprises dans de nombreuses discussions sur ce sujet, et qui est souvent négligé au départ, est la sauvegarde des données. Le facteur déterminant dans le choix d'une solution sera : cette solution dispose-t-elle d'une solution de sauvegarde robuste ? L'auteur indiquerait même si une solution comme Veeam Backup, que vous utiliseriez déjà et que vous ne voulez pas changer (pour des raisons de coût, de connaissances acquises ou de sécurité), est prise en charge par le logiciel actuel de l'auteur.

Parmi les autres caractéristiques à considérer :

- Sauvegarde et restauration, captures instantanées – `snapshots` – de machines virtuelles
- conteneurisation et/ou Kubernetes intégrés
- bases de données gérées
- IAAS : VPC, virtualisation du réseau et portail libre-service
- Maturité de l'intégration DevOps (Terraform, Ansible) - API
- Stockage d'objets S3 (Ceph...)
- VPN intégré (en particulier site à site)
- Groupes de sécurité (pare-feu virtuel)
- IPAM, DHCP géré, répartition de charge, SNAT
- Surveillance

Certaines solutions proposent aussi :

- Migration intégrée de VMware

## Choix de l'hyperviseur

Avant d’examiner les solutions existantes, penchons-nous sur le choix de l’hyperviseur parmi ceux disponibles :

- **ESXi**, l'hyperviseur de VMware. Si cette option est envisagée, elle simplifiera probablement la migration.
- **KVM (QEMU/libvirt)** : intégré au noyau, il s’agit de l’une des solutions open source les plus avancées en termes de fonctionnalités et est largement utilisé.
- **Xen (XCP-ng)** : le successeur de Citrix. Il s'agit d'un hyperviseur robuste et ancien qui peut encore présenter une certaine dette technique, mais qui semble être en développement actif et qui devrait bientôt rattraper son retard.
- **AHV (Nutanix)** : nous nous éloignons ici des solutions libres, mais nous parlerons de Nutanix plus tard.
- **Hyper-V** : il convient également de le mentionner car, bien qu’il s’agisse d’une solution propriétaire, de nombreuses petites entreprises peuvent opter pour Microsoft si ses prix sont inférieurs à ceux des offres de VMware.

Parmi les fonctionnalités auxquelles vous pouvez vous attendre d'un hyperviseur, vous voudrez peut-être vérifier :

- ajout à chaud de processeur et de mémoire vive aux systèmes invités
- Ajouter ou redimensionner à chaud des disques sur les systèmes invités
- migration en direct au sein ou entre les grappes
- migration du stockage en direct

À ce stade, comparer les hyperviseurs est délicat, car la plupart incluent généralement toutes ces fonctionnalités. Le choix dépend vraiment du type de gestionnaire que vous sélectionnez.

## Choix du gestionnaire

Nous en venons maintenant au cœur du sujet : choisir le gestionnaire de vos rêves. Qui sera le grand gagnant, le remplaçant idéal de votre fidèle vSphere ? Celui qui gérera de manière transparente les systèmes invités sur l'hyperviseur le plus approprié ?

### Fonctionnalités

Commençons par parler des caractéristiques de ces solutions, ce qui vous aidera à affiner vos options et à mettre en place des preuves de concept pour faciliter votre choix final.

Un gestionnaire doit fournir :

- Gestion de grappe : haute disponibilité (HA), maintenance des nœuds, etc.
- Portail libre-service : bienvenue dans le monde moderne du nuage privé et de l’infrastructure en tant que service
- virtualisation de réseau (SDN), VPC
- Gestion des API
- prise en charge des outils DevOps (Terraform, Ansible, Puppet, etc.)
- migration entre les grappes

### Solutions existantes

Dans cette section, l'auteur n'abordera pas les solutions exclusives comme Hyper-V ou Nutanix. L'auteur mentionne simplement que Nutanix offre de nombreuses fonctionnalités pour concurrencer VMware, et qu'il dispose d'un soutien professionnel réactif. Cela semble toujours être une solution plus coûteuse que de soutenir les solutions que l'auteur présentera ci-dessous, mais il vous laisse le soin de comparer les prix.

Selon l'auteur, **OpenStack** est la solution la plus avancée pour remplacer un système comme vSphere. Soutenu par de nombreux fournisseurs, il constitue la base de nombreux clouds publics. Mais c'est aussi la plus complexe à mettre en œuvre. Oubliez OpenStack si vous n'avez pas une équipe d'ingénieurs Linux compétents et disposant du temps nécessaire pour s'y consacrer. Mais si vous pouvez y consacrer ce temps, c'est la solution qu'il vous faut. Envisagez de vous tourner vers des solutions dérivées comme **Virtuozzo** pour obtenir de l'aide, ou vers des fournisseurs comme RedHat et Suse.

Puisque l'auteur a mentionné pour la première fois **OpenStack**, il se doit de poursuivre avec celui qu'il privilégie depuis longtemps : le célèbre projet de haut niveau de la Fondation Apache (rien de moins), **CloudStack**. Avec des fonctionnalités similaires à OpenStack, il offre tout ce qui est nécessaire pour configurer un portail nuagique privé, y compris la prise en charge VPC, la virtualisation du réseau, l'équilibrage de charge et même les grappes **Kubernetes**, le tout au sein d'un portail libre-service bien conçu. Il s'agit d'une application Java distribuée sous forme de paquet rpm ou deb, et son installation est simple. La partie la plus complexe consiste à configurer les commutateurs virtuels sur les hôtes (RockyLinux est pris en charge), mais rien d'insurmontable. Les hôtes peuvent être KVM, Xen, Hyper-V ou ESXi, et Proxmox est maintenant pris en charge. Comme mentionné précédemment, CloudStack est l'une des rares solutions permettant la migration directe des machines virtuelles invitées depuis vSphere via l'interface utilisateur. Derrière CloudStack, on trouve un acteur actif, ShapeBlue, qui offre du soutien aux entreprises. En termes d'évolutivité, il existe des instances CloudStack avec plus de 35 000 hôtes, ce qui témoigne d'une solide capacité d'adaptation.

L'auteur évoquera ensuite Proxmox, la solution open source qui devrait conquérir la plus grande part de marché dans ce domaine. Basé sur Debian (pas de RockyLinux ici ^^), l'auteur doit admettre qu'après avoir lu le guide d'administration bien fait, il a été impressionné par les fonctionnalités (IPAM, virtualisation du réseau, gestion du stockage, prise en charge des conteneurs et surtout intégration du stockage Ceph). Proxmox offre une solution de sauvegarde intégrée avec la possibilité d'effectuer des sauvegardes externes, ainsi qu'une nouvelle solution de gestion de centre de données (pour la gestion de plusieurs grappes Proxmox). Si vous n'avez pas besoin d'un portail libre-service comme celui proposé par CloudStack, que vous privilégiez un modèle hyperconvergé (le stockage est distribué entre les hôtes et non sur un SAN/NAS dédié) et que votre parc informatique se limite à quelques centaines de machines virtuelles, alors Proxmox est probablement le choix idéal.

Enfin, il convient de mentionner Vates et XCP-ng, qui sont basés sur l'hyperviseur Xen et l'interface d'administration web Xen Orchestra. Selon l'auteur, il s'agit de solutions à suivre de près, car elles reposent sur des bases solides et font l'objet d'un développement actif (Vates est développé par une entreprise française). Notez cependant que chez Vates, vous devrez dépenser davantage pour accéder au stockage hyperconvergé (XOSTOR) ou aux solutions de sauvegarde (XO Proxy).

### Contrôle des coûts

Cet article traitant des augmentations de coûts dues aux changements de licence de Broadcom, il serait erroné de la part de l'auteur de ne pas aborder les aspects financiers d'un changement de solution.

Outre le coût du soutien, auquel vous voudrez probablement souscrire si vous avez un modèle d'affaires, il est également essentiel de prendre en compte le coût total (TCO), qui comprend :

- le coût de l'assistance,
- les frais de maintenance,
- les frais de mise à jour,
- former vos équipes et le temps nécessaire à l'intégration de la solution,
- le temps consacré à la migration.

### Support et communauté

Le dernier point à prendre en compte, qui peut souvent s'avérer déterminant, est le soutien apporté à la fois par une entreprise et par une communauté active. Avoir accès à une équipe d'assistance réactive peut être rassurant, tout comme la possibilité de compter sur une communauté solide pour obtenir des conseils et résoudre les problèmes. Il est toutefois important de noter qu'un manque d'activité communautaire ou un soutien insuffisant peuvent constituer un inconvénient majeur.

## Conclusion

Ce court article a permis à l'auteur de présenter les solutions les plus importantes disponibles sur le marché, et comme vous pouvez le constater, la décision n'est pas facile. Tout dépend de la capacité de votre équipe à gérer l'outil, votre solution de sauvegarde, les fonctionnalités dont vous avez besoin, votre maîtrise des outils DevOps et les approches infonuagiques natives, ainsi que du volume d'invités à gérer.

Bien que l'auteur ait depuis longtemps une préférence pour CloudStack, ce projet Apache reste relativement méconnu (Apache ne fait pas la promotion de ses projets comme d'autres fournisseurs) et l'auteur vous recommande fortement de le prendre en considération dans votre décision. Proxmox et Vates sont également d'excellentes solutions pour les petites entreprises ou même pour les besoins plus importants avant de passer à une solution basée sur OpenStack (ou OpenShift).

L'auteur espère que ce bref aperçu vous fera gagner du temps dans votre recherche d'une solution de rechange pour VMware.
