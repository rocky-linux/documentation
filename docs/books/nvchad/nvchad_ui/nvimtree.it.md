---
title: NvimTree
author: Franco Colussi
contributors: Steven Spencer, Ganna Zhyrnova
tags:
  - nvchad
  - coding
  - editor
---

# NvimTree - File Explorer

![NvimTree](../images/nvimtree_basic.png){ align=right }

Un editor, per essere funzionale, deve fornire il supporto per l'apertura e la gestione dei file che vogliamo scrivere o modificare. Neovim, nella sua installazione di base, non fornisce la funzionalità di gestione dei file. È implementato da NvChad con il plugin _kyazdani42/nvim-tree.lua_. Il plugin fornisce un esploratore di file dal quale è possibile eseguire tutte le operazioni più comuni sui file attraverso i tasti della tastiera. Per aprirla si usa la combinazione ++ctrl++ + ++"n"++, disponibile solo in modalità _NORMAL_, e con la stessa combinazione di tasti la si chiude.

Se abbiamo installato i [Nerd Fonts](../nerd_fonts.md) avremo, come evidenziato dalla schermata, un file explorer che, sebbene testuale, ci darà una rappresentazione grafica della nostra struttura dei file.

Una volta aperta, possiamo passare dalla finestra di explorer a quella dell'editor e viceversa con le combinazioni ++ctrl++ + ++"h"++ per spostarci a sinistra e ++ctrl++ + ++"l"++ per spostarci a destra.

## Lavorare con l'Esplora File

Per lavorare con l'albero dei file del progetto, _NvimTree_ fornisce una serie di utili scorciatoie per la sua gestione, che sono:

- ++"R"++ (refresh) per eseguire una rilettura dei file contenuti nel progetto
- ++"H"++ (hide) per nascondere/visualizzare i file e le cartelle nascoste (che iniziano con un punto `.`)
- ++"E"++ (expand_all) per espandere l'intera struttura dei file partendo dalla cartella principale (area di lavoro)
- ++"W"++ (collapse_all) per chiudere tutte le cartelle aperte, a partire da quella principale
- ++"-"++ (dir_up) consente di risalire le cartelle. Questa navigazione consente anche di uscire dalla cartella principale (area di lavoro) per raggiungere la propria home directory
- ++"s"++ (system) per aprire il file con l'applicazione di sistema impostata di default per quel tipo di file
- ++"f"++ (find) per aprire la ricerca interattiva dei file a cui si possono applicare i filtri di ricerca
- ++"F"++ per chiudere la ricerca interattiva
- ++ctrl++ + ++"k"++ per visualizzare le informazioni sul file, come la dimensione, la data di creazione, ecc.
- ++"g"++ + ++"?"++ per aprire la guida con tutte le scorciatoie predefinite per una rapida consultazione
- ++"q"++ per chiudere l'esploratore di file

![Nvimtree Find](../images/nvimtree_find_filter.png){ align=right }

!!! note "Note:"

    La ricerca interattiva eseguita con ++"f"++, così come la navigazione con le frecce ++"&gt;"++ ++"&lt;"++, rimane limitata alla cartella in cui si trova attualmente _NvimTree_. Per eseguire una ricerca globale sull'intera area di lavoro, è necessario aprire l'intera struttura dei file con ++"E"++ e poi avviare la ricerca con ++"f"++.

La ricerca porta il buffer **NvimTree_1** allo stato _INSERT_ per la digitazione dei filtri. Se non è stato selezionato alcun file, per uscire dalla ricerca è necessario riportare il buffer a _NORMAL_ con ++esc++ prima di chiudere la ricerca con ++"F"++.

### Selezionare un File

Per selezionare un file dobbiamo prima assicurarci di trovarci nel buffer _nvimtree_ evidenziato nella statusline con **NvimTree_1**. Per farlo, si possono usare i tasti di selezione della finestra menzionati in precedenza o il comando specifico ++"F"++ fornito da NvChad, che posizionerà il cursore nell'albero dei file. La combinazione fa parte della mappatura predefinita di NvChad e corrisponde al comando `:NvimTreeFocus` del plugin.

Per spostarsi all'interno dell'albero dei file sono disponibili i tasti ++"&gt;"++ e ++"&lt;"++ che consentono di spostarsi su e giù per l'albero fino a raggiungere la cartella desiderata. Una volta posizionato, possiamo aprirlo con ++enter++ e chiuderlo con ++"BS"++.

