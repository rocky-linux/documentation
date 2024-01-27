---
title: Software Aggiuntivo
author: Franco Colussi
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 8.7, 9.1
tags:
  - nvchad
  - coding
---

# Software Aggiuntivo Richiesto

Esistono diversi software aggiuntivi che, pur non essendo necessari, facilitano l'uso complessivo di NvChad. Le sezioni seguenti illustrano il software e il suo utilizzo.

## RipGrep

`ripgrep` è uno strumento di ricerca orientato alla riga di comando che ricerca ricorsivamente la directory corrente per un modello di _regex_ (espressione regolare). Per impostazione predefinita, _ripgrep_ rispetta le regole di _gitignore_ e salta automaticamente i file/directory e i file binari nascosti. Ripgrep offre un eccellente supporto su Windows, macOS e Linux, con binari disponibili per ogni release.

### Installare RipGrep da EPEL

In entrambi Rocky Linux 8 e 9, è possibile installare RipGrep dall'EPEL. Per farlo, installate la `epel-release`, aggiornate il sistema e quindi installate `ripgrep`:

```bash
sudo dnf install -y epel-release
sudo dnf upgrade
sudo dnf install ripgrep
```

### Installare RipGrep usando `cargo`

Ripgrep è un software scritto in _Rust_ ed è installabile con l'utilità `cargo`. Si noti, tuttavia, che `cargo` non è installato dall'installazione predefinita di _rust_, quindi è necessario installarlo esplicitamente. Se si verificano errori con questo metodo, si può tornare all'installazione da EPEL.

```bash
dnf install rust cargo
```

Una volta installato il software necessario, possiamo installare `ripgrep` con:

```bash
cargo install ripgrep
```

L'installazione salverà l'eseguibile `rg` nella cartella `~/.cargo/bin`, che è al di fuori del PATH; per utilizzarlo a livello utente, lo collegheremo a `~/.local/bin/`.

```bash
ln -s ~/.cargo/bin/rg ~/.local/bin/
```

## Verificare RipGrep

A questo punto possiamo verificare che tutto sia a posto con:

```bash
rg --version
ripgrep 13.0.0
-SIMD -AVX (compiled)
+SIMD +AVX (runtime)
```

RipGrep è necessario per le ricerche ricorsive con `:Telescope`.

## Lazygit

[LazyGit](https://github.com/jesseduffield/lazygit) è un'interfaccia in stile ncurses che consente di eseguire tutte le operazioni di `git` in modo più semplice. È richiesto dal plugin _lazygit.nvim._  Questo plugin permette di utilizzare LazyGit direttamente da NvChad, aprendo una finestra fluttuante da cui è possibile eseguire tutte le operazioni sui repository, consentendo così di apportare tutte le modifiche al _repository git_ senza uscire dall'editor.

Per installarlo possiamo utilizzare il repository di Fedora. Su Rocky Linux 9 funziona perfettamente.

```bash
sudo dnf copr enable atim/lazygit -y
sudo dnf install lazygit
```

Una volta installato, apriamo un terminale e digitiamo il comando `lazygit`: apparirà un'interfaccia simile a questa:

![LazyGit UI](images/lazygit_ui.png)

Con il tasto ++x++ è possibile richiamare il menu con tutti i comandi disponibili.

![Interfaccia utente di LazyGit](images/lazygit_menu.png)

Ora che abbiamo tutti i software di supporto necessari sul nostro sistema, possiamo passare all'installazione del software di base. Inizieremo con l'editor su cui si basa l'intera configurazione, [Neovim](install_nvim.md).
