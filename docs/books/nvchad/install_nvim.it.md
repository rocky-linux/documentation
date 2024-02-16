---
title: Installare Neovim
author: Franco Colussi
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 8.7, 9.1
tags:
  - nvchad
  - nvim
  - coding
---

# :simple-neovim: Installazione di Neovim

## :material-message-outline: Introduzione a Neovim

Neovim è uno dei migliori editor di codice per la sua velocità, facilità di personalizzazione e configurazione.

Neovim è un fork dell'editor ==Vim==. È nato nel 2014, principalmente a causa della mancanza, all'epoca, del supporto per i lavori asincroni in Vim. Scritto in linguaggio ==Lua== con l'obiettivo di modularizzare il codice per renderlo più gestibile, Neovim è stato progettato pensando all'utente moderno. Come si legge sul sito ufficiale

> Neovim è stato creato per gli utenti che desiderano le parti migliori di Vim, e non solo.

Gli sviluppatori di Neovim hanno scelto Lua in quanto perfetto per l'incorporazione, l'utilizzo rapido di LuaJIT e una sintassi semplice e orientata agli script.

Dalla versione 0.5 Neovim include ==Treesitter== (uno strumento per la generazione di parser) e supporta il ==Language Server Protocol== (LSP). Questo riduce il numero di plugin necessari per ottenere funzioni di editing avanzate. Migliora le prestazioni di operazioni come il completamento del codice e il linting.

Uno dei suoi punti di forza è la personalizzazione. Tutte le sue configurazioni sono contenute in un unico file che può essere distribuito alle varie installazioni attraverso sistemi di controllo di versione (Git o altro) in modo che siano sempre sincronizzate.

### :fontawesome-solid-users-gear: Comunità di sviluppatori

Sebbene Vim e Neovim siano entrambi progetti open-source e ospitati su GitHub, esiste una differenza significativa tra le modalità di sviluppo. Neovim ha uno sviluppo comunitario più aperto, mentre lo sviluppo di Vim è più legato alle scelte del suo creatore. La base di utenti e sviluppatori di Neovim è piuttosto piccola rispetto a Vim, ma è un progetto in continua crescita.

### :material-key: Caratteristiche Principali

- Prestazioni: Molto veloce.
- Personalizzabile: Ampio ecosistema di plugin e temi
- Evidenziazione della sintassi: Integrato con Treesitter e LSP, ma richiede qualche configurazione

Come per Vim, Neovim richiede una conoscenza di base dei suoi comandi e delle sue opzioni. È possibile ottenere una panoramica delle sue caratteristiche attraverso il comando `:Tutor` che richiama un file in cui è possibile leggerlo ed esercitarsi a usarlo. L'apprendimento richiede più tempo rispetto a un IDE completamente grafico, ma una volta imparate le scorciatoie per i comandi e le funzionalità incluse, si procederà in modo molto fluido nella modifica dei documenti.

![Tutor Nvim](./images/neovim_tutor.png)

## :material-monitor-arrow-down-variant: Installazione di Neovim

!!! warning "Installazione da EPEL"

    Neovim è installabile anche dal repository EPEL. La versione disponibile è sempre troppo datata per soddisfare i requisiti minimi dell'installazione di NvChad.  
    L'installazione con questo metodo è fortemente sconsigliata e non è supportata da questa guida.

