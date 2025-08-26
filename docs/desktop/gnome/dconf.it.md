---
title: dconf Config Editor
author: Ezequiel Bruni
contributors: Steven Spencer, Ganna Zhyrnova
---

## Introduzione

GNOME ha un approccio molto semplificato alla sua interfaccia e le sue funzionalità. Non è un male, perché è facile da imparare e l'esperienza predefinita di GNOME permette di lavorare al meglio.

Tuttavia questo approccio fa si che non sia configurabile con la stessa rapidità. Se non riuscite a trovare ciò che vi serve nel pannello delle impostazioni, potete installare GNOME Tweaks per ampliare le vostre opzioni. Si può anche installare GNOME extensions per ottenere nuove funzionalità e opzioni.

Ma cosa succede se si vogliono vedere tutte le piccole impostazioni, le caratteristiche e le configurazioni che gli sviluppatori di GNOME hanno nascosto? Si può cercare il problema attuale online e digitare un comando per modificare una variabile oscura, oppure si può installare `dconf Editor`.

`dconf Editor` è un'applicazione per le impostazioni di GNOME con _tutto_. Potrebbe ricordare un po' il Registro di Windows, e in effetti è simile. Tuttavia, è più leggibile e copre solo le funzionalità di GNOME e alcuni software costruiti per GNOME.

È inoltre possibile modificare le impostazioni delle estensioni di GNOME.

!!! warning "Attenzione"

```
Il paragone con il registro di Windows era del tutto intenzionale. Come le chiavi di registro difettose, *alcune* delle impostazioni di GNOME Shell possono rompere l'installazione di GNOME o comunque causare problemi. Potrebbe essere necessario ripristinare le vecchie impostazioni tramite la riga di comando.

Se non si è sicuri di cosa faccia una particolare impostazione, è bene fare prima una ricerca. La modifica delle impostazioni delle applicazione va bene, tuttavia, ed è molto più facile da invertire.
```

## Presupposti

Per questa guida sono necessari i seguenti elementi:

 - Rocky Linux con GNOME installato.
 - L'autorità di installare il software sul sistema (privilegi `sudo`).

## Installazione di `dconf Editor`

Accedere all'applicazione "Software", cercare "Dconf Editor" e fare clic sul pulsante di installazione. È disponibile nel repository predefinito di Rocky Linux.

![the GNOME software center, featuring dconf Editor](images/dconf-01.png)

Per installare l'editor dconf dalla riga di comando, procedere come segue:

```bash
sudo dnf install dconf-editor
```

## Utilizzo dell'editor \`dconf

Una volta aperta l'applicazione, si notano tre importanti elementi dell'interfaccia utente. In cima c'è il percorso. Tutte le impostazioni di GNOME si trovano in una struttura di percorsi/cartelle.

In alto a destra si trova un pulsante con una stellina. È il pulsante dei preferiti, che consente di salvare il proprio posto nell'app e di tornarvi in seguito in modo semplice e veloce. In basso si trova il pannello centrale in cui si selezionano le sottocartelle delle impostazioni e si modificano le impostazioni come si ritiene opportuno.

![a screenshot of the dconf Editor window with arrows pointing at the aforementioned elements](images/dconf-02.png)

A sinistra del pulsante Preferiti si trova il pulsante di ricerca, che svolge esattamente le funzioni che ci si aspetta.

E se si desidera modificare alcune impostazioni nel file manager? Ad esempio, adoro la barra laterale. Lo trovo molto utile. Ma forse voi la pensate diversamente e volete cambiare le cose. Quindi, per questa guida, deve essere eliminata.

![a screenshot of the Nautilus file manager, with a threatening red X over the doomed sidebar](images/dconf-03.png)

Andate in `/org/gnome/nautilus/window-state' e vedrete un'opzione chiamata `start-with-sidebar\`. Premete la levetta e fate clic sul pulsante "Ricarica" quando appare, come mostrato nella schermata seguente:

![a screenshot of dconf Editor, showing the toggle and reload button in question](images/dconf-04.png)

Se tutto è andato per il verso giusto, la finestra del browser dei file che si apre dovrebbe avere il seguente aspetto:

![a screenshot of the file manager, bereft of its sidebar](images/dconf-05.png)

Se la sensazione è sbagliata, tornare indietro, premere di nuovo Ricarica e aprire una nuova finestra del browser dei file.

Infine, è possibile fare clic direttamente su qualsiasi impostazione nella finestra `dconf Editor` per visualizzare ulteriori informazioni (e talvolta più opzioni). Per esempio, ecco la schermata delle impostazioni della \`dimensione iniziale' per il file manager di GNOME.

![a screenshot of dconf Editor showing the initial-size settings for the file manager](images/dconf-06.png)

## Risoluzione dei problemi

Se si stanno apportando modifiche alle impostazioni in `dconf Editor` e non si vedono cambiamenti, provare una delle seguenti soluzioni:

1. Riavviare l'applicazione a cui si stanno apportando le modifiche.
2. Uscire, rientrare o riavviare per apportare alcune modifiche a GNOME Shell.
3. Rinunciare perché questa opzione non è più funzionale.

Sull'ultimo punto: sì, gli sviluppatori di GNOME a volte disabilitano la possibilità di modificare un'impostazione, anche con `dconf Editor`.

Ad esempio, ho provato a modificare le impostazioni del commutatore di finestre (l'elenco delle finestre aperte che viene visualizzato quando si preme ++alt+tab++) senza ottenere alcun risultato. Indipendentemente da ciò che ho provato, `dconf Editor` non influisce su alcune delle sue funzioni.

Potrebbe trattarsi di un bug, ma non sarebbe la prima volta che un'impostazione mostrata in `dconf Editor` è essenzialmente disattivata di nascosto. Se si incontra questo problema, cercare nel sito delle estensioni di GNOME per vedere se esiste un'estensione che aggiunge l'opzione desiderata a GNOME.

## Conclusione

Questo è tutto ciò che occorre sapere per iniziare. Ricordate solo di tenere traccia di tutte le modifiche, di non cambiare le impostazioni senza sapere esattamente a cosa servono e di divertirvi a esplorare le opzioni che sono (per lo più) disponibili.
