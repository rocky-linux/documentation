---
author: Wale Soyinka
contributors: Steven Spencer, Ganna Zhyrnova
tags:
  - kubernetes
  - k8s
  - lab exercise
---

# Laboratorio 7: Avvio del cluster `etcd`

!!! info

    Si tratta di un fork dell'originale ["Kubernetes the hard way"](https://github.com/kelseyhightower/kubernetes-the-hard-way) scritto originariamente da Kelsey Hightower (GitHub: kelseyhightower). A differenza dell'originale, che si basa su distribuzioni simili a Debian per l'architettura ARM64, questo fork si rivolge a distribuzioni Enterprise Linux come Rocky Linux, che gira su architettura x86_64.

I componenti di Kubernetes sono stateless e memorizzano lo stato del cluster in [etcd](https://github.com/etcd-io/etcd). In questo laboratorio si avvierà un cluster a tre nodi `etcd` e lo si configurerà per l'alta disponibilità e l'accesso remoto sicuro.

## Prerequisiti

Copiare i binari di `etcd` e i file dell'unità `systemd` nell'istanza `server`:

```bash
scp \
  downloads/etcd-v3.4.36-linux-amd64.tar.gz \
  units/etcd.service \
  root@server:~/
```

Eseguire i comandi nelle sezioni seguenti di questo laboratorio sul computer `server`. Accedere alla macchina `server` con il comando `ssh`. Esempio:

```bash
ssh root@server
```

## Avvio di un Cluster etcd

### Installare i binari di etcd

Se non è già installato, installare prima l'utilità `tar` con `dnf`. Quindi, estrarre e installare il server `etcd` e l'utilità a riga di comando `etcdctl`:

```bash
  dnf -y install tar
  tar -xvf etcd-v3.4.36-linux-amd64.tar.gz
  mv etcd-v3.4.36-linux-amd64/etcd* /usr/local/bin/
```

### Configurare il Server etcd

```bash
  mkdir -p /etc/etcd /var/lib/etcd
  chmod 700 /var/lib/etcd
  cp ca.crt kube-api-server.key kube-api-server.crt \
    /etc/etcd/
```

Ogni membro di `etcd` deve avere un nome unico all'interno di un cluster `etcd`. Impostare il nome `etcd` in modo che corrisponda al nome host dell'istanza di calcolo corrente:

Crea il file dell'unità `systemd` `etcd.service`:

```bash
mv etcd.service /etc/systemd/system/
chmod 644 /etc/systemd/system/etcd.service
```

!!! note "Nota"

    Sebbene sia considerata una forma di sicurezza inadeguata, potrebbe essere necessario disabilitare temporaneamente o permanentemente SELinux se si riscontrano problemi nell'avvio del servizio `etcd` `systemd`. La soluzione corretta consiste nell'analizzare e creare i file di policy necessari con strumenti quali `ausearch`, `audit2allow` e altri.  
    
    I comandi eliminano SELinux e lo disabilitano eseguendo quanto segue:

  ```bash
  sudo sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
  setenforce 0
  ```

### Avviare il Server `etcd`

```bash
  systemctl daemon-reload
  systemctl enable etcd
  systemctl start etcd
```

## Verifica

Elencare i membri del cluster `etcd`:

```bash
etcdctl member list
```

```text
6702b0a34e2cfd39, started, controller, http://127.0.0.1:2380, http://127.0.0.1:2379, false
```

Successivo: [Avvio del piano di controllo Kubernetes](lab8-bootstrapping-kubernetes-controllers.md)
