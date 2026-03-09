---
title: Directives à l'intention des nouveaux contributeurs
author: Krista Burdine
contributors: Ganna Zhyrnova, Ézéchiel Bruni, Steven Spencer
tags:
  - contribution
  - documentation
  - débutants
  - howto
---

# Directives à l'intention des nouveaux auteurs et contributeurs

*Everybody starts somewhere. Si c'est la première fois que vous contribuez à la documentation open source sur GitHub, félicitations pour cette initiative. On a hâte de voir ce que vous avez à dire ! Pour de meilleurs résultats, lisez [notre guide de style](style_guide.md) qui comprend plusieurs autres liens vers des documents pour vous aider à apprendre les meilleures pratiques en matière de documentation.</p>

## Git et GitHub

Toutes les instructions dans ce document supposent que vous ayez un compte GitHub. Si vous n'avez pas encore de compte GitHub, le moment est venu. Si vous avez 17 minutes, apprenez les bases de GitHub avec le [Guide du débutant vers Git et GitHub](https://www.udacity.com/blog/2015/06/a-beginners-git-github-tutorial.html) d'Udemy.

Vous ne commencerez pas à créer et à gérer des dépôts pour Rocky Linux mais ce tutoriel [Hello World](https://docs.github.com/en/get-started/quickstart/hello-world) vous guidera à travers la création d'un compte `GitHub`, l'apprentissage du jargon et la compréhension du fonctionnement des dépôts. Concentrez-vous sur la façon de faire et de valider des mises à jour de la documentation existante et sur la façon de créer un Pull Request.

## Markdown

Markdown est un langage simple qui permet d'inclure du formatage, du code et du texte brut dans un même fichier. La première fois que vous mettez à jour un document, il suffit de s'orienter au code existant. Il ne faudra pas attendre beaucoup avant d’être prêt à explorer d’autres fonctionnalités. Le moment venu, voici les éléments de base.

- [Markdown de base](https://www.markdownguide.org/basic-syntax#code)
- [Extended Markdown](https://www.markdownguide.org/extended-syntax/#fenced-code-blocks)
- Quelques unes des options plus avancées de [formatage](https://docs.rockylinux.org/guides/contribute/rockydocs_formatting/) que nous utilisons dans notre dépôt

## Éditeur du dépôt local

Pour créer un dépôt local, il faut d'abord trouver et installer un éditeur Markdown qui fonctionne avec votre ordinateur et votre système d'exploitation. Voici quelques options, mais il y en a d'autres. Utilisez ce que vous maîtrisez.

- [ReText](https://github.com/retext-project/retext) - Libre, multiplateforme et open source
- [Zettlr](https://www.zettlr.com/) - Libre, multiplateforme et open source
- [MarkText](https://github.com/marktext/marktext) - Libre, multiplateforme et open source
- [Remarkable](https://remarkableapp.github.io/) - Linux et Windows, open source
- [NvChad](https://nvchad.com/) pour l'utilisateur vi/vim et le client nvim. De nombreux plugiciels sont disponibles pour améliorer l'éditeur de markdown. Voir [ce document](https://docs.rockylinux.org/books/nvchad/) pour consulter un ensemble d'instructions d'installation.
- [VS Code](https://code.visualstudio.com/) - Partiellement open source, de Microsoft. VS Code est un éditeur léger et puissant disponible sous Windows, Linux et macOS. Pour contribuer à ce projet de documentation, vous devriez installer les extensions suivantes : Git Graph, HTML Preview, HTML Snippets, Markdown All in One, Markdown Preview Enhanced, Markdown Preview Mermaid Support et tout ce dont vous avez besoin.

## Créer un dépôt local

Une fois que vous avez installé un éditeur Markdown, suivez les instructions pour le connecter à votre compte GitHub et télécharger votre dépôt sur votre machine locale. Chaque fois que vous vous apprêtez à mettre à jour un document, suivez ces étapes pour synchroniser vos copies locales et en ligne avec la branche principale afin de vous assurer que vous travaillez avec la version la plus récente :

1. Dans GitHub, synchronisez votre fork du dépôt de documentation avec la branche principale.
2. Suivez les instructions de votre éditeur Markdown pour synchroniser votre fork actuel avec votre machine locale.
3. Dans votre éditeur Markdown, ouvrez le document que vous voulez modifier.
4. Modifiez le document.
5. Enregistrez.
6. Validez vos modifications dans votre éditeur, ce qui devrait synchroniser votre dépôt local avec votre fork en ligne.
7. Sur GitHub, trouvez le document mis à jour dans votre fork et créez une requête PR pour la fusionner avec le document principal.

## Soumettre une mise à jour

*Ajouter un mot manquant, corriger une erreur ou clarifier un peu de texte.*

1. Commencez par la page que vous souhaitez mettre à jour.

    Cliquez sur l'icône `Edit` (un crayon) située dans le coin supérieur droit du document que vous souhaitez mettre à jour. Cela vous redirigera vers le document original sur GitHub.

    La première fois que vous contribuez au référentiel Rocky Linux (RL), vous verrez une invite avec un bouton vert pour `**Fork** this **repository** and propose changes`. Cela crée une copie dupliquée du dépôt RL dans laquelle vous effectuez vos modifications suggérées. Cliquez sur le bouton vert et continuez.

2. Effectuez vos modifications

    Veuillez suivre le formatage de Markdown. Il manque peut-être un mot, ou vous devez corriger le lien à la ligne 21, par exemple. Effectuez les modifications nécessaires.

3. Proposer des modifications

    Au bas de la page, inscrivez une brève description dans le titre du bloc intitulé, **"Propose changes”**. Il est utile, mais pas nécessaire, de faire référence au nom du fichier qui est en haut du document.

    Si vous avez mis à jour un lien à la ligne 21 du texte Markdown, vous pourriez indiquer, `Update README.md with correct links`.

    **Remarque : formulez votre action au temps présent.**

    Cliquez ensuite sur `Propose Changes`, ce qui enregistrera – **commit** – vos modifications dans un document complet au sein de votre dépôt dupliqué.

4. Revoir les modifications

    Vous pouvez maintenant examiner vos modifications, ligne par ligne. Avez-vous raté quelque chose ? Retournez à la page précédente et corrigez-la à nouveau (vous devrez recommencer), puis cliquez, `Propose Changes`.

    Une fois que le document vous convient, cliquez sur le bouton vert qui indique `Create Pull Request`. Cela vous donne une chance supplémentaire de vérifier vos modifications et de confirmer que le document est prêt.

5. Création de Pull Request (PR)

    Vous avez terminé tout votre travail jusqu'à présent dans votre propre dépôt, sans aucun risque de casser le référentiel principal RL. Ensuite, vous la soumettez à l'équipe de documentation pour qu'elle intègre votre version à la version principale du document.

    Cliquez sur le gros bouton vert qui indique `Create Pull Request`. Bonne nouvelle, vous n'avez encore rien cassé, et le résultat est maintenant transmis à l'équipe de documentation RL pour passage en revue.

6. Veuillez patienter

    Une fois que l'équipe RL aura reçu votre demande PR, elle vous répondra de l'une des trois manières suivantes.

    - Accepter et fusionner votre PR
    - Commenter votre requête et demander des modifications
    - Refus de PR avec explication

    La dernière réponse est moins probable. Nous voulons vraiment inclure votre point de vue ici ! Si vous devez faire des changements, vous comprendrez soudainement pourquoi vous avez besoin d'un dépôt local. L'équipe peut [vous expliquer](https://chat.rockylinux.org/rocky-linux/channels/documentation) comment procéder ensuite. La bonne nouvelle, c’est toujours facile à maintenir. Si vous devez ajouter ou modifier votre demande de fusion PR, un membre de l'équipe l'ajoutera à la section des commentaires.

    Sinon, l'équipe acceptera votre demande de PR et la fusionnera. Bienvenue dans l'équipe, vous êtes maintenant officiellement un contributeur ! Votre nom devrait apparaître dans la liste de tous les contributeurs, au bas du « Guide du contributeur », d'ici quelques jours.
