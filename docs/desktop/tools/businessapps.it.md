---
title: Apps per Azienda & Ufficio
author: Ezequiel Bruni
contributors: Steven Spencer, Ganna Zhyrnova
---

## Introduzione

Sia che abbiate un nuovo notebook da lavoro basato su Linux o che stiate cercando di creare un ambiente di lavoro a casa, potreste chiedervi dove siano le vostre solite applicazioni per l'ufficio e l'azienda.

Molte di loro sono su Flathub. Questa guida spiega come installare le applicazioni più comuni e fornisce un elenco di valide alternative. Continuate a leggere per sapere come installare Office, Zoom e altro ancora.

## Presupposti

Questa guida presuppone quanto segue:

- Rocky Linux con un ambiente desktop grafico
- I permessi per installare software nel sistema
- Flatpak e Flathub installati e funzionanti

## Come installare i più comuni software aziendali su Rocky Linux

Il più delle volte, installati Flatpak e Flathub, si va nel Software Center, si cerca quello che si desidera e lo si installa. Queste piattaforme si prenderanno cura delle opzioni di installazione più comuni. Per gli altri, è necessario utilizzare le versioni browser delle applicazioni.

![A screenshot of Zoom in the software center](images/businessapps-01.png)

Per iniziare, ecco un elenco di alcune delle applicazioni aziendali più comuni con client desktop e i modi migliori per ottenerle.

!!! note "Nota"

```
Se volete conoscere lo stato di Microsoft Office su Linux, scorrete in basso e passate alla sezione successiva.
```

Inoltre, questo elenco non include applicazioni come Jira, che non hanno applicazioni desktop ufficiali.

### Asana Desktop

App per desktop: non disponibile su Linux

Consigliato: Utilizzare la versione web.

### Discord

App per desktop: Applicazioni ufficiali e di terze parti disponibili con Flathub nel Software Center

Consigliato: Utilizzare il client ufficiale se si ha bisogno di utilizzare push-to-talk. Utilizzare anche la versione del browser o qualsiasi client di terze parti nel Centro software.

### Dropbox

Applicazione per desktop: L'applicazione ufficiale è disponibile con Flathub nel Software Center.

Consigliato: Utilizzare l'applicazione ufficiale in GNOME e nella maggior parte degli altri ambienti desktop. Se si utilizza KDE, utilizzare l'integrazione nativa Dropbox.

### Evernote

Applicazione desktop: Non più disponibile per Linux.

Consigliato: Utilizzare la versione web.

### Freshbooks

Applicazione desktop: Non disponibile su Linux.

Consigliato: Utilizzare la versione web.

### Google Drive

Desktop app: Client di terze parti.

Consigliato: accedere al proprio account Google utilizzando la funzione Account online di GNOME Shell o KDE. Questo permetterà di accedere in modo integrato ai file, alla posta elettronica, al calendario, agli elenchi to-do e altro ancora su GNOME.

È possibile sfogliare e gestire i file di Drive dal gestore di file di KDE. Non è completamente integrato come GNOME, ma è comunque utile.

### Hubspot

Applicazione desktop: Non disponibile su Linux.

Consigliato: Utilizzare la versione web.

### Microsoft Exchange

Desktop app: Solo client di terze parti.

Consigliato: In GNOME è possibile utilizzare la funzione Account online per integrare le proprie applicazioni con Exchange, proprio come un account Google.

Su qualsiasi altro ambiente desktop, utilizzare Thunderbird con uno dei _numerosi_ addons Exchange-enabling. Thunderbird è disponibile nel repository predefinito di Rocky Linux, ma è possibile ottenere una versione più recente con Flathub.

### Notion

Applicazione desktop: Non disponibile su Linux.

Consigliato: Utilizzare la versione web.

### Outlook

Applicazione per desktop: Solo app di terze parti.

Consigliato: Utilizzare il client di posta elettronica preferito. Evolution e Thunderbird sono buone opzioni, oppure utilizzate la versione web.

### Quickbooks

Applicazione desktop: Non disponibile su Linux.

Consigliato: Utilizzare la versione web.

### Slack

Applicazione per desktop: Questa applicazione è disponibile con Flathub nel Sofware Center.

