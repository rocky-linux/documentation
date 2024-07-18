---
title: Editor Changes
author: Franco Colussi
contributors: Steven Spencer
tested_with: 9.4
tags:
  - neovim
  - nvchad
  - editor
  - markdown
---

Le funzionalità di base di NvChad sono state ampliate per fornire un'esperienza migliorata di quella ottima già fornita dall'editor, sono presenti funzioni per gestione dei file, la navigazione del buffer, la copia delle stringhe e altre piccole utilità.

## File Manager

La modifica più rilevante alla configurazione dell'editor è la sostituzione del file manager utilizzato da NvChad, al suo posto è stato utilizzato [neo-tree.nvim](https://github.com/nvim-neo-tree/neo-tree.nvim), questo plugin permette di avere una configurazione più semplice e fornisce "fuori dalla scatola" un layout flottante e vari parametri da passare al comando `:Neotree`.

![Neotree Standard](./images/neo-tree.png)

I comandi utilizzati in NvChad sono stati migrati per riflettere le modifiche ma le funzionalità rimangono le stesse, con ++ctrl+"n"++ si apre lateralmente il file manager e con ++space+"e"++ si posiziona il focus su di esso.

!!! note "Disabilitazione di nvimtree"

    Il plugin fornito dalla configurazione di base è stato completamente disabilitato per evitare problemi di incompatibilità con il suo sostituto, la disabilitazione è impostata nel file `lua/plugins/init.lua`.

    ```lua
    -- disable nvim-tree
    {
    "nvim-tree/nvim-tree.lua",
    enabled = false,
    },
    ```

Il plugin fornisce anche un layout flottante che viene richiamato con il carattere ++"-"++, il comando eseguito da questa scorciatoia corrisponde all'esecuzione di *Neotree* con la flag ==float==, al comando in particolare è stata aggiunta anche la flag ==toggle== per utilizzare lo stesso carattere anche per chiudere il buffer.

![Floating Neotree](./images/neo-tree_float.png)

La scorciatoia può essere modificata secondo preferenze modificando il carattere corrispondente nel file `lua/plugins/neotree.lua`.

```lua
  { -- lazy style key map
   "-",
   "<cmd>Neotree float toggle<cr>",
   desc = "file manager float",
  },
```

