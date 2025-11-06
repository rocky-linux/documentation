---
title: Metodo con lo script RockyDocs
author: Wale Soyinka
contributors: Ganna Zhyrnova
update: 11-Set-2025
---

# Esecuzione di una copia in locale del sito web docs.rockylinux.org utilizzando lo script RockyDocs

Questo documento illustra come utilizzare lo script automatizzato `rockydocs.sh` per ricreare ed eseguire una copia identica alla versione di produzione dell'intero sito web docs.rockylinux.org sul proprio computer locale.

Lo script RockyDocs offre un approccio moderno e automatizzato che elimina la complessità della configurazione manuale presente in altri metodi, garantendo al contempo un comportamento di produzione preciso.

Eseguire una copia locale del sito web della documentazione potrebbe essere utile nei seguenti scenari:

- Si è un autore di documentazione e si desidera visualizzare in anteprima l'esatto aspetto che avrà il vostro contenuto sul sito web live.
- Si desidera testare i propri contributi su più versioni di Rocky Linux (8, 9 e 10) a livello locale.
- Si è interessati a conoscere o contribuire all'infrastruttura della documentazione
- È necessario verificare che i contenuti vengano visualizzati correttamente con il selettore di versione e la navigazione.

## Prerequisiti

Lo script RockyDocs gestisce automaticamente la maggior parte delle dipendenze, ma si avrà bisogno di:

- Un sistema Linux o macOS (Windows con WSL2 dovrebbe funzionare)
- `git` installato sul tuo sistema
- Python 3.8+ con `pip` OPPURE Docker (lo script supporta entrambi gli ambienti)
- Circa 2 GB di spazio libero su disco per l'ambiente completo

Lo script verificherà e installerà automaticamente altri strumenti necessari come `mkdocs`, `mike` e vari plugin.

## Configurazione dell'ambiente dei contenuti

1. Passare alla directory in cui si desidera lavorare con la documentazione di Rocky Linux. Ci riferiremo a questa come alla directory dell'area di lavoro.

    ```bash
    mkdir -p ~/rocky-projects
    cd ~/rocky-projects
    ```

2. Clonare il repository ufficiale della documentazione di Rocky Linux:

    ```bash
    git clone https://github.com/rocky-linux/documentation.git
    cd documentation
    ```

   Ora si dispone dell'archivio dei contenuti con lo script automatizzato `rockydocs.sh` incluso.

## Opzioni di avvio rapido con lo script RockyDocs

Lo script RockyDocs offre diverse opzioni di flusso di lavoro per soddisfare le diverse esigenze dei collaboratori. Scegliere l'opzione più adatta al proprio flusso di lavoro di scrittura e revisione.

!!! note "Comprendere il Processo a Tre-Fasi"
    **Setup** (una tantum): crea un ambiente di compilazione con ambiente virtuale Python e installa gli strumenti MkDocs. Imposta anche la configurazione della lingua (minima o completa) che verrà utilizzata per tutte le distribuzioni successive. Questo crea una directory di lavoro separata per i file di compilazione, mantenendo pulito il repository dei contenuti.

    **Deploy**: crea tutte le versioni di Rocky Linux (8, 9, 10) in un sito web completo e versionato utilizzando Mike e la configurazione della lingua impostata durante l'installazione. Questo crea la struttura multiversione che vedete su docs.rockylinux.org.
    
    **Serve**: avvia un server web locale per visualizzare in anteprima le modifiche. La modalità statica serve file precompilati (identici alla produzione), mentre la modalità live consente il ricaricamento automatico quando si modificano i contenuti.

## Personalizzazione del percorso dell'area di lavoro

Per impostazione predefinita, lo script crea un'area di lavoro in `../rockydocs-workspaces/` relativa al repository dei contenuti. È possibile personalizzare questo percorso utilizzando l'opzione `--workspace`:

```bash
# Use a custom workspace location
./rockydocs.sh --setup --venv --workspace ~/my-docs-workspace

# The script remembers your choice for future commands
./rockydocs.sh --deploy
./rockydocs.sh --serve --static
```

