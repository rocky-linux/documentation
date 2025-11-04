---
title: Server LXD
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 8.8, 9.2
tags:
  - lxd
  - enterprise
---

# Creare un server LXD completo

!!! warning Attenzione "LXD status"

    Si noti che LXD non contiene immagini attuali di Rocky Linux 10, né la maggior parte, se non tutte, le altre immagini clone di RHEL. Ciò è probabilmente dovuto alle modifiche alle licenze che hanno impedito al progetto Linux Containers di contribuire con immagini a LXD. (vedi le altre note sotto). Ciò significa che se si desidera una piattaforma containerizzata moderna, basata sullo sviluppo originale di LXD e con il contributo di molti degli sviluppatori originali, la soluzione migliore è passare a [Incus](../incus_server/00-toc.md).

!!! info "Informazione"

    Questa procedura dovrebbe funzionare per Rocky Linux 8.x o 9.x. Se cercate un'implementazione moderna di questo progetto degli ex sviluppatori di LXD, ma disponibile solo per Rocky Linux 9.x, date un'occhiata a [il libro di Incus Server] (../incus_server/00-toc.md).

!!! info "Cosa è successo al progetto LXD"

    Più di un anno fa, nella mailing list lxc-users è stato pubblicato il seguente annuncio:
    
    > Canonical, the creator and main contributor of the LXD project has decided that after over eight years as part of the Linux Containers community, the project would now be better served directly under Canonical’s own set of projects.
    
    Uno dei fattori decisivi è stata le dimissioni di diversi sviluppatori principali da LXD, che poi hanno creato un fork di LXD chiamato Incus nell'agosto 2023. Una versione di rilascio (0.1) è stata rilasciata nell'ottobre 2023, e da allora gli sviluppatori hanno rapidamente sviluppato questa versione con rilasci successivi fino alla 0.7 (marzo 2024). Dopo la 0.7 è arrivata la versione di supporto a lungo termine, la 6.0 LTS, il 4 aprile 2024, e ora la 6.4 LTS (da settembre 2024).
    
    Durante tutto il processo, si pensava che Cannonical avrebbe continuato a mantenere i collegamenti alle immagini dei container fornite da Linux Containers, ma a causa di un [cambio di licenza](https://stgraber.org/2023/12/12/lxd-now-re-licensed-and-under-a-cla/) è diventato impossibile per Linux Containers continuare a offrire le immagini dei container all'interno di LXD. Tuttavia, a causa di un [cambio di licenza](https://stgraber.org/2023/12/12/lxd-now-re-licensed-and-under-a-cla/), è diventato impossibile per Linux Containers continuare a offrire le immagini dei container all'interno di LXD. Sebbene Linux Containers non sia più in grado di fornire immagini container a LXD, il progetto LXD ha creato alcuni container, compresi quelli per Rocky Linux. 
    
    Questo documento utilizza LXD anziché Incus.

## Introduzione

LXD è descritto meglio sul sito web [ufficiale](https://documentation.ubuntu.com/lxd/en/latest/), ma consideratelo come un sistema di container che offre i vantaggi dei server virtuali in un container.

È molto potente e, con l'hardware e la configurazione giustia, è possibile creare molte istanze di server su un singolo pezzo di hardware. Se lo si abbina a un server snapshot, si ha anche una serie di container che possono essere avviati quasi immediatamente se il server primario si guasta.

(Non si deve pensare a questo come a un backup tradizionale. È comunque necessario un sistema di backup regolare di qualche tipo, ad esempio [rsnapshot](../../guides/backup/rsnapshot_backup.md) )

La curva di apprendimento di LXD può essere un po' ripida, ma questo libro cercherà di fornirvi un bagaglio di conoscenze a portata di mano, per aiutarvi a distribuire e utilizzare LXD su Rocky Linux.

Per coloro che desiderano utilizzare LXD come ambiente di laboratorio sui propri notebook o workstation, vedere l'[Appendice A: Configurazione della workstation](30-appendix_a.md).

## Prerequisiti e presupposti

* Un server Linux Rocky, ben configurato. Considerare un disco rigido separato per lo spazio disco ZFS (è necessario se si usa ZFS) in un ambiente di produzione. E sì, il presupposto è un server bare metal, non un VPS (Virtual Private Server).
* Si tratta di un argomento avanzato, ma non troppo difficile da comprendere. Se si seguono queste istruzioni fin dall'inizio, si dovrebbe avere successo. Detto questo, la conoscenza di alcune nozioni di base sulla gestione dei container è molto utile.
* Comfort dalla riga di comando sulla/e macchina/e e dimestichezza con l'editor della riga di comando. (In questi esempi si utilizza _vi_, ma è possibile sostituirlo con il proprio editor preferito.)
* Per la maggior parte di questi processi è necessario essere un utente non privilegiato. Per le prime fasi di configurazione, è necessario essere l'utente root o essere in grado di usare `sudo` per diventarlo. In tutti questi capitoli si assume che l'utente non privilegiato sia "lxdadmin". L'account utente dovrà essere creato più avanti nel processo.
* Per ZFS, assicurarsi che il UEFI secure boot NON sia abilitato. Altrimenti, si finirà per dover firmare il modulo ZFS per farlo caricare.
* Utilizzo di container basati su Rocky Linux per la maggior parte del tempo

## Sinossi

* Il **Capitolo 1: Installazione e configurazione** tratta l'installazione del server primario. In generale, il modo corretto di utilizzare LXD in produzione è quello di avere un server primario e un server snapshot.
* Il **Capitolo 2: Configurazione di ZFS** tratta l'impostazione e la configurazione di ZFS. ZFS è un gestore di volumi logici e un file system open source creato da Sun Microsystems, originariamente per il suo sistema operativo Solaris.
* Il **Capitolo 3: Inizializzazione di LXD e configurazione dell'utente** si occupa dell'inizializzazione di base e delle opzioni, nonché della configurazione dell'utente non privilegiato che verrà utilizzato per la maggior parte del resto del processo
* **Capitolo 4: Impostazione del firewall** Ha le opzioni di configurazione di `firewalld`
* Il **capitolo 5: Impostazione e gestione delle immagini** descrive il processo di installazione delle immagini del sistema operativo in un contenitore e la loro configurazione
* Il **Capitolo 6: Profili** si occupa dell'aggiunta di profili e della loro applicazione ai container, in particolare di macvlan e della sua importanza per l'indirizzamento IP sulla LAN o sulla WAN
* Il **capitolo 7: Opzioni di configurazione dei contenitori** copre brevemente alcune delle opzioni di configurazione di base per i contenitori e offre alcuni vantaggi ed effetti collaterali per la modifica delle opzioni di configurazione
* Il **capitolo 8: Istantanee dei contenitori** illustra in dettaglio il processo di istantanea dei contenitori sul server primario
* Il **capitolo 9: Il server snapshot** tratta l'impostazione e la configurazione del server snapshot e come creare una relazione simbiotica tra il server primario e il server snapshot
* Il **capitolo 10: Automatizzazione delle istantanee** tratta dell'automazione della creazione di istantanee e del popolamento del server di istantanee con le istantanee
* L'**Appendice A: Configurazione della Workstation** non fa tecnicamente parte dei documenti del server di produzione, ma offre una soluzione per chi vuole costruire un laboratorio di contenitori LXD sul proprio notebook o stazione di lavoro personale.

## Conclusioni

Questi capitoli consentono di configurare efficacemente un server LXD primario e uno snapshot di livello aziendale. Nel corso di questo processo, imparerete molto su LXD. Siate consapevoli che c'è ancora molto da imparare e considerate questi documenti come un punto di partenza.

Il vantaggio principale di LXD è che è economico da usare su un server, consente di avviare rapidamente le installazioni del sistema operativo e permette di eseguire molti server applicativi stand-alone su un singolo componente hardware, sfruttando l'hardware per il massimo utilizzo.
