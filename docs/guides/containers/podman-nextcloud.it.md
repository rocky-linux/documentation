---
title: Nextcloud su Podman
author: Ananda Kammampati
contributors: Ezequiel Bruni, Steven Spencer, Franco Colussi
tested_with: 8.5
tags:
  - podman
  - containers
  - nextcloud
---

# Esecuzione di Nextcloud come container Podman su Rocky Linux

## Introduzione

Questo documento spiega tutti i passi necessari per costruire ed eseguire un'istanza di [Nextcloud](https://nextcloud.com) come container Podman su Rocky Linux. Inoltre, l'intera guida è stata testata su un Raspberry Pi, quindi dovrebbe essere compatibile con ogni architettura di processore supportata da Rocky.

La procedura è suddivisa in più fasi, ognuna con i propri script di shell per l'automazione:

1. Installare i pacchetti `podman` e `buildah` per gestire e costruire i nostri container, rispettivamente
2. Creare un'immagine di base che sarà riutilizzata per tutti i container di cui avremo bisogno
3. Creare un'immagine container `db-tools` con gli script di shell necessari per costruire ed eseguire il database MariaDB
4. Creare ed eseguire MariaDB come container Podman
5. Creazione ed esecuzione di Nextcloud come container Podman, utilizzando il container Podman MariaDB come backend

La maggior parte dei comandi della guida può essere eseguita manualmente, ma la creazione di alcuni script bash renderà la vita molto più facile, soprattutto quando si desidera ripetere questi passaggi con impostazioni, variabili o nomi di container diversi.

