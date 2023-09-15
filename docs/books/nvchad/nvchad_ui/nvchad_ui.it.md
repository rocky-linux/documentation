---
title: NvChad UI
author: Franco Colussi
contributors: Steven Spencer, Ganna Zhyrnova
tested: 8.6, 9.0
tags:
  - nvchad
  - coding
  - interfaccia nvchad
---

# Interfaccia NvChad

!!! note "Qualche parola su `mappings.lua`"

    Nella documentazione ufficiale di NvChad, vengono citati comandi come `<leader>`, insieme ad altri tasti che potrebbero non essere comprensibili al lettore occasionale. Il motivo è il file `mappings.lua` predefinito (`../nvim/lua/core/mappings.lua`).
    
    Questo file e le mappature delle chiavi che descrive sono delineati [here](https://nvchad.com/docs/config/mappings). Per essere chiaro, puoi sovrascrivere qualsiasi mappatura di tasti usando un file `mappings.lua` personalizzato (`../nvim/lua/custom/mappings.lua`).
    
    Per evitare confusione nei documenti che state leggendo, assumeremo che stiate usando il file predefinito `mappings.lua` e sostituiremo i comandi effettivi che dovete usare per accedere a una funzione. I riferimenti chiave standard sono:

    * leader = <kbd>SPAZIO</kbd>
    * A = <kbd>ALT</kbd>
    * C = <kbd>CTRL</kbd>
    * S = <kbd>SHIFT</kbd>

    Se un comando specifica `<leader>uu` come esempio, sostituiremo la combinazione di tasti attuale con <kbd>SPAZIO</kbd><kbd>uu</kbd>.

    Questo aspetto verrà trattato nuovamente nella prossima sezione [Utilizzo di NvChad](./using_nvchad.md)

Una volta installato Neovim e inserita la configurazione di NvChad, l'IDE dovrebbe avere questo aspetto:

![NvChad Default](../images/ui_default.png)

L'interfaccia è già dotata di alcune funzionalità avanzate, come l'indicazione dello stato del repository git, ma può essere ulteriormente migliorata utilizzando i Language Server e personalizzata sovrascrivendo alcune configurazioni di base. I moduli di base che lo compongono sono illustrati di seguito.

## Tabufline

![Tabufline](../images/ui_tabufline.png)

L'interfaccia utente presenta una barra superiore chiamata `Tabufline` in cui vengono gestiti i buffer aperti. La `tabufline` viene visualizzata solo se si ha più di un file aperto. Il buffer aperto presenta l'icona del tipo di file, il nome del file e il suo stato. Lo stato è indicato da un'icona.

Se, come nell'immagine, è presente una `x` rossa, significa che il file può essere chiuso in quanto già salvato. Se invece l'icona è un punto verde `.`, allora il file deve essere salvato e il comando di chiusura <kbd>SHIFT</kbd> + <kbd>:q</kbd> produrrà un avviso: "Nessuna scrittura dall'ultima modifica".

A destra si trova l'icona per impostare il tema _scuro_ o _chiaro_. Facendo clic su di esso con il mouse, è possibile selezionare il tema desiderato.

![NvChad Light](../images/ui_default_light.png)

A destra abbiamo anche l'icona per chiudere l'editor.

## Sezione Centrale - Buffer Aperti

La parte centrale dell'editor è composta dal buffer attivo nell'editor in quel momento (_index.en.md_). Per introdurre qualche funzionalità aggiuntiva, possiamo lavorare contemporaneamente su due file in un buffer diviso, aprendone un altro nell'esempio _(index.it.md_).

Nell'editor avremo il primo buffer in primo piano e il secondo elencato nella Tabufline. Ora se dividiamo il primo buffer con il comando <kbd>SHIFT</kbd> + <kbd>:vsplit</kbd> e selezioniamo il buffer di destra, facendo clic sul nome del secondo file_(index.it.md_) nella tabufline, questo verrà aperto nel buffer di destra e potremo lavorare con i due file fianco a fianco.

![NvChad Split](../images/ui_nvchad_split.png)

## Statusline

![Statusline](../images/ui_statusline.png)

In basso troviamo la linea di stato, che gestisce le informazioni di stato. Sulla destra troviamo lo stato dell'editor. Non dobbiamo dimenticare che stiamo utilizzando un editor di testo e che, in particolare, mantiene la filosofia e il funzionamento di Vim. Gli stati possibili sono:

- **NORMAL**
- **INSERT**
- **COMMAND**
- **VISUAL**

La modifica di un documento inizia dalla modalità **NORMAL** in cui si apre il file, quindi si può passare alla modalità **INSERT** per la modifica e, al termine, uscire con <kbd>ESC</kbd> e tornare alla modalità **NORMAL**.

Ora per salvare il file si passa alla modalità **COMMAND** digitando `:` nella riga di stato seguito da `w`_(write_) per scriverlo e con <kbd>ESC</kbd> si torna alla modalità **NORMAL**. L'indicazione dello stato è molto utile durante l'apprendimento dell'uso, soprattutto se non si ha molta familiarità con il flusso di lavoro di Vim.

Troviamo quindi il nome del file aperto e, se stiamo lavorando su un repository git, avremo indicazioni sullo stato del repository. Questo grazie al plugin _lewis6991/gitsigns.nvim._

A destra troviamo il nome della cartella da cui abbiamo aperto l'editor. Nel caso di utilizzo di LSP, indica la cartella che viene presa in considerazione come `workspace`, e di conseguenza valutata durante la diagnostica, e per seguire la posizione del cursore all'interno del file.

## Aiuto Integrato

NvChad e Neovim forniscono alcuni comandi utili per visualizzare le combinazioni di tasti preimpostate e le opzioni disponibili.

Se il tasto <kbd>SPAZIO</kbd> viene premuto da solo, viene visualizzata una legenda dei comandi associati, come nella seguente schermata:

![Chiave Dello Spazio](../images/ui_escape_key.png)

Per visualizzare tutti i comandi inclusi nell'editor si può usare il comando <kbd>SPAZIO</kbd> + <kbd>wK</kbd>, che darà il seguente risultato:

![leader wK](../images/ui_wK_key.png)

E premendo <kbd>d</kbd> possiamo visualizzare i rimanenti comandi:

![leader wK d](../images/ui_wK_01.png)

Come si può notare, quasi tutti i comandi si riferiscono alla navigazione all'interno del documento o del buffer. Non sono inclusi comandi per l'apertura del file. Questi sono forniti da Neovim.

Per visualizzare tutte le opzioni di Neovim, è disponibile il comando <kbd>SHIFT</kbd> + <kbd>:options</kbd>, che presenta una struttura ad albero delle opzioni indicizzate per categoria.

![Opzioni Nvim](../images/nvim_options.png)

In questo modo, attraverso la guida integrata, è possibile imparare i comandi mentre si utilizza l'editor e approfondire le opzioni disponibili.

## NvimTree

Per lavorare con i nostri file abbiamo bisogno di un File Explorer, fornito dal plugin _kyazdani42/nvim-tree.lua_. Con la combinazione <kbd>CTRL</kbd> + <kbd>n</kbd> possiamo aprire NvimTree.

![NvimTree](../images/nvim_tree.png)

Una descrizione dettagliata dei comandi e delle funzioni di NvimTree si trova nella [pagina dedicata](nvimtree.md).

Dopo aver esplorato i componenti dell'interfaccia, possiamo passare all'uso di NvChad.
