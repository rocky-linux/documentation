---
title: Introduzione
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 9.4
tags:
  - lxd
  - incus
  - enterprise
---

# Creare un server Incus

## Lo stato di Incus su Rocky Linux

Quasi un anno fa, nella mailing list di lxc-users è stato pubblicato il seguente annuncio:

> Canonical, il creatore e principale collaboratore del progetto LXD, ha deciso che, dopo oltre 8 anni di appartenenza alla comunità di Linux Containers, il progetto sarebbe stato gestito meglio direttamente nell'ambito dei progetti di Canonical.

Uno dei fattori decisivi sono state le dimissioni di alcuni sviluppatori principali di LXD. Questi sviluppatori hanno poi biforcato LXD in Incus, annunciando il fork nell'agosto del 2023. Una versione di rilascio (0.1) è stata rilasciata nell'ottobre 2023, e da allora gli sviluppatori hanno rapidamente sviluppato questa versione con rilasci successivi fino alla 0.7 (nel marzo 2024). Il rilascio della versione di supporto a lungo termine (6.0 LTS) ha seguito il rilascio della versione 0.7. La versione attuale è la 6.5.

Durante tutto il processo, si ritieneva che Canonical continasse a mantenere i collegamenti alle immagini dei container forniti da Linux Containers. Tuttavia, una [modifica della licenza](https://stgraber.org/2023/12/12/lxd-now-re-licensed-and-under-a-cla/) ha reso impossibile a Linux Containers di continuare a offrire le immagini dei container all'interno di LXD. Questo significa che LXD avrà delle immagini container, ma non saranno quelle che ci si aspetta. Linux Containers continua a ospitare e supportare le proprie immagini se si utilizza Incus.

Questo documento è una conversione del [libro LXD](../lxd_server/00-toc.md) in Incus. Dopo la creazione di un repository da parte del dell'infrastruttura co-leader del progetto Rocky Linux [Neil Hanlon](https://wiki.rockylinux.org/team/infrastructure/), è possibile installare Incus prima della sua inclusione nel repository EPEL (Extra Packages for Enterprise Linux).

!!! warning "Incus server non è disponibile su Rocky Linux 8"

```
L'installazione del server Incus è disponibile solo per Rocky Linux 9.x e attualmente è testata su Rocky Linux 9.4. Se si ha bisogno di qualcosa che funzioni su Rocky Linux 8.x, usare la [procedura LXD già citata](../lxd_server/00-toc.md).
```

## Introduzione

Una migliore descrizione di Incus è presente sul [sito ufficiale](https://linuxcontainers.org/incus/), ma può essere considerato come un sistema di container che offre i vantaggi dei server virtuali in un container.

È molto potente e, con l'hardware e la configurazione giusta, è possibile creare molte istanze di server su un singolo componente hardware. Se lo si abbina a un server snapshot, si ha anche una serie di container che possono essere avviati quasi immediatamente se il server primario si guasta.

!!! warning "Questo non è un backup"

```
Non si deve pensare a questo come a un backup tradizionale. È ancora necessario un sistema di backup tradizionale, come [rsnapshot](../../guides/backup/rsnapshot_backup.md).
```

La curva di apprendimento di Incus può essere impegantiva, ma questo libro cercherà di fornire le conoscenze necessarie a distribuire e utilizzare Incus su Rocky Linux.

Per coloro che desiderano utilizzare Incus come ambiente di prova su notebook o workstation, vedere [Appendice A: Configurazione della workstation] (30-appendix_a.md).

## Prerequisiti e presupposti

- Un server Rocky Linux, ben configurato. Considerare un disco rigido separato per lo spazio disco ZFS (è necessario se si usa ZFS) in un ambiente di produzione. E sì, il presupposto è un server bare metal, non un VPS (Virtual Private Server).
- Si tratta di un argomento avanzato, ma non troppo difficile da comprendere. Se si seguono queste istruzioni fin dall'inizio, si dovrebbe avere successo. Detto questo, esserea a conoscenza di alcune nozioni di base sulla gestione dei container è molto utile.
- Comfort con la riga di comando della macchina (o delle macchine) e dimestichezza con l'editor a riga di comando. (In questi esempi si utilizza _vi_, ma è possibile sostituirlo con il proprio editor preferito)
- Per la maggior parte di questi processi è necessario essere un utente non privilegiato. Per le prime fasi di configurazione, è necessario essere l'utente root o poter fare `sudo` per diventarlo. In tutti questi capitoli si assume che l'utente non privilegiato sia “incusadmin”. L'account utente dovrà essere creato più avanti nel processo.
- Per ZFS, assicurarsi che l'avvio sicuro UEFI NON sia abilitato. Altrimenti, si finirà per dover firmare il modulo ZFS per farlo caricare.
- Utilizzo di container basati su Rocky Linux per la maggior parte del tempo

!!! info "Informazione"

```
L'autore include una metodologia per l'utilizzo di un filesystem ZFS. Si noti che il progetto Incus raccomanda BTRFS come file system per un server Incus. (BTRFS, tuttavia, non è disponibile su Rocky Linux 9.4. Fino a quando non sarà approvato dall'upstream e rilasciato, il file system BTRFS non sarà disponibile. Finché non sarà approvato dall'upstream e rilasciato, l'unica opzione è utilizzare ZFS o un altro filesystem incluso. Per saperne di più sulle opzioni del filesystem di Incus, vedere [il documento ufficiale del progetto qui] (https://linuxcontainers.org/incus/docs/main/reference/storage_dir/)  
```

## Sinossi

- Il **Capitolo 1: Installazione e configurazione** si occupa dell'installazione del server primario. In generale, il modo più corretto di utilizzare Incus in produzione è quello di avere un server primario e uno snapshot.
- Il **Capitolo 2: Configurazione di ZFS** tratta l'impostazione e la configurazione di ZFS. ZFS è un gestore di volumi logici e un file system open source creato da Sun Microsystems, originariamente per il suo sistema operativo Solaris.
- Il **Capitolo 3: Inizializzazione di Incus e Setup Utente** tratta l'inizializzazione e le opzioni di base, nonché l'impostazione dell'utente non privilegiato che verrà utilizzato per la maggior parte del resto del processo.
- **Capitolo 4: Impostazione del firewall** Ha le opzioni di configurazione di `firewalld`
- Il **Capitolo 5: Impostazione e gestione delle immagini** descrive il processo di installazione delle immagini di sistema operativo in un container e la loro configurazione.
- Il **Capitolo 6: Profili** si occupa dell'aggiunta di profili e della loro applicazione ai container e tratta principalmente di `macvlan` e della sua funzione per l'indirizzamento IP sulla LAN o sulla WAN.
- Il **Capitolo 7: Opzioni di configurazione dei contenitori** tratta brevemente alcune opzioni di configurazione di base per i container e offre alcuni vantaggi ed effetti collaterali per la modifica delle opzioni di configurazione.
- Il **Capitolo 8: Istantanee dei container** illustra in dettaglio il processo di snapshot dei container sul server primario.
- Il **Capitolo 9: Il server snapshot** tratta l'impostazione e la configurazione del server snapshot e come creare una relazione simbiotica tra il server primario e il server snapshot.
- Il **Capitolo 10: Automatizzazione delle shapshots** tratta l'automazione della creazione di snapshot e il popolamento del server snapshot con le snapshots.
- **Appendice A: Impostazione della stazione di lavoro** non fa tecnicamente parte della documentazione del server di produzione. Offre una soluzione per chi vuole creare un ambiente di containers Incus sui propri notebook o workstation.

## Conclusioni

Questi capitoli consentono di configurare efficacemente una coppia di server Incus primario e snapshot enterprise-level. Nel corso del processo, imparerete molto su Incus. Siate consapevoli che c'è ancora molto da imparare e considerate questi documenti come un punto di partenza.

Il vantaggio più importate di Incus è la sua economicità d'uso su un server, consente di avviare rapidamente le installazioni del sistema operativo e permette di eseguire molti server applicativi standalone su una singola macchina, sfruttando al massimo l'hardware disponibile.
