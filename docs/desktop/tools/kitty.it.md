---
title: Installare l'emulatore di terminale Kitty
author: Alex Zolotarov
contributors: Spencer Steven
tested with: 9
---

## Introduzione

**Kitty è un emulatore di terminale velocissimo pompato di steroidi**, tutto ciò che si può immaginare è personalizzabile in Kitty.
È possibile utilizzare la gestione delle schede, il tiling, le anteprime delle immagini e molte altre opzioni, proprio all'interno di questo emulatore di terminale.
Si può anche sostituire `tmux` o un gestore di finestre con **Kitty** (se si lavora prevalentemente in un terminale).

## Prerequisiti

- Disponete di una workstation o di un server Rocky Linux con GUI
- Si è un'amministrazione con privilegi `sudo`.

## Installazione di Kitty

**Prima di tutto, installare il repository EPEL (Extra Packages for Enterprise Linux):**

```bash
dnf install -y epel-release
```

Quindi, installare **Kitty**:

```bash
dnf install -y kitty
```

Una volta installato, è possibile avviare Kitty.

## Panoramica rapida

### File di configurazione

Una volta avviato **Kitty** è possibile aprire il file di configurazione di Kitty con ++ctrl+shift+f2++.
Il file di configurazione si trova anche in `$HOME/.config/kitty`.

Questo documento non approfondirà il file di configurazione in sé. Sappiate che è possibile modificare le scorciatoie predefinite o qualsiasi altra cosa relativa all'aspetto nella configurazione.

### Schede

È possibile creare una nuova scheda con ++ctrl+shift+t++.

È possibile chiudere una scheda con ++ctrl+shift+w++ _o_ ++ctrl+shift+q++.

È possibile selezionare le schede con ++ctrl+shift+sinistra++ _o_ ++ctrl+shift+destra++.

![kittytabs](./images/kitty_tabs.png)

### Tiling

Premere ++ctrl+shift+enter++ per aprire un nuovo riquadro o una nuova finestra.
È possibile premerlo più volte per creare un tiling layout.

È possibile cambiare layout con ++ctrl+shift+l++.

È possibile selezionare le finestre o i riquadri con ++ctrl+shift+bracket-sinistra++ o ++ctrl+shift+bracket-destra++.
Se si preferisce, è sufficiente fare clic con il mouse sul riquadro o sulla finestra.

![kittytiling](./images/kitty_tilling.png)

## Conclusione

Kitty offre molte funzioni senza bisogno di ulteriori configurazioni.
Se avete già un gestore di finestre, `zsh` o `tmux` configurato sulla vostra workstation, probabilmente non avete bisogno di Kitty. Si consideri il fatto che è possibile combinare le scorciatoie di `zsh`, il tiling di `tmux` e molte funzioni di window manager, solo in un emulatore di terminale.
Ma se non si ha ancora provato nessuno di questi potenti tool, l'autore\*\* consiglia di iniziare con Kitty.
