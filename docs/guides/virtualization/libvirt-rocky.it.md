---
title: Configurazione di libvirt su Rocky Linux
author: Howard Van Der Wal
contributors: Steven Spencer
tested with: 9.5
tags:
  - libvirt
  - kvm
  - virtualization
---

## Introduzione

[libvirt](https://libvirt.org/) è un'incredibile API di virtualizzazione che consente la virtualizzazione di quasi tutti i sistemi operativi di vostra scelta con la potenza di KVM come hypervisor e QEMU come emulatore.

Questo documento fornisce le istruzioni per l'impostazione di libvirt su Rocky Linux 9.

## Prerequisiti

 - Una macchina a 64 bit con Rocky Linux 9.
 - Assicuratevi di aver abilitato la virtualizzazione nelle impostazioni del BIOS. Se il comando seguente restituisce un risultato, significa che l'abilitazione della virtualizzazione è stata completata:

```bash
sudo grep -e 'vmx' /proc/cpuinfo
```

## Configurazione del repository e installazione dei pacchetti

 - Attivare il repository EPEL (Extra Packages for Enterprise Linux):

```bash
sudo dnf install -y epel-release
```

 - Installare i pacchetti necessari per `libvirt` (opzionalmente per `virt-manager` se si vuole usare una GUI per gestire le macchine virtuali):

```bash
sudo dnf install -y bridge-utils virt-top libguestfs-tools bridge-utils virt-viewer qemu-kvm libvirt virt-manager virt-install
```

## Configurazione utente libvirt

 - Aggiungere il proprio utente al gruppo `libvirt`. Ciò consente di gestire le macchine virtuali e di utilizzare comandi come `virt-install` come utente non root:

```bash
sudo usermod -aG libvirt $USER
```

 - Attivare il gruppo `libvirt` utilizzando il comando `newgrp`:

```bash
sudo newgrp libvirt
```

 - Abilitare e avviare il servizio `libvirtd`:

```bash
sudo systemctl enable --now libvirtd
```

## Configurazione dell'interfaccia bridge per l'accesso diretto alle macchine virtuali

 - Controllare le interfacce attualmente in uso e annotare l'interfaccia principale con connessione a Internet:

```bash
sudo nmcli connection show
```

 - Eliminare l'interfaccia collegata a Internet e tutte le connessioni virtual bridge attualmente presenti:

```bash
sudo nmcli connection delete <CONNECTION_NAME>
```

!!! warning

```
Assicurarsi di avere accesso diretto alla macchina. Se si configura la macchina tramite SSH, la connessione verrà interrotta dopo aver eliminato la connessione all'interfaccia principale.
```

 - Creare la nuova connessione bridge:

```bash
sudo nmcli connection add type bridge autoconnect yes con-name <VIRTUAL_BRIDGE_CON-NAME> ifname <VIRTUAL_BRIDGE_IFNAME>
```

 - Assegnare un indirizzo IP statico:

```bash
sudo nmcli connection modify <VIRTUAL_BRIDGE_CON-NAME> ipv4.addresses <STATIC_IP/SUBNET_MASK> ipv4.method manual
```

 - Assegnare un indirizzo gateway:

```bash
sudo nmcli connection modify <VIRTUAL_BRIDGE_CON-NAME> ipv4.gateway <GATEWAY_IP>
```

 - Assegnare l'indirizzo DNS:

```bash
sudo nmcli connection modify <VIRTUAL_BRIDGE_CON-NAME> ipv4.dns <DNS_IP>
```

 - Aggiungere la connessione bridge slave:

```bash
sudo nmcli connection add type bridge-slave autoconnect yes con-name <MAIN_INTERFACE_WITH_INTERNET_ACCESS_CON-NAME> ifname <MAIN_INTERFACE_WITH_INTERNET_ACCESS_IFNAME> master <VIRTUAL_BRIDGE_CON-NAME>
```

 - Avviare la connessione bridge:

```bash
sudo nmcli connection up <VIRTUAL_BRIDGE_CON-NAME>
```

 - Aggiungere la riga `allow all` a `bridge.conf`:

```bash
sudo tee -a /etc/qemu-kvm/bridge.conf <<EOF
allow all
EOF
```

 - Riavviare il servizio `libvirtd`:

```bash
sudo systemctl restart libvirtd
```

## Installazione della VM

 - Impostare la proprietà della directory `/var/lib/libvirt` e delle sue directory annidate al proprio utente:

```bash
sudo chown -R $USER:libvirt /var/lib/libvirt/
```

 - È possibile creare una macchina virtuale tramite riga di comando utilizzando il comando `virt-install`. Ad esempio, per creare una macchina virtuale Rocky Linux 9.5 Minimal, si deve eseguire il seguente comando:

```bash
virt-install --name Rocky-Linux-9 --ram 4096 --vcpus 4 --disk path=/var/lib/libvirt/images/rocky-linux-9.img,size=20 --os-variant rocky9 --network bridge=virbr0,model=virtio --graphics none --console pty,target_type=serial --extra-args 'console=ttyS0,115200n8' --location ~/isos/Rocky-9.5-x86_64-minimal.iso
```

 - Per chi vuole gestire le proprie macchine virtuali tramite una GUI, `virt-manager` è lo strumento perfetto.

## Come arrestare una VM

 - Il comando \`shutdown' consente di ottenere questo risultato:

```bash
virsh shutdown --domain <YOUR_VM_NAME>
```

 - Per forzare lo spegnimento di una macchina virtuale che non risponde, utilizzare il comando `destroy`:

```bash
virsh destroy --domain <YOUR_VM_NAME>
```

## Come cancellare una VM

 - Utilizzare il comando `undefine`:

```bash
virsh undefine --domain <YOUR_VM_NAME> --nvram
```

 - Per ulteriori comandi `virsh`, consultare le pagine `virsh` `man`.

## Conclusione

 - libvirt offre molte possibilità e permette di installare e gestire le macchine virtuali con facilità. Se si hanno ulteriori integrazioni o modifiche a questo documento che si desidera condividere, l'autore vi invita a farlo.
