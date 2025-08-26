---
title: GNOME Tweaks
author: Spencer Steven
contributors: Ganna Zhyrnova
---

## Introduzione

GNOME Tweaks è uno strumento per personalizzare l'esperienza del desktop, compresi i font predefiniti, le finestre, gli spazi di lavoro e altro ancora.

## Presupposti

 - Una workstation o un server Rocky Linux con installazione dell'interfaccia grafica che utilizza GNOME.

## Installare GNOME tweaks

GNOME Tweaks è disponibile nel repository "appstream" e non richiede alcuna configurazione aggiuntiva del repository. Installare con:

```bash
sudo dnf install gnome-tweaks 
```

L'installazione include tutte le dipendenze necessarie.

## Schermate e funzioni

![Activities Menu](images/activities.png)

Per avviare i tweak, digitate "tweak" nella ricerca del menu Attività e fate clic su "Tweak".

![Tweaks](images/tweaks.png)

<!-- Please, add here a screen where you click Tweaks -->

_General_ permette di modificare il comportamento predefinito delle animazioni, delle sospensioni e della sovraamplificazione.

![Tweaks General](images/01_tweaks.png)

_Appearance_ consente di modificare le impostazioni predefinite del tema e le immagini dello sfondo e della schermata di blocco.

![Tweaks Appearance](images/02_tweaks.png)

_Fonts_ permette di cambiare i font e le dimensioni predefinite.

![Tweaks Fonts](images/03_tweaks.png)

_Tastiera e mouse_ consente di modificare il comportamento predefinito della tastiera e del mouse.

![Tweaks Keyboard and Mouse](images/04_tweaks.png)

Se si desidera che le applicazioni vengano avviate all'avvio della shell di GNOME, è possibile impostarle in _Applicazioni di avvio_.

![Tweaks Startup Applications](images/05_tweaks.png)

Personalizzare le impostazioni predefinite della _Barra superiore_ (orologio, calendario, batteria).

![Tweaks Top Bar](images/06_tweaks.png)

_Barre dei titoli delle finestre_ consente di modificare il comportamento predefinito delle barre dei titoli.

![Tweaks Window Titlebars](images/07_tweaks.png)

_Windows_ consente di modificare il comportamento predefinito delle finestre.

![Tweaks Windows](images/08_tweaks.png)

_Workspaces_ consente di modificare la modalità di creazione degli spazi di lavoro (dinamicamente o staticamente) e l'aspetto di tali spazi.

![Tweaks Workspaces](images/09_tweaks.png)

!!! note "Nota"

```
È possibile ripristinare le impostazioni predefinite utilizzando il menu a tre barre accanto a "Tweaks" nell'angolo sinistro.
```

## Conclusione

GNOME Tweaks è un buon strumento per personalizzare l'ambiente desktop GNOME.
