---
title: Importare in WSL2 con Docker
---

# Importare Rocky Linux in WSL2 con Docker

## Prerequisiti

O

* PC Linux con VirtualBox - VirtualBox non funzionerà sotto Windows 10 con WSL2, che è necessario per i passaggi successivi. È anche possibile utilizzare un PC dual boot o una distribuzione live, ma assicurarsi di avere a disposizione VirtualBox.

Oppure


* Docker Desktop per Windows 10 (o qualsiasi installazione di docker)

Richiesto
* PC Windows 10 con **WSL2**
* Accesso ad Internet

## Introduzione

Questa guida mostra i passaggi per creare un'immagine tar per un contenitore Docker e come importare tale immagine in Windows Subsystem for Linux (WSL). I passaggi descritti di seguito sono in gran parte tratti da [Importare qualsiasi distribuzione Linux da usare con WSL](https://docs.microsoft.com/en-us/windows/wsl/use-custom-distro) di Microsoft e da [Creare un'immagine di base](https://docs.docker.com/develop/develop-images/baseimages/) di Docker, e adattati alla nuova distribuzione.

Si noti che è necessario Virtual Box (per creare il container) **o** Docker per prelevare l'immagine esistente da Docker Hub. Questa guida presuppone che l'utente abbia familiarità con VirtualBox o Docker e sappia come eseguire operazioni come l'installazione delle VirtualBoxAdditions e il montaggio delle unità condivise.

È inoltre importante conoscere le limitazioni di WSL, che causano l'interruzione di alcune funzionalità, il loro funzionamento lento o in modi inaspettati. A seconda di ciò che si vuole ottenere, la distribuzione risultante può fare o meno ciò che si desidera. Non ci sono garanzie.

----

## Fasi di installazione

### Ottenere l'Immagine del Container Rocky

#### Estrarre da Docker Hub (sullo stesso PC in cui è installato WSL2)
1. Da powershell o da un'altra distro WSL2 creare un contenitore rocky usando la versione con cui si vuole iniziare. Sostituire l'etichetta con quella desiderata
```powershell
docker run --name rocky-container rockylinux/rockylinux:8.5
```
2. Confermare l'esistenza del container
```powershell
docker container list --all | Select-String rocky-container
```
3. Esportazione del container come tar
```powershell
docker export rocky-container -o rocky-container.tar
```

Nota: non è necessario essere sullo stesso sistema dell'installazione di WSL2, ma è sufficiente essere in grado di portare il file tar nel sistema.

#### Create il Vostro PC Linux con VirtualBox
1. Scaricare l'immagine minimale da [Rocky Linux](https://rockylinux.org/download).
2. Avviare e installare Rocky Linux su una nuova macchina virtuale VirtualBox. Le impostazioni predefinite vanno bene.
3. Installare VirtualBoxAdditions sulla macchina virtuale. Ciò richiederà l'installazione di pacchetti aggiuntivi (come mostrato nel comando suggerito):<br />
```bash
$ sudo yum install gcc make kernel-devel bzip2 binutils patch libgomp glibc-headers glibc-devel kernel-headers elfutils-libelf-devel tar

```
4. Creare una directory di lavoro e copiare i file da utilizzare per l'immagine tar.<br />
```bash
$ mkdir wsl_tar
$ cd wsl_tar
$ cp -p /etc/yum.conf .
$ cp -p /etc/yum.repos.d/Rocky-BaseOS.repo .
```
5. Modificare la *copia* di `yum.conf` e aggiungere questa riga (modificare il percorso come necessario):<br />
```bash
reposdir=/home/<your_username>/wsl_tar/
```
6. Scaricare lo script per creare un'immagine di base da Docker GitHub.<br/> Lo script si chiama [mkimage-yum.sh](https://github.com/moby/moby/blob/master/contrib/mkimage-yum.sh).
7. Modificare lo script per creare un file tar alla fine, invece di avviare Docker. Ecco le modifiche suggerite al file:
```bash
## Change line 143 to simply create the tar file, without invoking Docker
tar --numeric-owner -c -C "$target" . -f <path-to-the-new-tar-file>

## Comment out line 145
```
8. Eseguire lo script con questo comando (modificare il percorso se necessario):<br/>
```bash
$ sudo ./mkimage-yum.sh -y /home/<your_username>/wsl_tar/yum.conf baseos
```
9. Al termine dello script, il nuovo file tar si troverà nel percorso inserito nello script precedente. Montare un'unità condivisa con l'host e spostare lì il file tar.  
   È anche possibile spostare il file in un'unità USB o in una cartella accessibile al PC Windows 10.</br> Dopo aver spostato il file su un'unità o una cartella esterna, la macchina virtuale non sarà più necessaria. È possibile eliminarla o modificarla per altri scopi.


### Importazione in WSL2
1. Creare una directory per contenere il filesystem Rocky Linux.
2. In un prompt di PowerShell, importate Rocky Linux (qui si chiama `rocky_rc`, ma potete chiamarlo come volete).<br/>
```PowerShell
wsl --import rocky_rc <Path to RockyLinuxDirectory from step 1> <Path to tar file from previous sections>
```
3. Verificare che Rocky Linux sia installato con:<br/>
```PowerShell
wsl -l -v
```
4. Avviare Rocky Linux con<br/>
```PowerShell
wsl -d rocky_rc
```
5. Configurate Rocky Linux con i seguenti comandi bash (dovrete essere in esecuzione come root).<br/>
```bash
yum update
yum install glibc-langpack-en -y
yum install passwd sudo -y
yum reinstall cracklib-dicts -y
newUsername=<your new username>
adduser -G wheel $newUsername
echo -e "[user]\ndefault=$newUsername" >> /etc/wsl.conf
passwd $newUsername
```
6. Uscire dal prompt di bash (Ctrl+D o exit).
7. In un prompt di PowerShell, spegnere tutte le istanze WSL in esecuzione e avviare Rocky.<br/>
```PowerShell
wsl --shutdown
wsl -d rocky_rc
```
8. Provate e divertitevi!

Se avete installato Windows Terminal, il nome della nuova distro WSL apparirà come opzione nel menu a discesa, il che è molto utile per lanciarla in futuro. È quindi possibile personalizzarlo con colori, caratteri, ecc.

Anche se è necessario WSL2 per eseguire i passaggi sopra descritti, è possibile utilizzare la distro come WSL 1 o 2, convertendola con i comandi di PowerShell.
