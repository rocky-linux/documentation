---
author: Wale Soyinka
contributors: Steven Spencer, Ganna Zhyrnova
tags:
  - kubernetes
  - k8s
  - Laborübung
  - kubectl
  - etcd
  - runc
---

# Labor 8: Bootstrapping der Kubernetes-Steuerebene

!!! info

    Dies ist ein Fork des ursprünglichen ["Kubernetes the hard way"](https://github.com/kelseyhightower/kubernetes-the-hard-way), das ursprünglich von Kelsey Hightower geschrieben wurde (GitHub: kelseyhightower). Im Gegensatz zum Original, das auf Debian-ähnlichen Distributionen für die ARM64-Architektur basiert, zielt dieser Fork auf Enterprise-Linux-Distributionen wie Rocky Linux ab, das auf der x86_64-Architektur läuft.

In diesem Labor werden Sie die Kubernetes-Steuerebene bootstrappen. Sie werden die folgenden Komponenten auf der Controller-Maschine installieren:
Kubernetes API Server, Scheduler und Controller Manager.

## Voraussetzungen

Stellen Sie eine Verbindung zur `jumpbox` her und kopieren Sie Kubernetes-Binärdateien und `systemd`-Unit-Dateien in die `server`-Instanz:

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

Sie müssen die Befehle in den folgenden Abschnitten dieses Labors auf dem `server`-Computer ausführen. Melden Sie sich mit dem Befehl `ssh` bei der Controller-Instanz an. Beispiel:

```bash
ssh root@server
```

## Bereitstellen der Kubernetes-Steuerebene

Erstellen Sie das Kubernetes-Konfigurationsverzeichnis:

```bash
mkdir -p /etc/kubernetes/config
```

### Installieren Sie die Binärdateien des Kubernetes-Controllers

Installieren Sie die Kubernetes-Binärdateien:

```bash
  chmod +x kube-apiserver \
    kube-controller-manager \
    kube-scheduler kubectl
    
  mv kube-apiserver \
    kube-controller-manager \
    kube-scheduler kubectl \
    /usr/local/bin/
```

### Konfigurieren des Kubernetes-API-Servers

```bash
  mkdir -p /var/lib/kubernetes/

  mv ca.crt ca.key \
    kube-api-server.key kube-api-server.crt \
    service-accounts.key service-accounts.crt \
    encryption-config.yaml \
    /var/lib/kubernetes/
```

Erstellen Sie die `systemd`-Unit-Datei `kube-apiserver.service`:

```bash
mv kube-apiserver.service /etc/systemd/system/kube-apiserver.service
```

### Konfigurieren des Kubernetes Controller Managers

Verschieben Sie die kubeconfig `kube-controller-manager` an die richtige Stelle:

```bash
mv kube-controller-manager.kubeconfig /var/lib/kubernetes/
```

Erstellen Sie die `systemd`-Unit-Datei `kube-controller-manager.service`:

```bash
mv kube-controller-manager.service /etc/systemd/system/
```

### Konfigurieren des Kubernetes-Schedulers

Verschieben Sie die kubeconfig `kube-scheduler` an die richtige Stelle:

```bash
mv kube-scheduler.kubeconfig /var/lib/kubernetes/
```

Erstellen Sie die Konfigurationsdatei `kube-scheduler.yaml`:

```bash
mv kube-scheduler.yaml /etc/kubernetes/config/
```

Erstellen Sie die Systemd-Unit-Datei `kube-scheduler.service`:

```bash
mv kube-scheduler.service /etc/systemd/system/
```

### Starten Sie die Controller-Dienste

```bash
  systemctl daemon-reload
  
  systemctl enable kube-apiserver \
    kube-controller-manager kube-scheduler
    
  systemctl start kube-apiserver \
    kube-controller-manager kube-scheduler
```

> Warten Sie bis zu 10 Sekunden, bis der Kubernetes-API-Server vollständig initialisiert ist.

### Verifizierung

```bash
kubectl cluster-info   --kubeconfig admin.kubeconfig
```

```text
Die Kubernetes-Steuerebene läuft unter https://127.0.0.1:6443
```

## RBAC für die Kubelet-Autorisierung

In diesem Abschnitt konfigurieren Sie `RBAC`-Berechtigungen, um dem `Kubernetes`-API-Server den Zugriff auf die `Kubelet`-API auf jedem Worker-Knoten zu ermöglichen. Zum Abrufen von Metriken und Protokollen sowie zum Ausführen von Befehlen in `Pods` ist Zugriff auf die `Kubelet`-API erforderlich.

> Dieses Tutorial setzt das Kubelet-Flag `--authorization-mode` auf `Webhook`. Der Webhook\`-Modus verwendet die API [SubjectAccessReview](https://kubernetes.io/docs/reference/kubernetes-api/authorization-resources/subject-access-review-v1/), um die Autorisierung zu bestimmen.

Führen Sie die Befehle in diesem Abschnitt auf dem Controller-Knoten aus, was sich auf den gesamten Cluster auswirkt.

```bash
ssh root@server
```

Erstellen Sie die Clusterrolle `system:kube-apiserver-to-kubelet` [ClusterRole](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#role-and-clusterrole) mit Berechtigungen für den Zugriff auf die Kubelet-API und führen Sie die gängigsten Aufgaben im Zusammenhang mit der Verwaltung von Pods aus:

```bash
kubectl apply -f kube-apiserver-to-kubelet.yaml \
  --kubeconfig admin.kubeconfig
```

### Verifizierung von `RBAC`

Zu diesem Zeitpunkt ist die Kubernetes-Steuerebene betriebsbereit. Führen Sie die folgenden Befehle von der `jumpbox`-Maschine aus, um zu überprüfen, ob sie funktioniert:

Stellen Sie eine HTTP-Anfrage für die Kubernetes-Versionsinformationen:

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

Fortsetzung folgt: [Bootstrapping the Kubernetes Worker Nodes](lab9-bootstrapping-kubernetes-workers.md)
