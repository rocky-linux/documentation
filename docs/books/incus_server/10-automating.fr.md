---
title: "Chapitre 10 : Automatisation des Snapshots"
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 9.4
tags:
  - incus
  - entreprise
  - incus automation
---

Tout au long de ce chapitre, vous devez être l'utilisateur root ou pouvoir utiliser `sudo` pour obtenir les privilèges nécessaires.

Automatiser le processus de capture instantanée rend les choses beaucoup plus faciles.

## Automatisation du processus de copie des snapshots

Effectuez cette procédure sur incus-primary. La première chose que nous devons faire est de créer un script qui sera exécuté par cron dans /usr/local/sbin et appelé `refresh-containers` :

```bash
sudo vi /usr/local/sbin/refreshcontainers.sh
```

Le script est plutôt simple :

```bash
#!/bin/bash
# This script is for doing an lxc copy --refresh against each container, copying
# and updating them to the snapshot server.

for x in $(/var/lib/snapd/snap/bin/lxc ls -c n --format csv)
        do echo "Refreshing $x"
        /var/lib/snapd/snap/bin/lxc copy --refresh $x incus-snapshot:$x
        done

```

Rendre le script exécutable :

```bash
sudo chmod +x /usr/local/sbin/refreshcontainers.sh
```

Modifiez la propriété de ce script en l'assignant à votre utilisateur et groupe `incusadmin` :

```bash
sudo chown incusadmin.incusadmin /usr/local/sbin/refreshcontainers.sh
```

Configurez le crontab pour que l'utilisateur `incusadmin` exécute ce script, dans le cas de notre exemple à 22h :

```bash
crontab -e
```

Votre entrée ressemblera à ceci :

```bash
00 22 * * * /usr/local/sbin/refreshcontainers.sh > /home/incusadmin/refreshlog 2>&1
```

Enregistrez vos modifications et quittez l'éditeur.

Cela créera un journal, dans le répertoire personnel d'incusadmin, appelé « refreshlog », qui vous permettra de savoir si votre procédure a fonctionné ou non. Très important!

La procédure automatisée échouera parfois. Cela se produit généralement lorsqu'un conteneur particulier ne parvient pas à se mettre à jour. Vous pouvez relancer manuellement la mise à jour avec la commande suivante (en supposant que rockylinux-test-9 ici, est notre conteneur) :

```bash
lxc copy --refresh rockylinux-test-9 incus-snapshot:rockylinux-test-9
```
