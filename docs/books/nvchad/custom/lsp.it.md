---
title: Language Server Protocol
author: Franco Colussi
contributors: Steven Spencer, Franco Colussi
tested with: 8.6, 9.0
tags:
  - NvChad
  - coding
  - LSP
---

## LSP

Che cos'è il Protocollo del Server Linguistico?

È un servizio server che fornisce il supporto per funzioni di editing avanzate, come il completamento automatico del codice sorgente o il *"Go to Definition"*, per un linguaggio di programmazione in un editor o IDE.

Il Language Server Protocol (LSP) è il prodotto della standardizzazione dei messaggi scambiati tra uno strumento di sviluppo e un processo di server linguistico. L'obiettivo di LSP è semplificare questo tipo di integrazione e fornire un quadro utile per esporre le caratteristiche del linguaggio a una varietà di strumenti.

### LSP in NvChad

NvChad fornisce un meccanismo automatico per l'installazione dei server linguistici attraverso il plugin `williamboman/mason.nvim`, un piccolo gioiello dell'ecosistema dei plugin di Neovim che fornisce un'interfaccia grafica per l'installazione di server linguistici e altro.

![Mason UI](../images/mason_ui.png)

Per conoscere tutti i comandi disponibili, è sufficiente premere il tasto <kbd>g?</kbd> per avere a disposizione la legenda completa.

![Guida Mason](../images/mason_help.png)

### Introduzione a *nvim-lspconfig*

*nvim-lspconfig* è una raccolta di configurazioni, fornite dalla comunità, per i client e il server linguistico integrato nel nucleo di Nvim. Questo plugin offre quattro funzioni principali:

- comandi di avvio predefiniti, opzioni di inizializzazione e impostazioni per ogni server.
- un risolutore di directory radice che tenta di individuare la radice del progetto
- una mappatura automatica dei comandi che lancia un nuovo server linguistico o un server linguistico per ogni buffer aperto, se fa parte di un progetto tracciato.
- comandi di utilità come LspInfo, LspStart, LspStop e LspRestart, per la gestione delle istanze del server linguistico.

L'uso combinato dei due plugin consente di scaricare i server linguistici necessari e di configurarli automaticamente da NvChad.

#### Scaricare i Server Linguistici

Per scaricare il server linguistico scelto, apriamo l'interfaccia di *Mason* dal nostro editor con il comando <kbd>SHIFT</kbd> + <kbd>:Mason</kbd>. Supponiamo di voler installare il server linguistico per il *Markdown*. Per farlo, digitiamo <kbd>2</kbd> per accedere alla sezione `LSP`.

Ora scendiamo con il tasto freccia fino a trovare il server linguistico `marksman`. Premendo la barra spaziatrice si possono ottenere alcune informazioni sul server, come si può vedere nella schermata seguente.

![Mason Marksman](../images/mason_marksman.png)

Per installare il server, è sufficiente premere il tasto <kbd>i</kbd>; al termine dell'installazione Mason lo troverà tra i server installati.

![Marksman Installato](../images/mason_installed.png)

I server da installare con questa procedura sono:

- **marksman**: per il supporto markdown
- **yaml-language-server**: per il supporto al frontmatter
- **lua-language-server**: per il supporto lua
- **html-lsp**: per il supporto HTML

### Configurare `lspdconfig.lua`

I server installati non sono ancora configurati in NvChad. Per eseguire la registrazione del server è necessario eseguire una configurazione aggiuntiva.

Per prima cosa creiamo la cartella `custom/plugins` in `~/.local/nvim/lua`. Nota che se hai già seguito il resto di questa guida, questo percorso potrebbe essere già stato creato:

```bash
mkdir -p ~/.local/nvim/lua/custom/plugins
```

Abbiamo usato la flag `-p` poiché vogliamo creare l'intero percorso se non esiste già. Una volta creata la cartella, dobbiamo creare due file: `init.lua`, che si occuperà di istruire *Packer* per l'installazione del plugin, e `lspconfig.lua`, che definirà i nostri server.

Cominciamo a creare i due file:

```bash
touch ~/.config/nvim/lua/custom/plugins/init.lua
touch ~/.config/nvim/lua/custom/plugins/lspconfig.lua
```

A questo punto la struttura delle cartelle dovrebbe essere la seguente:

```text
└── plugins
    ├── init.lua
    └── lspconfig.lua
```

Passiamo ora a modificare i due file per includere il supporto per i *Language Server*.

#### init.lua

Inserendo il seguente codice si indica a Packer di installare il plugin `neovim/nvim-lspconfig` utilizzando il codice contenuto rispettivamente in *nvim/lua/plugins/lspconfig.lua* e *nvim/lua/custom/plugins/lspconfig.lua*. Per la configurazione, invece, abbiamo bisogno di chiamate di tipo `require`.

È necessario prestare particolare attenzione alla sequenza delle chiamate, poiché queste utilizzano la tecnica dell'override e l'inversione dell'ordine potrebbe causare incongruenze nella configurazione.

```lua
return {
  ["neovim/nvim-lspconfig"] = {
    config = function()
      require "plugins.configs.lspconfig"
      require "custom.plugins.lspconfig"
    end,
    },
}
```

