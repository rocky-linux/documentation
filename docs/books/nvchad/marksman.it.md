---
title: Marksman
author: Franco Colussi
contributors: Steven Spencer, Ganna Zhyrnova
tested with: 8.8, 9.2
tags:
  - nvchad
  - editor
  - markdown
---

# Marksman - assistente del codice

Marksman è uno strumento utile quando si redige un documento per Rocky Linux. Permette di inserire facilmente i simboli necessari per definire i tag del linguaggio _markdown_. Ciò consente di scrivere più velocemente e riduce la possibilità di errori.

NvChad/Neovim include già dei widget di testo che aiutano nella scrittura, come la ripetizione delle parole più usate indicizzate in base alla frequenza di inserimento. Le nuove opzioni incluse in questo server linguistico arricchiranno questi widget.

[Marksman](https://github.com/artempyanykh/marksman) si integra con il vostro editor per aiutarvi a scrivere e mantenere i vostri documenti Markdown con il protocollo [LSP](https://microsoft.github.io/language-server-protocol/), fornendo così funzioni come il completamento, la definizione di go-to, la ricerca di riferimenti, il refactoring dei nomi, la diagnostica e altro ancora.

## Obiettivi

- aumentare la produttività di NvChad nella scrittura di codice Markdown
- produrre documenti conformi alle regole del linguaggio Markdown
- affinare le proprie conoscenze riguardo al linguaggio

## Requisiti e competenze

- Una conoscenza di base del linguaggio Markdown, consigliata la lettura della [Guida Markdown](https://www.markdownguide.org/)
- NvChad sulla macchina in uso correttamente installato

**Livello di difficoltà** :star:

**Tempo di lettura:** 20 minuti

## Installazione di Marksman

L'installazione del server linguistico non comporta particolari problemi, poiché è disponibile nativamente in **Mason**. È possibile installarlo direttamente dalla _statusline_ con il comando:

`:MasonInstall marksman`

Il comando aprirà l'interfaccia di _Mason_ e installerà direttamente il server linguistico richiesto. Una volta completata l'installazione binaria, è possibile chiudere la schermata di _Mason_ con il tasto ++"q"++.

La sua installazione, tuttavia, non comporta ancora la sua integrazione nell'editor. Per abilitarlo, deve essere inserito nel file `configs/lspconfig.lua` della configurazione.

## Integrazione nell'editor

!!! note "LSP in NvChad"

    Il plugin [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) integra i server linguistici in NvChad. Questo plugin semplifica notevolmente la loro inclusione nella configurazione di NvChad.

Il file _lspconfig.lua_ si occupa di inserire le chiamate necessarie per utilizzare i server linguistici e permette anche di indicare quelli installati. Per integrare _marksman_ nella configurazione dei server linguistici dell'editor, è necessario modificare la stringa _local servers_ aggiungendo il nuovo LSP.

Aprire NvChad sul file con il comando:

```bash
nvim ~/.config/nvim/lua/configs/lspconfig.lua
```

E modificare la stringa _local servers_, che al termine avrà il seguente aspetto:

```lua
local servers = { "html", "cssls", "tsserver", "clangd", "marksman" }
```

Salvare il file e chiudere l'editor con il comando `:wq`.

Per verificare se il server linguistico viene attivato correttamente, aprire un file markdown in NvChad e usare il comando `:LspInfo` per visualizzare i server linguistici applicati a quel file. All'interno del sommario dovrebbe esserci qualcosa come:

```text
 Client: marksman (id: 2, bufnr: [11, 156])
  filetypes:       markdown
  autostart:       true
  root directory:  /home/your_user/your_path/your_directory
  cmd:             /home/your_user/.local/share/nvim/mason/bin/marksman server

 Configured servers list: cssls, tsserver, clangd, html, yamlls, lua_ls, marksman
```

Questo indica l'attivazione del server _marksman_ per il file aperto e che si è avviato automaticamente (`autostart: true`) poiché viene riconosciuto come file markdown `filetypes: markdown`. Le altre informazioni indicano il percorso dell'eseguibile utilizzato per il controllo del codice `cmd:`, che utilizza la modalità server `marksman server` e che utilizza la directory root `your_directory` per i controlli.

!!! note "Cartella root"

    Il concetto di "cartella root" è importante nell'uso di un server linguistico, in quanto per eseguire controlli sul documento, come collegamenti ad altri file o immagini, deve avere una "visione globale" del progetto. Possiamo dire che le "_cartelle root_" equivalgono ai "_progetti_" presenti negli IDE grafici.
    
    La _root directory_, detta anche "directory di lavoro\*", utilizzata dall'editor per il file aperto, è visualizzabile con il comando `:pwd`. È modificabile con il comando `:lcd` se non corrisponde a quella desiderata. Questo comando riassegna la _directory di lavoro_ solo a quel buffer, senza modificare le impostazioni degli altri buffer aperti nell'editor.

## Uso di marksman

Una volta completati tutti i passaggi per l'inserimento, l'attivazione del server linguistico avviene ogni volta che si apre un file _markdown_ nell'editor. Entrando in modalità `INSERT`, quando si digitano determinati caratteri si avranno nuove opzioni nei widget che aiuteranno a scrivere il documento. Nella schermata qui sotto si possono vedere alcuni degli snippet di markdown disponibili in questi widget.

![Marksman Snippets](./images/marksman_snippets.png)

## Chiavi principali

Il server linguistico fornisce molte scorciatoie che attivano l'assistenza alla scrittura. Questo include l'inserimento rapido di tag Markdown, la creazione di collegamenti e l'inserimento di immagini nel documento. Di seguito è riportato un elenco non esaustivo dei caratteri che attivano i vari snippet.

Questi snippet vengono visualizzati all'interno di widget che contengono anche altre scorciatoie. Utilizzare il tasto ++tab++ per la navigazione del widget per selezionare quelli forniti da _marksman_.La chiave inserisce il tag _superscript_.

| Tasto           | Snippets                                                                                                                                                                                                                                                                                                                                                    |
| --------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| ++"h"++         | Controlla con il comando `id` per verificare che il gruppo sia stato aggiunto. Consente l'inserimento rapido dei titoli (_h1_ a _h6_), ad esempio, inserendo _h4_ e premendo Invio verranno inseriti quattro segni di cancelletto e uno spazio e il cursore sarà già posizionato per inserire il titolo. |
| ++"b"++         | Inserendo questo carattere si attiva la possibilità di utilizzare la scorciatoia per inserire testo in grassetto inserendo quattro asterischi e posizionando il cursore al centro, rendendo molto più veloce la scrittura della parte in **grassetto**.                                                                                     |
| ++"i"++         | Come per il carattere precedente, consente di selezionare l'inserimento rapido di testo _in corsivo_ inserendo due asterischi e posizionando il cursore tra di essi.                                                                                                                                                                        |
| ++"bi"++        | Questo tasto inserisce sei asterischi posizionando il cursore al centro per scrivere il testo in _**grassetto e corsivo**_.                                                                                                                                                                                                                 |
| ++"img"++       | Questa parola chiave inserisce la struttura markdown per inserire un'immagine nel documento nel formato `![testo alternativo](percorso)`. Si noti che la scrittura del percorso può essere effettuata utilizzando il completamento automatico fornito dal server.                                                           |
| ++"link"++      | Questo parametro crea la struttura del tag markdown per un link `[testo](url)`. Anche in questo caso, se il collegamento fa riferimento a un file nella **directory di lavoro**, sarà possibile utilizzare il completamento automatico e il server verificherà la correttezza del riferimento.                              |
| ++"list"++      | La digitazione di questa chiave consente di inserire un elenco di tre elementi per iniziare la creazione di un elenco numerato o non ordinato                                                                                                                                                                                                               |
| ++"q"++         | Questo parametro consente l'inserimento del tag per una citazione `>` seguito da uno spazio e posiziona il cursore per scrivere la citazione.                                                                                                                                                                                               |
| ++"s"++         | Questo carattere attiva numerose possibilità, tra cui l'inserimento di quattro tildes e il posizionamento del cursore al centro per la scrittura del testo ~~barrato~~                                                                                                                                                                                      |
| ++"sup"++       | Il parametro inserisce il tag _apice_. Trademark<sup>TM                                                                                                                                                                                                                                                                                     |
| ++"sub"++       | Il parametro inserisce il tag <em x-id="3">subscript</em>. Note<sub>1                                                                                                                                                                                                                                                                       |
| ++"table"++     | Questo tasto consente di creare rapidamente la struttura di una tabella e di scegliere tra numerose strutture di partenza                                                                                                                                                                                                                                   |
| ++"code"++      | Inserisce un blocco di codice in linea posizionando due backtick nella posizione in cui si trova il cursore, posizionandolo al centro dei due backtick.                                                                                                                                                                                     |
| ++"codeblock"++ | Inserisce tre righe, due con triplo backtick e una vuota, dove si inseriscono i blocchi di codice. Si noti che inserisce anche la stringa _language_, che deve essere compilata con il linguaggio utilizzato nel blocco.                                                                                                    |

!!! note "Istruzione Code block"

    Le regole del codice Markdown raccomandano di dichiarare sempre il codice utilizzato nel blocco, anche senza funzioni di evidenziazione per una corretta interpretazione. Se il codice al suo interno è troppo generico, si consiglia di utilizzare “testo” per la sua dichiarazione.

Le chiavi di attivazione per le scorciatoie Markdown includono anche altre combinazioni che si possono scoprire con l'uso del server linguistico.

## Conclusione

Anche se non è strettamente necessario, questo server linguistico può diventare, col tempo, un ottimo compagno nella scrittura della documentazione per Rocky Linux.

Il suo utilizzo e la conseguente memorizzazione dei principali tasti per l'inserimento dei simboli del codice Markdown consentirà una scrittura più rapida, permettendo di concentrare l'attenzione sul contenuto.
