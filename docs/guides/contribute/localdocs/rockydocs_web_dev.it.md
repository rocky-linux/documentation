---
title: Metodo Docker
author: Wale Soyinka
contributors: Steve Spencer, Ganna Zhyrnova
update: 05-Mar-2022
---

# Esecuzione di una copia locale del sito docs.rockylinux.org per lo sviluppo web e/o gli autori di contenuti

Questo documento spiega come ricreare ed eseguire una copia locale dell'intero sito docs.rockylinux.org sulla tua macchina locale. **È un lavoro in corso.**

Eseguire una copia locale del sito web della documentazione potrebbe essere utile nei seguenti scenari:

- Sei interessato a conoscere e contribuire agli aspetti di sviluppo web del sito docs.rockylinux.org
- Sei un autore e vorresti vedere come i tuoi documenti saranno renderizzati/visualizzati sul sito web di docs prima di contribuirvi
- Sei uno sviluppatore web che cerca di contribuire o aiutare a mantenere il sito docs.rockylinux.org

## Alcune Note

- Le istruzioni di questa guida **NON** sono un prerequisito per gli Autori/Contributori della documentazione Rocky
- L'intero ambiente gira in un container Docker e quindi avrai bisogno di un motore Docker sulla tua macchina locale
- Il contenitore è costruito sulla base dell'immagine docker ufficiale di RockyLinux, disponibile qui <https://hub.docker.com/r/rockylinux/rockylinux>
- Il container conserva il contenuto della documentazione (guide, libri, immagini e così via) separato dal motore web (mkdocs)
- Il container avvia un server web locale in ascolto sulla porta 8000.  E la porta 8000 sarà inoltrata all'host Docker

## Creare l'ambiente dei contenuti

1. Passare dalla directory di lavoro corrente del sistema locale alla cartella in cui si intende effettuare le operazioni di scrittura. Nel resto di questa guida ci riferiremo a questa directory come`$ROCKYDOCS`.  Per la nostra dimostrazione, `$ROCKYDOCS` punta a `~/projects/rockydocs` sul nostro sistema demo.

    Creare $ROCKYDOCS se non esiste già e digitare:

    ```bash
    cd  $ROCKYDOCS
    ```

2. Assicurarsi di avere installato `git``(dnf -y install git`).  Mentre ci si trova in $ROCKYDOCS, usare git per clonare il repo dei contenuti della documentazione ufficiale di Rocky. Digitare:

    ```bash
    git clone https://github.com/rocky-linux/documentation.git
    ```

Ora avrete una cartella `$ROCKYDOCS/documentation`. Questa cartella è un repository git ed è sotto il controllo di git.

## Creare e avviare l'ambiente di sviluppo web RockyDocs

1. Assicurarsi che Docker sia attivo e funzionante sulla macchina locale (si può controllare con `systemctl`)

2. Da un terminale digitare:

    ```bash
    docker pull wsoyinka/rockydocs:latest
    ```

3. Verificare che l'immagine sia stata scaricata correttamente. Digitare:

    ```bash
    docker image  ls
    ```

## Avviare il contenitore RockyDocs

1. Avvia un contenitore dall'immagine di rockydocs. Digitare:

    ```bash
    docker run -it --name rockydoc --rm \
        -p 8000:8000  \
        --mount type=bind,source="$(pwd)"/documentation,target=/documentation  \
        wsoyinka/rockydocs:latest
    ```

    In alternativa, se si preferisce e se si ha installato `docker-compose`, si può creare un file di composizione chiamato `docker-compose.yml` con i seguenti contenuti:

    ```bash
    version: "3.9"
    services:
      rockydocs:
        image: wsoyinka/rockydocs:latest
        volumes:
          - type: bind
            source: ./documentation
            target: /documentation
        container_name: rocky
        ports:
          - "8000:8000"
    ```

    Salvare il file con il nome `docker-compose.yml` nella cartella di lavoro $ROCKYDOCS.  E avviare il servizio/contenitore eseguendo:

    ```bash
    docker-compose  up
    ```

## Visualizzare il sito web locale docs.rockylinux.org

Con il contenitore attivo e funzionante, ora si dovrebbe essere in grado di puntare il browser web al seguente URL per visualizzare la copia locale del sito:

<http://localhost:8000>