!!! Note "Nota per i principianti"

    Podman è uno strumento per la gestione dei container, in particolare dei container OCI (Open Containers Initiative). È stato progettato per essere praticamente compatibile con Docker, nel senso che la maggior parte, se non tutti, gli stessi comandi funzioneranno per entrambi gli strumenti. Se "Docker" non significa nulla per voi, o anche se siete solo curiosi, potete leggere di più su Podman e su come funziona sul [sito web di Podman](https://podman.io).
    
    `buildah` è uno strumento che costruisce immagini di container Podman basate su "DockerFiles".
    
    Questa guida è stata progettata come esercizio per aiutare le persone a familiarizzare con l'esecuzione dei container Podman in generale e su Rocky Linux in particolare.

## Prerequisiti e presupposti

Ecco tutto ciò che vi serve, o che dovete sapere, per far funzionare questa guida:

* Familiarità con la riga di comando, gli script bash e la modifica dei file di configurazione di Linux.
* Accesso SSH se si lavora su un computer remoto.
* Un editor di testo a riga di comando di vostra scelta. In questa guida utilizzeremo `vi`.
* Una macchina Rocky Linux connessa a Internet (anche in questo caso, un Raspberry Pi può andare bene).
* Molti di questi comandi devono essere eseguiti come root, quindi è necessario avere un utente root o con capacità sudo sulla macchina.
* La familiarità con i server web e MariaDB sarebbe sicuramente utile.
* La familiarità con i container e magari con Docker sarebbe *indubbiamente* un vantaggio ma non è strettamente essenziale.

## Passo 01: Installare `podman` e `buildah`

Innanzitutto, assicuratevi che il vostro sistema sia aggiornato:

```bash
dnf update
```

Successivamente si dovrà installare il repository `epel-release` per tutti i pacchetti extra che verranno utilizzati.

```bash
dnf -y install epel-release 
```

Una volta fatto questo, è possibile aggiornare di nuovo (cosa che a volte è di aiuto) o semplicemente andare avanti e installare i pacchetti di cui abbiamo bisogno:

```bash
dnf -y install podman buildah
```

Una volta installati, eseguire `podman --version` e `buildah --version` per verificare che tutto funzioni correttamente.

Per accedere al registro di Red Hat per scaricare le immagini dei container, è necessario eseguire:

```bash
vi /etc/containers/registries.conf
```

Trovate la sezione che assomiglia a quella che vedete qui sotto. Se è commentato, decommentarlo.

```
[registries.insecure]
registries = ['registry.access.redhat.com', 'registry.redhat.io', 'docker.io'] 
insecure = true
```

## Passo 02: Creare l'immagine `di base` del container

In questa guida lavoreremo come utente root, ma è possibile eseguire questa operazione in qualsiasi directory home. Passare alla directory principale, se non lo si è già fatto:

```bash
cd /root
```

Ora create tutte le directory necessarie per le varie build del container:

```bash
mkdir base db-tools mariadb nextcloud
```

Ora cambiate la vostra directory di lavoro nella cartella dell'immagine di base:

```bash
cd /root/base
```

E creare un file chiamato DockerFile. Sì, anche Podman li usa.

```bash
vi Dockerfile
```

Copiare e incollare il seguente testo nel nuovo file Docker.

```
FROM rockylinux/rockylinux:latest
ENV container docker
RUN yum -y install epel-release ; yum -y update
RUN dnf module enable -y php:7.4
RUN dnf install -y php
RUN yum install -y bzip2 unzip lsof wget traceroute nmap tcpdump bridge-utils ; yum -y update
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;
VOLUME [ "/sys/fs/cgroup" ]
CMD ["/usr/sbin/init"]
```

Salvare e chiudere il file precedente e creare un nuovo file di script bash:

```bash
vi build.sh
```

Quindi incollare questo contenuto:

```
#!/bin/bash
clear
buildah rmi `buildah images -q base` ;
buildah bud --no-cache -t base . ;
buildah images -a
```

Ora rendete eseguibile lo script di compilazione con:

```bash
chmod +x build.sh
```

E poi eseguire:

```bash
./build.sh
```

Attendere che sia terminato e passare alla fase successiva.

## Passo 03: Creare l'immagine `db-tools` del container

Per gli scopi di questa guida, manteniamo la configurazione del database il più semplice possibile. Si consiglia di tenere traccia dei seguenti elementi e di modificarli se necessario:

* Nome del database: ncdb
* Utente del database: nc-user
* Pass per il database: nc-pass
* L'indirizzo IP del vostro server (di seguito utilizzeremo un IP di esempio)

Per prima cosa, spostarsi nella cartella in cui si costruirà l'immagine di db-tools:

```bash
cd /root/db-tools
```

Ora impostiamo alcuni script bash che saranno usati all'interno dell'immagine del container Podman. Per prima cosa, create lo script che costruirà automaticamente il database per voi:

```bash
vi db-create.sh
```

Ora copiate e incollate il seguente codice nel file, utilizzando il vostro editor di testo preferito:

```
#!/bin/bash
mysql -h 10.1.1.160 -u root -p rockylinux << eof
create database ncdb;
grant all on ncdb.* to 'nc-user'@'10.1.1.160' identified by 'nc-pass';
flush privileges;
eof
```

Salvare e chiudere, quindi ripetere i passaggi con lo script per l'eliminazione dei database, se necessario:

```bash
vi db-drop.sh
```

Copiate e incollate questo codice nel nuovo file:

```
#!/bin/bash
mysql -h 10.1.1.160 -u root -p rockylinux << eof
drop database ncdb;
flush privileges;
eof
```

Infine, impostare il file Docker per l'immagine `db-tools`:

```bash
vi Dockerfile
```

Copia e incolla:

```
FROM localhost/base
RUN yum -y install mysql
WORKDIR /root
COPY db-drop.sh db-drop.sh
COPY db-create.sh db-create.sh
```

Infine, ma non meno importante, creare lo script bash per costruire l'immagine a comando:

```bash
vi build.sh
```

Il codice che si desidera ottenere:

```
#!/bin/bash
clear
buildah rmi `buildah images -q db-tools` ;
buildah bud --no-cache -t db-tools . ;
buildah images -a
```

Salvare e chiudere, quindi rendere il file eseguibile:

```bash
chmod +x build.sh
```

E poi eseguire:

```bash
./build.sh
```

## Passo 04: Creare l'immagine del container MariaDB

State prendendo confidenza con il processo, vero? È il momento di costruire il container del database vero e proprio. Cambiare la directory di lavoro in `/root/mariadb`:

```bash
cd /root/mariadb
```

Creare uno script per (ri)costruire il container ogni volta che si vuole:

```bash
vi db-init.sh
```

Ed ecco il codice necessario:

!!! warning "Attenzione"

    Ai fini di questa guida, il seguente script cancellerà tutti i Volumi Podman. Se ci sono altre applicazioni in esecuzione con i propri volumi, modificare/commentare la riga "podman volume rm --all";

```
#!/bin/bash
clear
echo " "
echo "Deleting existing volumes if any...."
podman volume rm --all ;
echo " "
echo "Starting mariadb container....."
podman run --name mariadb --label mariadb -d --net host -e MYSQL_ROOT_PASSWORD=rockylinux -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v mariadb-data:/var/lib/mysql/data:Z mariadb ;

echo " "
echo "Initializing mariadb (takes 2 minutes)....."
sleep 120 ;

echo " "
echo "Creating ncdb Database for nextcloud ....."
podman run --rm --net host db-tools /root/db-create.sh ;

echo " "
echo "Listing podman volumes...."
podman volume ls
```

È qui che si crea uno script per resettare il database ogni volta che lo si desidera:

```bash
vi db-reset.sh
```

Ed ecco il codice:

```
#!/bin/bash
clear
echo " "
echo "Deleting ncdb Database for nextcloud ....."
podman run --rm --net host db-tools /root/db-drop.sh ;

echo " "
echo "Creating ncdb Database for nextcloud ....."
podman run --rm --net host db-tools /root/db-create.sh ;
```

Infine, ecco lo script di compilazione che metterà insieme l'intero container mariadb:

```bash
vi build.sh
```

With its code:

```
#!/bin/bash
clear
buildah rmi `buildah images -q mariadb` ;
buildah bud --no-cache -t mariadb . ;
buildah images -a
```

Ora create il vostro DockferFile (`vi Dockerfile`) e incollate la seguente singola riga:

```
FROM arm64v8/mariadb
```

Ora rendete eseguibile il vostro script di compilazione ed eseguitelo:

```bash
chmod +x *.sh

./build.sh
```

## Passo 05: Creare ed eseguire il container Nextcloud

Siamo alla fase finale e il processo si ripete praticamente da solo. Passare alla directory dell'immagine di Nextcloud:

```bash
cd /root/nextcloud
```

Questa volta impostate il vostro file Docker per primo, per una questione di varietà:

```bash
vi Dockerfile
```

!!! note "Nota"

    Il prossimo punto presuppone l'architettura ARM (per il Raspberry Pi), quindi se si utilizza un'altra architettura, ricordarsi di cambiarla.

E incollare questo pezzo:

```
FROM arm64v8/nextcloud
```

Ora create il vostro script di compilazione:

```bash
vi build.sh
```

E incollare questo codice:

```
#!/bin/bash
clear
buildah rmi `buildah images -q nextcloud` ;
buildah bud --no-cache -t nextcloud . ;
buildah images -a
```

Ora, si imposterà un gruppo di cartelle locali sul server host (*non* in un container Podman), in modo da poter ricostruire i nostri container e database senza temere di perdere tutti i nostri file:

```bash
mkdir -p /usr/local/nc/nextcloud /usr/local/nc/apps /usr/local/nc/config /usr/local/nc/data
```

Infine, creeremo lo script che costruirà effettivamente il container Nextcloud per noi:

```bash
vi run.sh
```

Ecco tutto il codice necessario per farlo. Assicurarsi di cambiare l'indirizzo IP di `MYSQL_HOST` con il container docker su cui è in esecuzione l'istanza di MariaDB.

```
#!/bin/bash
clear
echo " "
echo "Starting nextloud container....."
podman run --name nextcloud --net host --privileged -d -p 80:80 \
-e MYSQL_HOST=10.1.1.160 \
-e MYSQL_DATABASE=ncdb \
-e MYSQL_USER=nc-user \
-e MYSQL_PASSWORD=nc-pass \
-e NEXTCLOUD_ADMIN_USER=admin \
-e NEXTCLOUD_ADMIN_PASSWORD=rockylinux \
-e NEXTCLOUD_DATA_DIR=/var/www/html/data \
-e NEXTCLOUD_TRUSTED_DOMAINS=10.1.1.160 \
-v /sys/fs/cgroup:/sys/fs/cgroup:ro \
-v /usr/local/nc/nextcloud:/var/www/html \
-v /usr/local/nc/apps:/var/www/html/custom_apps \
-v /usr/local/nc/config:/var/www/html/config \
-v /usr/local/nc/data:/var/www/html/data \
nextcloud ;
```

Salvare e chiudere il file, rendere eseguibili tutti gli script, quindi eseguire prima lo script di creazione dell'immagine:

```bash
chmod +x *.sh

./build.sh
```

Per assicurarsi che tutte le immagini siano state costruite correttamente, eseguire `podman images`. Dovrebbe apparire un elenco simile a questo:

```
REPOSITORY                      TAG    IMAGE ID     CREATED      SIZE
localhost/db-tools              latest 8f7ccb04ecab 6 days ago   557 MB
localhost/base                  latest 03ae68ad2271 6 days ago   465 MB
docker.io/arm64v8/mariadb       latest 89a126188478 11 days ago  405 MB
docker.io/arm64v8/nextcloud     latest 579a44c1dc98 3 weeks ago  945 MB
```

Se tutto sembra corretto, eseguite lo script finale per avviare Nextcloud:

```bash
./run.sh
```

Quando si esegue `podman ps -a`, si dovrebbe vedere un elenco di container in esecuzione che assomiglia a questo:

```
CONTAINER ID IMAGE                              COMMAND              CREATED        STATUS            PORTS    NAMES
9518756a259a docker.io/arm64v8/mariadb:latest   mariadbd             3 minutes  ago Up 3 minutes ago           mariadb
32534e5a5890 docker.io/arm64v8/nextcloud:latest apache2-foregroun... 12 seconds ago Up 12 seconds ago          nextcloud
```

Da qui, si dovrebbe essere in grado di puntare il browser all'indirizzo IP del server. Se state seguendo e avete lo stesso IP del nostro esempio, potete sostituirlo qui (ad esempio, http://your-server-ip) e vedere Nextcloud in funzione.

## Conclusione

Ovviamente, questa guida dovrà essere modificata in qualche modo su un server di produzione, soprattutto se l'istanza Nextcloud è destinata a essere pubblica. Comunque, questo dovrebbe darvi un'idea di base di come funziona Podman e di come potete configurarlo con script e immagini di base multiple per facilitare le ricostruzioni.
