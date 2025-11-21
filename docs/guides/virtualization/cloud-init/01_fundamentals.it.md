---
title: 1. cloud-init fundamentals
author: Wale Soyinka
contributors: Steven Spencer
tags:
  - cloud-init
  - cloud
  - automation
---

## L'architettura del primo boot

Questa guida esplora `cloud-init`, lo strumento essenziale per automatizzare la configurazione iniziale delle istanze cloud di Rocky Linux 10. Quando parliamo di implementazione di server nel cloud, o anche nel vostro laboratorio di virtualizzazione locale, spesso diamo per scontata la transizione quasi istantanea da un'immagine vuota a una macchina completamente funzionante e pronta per la rete. Questa impresa di alchimia digitale è compiuta da un unico, instancabile strumento: cloud-init.

## 1. Il dilemma del bootstrapping

### Il problema: quando un server si riattiva alla cieca

Immagina un'immagine generica Rocky Linux 10 QCOW2. È una copia perfetta, immacolata, ignara della sua destinazione finale. Non conosce il proprio nome host, quale account utente dovrebbe avere accesso SSH, in quale fuso orario si trova o se necessita di Apache o NGINX.

Se si stesse implementando hardware fisico, un amministratore di sistema configurerebbe manualmente tutti questi parametri. Ma nel cloud, i server sono effimeri, scalabili verso l'alto e verso il basso a migliaia. Abbiamo bisogno di un meccanismo standardizzato, generico e affidabile per inserire il contesto necessario in quell'immagine vuota al primo avvio.

Questo è il problema che **cloud-init** risolve.

### Cosa è cloud-init

In parole povere, cloud-init è il pacchetto multi-distribuzione standard del settore che gestisce l'inizializzazione iniziale delle istanze cloud. È il servizio principale responsabile di prendere un'immagine generica (come quella che stiamo utilizzando) ed eseguire le attività di configurazione necessarie per trasformarla in un server unico e pronto per la produzione.

Si trova letteralmente al centro del processo di provisioning, interpretando i **metadati** e le **istruzioni definite dall'utente** per configurare il sistema. Senza di esso, la tua istanza cloud è solo un kernel Linux ben compilato con una crisi di identità.

### L'ecosistema di cloud-init

cloud-init è un consumatore, non un creatore. Si affida alla piattaforma cloud sottostante (AWS, Azure, GCP, OpenStack o strumenti locali come libvirt) per fornire le informazioni di configurazione.

