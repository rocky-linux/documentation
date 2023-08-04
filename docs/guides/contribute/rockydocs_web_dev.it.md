---
title: Documentazione locale - Docker
author: Wale Soyinka
contributors: Steve Spencer, Franco Colussi
update: 05-Mar-2022
---

# Esecuzione di una copia locale del sito docs.rockylinux.org per lo sviluppo web e/o gli autori di contenuti

Questo documento spiega come ricreare ed eseguire una copia locale dell'intero sito docs.rockylinux.org sulla tua macchina locale. **È un lavoro in corso.**

Eseguire una copia locale del sito web della documentazione potrebbe essere utile nei seguenti scenari:

* Sei interessato a conoscere e contribuire agli aspetti di sviluppo web del sito docs.rockylinux.org
* Sei un autore e vorresti vedere come i tuoi documenti saranno renderizzati/visualizzati sul sito web di docs prima di contribuirvi
* Sei uno sviluppatore web che cerca di contribuire o aiutare a mantenere il sito docs.rockylinux.org


### Alcune note:

* Le istruzioni di questa guida **NON** sono un prerequisito per gli Autori/Contributori della documentazione Rocky
* L'intero ambiente gira in un container Docker e quindi avrai bisogno di un motore Docker sulla tua macchina locale
* Il container è costruito sopra l'immagine docker ufficiale di RockyLinux disponibile qui https://hub.docker.com/r/rockylinux/rockylinux
* Il container conserva il contenuto della documentazione (guide, libri, immagini e così via) separato dal motore web (mkdocs)
* Il container avvia un server web locale in ascolto sulla porta 8000.  E la porta 8000 sarà inoltrata all'host Docker


## Creare l'ambiente dei contenuti

1. Cambiate la directory di lavoro corrente sul vostro sistema locale in una cartella dove intendete scrivere. Ci riferiremo a questa directory come `$ROCKYDOCS` nel resto di questa guida.  Per la nostra demo qui, `$ROCKYDOCS` punta a `~/projects/rockydocs` sul nostro sistema demo.

Create $ROCKYDOCS se non esiste già e poi digitate:

```
cd  $ROCKYDOCS
```

2. Assicurati di avere `git` installato (`dnf -y install git`).  Mentre sei in $ROCKYDOCS usa git per clonare il repo ufficiale dei contenuti della Documentazione Rocky. Digitate:

```
git clone https://github.com/rocky-linux/documentation.git
```

Ora avrai una cartella `$ROCKYDOCS/documentation`. Questa cartella è un repository git e sotto il controllo di git.


## Creare e avviare l'ambiente di sviluppo web RockyDocs

3.  Assicurati di avere Docker attivo e funzionante sulla tua macchina locale (puoi controllare con `systemctl`)

4. Da un terminale, digita:

```
docker pull wsoyinka/rockydocs:latest
```

5. Controlla che l'immagine sia stata scaricata con successo. Digita:

```
docker image  ls
```

## Avviare il container RockyDocs

1. Avviare il container RockyDocs. Digita:

```
docker run -it --name rockydoc --rm \
     -p 8000:8000  \
     --mount type=bind,source="$(pwd)"/documentation,target=/documentation  \
     wsoyinka/rockydocs:latest

```


In alternativa, se preferisci e se hai installato `docker-compose`, puoi creare un file di composizione chiamato `docker-compose.yml` con i seguenti contenuti:

```
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

Salva il file con il nome `docker-compose.yml` nella tua directory di lavoro $ROCKYDOCS.  E avvia il servizio/container eseguendo:

```
docker-compose  up
```


## Visualizza il sito web locale docs.rockylinux.org

Con il container attivo e funzionante, dovresti ora essere in grado di puntare il tuo browser web al seguente URL per visualizzare la tua copia locale del sito:

http://localhost:8000
