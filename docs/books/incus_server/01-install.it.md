---
title: 1 Installazione e Configurazione
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 9.4
tags:
  - incus
  - enterprise
  - incus install
---

Nel corso di questo capitolo, è necessario essere l'utente root o essere in grado di eseguire con i privilegi di root con _sudo_.

## Installare i repository EPEL e OpenZFS

Incus richiede il repository EPEL (Extra Packages for Enterprise Linux), il quale è facile da installare:

```bash
dnf install epel-release -y
```

Una volta installato, verificare che non vi siano aggiornamenti:

```bash
dnf upgrade
```

Se durante il processo di aggiornamento sono stati effettuati aggiornamenti del kernel, riavviare il server.

### OpenZFS repository

Installare il repository OpenZFS con:

```bash
dnf install https://zfsonlinux.org/epel/zfs-release-2-8$(rpm --eval "%{dist}").noarch.rpm
```

## Installazione di `dkms`, `vim` e `kernel-devel`

Installare alcuni pacchetti necessari:

```bash
dnf install dkms vim kernel-devel bash-completion
```

## Installazione di `Incus`

È necessario il repository CRB, disponibile per alcuni pacchetti speciali, e il COPR (Cool Other Package Repo) di Neil Hanlon:

```bash
dnf config-manager --enable crb
dnf copr enable neil/incus
dnf install incus incus-tools
```

Abilitare ed attivare il serivzio:

```bash
systemctl enable incus --now
```

Riavviare il server prima di continuare.

## Installare OpenZFS

```bash
dnf install zfs
```

## Impostazione dell'ambiente

Per eseguire molti container sono necessarie diverse impostazioni del kernel del server. Se si presume fin dall'inizio che si utilizzerà il server in produzione, è necessario apportare queste modifiche in anticipo per evitare errori come "Too many open files".

Fortunatamente, modificare le impostazioni di Incus non è difficile, basta modificare alcuni file e riavviare il sistema.

### Modifica di `limits.conf`

Il primo file da modificare è il file `limits.conf`. Questo file è autodocumentato. Esaminate le spiegazioni nei commenti del file per capire cosa fa questo file. Per effettuare le modifiche, digitare:

```bash
vi /etc/security/limits.conf
```

L'intero file è costituito da commenti e, in fondo, mostra le impostazioni predefinite correnti. È necessario aggiungere le impostazioni personalizzate nello spazio vuoto sopra il marcatore di fine file (#End of file). Una volta completato, il file avrà il seguente aspetto:

```text
# Modifications made for LXD

*               soft    nofile           1048576
*               hard    nofile           1048576
root            soft    nofile           1048576
root            hard    nofile           1048576
*               soft    memlock          unlimited
*               hard    memlock          unlimited
```

Salvare le modifiche e uscire (++shift+colon+"w ‘+’q ”+exclam++ per _vi_).

### Modifica di `sysctl.conf` con `90-incus-override.conf`

Con _systemd_, è possibile modificare la configurazione di sistema e le opzioni del kernel _senza_ modificare il file di configurazione principale. Le impostazioni vanno invece inserite in un file separato che sovrascrive le impostazioni specifiche necessarie.

Per apportare queste modifiche al kernel, si deve creare un file chiamato `90-incus-override.conf` in `/etc/sysctl.d`. Per fare ciò, digitare il seguente comando:

```bash
vi /etc/sysctl.d/90-incus-override.conf
```

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

net.core.bpf_jit_limit = 1000000000

# This is the maximum number of keys a non-root user can use, should be higher than the number of containers

kernel.keys.maxkeys = 2000

# This is the maximum size of the keyring non-root users can use

kernel.keys.maxbytes = 2000000

# This is the maximum number of concurrent async I/O operations. You might need to increase it further if you have a lot of workloads th
at use the AIO subsystem (e.g. MySQL)

fs.aio-max-nr = 524288
```

Salvare le modifiche e uscire.

A questo punto, riavviare il server.

### Controllare i parametri di `sysctl.conf`

Dopo il riavvio, accedere nuovamente al server come utente root. È necessario verificare che il nostro file di override abbia effettivamente completato il lavoro.

Non è difficile da fare. Non è necessario verificare tutte le impostazioni, a meno che non lo si voglia fare, ma controllarne alcune consente di verificare che le impostazioni siano state modificate. Per farlo, utilizzare il comando `sysctl`:

```bash
sysctl net.core.bpf_jit_limit
```

Che vi mostrerà:

```bash
net.core.bpf_jit_limit = 1000000000 
```

Eseguire la stessa operazione con alcune altre impostazioni del file di sovrascrittura per verificare le modifiche.
