---
author: Wale Soyinka
contributors: Steven Spencer, Ganna Zhyrnova
tags:
  - kubernetes
  - k8s
  - lab exercise
  - kubectl
  - etcd
  - runc
---

# Laboratorio 8: Avvio del piano di controllo Kubernetes

!!! info

    Si tratta di un fork dell'originale ["Kubernetes the hard way"](https://github.com/kelseyhightower/kubernetes-the-hard-way) scritto originariamente da Kelsey Hightower (GitHub: kelseyhightower). A differenza dell'originale, che si basa su distribuzioni simili a Debian per l'architettura ARM64, questo fork si rivolge a distribuzioni Enterprise Linux come Rocky Linux, che gira su architettura x86_64.

In questo laboratorio, verrà avviato il piano di controllo Kubernetes. Sulla macchina controller verranno installati i seguenti componenti: Kubernetes API Server, Scheduler e Controller Manager.

## Prerequisiti

Connettersi alla `jumpbox` e copiare i file binari di Kubernetes e i file di unità `systemd` sull'istanza `server`:

```bash
scp \
  downloads/kube-apiserver \
  downloads/kube-controller-manager \
  downloads/kube-scheduler \
  downloads/kubectl \
  units/kube-apiserver.service \
  units/kube-controller-manager.service \
  units/kube-scheduler.service \
  configs/kube-scheduler.yaml \
  configs/kube-apiserver-to-kubelet.yaml \
  root@server:~/
```

È necessario eseguire i comandi riportati nelle sezioni seguenti di questo laboratorio sul computer `server`. Accedi all'istanza del controller con il comando `ssh`. Esempio:

```bash
ssh root@server
```

## Fornitura del piano di controllo Kubernetes

Crea la directory di configurazione di Kubernetes:

```bash
mkdir -p /etc/kubernetes/config
```

### Installazione dei binari del controller Kubernetes

Installare i binari Kubernetes:

```bash
  chmod +x kube-apiserver \
    kube-controller-manager \
    kube-scheduler kubectl
    
  mv kube-apiserver \
    kube-controller-manager \
    kube-scheduler kubectl \
    /usr/local/bin/
```

### Configurazione del server API Kubernetes

```bash
  mkdir -p /var/lib/kubernetes/

  mv ca.crt ca.key \
    kube-api-server.key kube-api-server.crt \
    service-accounts.key service-accounts.crt \
    encryption-config.yaml \
    /var/lib/kubernetes/
```

Creare il file dell'unità `systemd` `kube-apiserver.service`:

```bash
mv kube-apiserver.service /etc/systemd/system/kube-apiserver.service
```

### Configurazione del Kubernetes Controller Manager

Spostare il kubeconfig `kube-controller-manager` nella posizione corretta:

```bash
mv kube-controller-manager.kubeconfig /var/lib/kubernetes/
```

Creare il file dell'unità `systemd` `kube-controller-manager.service`:

```bash
mv kube-controller-manager.service /etc/systemd/system/
```

### Configurazione del scheduler Kubernetes

Spostare il kubeconfig `kube-scheduler` nella posizione corretta:

```bash
mv kube-scheduler.kubeconfig /var/lib/kubernetes/
```

Creare il file di configurazione `kube-scheduler.yaml`:

```bash
mv kube-scheduler.yaml /etc/kubernetes/config/
```

Creare il file dell'unità systemd `kube-scheduler.service`:

```bash
mv kube-scheduler.service /etc/systemd/system/
```

### Avvio dei servizi del controller

```bash
  systemctl daemon-reload
  
  systemctl enable kube-apiserver \
    kube-controller-manager kube-scheduler
    
  systemctl start kube-apiserver \
    kube-controller-manager kube-scheduler
```

> Attendere fino a 10 secondi affinché il server API Kubernetes completi l'inizializzazione.

### Verifica

```bash
kubectl cluster-info   --kubeconfig admin.kubeconfig
```

```text
Kubernetes control plane is running at https://127.0.0.1:6443
```

## RBAC per l'autorizzazione Kubelet

In questa sezione si configurano le autorizzazioni RBAC per consentire al server API Kubernetes di accedere all'API Kubelet su ciascun nodo di lavoro. È necessario accedere all'API Kubelet per recuperare metriche e log ed eseguire comandi nei pod.

> Questo tutorial imposta il flag Kubelet `--authorization-mode` su `Webhook`. La modalità `Webhook` utilizza l'API [SubjectAccessReview](https://kubernetes.io/docs/reference/kubernetes-api/authorization-resources/subject-access-review-v1/) per determinare l'autorizzazione.

Eseguire i comandi riportati in questa sezione sul nodo controller, che interessano l'intero cluster.

```bash
ssh root@server
```

Creare il `system:kube-apiserver-to-kubelet` [ClusterRole](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#role-and-clusterrole) con le autorizzazioni per accedere all'API Kubelet ed eseguire le attività più comuni associate alla gestione dei pod:

```bash
kubectl apply -f kube-apiserver-to-kubelet.yaml \
  --kubeconfig admin.kubeconfig
```

### Verifica RBAC

A questo punto, il piano di controllo Kubernetes è attivo e funzionante. Eseguire i seguenti comandi dalla macchina `jumpbox` per verificare che funzioni:

Effettuare una richiesta HTTP per ottenere le informazioni sulla versione di Kubernetes:

```bash
curl -k --cacert ca.crt https://server.kubernetes.local:6443/version
```

```text
{
  "major": "1",
  "minor": "32",
  "gitVersion": "v1.32.0",
  "gitCommit": "70d3cc986aa8221cd1dfb1121852688902d3bf53",
  "gitTreeState": "clean",
  "buildDate": "2024-12-11T17:59:15Z",
  "goVersion": "go1.23.3",
  "compiler": "gc",
  "platform": "linux/amd64"
}
```

Successivo: [Avvio dei nodi worker di Kubernetes](lab9-bootstrapping-kubernetes-workers.md)
