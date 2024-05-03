---
title: Création de paquets et dépannage
---

!!! danger "Danger"

Cet article a été rédigé au début de l'année 2021, lors du démarrage du projet Rocky Linux. Le contenu de cette page est conservé pour des raisons historiques, mais a été légèrement modifié pour corriger des liens, fournir un contexte ou supprimer des instructions qui ne sont plus pertinentes afin d'éviter toute confusion. Ce document sera archivé.

# Familiarisez-vous d'abord avec l'outil de construction Mock

Une fois cette étape franchie, la page technique/intro la plus importante et la plus pertinente pour notre effort de débogage des paquets est la suivante :

[https://wiki.rockylinux.org/archive/legacy/mock_building_guide/](https://wiki.rockylinux.org/archive/legacy/mock_building_guide/)

Nous utilisons le programme « mock » pour réaliser nos constructions, tout comme le fera la véritable infrastructure de Rocky. Vous devriez l'installer et vous familiariser avec. Veuillez utiliser ce guide pour commencer, et expliquer un peu ce que nous espérons réaliser et pourquoi nous devons construire tous ces paquets dans un ordre spécifique.

Veuillez les lire attentivement et peut-être vous mettre à l'eau en alimentant votre simulateur avec un ou deux SRPM et en compilant quelques éléments.

Mock est vraiment génial, car c'est un programme facile à appeler qui construit un système entier à l'intérieur d'un chroot pour effectuer la construction, et qui le nettoie ensuite.

Veuillez utiliser les configurations de simulation pour Rocky Linux fournies par le paquet `mock` dans EPEL.

## Intro - Ce qu'il faut faire

Le domaine dans lequel nous avons le plus besoin d'aide en ce moment, et la façon la plus simple de contribuer, est d'aider à dépanner les paquets qui échouent.

Nous reconstruisons CentOS 8.3 en tant que "pratique", afin de pouvoir résoudre à l'avance les problèmes qui pourraient survenir avec notre version officielle de Rocky. Nous documentons toutes les erreurs que nous trouvons dans les paquets et la manière de les corriger (pour qu'ils soient construits). Cette documentation aidera notre équipe d'ingénieurs en charge des versions lorsqu'il s'agira d'effectuer des constructions officielles.

## Contribuer à l'effort de débogage

Une fois que vous êtes familiarisé avec Mock, et en particulier avec le débogage de sa sortie, vous pouvez commencer à examiner les paquets défaillants. Certaines de ces informations se trouvent également sur la page "HowTo" de la simulation, dont le lien figure ci-dessus.

Faites savoir aux autres débogueurs sur quoi vous travaillez ! Nous ne voulons pas multiplier les efforts. Allez sur chat.rockylinux.org (canal #dev/packaging) et dites-nous ce que vous en pensez !

Préparez votre programme fictif avec les configurations les plus récentes que nous utilisons (lien ci-dessus). Vous pouvez l'utiliser pour tenter la construction de la même manière que nous (avec des dépendances externes, des dépôts supplémentaires, etc.)

Enquêter sur l'erreur ou les erreurs.

Déterminez ce qui se passe et comment y remédier. Elle peut prendre la forme de paramètres spéciaux de simulation ou d'un correctif ajouté au programme + fichier de spécifications. Signalez vos découvertes sur le canal #Dev/Packaging, et quelqu'un les enregistrera sur la page Wiki Package_Error_Tracking dont le lien figure ci-dessus.

L'idée est de réduire la page Build Failures et de développer la page Package_Error_Tracking. Si nécessaire, nous intégrerons des correctifs à notre dépôt de correctifs pour les différents paquets situé ici : <https://git.rockylinux.org/staging/patch>.
