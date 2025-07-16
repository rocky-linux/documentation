---
title: Migrazione a Nuove Immagini Azure
author: Neil Hanlon
contributors: Steven Spencer, Ganna Zhyrnova
tags:
  - cloud
  - azure
  - microsoft azure
  - deprecation
---

!!! info “Vecchie immagini di accunt pubblicati deprecate da aprile 2024”

```
Un publishing account Microsoft è un account del marketplace Azure che consente agli sviluppatori di pubblicare le proprie offerte su Microsoft AppSource o Azure Marketplace. 
RESF fornisce immagini di macchine virtuali Rocky Linux sotto due account di pubblishing separati in Azure: un account legacy identificato come `erockyenterprisesoftwarefoundationinc1653071250513` e un account ufficiale più recente chiamato `resf`.
Le immagini pubblicate con l'account di pubblicazione legacy (`erockyenterprisesoftwarefoundationinc1653071250513`) sono state contrassegnate per l'abbandono il 23 aprile 2024, con un periodo di 180 giorni (6 mesi) prima che non possano più essere utilizzate.

Per continuare a utilizzare Rocky Linux su Azure, è necessario seguire questa guida per migrare al nuovo account di pubblicazione (`resf`) o alle nuove immagini Community Galleries.
```

# Guida alla migrazione: Transizione a nuove immagini Rocky Linux su Azure

Questa guida fornisce i passaggi dettagliati per la migrazione delle macchine virtuali (VM) Azure dalle immagini Rocky Linux deprecate alle nuove immagini con l'account editore `resf` o utilizzando le Community Galleries. Seguendo questa guida, la transizione avverrà senza problemi e con il minimo disturbo.

## Prima di iniziare

- Assicurarsi di avere un backup aggiornato della macchina virtuale. Anche se il processo di migrazione non dovrebbe avere ripercussioni sui dati, un backup è la prassi migliore per qualsiasi modifica del sistema.
- Verificare di disporre delle autorizzazioni necessarie per creare nuove macchine virtuali e gestire quelle esistenti nel proprio account Azure.

## Passo 1: Individuare le macchine virtuali esistenti

Identificare le macchine virtuali distribuite con le vecchie immagini Rocky Linux. È possibile farlo filtrando le macchine virtuali con il nome dell'account del vecchio publisher:

```text
erockyenterprisesoftwarefoundationinc1653071250513`
```

## Passo 2: preparare una nuova macchina virtuale

1. **Navigare** nel Azure Marketplace.
2. **Cercate** le nuove immagini di Rocky Linux con l'account dell'editore `resf` o accedete alle Community Galleries.
    - Attuali Link Marketplace:
        - [Rocky Linux x86_64](https://azuremarketplace.microsoft.com/en-us/marketplace/apps/resf.rockylinux-x86_64)
    - [Rocky Linux aarch64](https://azuremarketplace.microsoft.com/en-us/marketplace/apps/resf.rockylinux-aarch64)
    - Le istruzioni complete per accedere alle immagini della Community Gallery si trovano in questo [post di notizie](https://rockylinux.org/news/rocky-on-azure-community-gallery/).
3. **Selezionare** la versione di Rocky Linux desiderata e **creare una nuova VM**. Durante la configurazione, è possibile scegliere la stessa dimensione della macchina virtuale e altre configurazioni della macchina virtuale esistente per garantire la compatibilità.

## Fase 3: Trasferimento dei dati

### Opzione A: Utilizzo di dischi gestiti da Azure (consigliato per semplicità)

1. **Arrestare** la macchina virtuale esistente.
2. **Detach** il disco del sistema operativo dalla macchina virtuale esistente.
3. **Attach** il disco alla nuova macchina virtuale come disco dati.
4. **Boot** la nuova macchina virtuale. Se necessario, è possibile montare il vecchio disco OS e copiare i dati sul nuovo disco.

### Opzione B: Utilizzo di strumenti di trasferimento dei dati (per ambienti complessi o esigenze specifiche)

1. **Selezionare** uno strumento di trasferimento dati come `rsync` o Azure Blob Storage per trasferire i dati.
2. **Trasferire** i dati dalla vecchia VM alla nuova VM. Questo potrebbe includere i dati delle applicazioni, le configurazioni e i dati degli utenti.

```bash
# Esempio con comando rsync 
rsync -avzh /path/to/old_VM_data/ user@new_VM_IP:/path/to/new_VM_destination/
```

## Passo 4: riconfigurare la nuova macchina virtuale

1. **Riapplicare** alla nuova macchina virtuale tutte le configurazioni o gli adattamenti personalizzati presenti sulla vecchia macchina virtuale, assicurandosi che corrispondano alla configurazione dell'ambiente prevista.
2. **Testare** la nuova macchina virtuale per verificare che le applicazioni e i servizi funzionino come previsto.

## Fase 5: Aggiornamento dei record DNS (se applicabile)

Se si accede alla macchina virtuale con un dominio specifico, è necessario aggiornare i record DNS per puntare all'indirizzo IP della nuova macchina virtuale.

## Passo 6: Disattivazione della vecchia macchina virtuale

Dopo aver confermato che la nuova macchina virtuale funziona correttamente e aver spostato tutti i dati e le configurazioni necessarie, è possibile **deallocare ed eliminare** la vecchia macchina virtuale.

## Fasi finali

- Verificare che tutti i servizi della nuova macchina virtuale funzionino come previsto.
- Monitorare le prestazioni e lo stato di salute della nuova macchina virtuale per assicurarsi che soddisfi le proprie esigenze.

## Supporto

L'assistenza è disponibile in caso di problemi durante la migrazione o di domande. Visitare [canali di supporto Rocky Linux](https://wiki.rockylinux.org/rocky/support/) per ricevere assistenza.
