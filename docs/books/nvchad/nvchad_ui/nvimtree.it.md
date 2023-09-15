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

Un editor, per essere funzionale, deve fornire il supporto per l'apertura e la gestione dei file che vogliamo scrivere o modificare. Neovim, nella sua installazione di base, non fornisce la funzionalità di gestione dei file. È implementato da NvChad con il plugin _kyazdani42/nvim-tree.lua_. Il plugin fornisce un esploratore di file dal quale è possibile eseguire tutte le operazioni più comuni sui file attraverso i tasti della tastiera. Per aprirla si usa la combinazione <kbd>Ctrl</kbd> + <kbd>n</kbd>, disponibile solo in modalità _NORMAL_, e con la stessa combinazione di tasti la si chiude.

Se abbiamo installato i [Nerd Fonts](../nerd_fonts.md) avremo, come evidenziato dalla schermata, un file explorer che, sebbene testuale, ci darà una rappresentazione grafica della nostra struttura dei file.

Una volta aperta, possiamo passare dalla finestra di explorer a quella dell'editor e viceversa con le combinazioni <kbd>Ctrl</kbd> + <kbd>h</kbd> per spostarci a sinistra e <kbd>Ctrl</kbd> + <kbd>l</kbd> per spostarci a destra.

## Lavorare con l'Esplora File

Per lavorare con l'albero dei file del progetto, _NvimTree_ fornisce una serie di utili scorciatoie per la sua gestione, che sono:

- <kbd>R</kbd> (refresh) per eseguire una rilettura dei file contenuti nel progetto
- <kbd>H</kbd> (hide) per nascondere/visualizzare i file e le cartelle nascoste (che iniziano con un punto `.`)
- <kbd>E</kbd> (expand_all) per espandere l'intera struttura dei file partendo dalla cartella principale (area di lavoro)
- <kbd>W</kbd> (collapse_all) per chiudere tutte le cartelle aperte, a partire da quella principale
- <kbd>-</kbd> (dir_up) consente di risalire le cartelle. Questa navigazione consente anche di uscire dalla cartella principale (area di lavoro) per raggiungere la propria home directory
- <kbd>s</kbd> (system) per aprire il file con l'applicazione di sistema impostata di default per quel tipo di file
- <kbd>f</kbd> (find) per aprire la ricerca interattiva dei file a cui si possono applicare i filtri di ricerca
- <kbd>F</kbd> per chiudere la ricerca interattiva
- <kbd>Ctrl</kbd> + <kbd>k</kbd> per visualizzare le informazioni sul file, come la dimensione, la data di creazione, ecc.
- <kbd>g</kbd> + <kbd>?</kbd> per aprire la guida con tutte le scorciatoie predefinite per una rapida consultazione
- <kbd>q</kbd> per chiudere l'esploratore di file

![Nvimtree Find](../images/nvimtree_find_filter.png){ align=right }

!!! note "Note:" 

    La ricerca interattiva eseguita con <kbd>f</kbd>, così come la navigazione con le frecce <kbd>></kbd> <kbd><</kbd>, rimane limitata alla cartella in cui si trova attualmente _NvimTree_. Per eseguire una ricerca globale sull'intera area di lavoro, è necessario aprire l'intera struttura dei file con <kbd>E</kbd> e poi avviare la ricerca con <kbd>f</kbd>.

La ricerca porta il buffer **NvimTree_1** allo stato _INSERT_ per la digitazione dei filtri. Se non è stato selezionato alcun file, per uscire dalla ricerca è necessario riportare il buffer a _NORMAL_ con <kbd>ESC</kbd> prima di chiudere la ricerca con <kbd>F</kbd>.

### Selezionare un File

Per selezionare un file dobbiamo prima assicurarci di trovarci nel buffer _nvimtree_ evidenziato nella statusline con **NvimTree_1**. Per farlo, si possono usare i tasti di selezione della finestra menzionati in precedenza o il comando specifico <kbd>Spazio</kbd> + <kbd>e</kbd> fornito da NvChad, che posizionerà il cursore nell'albero dei file. La combinazione fa parte della mappatura predefinita di NvChad e corrisponde al comando `:NvimTreeFocus` del plugin.

