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
