---
title: Installazione Di Kde
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 9.0
tags:
  - desktop
  - kde
---

# Introduzione

Grazie al team di sviluppo di Rocky Linux, sono disponibili immagini live per diverse installazioni desktop, tra cui KDE. Per chi non sapesse cos'è un'immagine live, essa consente di avviare il sistema operativo e l'ambiente desktop utilizzando il supporto di installazione e dando la possibilità di provare il sistema prima di installarlo.

!!! note "Nota"

    Questa procedura è specifica per Rocky Linux 9.0. Attualmente non esiste una procedura per installare KDE per le versioni precedenti di Rocky Linux. 
    Sentitevi liberi di scriverne una!

## Prerequisiti

* Una macchina compatibile con Rocky Linux 9.0 (desktop, notebook o server) su cui si desidera eseguire il desktop KDE.
* La possibilità di eseguire alcune operazioni dalla riga di comando, come la verifica dei checksum delle immagini.
* La conoscenza di come scrivere un'immagine avviabile su un DVD o una chiavetta USB.

## Ottenere, verificare e scrivere l'immagine live di KDE

Prima dell'installazione, il primo passo è scaricare l'immagine live e scriverla su un DVD o una chiavetta USB. Come detto in precedenza, l'immagine sarà avviabile, proprio come qualsiasi altro supporto di installazione per Linux. È possibile trovare l'ultima immagine di KDE nella sezione download di Rocky Linux 9 [immagini live](https://dl.rockylinux.org/pub/rocky/9.3/live/x86_64/).

Si noti che questo particolare collegamento presuppone x86_64 come architettura del processore. Se si dispone di un'architettura aarch64, è possibile utilizzare questa immagine. Scaricare l'immagine live e i file di checksum.

Verificare l'immagine con il file CHECKSUM utilizzando quanto segue (nota: si tratta di un esempio! Assicurarsi che il nome dell'immagine e i file CHECKSUM corrispondano):

```
sha256sum -c CHECKSUM --ignore-missing Rocky-9-KDE-x86_64-latest.iso.CHECKSUM
```

Se tutto va bene, si dovrebbe ricevere questo messaggio:

```
Rocky-9-KDE-x86_64-latest.iso: OK
```

Se il checksum per il file restituisce OK, ora sei pronto a scrivere la tua immagine ISO sul tuo supporto. Si presuppone che sappiate come scrivere l'immagine sul vostro supporto. Questa procedura varia a seconda del sistema operativo, del supporto e degli strumenti.

## Avvio

Anche in questo caso, la situazione varia a seconda della macchina, del BIOS, del sistema operativo e così via. È necessario assicurarsi che la macchina sia impostata per l'avvio su un supporto qualsiasi (DVD o USB) come primo dispositivo di avvio. In caso di successo, viene visualizzata questa schermata:

![kde_boot](images/kde_boot.png)

Se è così, siete sulla buona strada! Se si desidera testare il supporto, si può inserire prima questa opzione, oppure si può inserire **S** per **Avviare Rocky Linux KDE 9.0**.

Ricordate che si tratta di un'immagine live. L'avvio della prima schermata richiederà un po' di tempo. Non fatevi prendere dal panico, aspettate! Quando l'immagine live è attiva, viene visualizzata questa schermata:

![kde_live](images/kde_live.png)

## Installazione di KDE

A questo punto, si può usare l'ambiente KDE e vedere se ci piace. Quando si è deciso di utilizzarla in modo permanente, fare doppio clic sull'opzione **Installa sul disco rigido**.

Si avvia così un processo di installazione abbastanza familiare per chi ha già installato Rocky Linux. La prima schermata consente di cambiare la lingua regionale:

![kde_language](images/kde_language.png)

Dopo aver scelto la lingua e aver fatto clic su **Continua**, l'installazione passa alla schermata seguente. Abbiamo evidenziato le cose che *potreste* voler modificare o verificare:

![kde_install](images/kde_install.png)

1. **Tastiera** - Assicuratevi che corrisponda al layout della tastiera che utilizzate.
2. **Ora & data** - Assicuratevi che questo corrisponda al vostro fuso orario.
3. **Destinazione di installazione** - È necessario fare clic su questa opzione, anche solo per accettare ciò che è già presente.
4. **Rete e Nome host** - Verificare che sia presente ciò che si desidera. Se la rete è abilitata, è sempre possibile modificarla in seguito, se necessario.
5. **Password di root** - Procedere con l'impostazione di una password di root. Ricordate di salvarla in un luogo sicuro (gestore di password), soprattutto se non la utilizzate spesso.
6. **Creazione di un utente** - Crea sicuramente almeno un utente. Se si desidera che l'utente abbia diritti amministrativi, ricordarsi di impostare questa opzione al momento della creazione dell'utente.
7. **Iniziare l'installazione** - Dopo aver impostato o verificato tutte le impostazioni, fare clic su questa opzione.

Una volta eseguito il passo 7, il processo di installazione inizierà a installare i pacchetti, come mostrato in questa schermata:

![kde_install_2](images/kde_install_2.png)

Dopo l'installazione sul disco rigido, apparirà la seguente schermata:

![kde_install_final](images/kde_install_final.png)

Procedere e fare clic su **Fine dell'installazione**.

A questo punto è necessario riavviare il sistema operativo e rimuovere il supporto di avvio. Quando il sistema operativo viene avviato per la prima volta, appare una schermata di configurazione:

![kde_config](images/kde_config.png)

Fare clic sull'opzione **Informazioni sulla licenza** e accettare l'EULA qui riportata:

![eula](images/eula.png)

Infine, terminare la configurazione:

![kde_finish_config](images/kde_finish_config.png)

Al termine di questo passaggio, apparirà il nome utente creato in precedenza. Inserire la password creata per l'utente e premere <kbd>INVIO</kbd>. Questo mostrerà una schermata del desktop KDE immacolata:

![kde_screen](images/kde_screen.png)

## Conclusione

Grazie al team di sviluppo di Rocky Linux, è possibile installare diverse opzioni di desktop da immagini live per Rocky Linux 9.0. KDE è un'altra opzione per coloro che non amano il desktop GNOME predefinito e l'installazione, con l'immagine live, non è complessa.
