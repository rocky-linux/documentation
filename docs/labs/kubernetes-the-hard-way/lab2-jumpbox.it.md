---
author: Wale Soyinka
contributors: Steven Spencer, Ganna Zhyrnova
tags:
  - kubernetes
  - k8s
  - lab exercise
---

# Laboratorio 2: Configurazione della Jumpbox

!!! info

    Si tratta di un fork dell'originale ["Kubernetes the hard way"](https://github.com/kelseyhightower/kubernetes-the-hard-way) scritto originariamente da Kelsey Hightower (GitHub: kelseyhightower). A differenza dell'originale, che si basa su distribuzioni simili a Debian per l'architettura ARM64, questo fork si rivolge a distribuzioni Enterprise Linux come Rocky Linux, che gira su architettura x86_64.

In questo laboratorio, si imposterà una delle quattro macchine come `jumpbox`. Questa macchina verrà utilizzata per eseguire i comandi di questa esercitazione. Sebbene venga utilizzato un computer dedicato per garantire la coerenza, è possibile eseguire questi comandi da qualsiasi computer, compresa la propria workstation personale con macOS o Linux.

Considerate la `jumpbox` come la macchina di amministrazione che userete come base per impostare il vostro cluster Kubernetes da zero. Una cosa da fare prima di iniziare è installare alcune utility da riga di comando e clonare il repository git Kubernetes The Hard Way, che contiene alcuni file di configurazione aggiuntivi che verranno utilizzati per configurare vari componenti di Kubernetes nel corso di questo tutorial.

Accedere alla `jumpbox`:

```bash
ssh root@jumpbox
```

Per comodità, si eseguiranno tutti i comandi come utente `root`, in modo da ridurre il numero di comandi necessari per la configurazione.

## Installare le utilità della riga di comando

Una volta effettuato l'accesso alla macchina `jumpbox` come utente `root`, si installeranno le utility da riga di comando che verranno utilizzate per eseguire vari compiti nel corso dell'esercitazione:

```bash
sudo dnf -y install wget curl vim openssl git
```

## Sincronizzazione del repository GitHub

Ora è il momento di scaricare una copia di questo tutorial, che contiene i file di configurazione e i modelli da utilizzare per costruire il cluster Kubernetes da zero. Clonare il repository git Kubernetes The Hard Way usando il comando `git`:

```bash
git clone --depth 1 \
  https://github.com/wsoyinka/kubernetes-the-hard-way.git
```

Passare alla cartella `kubernetes-the-hard-way`:

```bash
cd kubernetes-the-hard-way
```

Questa sarà la directory di lavoro per il resto dell'esercitazione. Se vi perdete, eseguite il comando `pwd` per verificare di essere nella directory corretta quando eseguite i comandi su `jumpbox`:

```bash
pwd
```

```text
/root/kubernetes-the-hard-way
```

## Scaricare i binari

Qui si scaricano i binari dei vari componenti di Kubernetes. Memorizzare questi file binari nella directory `Downloads` della `jumpbox`. Questo ridurrà la quantità di banda internet necessaria per completare questa esercitazione, in quanto si eviterà di scaricare i binari più volte per ogni macchina del cluster Kubernetes.

Il file `download.txt` elenca i file binari che verranno scaricati, che possono essere esaminati con il comando `cat`:

```bash
cat downloads.txt
```

Scaricare i file binari elencati nel file `downloads.txt` in una directory chiamata `downloads` usando il comando `wget`:

```bash
wget -q --show-progress \
  --https-only \
  --timestamping \
  -P downloads \
  -i downloads.txt
```

A seconda della velocità di connessione a Internet, potrebbe essere necessario un po' di tempo per scaricare i `584` megabyte di file binari. Una volta completato il download, è possibile elencarli con il comando `ls`:

```bash
ls -loh downloads
```

```text
total 557M
-rw-r--r--. 1 root 51M Jan  6 11:13 cni-plugins-linux-amd64-v1.6.2.tgz
-rw-r--r--. 1 root 36M Feb 28 14:09 containerd-2.0.3-linux-amd64.tar.gz
-rw-r--r--. 1 root 19M Dec  9 04:16 crictl-v1.32.0-linux-amd64.tar.gz
-rw-r--r--. 1 root 17M Feb 25 14:19 etcd-v3.4.36-linux-amd64.tar.gz
-rw-r--r--. 1 root 89M Dec 11 16:12 kube-apiserver
-rw-r--r--. 1 root 82M Dec 11 16:12 kube-controller-manager
-rw-r--r--. 1 root 55M Dec 11 16:12 kubectl
-rw-r--r--. 1 root 74M Dec 11 16:12 kubelet
-rw-r--r--. 1 root 64M Dec 11 16:12 kube-proxy
-rw-r--r--. 1 root 63M Dec 11 16:12 kube-scheduler
-rw-r--r--. 1 root 11M Feb 13 20:19 runc.amd64
```

## Installare `kubectl`

In questa sezione si installerà `kubectl`, lo strumento a riga di comando ufficiale del client Kubernetes, sulla macchina `jumpbox`. Si userà `kubectl` per interagire con il piano di controllo di Kubernetes dopo il completamento del provisioning del cluster, più avanti in questo tutorial.

Usare il comando `chmod` per rendere eseguibile il binario `kubectl` e spostarlo nella directory `/usr/local/bin/`:

```bash
  chmod +x downloads/kubectl
  cp downloads/kubectl /usr/local/bin/
```

Poiché l'installazione di `kubectl` è completa, è possibile verificarla eseguendo il comando `kubectl`:

```bash
kubectl version --client
```

```text
Client Version: v1.32.0
Kustomize Version: v5.5.0
```

A questo punto, avete configurato una `jumpbox` con tutti gli strumenti e le utilità a riga di comando necessari per completare i laboratori di questa esercitazione.

Successivo: [Provisioning delle risorse di calcolo](lab3-compute-resources.md)
