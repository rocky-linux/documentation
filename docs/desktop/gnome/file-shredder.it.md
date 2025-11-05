---
title: File Shredder - Cancellazione sicura
author: Wale Soyinka
contributors: Ganna Zhyrnova
tags:
  - gnome
  - desktop
  - security
  - |
    privacy
  - flatpack
---

## Eliminare i file in modo permanente e sicuro

Quando si elimina un file utilizzando il file manager, i dati non vengono effettivamente cancellati. Il sistema operativo contrassegna semplicemente lo spazio sul disco rigido come “disponibile”, lasciando intatti i dati originali fino a quando non vengono sovrascritti da nuovi file. Ciò significa che i file “eliminati” possono spesso essere recuperati utilizzando software specializzati.

**File Shredder** è un'utilità semplice e moderna per il desktop GNOME che risolve questo problema consentendo di eliminare i file in modo permanente e sicuro. Lo fa sovrascrivendo più volte i dati del file con rumore casuale prima di eliminarlo, rendendo praticamente impossibile il recupero.

## Installazione

Il modo consigliato per installare File Shredder su Rocky Linux è come Flatpak dal repository Flathub.

### 1. Abilitare Flathub

Se non lo si è ancora fatto, assicurarsi di avere Flatpak installato e il remote Flathub configurato sul sistema.

```bash
# Install the Flatpak package
sudo dnf install flatpak

# Add the Flathub remote repository
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
```

### 2. Installare File Shredder

Una volta abilitato Flathub, è possibile installare File Shredder con un solo comando.

!!! note NOTA "Application ID"
L'applicazione si chiama “File Shredder”, ma il suo ID tecnico su Flathub è `io.github.ADBeveridge.Raider`.

```bash
flatpak install flathub io.github.ADBeveridge.Raider
```

## Come usare File Shredder

Dopo l'installazione, avviare l'applicazione dalla panoramica delle attività di GNOME cercando “File Shredder”.

Il processo è semplice:

1. Trascina e rilascia i file o le cartelle che si desidera eliminare definitivamente direttamente nella finestra di File Shredder. In alternativa, fare click su **"Add Files..."** o **"Add Folder..."**.
2. I file appariranno in un elenco. Esaminare attentamente questo elenco.
3. Quando sei assolutamente certo di voler distruggere definitivamente i file, fai clic sul pulsante **Distruggi**.

!!! warning "Questa azione è irreversibile"
Non c'è nessun bottone di annullamento. Una volta che un file viene distrutto, viene eliminato in modo permanente. Controlla attentamente i file che hai aggiunto prima di fare clic sul pulsante Distruggi.

## Una considerazione importante per SSD

Sebbene File Shredder sia altamente efficace sui tradizionali dischi rigidi magnetici (HDD), la sua efficacia sui moderni dischi a stato solido (SSD) presenta alcune limitazioni.

Gli SSD utilizzano meccanismi interni complessi come il livellamento dell'usura e la raccolta dei dati inutilizzati per gestire i dati e prolungare la durata dell'unità. Questi meccanismi fanno sì che sia l'unità stessa, e non il sistema operativo, a decidere dove scrivere fisicamente i dati. Uno strumento software come File Shredder non può forzare un SSD a sovrascrivere un blocco fisico specifico di dati.

Pertanto, sebbene l'utilizzo di File Shredder su un SSD renda il recupero dei dati significativamente più difficile rispetto a una cancellazione standard, **non è possibile garantire** che tutte le tracce dei dati siano state fisicamente cancellate dalle celle di memoria dell'unità. Per garantire il massimo livello di sicurezza dei dati su un SSD, l'approccio consigliato è quello di utilizzare la crittografia completa del disco (come LUKS, che può essere configurata durante l'installazione di Rocky Linux).

File Shredder rimane uno strumento prezioso per migliorare la privacy dei dati, in particolare su HDD, e fornisce un solido livello di sicurezza per la maggior parte dei casi d'uso.
