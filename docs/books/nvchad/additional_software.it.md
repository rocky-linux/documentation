---
title: Software Aggiuntivo
author: Franco Colussi
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 8.7, 9.1
tags:
  - nvchad
  - coding
---

# :material-cart-plus: Software aggiuntivo richiesto

Esistono diversi software aggiuntivi che, pur non essendo necessari, facilitano l'uso complessivo di NvChad. Le sezioni seguenti illustrano il software e il suo utilizzo.

## :material-text-search: RipGrep

`ripgrep` è uno strumento di ricerca orientato alla riga di comando che ricerca ricorsivamente la directory corrente per un modello di *regex* (espressione regolare). Per impostazione predefinita, *ripgrep* rispetta le regole di *gitignore* e salta automaticamente i file/directory e i file binari nascosti. Ripgrep offre un eccellente supporto su Windows, macOS e Linux, con binari disponibili per ogni release.

=== "Installare RipGrep da EPEL"

    In entrambi Rocky Linux 8 e 9, è possibile installare RipGrep dall'EPEL. Per farlo, installare la `epel-release`, aggiornare il sistema e quindi installare `ripgrep`:

    ```bash
    sudo dnf install -y epel-release
    sudo dnf upgrade
    sudo dnf install ripgrep
    ```

=== "Installare RipGrep usando cargo"

    Ripgrep è un software scritto in *Rust* ed è installabile con l'utilità `cargo`. Da notare, tuttavia, che `cargo' non è installato dall'installazione predefinita di *rust*, quindi è necessario installarlo esplicitamente. Se si verificano errori con questo metodo, tornare all'installazione da EPEL.

    ```bash
    dnf install rust cargo
    ```


    Una volta installato il software necessario, si può installare `ripgrep` con:

    ```bash
    cargo install ripgrep
    ```


    L'installazione salverà l'eseguibile `rg` nella cartella `~/.cargo/bin`, che è al di fuori del PATH; per utilizzarlo a livello utente, sarà necessario collegarlo a `~/.local/bin/`.

    ```bash
    ln -s ~/.cargo/bin/rg ~/.local/bin/
    ```

## :material-check-all: Verificare RipGrep

A questo punto si può verificare che tutto sia a posto con:

```bash
rg --version
ripgrep 13.0.0
-SIMD -AVX (compiled)
+SIMD +AVX (runtime)
```

RipGrep è necessario per le ricerche ricorsive con `:Telescope`.

## :material-source-merge: Lazygit

[LazyGit](https://github.com/jesseduffield/lazygit) è un'interfaccia in stile ncurses che consente di eseguire tutte le operazioni di `git` in maniera più agevole. È richiesto dal plugin ==lazygit.nvim==. Questo plugin consente di utilizzare LazyGit direttamente da NvChad, aprendo una finestra fluttuante da cui è possibile eseguire tutte le operazioni sui repository, consentendo così di apportare tutte le modifiche al *repository di Git* senza uscire dall'editor.

Per installarlo si può utilizzare il repository di Fedora. Su Rocky Linux 9 funziona perfettamente.

```bash
sudo dnf copr enable atim/lazygit -y
sudo dnf install lazygit
```

Una volta installato, aprire un terminale e digitare il comando `lazygit` e apparirà un'interfaccia simile a questa:

![LazyGit UI](./images/lazygit_ui.png)

Con il tasto ++"? "++ è possibile richiamare il menu con tutti i comandi disponibili.

![LazyGit UI](images/lazygit_menu.png)

Ora che tutti i software di supporto necessari sono presenti sul sistema, possiamo passare all'installazione del software di base. Inizieremo con l'editor su cui si basa l'intera configurazione, [Neovim](install_nvim.md).
