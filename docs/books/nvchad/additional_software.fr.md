---
title: Logiciels supplémentaires
author: Franco Colussi
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 8.7, 9.1
tags:
  - nvchad
  - codage
---

# Logiciels supplémentaires utiles

Il existe plusieurs logiciels supplémentaires qui, même s'ils ne sont pas nécessaires, aideront à l'utilisation quotidienne de NvChad. Les sections ci-dessous vous guideront à choisir parmi ces logiciels et leurs usages.

## RipGrep

`ripgrep` est un outil de recherche orienté ligne de commande qui recherche récursivement dans le répertoire courant en utilisant une expression régulière _regex_. Par défaut, _ripgrep_ respecte les règles de _gitignore_ et omet automatiquement les fichiers/répertoires et les binaires cachés. Ripgrep offre un excellent support sous Windows, macOS et Linux, avec des binaires disponibles pour chaque plateforme.

### Installer RipGrep depuis EPEL

Sous Rocky Linux 8 et 9, vous pouvez installer RipGrep à partir de l'EPEL. Pour cela, installez `epel-release,` mettez à jour le système, puis installez `ripgrep` :

```
sudo dnf install -y epel-release
sudo dnf upgrade
sudo dnf install ripgrep
```

### Installez RipGrep en utilisant `cargo`

Ripgrep est un logiciel écrit en _Rust_ et peut être installé avec l'utilitaire `cargo`. Notez toutefois que `cargo` n'est pas installé automatiquement par l'installation par défaut de _rust_, donc vous devez l'installer explicitement. Si vous rencontrez des problèmes en utilisant cette méthode, revenez à l'installation à partir de l'EPEL.

```bash
dnf install rust cargo
```

Une fois que le logiciel nécessaire est opérationnel, nous pouvons installer `ripgrep` avec :

```bash
cargo install ripgrep
```

L'installation sauvegardera l'exécutable `rg` dans le répertoire `~/.cargo/bin` qui se trouve en dehors du PATH, pour l'utiliser au niveau de l'utilisateur, nous le lierons à `~/.local/bin/`.

```bash
ln -s ~/.cargo/bin/rg ~/.local/bin/
```

## Vérification de RipGrep

À ce stade, nous pouvons vérifier que tout va bien :

```bash
rg --version
ripgrep 13.0.0
-SIMD -AVX (compiled)
+SIMD +AVX (runtime)
```

RipGrep est nécessaire pour les recherches récursives avec `:Telescope`.

## Lazygit

[LazyGit](https://github.com/jesseduffield/lazygit) est une interface de style ncurses qui vous permet d'effectuer toutes les opérations `git` de manière plus conviviale. Il est requis par le plugin _lazygit.nvim_. Ce plugin permet d'utiliser LazyGit directement depuis NvChad, il ouvre une fenêtre flottante à partir de laquelle vous pouvez effectuer toutes les opérations sur vos référentiels, vous permettant ainsi d'apporter toutes les modifications au dépôt _git_ sans quitter l'éditeur.

Pour l'installer, nous pouvons utiliser le référentiel pour Fedora. Sous Rocky Linux 9, il fonctionne à merveille.

```bash
sudo dnf copr enable atim/lazygit -y
sudo dnf install lazygit
```

Une fois installé, nous ouvrons un terminal et utilisons la commande `lazygit` et une interface similaire à ceci apparaîtra :

![LazyGit UI](images/lazygit_ui.png)

Avec la touche <kbd>x</kbd> , nous pouvons afficher le menu avec toutes les commandes disponibles.

![LazyGit UI](images/lazygit_menu.png)

Maintenant que nous avons tous les logiciels de support nécessaires sur notre système, nous pouvons passer à l'installation du logiciel de base. Nous allons commencer avec l'éditeur sur lequel la configuration entière est basée, [Neovim](install_nvim.md).
