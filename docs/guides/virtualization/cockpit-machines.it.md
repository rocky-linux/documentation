---
title: Cockpit KVM Dashboard
author: Neel Chauhan
contributors: Ganna Zhrynova
tested on: 9.3
tags:
  - virtualization
---

# Cockpit KVM dashboard

## Introduzione

Cockpit è uno strumento di amministrazione del server che fornisce un dashboard facile da usare per gestire il server. Una caratteristica di Cockpit è che con un pacchetto può gestire le macchine virtuali KVM da un'interfaccia web simile a quella di VMware ESXi o Proxmox.

## Prerequisiti

- Un server Rocky Linux con virtualizzazione hardware abilitata
- Accesso ai repository `dnf` di Rocky Linux

## Installazione di Cockpit

Cockpit è disponibile di default in Rocky Linux. Tuttavia, il supporto KVM non viene installato immediatamente. Si installa tramite `dnf`:

```bash
dnf install -y cockpit-machines
```

Installare anche `libvirtd`:

```bash
dnf install -y libvirt
```

## Abilitare `cockpit`

Per abilitare sia la virtualizzazione KVM che Cockpit, attivare i servizi `systemd`:

```bash
systemctl enable --now libvirtd cockpit.socket
```

Dopo aver abilitato `cockpit`, aprire un browser a **http://ip_address:9090** (nota: sostituire **ip_address** con l'indirizzo IP del proprio server):

![Cockpit login screen](../images/cockpit_login.png)

Effettuando il login come utente non root, si dovrebbe vedere una dashboard simile a quella mostrata qui:

![Cockpit dashboard](../images/cockpit_dashboard.png)

## Creazione di una macchina virtuale

In questa guida, si configurerà una macchina virtuale Rocky Linux 9 su un host, utilizzando l'automazione per aggiungere un nome utente e una password di root.

Per creare una macchina virtuale in Cockpit, fare clic sul pulsante blu **Turn on administrative access** e inserire la password, se necessario:

![Cockpit dashboard as root](../images/cockpit_root_dashboard.png)

Ora si è connessi come root in Cockpit. Nella barra laterale, fare clic su _Virtual Machines_\*:

![Cockpit Virtual Machine dashboard](../images/cockpit_vm_dashboard.png)

Quindi fare clic su **Create VM**:

![Virtual Machine create dialog](../images/cockpit_vm_create_1.png)

Nel menu a tendina **Operating system**, selezionare **Rocky Linux 9 (Blue Onyx)**:

![VM create dialog with Rocky Linux 9 selected](../images/cockpit_vm_create_2.png)

Quindi, fare clic su **Automation** e inserire i dati di accesso desiderati per la nuova macchina virtuale:

![VM create dialog with root password and username filed in](../images/cockpit_vm_create_2.png)

Infine, selezionare **Create and run**.

In pochi minuti, selezionando la macchina virtuale appena creata, si otterrà il suo indirizzo IP:

![Our VM's IP address](../images/cockpit_vm_ip.png)

SSH nell'hypervisor e SSH nell'indirizzo IP di Cockpit. In questo esempio, è **172.20.0.103**. Verrà effettuato l'accesso al nuovo server:

![Our VM's terminal](../images/cockpit_vm_terminal.png)

## Limitazioni

Sebbene Cockpit sia ottimo per la creazione e la gestione di macchine virtuali, ci sono alcune limitazioni da tenere presenti:

- Non è possibile creare un'bridge interface.
- Non è possibile creare una nuova immagine in nessun pool di archiviazione, ma solo in quello `default`.

Fortunatamente, è possibile crearli alla riga di comando e Cockpit può utilizzarli.

## Conclusione

Cockpit è uno strumento prezioso per gestire un server Rocky Linux tramite un'interfaccia web. È personalmente lo strumento preferito dall'autore per la creazione di macchine virtuali nel proprio laboratorio domestico. Sebbene `cockpit-machines` non sia così completo come ESXi o Proxmox, è in grado di svolgere il lavoro per il 90% dei casi di utilizzo dell'hypervisor.