=== "Installazione da Pacchetto Precompilato"

    L'uso del pacchetto precompilato consente di installare sia la versione di sviluppo che quella stabile, che soddisfano i requisiti e possono essere utilizzate come base per la configurazione di NvChad.
    
    Per utilizzare tutte le funzionalità dell'editor, è necessario soddisfare le dipendenze richieste da Neovim fornendo manualmente le dipendenze del pacchetto precompilato. I pacchetti necessari possono essere installati con:

    ```bash
    dnf install compat-lua-libs libtermkey libtree-sitter libvterm luajit luajit2.1-luv msgpack unibilium xsel
    ```


    Dopo aver installato le dipendenze necessarie, è il momento di acquisire il pacchetto scelto.
    
    Accedendo alla [pagina delle release](https://github.com/neovim/neovim/releases) sarà possibile scaricare la versione di sviluppo (==pre-release==) o la versione stabile (==stable==).
    In entrambi i casi l'archivio compresso da scaricare per la nostra architettura è ==linux64==.
    
    Il file richiesto è ==nvim-linux64.tar.gz==, è necessario scaricare anche il file ==nvim-linux64.tar.gz.sha256sum== per verificarne l'integrità.
    
    Supponendo che entrambi siano stati scaricati nella stessa cartella, utilizzeremo il seguente comando per la verifica:

    ```bash
    sha256sum -c nvim-linux64.tar.gz.sha256sum
    nvim-linux64.tar.gz: OK
    ```


    Ora scompattate il pacchetto precompilato in una posizione all'interno della vostra cartella home; in questa guida è stata scelta la posizione `.local/share/`, ma può essere modificata in base alle proprie esigenze. Eseguire il comando:

    ```bash
    tar xvzf nvim-linux64.tar.gz -C ~/.local/share/
    ```


    A questo punto non rimane che creare un collegamento simbolico in ~/.local/bin/ per l'eseguibile nvim del pacchetto precompilato.

    ```bash
    cd ~/.local/bin/
    ln -sf ~/.local/share/nvim-linux64/bin/nvim nvim
    ```


    Per verificare la corretta installazione, eseguire in un terminale il comando `nvim -v`, che dovrebbe ora mostrare qualcosa di simile:

    ```txt
    nvim -v
    NVIM v0.9.5
    Build type: RelWithDebInfo
    LuaJIT 2.1.1692716794
    ```

=== "Installazione da sorgente"

    L'installazione dal pacchetto precompilato fornisce `nvim` solo all'utente che lo esegue. Se si desidera rendere Neovim disponibile a tutti gli utenti del sistema, è necessario eseguire un'installazione da sorgente. La compilazione di Neovim non è particolarmente difficile e consiste nei seguenti passaggi.
    
    Per prima cosa installiamo i pacchetti necessari alla compilazione:

    ```bash
    dnf install ninja-build libtool autoconf automake cmake gcc gcc-c++ make pkgconfig unzip patch gettext curl git
    ```


    Una volta installati i pacchetti necessari, sarà necessario creare una cartella dove costruire neovim e passare al suo interno:
    
    Il clone di Neovim, per impostazione predefinita, è sincronizzato con il ramo di sviluppo di Neovim (al momento in cui scriviamo, la versione 0.10.0). Per compilare la versione stabile, si dovrà passare al ramo corrispondente prima di clonarlo:

    ```bash
    mkdir ~/lab/build
    cd ~/lab/build
    ```


    E successivamente clonare il repository:

    ```bash
    git clone https://github.com/neovim/neovim
    ```


    Una volta terminata l'operazione, avremo una cartella denominata *neovim* contenente tutti i file necessari. Il passo successivo è selezionare il ramo stabile, quindi configurare e compilare i sorgenti con il comando `make`.

    ```bash
    cd ~/lab/build/neovim/
    git checkout stable
    make CMAKE_BUILD_TYPE=RelWithDebInfo
    ```


    Abbiamo scelto la tipologia `RelWithDebInfo` in quanto fornisce delle ottimizzazioni e un livello di debug utile per le personalizzazioni successive. È anche possibile utilizzare la tipologia `Release` se si preferiscono le massime prestazioni.
    
    Il processo si occupa di configurare e compilare i file da inserire nel nostro sistema. Questi file vengono salvati in `neovim/build`. Per installarli, si utilizzerà il comando *make install*:

    ```bash
    make install
    ```


    Poiché questo comando andrà a modificare il filesystem, deve essere eseguito come superutente, con `sudo` o direttamente dall'utente root.
    
    Terminata l'installazione, possiamo verificare che tutto sia stato eseguito correttamente controllando il percorso di Neovim:

    ```bash
    whereis nvim
    nvim: /usr/local/bin/nvim
    ```


    E verificare la versione:

    ```bash
    nvim --version
    NVIM v0.9.5
    Build type: Release
    LuaJIT 2.1.1692716794
    ....
    ```


    Come si può vedere dall'estratto del comando qui sopra, è stata eseguita un'installazione della versione stabile. Entrambe le versioni, quella stabile e quella di sviluppo, funzionano perfettamente con NvChad su Rocky Linux 9.
    
    ### :material-package-variant-closed-remove: Disinstallazione
    
    Se è necessario rimuovere l'installazione, per esempio per passare a un'altra versione, si dovrà ritornare alla cartella di compilazione e usare il cmake `target` fornito da Neovim. Per eseguire la disinstallazione, è necessario eseguire il seguente comando:

    ```bash
    cmake --build build/ --target uninstall
    ```


    Anche questo comando richiede i permessi di superutente o di essere eseguito come utente *root*.
    
    In alternativa, è possibile utilizzare il metodo manuale rimuovendo l'eseguibile e le librerie con:

    ```bash
    rm /usr/local/bin/nvim
    rm -r /usr/local/share/nvim/
    ```


    Anche in questo caso, è necessario eseguire questi comandi con i permessi di superutente.

## :material-image-outline: Uso di Base

Come si può vedere dalla schermata, un'installazione di base di Neovim fornisce un editor che non può ancora essere paragonato a un IDE.

![Neovim Standard](./images/nvim_standard.png)

Ora che abbiamo il nostro editor di base, è il momento di trasformarlo in qualcosa di più avanzato grazie alla configurazione fornita da [NvChad](install_nvchad.md).
