---
title: 4. Provisioning avanzato
author: Wale Soyinka
contributors: Steven Spencer
tags:
  - cloud-init
  - rocky linux
  - cloud
  - automation
  - networking
---

## Networking e multi-part payload

Nel capitolo precedente si è imparato a utilizzare i moduli principali di `cloud-init` per la gestione di utenti, pacchetti e file. Ora è possibile creare un server ben configurato in modo dichiarativo. Ora è il momento di esplorare tecniche più avanzate che ci consentano un controllo ancora maggiore sulla configurazione della vostra istanza.

Questo capitolo tratta due argomenti avanzati e molto importanti:

1. Configurazione di rete dichiarativa: come andare oltre il DHCP e definire configurazioni di rete statiche per le tue istanze.
2. Payload MIME multiparte: come combinare diversi tipi di dati utente, come script di shell e file `#cloud-config`, in un unico potente payload.

## 1) Configurazione per rete dichiarativa

Per impostazione predefinita, la configurazione della maggior parte delle immagini cloud prevede l'acquisizione di un indirizzo IP tramite DHCP. Sebbene sia comodo, molti ambienti di produzione richiedono che i server abbiano indirizzi IP statici. Il sistema di configurazione di rete `cloud-init` offre un modo dichiarativo e indipendente dalla piattaforma per gestire tutto questo.

Le specifiche delle configurazioni di rete sono contenute in un documento YAML separato dal `#cloud-config` principale. I processi `cloud-init` provengono entrambi dallo stesso file e utilizzano il separatore standard dei documenti YAML (`---`) per distinguerli.

!!! note "Come `cloud-init` applica lo stato della rete"

    Su Rocky Linux, `cloud-init` non configura direttamente le interfacce di rete. Agisce invece come un traduttore, convertendo la sua configurazione di rete in file che **NetworkManager** (il servizio di rete predefinito) è in grado di comprendere. Quindi passa il controllo a NetworkManager per applicare la configurazione. È possibile ispezionare i profili di connessione risultanti in `/etc/NetworkManager/system-connections/`.

### Esempio 1: Configurazione di un singolo IP statico

In questo esercizio configureremo la macchina virtuale con un indirizzo IP statico, un gateway predefinito e server DNS personalizzati.

1. **Creare `user-data.yml`:**

   Questo file contiene due documenti YAML distinti, separati da `---`. Il primo è il `#cloud-config` standard. Il secondo definisce lo stato della rete.

    ```bash
    cat <<EOF > user-data.yml
    #cloud-config
    # Possiamo comunque includere i moduli standard.
    # Installiamo uno strumento per la risoluzione dei problemi di rete.
    packages:
      - traceroute
    
    ---
    
    # Questo secondo documento definisce la configurazione di rete.
    network:
      version: 2
      ethernets:
        eth0:
          dhcp4: no
          addresses:
            - 192.168.122.100/24
          gateway4: 192.168.122.1
          nameservers:
            addresses: [8.8.8.8, 8.8.4.4]
    EOF
    ```

2. **Spiegazione delle Key directives:**

   - `network:`: Chiave di primo livello per la configurazione di rete.
   - `versione: 2`: specifica che stiamo utilizzando la sintassi moderna, simile a Netplan.
   - `ethernets:`: un dizionario delle interfacce di rete fisiche da configurare, ordinate in base al nome dell'interfaccia (ad esempio, `eth0`).
   - `dhcp4: no`: Disabilita il DHCP per IPv4 su questa interfaccia.
   - `indirizzi`: un elenco di indirizzi IP statici da assegnare, specificati in notazione CIDR.
   - `gateway4`: Il gateway predefinito per il traffico IPv4.
   - `nameservers`: un dizionario contenente un elenco di indirizzi IP per la risoluzione DNS.

3. _Boot e verifica._\*

   La verifica è diversa questa volta, poiché la VM non otterrà un indirizzo IP dinamico. È necessario connettersi direttamente alla console della VM.

    ```bash
    # Utilizzare un nuovo disco per questo esercizio
    qemu-img create -f qcow2 -F qcow2 -b Rocky-10-GenericCloud.qcow2 static-ip-vm.qcow2
    
    virt-install --name rocky10-static-ip \
    --memory 2048 --vcpus 2 \
    --disk path=static-ip-vm.qcow2,format=qcow2 \
    --cloud-init user-data=user-data.yml,hostname=network-server \
    --os-variant rockylinux10 \
    --import --noautoconsole
    
    # Connettere la virtual console
    virsh console rocky10-static-ip
    
    # Loggarsi dentro e controlloare l'IP
    [rocky@network-server ~]$ ip a show eth0
    ```

   L'output dovrebbe mostrare che `eth0` ha l'indirizzo IP statico `192.168.122.100/24`.

### Esempio 2: Configurazione multi-interfaccia

Uno scenario comune nel mondo reale è un server con più interfacce di rete. Qui creeremo una VM con due interfacce: `eth0` utilizzerà DHCP, mentre `eth1` avrà un IP statico.

