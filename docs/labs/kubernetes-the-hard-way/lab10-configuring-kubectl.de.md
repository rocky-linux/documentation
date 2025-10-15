---
author: Wale Soyinka
contributors: Steven Spencer
tags:
  - kubernetes
  - k8s
  - Laborübung
  - runc
  - containerd
  - etcd
  - kubectl
---

# Labor 10: Konfigurieren von kubectl für den Remotezugriff

!!! info

    Dies ist ein Fork des ursprünglichen ["Kubernetes the hard way"](https://github.com/kelseyhightower/kubernetes-the-hard-way), das ursprünglich von Kelsey Hightower geschrieben wurde (GitHub: kelseyhightower). Im Gegensatz zum Original, das auf Debian-ähnlichen Distributionen für die ARM64-Architektur basiert, zielt dieser Fork auf Enterprise-Linux-Distributionen wie Rocky Linux ab, das auf der x86_64-Architektur läuft.

In diesem Labor generieren Sie basierend auf den Benutzeranmeldeinformationen `admin` eine Kubeconfig-Datei für das Befehlszeilenprogramm `kubectl`.

> Führen Sie Befehle in diesem Abschnitt aus der `jumpbox` aus.

## The Admin Kubernetes Configuration File

Für jede Kubeconfig ist ein Kubernetes-API-Server zur Verbindung erforderlich.

Basierend auf dem DNS-Eintrag „/etc/hosts“ aus einem früheren Labor sollten Sie in der Lage sein, „server.kubernetes.local“ anzupingen.

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

Generieren Sie eine Kubeconfig-Datei, die für die Authentifizierung als `admin`-Benutzer geeignet ist:

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

Die Ergebnisse der Ausführung des obigen Befehls sollten eine Kubeconfig-Datei am Standardspeicherort `~/.kube/config` erstellen, der vom Befehlszeilentool `kubectl` verwendet wird. Dies bedeutet auch, dass Sie den Befehl `kubectl` ausführen können, ohne eine Konfiguration anzugeben.

## Verifizierung

Überprüfen Sie die Version des Remote-Kubernetes-Clusters:

```bash
kubectl version
```

```text
Client Version: v1.32.0
Kustomize Version: v5.5.0
Server Version: v1.32.0
```

Listen Sie die Knoten im Remote-Kubernetes-Cluster auf:

```bash
kubectl get nodes
```

```text
NAME     STATUS   ROLES    AGE   VERSION
node-0   Ready    <none>   30m   v1.31.2
node-1   Ready    <none>   35m   v1.31.2
```

Fortsetzung folgt: [Provisionierung der Pod-Netzwerk-Routen](lab11-pod-network-routes.md)
