---
title: Modifiche alla navigazione
contributors: Franco Colussi, Steven Spencer
update: 12-06-2021
---

# Modifiche alla navigazione - Un documento di processo per manager/editori

## Motivo di questo documento

Quando il progetto di documentazione è iniziato, si sperava che i menu in Mkdocs fossero il più automatici possibile, rendendo rara la modifica manuale della navigazione. Dopo alcuni mesi di generazione di documenti, è diventato chiaro che semplicemente mettendo i documenti nella cartella corretta e lasciando che Mkdocs generasse la navigazione non poteva essere affidabile per mantenere le cose pulite e ordinate. Avevamo bisogno di categorie, qualcosa che Mkdocs non fornisce a meno che i documenti non siano messi in cartelle specifiche. Mkdocs creerà quindi una navigazione con un ordine alfabetico. Creare una struttura di cartelle che fissi la navigazione non è però uno scenario definitivo. Anche questo a volte avrà bisogno di ulteriori modifiche per mantenere le cose organizzate. Per esempio, la capitalizzazione senza modificare la struttura delle cartelle in minuscolo.

## Obiettivi

I nostri obiettivi erano:

* Creare la struttura delle cartelle come necessario ora (nuove cartelle potrebbero essere necessarie in futuro).
* Regolare la navigazione in modo che le aree Installazione Rocky, Migrazione e Contribuzione siano in cima.
* Regolare la navigazione per nominare meglio alcune cartelle, e abilitare la capitalizzazione corretta. Per esempio, "DNS" e "File Sharing Services", che altrimenti appaiono come "Dns" e "File sharing" senza una qualche manipolazione.
* Assicurarsi che questi file di navigazione siano limitati ai Gestori e agli Editori.

Quest'ultimo punto può sembrare inutile ad alcuni che leggono questo articolo, ma diventerà più chiaro continuando man mano la lettura di questo documento.

## Presupposti

