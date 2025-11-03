---
author: Wale Soyinka
contributors: Steven Spencer, Ganna Zhyrnova
tags:
  - kubernetes
  - k8s
  - Laborübung
  - runc
  - containerd
  - etcd
  - kubectl
---

# Labor 9: Bootstrapping der Kubernetes-Worker-Knoten

!!! info

    Dies ist ein Fork des ursprünglichen ["Kubernetes the hard way"](https://github.com/kelseyhightower/kubernetes-the-hard-way), das ursprünglich von Kelsey Hightower geschrieben wurde (GitHub: kelseyhightower). Im Gegensatz zum Original, das auf Debian-ähnlichen Distributionen für die ARM64-Architektur basiert, zielt dieser Fork auf Enterprise-Linux-Distributionen wie Rocky Linux ab, das auf der x86_64-Architektur läuft.

In diesem Labor werden Sie zwei Kubernetes-Workerknoten bootstrappen. Sie installieren die folgenden Komponenten: [runc](https://github.com/opencontainers/runc), [Container-Netzwerk-Plugins](https://github.com/containernetworking/cni), [containerd](https://github.com/containerd/containerd), [kubelet](https://kubernetes.io/docs/reference/command-line-tools-reference/kubelet/) und [kube-proxy](https://kubernetes.io/docs/concepts/cluster-administration/proxies).

## Voraussetzungen

Kopieren Sie aus der `jumpbox` Kubernetes-Binärdateien und `systemd`-Unit-Dateien in jede Worker-Instanz:

```bash
for host in node-0 node-1; do
  SUBNET=$(grep $host machines.txt | cut -d " " -f 5)
  sed "s|SUBNET|$SUBNET|g" \
    configs/10-bridge.conf > 10-bridge.conf 
    
  sed "s|SUBNET|$SUBNET|g" \
    configs/kubelet-config.yaml > kubelet-config.yaml
    
  scp 10-bridge.conf kubelet-config.yaml \
  root@$host:~/
done
```

```bash
for host in node-0 node-1; do
  scp \
    downloads/runc.amd64 \
    downloads/crictl-v1.32.0-linux-amd64.tar.gz \
    downloads/cni-plugins-linux-amd64-v1.6.2.tgz \
    downloads/containerd-2.0.3-linux-amd64.tar.gz \
    downloads/kubectl \
    downloads/kubelet \
    downloads/kube-proxy \
    configs/99-loopback.conf \
    configs/containerd-config.toml \
    configs/kubelet-config.yaml \
    configs/kube-proxy-config.yaml \
    units/containerd.service \
    units/kubelet.service \
    units/kube-proxy.service \
    root@$host:~/
done
```

Die Befehle in diesem Labor müssen auf jeder Workerinstanz separat ausgeführt werden: `node-0` und `node-1`. Es werden nur die Schritte für `node-0` beschrieben. Sie müssen die genauen Schritte und Befehle auf `node-1` wiederholen.

Melden Sie sich mit dem Befehl `ssh` bei der Worker-Instanz `node-0` an.

```bash
ssh root@node-0
```

## Bereitstellen eines Kubernetes-Worker-Knotens

Installieren Sie die Betriebssystemabhängigkeiten:

```bash
  dnf -y update
  dnf -y install socat conntrack ipset tar
```

> Die Binärdatei `socat` unterstützt den Befehl `kubectl port-forward`.

### Swap-Deaktivierung

Wenn Sie [Swap](https://help.ubuntu.com/community/SwapFaq) aktiviert haben, kann das Kubelet nicht gestartet werden. Die [Empfehlung lautet, Swap zu deaktivieren](https://github.com/kubernetes/kubernetes/issues/7294), um sicherzustellen, dass Kubernetes eine angemessene Ressourcenzuweisung und Servicequalität bietet.

Überprüfen Sie, ob der Swap aktiviert ist:

```bash
swapon --show
```

Wenn die Ausgabe leer ist, ist der Swap nicht aktiviert. Wenn die Ausgabe nicht leer ist, führen Sie den folgenden Befehl aus, um den Swap sofort zu deaktivieren:

```bash
swapoff -a
```

Um sicherzustellen, dass der Swap nach dem Neustart deaktiviert bleibt, kommentieren Sie die Zeile aus, die das Swap-Volume in der Datei `/etc/fstab` automatisch einbindet. Geben Sie bitte Folgendes ein:

```bash
sudo sed -i '/swap/s/^/#/' /etc/fstab
```

Erstellen Sie die Installationsverzeichnisse:

```bash
mkdir -p \
  /etc/cni/net.d \
  /opt/cni/bin \
  /var/lib/kubelet \
  /var/lib/kube-proxy \
  /var/lib/kubernetes \
  /var/run/kubernetes
```

Installieren Sie die Worker-Binärdateien:

```bash
  mkdir -p containerd
  tar -xvf crictl-v1.32.0-linux-amd64.tar.gz
  tar -xvf containerd-2.0.3-linux-amd64.tar.gz -C containerd
  tar -xvf cni-plugins-linux-amd64-v1.6.2.tgz -C /opt/cni/bin/
  mv runc.amd64 runc
  chmod +x crictl kubectl kube-proxy kubelet runc 
  mv crictl kubectl kube-proxy kubelet runc /usr/local/bin/
  mv containerd/bin/* /bin/
```

### Konfigurieren des CNI-Netzwerks

Erstellen Sie die Netzwerkkonfigurationsdatei `bridge`:

```bash
mv 10-bridge.conf 99-loopback.conf /etc/cni/net.d/
```

### Konfiguration von `containerd`

Installieren Sie die `containerd`-Konfigurationsdateien:

```bash
  mkdir -p /etc/containerd/
  mv containerd-config.toml /etc/containerd/config.toml
  mv containerd.service /etc/systemd/system/
```

### Kubelet-Konfiguration

Erstellen Sie die Konfigurationsdatei `kubelet-config.yaml`:

```bash
  mv kubelet-config.yaml /var/lib/kubelet/
  mv kubelet.service /etc/systemd/system/
```

### Konfigurieren des Kubernetes-Proxys

```bash
  mv kube-proxy-config.yaml /var/lib/kube-proxy/
  mv kube-proxy.service /etc/systemd/system/
```

!!! note "Anmerkung"

    Obwohl dies als unzureichende Sicherheit gilt, müssen Sie SELinux möglicherweise vorübergehend oder dauerhaft deaktivieren, wenn beim Starten der erforderlichen systemd-Dienste Probleme auftreten. Die richtige Lösung besteht darin, die erforderlichen Richtliniendateien mit Tools wie `ausearch`, `audit2allow` usw. zu analysieren und zu erstellen.
    
    Um SELinux zu entfernen und zu deaktivieren, gehen Sie wie folgt vor:

  ```bash
  sudo sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
  setenforce 0
  ```

### Starten Sie die Worker-Dienste

```bash
  systemctl daemon-reload
  systemctl enable containerd kubelet kube-proxy
  systemctl start containerd kubelet kube-proxy
```

## Verifizierung

Die in diesem Lernprogramm erstellten Compute-Instanzen verfügen nicht über die Berechtigung, diesen Überprüfungsabschnitt abzuschließen. Führen Sie die folgenden Befehle von der `jumpbox`-Maschine aus.

Listen Sie die registrierten Kubernetes-Knoten auf:

```bash
ssh root@server "kubectl get nodes --kubeconfig admin.kubeconfig"
```

```text
NAME     STATUS   ROLES    AGE    VERSION
node-0   Ready    <none>   1m     v1.32.0
```

Nachdem Sie alle vorherigen Schritte in diesem Labor sowohl auf `node-0` als auch auf `node-1` abgeschlossen haben, sollte die Ausgabe des Befehls `kubectl get nodes` Folgendes anzeigen:

```text
NAME     STATUS   ROLES    AGE    VERSION
node-0   Ready    <none>   1m     v1.32.0
node-1   Ready    <none>   10s    v1.32.0
```

Fortsetzung folgt: [Konfiguration von kubectl für Remote-Access](lab10-configuring-kubectl.md)
