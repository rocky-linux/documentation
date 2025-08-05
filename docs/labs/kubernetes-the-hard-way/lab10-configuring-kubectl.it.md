---
author: Wale Soyinka
contributors: Steven Spencer
tags:
  - kubernetes
  - k8s
  - lab exercise
  - runc
  - containerd
  - etcd
  - kubectl
---

# Laboratorio 10: Configurazione di `kubectl` per l'accesso remoto

!!! info

    Si tratta di un fork dell'originale ["Kubernetes the hard way"](https://github.com/kelseyhightower/kubernetes-the-hard-way) scritto originariamente da Kelsey Hightower (GitHub: kelseyhightower). A differenza dell'originale, che si basa su distribuzioni simili a Debian per l'architettura ARM64, questo fork si rivolge a distribuzioni Enterprise Linux come Rocky Linux, che gira su architettura x86_64.

In questo laboratorio si genererà un file kubeconfig per l'utilità a riga di comando `kubectl` basato sulle credenziali dell'utente `admin`.

> Eseguite i comandi di questo laboratorio dalla macchina `jumpbox`.

## Il file di configurazione Admin Kubernetes

Ogni kubeconfig richiede un Kubernetes API Server a cui connettersi.

In base alla voce DNS `/etc/hosts` di un laboratorio precedente, si dovrebbe essere in grado di eseguire il ping`server.kubernetes.local`.

```bash
curl -k --cacert ca.crt \
  https://server.kubernetes.local:6443/version
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

Generare un file kubeconfig adatto all'autenticazione come utente `admin`:

```bash
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.crt \
    --embed-certs=true \
    --server=https://server.kubernetes.local:6443

  kubectl config set-credentials admin \
    --client-certificate=admin.crt \
    --client-key=admin.key

  kubectl config set-context kubernetes-the-hard-way \
    --cluster=kubernetes-the-hard-way \
    --user=admin

  kubectl config use-context kubernetes-the-hard-way
```

L'esecuzione del comando sopra riportato dovrebbe creare un file kubeconfig nella posizione predefinita `~/.kube/config` utilizzata dallo strumento da riga di comando  `kubectl`. Questo significa anche che è possibile eseguire il comando `kubectl` senza specificare una configurazione.

## Verifica

Controllare la versione del cluster Kubernetes remoto:

```bash
kubectl version
```

```text
Client Version: v1.32.0
Kustomize Version: v5.5.0
Server Version: v1.32.0
```

Elencare i nodi del cluster Kubernetes remoto:

```bash
kubectl get nodes
```

```text
NAME     STATUS   ROLES    AGE   VERSION
node-0   Ready    <none>   30m   v1.31.2
node-1   Ready    <none>   35m   v1.31.2
```

Successivo: [Provisioning Pod Network Routes](lab11-pod-network-routes.md)
