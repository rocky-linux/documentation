---
title: Logiciels supplémentaires
author: Franco Colussi
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 8.7, 9.1
tags:
  - nvchad
  - codage
---

# :material-cart-plus: Logiciels Supplémentaires Nécessaires

Il existe plusieurs logiciels supplémentaires qui, même s'ils ne sont pas nécessaires, aideront à l'utilisation quotidienne de NvChad. Les sections ci-dessous vous guideront à choisir parmi ces logiciels et leurs usages.

## :material-text-search: RipGrep

`ripgrep` est un outil de recherche orienté ligne de commande qui recherche récursivement dans le répertoire courant en utilisant une expression régulière *regex* (pattern). Par défaut, *ripgrep* respecte les règles de *gitignore* et omet automatiquement les fichiers/répertoires et les binaires cachés. Ripgrep offre un excellent support sous Windows, macOS et Linux, avec des binaires disponibles pour chaque plateforme.

=== "Installer RipGrep depuis EPEL"

    Sous Rocky Linux 8 et 9, vous pouvez installer 'RipGrep' à partir de l'EPEL. Pour cela, installez `epel-release`, mettez à jour le système, puis installez `ripgrep` :

    ```bash
    sudo dnf install -y epel-release
    sudo dnf upgrade
    sudo dnf install ripgrep
    ```

=== "Installation de RipGrep en utilisant `cargo`"

    Ripgrep est un logiciel écrit en *Rust* et peut être installé avec l'utilitaire `cargo`. Notez cependant que `cargo` n'est pas installé par défaut avec *rust*, vous devez donc l'installer explicitement. Si vous rencontrez des problèmes en utilisant cette méthode, revenez à l'installation à partir d'EPEL.

    ```bash
    dnf install rust cargo
    ```


    Après avoir installé le logiciel nécessaire nous pouvons installer `ripgrep` avec la commande suivante :

    ```bash
    cargo install ripgrep
    ```


    L'installation enregistrera l'exécutable `rg` dans le dossier `~/.cargo/bin` qui est en dehors du PATH. Pour l'utiliser au niveau utilisateur nous le lierons à `~/.local/bin/`.

    ```bash
    ln -s ~/.cargo/bin/rg ~/.local/bin/
    ```

## :material-check-all: Vérification de RipGrep

À ce stade, vous pouvez vérifier que tout va bien avec la commande suivante :

```bash
rg --version
ripgrep 13.0.0
-SIMD -AVX (compiled)
+SIMD +AVX (runtime)
```

RipGrep est nécessaire pour des recherches récursives avec `:Telescope`.

## :material-source-merge: Lazygit

[LazyGit](https://github.com/jesseduffield/lazygit) est une interface de style `ncurses` qui vous permet d'effectuer toutes les opérations `git` de manière plus conviviale. C'est requis par le plugin ==lazygit.nvim==. Ce plugiciel permet d'utiliser `LazyGit` directement depuis `NvChad`, il ouvre une fenêtre flottante d'où vous pouvez effectuer toutes les opérations sur vos dépôts, vous permettant ainsi d'effectuer toutes les modifications sur le *dépôt git* sans quitter l'éditeur.

Pour l'installer, nous pouvons utiliser le référentiel de Fedora. Sous Rocky Linux 9, il fonctionne à merveille.

```bash
sudo dnf copr enable atim/lazygit -y
sudo dnf install lazygit
```

Une fois installé, nous ouvrons un terminal et utilisons la commande `lazygit` et une interface similaire à ceci apparaîtra :

![LazyGit UI](./images/lazygit_ui.png)

Avec la touche ++"?"++ , nous pouvons afficher le menu avec toutes les commandes disponibles.

![LazyGit UI](images/lazygit_menu.png)

Maintenant que nous avons tous les logiciels nécessaires sur notre système, nous pouvons passer à l'installation du logiciel de base. Nous allons commencer par l'éditeur sur lequel la configuration entière est basée, [Neovim](install_nvim.md).
