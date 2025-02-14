---
title: Démonstration de Markdown
author: Steven Spencer
contributors: Wale Soyinka, Tony Guntharp
tested_with: 8.5
tags:
  - exemple
  - crowdin
  - markdown
---

# Introduction

## Arrière-plan

- Utilisation de [Markdown](https://daringfireball.net/projects/markdown).
- Connaissance de `markdown`.

Ce guide présente les balises Markdown populaires utilisées sur [https://docs.rockylinux.org](https://docs.rockylinux.org) et inclut les `admonition`s, qui ne font pas partie des balises Markdown standard.

## La démonstration

> Ceci est un exemple de citation. Joliment formaté.

Parfois, vous verrez des choses comme _ceci_.

Que diriez-vous d'un peu de **caractères gras**

La plupart du temps, il s'agit simplement de texte comme celui-ci.

Parfois, vous devez indiquer une `commande`

Ou des commandes multiples :

```bash
dnf install my_stapler
dnf update my_pencil
dnf remove my_notepad
systemctl enable my_stapler
```

À d’autres moments, vous aurez besoin de listes à puces ou numérotées :

- Je crois que vous avez mon agrafeuse
- A bien y penser, je n'arrive même pas à trouver ma boussole
- Si ce n'est pas le cas, veuillez au moins me rendre mon crayon
- J'en ai vraiment besoin

1. Je ne savais pas que tu en avais besoin
2. Voici votre crayon cassé
3. Inutile de le tailler

Et vous pourriez avoir besoin d'une `admonition` :

### Admonitions

Les `admonition`s sont un excellent choix pour inclure du contenu annexe sans interrompre de manière significative le flux du document. Le matériel pour MkDocs fournit plusieurs types d'`admonition`s et permet l'inclusion et l'imbrication de contenu arbitraire.

!!! tip "Astuce"

    Pencils and staplers are old-school.

#### Usage

Les `admonition`s possèdent une syntaxe simple : un bloc commence par `!!!`, suivi d'un mot-clé utilisé comme qualificatif de type. Le contenu du bloc continue sur la ligne suivante, indenté de quatre espaces :

!!! note "Remarque"

    Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla et euismod
    nulla. Curabitur feugiat, tortor non consequat finibus, justo purus auctor
    massa, nec semper lorem quam in massa.

#### Modification du titre

Par défaut, le titre sera égal au qualificatif du type. Cependant, il peut être modifié en ajoutant une chaîne entre guillemets contenant du Markdown valide (incluant les liens, le formatage, ...) après le qualificatif de type :

!!! note "Phasellus posuere in sem ut cursus"

    Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla et euismod
    nulla. Curabitur feugiat, tortor non consequat finibus, justo purus auctor
    massa, nec semper lorem quam in massa.

La plupart du temps, lorsqu'une commande propose plusieurs options ou que vous devez répertorier des détails, vous souhaiterez peut-être utiliser un tableau pour identifier les éléments :

| Outil    | Utiliser                                            | Notes techniques de version                                                       |
| -------- | --------------------------------------------------- | --------------------------------------------------------------------------------- |
| crayon   | écriture ou impression                              | souvent remplacé par un stylo                                                     |
| stylo    | écriture ou impression                              | souvent remplacé par un stylet                                                    |
| stylus   | écriture ou impression sur un appareil électronique | parfois remplacé par un clavier                                                   |
| keyboard | écriture ou impression sur un appareil électronique | jamais remplacé - utilisé jusqu'à ce que les miettes de nourriture soient pleines |
| notepad  | prendre des notes                                   | remplacer une mémoire parfois défectueuse                                         |
