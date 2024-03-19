---
title: Gestore Progetto
author: Franco Colussi
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 8.7, 9.1
tags:
  - nvchad
  - plugins
  - editor
---

# Project Manager

## Introduzione

!!! danger "Istruzioni errate"

    Con il rilascio della versione 2.5, le istruzioni contenute in questa pagina non sono più corrette; se ne sconsiglia l'uso per le nuove installazioni. Per maggiori informazioni si veda [la pagina principale della guida](../index.md).

Una delle caratteristiche che un IDE deve sicuramente avere è la capacità di gestire i vari progetti su cui lavora uno sviluppatore o un editore. La possibilità di selezionare il progetto su cui lavorare una volta aperto NvChad, senza dover digitare comandi nella *statusline* per raggiungere l'obiettivo. Ciò consente di risparmiare tempo e di semplificare la gestione nel caso di un numero elevato di progetti.

L'uso di [charludo/projectmgr.nvim](https://github.com/charludo/projectmgr.nvim) integrerà questa funzionalità. Il plugin offre un'eccellente integrazione con `Telescope` e alcune interessanti funzionalità aggiuntive, come la possibilità di sincronizzare un repository *git* all'apertura del *progetto*.

Il plugin tiene anche traccia dello stato dell'editor alla sua chiusura, consentendo di avere, alla successiva apertura, tutte le pagine su cui si stava lavorando.

### Installazione del plugin

Per installare il plugin è necessario modificare il file **custom/plugins.lua** aggiungendo il seguente blocco di codice:

```lua
{
    "charludo/projectmgr.nvim",
    lazy = false, -- important!
},
```

Una volta salvato il file, il plugin sarà disponibile per l'installazione. Per installarlo, aprire *lazy.nvim* con il comando `:Lazy` e digitare ++"I"++. Una volta terminata l'installazione, si dovrà uscire dall'editor e riaprirlo per fargli leggere la nuova configurazione inserita.

Il plugin fornisce un unico comando `:ProjectMgr` che apre un buffer interattivo dal quale è possibile eseguire tutte le operazioni utilizzando le scorciatoie da tastiera. Alla prima apertura, il buffer sarà vuoto, come mostra questa schermata:

![ProjectMgr Init](./images/projectmgr_init.png)

### Utilizzo del Project Manager

Tutte le operazioni vengono eseguite con il tasto ++ctrl++ seguito da una lettera (ad esempio `<C-a`), mentre il tasto `<CR>` corrisponde al tasto ++ctrl++.

La tabella seguente mostra tutte le operazioni disponibili

| Opzione       | Operazione                                                |
| ------------- | --------------------------------------------------------- |
| `<CR>`  | Apre il progetto sotto il cursore                         |
| `<C-a>` | Aggiunge un progetto attraverso una procedura interattiva |
| `<C-d>` | Eliminare un progetto                                     |
| `<C-e>` | Modifica delle impostazioni del progetto                  |
| `<C-q>` | Chiudere il buffer                                        |

Per aggiungere il primo progetto è necessario usare la combinazione ++ctrl++ + ++"a"++, che aprirà un menu interattivo nella *statusline*. In questo esempio verrà utilizzato un clone della documentazione di Rocky Linux salvata in **~/lab/rockydocs/documentation**.

La prima domanda chiederà il nome del progetto:

> Project Name: documentation

Seguirà il percorso del progetto:

> Project Path: ~/lab/rockydocs/documentation/

Segue la possibilità di impostare i comandi da eseguire all'apertura e alla chiusura del progetto. Questi comandi si riferiscono a quelli eseguibili nell'editor e non al linguaggio **bash**.

È possibile, ad esempio, aprire contestualmente all'apertura dell'editor un buffer laterale con *NvimTree* con il comando `NvimTreeToggle`.

> Startup Command (optional): NvimTreeToggle

Oppure per eseguire un comando prima di chiudere l'editor.

> Exit Command (optional):

I comandi devono essere inseriti omettendo i due punti `:` utilizzati per eseguire gli stessi comandi nella *statusline.*

Una volta terminata la configurazione, il progetto sarà disponibile nel buffer. Per aprirla, selezionarlo e premere ++enter++.

![ProjectMgr Add](./images/projectmgr_add.png)

Come si può vedere dalla schermata nella sezione **Config & Info**, il plugin ha riconosciuto la cartella come gestita da *Git* e ci fornisce alcune informazioni su di essa.

