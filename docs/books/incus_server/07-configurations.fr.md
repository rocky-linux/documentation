---
title: "Chapitre 7 : Options de Configuration de Conteneur"
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 9.4
tags:
  - incus
  - entreprise
  - configuration de incus
---

Tout au long de ce chapitre, vous devez exécuter des commandes en tant qu'utilisateur non privilégié (`incusadmin` si vous avez suivi ce guide depuis le début).

Il existe une multitude d'options pour configurer le conteneur une fois que vous l'avez installé. Cependant, avant de les voir, examinons la commande `info` pour un conteneur. Dans cet exemple, nous allons utiliser le conteneur `ubuntu-test` :

```bash
incus info ubuntu-test
```

Cela devrait afficher le résultat suivant :

```bash
Name: ubuntu-test
Location: none
Remote: unix://
Architecture: x86_64
Created: 2021/04/26 15:14 UTC
Status: Running
Type: container
Profiles: default, macvlan
Pid: 584710
Ips:
  eth0:    inet    192.168.1.201    enp3s0
  eth0:    inet6    fe80::216:3eff:fe10:6d6d    enp3s0
  lo:    inet    127.0.0.1
  lo:    inet6    ::1
Resources:
  Processes: 13
  Disk usage:
    root: 85.30MB
  CPU usage:
    CPU usage (in seconds): 1
  Memory usage:
    Memory (current): 99.16MB
    Memory (peak): 110.90MB
  Network usage:
    eth0:
      Bytes received: 53.56kB
      Bytes sent: 2.66kB
      Packets received: 876
      Packets sent: 36
    lo:
      Bytes received: 0B
      Bytes sent: 0B
      Packets received: 0
      Packets sent: 0
```

Il existe de bonnes informations provenant des profils appliqués à la mémoire, à l'espace disque utilisé, etc.

## Un mot sur la configuration et quelques options

Incus attribuera par défaut la mémoire système, l'espace disque, les cœurs de processeur et d'autres ressources requis au conteneur. Mais que faire si vous souhaitez être plus précis ? C'est possible.

Cela implique des compromis. Par exemple, si vous attribuez de la mémoire système et que le conteneur ne l'utilise pas entièrement, vous l'avez bloquée du point de vue d'un autre conteneur qui pourrait en avoir besoin. L’inverse peut également se produire. Si un conteneur souhaite utiliser plus que sa part de mémoire, il peut empêcher les autres conteneurs d'en obtenir suffisamment, réduisant ainsi leurs performances.

N'oubliez pas que chaque action que vous effectuez pour configurer un conteneur _peut_ avoir des effets négatifs ailleurs.

Plutôt que d'exécuter toutes les options de configuration, utilisez l'onglet `auto-complete` pour voir les options disponibles :

```bash
incus config set ubuntu-test
```

et ++tab++.

Ceci vous montre toutes les options de configuration d'un conteneur. Si vous avez des questions sur ce que fait l'une des options de configuration, accédez à la [documentation officielle d'Incus](https://linuxcontainers.org/incus/docs/main/config-options/) et effectuez une recherche sur le paramètre de configuration, ou recherchez sur Google la chaîne entière, telle que par exemple `incus config set boundaries.memory` et examinez les résultats de la recherche.

Ici, nous examinons quelques-unes des options de configuration les plus utilisées. Par exemple, si vous souhaitez définir la quantité maximale de mémoire qu’un conteneur peut utiliser :

```bash
incus config set ubuntu-test limits.memory 2GB
```

Cela signifie que si la mémoire est disponible à l'utilisation, par exemple 2 Go, alors le conteneur peut en réalité utiliser plus de 2 Go. Il s'agit par exemple d'une limite `soft`.

```bash
incus config set ubuntu-test limits.memory.enforce 2GB
```

Cela signifie que le conteneur ne peut jamais utiliser plus de 2 Go de mémoire, qu'elle soit actuellement disponible ou non. Dans ce cas, c'est une limite dure – hard limit.

```bash
incus config set ubuntu-test limits.cpu 2
```

Cela signifie limiter le nombre de cœurs de processeur que le conteneur peut utiliser à 2.

!!! note "Remarque"

```
Lorsque ce document a été réécrit pour Rocky Linux 9.0, le référentiel ZFS pour RL9 n'était pas disponible. Pour cette raison, tous nos conteneurs de test ont été créés en utilisant `dir` dans le processus d'initialisation. C'est pourquoi l'exemple ci-dessous montre un pool de stockage `dir` au lieu d'un pool de stockage `zfs`.
```

Vous vous souvenez du moment où nous avons installé notre réserve de stockage dans le chapitre traitant de ZFS ? Vous avez nommé le pool `storage`, mais vous auriez pu lui donner n’importe quel nom. Si vous souhaitez examiner cela, vous pouvez utiliser cette commande, qui fonctionne aussi bien pour n’importe quel autre type de pool (comme indiqué pour `dir`) :

```bash
incus storage show storage
```

Ceci montre le résultat suivant :

```bash
config:
  source: /var/snap/lxd/common/lxd/storage-pools/storage
description: ""
name: storage
driver: dir
used_by:
- /1.0/instances/rockylinux-test-8
- /1.0/instances/rockylinux-test-9
- /1.0/instances/ubuntu-test
- /1.0/profiles/default
status: Created
locations:
- none
```

Cela montre que tous nos conteneurs utilisent notre pool de stockage `dir`. Lorsque vous utilisez ZFS, vous pouvez également définir un quota de disque sur un conteneur. Voici à quoi ressemblerait cette commande en définissant un quota de disque de 2 Go sur le conteneur ubuntu-rest:

```bash
incus config device override ubuntu-test root size=2GB
```

Comme je l’ai dit précédemment, vous pouvez utiliser les options de configuration avec parcimonie, à moins que vous n’ayez un conteneur qui souhaite utiliser plus de ressources que sa part propre. Incus, pour la plupart, gérera efficacement l’environnement.

Il y a bien sûr beaucoup plus d'options qui pourraient intéresser certains. Faire vos propres recherches vous aidera à déterminer si l’un d’entre eux est utile dans votre environnement.
