---
title: Politique de contribution assistée par l'IA
authors: Wale Soyinka, Steven Spencer, Documentation Team
contributors: Steven Spencer, Ganna Zhyrnova
---

!!! note

    La politique de contribution assistée par l'IA de ce projet de documentation Rocky Linux est basée sur et étend la [politique de contribution assistée par l'IA](https://docs.fedoraproject.org/en-US/council/policy/ai-contribution-policy/) développée par le projet Fedora. Ce document et les directives contenues sont susceptibles de modifications et de révisions.

Vous êtes autorisé à utiliser l'assistance de l'IA pour vos contributions au projet de documentation Rocky Linux, à condition de respecter les principes énoncés ci-dessous.

## Responsabilité et traçabilité

- Vous _DEVEZ_ assumer la responsabilité de votre contribution.
- Toute personne contribuant à Rocky Linux garantit la qualité, le respect des conditions de la licence et l'utilité de sa contribution.
- Toutes les contributions, qu’elles proviennent d’un auteur humain ou soient assistées par de grands modèles de langage (LLM) ou d’autres outils d’IA générative, doivent répondre aux normes d’inclusion du projet.
- Le contributeur est toujours l'auteur et assume l'entière responsabilité du contenu de ses contributions.

## Transparence

- Vous _DEVEZ_ divulguer l'utilisation d'outils d'IA si la partie substantielle de la contribution provient sans modification d'outil logiciel.
- Vous _DEVEZ_ divulguer les autres utilisations des outils d'IA, là où ils pourraient s'avérer utiles.
- L'utilisation habituelle d'outils pour corriger la grammaire et l'orthographe ou pour clarifier les formulations ne nécessite pas de déclaration. Les informations relatives à l'utilisation des outils d'IA nous aideront à évaluer leur impact, à développer de nouvelles pratiques exemplaires et à adapter les processus existants. Les auteurs font des déclarations là où ils indiquent normalement leur contribution en tant qu'auteurs.
- Pour les contributions suivies dans Git, il est recommandé d'utiliser un pied de page de message de commit avec le préfixe `Assisted-by:`.
- Les contributions de tiers doivent inclure une note correspondante dans le préambule du document ou dans une autre section des métadonnées du document.

Exemples :

  ```text
  ---
  title: 
  author: Steven Spencer
  contributors: Ganna Zhyrnova, Colussi Franco, tianci li, Wale Soyinka 
  ai-contributors: Claude (claude-sonnet-4-20250514), Gemini (gemini-2.5-pro)
  ---
  ```

## Contribution et évaluation de la communauté

- Les outils d'IA peuvent être utilisés pour aider les reviewers humains en fournissant des analyses et des suggestions.
- Vous ne devez _PAS_ utiliser l'IA comme seul ou dernier arbitre pour porter un jugement substantiel ou subjectif sur une contribution, ni pour évaluer la position d'une personne au sein de la communauté (par exemple, pour le financement, les rôles de direction ou les questions relatives au code de conduite).
- Cela n’exclut pas l’utilisation d’outils automatisés pour la validation technique objective, comme les pipelines CI/CD, les tests automatisés ou les filtres anti-spam.
- La responsabilité finale de l'acceptation d'une contribution, même si celle-ci est effectuée par un système automatisé, incombe toujours au contributeur humain qui autorise l'action.

## Initiatives à grande échelle

Cette directive ne couvre pas les initiatives de grande envergure susceptibles de modifier considérablement le fonctionnement du projet ou d'entraîner une croissance exponentielle des contributions dans certaines parties du projet. Ces initiatives devraient être discutées séparément avec la direction du projet.

## Respect des contributions existantes

- Vous _NE DEVRIEZ PAS_ soumettre du contenu généré par IA qui est principalement dérivé du travail d'autres participants ou qui le remanie substantiellement.
- Les modifications automatisées par l'IA _DOIVENT_ préserver l'intention originale de l'auteur, le style et la structure du texte.

Les préoccupations concernant d'éventuelles violations de politique doivent être signalées comme [problème via ce lien](https://github.com/rocky-linux/documentation/issues)

Les mots-clés `MAY`, `MUST`, `MUST NOT` et `SHOULD` dans ce document ou dans le document original doivent être interprétés conformément à la description du lien suivant : <https://datatracker.ietf.org/doc/html/rfc2119>[RFC 2119].