La modifica di un progetto si effettua con ++ctrl++ + ++"e"++ e consiste in un nuovo ciclo interattivo, mentre l'eventuale cancellazione si effettua con la combinazione ++ctrl++ + ++"d"++.

### Funzioni aggiuntive

Il plugin fornisce alcune funzioni aggiuntive specificate nella [sezione dedicata](https://github.com/charludo/projectmgr.nvim#%EF%B8%8F-configuration). Le più interessanti sono la possibilità di sincronizzare un repository git all'apertura del progetto e la possibilità di memorizzare lo stato dell'editor alla sua chiusura. Entrambe le caratteristiche sono già presenti nel file di configurazione predefinito, anche se la funzionalità relativa a *Git* è disattivata.

Per aggiungere la sincronizzazione del repository all'apertura dei progetti, è necessario aggiungere il seguente codice alla configurazione iniziale del plugin:

```lua
config = function()
    require("projectmgr").setup({
        autogit = {
            enabled = true,
            command = "git pull --ff-only >> .git/fastforward.log 2>&1",
        },
    })
end,
```

Come si può vedere dal codice, viene richiamata la funzione `require("projectmgr").setup`, che consente di sovrascrivere le impostazioni predefinite. Qualsiasi cosa venga impostata al suo interno cambierà il suo funzionamento.

Il comando `git pull --ff-only` esegue una sincronizzazione *fast forward* del repository, scaricando solo i file che non hanno conflitti e che possono essere aggiornati senza alcun intervento da parte vostra.

Il risultato del comando viene anche indirizzato al file **.git/fastforward.log** per evitare che venga visualizzato sul terminale in cui è in esecuzione NvChad e per avere a disposizione una cronologia della sincronizzazione.

È prevista anche l'opzione di salvare la sessione alla sua chiusura. In questo modo è possibile tornare alle pagine su cui si stava lavorando selezionando il progetto e riaprendolo.

```lua
session = { enabled = true, file = "Session.vim" },
```

Questa opzione è abilitata per impostazione predefinita, ma scrive il file **Session.vim** nella directory *root* del progetto e questo non è auspicabile nel caso della documentazione di Rocky Linux. In questo esempio, viene salvato nella cartella `.git`, che non è sotto controllo di versione.

Regolare il percorso di **Session.vim** e **fastforward.log** in base alle proprie esigenze.

Una volta completate le modifiche, la configurazione dovrebbe apparire come segue:

```lua
{
    "charludo/projectmgr.nvim",
    lazy = false, -- important!
    config = function()
        require("projectmgr").setup({
            autogit = {
                enabled = true,
                command = "git pull --ff-only > .git/fastforward.log 2>&1",
            },
            session = { enabled = true, file = ".git/Session.vim" },
        })
    end,
},
```

Ora, ogni volta che si aprono i progetti, i file aggiornati vengono scaricati automaticamente dal repository Git e i file più recenti su cui si stava lavorando sono aperti nell'editor, pronti per essere modificati.

!!! Warning "Attenzione"

    I file aperti nei buffer di sessione salvati di NvChad non vengono aggiornati automaticamente.

Per verificare se i file aperti non corrispondono a quelli aggiornati dal repository si può usare il comando `:checktime`, che controlla se i file aperti nell'editor sono stati modificati al di fuori di NvChad e avvisa della necessità di aggiornare i buffer.

### Mappatura

Per velocizzare l'apertura dei progetti, è possibile creare una scorciatoia da tastiera per inserire la mappatura in **/custom/mapping.lua**. Un esempio potrebbe essere:

```lua
-- Projects
M.projects = {
    n = {
        ["<leader>fp"] = { "<cmd> ProjectMgr<CR>", "Open Projects" },
    },
}
```

Con l'editor in stato **NORMALE** è possibile aprire il project manager con la combinazione ++space++ + ++"f"++ seguita da ++"p"++.

## Conclusioni e considerazioni finali

Quando il numero di progetti a cui si lavora aumenta, potrebbe essere utile avere uno strumento che vi aiuti a gestirli tutti. Questo plugin vi permetterà di velocizzare il vostro lavoro riducendo il tempo necessario per accedere ai file da modificare.

Da segnalare anche l'ottima integrazione con `Telescope`, che rende la gestione dei progetti molto funzionale.