!!! tip "Vantaggi dell'Area di Lavoro"
    - Mantiene pulito il repository dei contenuti dai file compilati
    - Consente a più progetti di documentazione di condividere lo stesso ambiente di compilazione
    - Salva automaticamente le preferenze dell'area di lavoro per i comandi futuri
    - Riutilizza in modo intelligente i repository esistenti per risparmiare spazio su disco e tempo di clonazione

    

### Opzione 1: Anteprima identica a quella in produzione (consigliata per la revisione finale)

Questa opzione offre la stessa identica esperienza del sito web live docs.rockylinux.org, perfetta per la revisione finale dei contenuti e i test.

1. **Configurazione dell'ambiente** (configurazione una tantum):

    ```bash
    # Basic setup (creates workspace in ../rockydocs-workspaces/)
    ./rockydocs.sh --setup --venv
    
    # Alternative: Custom workspace location
    ./rockydocs.sh --setup --venv --workspace ~/my-docs-workspace
    ```

2. **Creare tutte le versioni della documentazione**:

    ```bash
    ./rockydocs.sh --deploy
    ```

3. **Avvia il sito web identico a quello in produzione**:

    ```bash
    ./rockydocs.sh --serve --static
    ```

       !!! tip "Modalità Servizio Statico"
               Questo serve file statici predefiniti esattamente come nella produzione senza reindirizzamenti. Perfetto per verificare come appariranno i contenuti sul sito live. L'URL principale (`http://localhost:8000/`) fornisce direttamente i contenuti più recenti, proprio come docs.rockylinux.org.

        ```
         **Note**: È necessario eseguire nuovamente `--deploy` per visualizzare le modifiche al contenuto, poiché questo serve i file precompilati.
        ```

       !!! note "Supporto Lingue"
               Per impostazione predefinita, lo script crea versioni in lingua inglese e ucraina per una configurazione e una compilazione più rapide. Per eseguire il test completo con tutte le lingue disponibili, utilizzare il flag `--full`:

        ```
         ```bash
         # Full language support setup (config set once)
         ./rockydocs.sh --setup --venv --full
         # Deploy uses setup's language configuration automatically
         ./rockydocs.sh --deploy
         ```
        ```

### Opzione 2: Modalità di sviluppo live (ideale per la scrittura attiva)

Questa opzione aggiorna automaticamente il browser quando si modifica i file dei contenuti, ideale per sessioni di scrittura attive.

1. **Configurazione dell'ambiente** (configurazione una tantum):

    ```bash
    # Basic setup
    ./rockydocs.sh --setup --venv
    
    # Alternative: Custom workspace location
    ./rockydocs.sh --setup --venv --workspace ~/my-docs-workspace
    ```

2. **Creare tutte le versioni della documentazione**:

    ```bash
    ./rockydocs.sh --deploy
    ```

3. **Avvia il server di sviluppo live**:

    ```bash
    ./rockydocs.sh --serve
    ```

       !!! tip "Modalità Sviluppo Live"
               Questo consente il ricaricamento in tempo reale: modifica qualsiasi file Markdown nella directory `docs/` e visualizza immediatamente le modifiche nel browser. Perfetto per scrivere e modificare contenuti in modo attivo. Le modifiche vengono visualizzate automaticamente senza bisogno di eseguire nuovamente `--deploy`.

        ```
         **Note**: può includere reindirizzamenti e comportamenti leggermente diversi da quello in produzione. Utilizzare la modalità statica per la verifica finale.
        ```

### Opzione 3: Modalità doppio server (il meglio di entrambi i mondi)

Questa opzione esegue due server contemporaneamente, offrendoti sia la navigazione completa del sito che funzionalità di modifica dei contenuti in tempo reale.

1. **Configurazione dell'ambiente** (configurazione una tantum):

    ```bash
    # Basic setup
    ./rockydocs.sh --setup --venv
    
    # Alternative: Custom workspace location
    ./rockydocs.sh --setup --venv --workspace ~/my-docs-workspace
    ```