Il comando `:Neotree` dispone di numerose opzioni e layout predefiniti, per un suo approfondimento visitare [la sezione relativa](https://github.com/nvim-neo-tree/neo-tree.nvim?tab=readme-ov-file#the-neotree-command) della documentazione.

## Command line

Affiancata alla *cmdline* fornita da NvChad è stata inserita anche una seconda *command line* più moderna e funzionale, il suo inserimento è stato effettuato nel file `lua/plugins/telescope.lua`. Il plugin è un *picker* personalizzato di *Telescope*, fornisce una cronologia dei comandi effettuati e ne permette la ricerca, la funzionalità è fornita dal plugin [telescope-cmdline.nvim](https://github.com/jonarrien/telescope-cmdline.nvim).

![Cmdline](./images/cmdline_telescope.png)

## Copy and Paste

Le funzionalità del copia/incolla sono state ampliate mediante l'integrazione nella configurazione di [yanky.nvim](https://github.com/gbprod/yanky.nvim), questo plugin permette di incollare, da una comoda cronologia visualizzata in *Telescope*, le stringhe copiate in precedenza. La cronologia (*yanky-ring*) viene salvata in `~.local/share/nvim/databases/yanky.db`, si tratta di un database *sqlite* che consente di immagazzinare un numero superiore di stringhe e offre migliori prestazioni nella ricerca.  
Le chiavi per utilizzare *yanky* sono ++space+"y"++ in modalità *NORMAL* e ++ctrl+"y"++ nella modalità *INSERT*, entrambe posizionano la stringa da incollare nella posizione corrente in cui si trova il cursore.

![Yank Ring](./images/yank_ring.png)

## Ulteriori integrazioni

Ai plugin che forniscono le funzionalità descritte sopra sono stati aggiunti inoltre alcuni plugin che forniscono funzionalità comuni dedicate alla gestione del buffer.

* [nvim-highlight-colors](https://github.com/brenoprata10/nvim-highlight-colors) for color code translation (*hexadecimal*), this plugin adds a background color to the hexadecimal value (e.g. #FCFCFC) making it much easier to manage and edit. The feature is particularly useful for those who want to try their hand at editing NvChad themes. The ++space+"uC "++ shortcut is available for activation, which also allows its disabling (*toggle command*).

![Highlight Colors](./images/hl_colors.png)

* [neoscroll.nvim](https://github.com/karb94/neoscroll.nvim) enables smoother scrolling of the document (in *NORMAL* mode), its use allows you to quickly navigate the markdown file, which is useful for both editing and reviewing documents. The plugin provides two commands, ++ctrl+"u "++ and ++ctrl+"d "++ to scroll up or down the document.

## Controllo ortografico

Una delle funzioni *built-in* di Neovim è il controllo ortografico, questa funzione permette di confrontare la parola che si ha appena scritto con le parole contenute in un dizionario localizzato in quella lingua, si possono così evitare gli errori di battitura, permettendo di eliminare questo controllo dalla revisione del documento.  
Il dizionario per la lingua inglese è disponibile assieme ad una installazione standard di Neovim e può essere attivata immediatamente con il comando `:set spell spelllang=en`, per gli utenti internazionali invece i dizionari non sono disponibili e devono essere costruiti in locale.

### Costruzione del dizionario

Il processo di creazione di un dizionario locale consiste nello scaricamento dei file sorgente del dizionario e la successiva costruzione in Neovim con il comando `:mkspell`. I file sorgente possono essere reperiti utilizzando varie fonti (*Openoffice*, *Libreoffice*, altri..) e consistono in un file `.aff` e un file `.dict`.  
Il file `.aff` memorizzare la descrizione relativa al file dizionario del controllo ortografico selezionato mentre il file `.dict` è il file che contiene gli elenchi di parole e informazioni sulla lingua usati per controllare l'ortografia e fornire sinonimi.

#### Scaricare i file sorgente

!!! note "Scelta della fonte"

    Da una ricerca effettuata dall'autore è risultato che i dizionari più aggiornati siano quelli presenti sul sito delle [estensioni di Libreoffice](https://extensions.libreoffice.org/?Tags%5B%5D=50).

    In questa guida verrà costruito il dizionario per la lingua italiana ma lo stesso procedimento può essere eseguito per qualsiasi lingua si desideri, modificando il *locale* e il percorso dei sorgenti.

Aprire in un browser il sito delle estensioni di Libreoffice e selezionare la sezione *Dictionary*, una volta nella sezione si può utilizzare la funzione di ricerca per trovare, ad esempio, tutti i dizionari che trattano la lingua italiana.

![Libreoffice Extensions](./images/libreoffice_ext.png)

Selezionando il dizionario italiano si viene indirizzati ad una nuova pagina dove sono presenti la descrizione del progetto e le versioni disponibili, per scaricare la più recente basta semplicemente utilizzare il bottone presente in alto a sinistra.  
Nel caso del dizionario italiano il file da scaricare è `874d181c_dict-it.oxt`, tutti questi file sono archivi compressi (*zip*) e si possono scompattare con l'utilità `unzip`.  
Passiamo quindi a preparare i sorgenti eseguendo i seguenti comandi:

```bash
mkdir -p ~/nvspell/italian
cd ~/nvspell/italian
curl -O https://extensions.libreoffice.org/assets/downloads/z/874d181c_dict-it.oxt
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 1341k  100 1341k    0     0  1938k      0 --:--:-- --:--:-- --:--:-- 1935k
```

Una volta salvato scompattiamo il dizionario con:

```bash
unzip 874d181c_dict-it.oxt
```

Che creerà la seguente struttura:

```txt
.
├── description
├── description.xml
└──  dictionaries
    ├── CHANGELOG.txt
    ├── hyph_it_IT.dic
    ├── it_IT.aff
    ├── it_IT.dic
    ├── README_hyph_it_IT.txt
    ├── README.txt
    ├── th_it_IT_v2.dat
    └── th_it_IT_v2.idx
├── images
├── legacy
├── META-INF
└── registry
```

#### Costruzione del dizionario

Per costruire il dizionario ci si avvale del comando integrato in Neovim [mkspell](https://neovim.io/doc/user/spell.html#_3.-generating-a-spell-file), il comando scansiona tutte le parole disponibili nel file **.dict** e crea un file **.spl** dalla scansione.  
Il file **.spl** è il file che Neovim utilizza per il confronto delle parole nel buffer e va posizionato in un percorso di ricerca predefinito del comando `:spell`.

Uno dei percorsi predefiniti è una cartella `spell` nel percorso della configurazione (`~/.config/nvim`) e verrà utilizzata in questo esempio per la costruzione. L'uso di questo percorso consente inoltre, se la configurazione è mantenuta in un repository git, di replicare anche i dizionari evitando di doverli costruire sulle altre macchine dove viene replicata la configurazione.

```bash
mkdir ~/.config/nvim/spell/
```

Aprire NvChad e digitare il seguente comando, il comando consiste nel passare a `mkspell` come primo argomento il percorso di destinazione del dizionario seguito dal *locale* che si vuole costruire e come secondo argomento la sorgente dove reperire le parole seguito sempre dal *locale*.  

```txt
:mkspell ~/.config/nvim/spell/it_IT ~/nvspell/italian/it_IT
```

Al termine del processo sarà disponibile un nuovo file nella cartella `spell` chiamato **it.utf-8.spl**, ora è possibile avere il controllo ortografico in italiano del file che si sta scrivendo con:

```txt
:set spell spelllang=it
```

Per il controllo ortografico possono essere utilizzati anche più dizionari contemporaneamente, consentendo così di avere il controllo sia quando si scrive la stesura del documento che quando lo si traduce in inglese. Per avere entrambe i dizionari disponibili nel buffer a questo punto è sufficiente un:

```txt
:set spell spelllang=en,it
```

#### Aggiornamento del dizionario

Anche i dizionari, come tutte le *librerie*, vengono aggiornati per riflettere le modifiche della lingua, gli aggiornamenti anche se non così frequenti inseriscono nuove parole e nuove regole nei dizionari.

Una volta disponibile il dizionario aggiornato per prima cosa bisogna recuperare i nuovi sorgenti scaricandoli e scompattandoli in una nuova cartella che per questo esempio sarà `~/nvspell/it_new`, le istruzioni sono le stesse della procedura di costruzione.

Per l'aggiornamento del dizionario viene utilizzato il precedente comando `mkspell`, al quale va aggiunta la flag `!` per indicare al comando che il file è già presente e va sovrascritto; di conseguenza il percorso di destinazione va modificato per riflettere la posizione del file e anche il percorso dei sorgenti va indirizzato alla nuova cartella contenente i nuovi dizionari. Il comando sarà il seguente:

```txt
:mkspell! ~/.config/nvim/spell/it.utf-8.spl ~/nvspell/it_new/it_IT
```

Una volta terminata la costruzione sarà immediatamente disponibile nel buffer di NvChad.

### Dizionario delle eccezioni

Nella cartella `spell` sono presenti inoltre due file, **exceptions.utf-8.add** e **exceptions.utf-8.add.spl**, il primo è il file che fa da ponte per l'inserimento delle nuove parole nel dizionario. Il file **exceptions.utf-8.add** è un file arbitrario che deve essere creato in quanto non presente, quello che lo rende *speciale* è il fatto che venga definito come `spellfile` in questo modo si comunica al comando `spell` di utilizzarlo come ponte per la creazione di un dizionario con lo stesso nome ma con suffisso *.spl*.
Il file è condiviso fra tutte le lingue impostate in `spelllang` e serve ad eliminare le segnalazione di errore su parole che ortograficamente non sono corrette ma che lo sono nel contesto documentale come *Rocky*, *yaml* o *mkdocs*.

![Spell Wrong](./images/spell_wrong.png)

!!! note

    Il dizionario delle eccezioni viene impostato dal autocomando, presente in `lua/autocmds.lua`, che si occupa delle impostazioni automatiche per i file *markdown* e quindi è sempre disponibile in un buffer aperto su un file di quel tipo.

#### Gestione del dizionario

Per inserire nel dizionario una parola contrassegnata come corretta è sufficiente posizionare il cursore nella parola e digitare ++"z"+"g"++ (*good*) e la parola nel buffer, e nei prossimi documenti, non sarà più sottolineata ad indicare un errore. Allo stesso modo per contrassegnare qualcosa come errato si utilizza, sempre posizionati sulla parola, la combinazione ++"z"+"w"++ (*wrong*).  
Per una panoramica dei comandi disponibili si può fare riferimento a questa [sezione della guida](https://neovim.io/doc/user/spell.html#_1.-quick-start) di Neovim.
