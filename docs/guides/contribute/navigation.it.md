---
title: Modifiche alla Navigazione
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tags:
  - contribute
  - navigation
---

# Modifiche alla navigazione - Un documento di procedure per manager o redattori

## Motivo del documento

Quando è iniziato il progetto di documentazione, si sperava che i menu di Mkdocs fossero il più possibile automatici, rendendo rara la modifica manuale della navigazione. Dopo alcuni mesi di generazione di documenti, è diventato chiaro che non si poteva fare affidamento sul fatto che Mkdocs si limitasse a inserire i documenti nella cartella corretta e a generare la navigazione per mantenere le cose pulite e ordinate. Avevamo bisogno di categorie, che Mkdocs non fornisce a meno che i documenti non siano inseriti in cartelle specifiche. Mkdocs creerà quindi una navigazione con un ordinamento alfabetico. Tuttavia, la creazione di una struttura di cartelle che risolva la navigazione non è l'unica soluzione. Anche questo a volte richiede ulteriori modifiche per mantenere l'organizzazione. Ad esempio, la capitalizzazione senza modificare la struttura delle cartelle in minuscolo.

## Obiettivi

I nostri obiettivi erano:

* Creare ora la struttura di cartelle necessaria (in futuro potrebbero essere necessarie nuove cartelle)
* Regolare la navigazione in modo che le aree Installazione Rocky, Migrazione e Contributo siano in alto
* Adattare la navigazione in modo da assegnare un nome migliore ad alcune cartelle e da consentire una corretta capitalizzazione. Ad esempio, "DNS" e "Servizi di Condivisione File" vengono visualizzati come "Dns" e "Condivisione file" senza alcuna manipolazione.
* Assicurarsi che questi file di navigazione vengano riservati ai Manager e ai Redattori

Quest'ultimo punto può sembrare superfluo a chi sta leggendo, ma diventerà più evidente man mano che il documento prosegue.

## Presupposto

