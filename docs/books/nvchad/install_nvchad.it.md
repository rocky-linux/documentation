---
title: Installare NvChad
author: Fanco Colussi
contributors: Steven Spencer, Franco Colussi
tested with: 8.6, 9.0
tags:
  - nvchad
  - coding
---

## Trasformare Neovim in un IDE avanzato

In realtà non si tratta di una vera e propria "installazione", ma piuttosto di scrivere una configurazione personalizzata di Neovim per il nostro utente.

!!! warning "Esecuzione di un'Installazione Pulita"

    Come specificato nei requisiti, l'installazione di questa nuova configurazione su una precedente può creare problemi irrisolvibili. Si raccomanda un'installazione pulita.

### Operazioni Preliminari

Se avete già utilizzato l'installazione di Neovim, questa avrà creato tre cartelle in cui scrivere i vostri file, che sono:

```text
~/.config/nvim
~/.local/share/nvim
~/.cache/nvim
```

Per eseguire un'installazione pulita della configurazione, è necessario eseguire prima un backup di quella precedente:

```bash
mkdir ~/backup_nvim
cp -r ~/.config/nvim ~/backup_nvim
cp -r ~/.local/share/nvim ~/backup_nvim
cp -r ~/.cache/nvim ~/backup_nvim
```

E poi cancelliamo tutte le configurazioni e i file precedenti:

```bash
rm -rf ~/.config/nvim
rm -rf ~/.local/share/nvim
rm -rf ~/.cache/nvim
```

Ora che abbiamo fatto pulizia, possiamo passare all'installazione di NvChad.

A tale scopo, è sufficiente eseguire il seguente comando da qualsiasi posizione all'interno della propria _home directory_:

```bash
git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1 && nvim
```

Il comando esegue un clone della configurazione di NvChad ospitata su GitHub nella cartella utente `~/.config/nvim`.

Una volta terminato il processo di clonazione, i plugin che fanno parte della configurazione predefinita saranno installati e configurati e si avrà un IDE essenziale pronto all'uso.

![Temi NvChad](images/nvchad_init.png)

Come si può vedere dalla schermata sottostante, grazie alle modifiche apportate alla configurazione, l'editor ha cambiato completamente aspetto rispetto alla versione base di Neovim. Va ricordato, tuttavia, che anche se la configurazione di NvChad trasforma completamente l'editor, la base rimane Neovim.

![NvChad Rockydocs](images/nvchad_ui.png)

### Struttura Della Configurazione

Passiamo ora ad analizzare la struttura che la configurazione ha creato, la struttura è la seguente:

```text
nvim/
├── examples
│   ├── chadrc.lua
│   └── init.lua
├── init.lua
├── LICENSE
├── lua
│   ├── core
│   │   ├── default_config.lua
│   │   ├── init.lua
│   │   ├── lazy_load.lua
│   │   ├── mappings.lua
│   │   ├── options.lua
│   │   ├── packer.lua
│   │   └── utils.lua
│   └── plugins
│       ├── configs
│       │   ├── alpha.lua
│       │   ├── cmp.lua
│       │   ├── lspconfig.lua
│       │   ├── mason.lua
│       │   ├── nvimtree.lua
│       │   ├── nvterm.lua
│       │   ├── others.lua
│       │   ├── telescope.lua
│       │   ├── treesitter.lua
│       │   └── whichkey.lua
│       └── init.lua
└── plugin
    └── packer_compiled.lua
```

!!! note "Nota"

    Per il momento lasceremo fuori il contenuto della cartella `examples` in quanto si riferisce alla configurazione `custom`, che affronteremo nelle sezioni successive.

Il primo file che incontriamo è il file `init.lua` che inizializza la configurazione inserendo le cartelle `lua/core`, `lua/plugins` (e se presente `lua/custom`) nell'albero di _nvim_. Inserisce anche i seguenti file: `lua/core/options.lua`, `lua/core/utils.lua` e `lua/core/packer.lua`.

In particolare, la funzione `load_mappings` viene richiamata per caricare le scorciatoie da tastiera e `bootstrap` per caricare i plugin preconfigurati.

```lua
require "core"
require "core.options"

vim.defer_fn(function()
  require("core.utils").load_mappings()
end, 0)

-- setup packer + plugins
require("core.packer").bootstrap()
require "plugins"

pcall(require, "custom")
```

L'inclusione della cartella `core` comporta anche l'inclusione del file `core/init.lua`, che sovrascrive alcune configurazioni dell'interfaccia di Neovim e si prepara per la gestione del buffer.

Come si può vedere, ogni file `init.lua` viene incluso seguendo un ordine ben stabilito. Possiamo anticipare che anche il file `init.lua` che creeremo nella nostra personalizzazione sarà incluso, ma logicamente per ultimo nell'ordine di caricamento. A grandi linee, possiamo dire che i file `init.lua` hanno le seguenti funzioni:

- caricare le opzioni globali, gli autocmd o qualsiasi altra cosa.
- sovrascrive le opzioni predefinite in `core/options.lua`.

Questa è la chiamata che restituisce le mappature dei comandi di base:

```lua
`require("core.utils").load_mappings()
```

Questo sistema prevede quattro tasti principali dai quali, in associazione con altri tasti, è possibile lanciare i comandi. Le chiavi principali sono:

- C = CTRL
- leader = SPACE
- A = ALT
- S = SHIFT

!!! note "Nota"

    Nel corso di questi documenti si farà più volte riferimento a queste mappature di chiavi.

La mappatura predefinita è contenuta in _core/mapping.lua_, ma può essere estesa con altri comandi personalizzati usando il proprio _mappings.lua_.

Alcuni esempi della mappatura standard sono:

```text
<space>uu per aggiornare NvChad
<space>th per cambiare il tema
<CTRL-n> per aprire nvimtree
<ALT-i> per aprire un terminale in una scheda fluttuante
```

Ci sono molte combinazioni preimpostate che coprono tutti gli usi di NvChad. Vale la pena soffermarsi ad analizzare le mappature delle chiavi prima di iniziare a usare l'istanza di Neovim configurata con NvChad.

Proseguendo con l'analisi strutturale, troviamo la cartella _lua/plugins_, che contiene l'impostazione dei plugin integrati e le loro configurazioni. I plugin principali della configurazione saranno descritti nella sezione successiva. Come si può vedere, la cartella _core/plugins_ contiene anche un file `init.lua`, che viene utilizzato per l'installazione e la successiva compilazione dei plugin.

Infine, troviamo la cartella _nvim/plugin_ che contiene un file autogenerato dei plugin compilati.
