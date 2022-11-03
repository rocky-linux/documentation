---
title: Linter & Formatter
author: Franco Colussi
contributors: Steven Spencer, Franco Colussi
tested with: 8.6, 9.0
tags:
  - nvchad
  - coding
  - editor
  - plugins
---

# Null-ls

Il plugin `jose-elias-alvarez/null-ls.nvim`, sebbene non sia essenziale per il funzionamento dell'IDE, è sicuramente da avere nella configurazione. Consente di utilizzare le funzioni del server linguistico per inserire LSP dedicati alla diagnostica, alla formattazione e ad altre operazioni.

Null-ls mira a semplificare la creazione, la condivisione e l'impostazione delle fonti LSP. Consente di migliorare le prestazioni eliminando i processi esterni.

## Inserimento dei Plugin

L'inserimento del plugin consiste nella modifica del file `custom/plugins/init.lua` e nella creazione di un nuovo file di configurazione `custom/plugins/null-ls.lua`. Il codice da inserire in _init.lua_ è il seguente:

```lua
["jose-elias-alvarez/null-ls.nvim"] = {
    after = "nvim-lspconfig",
        config = function()
            require("custom.plugins.null-ls")
    end,
},
```

Come evidenziato anche dal codice, l'inserimento deve avvenire dopo il plugin _neovim/nvim-lspconfig_. Viene quindi richiamata la funzione di configurazione e viene richiesto il nostro file di configurazione _null-ls.lua._

### Installazione LSP Richiesti

Per un corretto funzionamento, i server linguistici devono essere installati separatamente con _Mason_. Per l'installazione, si può usare l'interfaccia richiamabile con il comando `:Mason`, oppure l'installazione da _statusline_ con il comando `:MasonInstall nome_lsp`, ad esempio:

```text
:MasonInstall markdownlint
```

![Mason UI](../../images/mason_install_ui.png)

Gli LSP da installare sono `prettierd`, `markdownlint` e `stylua`. I primi due LSP forniranno funzionalità di formattazione e diagnostica per il codice Markdown, mentre il terzo fornisce supporto per la formattazione del codice Lua.

!!! attention "Impostazione di Markdownlint"

    Per un uso ottimale del linter, è necessario inserire un file di configurazione `rc` nella propria home directory; istruzioni dettagliate sono disponibili alla fine di questo documento.

## Creazione di null-ls.lua

Una volta installati i server linguistici necessari, possiamo passare alla creazione del file `custom/plugins/null-ls.lua.`  Per farlo, possiamo semplicemente utilizzare il nostro NvChad:

```bash
nvim ~/.config/nvim/lua/custom/plugins/null-ls.lua
```

Copiamo il codice qui sotto, portiamoci nell'IDE assicurandoci di essere nello stato NORMAL e con il tasto <kbd>p</kbd> (incolla) lo inseriamo. Poi basta salvarlo e chiuderlo con il comando `:wq.`

```lua
local present, null_ls = pcall(require, "null-ls")

if not present then
  return
end

local b = null_ls.builtins

local sources = {
  -- format html and markdown
  b.formatting.prettierd.with { filetypes = { "html", "yaml", "markdown" } },
  -- markdown diagnostic
  b.diagnostics.markdownlint,
  -- Lua formatting
  b.formatting.stylua,
}

local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
local on_attach = function(client, bufnr)
  if client.supports_method "textDocument/formatting" then
    vim.api.nvim_clear_autocmds { group = augroup, buffer = bufnr }
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = augroup,
      buffer = bufnr,
      callback = function()
        -- on 0.8, you should use vim.lsp.buf.format({ bufnr = bufnr }) instead
        vim.lsp.buf.formatting_sync()
        end,
    })
  end
end

null_ls.setup {
  debug = true,
  sources = sources,
  on_attach = on_attach,
}
```

Una volta terminate le modifiche, per istruire NvChad dobbiamo eseguire un `:PackerSync`. È consigliabile uscire dall'editor e rientrare prima di effettuare la sincronizzazione.

### Fonti LSP

La parte del file di configurazione _null-ls.lua_ in cui possiamo intervenire con eventuali modifiche è la seguente:

```lua
local sources = {
  -- format html and markdown
  b.formatting.prettierd.with { filetypes = { "html", "yaml", "markdown" } },
  -- markdown diagnostic
  b.diagnostics.markdownlint,
  -- Lua formatting
  b.formatting.stylua,
}

```