Consigliato: Utilizzare l'app o la versione web, a seconda delle preferenze.

### Teams

Applicazione per desktop: Questa applicazione è disponibile con Flathub nel Sofware Center.

Consigliato: Utilizzatelo sul desktop o sul browser come meglio si crede. Se è necessario abilitare la condivisione dello schermo, accedere a una sessione X11 all'avvio di sistema. La condivisione dello schermo non è ancora supportata su Wayland.

### Zoom

Applicazione per desktop: Questa applicazione è disponibile con Flathub nel Sofware Center.

Consigliato: Se si utilizza l'applicazione desktop su Rocky Linux, accedere a sistema utilizzando la sessione X11 anziché Wayland se si ha bisogno di condividere lo schermo. La condivisione dello schermo funziona oggi in Wayland, ma solo con le versioni più recenti del software.

Essendo di principio un sistema operativo aziendale stabile, Rocky Linux impiega un po' di tempo per rimanere al passo.

Tuttavia, a seconda del vostro browser, potreste avere più fortuna nella condivisione dello schermo su Wayland saltando del tutto l'applicazione desktop e usando solo la versione web.

## Alternative open source alle classiche applicazioni aziendali

Se potete scegliere il vostro software per il lavoro e la produttività, potreste considerare di cambiare la vostra routine e provare un'alternativa open-source. La maggior parte delle applicazioni sopra elencate può essere sostituita da un'istanza self-hosted o cloud-hosted di [Nextcloud](https://nextcloud.com) e da alcune applicazioni di terze parti che è possibile installare su tale piattaforma.

È in grado di gestire la sincronizzazione dei file, la gestione dei progetti, il CRM, il calendario, la gestione delle note, la contabilità di base, la posta elettronica e, con un po' di lavoro e di configurazione, la chat di testo e video.

Per un'alternativa più avanzata e di livello aziendale a Nextcloud, [Wikisuite](https://wikisuite.org/Software) può fare tutto ciò che è stato elencato sopra e aiutarvi a costruire il vostro sito web aziendale. In questo senso è molto simile a Odoo.

Si noti tuttavia che queste piattaforme sono principalmente incentrate sul web. Il client Nextcloud Desktop serve solo per la sincronizzazione dei file e Wikisuite non ne ha uno.

Potete sostituire Slack con [Mattermost](https://mattermost.com), una piattaforma open-source di chat e gestione dei team. Se però avete bisogno delle funzioni video e audio fornite da Discord, Teams o Zoom, potete aggiungere [Jitsi Meet](https://meet.jit.si) al mix. È un po' come un Google Meet self-hosted.

Sia Mattermost che Jitsi hanno anche client desktop Linux su Flathub.

Lo stesso vale per [Joplin](https://joplinapp.org) e [QOwnNotes](https://www.qownnotes.org/), e [Notesnook](https://notesnook.com), che sono fantastiche alternative a Evernote.

State cercando un'alternativa a Notion nel Software Center? [AppFlowy](https://appflowy.io) o [SiYuan](https://b3log.org/siyuan/en/) potrebbero fare al caso.

!!! note "Nota"

```
Sebbene tutte le app alternative elencate sopra siano open source, non tutte sono “Free Libre and Open Source (FLOSS)”. Ciò significa che alcune di esse richiedono il pagamento di funzioni aggiuntive o di versioni premium dei loro servizi.
```

## Microsoft Office su Rocky Linux

I neofiti nel mondo Linux potrebbero chiedersi cosa ci sia di così difficile nel farlo funzionare. Non è difficile se si è in grado di utilizzare la versione web di Office365.

Tuttavia, sarà più difficile se avete bisogno di un'esperienza desktop completa, con tutte le caratteristiche e i vantaggi offerti dalle applicazioni di Windows. Sebbene ogni tanto qualcuno scriva un tutorial su come far funzionare l'ultima versione delle applicazioni di Office su Linux con WINE, queste soluzioni spesso si bloccano prima del tempo. Non esiste un modo stabile per far funzionare le applicazioni desktop su Linux.

Esistono suite per ufficio compatibili con Linux e Microsoft Office, ma il vero problema è Excel.

Fino a questo momento, la versione desktop di Excel è stata praticamente impareggiabile in termini di funzioni, modalità di manipolazione dei dati e così via. Certo, si tratta di una "bestia" di programma che altri difficile replicare.

Il flusso di lavoro è diverso anche se le alternative hanno tutte le caratteristiche di cui un particolare utente potrebbe aver bisogno. Non è possibile inserire le formule e i fogli di calcolo più complicati in una delle alternative, nemmeno nella versione web di Excel, e aspettarsi che funzioni.

Tuttavia, se Excel non è una parte importante del vostro flusso di lavoro, si possono scegliere le alternative. Sono _tutti_ disponibili nel Software Center con Flathub.

### Alternative Microsoft Office per Rocky Linux

#### LibreOffice

[LibreOffice](https://www.libreoffice.org) è lo standard de-facto per software d'ufficio e produttività di FLOSS. Copre la maggior parte delle esigenze d'ufficio: documenti, fogli di calcolo, presentazioni, software per il disegno vettoriale (costruito pensando alla stampa) e database.

In genere ha una buona compatibilità, ma non perfetta con Microsoft Office, ma è _molto_ bravo a gestire i formati aperti. Se volete staccarvi completamente dall'ecosistema Microsoft, LibreOffice è probabilmente la scelta migliore.

Esiste anche una versione web-hosted, chiamata Collabora Office, che presenta limitazioni a meno che non si paghi per le versioni premium.

#### OnlyOffice

[OnlyOffice](https://www.onlyoffice.com) è una suite di applicazioni leggermente meno completa, ma comunque fantastica, per creare documenti, presentazioni, fogli di calcolo e moduli PDF. Degno di nota, l'editor di PDF incluso nella suite.

Se avete bisogno della compatibilità con Microsoft Office, in particolare per i documenti e le presentazioni, OnlyOffice è probabilmente la scelta migliore. OnlyOffice gestisce meglio i documenti Word rispetto alla versione online di Office365.

#### WPS Office

[WPS Office](https://www.wps.com), ex Kingsoft Office, è presente nell'ecosistema Linux da diverso tempo. Gestisce anche documenti, fogli di calcolo, presentazioni e un editor di PDF.

WPS Office ha una compatibilità con Microsoft Office leggermente migliore rispetto a LibreOffice, ma non è compatibile come OnlyOffice. Inoltre, dispone di un minor numero di funzioni ed è meno personalizzabile. Questo è un estratto del loro blog:

![WPS Office ha un'interfaccia più moderna e facile da usare rispetto a OnlyOffice. È anche più facile da imparare e da usare, soprattutto per i principianti. WPS Office dispone inoltre di una gamma più ampia di modelli e temi, che facilitano la creazione di documenti dall'aspetto professionale. OnlyOffice è più potente e personalizzabile di WPS Office. Ha una gamma più ampia di funzioni, tra cui strumenti di gestione dei documenti e dei progetti. OnlyOffice è anche più compatibile con i formati di Microsoft Office rispetto a WPS Office](images/businessapps-02.png).

Il loro obiettivo principale è creare un'esperienza utente più semplice e accessibile, che potrebbe essere esattamente ciò che ci si aspetta.

#### Calligra

La suite per ufficio [Calligra](https://calligra.org) è un progetto FLOSS degli sviluppatori di KDE. Offre un set di applicazioni di base da ufficio di facile utilizzo per creare documenti, fogli di calcolo, presentazioni, database, diagrammi di flusso, disegni vettoriali, ebook e altro ancora.

Tuttavia, le applicazioni Calligra non sono facili da installare su Rocky Linux. Se si ha un'altra macchina con Fedora, l'autore incoraggia a provarla.

## Conclusione

Con alcune eccezioni degne di nota, per utilizzare tutti i software d'ufficio su Rocky Linux è sufficiente trovare le applicazioni su Flathub o utilizzarne la versione web. In ogni caso, Rocky Linux è certamente una piattaforma stabile e conveniente per la maggior parte delle attività tipiche dell'ufficio.

Se la mancanza di assistenza per la versione desktop di Excel è un ostacolo, l'autore consiglia di utilizzare un database server full-on. I database server possono fare cose straordinarie.
