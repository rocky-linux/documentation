---
title: init.lua
author: Franco Colussi
contributors: Steven Spencer, Franco Colussi
tested with: 8.6, 9.0
tags:
  - nvchad
  - coding
  - editor
---

# `init.lua`

Il file `custom/plugins/init.lua` chiude la configurazione di NvChad. È l'ultimo `init.lua` che viene letto e inserisce i nostri plugin aggiuntivi nella configurazione.

La sua configurazione consiste nell'inserire i plugin nel seguente formato:

```lua
  ["github_username/plugin_name"] = {},
```

Se il plugin non necessita di configurazioni aggiuntive, la configurazione descritta sopra è sufficiente. Se sono necessarie ulteriori configurazioni, queste verranno inserite all'interno delle parentesi graffe.

Prendiamo il nostro file di esempio:

```lua
return {
  ["neovim/nvim-lspconfig"] = {
    config = function()
      require "plugins.configs.lspconfig"
      require "custom.plugins.lspconfig"
    end,
    },
  ["kdheepak/lazygit.nvim"] = {},
  ['folke/which-key.nvim'] = { disable = false  },
}
```

In questa configurazione abbiamo incluso solo i due plugin necessari *nvim-lspconfig* e *che-key*, più uno che non richiede alcuna configurazione aggiuntiva come esempio. I due plugin sono necessari perché senza la loro configurazione non avremo il supporto per gli LSP (server linguistici), anche se sono installati. La funzionalità di *which-key* è disabilitata per impostazione predefinita e vogliamo abilitarla qui.

Come possiamo vedere, il primo plugin chiama la funzione di configurazione e legge prima il file `nvim/lua/plugins/configs/lspconfig.lua` e poi il *nostro* file `nvim/lua/custom/plugins/lspconfig.lua`. In questo caso viene utilizzato un file aggiuntivo per le configurazioni personali. La scelta dipende dal numero di modifiche da apportare.

Il secondo è un esempio di plugin che non necessita di alcuna configurazione aggiuntiva. Una volta installato, consente di accedere alla gestione dei repository Git direttamente dall'editor con il comando <kbd>SHIFT</kbd> + <kbd>:LazyGit</kbd>. Per l'installazione di LazyGit si può fare riferimento alla pagina [Software aggiuntivo](../../additional_software.md).

Il terzo è un esempio di inserimento delle configurazioni da sovrascrivere direttamente nel file. In questo caso, l'unica modifica è la riattivazione del plugin disattivato di default (which-key). Questo plugin è racchiuso da due apici singoli che possono sostituire gli apici doppi. Le due notazioni sono equivalenti.

Una volta terminata la configurazione del file e di tutti i file di configurazione correlati, è necessario attivarli. A tal fine, è necessario uscire dall'editor, rientrare e quindi eseguire un comando <kbd>SHIFT</kbd> + <kbd>:PackerSync</kbd>.

In breve possiamo dire che questo file è il motore di tutti i nostri plugin personali. È qui che viene configurata la maggior parte delle funzionalità aggiuntive del nostro IDE.
