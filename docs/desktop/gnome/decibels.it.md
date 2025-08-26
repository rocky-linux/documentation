---
title: Decibels
author: Christine Belzie
contributors: Steven Spencer, Ganna Zhyrnova
---

## Introduzione

Decibel è un'applicazione che riproduce file audio. L'interfaccia intuitiva consente di caricare e riprodurre facilmente le canzoni preferite, le registrazioni delle lezioni, le idee per i progetti e altri file audio.

## Presupposti

Questa guida presuppone che si disponga di quanto segue:

 - Rocky Linux
 - Flatpak
 - FlatHub

## Processo di installazione

Andate su [Flathub.org](https://flathub.org), digitate "Decibel" nella barra di ricerca e fate clic su **Install**.

![Screenshot of the Decibels app page on FlatHub, showing the install button being highlighted by a red rectangle](images/01_decibels.png)

![manual install script and run script](images/decibels-install.png)

2. Copiare lo script di installazione manuale ed eseguirlo in un terminale:

   ```bash
   flatpak install flathub org.gnome.Decibels
   ```

3. Infine, copiate il comando run ed eseguitelo nel vostro terminale:

   ```bash
   flatpak run org.gnome.Decibels
   ```

## Guida all'uso

Per utilizzare Decibel, procedere come segue:

1. Cliccare su **Open**

   ![Screenshot of Decibels' landing page with a red rectangle surrounding the blue open button](images/02_decibels.png)

2. Scegliere il file desiderato e fare clic su **Apri** che appare nell'angolo in alto a destra dello schermo

   ![Screenshot of Decibels file selection interface with numbered arrows indicating audio file and Open button](images/03_decibels.png)

!!! note "Nota"

```
Stanchi di cliccare con il mouse? Ecco alcuni modi in cui potete usare la tastiera per riprodurre e interagire con i vostri file audio

- ++ctrl++ + ++shift++ + ++o++ = Aprire il file
- ++space++ = Riproduzione o pausa
- ++left++ = Spostare l'audio indietro di 10 secondi
- ++right++ = Spostare l'audio in avanti di 10 secondi
```

## Conclusione

Siete desiderosi di saperne di più su questa app o avete altre idee in merito? [Submit an issue in Decibel's repository at GitLab](https://gitlab.gnome.org/GNOME/Incubator/decibels/-/issues).
