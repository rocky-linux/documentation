---
title: Installare NvChad
author: Franco Colussi
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 8.8, 9.2
tags:
  - nvchad
  - coding
  - editor
---

# :simple-neovim: Trasformare Neovim in un IDE avanzato

## :material-arrow-bottom-right-bold-outline: Prerequisiti

Come specificato sul sito di NvChad, è necessario assicurarsi che il sistema soddisfi i seguenti requisiti:

* [Neovim 0.9.4](https://github.com/neovim/neovim/releases/tag/v0.9.4).
* [Nerd Font](https://www.nerdfonts.com/) Impostato nel tuo emulatore di terminale.
    * Assicuratevi che il carattere nerd impostato non finisca con **Mono**
    * **Esempio:** Carattere Iosevka Nerd e non ~~Iosevka Nerd Font Mono~~
* [Ripgrep](https://github.com/BurntSushi/ripgrep) è necessario per la ricerca con grep in Telescope **(OPZIONALEL)**.
* GCC and Make

In realtà non si tratta di una vera e propria "installazione", ma piuttosto di scrivere una configurazione personalizzata di Neovim per il nostro utente.

??? warning "Esecuzione di un'Installazione Pulita"

    Come specificato nei requisiti, l'installazione di questa nuova configurazione su una precedente può creare problemi irrisolvibili. Si raccomanda un'installazione pulita.

### :material-content-save-cog-outline: Operazioni Preliminari

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

## :material-monitor-arrow-down-variant: Installazione

Ora che abbiamo fatto pulizia, possiamo passare all'installazione di NvChad.

### :octicons-repo-clone-16: Configurazione del clone

Per farlo, è sufficiente eseguire il seguente comando da qualsiasi posizione all'interno della propria *directory home*:

```bash
git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1 && nvim
```

La prima parte del comando clona il repository NvChad nella cartella ==~/.config/nvim==; questo è il percorso predefinito di Neovim per la ricerca della configurazione utente. L'opzione ==--depth 1== istruisce *git* di clonare solo il repository impostato come "default" su GitHub.

Una volta terminato il processo di clonazione nella seconda parte del comando, viene richiamato l'eseguibile Neovim (*nvim*), che dopo aver trovato una cartella di configurazione inizierà a importare le configurazioni incontrate nei file ==init.lua== in un ordine predefinito.

### :material-timer-cog-outline: Bootstrap

Prima di avviare il bootstrap, l'installazione ci proporrà l'installazione di una struttura di base (*template chadrc*) per la nostra ulteriore personalizzazione:

> Do you want to install chadrc template? (y/N):

Sebbene la scelta di installare la struttura raccomandata non sia obbligatoria, è sicuramente consigliata per chiunque sia alla prima esperienza con questo editor. Gli utenti di NvChad che hanno già una cartella ==custom== potranno continuare a usarla dopo aver apportato le modifiche necessarie.

La struttura creata dal modello sarà utilizzata anche in questa guida per sviluppare la configurazione da utilizzare per scrivere documenti in Markdown.

Per coloro che vogliono saperne di più su questo argomento prima di iniziare l'installazione, possono consultare la pagina dedicata [Template Chadrc](template_chadrc.md).

La pagina contiene informazioni sulla struttura della cartella che verrà creata, le funzioni dei file correlati, e altre informazioni utili per personalizzare NvChad.

A questo punto inizierà il download e la configurazione dei plugin di base e, se abbiamo scelto d'installare anche il template, l'installazione dei server linguistici configurati. Una volta completato il processo, il nostro Editor sarà pronto all'uso.

![Installazione](images/installed_first_time.png)

Come si può vedere dalla schermata sottostante, grazie alle modifiche apportate alla configurazione, l'editor ha cambiato completamente aspetto rispetto alla versione base di Neovim. Va ricordato, tuttavia, che anche se la configurazione di NvChad trasforma completamente l'editor, la base rimane Neovim.

![NvChad Rockydocs](images/nvchad_ui.png)

## :material-file-tree-outline: Configurazione della struttura

La configurazione installata consiste in due parti, una dedicata all'editor che rimane sotto il controllo di versione (==git==) del repository NvChad e una dedicata alla personalizzazione dell'utente che viene esclusa dal controllo di versione attraverso l'uso di un file ==.gitignore==.

In questo modo è possibile aggiornare l'editor senza compromettere la configurazione personale.

### Struttura di base

La parte riservata all'editor è la seguente:

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
        │   └── treesitter.lua
        └── init.lua
```

### Struttura del template

Mentre la parte relativa alla personalizzazione è costituita dalla seguente struttura:

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
├── plugins.lua
└── README.md
```

## :octicons-file-code-16: Analisi della struttura

Il primo file che incontriamo è il file `init.lua`, che inizializza la configurazione inserendo la cartella `lua/core` e i file `lua/core/utils.lua` (e, se presente, `lua/custom/init.lua`) nell'albero di _nvim_. Esegue il bootstrap di `lazy.nvim` (il plugin manager) e una volta finito inizializza la cartella `plugins`.

In particolare, la funzione `load_mappings()` è chiamata per caricare le scorciatoie da tastiera. Inoltre, la funzione `gen_chadrc_template()` fornisce la subroutine per creare la cartella `custom`.

```lua
require("core")

local custom_init_path = vim.api.nvim_get_runtime_file("lua/custom/init.lua", false)[1]

if custom_init_path then
    dofile(custom_init_path)
end

require("core.utils").load_mappings()

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

-- bootstrap lazy.nvim!
if not vim.loop.fs_stat(lazypath) then
    require("core.bootstrap").gen_chadrc_template()
    require("core.bootstrap").lazy(lazypath)
end

vim.opt.rtp:prepend(lazypath)
require("plugins")

dofile(vim.g.base46_cache .. "defaults")
```

L'inclusione della cartella `core` comporta anche l'inclusione del file `core/init.lua`, che sovrascrive alcune configurazioni dell'interfaccia di Neovim e prepara la gestione dei buffer.

Come si può vedere, ogni file `init.lua` viene incluso seguendo un ordine ben stabilito. Questo è usato per sovrascrivere selettivamente le varie opzioni delle impostazioni di base. In generale, possiamo dire che i file `init.lua` hanno le funzioni per caricare opzioni globali, autocmds o qualsiasi altra cosa.

Proseguendo con l'analisi strutturale, troviamo la cartella *lua/plugins*, che contiene l'impostazione dei plugin integrati e le loro configurazioni. I plugin principali della configurazione saranno descritti nella sezione successiva. Come si può vedere, la cartella *core/plugins* contiene anche un file ==init.lua==, che viene utilizzato per l'installazione e la successiva compilazione dei plugin.

Infine, troviamo il file ==lazy-lock.json==. Questo file ci permette di sincronizzare la configurazione dei plugin NvChad su più workstation, in modo da avere le stesse funzionalità su tutte le postazioni di lavoro utilizzate. La sua funzione è illustrata meglio nella sezione dedicata al gestore dei plugin.

## :material-keyboard-outline: Chiavi principali della tastiera

L'installazione di NvChad inserisce nell'editor anche una serie di chiavi per i comandi più comuni; la loro configurazione è contenuta nel file `lua/core/mappings.lua` e può essere modificata o estesa con il file `lua/custom/mappings.lua`.

Questa è la chiamata che restituisce le mappature dei comandi di base:

```lua
require("core.utils").load_mappings()
```

Questo sistema prevede quattro tasti principali dai quali, in associazione con altri tasti, è possibile lanciare i comandi. Le chiavi principali sono:

* C = ++ctrl++
* leader = ++space++
* A = ++alt++
* S = ++shift++

!!! note "Nota"

    Nel corso di questi documenti si farà più volte riferimento a queste mappature di chiavi.

Queste sono alcune delle chiavi impostate. Si consiglia di consultare il file sopra citato per un elenco esaustivo.

`<leader>th` per cambiare il tema ++space++ + ++"t"++ + ++"h"++  
`<C-n>` per aprire nvimtree ++ctrl++ + ++"n"++  
`<A-i>` per aprire un terminale in una scheda flottante ++alt++ + ++"i"++

Le combinazioni preimpostate sono numerose e coprono tutti gli usi di NvChad. Vale la pena soffermarsi ad analizzare le mappature delle chiavi prima di iniziare a usare l'istanza di Neovim configurata con NvChad.
