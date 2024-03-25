---
title: 'Chapitre 10 : Automatisation des Snapshots'
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 8.8, 9.2
tags:
  - lxd
  - enterprise
  - automatisation lxd
---

# Chapitre 10 : Automatisation des Snapshots

Tout au long de ce chapitre, vous devrez être root ou capable d'utiliser `sudo` pour devenir root.

Automatiser le processus de capture instantanée rend les choses beaucoup plus faciles.

## Automatisation du processus de copie des snapshots


Ce processus est effectué sur le serveur lxd-primary. La première chose que nous devons faire est de créer un script qui sera exécuté par cron dans /usr/local/sbin et appelé "refresh-containers" :

```
sudo vi /usr/local/sbin/refreshcontainers.sh
```

Le script est plutôt simple :

```
#!/bin/bash
# This script is for doing an lxc copy --refresh against each container, copying
# and updating them to the snapshot server.

for x in $(/var/lib/snapd/snap/bin/lxc ls -c n --format csv)
        do echo "Refreshing $x"
        /var/lib/snapd/snap/bin/lxc copy --refresh $x lxd-snapshot:$x
        done

```

 Rendre le script exécutable :

```
sudo chmod +x /usr/local/sbin/refreshcontainers.sh
```

Changer la propriété de ce script aux utilisateur et groupe lxdadmin :

```
sudo chown lxdadmin.lxdadmin /usr/local/sbin/refreshcontainers.sh
```

Configurez le crontab pour que l'utilisateur lxdadmin exécute ce script, dans ce cas à 22h :

```
crontab -e
```

Votre entrée ressemblera à ceci :

```
00 22 * * * /usr/local/sbin/refreshcontainers.sh > /home/lxdadmin/refreshlog 2>&1
```

Enregistrez vos modifications et quittez l'éditeur.

Cela créera un log dans le répertoire home de lxdadmin, appelé "refreshlog" qui vous permettra de savoir si votre processus a fonctionné ou non. Très important!

La procédure automatisée échouera parfois. Cela se produit généralement lorsqu'un conteneur particulier ne parvient pas à se mettre à jour. Vous pouvez relancer manuellement la mise à jour avec la commande suivante (en supposant que rockylinux-test-9 ici, est notre conteneur) :

```
lxc copy --refresh rockylinux-test-9 lxd-snapshot:rockylinux-test-9
```
