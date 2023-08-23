---
title: Marksman
author: Franco Colussi
contributors: Steven Spencer, Franco Colussi
tested with: 8.8, 9.2
tags:
  - nvchad
  - editor
  - markdown
---

# Marksman - assistente del codice

Marksman è uno strumento utile quando si redige un documento per Rocky Linux. Permette di inserire facilmente i simboli necessari per definire i tag del linguaggio *markdown*. Ciò consente di scrivere più velocemente e riduce la possibilità di errori.


NvChad/Neovim include già dei widget di testo che aiutano nella scrittura, come la ripetizione delle parole più usate indicizzate in base alla frequenza di inserimento. Le nuove opzioni incluse in questo server linguistico arricchiranno questi widget.

[Marksman](https://github.com/artempyanykh/marksman) si integra con il vostro editor per aiutarvi a scrivere e mantenere i vostri documenti Markdown con il protocollo [LSP](https://microsoft.github.io/language-server-protocol/), fornendo così funzioni come il completamento, la definizione di go-to, la ricerca di riferimenti, il refactoring dei nomi, la diagnostica e altro ancora.

## Obiettivi

- aumentare la produttività di NvChad nella scrittura di codice Markdown
- produrre documenti conformi alle regole del linguaggio Markdown
- affinare le proprie conoscenze riguardo al linguaggio

## Requisiti e competenze

- Una conoscenza di base del linguaggio Markdown, consigliata la lettura della [Guida Markdown](https://www.markdownguide.org/)
- NvChad sulla macchina in uso con il [Template Chadr](./template_chadrc.md) correttamente installato

**Livello di difficoltà** :star:

**Tempo di lettura:** 20 minuti

## Installazione di Marksman

L'installazione del server linguistico non comporta particolari problemi, poiché è disponibile nativamente in **Mason**. Installatelo direttamente dalla *statusline* con il comando:

`:MasonInstall marksman`

Il comando aprirà l'interfaccia di *Mason* e installerà direttamente il server linguistico richiesto. Una volta completata l'installazione binaria, è possibile chiudere la schermata di *Mason* con il tasto <kbd>q</kbd>.

La sua installazione, tuttavia, non comporta ancora la sua integrazione nell'editor. Per abilitare questa funzione, si deve modificare il file `custom/configs/lspconfig.lua` del *Template Chadrc*.

## Integrazione nell'editor

!!! note "LSP in NvChad"

    Il plugin [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) integra i server linguistici in NvChad. Questo plugin semplifica notevolmente la loro inclusione nella configurazione di NvChad.

Se durante l'installazione dell'editor si è scelto di installare anche il *Template Chadrc*, questo creerà il file *lspconfig.lua* nella cartella `custom/configs`.

Questo file si occupa di inserire le chiamate necessarie per utilizzare i server linguistici e consente anche di specificare quelli da voi installati. Per integrare *marksman* nella configurazione dei server linguistici dell'editor, è necessario modificare la stringa *local servers* aggiungendo il nuovo LSP.

Aprite il vostro NvChad sul file con il comando:

```bash
nvim ~/.config/nvim/lua/custom/configs/lspconfig.lua
```

E modificare la stringa *local servers*, che al termine avrà il seguente aspetto:

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

Questo indica l'attivazione del server *marksman* per il file aperto e che si è avviato automaticamente (`autostart: true`) poiché viene riconosciuto come file markdown `filetypes: markdown`. Le altre informazioni indicano il percorso dell'eseguibile utilizzato per il controllo del codice `cmd:`, che utilizza la modalità server `marksman server` e che utilizza la directory root `your_directory` per i controlli.

!!! note "Cartella root"

    Il concetto di "cartella root" è importante nell'uso di un server linguistico, in quanto per eseguire controlli sul documento, come collegamenti ad altri file o immagini, deve avere una "visione globale" del progetto. Possiamo dire che le "*cartelle root*" equivalgono ai "*progetti*" presenti negli IDE grafici.
    
    La *root directory*, detta anche "directory di lavoro*", utilizzata dall'editor per il file aperto, è visualizzabile con il comando `:pwd`. È modificabile con il comando `:lcd` se non corrisponde a quella desiderata. Questo comando riassegna la *directory di lavoro* solo a quel buffer, senza modificare le impostazioni degli altri buffer aperti nell'editor.

## Uso di marksman

Una volta completati tutti i passaggi per l'inserimento, l'attivazione del server linguistico avviene ogni volta che si apre un file *markdown* nell'editor. Entrando in modalità `INSERT`, quando si digitano determinati caratteri si avranno nuove opzioni nei widget che aiuteranno a scrivere il documento. Nella schermata qui sotto si possono vedere alcuni degli snippet di markdown disponibili in questi widget.

![Marksman Snippets](./images/marksman_snippets.png)

## Chiavi principali

Il server linguistico fornisce molte scorciatoie che attivano l'assistenza alla scrittura. Questo include l'inserimento rapido di tag Markdown, la creazione di collegamenti e l'inserimento di immagini nel documento. Di seguito è riportato un elenco non esaustivo dei caratteri che attivano i vari snippet.

Questi snippet vengono visualizzati all'interno di widget che contengono anche altre scorciatoie. Utilizzare il tasto <kbd>Tab</kbd> per la navigazione del widget e selezionare quelli forniti da *marksman*.La chiave inserisce il tag *superscript*. Trademark<sup>TM</td> </tr> 

<tr>
  <td>
    <kbd>sub</kbd>
  </td>
  
  <td>
    La chiave inserisce il tag <em x-id="3">subscript</em>. Note<sub>1</td> </tr> 
    
    <tr>
      <td>
        <kbd>table</kbd>
      </td>
      
      <td>
        Questo tasto consente di creare rapidamente la struttura di una tabella e di scegliere tra numerose strutture di partenza
      </td>
    </tr>
    
    <tr>
      <td>
        <kbd>code</kbd>
      </td>
      
      <td>
        Inserisce un blocco di codice in linea posizionando due backtick nella posizione in cui si trova il cursore, posizionandolo al centro dei due backtick.
      </td>
    </tr>
    
    <tr>
      <td>
        <kbd>codeblock</kbd>
      </td>
      
      <td>
        Inserisce tre righe, due con triplo backtick e una vuota, dove si inseriscono i blocchi di codice. Da notare che inserisce anche la stringa <em x-id="3">language</em>, che deve essere compilata con la lingua usata nel blocco.
      </td>
    </tr></tbody> </table> 
    
    <p spaces-before="0">
      !!! note "Dichiarazione del blocco di codice"
    </p>
    
    <pre><code>Le regole del codice Markdown raccomandano di dichiarare sempre il codice utilizzato nel blocco, anche senza la necessità di evidenziazione per una corretta interpretazione. Se il codice al suo interno è troppo generico, si consiglia di usare "text" per la sua dichiarazione.
</code></pre>
    
    <p spaces-before="0">
      Le chiavi di attivazione per le scorciatoie di Markdown includono anche altre combinazioni che si possono scoprire con l'uso del server linguistico.
    </p>
    
    

<h2 spaces-before="0">
  Conclusione
</h2>

<p spaces-before="0">
  Anche se non è strettamente necessario, questo server linguistico può diventare, col tempo, un ottimo compagno nella scrittura della documentazione per Rocky Linux.
</p>

<p spaces-before="0">
  Il suo utilizzo e la conseguente memorizzazione dei principali tasti per l'inserimento dei simboli del codice Markdown consentirà una scrittura più rapida, permettendo di concentrare l'attenzione sul contenuto.
</p>

