---
title: Installazione dei Caratteri Nerd
author: Franco Colussi
contributors: Steven Spencer, Ganna Zhyrnova
tested: 8.6, 9.0
tags:
  - nvchad
  - coding
  - font
---

# Caratteri Nerd - Caratteri per sviluppatori

L'installazione dei Nerd Fonts non modifica la funzione di Neovim o NvChad, ma aggiunge semplicemente dei caratteri più gradevoli alla vista rispetto al carattere standard del terminale.

![Caratteri Nerd](images/nerd_fonts_site_small.png){ align=right } I caratteri Nerd sono una raccolta di caratteri modificati rivolta agli sviluppatori. In particolare, "font iconici" come Font Awesome, Devics, Octicons ecc sono utilizzati per aggiungere glifi extra.

Nerd Fonts prende i caratteri di programmazione più popolari e li modifica aggiungendo un gruppo di glifi (icone). È disponibile anche un font patcher se il carattere che vuoi usare non è già stato modificato. Sul sito è disponibile una comoda anteprima che consente di vedere come dovrebbe apparire il font nell'editor. Per ulteriori informazioni, consultare il [sito](https://www.nerdfonts.com/) principale del progetto.

## Download

I caratteri sono disponibili per il download su:

```text
https://www.nerdfonts.com/font-downloads
```

## Installazione

La procedura per l'installazione dei font su Rocky Linux consiste nel salvare da qualche parte i font che si desidera aggiungere e poi installarli con il comando `fc-cache`. Questa procedura non è una vera e propria installazione, ma piuttosto una registrazione dei nuovi font nel sistema.

!!! warning "Creazione di pacchetti compressi"

    La procedura descritta di seguito non è una procedura standard, poiché ogni sviluppatore ha confezionato i font utilizzando uno schema personalizzato. Quindi, una volta scaricato ed estratto, è necessario verificare il contenuto per scegliere la procedura di copia dei font.

Per questa guida utilizzeremo il font `Sauce Code Pro Nerd`.

Scarica il pacchetto con:

```bash
https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.3/SourceCodePro.zip
```

Quindi, decomprimere il contenuto della cartella e copiare i font in `~/.local/share/fonts/` con:

```bash
mkdir ~/.local/share/fonts
unzip SourceCodePro.zip -d ~/.local/share/fonts/
fc-cache ~/.local/share/fonts
```

## Configurazione

A questo punto il carattere Nerd scelto dovrebbe essere disponibile per la selezione. Per selezionarlo effettivamente è necessario fare riferimento al desktop in uso.

![Gestore Caratteri](images/font_nerd_view.png)

Se si utilizza il desktop predefinito di Rocky Linux (Gnome), per cambiare il carattere nell'emulatore di terminale è sufficiente aprire `gnome-terminal`, andare in "Preferenze" e impostare il carattere Nerd per il proprio profilo.
