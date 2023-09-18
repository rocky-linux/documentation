---
title: Anteprima Markdown
author: Franco Colussi
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 8.7, 9.2
tags:
  - nvchad
  - plugins
  - editor
---

# Anteprima Markdown

## Introduzione

Una delle caratteristiche del linguaggio Markdown che lo rendono ampiamente utilizzato nella scrittura di documentazione tecnica è la sua convertibilità. Il codice può essere convertito per la visualizzazione in molti formati (HTML, PDF, testo normale, ecc.), rendendo così il contenuto utilizzabile in numerosi scenari.

In particolare, la documentazione scritta per Rocky Linux viene convertita in `HTML` utilizzando un'applicazione *python*. L'applicazione converte i documenti scritti in *markdown* in pagine HTML statiche.

Quando si scrive la documentazione per Rocky Linux, si pone il problema di verificarne la corretta visualizzazione quando viene convertita in codice `HTML`.

Per integrare questa funzionalità nel proprio editor, in questa pagina verranno illustrati due dei plugin disponibili a questo scopo, [toppair/peek.nvim](https://github.com/toppair/peek.nvim) e [markdown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim). Entrambi supportano lo *stile github*, la scelta del browser da usare per l'anteprima e lo scorrimento sincronizzato con l'editor.

### Peek.nvim

[Peek](https://github.com/toppair/peek.nvim) utilizza [Deno](https://deno.com/manual), un runtime JavaScript, TypeScript e WebAssembly con impostazioni sicure predefinite per il suo funzionamento. Per impostazione predefinita, Deno non consente l'accesso a file, rete o ambiente, a meno che non sia esplicitamente abilitato.

Se è stato installato anche il [Template Chadrc](../template_chadrc.md), questo componente sarà già disponibile perché è uno dei server linguistici installati di default. Nel caso in cui non sia ancora presente nell'editor, è possibile installarlo con il comando `:MasonInstall deno`.

!!! Warning "Attenzione"

    Il server linguistico **deve** essere installato prima di procedere all'installazione del plugin. In caso contrario, l'installazione fallirà e sarà necessario rimuovere il codice da **/custom/plugins.lua**, eseguire una pulizia della configurazione aprendo `Lazy` e digitando <kbd>X</kbd> per eliminare il plugin e quindi ripetere la procedura di installazione.

Per installare il plugin è necessario modificare il file **/custom/plugins.lua** aggiungendo il seguente blocco di codice:

```lua
{
    "toppair/peek.nvim",
    build = "deno task --quiet build:fast",
    keys = {
        {
        "<leader>op",
            function()
            local peek = require("peek")
                if peek.is_open() then
            peek.close()
            else
            peek.open()
            end
        end,
        desc = "Peek (Markdown Preview)",
        },
},
    opts = { theme = "dark", app = "browser" },
},
```

Una volta salvato il file, è possibile eseguirne l'installazione aprendo l'interfaccia del gestore dei plugin con il comando `:Lazy`. Il gestore dei plugin lo avrà già riconosciuto automaticamente e vi permetterà di installarlo digitando <kbd>I</kbd>.

Per ottenere tutte le funzionalità, tuttavia, è necessario chiudere NvChad (*nvim*) e riaprirlo. Questo per consentire all'editor di caricare quelle di **Peek** nella configurazione.

La sua configurazione include già il comando per attivarlo `<leader>op`, che sulla tastiera si traduce in <kbd>Spazio</kbd> + <kbd>o</kbd> seguito da <kbd>p</kbd>.

![Peek](./images/peek_command.png)

Avete anche la stringa:

```lua
opts = { theme = "dark", app = "browser" },
```

Che consente di passare le opzioni per il tema chiaro o scuro dell'anteprima e il metodo da usare per la visualizzazione.

In questa configurazione, è stato scelto il metodo "browser", che apre il file da visualizzare nel browser predefinito del sistema, ma il plugin consente attraverso il metodo "webview" di visualizzare l'anteprima del file utilizzando solo **Deno** tramite il componente [webview_deno](https://github.com/webview/webview_deno).

![Peek Webview](./images/peek_webview.png)

### Markdown-preview.nvim

[Markdown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim) è un plugin scritto in `node.js` (JavaScript). La sua installazione su NvChad non richiede alcuna dipendenza, poiché gli sviluppatori forniscono una versione precompilata che funziona perfettamente nell'editor.

Per installare questa versione è necessario aggiungere questo blocco di codice al file **/custom/plugins.lua**:

```lua
{
    "iamcco/markdown-preview.nvim",
    cmd = {"MarkdownPreview", "MarkdownPreviewStop"},
    lazy = false,
    build = function() vim.fn["mkdp#util#install"]() end,
    init = function()
        vim.g.mkdp_theme = 'dark'
    end
},
```

Come per il plugin precedente, è necessario chiudere l'editor e riaprirlo per dare a NvChad la possibilità di caricare la nuova configurazione. Anche in questo caso è possibile passare al plugin alcune opzioni personalizzate descritte nella [sezione dedicata](https://github.com/iamcco/markdown-preview.nvim#markdownpreview-config) del repository del progetto.

Tuttavia, le opzioni devono essere modificate per adattarsi alla configurazione di `lazy.nvim`, in particolare l'opzione configurata in questo esempio:

```lua
vim.g.mkdp_theme = 'dark'
```

Corrisponde all'opzione descritta sul sito del progetto come:

```lua
let g:mkdp_theme = 'dark'
```

Come si può notare, per impostare le opzioni è necessario modificare la parte iniziale delle stesse per renderle interpretabili. Per fare un altro esempio, prendiamo l'opzione che consente di scegliere quale browser utilizzare per l'anteprima, specificata in questo modo:

```lua
let g:mkdp_browser = '/usr/bin/chromium-browser'
```

Per interpretarlo correttamente in NvChad, è necessario modificare il testo sostituendo `let g:` con `vim.g.`.


```lua
vim.g.mkdp_browser = '/usr/bin/chromium-browser'
```

In questo modo, alla prossima apertura di NvChad, verrà utilizzato `chromium-browser`, indipendentemente dal browser predefinito del sistema.

La configurazione fornisce anche i comandi `:MarkdownPreview` e `:MarkdownPreviewStop` per aprire e chiudere l'anteprima, rispettivamente. Per un accesso più rapido ai comandi, è possibile mapparli nel file **/custom/mapping.lua** come segue:

```lua
-- binding for Markdown Preview
M.mdpreview = {
  n = {
    ["<leader>mp"] = { "<cmd> MarkdownPreview<CR>", "Open Preview"},
    ["<leader>mc"] = { "<cmd> MarkdownPreviewStop<CR>", "Close Preview"},
    },
}
```

In questo modo è possibile aprire l'anteprima del markdown digitando <kbd>Invio</kbd> + <kbd>m</kbd> seguito da <kbd>p</kbd> e chiuderla con la combinazione <kbd>Invio</kbd> + <kbd>m</kbd> seguito da <kbd>c</kbd>.

!!! Note "Nota"

    Il plugin fornisce anche il comando `:MarkdownPreviewToggle`, ma al momento della stesura di questo documento non sembra funzionare correttamente. Se si prova a richiamarlo, non cambierà il tema dell'anteprima ma si aprirà una nuova scheda del browser con la stessa anteprima.

![Markdown Preview](./images/markdown_preview_nvim.png)

## Conclusioni e considerazioni finali

Un'anteprima di ciò che si sta scrivendo può essere utile sia per chi è alle prime armi con questo editor sia per chi ha una conoscenza più approfondita del linguaggio Markdown. L'anteprima consente di valutare l'impatto del codice una volta convertito e gli eventuali errori contenuti.

La scelta di quale plugin utilizzare è del tutto soggettiva e vi invitiamo a provarli entrambi per valutare quale sia il migliore per voi.

L'uso di uno di questi plugin consente di contribuire alla documentazione di Rocky Linux con documenti conformi al codice utilizzato, alleggerendo così il lavoro dei revisori della documentazione.
