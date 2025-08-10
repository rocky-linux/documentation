---
author: Wale Soyinka
contributors: Steven Spencer, Ganna Zhyrnova
tags:
  - kubernetes
  - k8s
  - lab exercise
---

# Laboratorio 5: Generazione dei file di configurazione di Kubernetes per l'autenticazione

!!! info

    Si tratta di un fork dell'originale ["Kubernetes the hard way"](https://github.com/kelseyhightower/kubernetes-the-hard-way) scritto originariamente da Kelsey Hightower (GitHub: kelseyhightower). A differenza dell'originale, che si basa su distribuzioni simili a Debian per l'architettura ARM64, questo fork si rivolge a distribuzioni Enterprise Linux come Rocky Linux, che gira su architettura x86_64.

In questo laboratorio, si genereranno i [file di configurazione client Kubernetes](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/), che vengono solitamente chiamati kubeconfig. Questi file configurano i client Kubernetes per connettersi e autenticarsi con i server API Kubernetes.

## Configurazioni di autenticazione del client

In questa sezione si generano i file kubeconfig per `kubelet` e per l'utente `admin`.

### Il file di configurazione kubelet Kubernetes

Quando si generano i file kubeconfig per i Kubelet, è necessario far corrispondere il certificato del client al nome del nodo del Kubelet. Questo assicura che i Kubelets siano autorizzati correttamente dal [Node Authorizer] di Kubernetes (https://kubernetes.io/docs/reference/access-authn-authz/node/).

> I comandi seguenti devono essere eseguiti nella stessa directory utilizzata per generare i certificati SSL durante il laboratorio [Generazione di certificati TLS](lab4-certificate-authority.md).

Generare un file kubeconfig per i nodi di lavoro node-0 e node-1:

```bash
for host in node-0 node-1; do
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.crt \
    --embed-certs=true \
    --server=https://server.kubernetes.local:6443 \
    --kubeconfig=${host}.kubeconfig

  kubectl config set-credentials system:node:${host} \
    --client-certificate=${host}.crt \
    --client-key=${host}.key \
    --embed-certs=true \
    --kubeconfig=${host}.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:node:${host} \
    --kubeconfig=${host}.kubeconfig

  kubectl config use-context default \
    --kubeconfig=${host}.kubeconfig
done
```

Risultati:

```text
node-0.kubeconfig
node-1.kubeconfig
```

### Il file di configurazione di Kubernetes kube-proxy

Generare un file kubeconfig per il servizio `kube-proxy`:

```bash
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.crt \
    --embed-certs=true \
    --server=https://server.kubernetes.local:6443 \
    --kubeconfig=kube-proxy.kubeconfig

  kubectl config set-credentials system:kube-proxy \
    --client-certificate=kube-proxy.crt \
    --client-key=kube-proxy.key \
    --embed-certs=true \
    --kubeconfig=kube-proxy.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:kube-proxy \
    --kubeconfig=kube-proxy.kubeconfig

  kubectl config use-context default \
    --kubeconfig=kube-proxy.kubeconfig
```

Risultati:

```text
kube-proxy.kubeconfig
```

### Il file di configurazione di Kubernetes di kube-controller-manager

Generare un file kubeconfig per il servizio `kube-controller-manager`:

```bash
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.crt \
    --embed-certs=true \
    --server=https://server.kubernetes.local:6443 \
    --kubeconfig=kube-controller-manager.kubeconfig

  kubectl config set-credentials system:kube-controller-manager \
    --client-certificate=kube-controller-manager.crt \
    --client-key=kube-controller-manager.key \
    --embed-certs=true \
    --kubeconfig=kube-controller-manager.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:kube-controller-manager \
    --kubeconfig=kube-controller-manager.kubeconfig

  kubectl config use-context default \
    --kubeconfig=kube-controller-manager.kubeconfig
```

Risultati:

```text
kube-controller-manager.kubeconfig
```

### Il file di configurazione di kube-scheduler Kubernetes

Generare un file kubeconfig per il servizio `kube-scheduler`:

```bash
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.crt \
    --embed-certs=true \
    --server=https://server.kubernetes.local:6443 \
    --kubeconfig=kube-scheduler.kubeconfig

  kubectl config set-credentials system:kube-scheduler \
    --client-certificate=kube-scheduler.crt \
    --client-key=kube-scheduler.key \
    --embed-certs=true \
    --kubeconfig=kube-scheduler.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:kube-scheduler \
    --kubeconfig=kube-scheduler.kubeconfig

  kubectl config use-context default \
    --kubeconfig=kube-scheduler.kubeconfig
```

Risultati:

```text
kube-scheduler.kubeconfig
```

### Il file di configurazione Kubernetes dell'amministratore

Generare un file kubeconfig per l'utente `admin`:

```bash
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.crt \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=admin.kubeconfig

  kubectl config set-credentials admin \
    --client-certificate=admin.crt \
    --client-key=admin.key \
    --embed-certs=true \
    --kubeconfig=admin.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=admin \
    --kubeconfig=admin.kubeconfig

  kubectl config use-context default \
    --kubeconfig=admin.kubeconfig
```

Risultati:

```text
admin.kubeconfig
```

## Distribuire i file di configurazione di Kubernetes

Copiare i file `kubelet` e `kube-proxy` nelle istanze `node-0` e `node-1`:

```bash
for host in node-0 node-1; do
  ssh root@$host "mkdir /var/lib/{kube-proxy,kubelet}"
  
  scp kube-proxy.kubeconfig \
    root@$host:/var/lib/kube-proxy/kubeconfig \
  
  scp ${host}.kubeconfig \
    root@$host:/var/lib/kubelet/kubeconfig
done
```

Copiare i file kubeconfig `kube-controller-manager` e `kube-scheduler` nell'istanza del controller:

```bash
scp admin.kubeconfig \
  kube-controller-manager.kubeconfig \
  kube-scheduler.kubeconfig \
  root@server:~/
```

Successivo: [Generazione della configurazione e della chiave di crittografia dei dati](lab6-data-encryption-keys.md)