Per spostarsi all'interno dell'albero dei file sono disponibili i tasti <kbd>&gt;</kbd> e <kbd>&lt;</kbd> che consentono di spostarsi su e giù per l'albero fino a raggiungere la cartella desiderata. Una volta posizionato, possiamo aprirlo con <kbd>Invio</kbd> e chiuderlo con <kbd>BS</kbd>.

Va sottolineato che la navigazione con i tasti <kbd>&gt;</kbd> e <kbd>&lt;</kbd> si riferisce sempre alla cartella corrente. Ciò significa che una volta aperta e posizionati in una cartella, la navigazione rimarrà limitata a quella cartella. Per uscire dalla cartella si usa il tasto <kbd>Ctrl</kbd> + <kbd>p</kbd> (parent directory) che ci permette di risalire dalla cartella corrente alla cartella da cui abbiamo aperto l'editor e che corrisponde al nostro _workspace_ definito nella statusline a destra.

### Apertura di un file

Posizionati nella cartella desiderata e con il file selezionato da modificare, abbiamo le seguenti combinazioni per aprirlo:

- <kbd>Invio</kbd> o <kbd>o</kbd> per aprire il file in un nuovo buffer e posizionare il cursore sulla prima riga del file
- <kbd>Tab</kbd> per aprire il file in un nuovo buffer mantenendo il cursore in _nvimtree_; questo è utile, ad esempio, se si vogliono aprire più file contemporaneamente
- <kbd>Ctrl</kbd> + <kbd>t</kbd> per aprire il file in una nuova _scheda_ che può essere gestita separatamente dagli altri buffer presenti
- <kbd>Ctrl</kbd> + <kbd>v</kbd> per aprire il file nel buffer dividendolo verticalmente in due parti; se c'era già un file aperto, questo verrà visualizzato fianco a fianco con il nuovo file
- <kbd>Ctrl</kbd> + <kbd>h</kbd> per aprire il file come il comando descritto sopra, ma dividendo il buffer orizzontalmente

### Gestione File

Come tutti gli esploratori di file, in _nvimtree_ è possibile creare, eliminare e rinominare i file. Poiché si tratta sempre di un approccio testuale, non si avrà a disposizione un comodo widget grafico, ma le indicazioni saranno visualizzate nella _statusline_. Tutte le combinazioni hanno una richiesta di conferma _(y/n)_ per dare modo di verificare l'operazione ed evitare così modifiche inappropriate. Questo è particolarmente importante per l'eliminazione di un file, poiché la cancellazione sarebbe irreversibile.

I tasti per la modifica sono:

- <kbd>a</kbd> (add) consente di creare file o cartelle; la creazione di una cartella si effettua facendo seguire al nome la barra `/`. ad es. `/nvchad/nvimtree.md` creerà il relativo file markdown, mentre `/nvchad/nvimtree/` creerà la cartella _nvimtree_. La creazione avverrà di default nella posizione in cui si trova il cursore nel file explorer in quel momento, quindi la selezione della cartella in cui creare il file dovrà essere fatta in precedenza o, in alternativa, si può scrivere il percorso completo nella statusline; nello scrivere il percorso si può utilizzare la funzione di autocompletamento
- <kbd>r</kbd> (rinominare) per rinominare il file selezionato rispetto al nome originale
- <kbd>Ctrl</kbd> + <kbd>r</kbd> per rinominare il file indipendentemente dal suo nome originale
- <kbd>d</kbd> (delete) per cancellare il file selezionato o, nel caso di una cartella, per cancellare la cartella con tutto il suo contenuto
- <kbd>x</kbd> (cut) per tagliare e copiare la selezione negli appunti, possono essere file o cartelle con tutto il loro contenuto; con questo comando associato al comando incolla si effettuano gli spostamenti dei file all'interno dell'albero
- <kbd>c</kbd> (copy) come il comando precedente, copia il file negli appunti ma mantiene il file originale nella sua posizione
- <kbd>p</kbd> (paste) per incollare il contenuto degli appunti nella posizione corrente
- <kbd>y</kbd> per copiare solo il nome del file negli appunti, esistono anche due varianti: <kbd>Y</kbd> per copiare il percorso relativo e <kbd>g</kbd> + <kbd>y</kbd> per copiare il percorso assoluto

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
