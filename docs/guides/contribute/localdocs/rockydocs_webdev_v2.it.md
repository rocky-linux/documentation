---
title: Metodo Podman
author: Wale Soyinka
contributors: Ganna Zhyrnova
update: 13-Feb-2023
---

# Esecuzione del sito docs.rockylinux.org in locale per lo sviluppo web | Podman

Questo documento spiega come ricreare ed eseguire una copia locale dell'intero sito web docs.rockylinux.org sulla vostra macchina locale. Utilizzare una copia locale del sito web della documentazione può essere utile nei seguenti scenari:

* Siete interessati a conoscere e a contribuire agli aspetti dello sviluppo web del sito docs.rockylinux.org
* Siete un autore e volete vedere come i vostri documenti verranno visualizzati sul sito web della documentazione prima di inviarli

## Creare l'ambiente del contenuti

1. Assicuratevi che i prerequisiti siano soddisfatti. In caso contrario, passare alla sezione "[Impostare-i-prerequisiti](#impostazione-dei-prerequisiti)" e poi tornare qui.

2. Passare dalla directory di lavoro corrente del sistema locale alla cartella in cui si intende effettuare le operazioni di scrittura. Nel resto di questa guida ci riferiremo a questa directory come `$ROCKYDOCS`. Per la nostra dimostrazione, `$ROCKYDOCS` punta a `$HOME/projects/rockydocs` sul nostro sistema demo.

    Creare `$ROCKYDOCS` se non esiste già e cambiare la directory di lavoro in quella `$ROCKYDOCS`:

    ```bash
    mkdir -p $HOME/projects/rockydocs
    export ROCKYDOCS=${HOME}/projects/rockydocs
    cd  $ROCKYDOCS
    ```

3. Assicurarsi di avere installato `git`. (`dnf -y install git`).  Mentre ci si trova in $ROCKYDOCS, usare git per clonare il repo dei contenuti della documentazione ufficiale di Rocky. Digitare:

    ```bash
    git clone https://github.com/rocky-linux/documentation.git
    ```

    Ora avrete una cartella `$ROCKYDOCS/documentation`. Questa cartella è un repository git ed è sotto il controllo di git.

4. Usare sempre `git` per clonare il repo ufficiale docs.rockylinux.org. Digitare:

    ```bash
    git clone https://github.com/rocky-linux/docs.rockylinux.org.git
    ```

Ora avrete una cartella `$ROCKYDOCS/docs.rockylinux.org`. In questa cartella è possibile sperimentare i propri contributi di sviluppo web.

## Creare e avviare l'ambiente di sviluppo web RockyDocs

1. Assicurarsi che Podman sia attivo e funzionante sulla macchina locale (si può controllare con `systemctl`). Eseguire il test:

    ```bash
    systemctl  enable --now podman.socket
    ```

2. Creare un nuovo file `docker-compose.yml` con i seguenti contenuti:

    ```bash
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

    Salvare il file con il nome `docker-compose.yml` nella cartella di lavoro $ROCKYDOCS.

    È anche possibile scaricare rapidamente una copia del file docker-compose.yml eseguendo:

    ```bash
    curl -SL https://raw.githubusercontent.com/rocky-linux/documentation-test/main/docs/labs/docker-compose-rockydocs.yml -o docker-compose.yml
    ```

3. Infine, utilizzare docker-compose per creare il servizio. Digitare:

    ```bash
    docker-compose  up
    ```


## Visualizzare il sito web locale docs.rockylinux.org

Se sul sistema Rocky Linux è attivo un firewall, assicurarsi che la porta 8001 sia aperta. Digitare:

  ```bash
  firewall-cmd  --add-port=8001/tcp  --permanent
  firewall-cmd  --reload
  ```

  Con il container attivo e funzionante, ora si dovrebbe essere in grado di puntare il browser web al seguente URL per visualizzare la copia locale del sito:

  <http://localhost:8001>

  O

  <http://SERVER_IP:8001>

## Impostazione dei prerequisiti

Installare e configurare Podman e altri strumenti eseguendo:

```bash
sudo dnf -y install podman podman-docker git

sudo systemctl enable --now  podman.socket
```

Installare docker-compose e renderlo eseguibile. Digitare:

```bash
curl -SL https://github.com/docker/compose/releases/download/v2.16.0/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose

chmod 755 /usr/local/bin/docker-compose
```

Correggere i permessi sul socket docker. Digitare:

```bash

sudo chmod 666 /var/run/docker.sock
```

### Note

- Le istruzioni contenute in questa guida **NON** sono un prerequisito per gli autori della documentazione Rocky o per i contributori di contenuti
- L'intero ambiente viene eseguito in un container Podman e quindi è necessario che Podman sia correttamente configurato sulla propria macchina locale
- Il container è costruito sulla base dell'immagine docker ufficiale di Rocky Linux 9.1, disponibile qui https://hub.docker.com/r/rockylinux/rockylinux
- Il container mantiene il contenuto della documentazione separato dal motore web (mkdocs)
- Il container avvia un server web locale in ascolto sulla porta 8001.