1. **Create `user-data.yml` per due interfacce:**

    ```bash
    cat <<EOF > user-data.yml
    #cloud-config
    packages: [iperf3]
    
    ---
    
    network:
      version: 2
      ethernets:
        eth0:
          dhcp4: yes
        eth1:
          dhcp4: no
          addresses: [192.168.200.10/24]
    EOF
    ```

2. **Boot di una VM con due schede di rete:** aggiungiamo un secondo flag `--network` al comando `virt-install`.

    ```bash
    virt-install --name rocky10-multi-nic \
    --memory 2048 --vcpus 2 \
    --disk path=... \
    --network network=default,model=virtio \
    --network network=default,model=virtio \
    --cloud-init user-data=user-data.yml,hostname=multi-nic-server \
    --os-variant rockylinux10 --import --noautoconsole
    ```

3. **Verifica:** esegure SSH all'indirizzo assegnato dal DHCP su `eth0`, quindi controlla l'IP statico su `eth1` con `ip a show eth1`.

## 2) Unificazione dei payload con MIME multi-part

A volte è necessario eseguire uno script di configurazione _prima_ dell'esecuzione dei moduli principali `#cloud-config`. I file multi-part MIME sono la soluzione ideale, poiché consentono di raggruppare diversi tipi di contenuti in un unico payload ordinato.

È possibile visualizzare la struttura di un file MIME come segue:

```
+-----------------------------------------+
| Main Header (multipart/mixed; boundary) |
+-----------------------------------------+
|
| --boundary                              |
| +-------------------------------------+
| | Part 1 Header (e.g., text/x-shellscript)  |
| +-------------------------------------+
| | Part 1 Content (#/bin/sh...)        |
| +-------------------------------------+
|
| --boundary                              |
| +-------------------------------------+
| | Part 2 Header (e.g., text/cloud-config)   |
| +-------------------------------------+
| | Part 2 Content (#cloud-config...)   |
| +-------------------------------------+
|
| --boundary-- (closing)                  |
+-----------------------------------------+
```

### Hands-on: uno script per il controllo preventivo

Creeremo un file composto da più parti che prima esegue uno script shell e poi procede al `#cloud-config` principale.

1. **Creare il file multiparte `user-data.mime`:**

   Si tratta di un file di testo con un formato speciale che utilizza una stringa “di delimitazione” per separare le parti.

    ```bash
    cat <<EOF > user-data.mime
    Content-Type: multipart/mixed; boundary="//"
    MIME-Version: 1.0
    
    --//
    Content-Type: text/x-shellscript; charset="us-ascii"
    
    #!/bin/sh
    echo "Running pre-flight checks..."
    # In a real script, you might check disk space or memory.
    # If checks failed, you could 'exit 1' to halt cloud-init.
    echo "Pre-flight checks passed." > /tmp/pre-flight-status.txt
    
    --//
    Content-Type: text/cloud-config; charset="us-ascii"
    
    #cloud-config
    packages:
        - htop
        runcmd:
          - [ sh, -c, "echo 'Main cloud-config ran successfully' > /tmp/main-config-status.txt" ]
    
    --//--
    EOF
    ```

       !!! note "Informazioni sul delimitatore  MIME"

        ```
         La stringa di delimitazione (in questo caso `//`) è una stringa arbitraria che non deve comparire nel contenuto di nessuna parte. Viene utilizzata per separare le diverse sezioni del file.
        ```

2. _Boot e verifica._\*

   Questo file viene passato a `virt-install` allo stesso modo di un file `user-data.yml` standard.

    ```bash
    # Use a new disk image
    qemu-img create -f qcow2 -F qcow2 -b Rocky-10-GenericCloud.qcow2 mime-vm.qcow2
    
    virt-install --name rocky10-mime-test \
    --memory 2048 --vcpus 2 \
    --disk path=mime-vm.qcow2,format=qcow2 \
    --cloud-init user-data=user-data.mime,hostname=mime-server \
    --os-variant rockylinux10 \
    --import --noautoconsole
    ```

   Dopo il boot, accedere alla VM tramite SSH e verificare che entrambe le parti siano state eseguite cercando i file che hanno creato:

    ```bash
    cat /tmp/pre-flight-status.txt
    cat /tmp/main-config-status.txt
    ```

!!! tip "Altri tipi di contenuti Multi-part"

    `cloud-init` supporta altri tipi di contenuto per casi d'uso avanzati, come `text/cloud-boothook` per script  iniziali di boot o `text/part-handler` per l'esecuzione di codice Python personalizzato. Per ulteriori dettagli, consultare la documentazione ufficiale.

## Prossimo passo

Ora avete imparato due potenti tecniche avanzate di `cloud-init`. Ora è possibile definire reti statiche e orchestrare flussi di lavoro di provisioning complessi con dati utente multi-part.

Nel prossimo capitolo, sposteremo la nostra prospettiva dal _consumo_ di `cloud-init` su base individuale alla _personalizzazione del suo comportamento predefinito_ per creare le vostre “immagini golden” preconfigurate.
