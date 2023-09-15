---
title: Metodo VENV di Python
author: Franco Colussi
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 8.7, 9.1
tags:
  - mkdocs
  - testing
  - documentation
---

# MkDocs (Python Virtual Enviroment)

## Introduzione

Uno degli aspetti del processo di creazione della documentazione per Rocky Linux è la verifica della corretta visualizzazione del nuovo documento prima della pubblicazione.

Lo scopo di questa guida è fornire alcuni suggerimenti per eseguire questo compito in un ambiente python locale dedicato esclusivamente a questo scopo.

La documentazione di Rocky Linux è scritta utilizzando il linguaggio Markdown, generalmente convertito a sua volta in altri formati. Markdown è pulito nella sintassi e particolarmente adatto alla scrittura di documentazione tecnica.

Nel nostro caso, la documentazione viene convertita in `HTML` utilizzando un'applicazione python che si occupa della costruzione del sito statico. L'applicazione utilizzata dagli sviluppatori è [MkDocs](https://www.mkdocs.org/).

Un problema che si presenta durante lo sviluppo di un'applicazione python è quello di isolare l'istanza python utilizzata per lo sviluppo dall'interprete di sistema. La separazione previene le incompatibilità tra i moduli necessari per l'installazione dell'applicazione Python e quelli installati sul sistema host.

Esistono già ottime guide che utilizzano i **container** per isolare l'interprete python. Queste guide, tuttavia, presuppongono la conoscenza delle varie tecniche di containerizzazione.

In questa guida viene utilizzato il modulo `venv` fornito dal pacchetto *python* di Rocky Linux per la separazione. Questo modulo è disponibile su tutte le nuove versioni di *Python* a partire dalla versione 3.6. In questo modo si otterrà direttamente l'isolamento dell'interprete python sul sistema senza la necessità di installare e configurare nuovi**"sistemi**".

### Requisiti

- una copia funzionante di Rocky Linux
- il pacchetto *python* installato correttamente
- familiarità con la riga di comando
- una connessione internet attiva

## Preparazione dell'ambiente

L'ambiente fornisce una cartella principale contenente i due repository Rocky Linux GitHub necessari e la cartella in cui avviene l'inizializzazione e l'esecuzione della copia di python nell'ambiente virtuale.

Per prima cosa, create la cartella che conterrà tutto il resto e, contestualmente, create anche la cartella **env** dove verrà eseguito MkDocs:

```bash
mkdir -p ~/lab/rockydocs/env
```

### Ambiente virtuale Python

Per creare la vostra copia di Python in cui verrà eseguito MkDocs, utilizzate il modulo appositamente sviluppato per questo scopo, il modulo python `venv.`  Questo permette di creare un ambiente virtuale, derivato da quello installato sul sistema, totalmente isolato e indipendente.

Questo ci permetterà di avere una copia, in una cartella separata, dell'interprete con solo i pacchetti richiesti da `MkDocs` per eseguire la documentazione Rocky Linux.

Andare nella cartella appena creata*(rockydocs*) e creare l'ambiente virtuale con:

```bash
cd ~/lab/rockydocs/
python -m venv env
```

Il comando popolerà la cartella **env** con una serie di cartelle e file che imitano l'albero *python* del sistema, come mostrato qui:

```text
env/
├── bin
│   ├── activate
│   ├── activate.csh
│   ├── activate.fish
│   ├── Activate.ps1
│   ├── pip
│   ├── pip3
│   ├── pip3.11
│   ├── python -> /usr/bin/python
│   ├── python3 -> python
│   └── python3.11 -> python
├── include
│   └── python3.11
├── lib
│   └── python3.11
├── lib64 -> lib
└── pyvenv.cfg
```

Come si può vedere, l'interprete python usato dall'ambiente virtuale è ancora quello disponibile sul sistema `python -> /usr/bin/python`. Il processo di virtualizzazione si occupa solo di isolare l'istanza.

#### Attivazione dell'ambiente virtuale

Tra i file elencati nella struttura, ci sono diversi file denominati **activate** che servono a questo scopo. Il suffisso di ogni file indica la relativa *shell*.

L'attivazione separa questa istanza python dall'istanza python di sistema e consente di eseguire lo sviluppo della documentazione senza interferenze. Per attivarlo, andare nella cartella *env* ed eseguire il comando:

```bash
[rocky_user@rl9 rockydocs]$ cd ~/lab/rockydocs/env/
[rocky_user@rl9 env]$ source ./bin/activate
```

Il comando *activate* è stato emesso senza alcun suffisso perché si riferisce alla shell *bash*, la shell predefinita di Rocky Linux. A questo punto il *prompt della shell* dovrebbe essere:

```bash
(env) [rocky_user@rl9 env]$
```

Come si può notare, la parte iniziale *(env)* indica che ci si trova nell'ambiente virtuale. La prima cosa da fare a questo punto è aggiornare **pip**, il gestore di moduli python usato per installare MkDocs. Per farlo, utilizzare il comando:

```bash
python -m pip install --upgrade pip
```

```bash
python -m pip install --upgrade pip
Requirement already satisfied: pip in ./lib/python3.9/site-packages (21.2.3)
Collecting pip
  Downloading pip-23.1-py3-none-any.whl (2.1 MB)
    |████████████████████████████████| 2.1 MB 1.6 MB/s
Installing collected packages: pip
  Attempting uninstall: pip
    Found existing installation: pip 21.2.3
    Uninstalling pip-21.2.3:
      Successfully uninstalled pip-21.2.3
Successfully installed pip-23.1
```

#### Disattivare l'ambiente

Per uscire dall'ambiente virtuale, utilizzare il comando *deactivate*:

```bash
(env) [rocky_user@rl9 env]$ deactivate
[rocky_user@rl9 env]$
```

Come si può vedere, il terminale *prompt* è tornato a quello di sistema dopo la disattivazione. Si consiglia di controllare sempre attentamente il prompt prima di eseguire l'installazione di *MkDocs* e i comandi successivi. Selezionando questa opzione si evitano installazioni di applicazioni globali non necessarie e indesiderate e la mancata esecuzione di `mkdocs serve`.

### Scaricare i repository

Ora che avete visto come creare il vostro ambiente virtuale e come gestirlo, potete passare alla preparazione di tutto il necessario.

Per implementare una versione locale della documentazione di Rocky Linux sono necessari due repository: il repository della [documentazione](https://github.com/rocky-linux/documentation) e il repository della struttura del sito [docs.rockylinux.org](https://github.com/rocky-linux/docs.rockylinux.org). Il download di questi file viene effettuato dal Rocky Linux GitHub.

Si inizia con il repository della struttura del sito, che verrà clonato nella cartella **rockydocs**:

```bash
cd ~/lab/rockydocs/
git clone https://github.com/rocky-linux/docs.rockylinux.org.git
```

In questa cartella ci sono due file che verranno utilizzati per costruire la documentazione locale. Sono **mkdocs.yml**, il file di configurazione usato per inizializzare MkDocs, e **requirement.txt**, che contiene tutti i pacchetti python necessari per installare *mkdocs*.

Al termine, è necessario scaricare anche il repository della documentazione:

```bash
git clone https://github.com/rocky-linux/documentation.git
```

A questo punto, nella cartella **rockydocs** si avrà la seguente struttura:

```text
rockydocs/
├── env
├── docs.rockylinux.org
├── documentation
```

Schematizzando, si può dire che la cartella **env** sarà il motore *MkDocs* che userà **docs.rockylinux.org** come contenitore per visualizzare i dati contenuti nella **documentation**.

### Installazione di MkDocs

Come sottolineato in precedenza, gli sviluppatori di Rocky Linux forniscono il file **requirement.txt**, che contiene l'elenco dei moduli necessari per la corretta esecuzione di un'istanza personalizzata di MkDocs. Il file verrà utilizzato per installare tutto il necessario in un'unica operazione.

Per prima cosa si entra nel proprio ambiente virtuale python:

```bash
[rocky_user@rl9 rockydocs]$ cd ~/lab/rockydocs/env/
[rocky_user@rl9 env]$ source ./bin/activate
(env) [rocky_user@rl9 env]$
```

Quindi, procedete all'installazione di MkDocs e di tutti i suoi componenti con il comando:

```bash
(env) [rocky_user@rl9 env]$ python -m pip install -r ../docs.rockylinux.org/requirements.txt
```

Per verificare che tutto sia andato bene, si può richiamare la guida di MkDocs, che ci introduce anche ai comandi disponibili:

```bash
(env) [rocky_user@rl9 env]$ mkdocs -h
Usage: mkdocs [OPTIONS] COMMAND [ARGS]...

  MkDocs - Project documentation with Markdown.

Options:
  -V, --version  Show the version and exit.
  -q, --quiet    Silence warnings
  -v, --verbose  Enable verbose output
  -h, --help     Show this message and exit.

Commands:
  build      Build the MkDocs documentation
  gh-deploy  Deploy your documentation to GitHub Pages
  new        Create a new MkDocs project
  serve      Run the builtin development server
```

Se tutto ha funzionato come previsto, si può uscire dall'ambiente virtuale e iniziare a preparare le connessioni necessarie.

```bash
(env) [rocky_user@rl9 env]$ deactivate
[rocky_user@rl9 env]$
```

### Collegamento della documentazione

Ora che tutto è disponibile, è necessario collegare il repository della documentazione all'interno del sito contenitore *docs.rockylinux.org*. Seguendo la configurazione definita in *mkdocs.yml*:

```yaml
docs_dir: 'docs/docs'
```

Per prima cosa è necessario creare una cartella **docs** in **docs.rockylinux.org** e poi, all'interno di essa, collegare la cartella **docs** dal repository **della documentazione**.

```bash
cd ~/lab/rockydocs/docs.rockylinux.org
mkdir docs
cd docs/
ln -s ../../documentation/docs/ docs
```

## Avvio della documentazione locale

Ora si è pronti ad avviare la copia locale della documentazione di Rocky Linux. Per prima cosa è necessario avviare l'ambiente virtuale python e poi inizializzare l'istanza di MkDocs con le impostazioni definite in **docs.rockylinux.org/mkdocs.yml**.

Questo file contiene tutte le impostazioni per la localizzazione, le funzionalità e la gestione dei temi.

Gli sviluppatori dell'interfaccia utente del sito hanno scelto il tema [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/), che offre molte funzionalità e personalizzazioni aggiuntive rispetto al tema predefinito di MkDocs.

Eseguire i seguenti comandi:

```bash
[rocky_user@rl9 rockydocs]$ cd ~/lab/rockydocs/env/
[rocky_user@rl9 rockydocs]$ source ./bin/activate
(env) [rocky_user@rl9 env]$ mkdocs serve -f ../docs.rockylinux.org/mkdocs.yml
```

Nel vostro terminale dovreste vedere l'inizio della costruzione del sito. Il display mostrerà tutti gli errori riscontrati da MkDocs, come collegamenti mancanti o altro:

```text
INFO     -  Building documentation...
INFO     -  Adding 'de' to the 'plugins.search.lang' option
INFO     -  Adding 'fr' to the 'plugins.search.lang' option
INFO     -  Adding 'es' to the 'plugins.search.lang' option
INFO     -  Adding 'it' to the 'plugins.search.lang' option
INFO     -  Adding 'ja' to the 'plugins.search.lang' option
...
...
INFO     -  Documentation built in 102.59 seconds
INFO     -  [11:46:50] Watching paths for changes:
            '/home/rocky_user/lab/rockydocs/docs.rockylinux.org/docs/docs',
            '/home/rocky_user/lab/rockydocs/docs.rockylinux.org/mkdocs.yml'
INFO     -  [11:46:50] Serving on http://127.0.0.1:8000/
```

La copia del sito di documentazione sarà in esecuzione quando si aprirà il browser all'indirizzo specificato (http://1127.0.0.1:8000). La copia rispecchia perfettamente il sito online in termini di funzionalità e struttura, consentendovi di valutare l'aspetto e l'impatto che la vostra pagina avrà sul sito.

MkDocs incorpora un meccanismo di controllo delle modifiche apportate ai file nella cartella specificata dal percorso `docs_dir`; l'inserimento di una nuova pagina o la modifica di una esistente in `documentation/docs` verrà automaticamente riconosciuta e produrrà una nuova creazione del sito statico.

Poiché il tempo necessario a MkDocs per costruire il sito statico può essere di diversi minuti, si consiglia di esaminare attentamente la pagina che si sta scrivendo prima di salvarla o inserirla. In questo modo si evita di attendere la costruzione del sito solo perché si è dimenticata, ad esempio, la punteggiatura.

### Uscire dall'ambiente di sviluppo

Quando la visualizzazione della nuova pagina è soddisfacente, si può uscire dall'ambiente di sviluppo. Questo comporta prima l'uscita da *MkDocs* e poi la disattivazione dell'ambiente virtuale python. Per uscire da *MkDocs* è necessario utilizzare la combinazione di tasti <kbd>CTRL</kbd> + <kbd>C</kbd> e, come visto in precedenza, per uscire dall'ambiente virtuale è necessario richiamare il comando di `deactivate`.

```bash
...
INFO     -  [22:32:41] Serving on http://127.0.0.1:8000/
^CINFO     -  Shutting down...
(env) [rocky_user@rl9 env]$
(env) [rocky_user@rl9 env]$ deacticate
[rocky_user@rl9 env]$
```

## Conclusioni e considerazioni finali

La verifica delle nuove pagine in un sito di sviluppo locale ci assicura che il vostro lavoro sarà sempre conforme al sito di documentazione online, consentendovi di contribuire in modo ottimale.

La conformità dei documenti è di grande aiuto anche per i curatori del sito della documentazione, che dovranno occuparsi solo della correttezza dei contenuti.

In conclusione, si può dire che questo metodo consente di soddisfare i requisiti per un'installazione "pulita" di MkDocs senza dover ricorrere alla containerizzazione.
