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

## Introduzione a Neovim

Neovim è uno dei migliori editor di codice per la sua velocità, facilità di personalizzazione e configurazione.

Neovim è un fork dell'editor `Vim`. È nato nel 2014, principalmente a causa della mancanza, all'epoca, del supporto per i lavori asincroni in Vim. Scritto in linguaggio Lua con l'obiettivo di modularizzare il codice per renderlo più gestibile, Neovim è stato progettato pensando all'utente moderno. Come si legge sul sito ufficiale, "Neovim è costruito per gli utenti che vogliono le parti migliori di Vim, e non solo".

Gli sviluppatori di Neovim hanno scelto Lua in quanto perfetto per l'incorporazione, l'utilizzo rapido di LuaJIT e una sintassi semplice e orientata agli script.

Dalla versione 0.5 Neovim include Treesitter (uno strumento per la generazione di parser) e supporta il Language Server Protocol (LSP). Questo riduce il numero di plugin necessari per ottenere funzioni di editing avanzate. Migliora le prestazioni di operazioni come il completamento del codice e il linting.

Uno dei suoi punti di forza è la personalizzazione. Tutte le sue configurazioni sono contenute in un unico file che può essere distribuito alle varie installazioni attraverso sistemi di controllo di versione (Git o altro) in modo che siano sempre sincronizzate.

### Comunità di sviluppatori

Sebbene Vim e Neovim siano entrambi progetti open-source e ospitati su GitHub, esiste una differenza significativa tra le modalità di sviluppo. Neovim ha uno sviluppo comunitario più aperto, mentre lo sviluppo di Vim è più legato alle scelte del suo creatore. La base di utenti e sviluppatori di Neovim è piuttosto piccola rispetto a Vim, ma è un progetto in continua crescita.

### Caratteristiche Principali

- Prestazioni: Molto veloce.
- Personalizzabile: Ampio ecosistema di plugin e temi
- Evidenziazione della sintassi: Integrato con Treesitter e LSP, ma richiede qualche configurazione

Come per Vim, Neovim richiede una conoscenza di base dei suoi comandi e delle sue opzioni. È possibile ottenere una panoramica delle sue caratteristiche attraverso il comando `:Tutor` che richiama un file in cui è possibile leggerlo ed esercitarsi a usarlo. L'apprendimento richiede più tempo rispetto a un IDE completamente grafico, ma una volta imparate le scorciatoie per i comandi e le funzionalità incluse, si procederà in modo molto fluido nella modifica dei documenti.

![Tutor Nvim](images/neovim_tutor.png)

## Installazione di Neovim

### Installazione da EPEL

Prima di passare all'installazione di NvChad, dobbiamo assicurarci di avere a disposizione un'installazione di Neovim. Se non è già installato, è possibile installarlo dal repository EPEL. Il repository EPEL fornisce la versione minima richiesta da NvChad (attualmente 0.7.2). Nel caso in cui si voglia utilizzare una versione più recente, si consiglia l'installazione dal pacchetto precompilato o dal sorgente.

Per installare la versione di Neovim fornita da EPEL, è necessario installare il repository stesso, se non lo si è già fatto.

```bash
dnf install epel-release
```

Digitare il seguente comando per installare l'applicazione:

```bash
dnf install neovim
```

### Installazione da Pacchetto Precompilato

L'installazione dal pacchetto precompilato consente di testare le versioni di sviluppo di Neovim (0.8 e successive). Le due versioni (installazioni) possono coesistere sullo stesso sistema, poiché la versione del pacchetto precompilato rimane interamente confinata a livello utente.

Per poter utilizzare tutte le funzionalità della nuova versione, dobbiamo ancora soddisfare le dipendenze richieste da Neovim, dobbiamo fornire manualmente le dipendenze _al nostro_ `nvim`. I pacchetti necessari possono essere installati con:

```bash
dnf install compat-lua-libs libtermkey libtree-sitter libvterm luajit luajit2.1-luv msgpack unibilium xsel
```

Successivamente, scarichiamo l'archivio compresso per la nostra architettura (linux64) da questo indirizzo:

```text
https://github.com/neovim/neovim/releases
```

Il file da scaricare è `nvim-linux64.tar.gz`. Per verificare l'integrità dell'archivio è necessario scaricare anche il file `nvim-linux64.tar.gz.sha256sum`. Una volta scaricato, dobbiamo verificarne l'integrità e scompattarlo da qualche parte nella nostra `home directory`. La soluzione proposta è quella di scompattarlo in `~/.local/share/`. Supponendo che lo abbiamo scaricato in _/home/user/downloads/_, dovremo eseguire i seguenti comandi:

