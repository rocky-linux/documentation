---
title: Podman
author: Neel Chauhan, Antoine Le Morvan
contributors: Steven Spencer, Ganna Zhyrnova, Christian Steinert
date: 2024-03-07
tags:
  - docker
  - podman
---

## Introduzione

!!! note

```
Questo documento rappresenta il contenuto esteso del suo [documento di riferimento trovato qui](../../gemstones/containers/podman.md). Se si ha bisogno di una guida rapida, il documento di riferimento può essere sufficiente.
```

[Podman](https://podman.io/) (Pod Manager) è uno strumento di gestione di container e immagini compatibile con la [OCI](https://opencontainers.org/) (Open Container Initiative).

Podman:

- funziona senza un daemon (può eseguire i container come servizio `systemd`)
- permette di gestire i container come utente non privilegiato (non è necessario essere root)
- incluso, a differenza di docker, nei repository Rocky Linux

Questo rende Podman non solo un runtime alternativo per container compatibile con docker, ma molto di più.

## Installare `Podman`

Utilizzare l'utility `dnf` per installare Podman:

```bash
dnf install podman
```

È possibile recuperare l'elenco dei sottocomandi Podman disponibili con il seguente comando:

```bash
$ podman --help

Manage pods, containers and images

Usage:
  podman [options] [command]

Available Commands:
  attach      Attach to a running container
  auto-update Auto update containers according to their auto-update policy
...
...
```

Ecco un elenco selezionato dei sottocomandi più comunemente utilizzati:

| Sottocomando | Descrizione                                                                                                      |
| ------------ | ---------------------------------------------------------------------------------------------------------------- |
| `build`      | Crea un'immagine usando le istruzioni nei Containerfiles                                                         |
| `commit`     | Crea una nuova immagine basata sul container modificato                                                          |
| `container`  | Gestore dei container                                                                                            |
| `cp`         | Copia file/cartelle tra un container e il filesystem locale.                                     |
| `create`     | Crea ma non avvia un container                                                                                   |
| `exec`       | Esegue un processo in un container in esecuzione                                                                 |
| `image`      | Gestione immagini                                                                                                |
| `images`     | Elenca le immagini nello storage locale                                                                          |
| `info`       | Visualizza le informazioni del sistema Podman                                                                    |
| `init`       | Inizializza uno o piu' container                                                                                 |
| `inspect`    | Visualizza la configurazione dell'oggetto indicato con ID                                                        |
| `kill`       | Termina uno o più container in esecuzione con un segnale specifico                                               |
| `login`      | Log in al registro di un container                                                                               |
| `logs`       | Recupera i registri di uno o più container                                                                       |
| `network`    | Gestione delle reti                                                                                              |
| `pause`      | Mette in pausa tutti i processi in uno o più container.                                          |
| `ps`         | Elenca i container                                                                                               |
| `pull`       | Pull una image da un registry                                                                                    |
| `push`       | Push una image ad una destinazione specifica                                                                     |
| `restart`    | Riavvia uno o più container                                                                                      |
| `rm`         | Cancella uno o più container                                                                                     |
| `rmi`        | Rimuove una o più image dallo storage locale                                                                     |
| `run`        | Esegue un comando su un nuovo container                                                                          |
| `start`      | Avvia uno o più container                                                                                        |
| `stats`      | Visualizza un stream in tempo reale delle statistiche sull'utilizzo delle risorse del container. |
| `stop`       | Termina uno o più container                                                                                      |
| `system`     | Gestione di Podman                                                                                               |
| `top`        | Visualizza i processi in esecuzione di un container                                                              |
| `unpause`    | Riavvia i processi in uno o più container                                                                        |
| `volume`     | Gestisce i volume                                                                                                |

!!! note "Nota"

```
Podman può eseguire quasi tutti i comandi Docker grazie alla sua interfaccia CLI simile.
```

Se si deve usare un compose file, ricordarsi di installare il pacchetto `podman-compose`:

```bash
dnf install podman-compose
```

## Aggiungere un container

Eseguire una piattaforma cloud self-hosted [Nextcloud](https://nextcloud.com/) come esempio:

```bash
podman run -d -p 8080:80 nextcloud
```

Verrà richiesto di selezionare il registro del container da cui scaricare. In questo esempio, si utilizzerà `docker.io/library/nextcloud:latest`.

Una volta scaricata l'immagine di Nextcloud, questa verrà eseguita.

Inserite **indirizzo_ip:8080** nel vostro browser web (supponendo di aver aperto la porta in `firewalld`) e configurate Nextcloud:

![Nextcloud in container](../../gemstones/images/podman_nextcloud.png)

!!! tip "Suggerimento"

```
Per seguire l'output dei log dell'ultimo container creato, usare `podman logs -lf`. `-l` specifica di usare l'ultimo container creato, mentre `-f` specifica di seguire i log, man mano che vengono creati. Premere Ctrl+C per interrompere l'output dei log.
```

## Eseguire contenitori come servizi `systemd`

### Utilizzare `quadlet`

Dalla versione Podman 4.4 con [Quadlet](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html) - viene fornito un generatore di systemd. Può essere usato per generare unit file per servizi systemd rootless e rootful.

Collocare i file Quadlet per i servizi rootful in:

- `/etc/containers/systemd/`
- `/usr/share/containers/systemd/`

Posizionare i file rootless in uno qualsiasi dei seguenti percorsi:

- `$XDG_CONFIG_HOME/containers/systemd/` or `~/.config/containers/systemd/`
- `/etc/containers/systemd/users/$(UID)`
- `/etc/containers/systemd/users/`

Oltre ai singoli contenitori, sono supportati i file pod, immagine, rete, volume e kube. In particolare focalizzandosi sull'esempio di Nextcloud. Creare un nuovo file `~/.config/containers/systemd/nextcloud.container` con il seguente contenuto:

```systemd
[Container]
Image=nextcloud
PublishPort=8080:80
```

Sono disponibili [molte altre opzioni](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html#container-units-container).

Per eseguire il generator e far sapere a systemd che c'è un nuovo servizio da eseguire:

```bash
systemctl --user daemon-reload
```

Per avviare il servizio, eseguire:

```bash
systemctl --user start nextcloud.service
```

!!! note "Nota"

```
Se si è già creato un file in una delle directory per i servizi rootful, omettere il flag `--user`.
```

Per eseguire automaticamente il container all'avvio del sistema o al login dell'utente, si può aggiungere un'altra sezione al file `nextcloud.container`:

```systemd
[Install]
WantedBy=default.target
```

Poiché i file del servizio generati sono considerati temporanei, non possono essere abilitati da systemd. Per ovviare a questo problema, il generator applica manualmente le installazioni durante la generazione. In questo modo si abilitano effettivamente anche i file dei servizi.

Sono supportati altri tipi di file: pod, volume, network, image, and kube. [Pods](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html#pod-units-pod), per esempio, può essere usato per raggruppare i container – i servizi systemd generati e le loro dipendenze (creare il pod prima dei container) sono gestiti automaticamente da systemd.

### Utilizzare `podman generate systemd`

Podman fornisce inoltre il sottocomando `generate systemd`. Usare questo sottocomando per generare i service file di `systemd`.

!!! warning "Attenzione"

```
`generate systemd` è ora deprecato e non riceverà ulteriori funzioni. Si raccomanda l'uso di Quadlet.
```

Ora lo si farà con Nextcloud. Eseguire:

```bash
podman ps
```

Si otterrà un elenco di container in esecuzione:

```bash
04f7553f431a  docker.io/library/nextcloud:latest  apache2-foregroun...  5 minutes ago  Up 5 minutes  0.0.0.0:8080->80/tcp  compassionate_meninsky
```

Come visto sopra, il nome del nostro container è `compassionate_meninsky`.

Per creare un servizio `systemd` per il container Nextcloud e abilitarlo al riavvio, eseguire quanto segue:

```bash
podman generate systemd --name compassionate_meninsky > /usr/lib/systemd/system/nextcloud.service
systemctl enable nextcloud
```

Sostituire `compassionate_meninsky` con il nome assegnato al container.

Quando il sistema si riavvia, Nextcloud si riavvia in Podman.

## Containerfiles

Un Containerfile è un file usato da Podman per creare immagini di container. I file container usano la stessa sintassi dei file Docker, quindi si possono costruire le immagini dei container con Podman come si farebbe con Docker.

### Server web da un Containerfile

Server web da un file container

Creare una cartella dedicata alla image:

```bash
mkdir myrocky && cd myrocky
```

Creare un file `index.html` che verrà eseguito nel nostro server web:

```bash
echo "Welcome to Rocky" > index.html
```

Creare un file `Containerfile` con il seguente contenuto:

```text
# Use the latest rockylinux image as a start
FROM rockylinux:9

# Make it uptodate
RUN dnf -y update
# Install and enable httpd
RUN dnf -y install httpd
RUN systemctl enable httpd
# Copy the local index.html file into our image
COPY index.html /var/www/html/

# Expose the port 80 to the outside
EXPOSE 80

# Start the services
CMD [ "/sbin/init" ]
```

Siamo pronti a costruire la nostra immagine chiamata `myrockywebserver`:

```bash
$ podman build -t myrockywebserver .

STEP 1/7: FROM rockylinux:9
Resolved "rockylinux" as an alias (/etc/containers/registries.conf.d/000-shortnames.conf)
Trying to pull docker.io/library/rockylinux:9...
Getting image source signatures
Copying blob 489e1be6ce56 skipped: already exists
Copying config b72d2d9150 done
Writing manifest to image destination
STEP 2/7: RUN dnf -y update
Rocky Linux 9 - BaseOS                          406 kB/s | 2.2 MB     00:05    
Rocky Linux 9 - AppStream                       9.9 MB/s | 7.4 MB     00:00    
Rocky Linux 9 - Extras                           35 kB/s |  14 kB     00:00    
Dependencies resolved.
================================================================================
 Package                   Arch      Version                 Repository    Size
================================================================================
Upgrading:
 basesystem                noarch    11-13.el9.0.1           baseos       6.4 k
 binutils                  x86_64    2.35.2-42.el9_3.1       baseos       4.5 M
...
Complete!
--> 2e8b93d30f31
STEP 3/7: RUN dnf -y install httpd
Last metadata expiration check: 0:00:34 ago on Wed Apr  3 07:29:56 2024.
Dependencies resolved.
================================================================================
 Package                Arch       Version                  Repository     Size
================================================================================
Installing:
 httpd                  x86_64     2.4.57-5.el9             appstream      46 k
...
Complete!
--> 71db5cabef1e
STEP 4/7: RUN systemctl enable httpd
Created symlink /etc/systemd/system/multi-user.target.wants/httpd.service → /usr/lib/systemd/system/httpd.service.
--> 423d45a3cb2d
STEP 5/7: COPY index.html /var/www/html/
--> dfaf9236ebae
STEP 6/7: EXPOSE 80
--> 439bc5aee524
STEP 7/7: CMD [ "/sbin/init" ]
COMMIT myrockywebserver
--> 7fcf202d3c8d
Successfully tagged localhost/myrockywebserver:latest
7fcf202d3c8d059837cc4e7bc083a526966874f978cd4ab18690efb0f893d583
```

È possibile eseguire l'immagine di Podman e confermare l'avvio:

```bash
$ podman run -d --name rockywebserver -p 8080:80 localhost/myrockywebserver
282c09eecf845c7d9390f6878f9340a802cc2e13d654da197d6c08111905f1bd

$ podman ps
CONTAINER ID  IMAGE                              COMMAND     CREATED         STATUS         PORTS                 NAMES
282c09eecf84  localhost/myrockywebserver:latest  /sbin/init  16 seconds ago  Up 16 seconds  0.0.0.0:8080->80/tcp  rockywebserver
```

Si è eseguita l'immagine Podman in modalità demone (`-d`) e la si è chiamata `rockywebserver` (opzione `--nome`).

Si è reindirizzata la porta 80 (protetta) alla porta 8080 con l'opzione `-p`. Vedere se la porta è in ascolto con:

```bash
ss -tuna | grep "*:8080"
tcp   LISTEN    0      4096                *:8080             *:*
```

Verificare che il file `index.html` sia accessibile:

```bash
$ curl http://localhost:8080
Welcome to Rocky
```

Congratulazioni! A questo punto è possibile arrestare e cancellare l'immagine in esecuzione, assegnando il nome fornito durante la creazione:

```bash
podman stop rockywebserver && podman rm rockywebserver
```

!!! tip "Suggerimento"

```
Si può aggiungere l'opzione `--rm` per cancellare automaticamente il contenitore una volta che si ferma.
```

Se si rilancia il processo di compilazione, `podman` utilizzerà una cache a ogni passo della compilazione:

```bash
$ podman build -t myrockywebserver .

STEP 1/7: FROM rockylinux:9
STEP 2/7: RUN dnf -y update
--> Using cache 2e8b93d30f3104d77827a888fdf1d6350d203af18e16ae528b9ca612b850f844
--> 2e8b93d30f31
STEP 3/7: RUN dnf -y install httpd
--> Using cache 71db5cabef1e033c0d7416bc341848fbf4dfcfa25cd43758a8b264ac0cfcf461
--> 71db5cabef1e
STEP 4/7: RUN systemctl enable httpd
--> Using cache 423d45a3cb2d9f5ef0af474e4f16721f4c84c1b80aa486925a3ae2b563ba3968
--> 423d45a3cb2d
STEP 5/7: COPY index.html /var/www/html/
--> Using cache dfaf9236ebaecf835ecb9049c657723bd9ec37190679dd3532e7d75c0ca80331
--> dfaf9236ebae
STEP 6/7: EXPOSE 80
--> Using cache 439bc5aee524338a416ae5080afbbea258a3c5e5cd910b2485559b4a908f81a3
--> 439bc5aee524
STEP 7/7: CMD [ "/sbin/init" ]
--> Using cache 7fcf202d3c8d059837cc4e7bc083a526966874f978cd4ab18690efb0f893d583
COMMIT myrockywebserver
--> 7fcf202d3c8d
Successfully tagged localhost/myrockywebserver:latest
7fcf202d3c8d059837cc4e7bc083a526966874f978cd4ab18690efb0f893d583
```

È possibile cancellare la cache con il sottocomando `prune`:

```bash
podman system prune -a -f
```

| Opzioni     | Descrizione                                                                          |
| ----------- | ------------------------------------------------------------------------------------ |
| `-a`        | Rimuove tutti i dati inutilizzati, non solo quelli esterni a Podman. |
| `-f`        | Forza senza nessuna richiesta di conferma                                            |
| `--volumes` | Elimina i volume                                                                     |

## Pods

I pod sono un modo per raggruppare i container I contenitori in un pod condividono alcune impostazioni, come i mount point l'allocazione delle risorse o le mappature delle porte.

In Podman, si gestiscono i pod usando il sottocomando `podman pod`, simile a molti comandi di Podman, per controllare i contenitori:

| Comando   | Descrizione                                                                                                                       |
| --------- | --------------------------------------------------------------------------------------------------------------------------------- |
| clone     | Crea una copia di un pod esistente.                                                                               |
| create    | Crea un nuovo pod.                                                                                                |
| exists    | Controlla se un pod esiste nel storage locale.                                                                    |
| `inspect` | Visualizza le informazioni che descrivono un pod.                                                                 |
| kill      | Termina il processo principale di ogni container in uno o più pods.                                               |
| logs      | Visualizza i registry per i pod con uno o più container.                                                          |
| pause     | Mette in pausa uno o più pod.                                                                                     |
| prune     | Rimuove tutti i pod terminati e i loro container.                                                                 |
| ps        | Stampa le informazioni sui pod.                                                                                   |
| restart   | Riavvia uno o più pod.                                                                                            |
| rm        | Rimuove uno o più pod e container terminati.                                                                      |
| start     | Avvia uno o più pods.                                                                                             |
| stats     | Visualizza uno stream in tempo reale delle statistiche di utilizzo delle risorse per i continer in uno o più pod. |
| stop      | Termina uno o più pod.                                                                                            |
| top       | Visualizza i processi in esecuzione dei container in un pod.                                                      |
| unpause   | Riavvia uno o più pods.                                                                                           |

I container raggruppati in un pod possono accedere l'uno all'altro utilizzando localhost. È utile, ad esempio, quando si configura Nextcloud con un database dedicato come Postgres. Nextcloud può accedere al database, ma non è necessario che il database sia accessibile dall'esterno dei container.

Per creare un pod contenente Nextcloud e un database dedicato, eseguire quanto segue:

```bash
# Creare il pod con una mappatura delle porte
podman pod create --name nextcloud -p 8080:80

# Aggiungere un contenitore Nextcloud al pod - il mapping della porta non deve essere specificato di nuovo!
podman create --pod nextcloud --name nextcloud-app nextcloud

# Aggiungere un database Postgres. Questo contenitore ha una variabile d'ambiente specifica per Postgres.
podman create --pod nextcloud --name nextcloud-db -e POSTGRES_HOST_AUTH_METHOD=trust postgres
```

Per eseguire il pod appena creato, eseguire:

```bash
podman pod start nextcloud
```

Ora è possibile configurare Nextcloud utilizzando un database locale:

![Nextcloud setting up a database](img/podman_nextcloud_db_setup.png)
