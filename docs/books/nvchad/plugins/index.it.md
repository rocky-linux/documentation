---
title: Panoramica
author: Franco Colussi
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 8.7, 9.1
tags:
  - nvchad
  - plugins
  - editor
---

# Panoramica

## :material-message-outline: Introduzione

La configurazione personalizzata creata dagli sviluppatori di NvChad permette di avere un ambiente integrato con molte delle caratteristiche di un IDE grafico. Queste caratteristiche vengono integrate nella configurazione di Neovim per mezzo di plugin. Quelli selezionati per NvChad dagli sviluppatori hanno la funzione di impostare l'editor per l'uso generale.

Tuttavia, l'ecosistema di plugin per Neovim è molto più ampio e, grazie al loro utilizzo, consente di estendere l'editor per concentrarsi sulle proprie esigenze.

Lo scenario affrontato in questa sezione è la creazione di documentazione per Rocky Linux, quindi verranno illustrati i plugin per la scrittura di codice Markdown, la gestione dei repository Git e altri compiti legati allo scopo.

### :material-arrow-bottom-right-bold-outline: Requisiti

- NvChad correttamente installato nel sistema
- Familiarità con la riga di comando
- Una connessione internet attiva

### :material-comment-processing-outline: Suggerimenti generali sui plugin

La configurazione di NvChad prevede l'inserimento dei plugin utente dalla cartella `lua/plugins`. Al suo interno si trova inizialmente il file **init.lua** con l'installazione del plugin *conform.nvim* e alcuni esempi per la personalizzazione delle funzionalità del sistema.  
Anche se è possibile inserire i propri plugin nel file, è consigliabile utilizzare file separati per le configurazioni degli utenti. In questo modo, si può usare il file iniziale per qualsiasi sovrascrittura dei plugin di base, mentre si possono organizzare i plugin in file indipendenti, secondo le proprie preferenze.

### :material-location-enter: Inserimento dei plugin

La configurazione interroga la cartella `plugins` e vengono caricati tutti i file *.lua* in essa contenuti. Questo permette di unire più file di configurazione quando vengono caricati dall'editor.  
Per essere inseriti correttamente, i file aggiuntivi devono avere le configurazioni dei plugin racchiuse all'interno di ==tabelle lua==:

```lua title="lua table example"
return {
    { -- lua table
    -- your plugin here
    }, -- end lua table
}
```

È presente anche una cartella `configs` in cui è possibile inserire impostazioni particolarmente lunghe di alcuni plugin o parti modificabili dall'utente, come nel caso di *conform.nvim*.

Passando ad un esempio pratico, supponiamo di voler includere nelle funzionalità dell'editor il plugin [karb94/neoscroll.nvim](https://github.com/karb94/neoscroll.nvim), che permette di migliorare lo scorrimento all'interno di file molto lunghi.  
Per la sua creazione possiamo scegliere di creare un file `plugins/editor.lua` in cui inserire tutti i plugin relativi all'uso dell'editor o un file `plugins/neoscroll.lua` e tenere separati tutti i plugin aggiuntivi.

In questo esempio, seguiremo la prima opzione, quindi creeremo un file nella cartella `plugins`:

```bash
touch ~/.config/nvim/lua/plugins/editor.lua
```

Seguendo le informazioni della pagina del progetto, inseriamo il seguente blocco di codice:

```lua title="editor.lua"
return {
{
    "karb94/neoscroll.nvim",
    keys = { "<C-d>", "<C-u>" },
    opts = { mappings = {
        "<C-u>",
        "<C-d>",
    } },
},
}
```

Una volta salvato, verrà riconosciuto dalla configurazione di NvChad, che si occuperà del suo inserimento utilizzando le funzionalità offerte dal gestore *lazy.nvim*.

Neovim, su cui si basa la configurazione di NvChad, non integra un meccanismo di aggiornamento automatico della configurazione con l'editor in esecuzione. Questo comporta che ogni volta che il file del plugin viene modificato, è necessario chiudere `nvim` e poi riaprirlo per ottenere la piena funzionalità del plugin.

![plugins.lua](./images/plugins_lua.png)

## Conclusioni e considerazioni finali

Esiste un ampio ecosistema di plugin per Neovim che possono essere integrati in NvChad. Per le ricerche si può utilizzare il supporto del sito [Dotfyle](https://dotfyle.com/) che fornisce informazioni su plugin e configurazioni per Neovim o di [Neovimcraft](https://neovimcraft.com/), che si concentra invece solo sui plugin disponibili. Entrambi forniscono ottime informazioni generali sui plugin e link ai rispettivi progetti su GitHub.

L'introduzione della nuova funzione di ricerca dei plugin, presente dalla versione 2.5, consente di organizzare i plugin degli utenti in modo molto efficiente e altamente configurabile. In una configurazione complessa, consente ai plugin che richiedono configurazioni speciali (codice lua o autocmd) di essere gestiti separatamente, semplificando notevolmente la loro gestione.
