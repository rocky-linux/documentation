---
title: DISA STIG Su Rocky Linux 8 - Parte 1
author: Scott Shinn
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 8.6
tags:
  - DISA
  - STIG
  - security
  - enterprise
---

# HOWTO: STIG Rocky Linux 8 Fast - Part 1

## Terminologia di riferimento

* DISA - Agenzia per i Sistemi Informativi della Difesa
* RHEL8 - Red Hat Enterprise Linux 8
* STIG - Guida all'Implementazione della Tecnica Sicura
* SCAP - Protocollo di Automazione Sicura dei Contenuti
* DoD - Dipartimento della Difesa

## Introduzione

In questa guida verrà illustrato come applicare la [DISA STIG per RHEL8](https://www.stigviewer.com/stig/red_hat_enterprise_linux_8/) per una nuova installazione di Rocky Linux. Come serie in più parti, tratteremo anche come testare la conformità STIG, adattare le impostazioni STIG e applicare altri contenuti STIG in questo ambiente.

Rocky Linux è un derivato bug per bug di RHEL e come tale il contenuto pubblicato per il DISA RHEL8 STIG è in parità per entrambi i sistemi operativi.  Una notizia ancora migliore è che l'applicazione delle impostazioni STIG è integrata nel programma di installazione di Rocky Linux 8 anaconda, sotto la voce Profili di Sicurezza.  Il tutto è gestito da uno strumento chiamato [OpenSCAP](https://www.open-scap.org/), che consente sia di configurare il sistema in modo che sia conforme alla DISA STIG (velocemente!), sia di testare la conformità del sistema dopo l'installazione.

Lo farò su una macchina virtuale nel mio ambiente, ma tutto ciò che è riportato qui si applica esattamente allo stesso modo su una macchina reale.

### Passo 1: Creare la Macchina Virtuale

* Memoria 2G
* Disco 30G
* 1 core

![Macchina Virtuale](images/disa_stig_pt1_img1.jpg)

### Passo 2: Scarica l'ISO Rocky Linux 8 DVD

[Scarica Rocky Linux DVD](https://download.rockylinux.org/pub/rocky/8/isos/x86_64/Rocky-8.6-x86_64-dvd1.iso).  **Nota:** La ISO minimale non contiene il contenuto necessario per applicare la STIG per Rocky Linux 8; è necessario utilizzare il DVD o un'installazione di rete.

![Scarica Rocky](images/disa_stig_pt1_img2.jpg)

### Passo 3: Avviare l'Installatore

![Avvia L'Installatore](images/disa_stig_pt1_img3.jpg)

### Passo 4: PRIMO Selezionare il Partizionamento

Questo è probabilmente il passo più complicato dell'installazione, e un requisito per essere conforme al STIG. È necessario partizionare il filesystem del sistema operativo in un modo che probabilmente creerà nuovi problemi. In altre parole: Avrai bisogno di sapere esattamente quali sono i tuoi requisiti di archiviazione.

!!! tip "Pro-Tip"

    Linux consente di ridimensionare i filesystem, di cui parleremo in un altro articolo. Basti pensare che questo è uno dei problemi più gravi dell'applicazione di DISA STIG su bare iron, che spesso richiede re-installazioni complete per essere risolto, quindi è necessario sovrastimare le dimensioni necessarie.

![Partizionamento](images/disa_stig_pt1_img4.jpg)

* Seleziona "Custom e poi "Done"

![Partizionamento Personalizzato](images/disa_stig_pt1_img5.jpg)

* Inizia ad Aggiungere Partizioni

![Aggiungi Partizioni](images/disa_stig_pt1_img6.jpg)

Schema di partizionamento DISA STIG per un disco 30G. Il mio caso d'uso è un semplice server web:

* / (10G)
* /boot (500m)
* /var (10G)
* /var/log (4G)
* /var/log/audit (1G)
* /home (1G)
* /tmp (1G)
* /var/tmp (1G)
* Swap (2G)

!!! tip "Pro-Tip"

     Configurate / per ultimo e assegnategli un numero molto alto; in questo modo tutto lo spazio libero del disco rimarrà su / e non dovrete fare alcun calcolo.

![Partizione Slash](images/disa_stig_pt1_img7.jpg)

!!! tip "Pro-Tip"

    Riprendendo il consiglio precedente: SOVRASTIMARE i filesystem, anche se in seguito dovrete farli espandere di nuovo.

* Clicca su "Done" e "Accept Changes"

![Conferma Partizionamento](images/disa_stig_pt1_img8.jpg)

![Accetta Modifiche](images/disa_stig_pt1_img9.jpg)

### Passo 5: Configura il software per il tuo ambiente: Installazione del Server senza una GUI.

Questo avrà importanza in **Fase 6**, quindi se si utilizza un'interfaccia utente o una configurazione di workstation il profilo di sicurezza sarà diverso.

![Selezione Software](images/disa_stig_pt1_img10.jpg)

### Passo 6: Selezionare Il Profilo Di Sicurezza

Questo configurerà una serie di impostazioni di sicurezza sul sistema in base al criterio selezionato, sfruttando il framework SCAP. Modificherà i pacchetti selezionati nella **Fase 5**, aggiungendo o rimuovendo i componenti necessari.  Se _è stata_ selezionata un'installazione con interfaccia grafica in **Fase 5** e si utilizza STIG non-GUI in questa fase, l'interfaccia grafica verrà rimossa. Regolatevi di conseguenza!

![Profilo Di Sicurezza](images/disa_stig_pt1_img11.jpg)

Selezionare DISA STIG per Red Hat Enterprise Linux 8:

![DISA STIG](images/disa_stig_pt1_img12.jpg)

Fare clic su "Select Profile" e prendere nota delle modifiche che verranno apportate al sistema. In questo modo si impostano le opzioni sui punti di montaggio, si aggiungono/rimuovono le applicazioni e si apportano altre modifiche alla configurazione:

![Seleziona Profile_A](images/disa_stig_pt1_img13.jpg)

![Seleziona_Profilo_B](images/disa_stig_pt1_img14.jpg)

### Fase 7: fare clic su "Done" e continuare con la Configurazione Finale

![Completare Il Profilo](images/disa_stig_pt1_img15.jpg)

### Passo 8: Creare un account utente e impostarlo come amministratore

Nelle esercitazioni successive potremo unire il tutto a una configurazione aziendale FreeIPA. Per il momento, lo tratteremo come un documento a sé stante. Notate che non sto impostando una password di root, piuttosto diamo l'accesso al nostro utente predefinito `sudo`.

![Configurazione Utente](images/disa_stig_pt1_img16.jpg)

### Passo 9: Fare clic su "Done", e poi su "Begin Installation"

![Inizia L'Installazione](images/disa_stig_pt1_img17.jpg)

### Passo 10: Una volta completata l'installazione, fate clic su "Reboot System"

![Reboot](images/disa_stig_pt1_img18.jpg)

### Fase 11: Accedere al sistema Rocky Linux 8 STIG!

![Avvertimento DoD](images/disa_stig_pt1_img19.jpg)

Se tutto è andato bene, si dovrebbe vedere il banner di avviso predefinito del DoD.

![Schermo Finale](images/disa_stig_pt1_img20.jpg)

## Informazioni Sull'Autore

Scott Shinn è il CTO per Atomicorp e fa parte del team Rocky Linux Security. Dal 1995 si occupa di sistemi informativi federali presso la Casa Bianca, il Dipartimento della Difesa e l'Intelligence Community. Parte di questo è stata la creazione degli STIG e l'obbligo di usarli, e mi dispiace molto per questo.
