---
title: GNOME Online Accounts
author: Ezequiel Bruni
contributors: Steven Spencer
---

## Introduction

À première vue, la fonctionnalité de comptes en ligne de GNOME semble modeste, mais elle est plutôt puissante. Les comptes en ligne vous permettent d'accéder en quelques minutes à vos e-mails, tâches, fichiers cloud, calendriers en ligne et bien plus encore depuis vos applications de bureau.

Ce guide rapide vous montrera par où commencer.

## Prérequis

Ce guide suppose que vous disposez de la configuration suivante :

 - Une installation Rocky Linux avec un environnement de bureau GNOME.

## Comment ajouter vos comptes en ligne

Ouvrez l'aperçu des activités GNOME dans le coin supérieur gauche (ou avec la touche ++meta++ ou ++win++) et recherchez les comptes en ligne. Vous pouvez également ouvrir le panneau des paramètres et trouver les comptes en ligne sur la gauche.

Quoi qu'il en soit, vous finirez sur cet écran :

![a screenshot of the GNOME Online Accounts settings panel](images/onlineaccounts-01.png)

!!! note "Remarque"

```
Vous devrez peut-être cliquer sur l'icône à trois points verticaux pour accéder à toutes les options répertoriées ici :

![a screenthot of the Online Accounts panel featuring the three-vertical-dots icon at the bottom](images/onlineaccounts-02.png)
```

Pour ajouter un compte, sélectionnez l'une des options. Pour votre compte Google, vous serez invité à vous connecter à Google avec votre navigateur et à autoriser GNOME à accéder à toutes vos données. Pour les services comme Nextcloud, vous verrez un formulaire de connexion similaire à celui ci-dessous :

![a screenshot showing the login form for Nextcloud](images/onlineaccounts-03.png)

Remplissez les informations pertinentes et GNOME s'occupera du reste.

## Types de comptes pris en charge par GNOME

Comme vous pouvez le constater sur les captures d'écran, Google, Nextcloud, Microsoft, Microsoft Exchange, Fedora, IMAP/SMTP et Kerberos sont pris en charge dans une certaine mesure. Cependant, ces intégrations ne sont pas équivalentes.

Les comptes Google bénéficient du plus grand nombre de fonctionnalités, même si Microsoft Exchange et Nextcloud ne sont pas loin derrière.

Pour qu'il soit plus facile de savoir exactement ce qui est supporté et ce qui ne l'est pas, voici un tableau que l'auteur a volé sans vergogne dans la documentation officielle de GNOME :

| **Fournisseur**    | **Mail** | **Calendrier** | **Contacts** | **Cartes** | **Photos** | **Fichiers** | **Ticketing** |
| ------------------ | -------- | -------------- | ------------ | ---------- | ---------- | ------------ | ------------- |
| Google             | ✅️       | ✅️             | ✅️           |            | ✅️         | ✅️           |               |
| Microsoft          | ✅️       |                |              |            |            |              |               |
| Microsoft Exchange | ✅️       | ✅️             | ✅️           |            |            |              |               |
| Nextcloud          |          | ✅️             | ✅️           |            |            | ✅️           |               |
| IMAP et SMTP       | ✅️       |                |              |            |            |              |               |
| Kerberos           |          |                |              |            |            |              | ✅️            |

!!! note "Remarque"

```
Bien que les « tâches » ne soient pas répertoriées dans le tableau ci-dessus, elles *semblent* être prises en charge, du moins pour Google. Les tests de ce guide ont montré que si vous installez le gestionnaire de tâches Endeavour (disponible via Flathub) sur Rocky Linux et que vous disposez déjà d'un compte Google connecté à GNOME, vos tâches seront importées automatiquement.
```

## Conclusion

Bien que vous puissiez bien-sûr utiliser les variantes d'application Web de certains de ces logiciels ou utiliser des clients tiers dans certains cas, GNOME facilite l'intégration simple de nombreuses fonctionnalités les plus importantes directement dans le bureau. Inscrivez-vous et allez-y.

Si un service est manquant, consultez les [Forums de la communauté GNOME](https://discourse.gnome.org) et faites-le-leur savoir.