2. **Creare tutte le versioni della documentazione**:

    ```bash
    ./rockydocs.sh --deploy
    ```

3. **Avviare i dual server**:

    ```bash
    ./rockydocs.sh --serve-dual
    ```

       !!! tip "Modalità Dual Server"
               Questo fa funzionare due server contemporaneamente per ottenere il meglio da entrambi i mondi:

        ```
        - **Port 8000**: Mike serve with full version selector and site navigation
         - **Port 8001**: MkDocs live reload for instant content updates
         
         Switch between ports depending on whether you need live editing (8001) or full site testing (8000). This mode is ideal for contributors who want both immediate content feedback and complete site navigation testing.
        ```

### Opzione 4: Ambiente Docker

Se si preferiscono gli ambienti containerizzati o non si desidera installare le dipendenze Python localmente, puoi utilizzare le versioni Docker di qualsiasi modalità di servizio.

!!! note "Benefici dell'Ambiente Docker"
    - **Ambiente isolato**: nessun impatto sull'installazione locale di Python o sulle dipendenze di sistema
    - **Build coerenti**: stesso ambiente container su macchine diverse
    - **Facile pulizia**: basta rimuovere i container e le immagini al termine
    - **Tutte le modalità di servizio**: supporta le modalità server statica, live e doppia nei container

1.     

    ```bash
    # Basic Docker setup
    ./rockydocs.sh --setup --docker
    
    # Alternative: Custom workspace location
    ./rockydocs.sh --setup --docker --workspace ~/my-docs-workspace
    ```

2. **Compilare tutte le versioni nei container**:

    ```bash
    ./rockydocs.sh --deploy --docker
    ```

3. **Scegliere la modalità Docker serving**:

    ```bash
     Production-identical (static)
    ./rockydocs.sh --serve --docker --static
    
    # Live development with auto-reload
    ./rockydocs.sh --serve --docker
    
    # Dual servers (containerized)
    ./rockydocs.sh --serve-dual --docker
    ```

## Visualizzare il sito web della documentazione in locale

Con entrambi i metodi, ora è possibile visualizzare la copia in locale del sito web aprendo il browser web all'indirizzo:

**<http://localhost:8000>**

Si dovrebbe vedere:

- Il sito web completo della documentazione di Rocky Linux
- Funzionalità complete di navigazione e ricerca
- Selettore versione nella barra di navigazione superiore
- Tutti i contenuti esattamente come appaiono sul sito di produzione
- Nessun comportamento di reindirizzamento: le pagine vengono caricate direttamente

## Comandi script disponibili

Lo script `rockydocs.sh` fornisce diversi comandi utili:

### Comandi principali del flusso di lavoro

```bash
# Setup commands (run once)
./rockydocs.sh --setup --venv --minimal     # Python virtual environment setup
./rockydocs.sh --setup --docker --minimal   # Docker containerized setup

# Deployment commands (build the site)
./rockydocs.sh --deploy --minimal           # Build all versions (venv)
./rockydocs.sh --deploy --docker --minimal  # Build all versions (Docker)

# Serving commands (start the local website)
./rockydocs.sh --serve --static             # Production-identical static server (venv)
./rockydocs.sh --serve --docker --static    # Production-identical static server (Docker)
./rockydocs.sh --serve                      # Live development server with auto-reload (venv)
./rockydocs.sh --serve --docker             # Live development server with auto-reload (Docker)
./rockydocs.sh --serve-dual                 # Dual servers: mike serve + mkdocs live reload (venv)
./rockydocs.sh --serve-dual --docker        # Dual servers: containerized version (Docker)
```

### Comandi di manutenzione e informazione

```bash
./rockydocs.sh --status                     # Mostra lo stato e le informazioni sull'ambiente
./rockydocs.sh --clean                      # Pulisce l'area di lavoro e gli artefatti di compilazione
./rockydocs.sh --reset                      # Ripristina la configurazione salvata
./rockydocs.sh --help                       # Mostra informazioni dettagliate sulla guida
```

