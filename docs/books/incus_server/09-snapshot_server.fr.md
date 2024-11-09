---
title: "Chapitre 9 : Serveur de Snapshot"
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 9.4
tags:
  - incus
  - entreprise
  - serveur de capture instantanée incus
---

Ce chapitre utilise une combinaison de l'utilisateur privilégié (root) et de l'utilisateur non privilégié (incusadmin) en fonction des tâches que vous exécutez.

Comme indiqué au début, le serveur de snapshots Incus doit refléter le serveur de production de toutes les manières possibles. Vous devrez peut-être le mettre en production si le matériel tombe en panne sur votre serveur principal, et disposer de sauvegardes et d'un moyen rapide de redémarrer les conteneurs de production réduit au minimum les appels téléphoniques et les SMS de panique des administrateurs système. C'est toujours une très bonne idée !

Le processus de création du serveur de snapshots est exactement le même que celui du serveur de production. Pour émuler entièrement la configuration de votre serveur de production, répétez les chapitres 1 à 4 sur le serveur de capture instantanée et, une fois terminé, revenez ici à cet endroit.

Si vous êtes ici, vous avez terminé l'installation de base du serveur de snapshots.

## Mise en place de la relation Serveur Primaire et Serveur de Snapshot

Vous avez besoin de quelques ajustements avant de pouvoir continuer. Tout d’abord, si vous travaillez dans un environnement de production, vous avez probablement accès à un serveur DNS pour configurer la résolution IP et le nom.

Dans votre laboratoire, vous ne disposez pas de ce luxe. Peut-être avez-vous le même scénario en cours. Pour cette raison, vous ajouterez les adresses IP et les noms des serveurs au fichier `/etc/hosts` sur le serveur principal et sur le serveur de snapshots. Vous devez le faire en tant qu'utilisateur root (ou avec _sudo_).

Dans votre laboratoire, le serveur Incus principal s'exécute sur 192.168.1.106 et le serveur Incus de snapshot s'exécute sur 192.168.1.141. Connectez-vous à chaque serveur via SSH et ajoutez ce qui suit au fichier `/etc/hosts` :

```bash
192.168.1.106 incus-primary
192.168.1.141 incus-snapshot
```

Ensuite, vous devez autoriser tout le trafic entre les deux serveurs. Pour ce faire, modifiez les règles pour `firewalld`. Ajoutez d'abord cette ligne sur le serveur incus-primary :

```bash
firewall-cmd zone=trusted add-source=192.168.1.141 --permanent
```

Et sur le serveur de snapshots, ajoutez cette règle :

```bash
firewall-cmd zone=trusted add-source=192.168.1.106 --permanent
```

Puis recharger :

```bash
firewall-cmd reload
```

Ensuite, en tant qu’utilisateur non privilégié (incusadmin), vous devez établir une relation de confiance entre les deux machines. Cela se fait en exécutant ce qui suit sur incus-primary :

```bash
incus remote add incus-snapshot
```

Le certificat à accepter s'affiche. Acceptez-le et le système vous demandera votre mot de passe. Il s’agit du « mot de passe de confiance » que vous avez défini lors de l’étape d’initialisation d’Incus. N'oubliez pas de garder une trace sécurisée de tous ces mots de passe. Lorsque vous entrez le mot de passe, vous verrez ceci :

```bash
Client certificate stored at server:  incus-snapshot
```

Il est recommandé de mettre en place aussi l'inverse. Par exemple, la relation de confiance peut également être définie sur le serveur `incus-snapshot`. Si nécessaire, le serveur `incus-snapshot` peut renvoyer des snapshots au serveur `incus-primary`. Répétez les étapes et remplacez `incus-primary` par `incus-snapshot`.

### Migrer votre premier instantané

Avant de migrer votre premier snapshot, vous devez créer tous les profils sur le serveur `incus-snapshot` que vous avez créés sur le serveur
`incus-primary`. Dans ce cas, il s'agit du profil `macvlan`.

Vous devrez créer ceci pour le serveur `incus-snapshot`. Revenez au [Chapitre 6](06-profiles.md) et créez le profil `macvlan` sur `incus-snapshot` si besoin est. Si vos deux serveurs ont les mêmes noms d'interface parent (`enp3s0` par exemple), vous pouvez copier le profil `macvlan` sur incus-snapshot sans le recréer :

```bash
incus profile copy macvlan incus-snapshot
```

Une fois toutes les relations et tous les profils configurés, l’étape suivante consiste à envoyer un snapshot d’`incus-primary` à `incus-snapshot`. Si vous avez suivi exactement, vous avez probablement supprimé tous vos snapshots. Créer un autre instantané :

```bash
incus snapshot rockylinux-test-9 rockylinux-test-9-snap1
```