Si presume che tu abbia un clone locale del repository Rocky di GitHub: [https://github.com/rocky-linux/documentation](https://github.com/rocky-linux/documentation).

## Modifiche all'ambiente

Con questi cambiamenti arriva una reale necessità di "vedere" come qualsiasi cambiamento che si stia facendo influisca sul contenuto, nel contesto del sito web, _PRIMA_ che il contenuto sia inserito nel repository dei documenti, e successivamente vada 'live'.

MkDocs è un'applicazione [Python](https://www.python.org) e i pacchetti extra che usa sono anch'essi codice Python, questo significa che l'ambiente richiesto per eseguire MkDocs deve essere un **ambiente Python correttamente configurato**. Impostare Python per compiti di sviluppo (che è quello che viene fatto eseguendo MkDocs) non è un compito banale, e le istruzioni per questo sono fuori dallo scopo di questo documento. Alcune considerazioni sono:

* La versione di Python, dovrebbe essere >= 3.8, inoltre **si deve prestare particolare attenzione a non usare la versione Python 'di sistema' di un computer se il computer ha Linux/macOS**. Per esempio, al momento della scrittura di questo documento, la versione di sistema di Python su macOS è ancora la versione 2.7.
* Esecuzione di un "ambiente virtuale" Python. Quando si esegue un progetto di applicazione Python e si installano pacchetti, per esempio MkDocs, è **fortemente raccomandato** dalla comunità Python di [creare un ambiente virtuale isolato](https://realpython.com/python-virtual-environments-a-primer/) per ciascun progetto.
* Usate un moderno IDE (Integrated Development Environment) che supporti bene Python. Due IDE popolari, che hanno anche un supporto integrato per l'esecuzione di ambienti virtuali, sono:
    * PyCharm - (versione gratuita disponibile) il principale IDE per Python https://www.jetbrains.com/pycharm/
    * Visual Studio Code- (versione gratuita disponibile) da Microsoft https://code.visualstudio.com

Fare questo in modo efficace richiede:

* Impostare un nuovo progetto Python che, idealmente, utilizza un ambiente virtuale (sopra).
* Installazione di `mkdocs`
* Installare alcuni plugin python
* Clonare questo repository di Rocky GitHub:[https://github.com/rocky-linux/docs.rockylinux.org](https://github.com/rocky-linux/docs.rockylinux.org)
* Collegamento alla cartella `docs` all'interno del tuo repository di documentazione clonato (puoi anche solo modificare il file mkdocs.yml se vuoi caricare la cartella corretta, ma il collegamento mantiene il tuo ambiente mkdocs più pulito)
* Eseguire `mkdocs serve` nel tuo clone di docs.rockylinux.org

!!! Note - Nota
    Questo documento è stato scritto in un ambiente Linux. Se il vostro ambiente è diverso (Windows o Mac), allora avrete bisogno di fare un po' di ricerca su alcuni di questi passi. Un redattore o un manager che legge questo documento può sottoporvi delle modifiche per aggiungere dei passi per quegli ambienti.

### Installazione di

* Installare `mkdocs` con l'ambiente python: `pip install mkdocs`
* Installare i plugin necessari:  `pip install mkdocs-material mkdocs-localsearch mkdocs-awesome-pages-plugin mkdocs-i18n`
* Clonare il repository (indicato sopra)

### Collegamento ed esecuzione `mkdocs`

All'interno del tuo (clone) locale docs.rockylinux.org, fai quanto segue. Questo presuppone la posizione del tuo clone di documentazione, quindi modificalo come necessario:

`ln -s /home/username/documentation/docs docs`

Di nuovo, se vuoi, puoi modificare la copia locale del file `mkdocs.yml` per impostare il percorso. Se usi questo metodo, devi modificare questa linea per puntare alla tua cartella `documentation/docs`:

```text
docs_dir: 'docs/docs'
```

Una volta completato, puoi provare ad eseguire `mkdocs serve` per vedere se ottieni il contenuto desiderato. Questo verrà eseguito su un localhost sulla porta 8000 per esempio: [http://127.0.0.1:8000/](http://127.0.0.1:8000/)

## Navigazione e altri cambiamenti

La navigazione è gestita con i file mkdocs `.pages`. Non sono terribilmente complessi, MA, se qualcosa viene lasciato fuori, può causare il mancato caricamento del server. Ecco perché questa procedura è **SOLO** per gestori e redattori. Questi individui avranno gli strumenti a disposizione (installazione locale di mkdocs, più i cloni sia della documentazione che di docs.rockylinux.org) in modo che qualcosa spinto e unito a GitHub non interrompa il servizio del sito web della documentazione. Non ci si può aspettare che un collaboratore abbia anche solo uno di questi requisiti.

### Files `.pages`

Come già detto, i file .pages sono generalmente piuttosto semplici. Sono un file formattato in YAML che `mkdocs` legge prima di renderizzare il contenuto. Per dare un'occhiata a uno dei file `.pages` più complessi, guardiamo quello creato per aiutare a formattare la navigazione laterale:

```yaml
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

Qui, `index*md` mostra la "Home Guide: ", `installation*.md` mostra il link al documento "Installazione Rocky Linux", e il `migrate2rocky*.md` mostra il link al documento "Migrazione a Rocky Linux". Il "*" all'interno di ciascuno di questi link permette di avere quel documento in _qualsiasi_ lingua. Infine, mettendo "Contribute" dopo, viene messo sotto queste voci piuttosto che nel normale ordine (alfabetico). Se si guarda in basso nella lista, si può vedere cosa sta facendo ogni voce. Nota che dopo la voce "Package Management: package_management", ci sono in realtà altre due cartelle (security e web). Queste non richiedono alcuna formattazione aggiuntiva, quindi stiamo semplicemente dicendo a `mkdocs` di caricarle normalmente con il "-..."

Puoi anche usare la formattazione YAML all'interno di un file vero e proprio. Una ragione per farlo potrebbe essere che l'intestazione iniziale del file è così lunga che non viene visualizzata bene nella sezione di navigazione. Come esempio, prendete questo documento dal titolo "# `mod_ssl` su Rocky Linux in un ambiente web-server httpd Apache". È molto lungo. Viene visualizzato molto male nella navigazione laterale una volta aperta la voce di navigazione "Web". Per risolvere questo problema, si può lavorare con l'autore per cambiare il suo titolo, oppure, si può cambiare come viene visualizzato nel menu aggiungendo un titolo prima del titolo all'interno del documento. Per il documento di esempio, è stato aggiunto un titolo:

```yaml
---
title: Apache With `mod_ssl`
---
```

Questo cambia il titolo per quanto riguarda la navigazione, ma lascia il titolo originale dell'autore al suo posto nel documento.

Probabilmente non ci sarà molto bisogno di file `.pages` aggiuntivi. Dovrebbero essere usati in modo economico.

## Conclusione

Mentre i cambiamenti di navigazione che potrebbero essere fatti non sono difficili, il potenziale per interrompere la documentazione dal vivo esiste. Per questo motivo, solo i manager e gli editor con gli strumenti appropriati dovrebbero avere i permessi per modificare questi file. Avere a disposizione un ambiente completo per vedere come saranno le pagine dal vivo, evita che il manager o l'editor facciano un errore mentre modificano questi file che potrebbe anche interrompere la documentazione dal vivo.
