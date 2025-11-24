---
title: 2. Primo contatto
author: Wale Soyinka
contributors: Ganna Zhyrnova
tags:
  - cloud-init
  - cloud
  - automation
---

## Avvio semplice con l'immagine QCOW2 di Rocky Linux 10

Nel capitolo precedente abbiamo trattato i concetti fondamentali di `cloud-init`. Ora è il momento di passare dalla teoria alla pratica. Questo capitolo è la tua  prima missione pratica: prenderai l'immagine ufficiale Rocky Linux 10 Generic Cloud, le fornirai una serie di semplici istruzioni e la guarderai configurarsi da sola al primo avvio.

## 1. Preparazione dell'ambiente

Prima di poter avviare la nostra prima istanza, dobbiamo preparare il nostro ambiente di lavoro in locale. Per questi esercizi, simuleremo un ambiente cloud utilizzando strumenti di virtualizzazione Linux standard.

### Prerequisiti: tools su host

Assicurarsi di avere i seguenti strumenti installati sul computer host. Su un host Rocky Linux, è possibile installarli con `dnf`:

```bash
sudo dnf install -y libvirt qemu-kvm virt-install genisoimage
```

- **Hypervisor di virtualizzazione:** uno strumento come KVM/QEMU o VirtualBox.
- `virt-install`: un'utility da riga di comando per il provisioning di nuove macchine virtuali.
- `genisoimage` (o `mkisofs`): uno strumento per creare un filesystem ISO9660.

### L'immagine QCOW2

Scaricare l'immagine ufficiale Rocky Linux 10 Generic Cloud.

```bash
curl -L -o Rocky-10-GenericCloud.qcow2 \
https://dl.rockylinux.org/pub/rocky/10/images/x86_64/Rocky-10-GenericCloud-Base.latest.x86_64.qcow2
```

Per conservare l'originale, crea una copia di lavoro dell'immagine per la tua VM.

```bash
cp Rocky-10-GenericCloud.qcow2 first-boot-vm.qcow2
```

!!! tip "Risparmia spazio su disco con i file di backup"

    Una copia completa dell'immagine può essere di grandi dimensioni. Per risparmiare spazio su disco, è possibile creare un _clone collegato_ che utilizza l'immagine originale come file di supporto. In questo modo si crea un file `qcow2` molto più piccolo che memorizza solo le differenze rispetto all'originale.
    
    `bash     qemu-img create -f qcow2 -F qcow2 \     -b Rocky-10-GenericCloud.qcow2 first-boot-vm.qcow2     `

## 2. Metodo 1: Il `NoCloud` datasource (ISO)

Uno dei modi più comuni per fornire dati a `cloud-init` in un ambiente locale è il `NoCloud` datasource. Questo metodo richiede l'inserimento dei file di configurazione in un CD-ROM virtuale (un file ISO) che `cloud-init` rileverà e leggerà automaticamente all'avvio.

### Creazione dei file di configurazione

1. **Crea una cartella per salvare i file di configurazione:**

    ```bash
    mkdir cloud-init-data
    ```

2. **Creare il file `user-data`:** questo file contiene le istruzioni principali. Per crearlo useremo un `cat` heredoc .

    ```bash
    cat <<EOF > cloud-init-data/user-data
    #cloud-config
    hostname: cloud-rockstar-01
    runcmd:
      - [ sh, -c, "echo 'Hello from the cloud-init Final Stage!' > /root/boot_done.txt" ]
    EOF
    ```

3. **Creare il file `meta-data`:** questo file fornisce informazioni _sul_ contesto L'`instance-id` è particolarmente importante, poiché `cloud-init` lo utilizza per determinare se è già stato eseguito su questa istanza in precedenza. La modifica dell'ID causerà il riavvio di `cloud-init`.

    ```bash
    cat <<EOF > cloud-init-data/meta-data
    {
      "instance-id": "i-first-boot-01",
      "local-hostname": "cloud-rockstar-01"
    }
    EOF
    ```

4. **Creare l'ISO:** Utilizzare `genisoimage` per comprimere i file in `config.iso`. L'etichetta del volume `-V cidata` è la chiave magica che `cloud-init` cerca.

    ```bash
    genisoimage -o config.iso -V cidata -r -J cloud-init-data
    ```

### Avvio e verifica

1. **Avvia la VM** con `virt-install`, allegando sia l'immagine della VM che il file `config.iso`.

    ```bash
    virt-install --name rocky10-iso-boot \
    --memory 2048 --vcpus 2 \
    --disk path=first-boot-vm.qcow2,format=qcow2 \
    --disk path=config.iso,device=cdrom \
    --os-variant rockylinux10 \
    --import --noautoconsole
    ```

2. **Trova l'IP e connettiti tramite SSH.** L'utente predefinito è `rocky`.

    ```bash
    virsh domifaddr rocky10-iso-boot
    ssh rocky@<IP_ADDRESS>
    ```

       !!! tip "Accedi in modo sicuro con le chiavi SSH"

        ```
         Connettersi con un utente predefinito è comodo per un rapido test di laboratorio, ma non è una pratica sicura. Nel prossimo capitolo vedremo come utilizzare `cloud-init` per inserire automaticamente la tua chiave pubblica SSH, consentendo accessi sicuri e senza password.
        ```

3. **Verifica le modifiche:** controlla il nome host e il file creato da `runcmd`.

    ```bash
    hostname
    sudo cat /root/boot_done.txt
    ```

## 3) Metodo 2: Iniezione diretta con `virt-install`

La creazione di un ISO è un metodo affidabile, ma per gli utenti di `libvirt` e `virt-install` esiste un modo molto più semplice. Il flag `--cloud-init` consente di passare direttamente `user-data`, lasciando che `virt-install` gestisca automaticamente la creazione dell'origine dati.

### `user-data` semplificato

Crea un semplice file `user-data.yml`. È anche possibile aggiungere preventivamente la chiave SSH.

```bash
cat <<EOF > user-data.yml
#cloud-config
users:
  - name: rocky
    ssh_authorized_keys:
      - <YOUR_SSH_PUBLIC_KEY>
EOF
```

### Avvio e verifica

1. **Avvia la VM** utilizzando il flag `--cloud-init`. Si noti che qui è possibile impostare direttamente il nome host.

    ```bash
    virt-install --name rocky10-direct-boot \
    --memory 2048 --vcpus 2 \
    --disk path=first-boot-vm.qcow2,format=qcow2 \
    --cloud-init user-data=user-data.yml,hostname=cloud-rockstar-02 \
    --os-variant rockylinux10 \
    --import --noautoconsole
    ```

2. **Trova l'IP e connettiti.** Se hai aggiunto la tua chiave SSH, dovresti essere in grado di connetterti senza password.

3. **Verifica il nome host.** Dovrebbe essere `cloud-rockstar-02`.

Questo metodo diretto è spesso più veloce e conveniente per lo sviluppo locale e il testing con `libvirt`.
