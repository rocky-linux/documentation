---
title: Installazione Di Kde
author: Steven Spencer
contributors: Ezequiel Bruni, Franco Colussi
tested_with: 9.0
tags:
  - desktop
  - kde
---

# Introduzione

Grazie al team di sviluppo di Rocky Linux, sono ora disponibili immagini live per diverse installazioni desktop, tra cui KDE. Per chi non sapesse cos'è un'immagine live, essa consente di avviare il sistema operativo e l'ambiente desktop utilizzando il supporto di installazione e dando la possibilità di provare il sistema prima di installarlo.

!!! note "Nota"

    Questa procedura è specifica per Rocky Linux 9.0. Attualmente non esiste una procedura per l'installazione di KDE per le versioni precedenti di Rocky Linux. 
    Sentitevi liberi di scriverne una!

## Prerequisiti

* Un computer compatibile con Rocky Linux 9.0 (desktop, laptop o server) su cui si desidera eseguire il desktop KDE.
* La possibilità di eseguire alcune operazioni dalla riga di comando, come la verifica dei checksum delle immagini.
* La conoscenza di come scrivere un'immagine avviabile su un disco DVD o USB.

## Ottenere, verificare e scrivere l'immagine live di KDE

Prima dell'installazione, il primo passo è scaricare l'immagine live e scriverla su un DVD o una chiavetta USB. Come detto in precedenza, l'immagine sarà avviabile, proprio come qualsiasi altro supporto di installazione per Linux. È possibile trovare l'ultima immagine di KDE nella sezione di download per le [immagini live](https://dl.rockylinux.org/pub/rocky/9.0/live/x86_64/) di Rocky Linux 9.

Si noti che questo particolare collegamento presuppone x86_64 come architettura del processore. Se si dispone di un'architettura aarch64, è possibile utilizzare questa immagine. Scaricare sia l'immagine live che i file di checksum.

Ora verificate l'immagine con il file CHECKSUM utilizzando quanto segue (nota: questo è un esempio! Assicurarsi che il nome dell'immagine e i file CHECKSUM corrispondano):

```
sha256sum -c CHECKSUM --ignore-missing Rocky-9-KDE-x86_64-latest.iso.CHECKSUM
```

Se tutto va bene, si dovrebbe ricevere questo messaggio:

```
Rocky-9-KDE-x86_64-latest.iso: OK
```

Se il checksum per il file restituisce OK, ora sei pronto a scrivere la tua immagine ISO sul tuo supporto. Questa procedura varia a seconda del sistema operativo in uso, del supporto e degli strumenti. Si presuppone che sappiate come scrivere l'immagine sul vostro supporto.

## Avvio

Anche in questo caso la procedura varia a seconda della macchina, del BIOS, del sistema operativo e così via.  È necessario assicurarsi che la macchina sia impostata per l'avvio da qualsiasi supporto (DVD o USB) come primo dispositivo di avvio. In caso di successo, dovrebbe essere visualizzata questa schermata:

![kde_boot](images/kde_boot.png)

Se è così, siete sulla buona strada! Se si desidera testare il supporto, è possibile selezionare prima questa opzione, oppure si può semplicemente digitare **S** per **avviare Rocky Linux KDE 9.0**.

Ricordate che si tratta di un'immagine live, quindi ci vorrà un po' di tempo per avviare la prima schermata. Non fatevi prendere dal panico, aspettate! Una volta avviata l'immagine live, si dovrebbe vedere questa schermata:

![kde_live](images/kde_live.png)

## Installazione di KDE

A questo punto, si può usare l'ambiente KDE e vedere se ci piace. Una volta deciso di utilizzarlo in modo permanente, fare doppio clic sull'opzione **Installa sul disco rigido**.

Si avvia così un processo di installazione abbastanza familiare per chi ha già installato Rocky Linux. La prima schermata vi darà la possibilità di cambiare la vostra lingua regionale:

![kde_language](images/kde_language.png)

Una volta selezionata la lingua e fatto clic su **Continua**, il programma di installazione passa alla schermata seguente. Abbiamo evidenziato le cose che *potreste* voler modificare e/o verificare:

![kde_install](images/kde_install.png)

1. **Tastiera** - Osservate questa opzione e assicuratevi che corrisponda al layout della tastiera che utilizzate.
2. **Ora e data** - Assicurarsi che corrisponda al proprio fuso orario.
3. **Destinazione di installazione** - È necessario fare clic su questa opzione, anche solo per accettare ciò che è già presente.
4. **Rete e Nome host** - Verificare che sia presente ciò che si desidera. Finché la rete è abilitata, è sempre possibile modificarla in seguito, se necessario.
5. **Password di root** - Procedere con l'impostazione di una password di root. Ricordate di salvarla in un luogo sicuro (gestore di password), soprattutto se non la utilizzate spesso.
6. **Creazione di un utente** - Crea sicuramente almeno un utente. Se si desidera che l'utente abbia diritti amministrativi, ricordarsi di impostare questa opzione al momento della creazione dell'utente.
7. **Iniziare l'installazione** - Una volta impostate o verificate tutte le impostazioni, fare clic su questa opzione.

Una volta eseguito il passo 7, il processo di installazione dovrebbe iniziare a installare i pacchetti, come nella schermata seguente:

![kde_install_2](images/kde_install_2.png)

Al termine dell'installazione sul disco rigido, verrà visualizzata la seguente schermata:

![kde_install_final](images/kde_install_final.png)

Procedere e fare clic su **Fine dell'installazione**.

A questo punto è necessario riavviare il sistema operativo e rimuovere il supporto di avvio. Quando il sistema operativo viene avviato per la prima volta, viene visualizzata una schermata di configurazione:

![kde_config](images/kde_config.png)

Fare clic sull'opzione **Informazioni sulla licenza** e accettare l'EULA come indicato qui:

![eula](images/eula.png)

E infine terminare la configurazione:

![kde_finish_config](images/kde_finish_config.png)

Una volta completato questo passaggio, verrà visualizzato il nome utente creato in precedenza. Inserire la password creata per l'utente e premere <kbd>INVIO</kbd>. Dovrebbe apparire una schermata di desktop KDE immacolata:

![kde_screen](images/kde_screen.png)

## Conclusione

Grazie al team di sviluppo di Rocky Linux, ci sono diverse opzioni desktop che si possono installare dalle immagini live di Rocky Linux 9.0. Per coloro che non amano il desktop GNOME predefinito, KDE è un'altra opzione e può essere facilmente installato con l'immagine live. 
