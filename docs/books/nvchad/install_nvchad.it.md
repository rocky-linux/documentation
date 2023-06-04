---
title: Installare NvChad
author: Franco Colussi
contributors: Steven Spencer, Franco Colussi
tested with: 8.8, 9.2
tags:
  - nvchad
  - coding
---

# Trasformare Neovim in un IDE avanzato

## Pre-requisiti

Come specificato sul sito NvChad è necessario assicurarsi di soddisfare i seguenti requisiti:

- [Neovim 0.8.3](https://github.com/neovim/neovim/releases/tag/v0.8.3).
- [Nerd Font](https://www.nerdfonts.com/) Impostato nel tuo emulatore di terminale.
  - Assicurati che il carattere nerd che hai impostato non finisca con **Mono**
   - **Esempio :** Carattere Iosevka Nerd e non ~~Iosevka Nerd Font Mono~~
- [Ripgrep](https://github.com/BurntSushi/ripgrep) è necessario per la ricerca con grep in Telescope **(OPZIONALEL)**.
- GCC

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

E poi cancellare tutte le configurazioni e i file precedenti:

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

La prima parte del comando clona il repository NvChad nella cartella `~/.config/nvim`; questo è il percorso predefinito di Neovim per la ricerca della configurazione utente. L'opzione `--depth 1` istruisce _git_ di clonare solo il repository impostato come "default" su GitHub.

Una volta terminato il processo di clonazione nella seconda parte del comando, viene richiamato l'eseguibile Neovim (_nvim_), che dopo aver trovato una cartella di configurazione inizierà a importare le configurazioni incontrate nei file `init.lua` di tale cartella in un ordine predefinito.

Prima di avviare il bootstrap, l'installazione ci proporrà l'installazione di una struttura di base (_template chadrc_) per le nostre ulteriori personalizzazioni:

> Do you want to install chadrc template? (y/N) :

Sebbene la scelta di installare la struttura raccomandata non sia obbligatoria, è sicuramente consigliata per chiunque sia alla prima esperienza con questo editor. Gli utenti attuali di NvChad che hanno già una cartella `custom` saranno in grado di continuare ad utilizzarla dopo aver apportato le modifiche necessarie.

La struttura creata dal modello sarà utilizzata anche in questa guida per sviluppare la configurazione da utilizzare per scrivere documenti in Markdown.

Per coloro che vogliono saperne di più su questo argomento prima di iniziare l'installazione, possono consultare la pagina dedicata [Template Chadrc](template_chadrc.md).

La pagina contiene informazioni sulla struttura della cartella che verrà creata, le funzioni dei file correlati, e altre informazioni utili per personalizzare NvChad.

A questo punto inizierà il download e la configurazione dei plugin di base e, se abbiamo scelto d'installare anche il template, l'installazione dei server linguistici configurati. Una volta completato il processo, il nostro Editor sarà pronto all'uso.

![Installazione](images/installed_first_time.png)

Come si può vedere dalla schermata sottostante, grazie alle modifiche apportate alla configurazione, l'editor ha cambiato completamente aspetto rispetto alla versione base di Neovim. Va ricordato, tuttavia, che anche se la configurazione di NvChad trasforma completamente l'editor, la base rimane Neovim.

![NvChad Rockydocs](images/nvchad_ui.png)

### Struttura della configurazione

Passiamo ora ad analizzare la struttura che la configurazione ha creato, la struttura è la seguente:

```text
.config/nvim
├── init.lua
├── lazy-lock.json
├── LICENSE
└── lua
    ├── core
    │   ├── bootstrap.lua
    │   ├── default_config.lua
    │   ├── init.lua
    │   ├── mappings.lua
    │   └── utils.lua
    └── plugins
        ├── configs
        │   ├── cmp.lua
        │   ├── lazy_nvim.lua
        │   ├── lspconfig.lua
        │   ├── mason.lua
        │   ├── nvimtree.lua
        │   ├── others.lua
        │   ├── telescope.lua
        │   ├── treesitter.lua
        │   └── whichkey.lua
        └── init.lua
```

Se si sceglie di installare anche il _template chadrc_, si avrà anche la cartella `nvim/lua/custom` con la seguente struttura:

```text
.config/nvim/lua/custom/
├── chadrc.lua
├── configs
│   ├── lspconfig.lua
│   ├── null-ls.lua
│   └── overrides.lua
├── highlights.lua
├── init.lua
├── mappings.lua
└── plugins.lua
```


Il primo file che incontriamo è il file `init.lua`, che inizializza la configurazione inserendo la cartella `lua/core` e i file `lua/core/utils.lua` (e, se presente, `lua/custom/init.lua`) nell'albero di _nvim_. Esegue il bootstrap di `lazy.nvim` (il plugin manager) e una volta finito inizializza la cartella `plugins`.

In particolare, la funzione `load_mappings()` è chiamata per caricare le scorciatoie da tastiera. Inoltre, la funzione `gen_chadrc_template()` fornisce la subroutine per creare la cartella `custom`.

```lua
require "core"

local custom_init_path = vim.api.nvim_get_runtime_file("lua/custom/init.lua", false)[1]

if custom_init_path then
  dofile(custom_init_path)
end

require("core.utils").load_mappings()

local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

-- bootstrap lazy.nvim!
if not vim.loop.fs_stat(lazypath) then
  require("core.bootstrap").gen_chadrc_template()
  require("core.bootstrap").lazy(lazypath)
end

vim.opt.rtp:prepend(lazypath)
require "plugins"

dofile(vim.g.base46_cache .. "defaults")
```

L'inclusione della cartella `core` comporta anche l'inclusione del file `core/init.lua`, che sovrascrive alcune configurazioni dell'interfaccia di Neovim prepara la gestione del buffer.

Come si può vedere, ogni file `init.lua` viene incluso seguendo un ordine ben stabilito. Questo è usato per sovrascrivere selettivamente le varie opzioni delle impostazioni di base. In generale, possiamo dire che i file `init.lua` hanno le funzioni per caricare opzioni globali, autocmds o qualsiasi altra cosa.

Questa è la chiamata che restituisce le mappature dei comandi di base:

```lua
require("core.utils").load_mappings()
```

Questo sistema prevede quattro tasti principali dai quali, in associazione con altri tasti, è possibile lanciare i comandi. Le chiavi principali sono:

- C = <kbd>CTRL</kbd>
- leader = <kbd>SPAZIO</kbd>
- A = <kbd>ALT</kbd>
- S = <kbd>MAIUSC</kbd>

!!! note "Nota"

    Nel corso di questi documenti si farà più volte riferimento a queste mappature di chiavi.

La mappatura predefinita è contenuta in _core/mapping.lua_, ma può essere estesa con altri comandi personalizzati usando il proprio _mappings.lua_.

Alcuni esempi della mappatura standard sono:

```text
<space>th per cambiare il tema
<CTRL-n> per aprire nvimtree
<ALT-i> per aprire un terminale in una scheda fluttuante
```

Ci sono molte combinazioni preimpostate che coprono tutti gli usi di NvChad. Vale la pena soffermarsi ad analizzare le mappature delle chiavi prima di iniziare a usare l'istanza di Neovim configurata con NvChad.

Proseguendo con l'analisi strutturale, troviamo la cartella _lua/plugins_, che contiene l'impostazione dei plugin integrati e le loro configurazioni. I plugin principali della configurazione saranno descritti nella sezione successiva. Come si può vedere, la cartella _core/plugins_ contiene anche un file `init.lua`, che viene utilizzato per l'installazione e la successiva compilazione dei plugin.

Infine, troviamo il file `lazy-lock.json`. Questo file ci permette di sincronizzare la configurazione dei plugin NvChad su più workstation, in modo da avere le stesse funzionalità su tutte le postazioni di lavoro utilizzate. La sua funzione è illustrata meglio nella sezione dedicata al gestore dei plugin.
