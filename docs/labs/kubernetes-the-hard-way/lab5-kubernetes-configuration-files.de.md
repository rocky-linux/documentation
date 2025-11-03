---
author: Wale Soyinka
contributors: Steven Spencer, Ganna Zhyrnova
tags:
  - kubernetes
  - k8s
  - Laborübung
---

# Labor 5: Generierung von Kubernetes-Konfigurationsdateien zur Authentifizierung

!!! info

    Dies ist ein Fork des ursprünglichen ["Kubernetes the hard way"](https://github.com/kelseyhightower/kubernetes-the-hard-way), das ursprünglich von Kelsey Hightower geschrieben wurde (GitHub: kelseyhightower). Im Gegensatz zum Original, das auf Debian-ähnlichen Distributionen für die ARM64-Architektur basiert, zielt dieser Fork auf Enterprise-Linux-Distributionen wie Rocky Linux ab, das auf der x86_64-Architektur läuft.

In diesem Labor generieren Sie [Kubernetes-Client-Konfigurationsdateien](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/), die normalerweise als `kubeconfigs` bezeichnet werden. Diese Dateien konfigurieren Kubernetes-Clients für die Verbindung mit Kubernetes-API-Servern und die Authentifizierung bei diesen.

## Client-Authentifizierungskonfigurationen

In diesem Abschnitt generieren Sie Kubeconfig-Dateien für den Benutzer `kubelet` und `admin`.

### Die `kubelet` Kubernetes-Konfigurationsdatei

Beim Generieren von Kubeconfig-Dateien für Kubelets müssen Sie das Client-Zertifikat mit dem Knotennamen des Kubelets abgleichen. Dadurch wird sichergestellt, dass Kubelets ordnungsgemäß vom Kubernetes [Node Authorizer](https://kubernetes.io/docs/reference/access-authn-authz/node/) autorisiert werden.

> Die folgenden Befehle müssen im selben Verzeichnis ausgeführt werden, das zum Generieren der SSL-Zertifikate während des Labors [Generieren von TLS-Zertifikaten](lab4-certificate-authority.md) verwendet wurde.

Generieren Sie eine Kubeconfig-Datei für die Worker-Knoten `node-0` und `node-1`:

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

Ergebnisse:

```text
node-0.kubeconfig
node-1.kubeconfig
```

### Die `kube-proxy` Kubernetes-Konfigurationsdatei

Generieren Sie eine Kubeconfig-Datei für den Dienst `kube-proxy`:

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

Ergebnisse:

```text
kube-proxy.kubeconfig
```

### Die Kubernetes-Konfigurationsdatei `kube-controller-manager`

Generieren Sie eine Kubeconfig-Datei für den Dienst `kube-controller-manager`:

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

Ergebnisse:

```text
kube-controller-manager.kubeconfig
```

### Die Kubernetes-Konfigurationsdatei `kube-scheduler`

Generieren Sie eine Kubeconfig-Datei für den Dienst `kube-scheduler`:

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

Ergebnisse:

```text
kube-scheduler.kubeconfig
```

### Die Kubernetes-Konfigurationsdatei des Administrators

Generieren Sie eine Kubeconfig-Datei für den Benutzer `admin`:

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

Ergebnisse:

```text
admin.kubeconfig
```

## Verteilen der Kubernetes-Konfigurationsdateien

Kopieren Sie die Kubeconfig-Dateien `kubelet` und `kube-proxy` in die Instanzen `node-0` und `node-1`:

```bash
for host in node-0 node-1; do
  ssh root@$host "mkdir /var/lib/{kube-proxy,kubelet}"
  
  scp kube-proxy.kubeconfig \
    root@$host:/var/lib/kube-proxy/kubeconfig \
  
  scp ${host}.kubeconfig \
    root@$host:/var/lib/kubelet/kubeconfig
done
```

Kopieren Sie die Kubeconfig-Dateien `kube-controller-manager` und `kube-scheduler` in die Controller-Instanz:

```bash
scp admin.kubeconfig \
  kube-controller-manager.kubeconfig \
  kube-scheduler.kubeconfig \
  root@server:~/
```

Fortsetzung folgt: [Konfiguration der Datenverschlüsselung]ä(lab6-data-encryption-keys.md)
