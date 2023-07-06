---
title: Documentazione Locale - Podman
author: Wale Soyinka
contributors:
update: 13-Feb-2023
---

# Esecuzione del sito docs.rockylinux.org in locale per lo sviluppo web | Podman


Questo documento spiega come ricreare ed eseguire una copia locale dell'intero sito web docs.rockylinux.org sul vostro computer locale. Eseguire una copia locale del sito web della documentazione potrebbe essere utile nei seguenti scenari:

* Sei interessato a conoscere e contribuire agli aspetti di sviluppo web del sito docs.rockylinux.org
* Sei un autore e vorresti vedere come i tuoi documenti saranno renderizzati/visualizzati sul sito web di docs prima di contribuirvi


## Creare l'ambiente dei contenuti

1. Assicuratevi che i prerequisiti siano soddisfatti. In caso contrario, passare alla sezione "[Impostare-i-prerequisiti](#setup-the-prerequisites)" e poi tornare qui.

2. Cambiate la directory di lavoro corrente sul vostro sistema locale in una cartella dove intendete scrivere. Ci riferiremo a questa directory come `$ROCKYDOCS` nel resto di questa guida.  Per la nostra dimostrazione, `$ROCKYDOCS` punta a `$HOME/projects/rockydocs` sul nostro sistema demo.

Crea $ROCKYDOCS se non esiste già e cambia la tua directory di lavoro in $ROCKYDOCS digita:

```
mkdir -p $HOME/projects/rockydocs
export ROCKYDOCS=${HOME}/projects/rockydocs
cd  $ROCKYDOCS
```

3. Assicurati di avere `git` installato (`dnf -y install git`).  Mentre sei in $ROCKYDOCS usa git per clonare il repo ufficiale dei contenuti della Documentazione Rocky. Digita:

```
git clone https://github.com/rocky-linux/documentation.git
```

Ora avrai una cartella `$ROCKYDOCS/documentation`. Questa cartella è un repository git e sotto il controllo di git.

4. Usate inoltre git per clonare il repo ufficiale docs.rockylinux.org. Digita:

```
git clone https://github.com/rocky-linux/docs.rockylinux.org.git
```

Ora avrete una cartella `$ROCKYDOCS/docs.rockylinux.org`. In questa cartella è possibile sperimentare i propri contributi di sviluppo web.


## Creare e avviare l'ambiente di sviluppo web RockyDocs

5.  Assicurarsi che podman sia attivo e funzionante sulla macchina locale (si può controllare con `systemctl`). Eseguire il test con l'esecuzione:

```
systemctl  enable --now podman.socket
```

6. Creare un nuovo file `docker-compose.yml` con i seguenti contenuti:

```
version: '2'
services:
  mkdocs:
    privileged: true
    image: rockylinux:9.1
    ports:
      - 8001:8001
    environment:
      PIP_NO_CACHE_DIR: "off"
      PIP_DISABLE_PIP_VERSION_CHECK: "on"
    volumes:
       - type: bind
         source: ./documentation
         target: /app/docs
       - type: bind
         source: ./docs.rockylinux.org
         target: /app/docs.rockylinux.org
    working_dir: /app
    command: bash -c "dnf install -y python3 pip git && \
       ln -sfn  /app/docs   docs.rockylinux.org/docs && \
       cd docs.rockylinux.org && \
       git config  --global user.name webmaster && \
       git config  --global user.email webmaster@rockylinux.org && \
       curl -SL https://raw.githubusercontent.com/rocky-linux/documentation-test/main/docs/labs/mike-plugin-changes.patch -o mike-plugin-changes.patch && \
       git apply --reverse --check mike-plugin-changes.patch && \
       /usr/bin/pip3 install --no-cache-dir -r requirements.txt && \
       /usr/local/bin/mike deploy -F mkdocs.yml 9.1 91alias && \
       /usr/local/bin/mike set-default 9.1 && \
       echo  All done && \
       /usr/local/bin/mike serve  -F mkdocs.yml -a  0.0.0.0:8001"

```

Salva il file con il nome `docker-compose.yml` nella tua directory di lavoro $ROCKYDOCS.

È anche possibile scaricare rapidamente una copia del file docker-compose.yml eseguendo:

```
curl -SL https://raw.githubusercontent.com/rocky-linux/documentation-test/main/docs/labs/docker-compose-rockydocs.yml -o docker-compose.yml
```


7. Infine, utilizzare docker-compose per creare il servizio. Digita:

```
docker-compose  up
```


## Visualizza il sito web locale docs.rockylinux.org

8. Nel caso in cui il sistema Rocky Linux sia dotato di un firewall, assicurarsi che la porta 8001 sia aperta. Digita:

```
firewall-cmd  --add-port=8001/tcp  --permanent
firewall-cmd  --reload
```

Con il container attivo e funzionante, dovresti ora essere in grado di puntare il tuo browser web al seguente URL per visualizzare la tua copia locale del sito:

http://localhost:8001

O

http://<SERVER_IP>:8001




## Impostazione dei prerequisiti

Installare e configurare podman e altri strumenti eseguendo:

```
sudo dnf -y install podman podman-docker git

sudo systemctl enable --now  podman.socket

```

Installare docker-compose e renderlo eseguibile. Digita:

```
curl -SL https://github.com/docker/compose/releases/download/v2.16.0/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose

chmod 755 /usr/local/bin/docker-compose
```


Correggere i permessi sul socket docker. Digita:

```
sudo chmod 666 /var/run/docker.sock
```


### Note:

* Le istruzioni di questa guida **NON** sono un prerequisito per gli Autori/Contributori della documentazione Rocky
* L'intero ambiente viene eseguito in un container Podman e quindi è necessario che Podman sia correttamente configurato sulla propria macchina locale
* Il container è costruito sulla base dell'immagine docker ufficiale di Rocky Linux 9.1, disponibile qui https://hub.docker.com/r/rockylinux/rockylinux
* Il container mantiene il contenuto della documentazione separato dal motore web (mkdocs)
* Il container avvia un server web locale in ascolto sulla porta 8001. 