Si presuppone che si abbia un clone locale del repository Rocky GitHub: [https://github.com/rocky-linux/documentation.](https://github.com/rocky-linux/documentation).

## Cambiamenti all'ambiente

Con questi cambiamenti nasce l'esigenza di "vedere" come le modifiche apportate influiscono sui contenuti, nel contesto del sito web, _PRIMA_ che questi vengano inseriti nel repository dei documenti e che vengano poi pubblicati.

MkDocs è un'applicazione [Python](https://www.python.org) e i pacchetti aggiuntivi che utilizza sono anch'essi codice Python; ciò significa che l'ambiente richiesto per eseguire MkDocs deve essere un **ambiente Python correttamente configurato**. L'impostazione di Python per le attività di sviluppo (che è ciò che si sta facendo con MkDocs) non è un compito banale e le relative istruzioni sono al di fuori dello scopo di questo documento. Alcune considerazioni sono:

* La versione di Python deve essere >= 3.8, inoltre **deve essere prestata particolare attenzione a non utilizzare la versione Python "di sistema" di un computer se questo utilizza Linux/macOS**. Ad esempio, al momento della stesura di questo documento, la versione di sistema di Python su macOS è ancora la versione 2.7.
* Esecuzione di un "ambiente virtuale" Python. Quando si eseguono progetti di applicazioni Python e si installano pacchetti, ad esempio MkDocs, la comunità Python **raccomanda vivamente** di [creare un ambiente virtuale isolato](https://realpython.com/python-virtual-environments-a-primer/) per ogni progetto.
* Utilizzate un moderno IDE (Integrated Development Environment) che supporti bene Python. Due IDE popolari, che hanno anche un supporto integrato per l'esecuzione di ambienti virtuali, sono:
    * PyCharm - (versione gratuita disponibile) il principale IDE per Python https://www.jetbrains.com/pycharm/
    * Visual Studio Code - (versione gratuita disponibile) da Microsoft https://code.visualstudio.com

Per farlo in modo efficace occorre:

* Impostare un nuovo progetto Python che, idealmente, utilizza un ambiente virtuale (sopra).
* Installare `mkdocs`
* Installare alcuni plugin python
* Clonare questo repository Rocky GitHub: [https://github.com/rocky-linux/docs.rockylinux.org](https://github.com/rocky-linux/docs.rockylinux.org)
* Collegare la cartella `docs` all'interno del repository di documentazione clonato (si può anche modificare il file mkdocs.yml per caricare la cartella corretta, ma il collegamento mantiene l'ambiente mkdocs più pulito)
* Eseguire `mkdocs serve` all'interno del proprio clone di docs.rockylinux.org

!!! tip "Suggerimento"

    È possibile creare ambienti completamente separati per `mkdocs` utilizzando una qualsiasi delle procedure presenti nella sezione "Documentazione locale" del menu "Contributi".

!!! Note "Nota"

    Questo documento è stato scritto in ambiente Linux. Se il vostro ambiente è diverso (Windows o Mac), dovrete ricercare la corrispondenza con alcuni di questi passaggi. Un redattore o un manager che legge questo documento può apportare modifiche per aggiungere passaggi per questi ambienti.

### Installazione

* Installare `mkdocs` con l'ambiente python: `pip install mkdocs`
* Installare i plugin necessari:  `pip install mkdocs-material mkdocs-localsearch mkdocs-awesome-pages-plugin mkdocs-redirects mkdocs-i18n`
* Clonare il repository (come indicato sopra)

### Collegamento ed esecuzione di `mkdocs`

All'interno del vostro docs.rockylinux.org locale (clone), fate quanto segue. Questo presuppone la posizione del clone della documentazione, quindi modificarlo secondo le necessità:

`ln -s /home/username/documentation/docs docs`

Anche in questo caso, se si desidera, si può modificare la copia locale del file `mkdocs.yml` per impostare il percorso. Se si usa questo metodo, si deve modificare questa riga per puntare alla vostra cartella `documentation/docs`:

```
docs_dir: 'docs/docs'
```

Una volta completato, si può provare a eseguire `mkdocs serve` per vedere se si ottiene il contenuto desiderato. Verrà eseguito su localhost sulla porta 8000; ad esempio: [http://127.0.0.1:8000/](http://127.0.0.1:8000/)

## Navigazione e altre modifiche

La navigazione è gestita con i file mkdocs `.pages` **O** dal valore del meta "title:" nel frontespizio del documento. I file `.pages` non sono terribilmente complessi, MA, se qualcosa viene tralasciato, può causare il mancato caricamento del server. Ecco perché questa procedura è destinata **SOLO** a Gestori e Redattori. Questi individui avranno gli strumenti necessari (installazione locale di mkdocs, oltre a cloni di documentazione e docs.rockylinux.org) in modo che qualcosa spinto e unito a GitHub non interrompa il servizio del sito web della documentazione. Non si può pretendere che un collaboratore abbia anche solo uno di questi requisiti.


### Files `.pages`

Come già detto, i file `.pages` sono generalmente piuttosto semplici. Si tratta di un file formattato in YAML che `mkdocs` legge prima di fare il render del contenuto. Per dare un'occhiata a uno dei file `.pages` più complessi, vediamo quello creato per aiutare a formattare la navigazione laterale:

```
---
nav:
    - ... | index*.md
    - ... | installation*.md
    - ... | migrate2rocky*.md
    - Contribute: contribute
    - Automation: automation
    - Backup & Sync: backup
    - Content Management: cms
    - Communications: communications
    - Containers: containers
    - Database: database
    - Desktop: desktop
    - DNS: dns
    - Email: email
    - File Sharing Services: file_sharing
    - Git: git
    - Interoperability: interoperability
    - Mirror Management: mirror_management
    - Network: network
    - Package Management: package_management
    - ...

```
Qui, l'`index*md` mostra la "Guides Home: ", `installation*.md` mostra il collegamento al documento "Installing Rocky Linux" e `migrate2rocky*.md` mostra il collegamento al documento "Migrating To Rocky Linux". Il simbolo "*" all'interno di ciascun collegamento consente di inserire il documento in _qualsiasi_ lingua. Infine, posizionando "Contribute" accanto a queste voci, si trova sotto di esse anziché nel normale ordine (alfabetico). Scorrendo l'elenco, si può vedere cosa fa ogni voce. Si noti che dopo la voce "Package Management: package_management", ci sono altre due cartelle (security e web). Queste non richiedono alcuna formattazione aggiuntiva, quindi diciamo a `mkdocs` di caricarle normalmente con l'opzione "-..."

È possibile utilizzare la formattazione YAML anche all'interno di un file corrente. Un motivo per farlo potrebbe essere che l'intestazione iniziale del file è così lunga che non viene visualizzata bene nella sezione di navigazione.  A titolo di esempio, si prenda il titolo di questo documento "# `mod_ssl` on Rocky Linux in an httpd Apache Web-Server Environment". È molto lungo. Una volta aperta la voce di navigazione "Web", la visualizzazione è molto scarsa nella navigazione laterale. Per risolvere questo problema, si può collaborare con l'autore per modificare l'intestazione, oppure si può cambiare la visualizzazione nel menu aggiungendo un titolo prima dell'intestazione all'interno del documento. Per il documento di esempio, è stato aggiunto un titolo:
```
---
title: Apache With `mod_ssl`
---
```
Questo cambia il titolo nella navigazione, ma lascia il titolo originale dell'autore all'interno del documento.

Probabilmente non ci sarà bisogno di file `.pages` aggiuntivi. Dovrebbero essere utilizzati in modo economico.

## Conclusione

Sebbene le modifiche alla navigazione che potrebbero essere necessarie non siano difficili, esiste la possibilità di interrompere la documentazione in tempo reale. Per questo motivo, solo i manager e i redattori con gli strumenti appropriati dovrebbero avere i permessi per modificare questi file. Avere a disposizione un ambiente completo per visualizzare l'aspetto delle pagine live impedisce al manager o al redattore di commettere un errore durante la modifica di questi file, compromettendo la documentazione live.