Le nostre fonti locali sono impostate utilizzando le funzioni `b.formatting` e `b.diagnostic` fornite da _null-ls_, seguite dagli LSP scelti. Per un elenco completo delle funzioni incluse nel plugin, consultare la [pagina del progetto](https://github.com/jose-elias-alvarez/null-ls.nvim).

Per la formattazione dei documenti Markdown sono disponibili anche altri LSP. L'impostazione qui utilizzata fornisce un supporto eccellente ma, per un elenco completo, è possibile consultare la [pagina dedicata](https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md).

### Impostazione Markdownlint

_Markdownlint_ funziona confrontando il codice che scriviamo con le regole stabilite dal progetto, che si trovano in [questa pagina](https://github.com/DavidAnson/markdownlint/blob/main/doc/Rules.md).

Una volta attivato, ogni volta che un file Markdown viene modificato e l'editor torna in modalità NORMAL, dovrebbe apparire un messaggio nella parte centrale della _riga di stato_. Questo ci informa prima del controllo con il `diagnostic markdown` e, una volta terminato il controllo, il messaggio degli errori trovati: `diagnostic (0%)`. La percentuale si riferisce al numero di errori trovati e non all'avanzamento del file.

Le regole stabilite da `markdownlint` sono molto rigide e includono, ad esempio, una lunghezza massima delle righe di 80 parole, che nella scrittura della documentazione potrebbe non essere adeguata. Per aggirare queste limitazioni, è possibile modificare le impostazioni passate all'eseguibile posizionando un file `rc` nella _cartella di lavoro_ per una modifica a livello di progetto, o nella propria _home_ per una modifica a livello di utente. Il file deve essere chiamato `.markdownlintrc` se si trova nella propria _home_ o `.markdownlint.jsonc` se si trova nella _cartella di lavoro_ del progetto. Per lavorare su un fork della documentazione di Rocky, la prima soluzione è preferibile, perché non interferisce con il _repository Git_.

I commenti sono esplicativi dei controlli effettuati dalle varie regole. In particolare, la regola _MD013_ sulla lunghezza massima delle righe (lunghezza personalizzabile), se non modificata, è particolarmente noiosa. La regola _MD033_ è necessaria per evitare avvisi quando si inseriscono i tasti della tastiera `<kbd>` e può essere integrata in forma di array con altri tasti. La regola _MD025_ impedisce che l'interpretazione del titolo, presente nel _frontmatter_, generi l'errore di doppia intestazione `H1`. La regola _MD046_ modifica il valore predefinito (consistent) in _fenced_. Questo perché nella documentazione di Rocky Linux le ammonizioni (indent) sono comunemente usate con i codici di blocco (fenced), che darebbero un errore di incoerenza.

L'esempio completo, ottimamente commentato, si trova nelle [pagine correlate](https://github.com/DavidAnson/markdownlint/blob/main/schema/.markdownlint.jsonc).

Ecco, quindi, il file `.markdownlintrc` proposto:

```json
{
  // Default state for all rules
  "default": true,
  // MD007/ul-indent - Unordered list indentation
  "MD007": {
    // Spaces for indent
    "indent": 4,
    // Whether to indent the first level of the list
    "start_indented": true,
    // Spaces for first level indent (when start_indented is set)
    "start_indent": 4
  },
  // MD013/line-length - Line length
  "MD013": {
    // Number of characters
    "line_length": 480,
    // Number of characters for headings
    "heading_line_length": 80,
    // Number of characters for code blocks
    "code_block_line_length": 280,
    // Include code blocks
    "code_blocks": true,
    // Include tables
    "tables": true,
    // Include headings
    "headings": true,
    // Include headings
    "headers": true,
    // Strict length checking
    "strict": false,
    // Stern length checking
    "stern": false
  },
  // MD033/no-inline-html - Inline HTML
  "MD033": {
    // Allowed elements
    "allowed_elements": ["kbd"]
  },
  // MD025/single-title/single-h1 - Multiple top-level headings in the same document
  "MD025": {
    // Heading level
    "level": 1,
    // RegExp for matching title in front matter
    "front_matter_title": "^\\s*title\\s*[:=]"
  },
  // MD046/code-block-style - Code block style
  "MD046": {
    // Block style
    "style": "fenced"
  }
}
```

L'inclusione del file dovrebbe eliminare le flag relative agli aspetti del controllo del codice che vogliamo o dobbiamo includere per scrivere la documentazione su Rocky Linux. Queste eccezioni violerebbero altrimenti le regole predefinite.

In sintesi, anche se non indispensabile, il plugin _null-ls_ dà un contributo significativo al nostro lavoro di documentazione. Se installato, aiuta a scrivere codice corretto e coerente.
