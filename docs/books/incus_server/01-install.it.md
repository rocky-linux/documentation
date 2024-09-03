---
title: 1 Installazione e configurazione
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 8.8, 9.2
tags:
  - lxd
  - enterprise
  - lxd install
---

# Capitolo 1: Installazione e configurazione

In tutto questo capitolo dovrete essere l'utente root o dovrete essere in grado di passare a root con *sudo*.

## Installare i repository EPEL e OpenZFS

LXD richiede i repository EPEL (Extra Packages for Enterprise Linux), che sono facili da installare:

```bash
dnf install epel-release
```

Una volta installato, verificare che non vi siano aggiornamenti:

```bash
dnf upgrade
```

Se durante il processo di aggiornamento sono stati effettuati aggiornamenti del kernel, riavviare il server.

### Repository OpenZFS per 8 e 9

Installare il repository OpenZFS con:

```bash
dnf install https://zfsonlinux.org/epel/zfs-release-2-2$(rpm --eval "%{dist}").noarch.rpm
```

## Installare `snapd`, `dkms`, `vim` e `kernel-devel`

L'installazione di LXD richiede un pacchetto snap su Rocky Linux. Per questo motivo, è necessario installare `snapd` (e alcuni altri programmi utili) con:

```bash
dnf install snapd dkms vim kernel-devel
```

Ora abilitate e avviate snapd:

```bash
systemctl enable snapd
```

Quindi eseguire:

```bash
systemctl start snapd
```

Riavviare il server prima di continuare.

## Installare LXD

L'installazione di LXD richiede l'uso del comando snap. A questo punto, si sta solo installando, non si sta eseguendo la configurazione:

```bash
snap install lxd
```

## Installare OpenZFS

```bash
dnf install zfs
```

## Impostazione dell'ambiente

La maggior parte delle impostazioni del kernel del server non sono sufficienti per eseguire un gran numero di container. Se si presume fin dall'inizio che si utilizzerà il server in produzione, è necessario apportare queste modifiche in anticipo per evitare errori come "Too many open files".

Fortunatamente, modificare le impostazioni di LXD non è difficile, basta modificare alcuni file e riavviare il sistema.

### Modifica di `limits.conf`

Il primo file da modificare è il file `limits.conf.` Questo file è autodocumentato. Esaminate le spiegazioni nei commenti del file per capire cosa fa questo file. Per apportare le modifiche, inserire:

```bash
vi /etc/security/limits.conf
```

L'intero file è costituito da commenti e, in fondo, mostra le impostazioni predefinite correnti. Nello spazio vuoto sopra il marcatore di fine file (#End of file) è necessario aggiungere le nostre impostazioni personalizzate. Una volta completato, il file avrà il seguente aspetto:

```text
# Modifications made for LXD

*               soft    nofile           1048576
*               hard    nofile           1048576
root            soft    nofile           1048576
root            hard    nofile           1048576
*               soft    memlock          unlimited
*               hard    memlock          unlimited
```

Salva le tue modifiche ed esci (++shift+colon+"w"+"q"+exclam++ per *vi*).

### Modifica di sysctl.conf con `90-lxd.override.conf`

Con *systemd*, è possibile apportare modifiche alla configurazione generale del sistema e alle opzioni del kernel *senza* modificare il file di configurazione principale. Le impostazioni vanno invece inserite in un file separato che sovrascrive le impostazioni specifiche necessarie.

Per apportare queste modifiche al kernel, si deve creare un file chiamato `90-lxd-override.conf` in `/etc/sysctl.d`. Per farlo, digitare:

```bash
vi /etc/sysctl.d/90-lxd-override.conf
```

!!! warning "RL 9 e valore MAX di `net.core.bpf_jit_limit`"

    A causa dei recenti aggiornamenti della sicurezza del kernel, il valore massimo di `net.core.bpf_jit_limit` sembra essere 1000000000. Se si utilizza Rocky Linux 9.x, regolare questo valore nel file di autodocumentazione sottostante. Se lo si imposta al di sopra di questo limite **O** se non lo si imposta affatto, verrà impostato il valore predefinito di sistema di 264241152, che potrebbe non essere sufficiente se si esegue un numero elevato di contenitori.

Inserite il seguente contenuto nel file. Se vi state chiedendo cosa state facendo, il contenuto del file è autodocumentante:

```bash
## The following changes have been made for LXD ##

# fs.inotify.max_queued_events specifies an upper limit on the number of events that can be queued to the corresponding inotify instance
 - (default is 16384)

fs.inotify.max_queued_events = 1048576

# fs.inotify.max_user_instances This specifies an upper limit on the number of inotify instances that can be created per real user ID -
(default value is 128)

fs.inotify.max_user_instances = 1048576

# fs.inotify.max_user_watches specifies an upper limit on the number of watches that can be created per real user ID - (default is 8192)

fs.inotify.max_user_watches = 1048576

# vm.max_map_count contains the maximum number of memory map areas a process may have. Memory map areas are used as a side-effect of cal
ling malloc, directly by mmap and mprotect, and also when loading shared libraries - (default is 65530)

vm.max_map_count = 262144

# kernel.dmesg_restrict denies container access to the messages in the kernel ring buffer. Please note that this also will deny access t
o non-root users on the host system - (default is 0)

kernel.dmesg_restrict = 1

# This is the maximum number of entries in ARP table (IPv4). You should increase this if you create over 1024 containers.

net.ipv4.neigh.default.gc_thresh3 = 8192

# This is the maximum number of entries in ARP table (IPv6). You should increase this if you plan to create over 1024 containers.Not nee
ded if not using IPv6, but...

net.ipv6.neigh.default.gc_thresh3 = 8192

# This is a limit on the size of eBPF JIT allocations which is usually set to PAGE_SIZE * 40000. Set this to 1000000000 if you are running Rocky Linux 9.x

net.core.bpf_jit_limit = 3000000000

# This is the maximum number of keys a non-root user can use, should be higher than the number of containers

kernel.keys.maxkeys = 2000

# This is the maximum size of the keyring non-root users can use

kernel.keys.maxbytes = 2000000

# This is the maximum number of concurrent async I/O operations. You might need to increase it further if you have a lot of workloads th
at use the AIO subsystem (e.g. MySQL)

fs.aio-max-nr = 524288
```

Salvare le modifiche e uscire.

A questo punto riavviare il server.

### Controllo dei valori di *sysctl.conf*

Dopo il riavvio, accedere nuovamente al server come utente root. È necessario verificare che il nostro file di override abbia effettivamente completato il lavoro.

Non è difficile da fare. Non è necessario verificare tutte le impostazioni, a meno che non lo si voglia fare, ma controllarne alcune consente di verificare che le impostazioni siano state modificate. Per farlo, utilizzare il comando `sysctl`:

```bash
sysctl net.core.bpf_jit_limit
```

Che vi mostrerà:

```bash
net.core.bpf_jit_limit = 3000000000
```

Eseguire la stessa operazione con alcune altre impostazioni del file di sovrascrittura per verificare le modifiche.