```bash
sha256sum -c /home/user/downloads/nvim-linux64.tar.gz.sha256sum
nvim-linux64.tar.gz: OK

tar xvzf /home/user/downloads/nvim-linux64.tar.gz
mv /home/user/downloads/nvim-linux64 ~/.local/share/nvim-linux64
```

A questo punto non resta che creare un collegamento simbolico in `~/.local/bin/` per il nostro _nvim_.

```bash
cd ~/.local/bin/
ln -sf ~/.local/share/nvim-linux64/bin/nvim nvim
```

Verificate ora di avere la versione corretta con il comando `nvim -v`, che dovrebbe ora mostrarvi:

```txt
nvim -v
NVIM v0.8.3
Build type: RelWithDebInfo
LuaJIT 2.1.0-beta3
```

### Installazione da Sorgente

L'installazione di un pacchetto precompilato, come sopra, fornisce `nvim` solo all'utente che lo esegue. Se si desidera rendere Neovim disponibile a tutti gli utenti del sistema, è necessario eseguire un'installazione da sorgente. La compilazione di Neovim non è particolarmente difficile e consiste nei seguenti passaggi.

Installiamo prima i pacchetti necessari per la compilazione:

```bash
dnf install ninja-build libtool autoconf automake cmake gcc gcc-c++ make pkgconfig unzip patch gettext curl git
```

Una volta installati i pacchetti necessari, dobbiamo creare una cartella dove costruire neovim e posizionarci:

Il clone di Neovim, per impostazione predefinita, è sincronizzato con il ramo di sviluppo di Neovim (al momento in cui scriviamo, la versione 8.0). Per compilare la versione stabile dovremo passare al ramo corrispondente prima di clonare con:

```bash
mkdir ~/lab/build
cd ~/lab/build
```

E successivamente clonare il repository:

```bash
git clone https://github.com/neovim/neovim
```

Una volta terminata l'operazione, avremo una cartella denominata _neovim_ contenente tutti i file necessari. Il passo successivo consiste nel fare il checkout del ramo stabile, quindi configurare e compilare i sorgenti con il comando `make`.

```bash
cd ~/lab/build/neovim/
git checkout stable
make CMAKE_BUILD_TYPE=RelWithDebInfo
```

Abbiamo scelto il tipo `RelWithDebInfo` perché fornisce non solo ottimizzazioni, ma anche un utile livello di debug per le personalizzazioni successive. Si sarebbe potuto utilizzare anche il tipo `Release`, se si vogliono ottenere le massime prestazioni.

Il processo si occupa di configurare e compilare i file da inserire nel nostro sistema. Questi file vengono salvati in `neovim/build`. Per installarli, utilizzeremo il comando _make install_:

```bash
make install
```

Poiché questo comando modificherà il filesystem, deve essere eseguito come superutente, con `sudo` o direttamente dall'utente root.

Una volta terminata l'installazione, possiamo verificare che tutto sia andato bene controllando il percorso di Neovim:

```bash
whereis nvim
nvim: /usr/local/bin/nvim
```

E verificare la versione:

```bash
nvim --version
NVIM v0.8.3
Build type: RelWithDebInfo
LuaJIT 2.1.0-beta3
....
```

Come si può vedere dall'estratto del comando qui sopra, è stata eseguita un'installazione della versione stabile. Entrambe le versioni, quella stabile e quella di sviluppo, funzionano perfettamente con NvChad su Rocky Linux 9.

#### Disinstallare

Nel caso in cui si debba rimuovere l'installazione, ad esempio per passare a un'altra versione, si dovrà tornare alla cartella di compilazione e utilizzare il `target` cmake fornito da Neovim stesso. Per eseguire la disinstallazione, è necessario eseguire il seguente comando:

```bash
cmake --build build/ --target uninstall
```

Anche questo comando richiede i privilegi di superutente o di essere eseguito come utente _root_.

In alternativa, è possibile utilizzare il metodo manuale rimuovendo l'eseguibile e le librerie con:

```bash
rm /usr/local/bin/nvim
rm -r /usr/local/share/nvim/
```

Anche in questo caso, è necessario eseguire questi comandi con i permessi di superutente.

## Uso di Base

Come si può vedere dalla schermata, un'installazione di base di Neovim fornisce un editor che non può ancora essere paragonato a un IDE.

![Standard Neovim](images/nvim_standard.png)

Ora che abbiamo il nostro editor di base, è il momento di trasformarlo in qualcosa di più avanzato grazie alla configurazione fornita da [NvChad](install_nvchad.md).