- I **fornitori di servizi cloud** espongono i dati tramite una _fonte dati_ specializzata (spesso un endpoint HTTP locale, un'etichetta disco specifica o un parametro del kernel).
- **cloud-init** rileva questa fonte di dati, legge la configurazione ed esegue i passaggi di configurazione appropriati.

Questo disaccoppiamento, in cui l'immagine è generica e la configurazione viene fornita esternamente, è il genio fondamentale dell'intero modello di implementazione cloud.

## 2. Rocky Linux 10 e l'immagine cloud generica

Per questa guida utilizzeremo il file ufficiale [Rocky-10-GenericCloud-Base.latest.x86_64.qcow2](https://dl.rockylinux.org/pub/rocky/10/images/x86_64/Rocky-10-GenericCloud-Base.latest.x86_64.qcow2).

### L'immagine target: un cavallo di battaglia precablato

Questa immagine è speciale perché include il pacchetto cloud-init preinstallato e abilitato. È stato _generalizzato_, il che significa che tutti gli identificatori specifici della macchina, le chiavi host SSH e i file di log sono stati eliminati. È pronto per ricevere la sua nuova identità al primo avvio.

!!! warning "Utilizzare l'Immagine Raccomandata"

    Se provi a utilizzare cloud-init su un'installazione standard di Rocky Linux (come un'installazione ISO minimale), scoprirai che non è presente di default. Utilizza l'immagine **Generic Cloud** per evitare inutili complicazioni e assicurarti che tutto funzioni esattamente come previsto. Provare a eseguire gli esercizi descritti in questa guida con altre immagini probabilmente non funzionerà e non è supportato.

### Concetti fondamentali: dati utente vs. metadati

Le informazioni di configurazione elaborate da cloud-init sono classificate in due tipi principali. Comprendere questa distinzione è fondamentale per sapere cosa è possibile controllare e cosa controlla il fornitore di servizi cloud.

Pensate come alla costruzione di una casa: i **metadati** sono l'indirizzo assegnato dal comune, mentre i **dati utente** sono il progetto che fornite per l'interior design.

| Tipo          | Origine e scopo                                                                                                                                                                                                                                       | Tipo di configurazione   |
| :------------ | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :----------------------- |
| **Meta-Data** | Fornito dalla piattaforma cloud (sola lettura). Contiene identificatori di sistema quali ID istanza, nome host (se fornito dalla piattaforma), regione e zona di disponibilità. | _Contesto di sistema_    |
| **User-Data** | Fornito dall'utente. Questo è il tuo set di istruzioni: blocchi di configurazione YAML o script di shell che personalizzano il server.                                                                | _Istruzioni dell'utente_ |

I **metadati** indicano a cloud-init _dove_ si trova. **User-Data** indica a cloud-init _cosa fare_.

Ci concentreremo principalmente sulla creazione di file **User-Data** efficaci, che in genere iniziano con l'intestazione YAML obbligatoria:

```yaml
#cloud-config
```

## 3. Il ciclo di vita: le quattro fasi di inizializzazione di cloud-init

cloud-init non si limita a eseguire uno script e chiudersi, ma esegue una serie di fasi altamente strutturate che si allineano con il processo di avvio del server. Questo approccio metodico garantisce che le dipendenze siano soddisfatte (ad esempio, la rete viene configurata prima che i pacchetti vengano scaricati).

Comprendere questo ciclo di vita è fondamentale per il debug e per sapere con precisione quando vengono eseguite le istruzioni personalizzate.

| Stage         | Tempistiche e descrizione                                                                                                                                                                                                  | Azioni chiave/Moduli                                                                                                                                                                                       |
| :------------ | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Generator** | Viene eseguito all'inizio del processo di avvio. Imposta le directory interne ed esegue controlli di configurazione di base.                                                               | Configurazione interna, inizializzazione del registro.                                                                                                                                     |
| **Local**     | Funziona prima che la rete sia necessariamente attiva. Elabora fonti di dati locali come CD-ROM o unità virtuali (che useremo nel nostro laboratorio).                  | Impostazione del nome host dai dati locali, configurazione iniziale del disco.                                                                                                             |
| **Network**   | Viene eseguito una volta che la rete è completamente configurata e operativa. Interroga fonti di dati basate sulla rete (come l'API del fornitore di servizi cloud).    | Configura le interfacce di rete, recupera le chiavi dai metadati di rete.                                                                                                                  |
| **Final**     | Ultimo in esecuzione. È qui che avviene la maggior parte della configurazione definita dall'utente, poiché tutti i prerequisiti (utenti, rete, dischi) sono ora pronti. | Installazione di pacchetti, esecuzione di script personalizzati (runcmd), scrittura di file (write_files), pulizia del sistema. |

!!! tip "Controllare i log"

    Durante la risoluzione dei problemi, controllare sempre `/var/log/cloud-init.log`. Questo file è il rapporto diagnostico del processo `cloud-init`, che mostra esattamente quando ogni fase è iniziata e terminata e quali moduli sono stati eseguiti durante il processo. Se lo script non è stato eseguito, il log indicherà esattamente il motivo e quale fase ha avuto esito negativo.

## Cosa succederà

Ora che avete compreso l'architettura fondamentale di `cloud-init` — il “cosa” e il “perché”, i diversi tipi di dati e le fasi di avvio — siete pronti per passare dalla teoria alla pratica. Il prossimo capitolo ti guiderà attraverso il tuo primo esercizio pratico: avviare l'immagine cloud di Rocky Linux 10 ed eseguire una semplice personalizzazione reale.
