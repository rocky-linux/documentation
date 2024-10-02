---
title: "Chapitre 8 : Snapshots de Conteneur"
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 9.4
tags:
  - incus
  - entreprise
  - incus snapshots
---

Tout au long de ce chapitre, vous devez exécuter des commandes en tant qu'utilisateur non privilégié (`incusadmin` si vous avez suivi ce guide depuis le début).

Les instantanés de conteneurs et un serveur d'instantanés (plus d'informations plus tard) sont les aspects les plus critiques de l'exécution d'un serveur Incus de production. Les instantanés assurent une récupération rapide. C'est une bonne idée de les utiliser comme mesure de sécurité lors de la mise à jour du logiciel principal qui s'exécute sur un conteneur particulier. Si quelque chose se produit pendant la mise à jour qui interrompt cette application, il vous suffit de restaurer l'instantané et vous êtes de nouveau opérationnel avec seulement quelques secondes d'indisponibilité.

L'auteur a utilisé des conteneurs Incus pour des serveurs publics PowerDNS, et la mise à jour de ces applications est devenue moins problématique, grâce à la prise d'instantanés avant chaque mise à jour.

Vous pouvez même faire un Snapshot d'un conteneur pendant qu'il est en cours d'exécution.

## Le processus de capture instantanée Snapshot

Nous commencerons par obtenir un instantané du conteneur ubuntu-test en utilisant cette commande :

```bash
incus snapshot ubuntu-test ubuntu-test-1
```

Ici, vous appelez l'instantané `ubuntu-test-1`, mais vous pouvez l'appeler comme vous le souhaitez. Pour vous assurer que vous disposez de l'instantané, effectuez une `incus info` du conteneur :

```bash
incus info ubuntu-test
```

Vous avez déjà observé un écran d'information. Si vous faites défiler l'écran jusqu'en bas, vous voyez maintenant :

```bash
Snapshots:
  ubuntu-test-1 (taken at 2021/04/29 15:57 UTC) (stateless)
```

Success! Notre snapshot est en place.

Allez dans le conteneur de ubuntu-test :

```bash
incus shell ubuntu-test
```

Créez un fichier vide avec la commande _touch_ :

```bash
touch this_file.txt
```

Quitter le conteneur.

Avant de restaurer le conteneur tel qu'il était avant la création du fichier, le moyen le plus sûr de restaurer un conteneur, surtout s'il y a eu de nombreuses modifications, est de l'arrêter d'abord :

```bash
incus stop ubuntu-test
```

Restaurez-le :

```bash
incus restore ubuntu-test ubuntu-test-1
```

Redémarrer le conteneur :

```bash
incus start ubuntu-test
```

Si vous revenez au conteneur et regardez, le fichier `this_file.txt` que vous avez créé a disparu.

Lorsque vous n’avez plus besoin d’un instantané, vous pouvez le supprimer :

```bash
incus delete ubuntu-test/ubuntu-test-1
```

!!! warning "Avertissement"

````
Vous devez supprimer définitivement les instantanés pendant que le conteneur est en cours d'exécution. Pourquoi ? Eh bien, la commande _incus delete_ fonctionne également pour supprimer l'intégralité du conteneur. Si nous appuyons accidentellement sur `Enter` après « ubuntu-test » dans la commande ci-dessus, ET si le conteneur a été arrêté, le conteneur serait supprimé. L'auteur veut juste vous faire savoir qu'aucun avertissement n'est donné. Il fait simplement ce que vous demandez.

Si le conteneur est en cours d'exécution, cependant, vous obtiendrez ce message :

```
Error: The instance is currently running, stop it first or pass --force
```

Supprimez donc toujours les instantanés pendant que le conteneur est en cours d'exécution.
````

Dans les chapitres qui suivent, vous allez :

- mettre en place un processus de création automatique d'instantanés
- set up the expiration of a snapshot so that it goes away after a certain length of time
- configurer l'actualisation automatique des instantanés – `auto-refreshing` — sur le serveur de Snapshots