## Lavorare su diverse versioni di Rocky Linux

Lo script rileva automaticamente la versione su cui si sta lavorando in base al branch git:

```bash
# Switch to different versions in your content repository
git checkout rocky-8    # Work on Rocky Linux 8 documentation
git checkout rocky-9    # Work on Rocky Linux 9 documentation
git checkout main       # Work on Rocky Linux 10 documentation

# Rebuild with your changes
./rockydocs.sh --deploy --minimal
```

Le modifiche apportate appariranno nella versione corrispondente quando si visualizzerà il sito web locale.

## Comprendere la struttura della cartella

Lo script RockyDocs crea una netta separazione tra i tuoi contenuti e l'ambiente di compilazione:

```
~/rocky-projects/documentation/          # Your content repository (where you edit)
├── docs/                                # Your content files (guides, books, etc.)
├── rockydocs.sh                         # The script
└── .git/                               # Your content git repository

~/rockydocs-workspaces/                  # Build workspace (created by script)
├── docs.rockylinux.org/                # Main build environment
│   ├── venv/                           # Python virtual environment
│   ├── worktrees/                      # Cached copies of doc versions
│   │   ├── main/                       # Rocky Linux 10 content cache
│   │   ├── rocky-8/                    # Rocky Linux 8 content cache  
│   │   └── rocky-9/                    # Rocky Linux 9 content cache
│   ├── site-static/                    # Static site files (for --static mode)
│   ├── content -> worktrees/main/docs  # Symlink to your current version
│   ├── mkdocs.yml                      # Build configuration
│   └── .git/                          # Local build repository
└── app -> docs.rockylinux.org          # Compatibility symlink
```

**Punti chiave.**

- Il nostro archivio dei contenuti rimane pulito: nessun file di compilazione o dipendenze
- L'area di lavoro di compilazione è completamente separata e può essere eliminata in tutta sicurezza.
- Lo script gestisce automaticamente il collegamento simbolico `content` in base al vostro ramo git corrente.
- Gli alberi di lavoro memorizzati nella cache evitano il download ripetuto di contenuti per diverse versioni di Rocky.
- Il comando `--clean` rimuove l'intero spazio di lavoro di compilazione, se necessario.

## Aggiornamento dell'ambiente

Per ottenere le ultime modifiche dai repository ufficiali:

```bash
# This updates both the build environment and content
./rockydocs.sh --deploy --minimal
```

Lo script recupera automaticamente gli aggiornamenti da tutti i rami della documentazione di Rocky Linux.

## Troubleshooting

Se si riscontrano dei problemi:

1. **Controllare lo stato del sistema**:
    ```bash
    ./rockydocs.sh --status
    ```

2. **Ripulire e ricompilare**:
    ```bash
    ./rockydocs.sh --clean
    ./rockydocs.sh --setup --venv --minimal
    ./rockydocs.sh --deploy --minimal
    ```

3. **Ottenere assistenza dettagliata**:
    ```bash
    ./rockydocs.sh --help
    ./rockydocs.sh --setup --help
    ./rockydocs.sh --serve --help
    ```

## Come le modifiche vengono trasferite al sito costruito

Comprendere in che modo lo script RockyDocs collega le modifiche locali al sito web pubblicato aiuta a spiegare perché sono state prese determinate decisioni di progettazione e come le modifiche apportate vengono visualizzate nella documentazione creata.

### La sfida fondamentale

Lo script deve svolgere tre funzioni contemporaneamente:

1. Consente di modificare nel repository locale
2. Crea più versioni di Rocky Linux (8, 9, 10) con il contesto git appropriato
3. Riporta immediatamente le modifiche apportate in tempo reale nelle build

### Panoramica della struttura delle directory

