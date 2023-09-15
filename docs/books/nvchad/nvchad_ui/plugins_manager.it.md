---
title: Gestione dei Plugin
author: Franco Colussi
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 8.7, 9.1
tags:
  - nvchad
  - coding
  - plugins
---

# Gestione dei Plugin

La gestione dei plugin in NvChad 2.0 è affidata a [folke/lazy.nvim](https://github.com/folke/lazy.nvim), che viene installato durante la prima installazione dalla procedura di bootstrap. Il plugin consente di eseguire tutte le operazioni comuni sui plugin, come l'installazione, l'aggiornamento, ecc.

![Lazy Nvim](../images/lazy_nvim.png)

## Caratteristiche Principali

- Gestione di tutte le operazioni sui plugins da un'interfaccia unificata.
- Prestazioni ottimizzate del plugin grazie al caching e alla compilazione del bytecode del modulo Lua.
- Controllo automatico e installazione dei plugin mancanti all'avvio, una funzione molto utile quando si trasferisce una configurazione da una macchina all'altra.
- Profiler per la consultazione dei tempi di caricamento dei plugin. Permette di monitorare e risolvere i problemi causati da plugins difettosi.
- Sincronizzazione dei plugins su più workstation memorizzando la revisione di tutti i plugins installati nel file _lazy-lock.json_.

## Operazioni Preliminari

_lazy.nvim_ integra una funzione di controllo dello stato di salute dell'ambiente che può essere invocata con il comando `:checkhealth lazy`. Il comando dovrebbe restituire qualcosa del genere in un nuovo buffer:

```text
lazy: require("lazy.health").check()
========================================================================
## lazy.nvim
  - OK: Git installed
  - OK: no existing packages found by other package managers
  - OK: packer_compiled.lua not found
  - WARNING: {nvim-lspconfig}: overriding <config>
```

Anche se non è strettamente necessario, controllare l'ambiente di compilazione prima di iniziare a lavorare sulla nostra configurazione personalizzata ci permette di escludere questa variabile da eventuali errori o malfunzionamenti che potrebbero verificarsi nei plugins stessi o nella scrittura delle loro configurazioni.

Potrebbe anche essere interessante consultare l'aiuto in linea fornito dal plugin stesso. Per aprirlo si può usare il comando `:Lazy help` o richiamarlo dall'interfaccia del plugin digitando <kbd>?</kbd>

![Lazy Help](../images/lazy_help.png)

La guida fornisce un'introduzione alla navigazione dell'interfaccia, ai controlli e alle loro funzioni.

Ora, dopo aver controllato l'ambiente e aver acquisito le conoscenze di base, possiamo passare alla creazione della nostra configurazione. Lo scopo è chiaramente quello di aggiungere funzionalità all'editor per soddisfare le nostre esigenze e, poiché questo si ottiene includendo i plugins nella configurazione di NvChad, inizieremo aggiungendo un plugin.

## Inserimento di un plugin

!!! note "Nota"

    In questi esempi si presume che durante l'installazione di NvChad si sia scelto di creare la struttura della cartella `custom` con il _template chadrc_.

Mentre la gestione dei plugin installati può essere comodamente eseguita dall'interfaccia _lazy.nvim_, l'inserimento di un nuovo plugin richiede la modifica manuale del file **custom/plugins.lua**.

In questo esempio installeremo il plugin [natecraddock/workspaces.nvim.](https://github.com/natecraddock/workspaces.nvim)  Questo plugin consente di salvare e utilizzare successivamente le sessioni di lavoro (workspaces) in modo da potervi accedere rapidamente. Apriamo il file con:

```bash
nvim ~/.config/nvim/lua/custom/plugins.lua
```

e inseriamo il seguente codice dopo il plugin _better-escape.nvim_:

```lua
    -- Workspaces
    {
        "natecraddock/workspaces.nvim",
        cmd = { "WorkspacesList", "WorkspacesAdd", "WorkspacesOpen", "WorkspacesRemove" },
        config = function()
            require("workspaces").setup {
        hooks = {
            open = "Telescope find_files",
        },
      }
    end,
    },
```

Una volta salvato il file, riceveremo una notifica con la richiesta di approvazione:

```text
# Config Change Detected. Reloading...

> - **changed**: `plugins.lua`
```

Questo grazie al meccanismo incorporato in _lazy.nvim_ che controlla lo stato dei plugins e delle sue configurazioni e permette quindi di eseguire operazioni sui plugins senza dover uscire dall'editor, operazione che era necessaria con la versione 1.0.

Chiaramente risponderemo "sì".

Ora, se apriamo il gestore dei plugin con il comando `:Lazy`, scopriremo che il nostro plugin è stato riconosciuto ed è pronto per essere installato. Per installarlo, è sufficiente digitare <kbd>I</kbd>

![Install Plugin](../images/lazy_install.png)

A questo punto sarà _lazy.nvim_ a occuparsi di scaricare il repository nel percorso **.local/share/nvim/lazy/** e di eseguire la compilazione. Una volta terminata l'installazione, avremo una nuova cartella denominata _workspaces.nvim:_

```text
.local/share/nvim/lazy/workspaces.nvim/
├── CHANGELOG.md
├── doc
│   ├── tags
│   └── workspaces.txt
├── LICENSE
├── lua
│   ├── telescope
│   │   └── _extensions
│   │       └── workspaces.lua
│   └── workspaces
│       ├── init.lua
│       └── util.lua
├── README.md
└── stylua.toml
```

Ora avremo le funzionalità del plugin che possono essere invocate con i comandi impostati nell'array:

```lua
cmd = { "WorkspacesList", "WorkspacesAdd", "WorkspacesOpen", "WorkspacesRemove" },
```

L'inserimento comporta anche l'aggiunta di una stringa al file _lazy-lock.json_ per il monitoraggio dello stato e gli aggiornamenti successivi. La funzione del file _lazy-lock.json_ sarà descritta nella sezione corrispondente qui sotto.

```json
  "workspaces.nvim": { "branch": "master", "commit": "dd9574c8a6fbd4910bf298fcd1175a0222e9a09d" },
```
## Rimozione di un plugin

Come per l'installazione, la rimozione di un plugin dalla configurazione passa anche attraverso la modifica manuale del file _custom/plugins.lua_. In questo esempio stiamo per rimuovere il plugin [TimUntersberger/neogit](https://github.com/TimUntersberger/neogit) questo plugin permette una gestione dei repository git direttamente dall'editor.

!!! note "Nota"

    La scelta del plugin è puramente casuale. Il plugin utilizzato per l'esempio non ha problemi a funzionare in NvChad.

Apriamo il nostro editor e rimuoviamo il plugin dalla configurazione. Questo può essere fatto comodamente selezionando le quattro righe da eliminare con il mouse e quindi premendo <kbd>x</kbd> per eliminarle e <kbd>CTRL</kbd> + <kbd>s</kbd> per salvare il file.

![Remove Plugin](../images/remove_plugin_01.png)

Anche in questo caso riceveremo un avviso sulla modifica del file _plugins.lua_ al quale risponderemo "sì" e una volta aperto _Lazy_ avremo il nostro plugin contrassegnato come da rimuovere. La rimozione viene eseguita premendo il tasto <kbd>X</kbd>.

![Lazy Clean](../images/remove_plugin_02.png)

La rimozione di un plugin consiste fondamentalmente nella rimozione della cartella creata durante l'installazione.

## Aggiornamento dei Plugins

Una volta che i plugins sono installati e configurati, sono gestiti in modo indipendente da _lazy.nvim_. Per verificare la presenza di aggiornamenti, è sufficiente aprire il manager e digitare <kbd>C</kbd>. _Lazy_ controllerà i repository dei plugins installati_(git fetch_) e poi ci presenterà un elenco di plugins aggiornabili che, una volta controllati, possono essere aggiornati tutti in una volta con <kbd>U</kbd> o singolarmente dopo averli selezionati con <kbd>u</kbd>.

![Lazy Check](../images/lazy_check.png)

!!! note "Nota"

    Anche se non è presente nella schermata precedente, se ci sono plugin con commit che includono "breaking changes", questi verranno visualizzati per primi.

Esiste anche la possibilità di eseguire l'intero ciclo di aggiornamento con il solo comando `Sync`. Dall'interfaccia digitando <kbd>S</kbd> o con il comando `:Lazy sync` invocheremo la funzione, che consiste nella concatenazione di `install` + `clean` + `update`.

Il processo di aggiornamento, sia individuale che cumulativo, modificherà anche il file _lazy-lock.json._  In particolare, i commit saranno modificati per sincronizzarli con lo stato del repository su GitHub.

## Funzionalità Aggiuntive

Nella scrittura del plugin si è prestata particolare attenzione alle prestazioni e all'efficienza del codice, oltre a fornire un modo per valutare i tempi di avvio dei vari plugins. Viene fornito un _profiler_ che può essere invocato con il comando `:Lazy profile` o con il tasto <kbd>P</kbd> dell'interfaccia.

![Lazy Profiler](../images/lazy_profile.png)

Qui possiamo vedere i tempi di caricamento dei vari plugins che possono essere ordinati con la combinazione di tasti <knd>CTRL</kbd> + <kbd>s</kbd> per inserimento nella configurazione o per tempo di caricamento. Abbiamo anche la possibilità di effettuare ricerche sul tempo di caricamento dei plugins, impostando una soglia minima in millisecondi con la combinazione <kbd>CTRL</kbd> + <kbd>f</kbd>.

Queste informazioni possono essere utili per la risoluzione dei problemi se l'editor rallenta in modo anomalo.

Il plugin fornisce anche una visualizzazione delle ultime operazioni eseguite sui plugins, visualizzazione che può essere richiamata con il tasto <kbd>L</kbd> dall'interfaccia o con il comando `:Lazy log` dall'editor stesso.

![Lazy Log](../images/lazy_log.png)

Integra anche una funzione di debug che ci permette di controllare i gestori attivi in lazy-loading e ciò che è presente nella cache del modulo. Per attivarlo possiamo utilizzare il tasto <kbd>D</kbd> dall'interfaccia o invocarlo con il comando `:Lazy debug`.

![Lazy Debug](../images/lazy_debug.png)

## Sincronizzazione

Lazy.nvim consente la sincronizzazione di tutti i plugin installati, memorizzando il loro stato in un file _json_. Al suo interno, per ogni plugin viene creata una stringa che contiene il nome della cartella corrispondente al plugin installato che si trova in **~/.local/share/nvim/lazy/**, il ramo corrispondente e il commit utilizzato per la sincronizzazione dal repository GitHub. Il file utilizzato a questo scopo è il file `lazy-lock.json` che si trova nella cartella principale di **~/.config/nvim**. Qui sotto possiamo vedere un estratto del file:

```json
{
  "Comment.nvim": { "branch": "master", "commit": "8d3aa5c22c2d45e788c7a5fe13ad77368b783c20" },
  "LuaSnip": { "branch": "master", "commit": "025886915e7a1442019f467e0ae2847a7cf6bf1a" },
  "base46": { "branch": "v2.0", "commit": "eea1c3155a188953008bbff031893aa8cb0610e9" },
  "better-escape.nvim": { "branch": "master", "commit": "426d29708064d5b1bfbb040424651c92af1f3f64" },
  "cmp-buffer": { "branch": "main", "commit": "3022dbc9166796b644a841a02de8dd1cc1d311fa" },
  "cmp-nvim-lsp": { "branch": "main", "commit": "0e6b2ed705ddcff9738ec4ea838141654f12eeef" },
  "cmp-nvim-lua": { "branch": "main", "commit": "f3491638d123cfd2c8048aefaf66d246ff250ca6" },
  "cmp-path": { "branch": "main", "commit": "91ff86cd9c29299a64f968ebb45846c485725f23" },
  "cmp_luasnip": { "branch": "master", "commit": "18095520391186d634a0045dacaa346291096566" },
...
```

Grazie alla memorizzazione dei commit, possiamo vedere esattamente lo stato del plugin nel repository al momento dell'installazione o dell'aggiornamento. Questo ci permette, attraverso la funzione di `restore`, di riportarlo o portarlo allo stesso stato anche nell'editor. La funzione, richiamabile con il tasto <kbd>R</kbd> dell'interfaccia o con `:Lazy restore`, aggiorna tutti i plugin dell'editor allo stato definito nel file _lazy-lock.json._

Copiando il file _lazy-lock.json_ da una configurazione stabile in un posto sicuro, si ha la possibilità di ripristinare l'editor in quella condizione se un aggiornamento dovesse creare problemi. Esportandolo invece su un'altra stazione di lavoro, possiamo utilizzarlo per configurare l'editor con le stesse funzionalità.

Se invece lo mettiamo sotto un controllo di versione, possiamo ottenere la sincronizzazione della configurazione tra tutte le postazioni di lavoro utilizzate.

Ora dopo aver illustrato il gestore dei plugins, possiamo andare avanti per analizzare l'interfaccia utente.