Si vous exécutez la commande `info` pour `incus`, vous pouvez voir le snapshot en bas de votre liste :

```bash
incus info rockylinux-test-9
```

Ce qui montrera quelque chose comme ça dans la partie inférieure :

```bash
rockylinux-test-9-snap1 at 2021/05/13 16:34 UTC) (stateless)
```

Essayez de migrer votre instantané :

```bash
incus copy rockylinux-test-9/rockylinux-test-9-snap1 incus-snapshot:rockylinux-test-9
```

Cette commande indique que dans le conteneur rockylinux-test-9, vous souhaitez envoyer l'instantané rockylinux-test-9-snap1 à incus-snapshot et le nommer rockylinux-test-9.

Après un court laps de temps, la copie sera terminée. Vous voulez en savoir plus ? Exécutez `incus list` sur le serveur `incus-snapshot`. Qui devrait retourner ce qui suit :

```bash
+-------------------+---------+------+------+-----------+-----------+
|    NAME           |  STATE  | IPV4 | IPV6 |   TYPE    | SNAPSHOTS |
+-------------------+---------+------+------+-----------+-----------+
| rockylinux-test-9 | STOPPED |      |      | CONTAINER | 0         |
+-------------------+---------+------+------+-----------+-----------+
```

Success! Try starting it. Étant donné que vous le démarrez sur le serveur incus-snapshot, vous devez d'abord l'arrêter sur le serveur incus-primary pour éviter un conflit d'adresse IP :

```bash
incus stop rockylinux-test-9
```

Et sur le serveur `incus-snapshot` :

```bash
incus start rockylinux-test-9
```

En supposant que tout cela fonctionne sans erreur, arrêtez le conteneur sur `incus-snapshot` et redémarrez-le sur `incus-primary`.

## Définition de `boot.autostart` sur désactivé `off` pour les conteneurs

Les instantanés copiés sur incus-snapshot seront hors service lors de leur migration, mais si vous avez un événement d'alimentation ou si vous devez redémarrer le serveur d'instantanés en raison de mises à jour ou autre, vous aurez un problème. Ces conteneurs tenteront de démarrer sur le serveur de snapshots, créant ainsi un conflit d'adresse IP potentiel.

Pour éliminer ce problème, vous devez configurer les conteneurs migrés afin qu’ils ne soient pas lancés automatiquement lors d’un redémarrage du serveur. Pour votre conteneur `rockylinux-test-9` nouvellement copié, vous procéderez comme suit :

```bash
incus config set rockylinux-test-9 boot.autostart 0
```

Faites cela pour chaque snapshot sur le serveur `incus-snapshot`. The "0" in the command will ensure that `boot.autostart` is off.

## Automatisation du processus de copie des snapshots

C'est excellent de pouvoir créer des instantanés lorsque cela est nécessaire, et parfois vous avez justement besoin de créer un snapshot manuellement. Vous souhaiterez peut-être même le copier manuellement vers le serveur `incus-snapshot`. Mais pour toutes les autres fois, en particulier pour de nombreux conteneurs exécutés sur votre serveur incus-primary, la **dernière** chose que vous voulez faire est de passer un après-midi à supprimer des instantanés sur le serveur d'instantanés, à créer de nouveaux instantanés et à les envoyer au serveur d'instantanés. Pour l'essentiel de vos opérations, vous souhaiterez automatiser le processus.

Vous devrez planifier un processus pour automatiser la création d'instantanés sur `incus-primary`. Vous ferez cela pour chaque conteneur sur le serveur `incus-primary`. Une fois en place, cette tâche s’occupera de cela à l'avenir. Pour ce faire, la syntaxe suivante est utilisée. Notez les similitudes avec une entrée `crontab` pour l'horodatage :

```bash
incus config set [container_name] snapshots.schedule "50 20 * * *"
```

Cela signifie : faites un instantané du nom du conteneur tous les jours à 20h50.

Pour appliquer ceci à votre conteneur `rockylinux-test-9` :

```bash
incus config set rockylinux-test-9 snapshots.schedule "50 20 * * *"
```

Vous pouvez également configurer le nom de l'instantané pour qu'il corresponde à la date de création. Incus utilise l'UTC partout, donc votre meilleure option pour garder une trace des choses est de définir le nom de l'instantané avec un horodatage dans un format plus compréhensible :

```bash
incus config set rockylinux-test-9 snapshots.pattern "rockylinux-test-9{{ creation_date|date:'2006-01-02_15-04-05' }}"
```

SUPER, mais vous ne voulez certainement pas un nouveau snapshot chaque jour sans vous débarrasser d'un ancien. Vous rempliriez votre disque avec les instantanés. Pour ce faire, tapez ce qui suit :

```bash
incus config set rockylinux-test-9 snapshots.expiry 1d
```
