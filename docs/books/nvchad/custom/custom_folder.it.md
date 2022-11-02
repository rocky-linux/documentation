---
title: Cartella Personalizzata
author: Franco Colussi
contributors: Steven Spencer, Franco Colussi
tested with: 8.6, 9.0
tags:
  - nvchad
  - coding
  - custom
---

# Configurazione avanzata della Cartella Personalizzata

## Introduzione

NvChad utilizza `git` per gli aggiornamenti. Ciò implica che a ogni aggiornamento, parte o l'intera configurazione viene sovrascritta dai nuovi commit. Di conseguenza, sarebbe inutile effettuare personalizzazioni all'interno della configurazione predefinita.

Per risolvere questo problema, gli sviluppatori di NvChad hanno creato una cartella `custom` che **deve essere** collocata in `.config/nvim/lua/` ed è progettata per ospitare tutti i file di configurazione personalizzati. Di seguito viene rappresentata la struttura di base di un'installazione standard di NvChad.

```text
nvim/
├── examples
│   ├── chadrc.lua
│   └── init.lua
├── init.lua
├── LICENSE
├── lua
│   ├── core
│   └── plugins
└── plugin
    └── packer_compiled.lua
```

### Creazione della Struttura

Per iniziare la personalizzazione dobbiamo creare la cartella `custom` che conterrà tutti i nostri file e anche la cartella `plugins` che conterrà i _file di configurazione_ dei nostri plugin. Poiché le cartelle non saranno presenti, utilizzeremo la flag `-p` per indicare al comando `mkdir` di creare le cartelle mancanti. Il comando sarà il seguente:

```bash
mkdir -p ~/.config/nvim/lua/custom/plugins
```

La struttura della cartella `nvim/lua` dovrebbe ora apparire come segue:

```text
├── lua
│   ├── core
│   ├── custom
│   │   └── plugins
│   └── plugins
```

La scelta del percorso non è casuale. Risponde alla necessità di preservare questa cartella dagli aggiornamenti. In caso contrario, a ogni aggiornamento la cartella verrebbe semplicemente cancellata perché non fa parte del repository.

Gli sviluppatori di NvChad hanno preparato un file `.gitignore` per questo, che ne determina l'esclusione.

```bash
cat .config/nvim/.gitignore 
plugin
custom
spell
```

### Struttura della Cartella Custom

La struttura della cartella _custom_ utilizzata per questa guida è la seguente:

```text
custom/
├── chadrc.lua
├── init.lua
├── mappings.lua
├── override.lua
└── plugins
    ├── init.lua
    └── lspconfig.lua
```

Analizzeremo il suo contenuto e descriveremo brevemente i file che contiene. I file saranno analizzati in dettaglio più tardi, sulle pagine ad essi dedicate.

- `chadrc.lua` - Questo file permette di sovrascrivere le configurazioni predefinite. Permette inoltre di sovrascrivere i plugin, in modo che possano essere associati alle configurazioni in _override.lua_. Ad esempio, viene utilizzato per salvare il tema dell'interfaccia con:

```lua
M.ui = {
  theme = "everforest",
}
```

- `init.lua` - Questo file viene eseguito dopo il file primario `init.lua`, contenuto in `nvim/lua/core/`, e consente l'esecuzione di comandi personalizzati all'avvio di NvChad.

- `mappings.lua` - Permette di impostare comandi personalizzati. Questi comandi vengono normalmente utilizzati per abbreviare i comandi standard. Un esempio è l'abbreviazione del comando `:Telescope find_files`, che può essere impostata in _mappings.lua_ in questo modo:

```lua
["\\\\"] = { "<cmd> Telescope find_files<CR>", "file-finder" },
```

permette di recuperare il **:Telescope find_files** digitando due `\\`

![Telescope Find Files](../images/telescope_find_files.png)


- `override.lua` - Questo file contiene le configurazioni personalizzate che sostituiscono quelle predefinite. Ciò è reso possibile grazie all'override effettuata a monte in _chadrc.lua_.

Passiamo ora alla cartella `plugins`. Questa cartella contiene tutti i file di configurazione dei vari plugin installati. Contiene anche il file `init.lua` per le personalizzazioni. Il file `init.lua` deve contenere i plugin che vogliamo installare sul nostro IDE. Una volta inseriti e configurati, saranno installabili tramite il comando `:PackerSync`.

L'unico plugin richiesto è _neovim/nvim-lspconfig_, che abilita la funzionalità LSP (language server) per l'editing avanzato.
