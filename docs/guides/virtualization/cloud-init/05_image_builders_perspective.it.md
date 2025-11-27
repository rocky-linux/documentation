---
title: 5. La prospettiva del image builder
author: Wale Soyinka
contributors: Steven Spencer
tags:
  - cloud-init
  - rocky linux
  - cloud
  - automation
  - image-building
---

## Impostazioni predefinite e generalizzazione

Finora, il nostro percorso si è concentrato sulla configurazione delle singole istanze all'avvio utilizzando `user-data`. In questo capitolo, cambieremo prospettiva e assumeremo quella di un **image builder**. Cioè qualcuno che crea e gestisce le “golden images” che fungono da modelli per altre macchine virtuali.

Il nostro obiettivo è quello di creare una nuova immagine personalizzata con le nostre policies ed impostazioni predefinite integrate. Ciò comporta due passaggi fondamentali:

1. **Personalizzazione delle impostazioni predefinite a livello di sistema:** Modifica della configurazione `cloud-init` _all'interno dell'immagine stessa_.
2. **Generalizzazione dell'immagine:** utilizzo di strumenti quali `cloud-init clean` e `virt-sysprep` per rimuovere tutti i dati specifici della macchina, preparando l'immagine per la clonazione.

## 1) Configurazione del laboratorio di personalizzazione

Per iniziare, abbiamo bisogno di un'istanza funzionante dell'immagine cloud di base da poter modificare. Avvieremo questa VM _senza_ fornire alcun `dato utente` per ottenere un sistema pulito.

```bash
# Create un'immagine disco per il nostro nuovo modello
qemu-img create -f qcow2 -o size=10G golden-image-template.qcow2

# Avviate l'immagine di base utilizzando virt-install
virt-install --name golden-image-builder \
--memory 2048 --vcpus 2 \
--disk path=golden-image-template.qcow2,format=qcow2 \
--cloud-init none --os-variant rockylinux10 --import

# Connettersi alla console ed effettuare il login come utente predefinito “rocky”.
virsh console golden-image-builder
```

## 2. Configurazione a livello di sistema con `cloud.cfg.d`

All'interno della nostra VM in esecuzione, ora possiamo personalizzare la configurazione `cloud-init` a livello di sistema. Non modificare mai direttamente il file master, `/etc/cloud/cloud.cfg`. La posizione corretta e sicura per gli aggiornamenti delle personalizzazioni è la directory `/etc/cloud/cloud.cfg.d/`. `cloud-init` legge tutti i file `.cfg` qui presenti in ordine alfabetico dopo il file principale `cloud.cfg`, consentendo di sovrascrivere le impostazioni predefinite.

### Hands-on: impostazione dei valori predefiniti della golden image

Applichiamo una policy sul nostro golden image: disabiliteremo l'autenticazione tramite password, imposteremo un nuovo utente predefinito e garantiremo che sia sempre installato un set di pacchetti di base.

1. **Creare un file di configurazione personalizzato:** dall'interno della VM, creare `/etc/cloud/cloud.cfg.d/99-custom-defaults.cfg`. Il prefisso “99-” assicura che venga letto per ultimo.

    ```bash
    sudo cat <<EOF > /etc/cloud/cloud.cfg.d/99-custom-defaults.cfg
    # Golden Image Customizations
    
    # Define a new default user named 'admin'
    system_info:
      default_user:
        name: admin
        sudo: ["ALL=(ALL) NOPASSWD:ALL"]
        shell: /bin/bash
    
    # Enforce key-based SSH authentication
    ssh_pwauth: false
    
    # Ensure a baseline of packages is always installed
    packages:
      - htop
      - vim-enhanced
    EOF
    ```

!!! tip "Disabilitazione di moduli specifici"

    Una tecnica per una sicurezza efficace consiste nel disabilitare completamente determinati moduli `cloud-init`. Ad esempio, per impedire a qualsiasi utente di utilizzare `runcmd`, è possibile aggiungere quanto segue al file `.cfg` personalizzato. In questo modo si indica a `cloud-init` di eseguire un elenco vuoto di moduli durante la fase finale.
    
    `yaml     cloud_final_modules: []     `

## 3. Generalizzare l'immagine

La nostra VM ora contiene la nostra configurazione personalizzata, ma contiene anche identificatori univoci della macchina (come `/etc/machine-id`) e chiavi host SSH. Prima di poterlo clonare, dobbiamo rimuovere questi dati attraverso un processo chiamato **generalizzazione**.

### Metodo 1: `cloud-init clean` (all'interno della VM)

`cloud-init` fornisce un comando integrato per questo scopo.

1. **Eseguire `cloud-init clean`:** dall'interno della VM, eseguire il seguente comando per rimuovere i dati specifici dell'istanza.

    ```bash
    sudo cloud-init clean --logs --seed
    ```

       !!! note "Riguardo a `cloud-init clean --seed`"

        ```
         Questo comando rimuove il seed univoco utilizzato da `cloud-init` per identificare l'istanza, costringendola a eseguire il processo da zero al successivo avvio. **Non** rimuove le configurazioni personalizzate in `/etc/cloud/cloud.cfg.d/`. Questo passaggio è essenziale per creare un modello veramente generico.
        ```

2. **Spegnimento immediato:** dopo la pulizia, spegnere immediatamente la VM.

    ```bash
    sudo poweroff
    ```

### Metodo 2: `virt-sysprep` (dall'host)

Uno strumento ancora più completo e conforme agli standard del settore è `virt-sysprep`. È possibile eseguire questa operazione dal computer host sul disco della macchina virtuale spenta. Esegue tutte le azioni di `cloud-init clean` e molto altro ancora, come cancellare la cronologia dei comandi, rimuovere i file temporanei e reimpostare i file di log.

1. **Assicurarsi che la VM sia spenta.**

2. **Eseguire `virt-sysprep` dal vostro host:**

    ```bash
    sudo virt-sysprep -a golden-image-template.qcow2
    ```

Una volta completato il processo di generalizzazione, il file su disco (`golden-image-template.qcow2`) diveterà la vostra nuova nuova golden image.

!!! note "Convenzioni di denominazione delle golden image"

    È buona norma assegnare alle golden image nomi descrittivi che includano il sistema operativo e il numero di versione, ad esempio `rocky10-base-v1.0.qcow2`. Ciò facilita il controllo delle versioni e la gestione dell'infrastruttura.

## 4. Verificare la golden image

Proviamo la nostra nuova immagine avviando una nuova istanza _da_ essa senza alcun `user-data`.

1. **Creare un nuovo VM disk dalla nostra golden image:**

    ```bash
    qemu-img create -f qcow2 -F qcow2 -b golden-image-template.qcow2 test-instance.qcow2
    ```

2. **Avviare l'istanza di prova:**

    ```bash
    virt-install --name golden-image-test --cloud-init none ...
    ```

3. **Verifica:** Connettersi alla console (`virsh console golden-image-test`). La richiesta di accesso dovrebbe essere per l'utente `admin`, non per `rocky`. Una volta effettuato l'accesso, è anche possibile verificare l'installazione di `htop` con (`rpm -q htop`). Questo conferma che le impostazioni predefinite integrate funzionano correttamente.

## Il passo successivo

Ora avete imparato come creare modelli standardizzati integrando le impostazioni predefinite nella configurazione di sistema di `cloud-init` e generalizzandoli correttamente per la clonazione. Nel prossimo capitolo tratteremo le competenze essenziali per la risoluzione dei problemi quando `cloud-init` non funziona come previsto.