Va sottolineato che la navigazione con i tasti ++"&gt;"++ and ++"&lt;"++ si riferisce sempre alla cartella corrente. Ciò significa che una volta aperta e posizionati in una cartella, la navigazione rimarrà limitata a quella cartella. Per uscire dalla cartella si usa il tasto ++ctrl++ + ++"p"++ (parent directory) che ci permette di risalire dalla cartella corrente alla cartella da cui abbiamo aperto l'editor e che corrisponde al nostro _workspace_ definito nella statusline a destra.

### Apertura di un file

Posizionati nella cartella desiderata e con il file selezionato da modificare, abbiamo le seguenti combinazioni per aprirlo:

- ++enter++ o ++"o"++ per aprire il file in un nuovo buffer e posizionare il cursore sulla prima riga del file
- ++tab++ per aprire il file in un nuovo buffer mantenendo il cursore in _nvimtree_; questo è utile, ad esempio, se si vogliono aprire più file contemporaneamente
- ++ctrl++ + ++"t"++ per aprire il file in una nuova _scheda_ che può essere gestita separatamente dagli altri buffer presenti
- ++ctrl++ + ++"v"++ per aprire il file nel buffer dividendolo verticalmente in due parti; se c'era già un file aperto, questo verrà visualizzato fianco a fianco con il nuovo file
- ++ctrl++ + ++"h"++ per aprire il file come il comando descritto sopra, ma dividendo il buffer orizzontalmente

### Gestione File

Come tutti gli esploratori di file, in _nvimtree_ è possibile creare, eliminare e rinominare i file. Poiché si tratta sempre di un approccio testuale, non si avrà a disposizione un comodo widget grafico, ma le indicazioni saranno visualizzate nella _statusline_. Tutte le combinazioni hanno una richiesta di conferma _(y/n)_ per dare modo di verificare l'operazione ed evitare così modifiche inappropriate. Questo è particolarmente importante per l'eliminazione di un file, poiché la cancellazione sarebbe irreversibile.

I tasti per la modifica sono:

- ++"a"++ (add) consente di creare file o cartelle; la creazione di una cartella si effettua facendo seguire al nome la barra `/`. ad es. `/nvchad/nvimtree.md` creerà il relativo file markdown, mentre `/nvchad/nvimtree/` creerà la cartella _nvimtree_. La creazione avverrà di default nella posizione in cui si trova il cursore nel file explorer in quel momento, quindi la selezione della cartella in cui creare il file dovrà essere fatta in precedenza o, in alternativa, si può scrivere il percorso completo nella statusline; nello scrivere il percorso si può utilizzare la funzione di autocompletamento
- ++"r"++ (rinominare) per rinominare il file selezionato rispetto al nome originale
- ++ctrl++ + ++"r"++ per rinominare il file indipendentemente dal suo nome originale
- ++"d"++ (delete) per cancellare il file selezionato o, nel caso di una cartella, per cancellare la cartella con tutto il suo contenuto
- ++"x"++ (cut) per tagliare e copiare la selezione negli appunti, possono essere file o cartelle con tutto il loro contenuto; con questo comando associato al comando incolla si effettuano gli spostamenti dei file all'interno dell'albero
- ++"c"++ (copy) come il comando precedente, copia il file negli appunti ma mantiene il file originale nella sua posizione
- ++"p"++ (paste) per incollare il contenuto degli appunti nella posizione corrente
- ++"p"++ per copiare solo il nome del file negli appunti, esistono anche due varianti: ++"Y"++ per copiare il percorso relativo e ++"g"++ + ++"y"++ per copiare il percorso assoluto

## Funzionalità avanzate

Sebbene sia disattivato per impostazione predefinita, _nvimtree_ integra alcune funzionalità per controllare un eventuale repository _Git_. Tale funzionalità è abilitata utilizzando la sovrascrittura delle impostazioni di base, come descritto nella sezione override della pagina [Template Chadrc](../template_chadrc.md).

Il codice relativo è il seguente:

```lua
M.nvimtree = {
    git = {
        enable = true,
    },
    renderer = {
        highlight_git = true,
        icons = {
        show = {
            git = true,
            },
        },
    },
    view = {
        side = "right",
    },
}
```

Una volta attivata la funzionalità _Git_, il nostro albero dei file ci darà lo stato in tempo reale dei nostri file locali rispetto al repository Git.

## Conclusione

Il plugin _kyazdani42/nvim-tree.lua_ fornisce il File Explorer all'editor Neovim, che è certamente uno degli elementi essenziali dell'IDE NvChad, da cui si possono eseguire tutte le operazioni più comuni sui file. Integra anche funzioni avanzate, che però devono essere abilitate. Ulteriori informazioni sono disponibili nella [pagina del progetto](https://github.com/kyazdani42/nvim-tree.lua).