Si passa quindi a modificare il file con NvChad:

```text
nvim ~/.config/nvim/lua/custom/plugins/init.lua
```

![NvChad init.lua](../images/init_custom_plugins.png)

Una volta terminate le modifiche, salviamo il file con il comando <kbd>SHIFT</kbd> + <kbd>:wq</kbd>.

Ora possiamo modificare il file di configurazione dei nostri server locali.

#### lspconfig.lua

Questo è il nostro file di configurazione `lspconfig.lua`, inserito dopo che la configurazione *lspconfig* di NvChad ha finito di configurare l'ambiente.

```lua
-- custom.plugins.lspconfig
local on_attach = require("plugins.configs.lspconfig").on_attach
local capabilities = require("plugins.configs.lspconfig").capabilities

local lspconfig = require "lspconfig"
local servers = { "html", "marksman", "yamlls"}

for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities,
  }
end
```

Apriamo nuovamente il nostro editor e modifichiamo il file:

```textile
nvim ~/.config/nvim/lua/custom/plugins/lspconfig.lua
```

![Custom lspconfig.lua](../images/lspconfig_custom.png)

Dopo aver terminato le modifiche, salviamo e chiudiamo l'editor come prima con <kbd>SHIFT</kbd> + <kbd>:wq.</kbd>

Come possiamo vedere, abbiamo aggiunto alla tabella dei `server locali` i server che abbiamo installato con *Mason*:

```lua
local servers = { "html", "marksman", "yamlls"}
```

Questo dà a *nvim-lspconfig* un modo per recuperare le configurazioni necessarie per il loro funzionamento nell'IDE.

Una volta terminate le modifiche, per renderle effettive è necessario dire a *Packer* di sincronizzarle. Questo si fa con un semplice <kbd>SHIFT</kbd> + <kbd>:PackerSync</kbd> al termine del quale la nuova installazione di *neovim/nvim-lspconfig* sarà evidenziata nel log. Ora, aprendo un file Markdown dovrebbe apparire un'icona a forma di ingranaggio nell'angolo in basso a destra, con la scritta `LSP - marksman`.

![Marksman Enable](../images/marksman_enable.png)

![Server Marksman](../images/marksman_server_info.png)

### Introduzione all'LSP usato

#### SumnekoLua

Un componente molto importante è il `lua-language-server`, che cambia completamente l'esperienza di scrittura del codice Lua e di conseguenza anche la modifica dei file di configurazione di NvChad scritti in questo linguaggio. Questo è anche il LSP predefinito per *lua*

L'eseguibile è fornito dal plugin [SumnekoLua](https://github.com/sumneko/lua-language-server).

![Lua Language Server](../images/lua-language-server.png)

Si noti che il server lua non deve essere configurato nel file di configurazione `lspconfig.lua`. Poiché è il server predefinito di NvChad, funziona senza bisogno di ulteriori configurazioni.

![Lua Diagnostic](../images/lua_diagnostic.png)

#### Marksman

Marksman è un server linguistico per Markdown che fornisce autocompletamento, definizioni go-to, ricerca di riferimenti, diagnostica, ecc. Tutti i tipi di link supportano il completamento, l'hover e la definizione di goto/reference. Inoltre, Marksman fornisce una diagnostica per i collegamenti wiki per individuare i riferimenti interrotti e i titoli duplicati/ambigui.

![Marksman Server](../images/marksman_assistant.png)

E se proviamo a creare degli errori (nel nostro esempio creeremo alcune righe vuote, che in markdown non sono un errore ma sono considerate una cattiva formattazione), otterremo un avviso visivo (i quadratini rosa a sinistra del numero della riga) che ci avviserà del problema.

![Marksman Diagnostic](../images/marksman_diagnostic.png)

#### yamlls

`yamlls` fornisce funzioni per convalidare l'intero file yaml, controllare gli errori e gli avvertimenti relativi al codice, autocompletare i comandi e, inoltre, passando il mouse su un nodo se ne visualizza la descrizione, se disponibile.

Il server delle lingue è fornito dal pacchetto [yaml-language-server](https://github.com/redhat-developer/yaml-language-server).

![Yaml Server](../images/yamlls_server.png)

Una volta installato, entrerà in azione ogni volta che apriremo un file `.yaml`, dando un contributo prezioso alla scrittura e al debug del codice.

### Considerazioni Finali

L'uso degli LSP facilita notevolmente il processo di editing, arricchendolo di funzionalità avanzate. Ci permette inoltre di tenere traccia della sua consistenza in tempo reale. È sicuramente uno strumento da avere nel nostro IDE.

L'introduzione di *Mason*, sebbene sia ancora necessario un certo intervento manuale per configurare l'ambiente, ha reso disponibile una procedura automatizzata per l'installazione dei server linguistici. Inoltre, ci permette di evitare i controlli periodici degli aggiornamenti che sarebbero stati necessari in caso di installazione manuale.

Una volta installati e configurati, tutti i nostri server potranno essere aggiornati dalla *GUI di Mason* con la semplice pressione del tasto <kbd>U</kbd>.
