---
title: Editor Changes
author: Franco Colussi
contributors: Steven Spencer
tested_with: 9.4
tags:
  - neovim
  - nvchad
  - editor
  - markdown
---

Le funzionalità di base di NvChad sono state ampliate per fornire un'esperienza migliorata di quella ottima già fornita dall'editor, sono presenti funzioni per gestione dei file, la navigazione del buffer, la copia delle stringhe e altre piccole utilità.

## File Manager

La modifica più rilevante alla configurazione dell'editor è la sostituzione del file manager utilizzato da NvChad, al suo posto è stato utilizzato [neo-tree.nvim](https://github.com/nvim-neo-tree/neo-tree.nvim), questo plugin permette di avere una configurazione più semplice e fornisce "fuori dalla scatola" un layout flottante e vari parametri da passare al comando `:Neotree`.

![Neotree Standard](./images/neo-tree.png)

I comandi utilizzati in NvChad sono stati migrati per riflettere le modifiche ma le funzionalità rimangono le stesse, con ++ctrl+"n"++ si apre lateralmente il file manager e con ++space+"e"++ si posiziona il focus su di esso.

!!! note "Disabilitazione di nvimtree"

    Il plugin fornito dalla configurazione di base è stato completamente disabilitato per evitare problemi di incompatibilità con il suo sostituto, la disabilitazione è impostata nel file `lua/plugins/init.lua`.

    ```lua
    -- disable nvim-tree
    {
    "nvim-tree/nvim-tree.lua",
    enabled = false,
    },
    ```

Il plugin fornisce anche un layout flottante che viene richiamato con il carattere ++"-"++, il comando eseguito da questa scorciatoia corrisponde all'esecuzione di *Neotree* con la flag ==float==, al comando in particolare è stata aggiunta anche la flag ==toggle== per utilizzare lo stesso carattere anche per chiudere il buffer.

![Floating Neotree](./images/neo-tree_float.png)

La scorciatoia può essere modificata secondo preferenze modificando il carattere corrispondente nel file `lua/plugins/neotree.lua`.

```lua
  { -- lazy style key map
   "-",
   "<cmd>Neotree float toggle<cr>",
   desc = "file manager float",
  },
```

Il comando `:Neotree` dispone di numerose opzioni e layout predefiniti, per un suo approfondimento visitare [la sezione relativa](https://github.com/nvim-neo-tree/neo-tree.nvim?tab=readme-ov-file#the-neotree-command) della documentazione.

## Command line

Affiancata alla *cmdline* fornita da NvChad è stata inserita anche una seconda *command line* più moderna e funzionale, il suo inserimento è stato effettuato nel file `lua/plugins/telescope.lua`. Il plugin è un *picker* personalizzato di *Telescope*, fornisce una cronologia dei comandi effettuati e ne permette la ricerca, la funzionalità è fornita dal plugin [telescope-cmdline.nvim](https://github.com/jonarrien/telescope-cmdline.nvim).

![Cmdline](./images/cmdline_telescope.png)

## Copy and Paste

Le funzionalità del copia/incolla sono state ampliate mediante l'integrazione nella configurazione di [yanky.nvim](https://github.com/gbprod/yanky.nvim), questo plugin permette di incollare, da una comoda cronologia visualizzata in *Telescope*, le stringhe copiate in precedenza. La cronologia (*yanky-ring*) viene salvata in `~.local/share/nvim/databases/yanky.db`, si tratta di un database *sqlite* che consente di immagazzinare un numero superiore di stringhe e offre migliori prestazioni nella ricerca.  
Le chiavi per utilizzare *yanky* sono ++space+"y"++ in modalità *NORMAL* e ++ctrl+"y"++ nella modalità *INSERT*, entrambe posizionano la stringa da incollare nella posizione corrente in cui si trova il cursore.

![Yank Ring](./images/yank_ring.png)

## Ulteriori integrazioni

Ai plugin che forniscono le funzionalità descritte sopra sono stati aggiunti inoltre alcuni plugin che forniscono funzionalità comuni dedicate alla gestione del buffer.

* [nvim-highlight-colors](https://github.com/brenoprata10/nvim-highlight-colors) for color code translation (*hexadecimal*), this plugin adds a background color to the hexadecimal value (e.g. #FCFCFC) making it much easier to manage and edit. The feature is particularly useful for those who want to try their hand at editing NvChad themes. The ++space+"uC "++ shortcut is available for activation, which also allows its disabling (*toggle command*).

![Highlight Colors](./images/hl_colors.png)

* [neoscroll.nvim](https://github.com/karb94/neoscroll.nvim) enables smoother scrolling of the document (in *NORMAL* mode), its use allows you to quickly navigate the markdown file, which is useful for both editing and reviewing documents. The plugin provides two commands, ++ctrl+"u "++ and ++ctrl+"d "++ to scroll up or down the document.

## Controllo ortografico

Una delle funzioni *built-in* di Neovim è il controllo ortografico, questa funzione permette di confrontare la parola che si ha appena scritto con le parole contenute in un dizionario `myspell` di quella lingua, si possono così evitare gli errori di battitura, permettendo di eliminare questo controllo dalla revisione del documento.  
Il dizionario per la lingua inglese è disponibile assieme ad una installazione standard di Neovim e può essere attivata immediatamente con il comando `:set spell spelllang=en`, per gli utenti internazionali invece i dizionari non sono disponibili e devono essere costruiti in locale.

!!! warning "Disabilitazione dei plugin built-in di Neovim"

L'uso del gestore dei plugin *lazy.nvim* comporta la totale disabilitazione dei plugin inclusi in Neovim, di conseguenza per NvChad non possono essere seguiti i tutorial sull'argomento che si trovano in rete, i dizionari devono necessariamente essere scaricati e costruiti utilizzando una copia locale.