```
Your editing environment:
~/rocky-projects/documentation/          ← You edit here
├── docs/                               ← Your live content
├── .git/                              ← Your git repository  
└── rockydocs.sh

Build environment (separate):
../rockydocs-workspaces/docs.rockylinux.org/
├── content → (symlink target varies)   ← MkDocs reads from here
├── mkdocs.yml (docs_dir: "content")    ← Always points to symlink
├── worktrees/                          ← Cached content for other versions
│   ├── main/docs/      ← Rocky 10 cached content
│   ├── rocky-8/docs/   ← Rocky 8 cached content  
│   └── rocky-9/docs/   ← Rocky 9 cached content
└── venv/
```

### La Strategia Smart Symlink

L'innovazione chiave è un Symlink dinamico chiamato “content” nell'ambiente di compilazione. Quest symlink simbolico cambia la sua destinazione in base a ciò su cui stai attualmente lavorando:

#### Quando si modifica Rocky Linux 10 (ramo principale):

```bash
# Your context:
cd ~/rocky-projects/documentation
git branch  # Shows: * main

# When you run: ./rockydocs.sh --deploy
# Script creates: content → ~/rocky-projects/documentation/docs

# Result: Your live edits appear immediately in builds
```

#### Quando si compilano altre versioni:

```bash
# Script builds Rocky 8:
# content → ../worktrees/rocky-8/docs (cached Rocky 8 content)

# Script builds Rocky 9:  
# content → ../worktrees/rocky-9/docs (cached Rocky 9 content)
```

### Perchè Questa Struttura?

**Main Branch → Sono i File Live:**

- Stai modificando attivamente i contenuti di Rocky Linux 10
- Ricaricamento in tempo reale: salva il file e visualizza immediatamente le modifiche nel browser
- Utilizza la cronologia git del vostro repository per ottenere timestamp accurati

**Altri Branches → Worktrees memorizzati nella cache:**

- È possibile che localmente non siano presenti i rami rocky-8/rocky-9.
- Fornisce un contesto git completo per ogni versione di Rocky
- Consente di creare tutte le versioni senza influire sul flusso di lavoro

### Esempio Completo di Flusso di Compilazione

```bash
# 1. You edit in your repo
cd ~/rocky-projects/documentation
echo "New troubleshooting tip" >> docs/guides/myguide.md

# 2. You deploy and serve
./rockydocs.sh --deploy
./rockydocs.sh --serve

# 3. Script creates symlink in build environment
# content → ~/rocky-projects/documentation/docs

# 4. MkDocs builds from your live files
# Your changes appear immediately in the local website
```

### I Benefici di Questa Architettura

1. **Modifica immediata Riflessione**: le modifiche vengono visualizzate immediatamente senza necessità di ricostruzione.
2. **Supporto multi-versione**: è possibile compilare tutte le versioni Rocky con il contesto git appropriato.
3. **Separazione pulita**: il tuo flusso di lavoro git rimane completamente inalterato
4. **Conservazione della cronologia Git**: ogni versione è dotata di timestamp accurati e informazioni sull'autore.
5. **Sviluppo flessibile**: cambia ramo, lo script si adatta automaticamente

Il sumlink funge da “puntatore intelligente” che MkDocs segue per trovare i contenuti, mentre lo script lo reindirizza dinamicamente in base a ciò su cui stai attualmente lavorando. Questo spiega perché lo script deve clonare i repository separatamente: crea un ambiente di compilazione pulito mantenendo intatto l'ambiente di modifica.

## Note

- Lo script RockyDocs crea uno spazio di lavoro **al di fuori** del repository dei contenuti per mantenere pulito il flusso di lavoro git.
- Tutti gli ambienti sono completamente in locale: nulla viene caricato o pubblicato automaticamente.
- Lo script gestisce automaticamente le dipendenze, i conflitti di porta e la pulizia.
- Sia l'ambiente virtuale Python che i metodi Docker offrono funzionalità identiche.
- Il sito web locale include lo stesso identico tema, la stessa navigazione e le stesse funzionalità del sito di produzione.
- E' possibile sperimentare in tutta sicurezza modifiche ai contenuti: il proprio ambiente locale è completamente isolato.
- Lo script conserva automaticamente la cronologia git per garantire la precisione dei timestamp dei documenti.
