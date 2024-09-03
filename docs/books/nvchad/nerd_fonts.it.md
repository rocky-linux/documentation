---
title: Installazione dei Caratteri Nerd
author: Franco Colussi
contributors: Steven Spencer, Ganna Zhyrnova, Christine Belzie
tested: 8.6, 9.0
tags:
  - nvchad
  - coding
  - font
---

# :material-format-font: Caratteri Nerd - Caratteri per sviluppatori

## :material-format-font: Cosa sono i caratteri Nerd?

![Nerd Fonts](images/nerd_fonts_site_small.png){ align=right } Nerd Fonts è una raccolta di font modificati destinati agli sviluppatori. In particolare, i "font iconici" come [Font Awesome](https://fontawesome.com/), [Devicons](https://devicon.dev/), e [Octicons](https://primer.style/foundations/icons) sono utilizzati per aggiungere glifi supplementari.

Nerd Fonts prende anche i font di programmazione più popolari, come MonoLisa o SourceCode Pro, e li modifica aggiungendo un gruppo di glifi (icone). Se il font che si desidera utilizzare non è già stato modificato, è disponibile un patcher di font.  È disponibile anche una funzione di anteprima per vedere come dovrebbe apparire il carattere nell'editor. Per ulteriori informazioni, visitare il sito principale [del progetto](https://www.nerdfonts.com/).

## :material-monitor-arrow-down-variant: Download

I font sono disponibili per il download all'indirizzo:

```text
https://www.nerdfonts.com/font-downloads
```

### :material-monitor-arrow-down-variant: Procedura di installazione

L'installazione dei Nerd Fonts in Rocky Linux si effettua interamente dalla riga di comando grazie all'implementazione della procedura fornita dal repository del progetto [ryanoasis/nerd-fonts](https://github.com/ryanoasis/nerd-fonts). La procedura utilizza *git* per recuperare i font necessari e *fc-cache* per la loro configurazione.

!!! Note "Nota"

    Questo metodo può essere usato su tutte le distribuzioni *linux* che usano [fontconfig](https://www.freedesktop.org/wiki/Software/fontconfig/) per la gestione dei font di sistema.

Per iniziare, recuperare i file necessari dal repository del progetto:

```bash
git clone --filter=blob:none --sparse git@github.com:ryanoasis/nerd-fonts
```

Questo comando scarica solo i file necessari, omettendo i font contenuti in *patched-fonts*, in modo da non appesantire il repository locale con font che poi non verranno utilizzati, consentendo così un'installazione selettiva.  
Questa guida utilizzerà il font [IBM Plex Mono](https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/IBMPlexMono), che offre una visualizzazione pulita e leggermente tipografica, caratteristiche che lo rendono particolarmente adatto alla scrittura di documentazione Markdown.  
Visitare il sito [dedicato](https://www.programmingfonts.org/#plex-mono) per una panoramica e un'anteprima dei font disponibili.

Andare alla cartella appena creata e scaricare il set di font con i comandi:

```bash
cd ~/nerd-fonts/
git sparse-checkout add patched-fonts/IBMPlexMono
```

Il comando scaricherà i font nella cartella *patched-fonts* e al termine sarà possibile installarli con lo script ==install.sh== fornito, digitando:

```bash
./install.sh IBMPlexMono
```

!!! Note "Nome riservato"

    Il font durante l'installazione viene rinominato in *BlexMono* per rispettare la SIL Open Font License (OFL) e in particolare il meccanismo [reserved name mechanism](http://scripts.sil.org/cms/scripts/page.php?item_id=OFL_web_fonts_and_RFNs#14cbfd4a).

Lo script *install.sh* copia i font nella cartella utente `~/.local/share/fonts/` e invoca il programma *fc-cache* per registrarli nel sistema. Una volta terminato, i font saranno disponibili per l'emulatore di terminale; in particolare, troveremo installati i seguenti font:

```text title="~/.local/share/fonts/"
NerdFonts/
├── BlexMonoNerdFont-BoldItalic.ttf
├── BlexMonoNerdFont-Bold.ttf
├── BlexMonoNerdFont-ExtraLightItalic.ttf
├── BlexMonoNerdFont-ExtraLight.ttf
├── BlexMonoNerdFont-Italic.ttf
├── BlexMonoNerdFont-LightItalic.ttf
├── BlexMonoNerdFont-Light.ttf
├── BlexMonoNerdFont-MediumItalic.ttf
├── BlexMonoNerdFont-Medium.ttf
├── BlexMonoNerdFont-Regular.ttf
├── BlexMonoNerdFont-SemiBoldItalic.ttf
├── BlexMonoNerdFont-SemiBold.ttf
├── BlexMonoNerdFont-TextItalic.ttf
├── BlexMonoNerdFont-Text.ttf
├── BlexMonoNerdFont-ThinItalic.ttf
├── BlexMonoNerdFont-Thin.ttf
```

## :material-file-cog-outline: Configurazione

A questo punto, il carattere Nerd scelto dovrebbe essere disponibile per la selezione. Per selezionarlo, è necessario fare riferimento al desktop in uso.

![Font Manager](images/font_nerd_view.png)

Se si utilizza il desktop predefinito di Rocky Linux (Gnome), per cambiare il carattere nell'emulatore di terminale, è sufficiente aprire `gnome-terminal`, andare in "Preferenze" e impostare il carattere Nerd per il proprio profilo.
