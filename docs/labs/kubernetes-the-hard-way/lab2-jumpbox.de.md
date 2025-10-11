---
author: Wale Soyinka
contributors: Steven Spencer, Ganna Zhyrnova
tags:
  - kubernetes
  - k8s
  - Laborübung
---

# Labor 2: Einrichten der Jumpbox

!!! info

    Dies ist ein Fork des ursprünglichen ["Kubernetes the hard way"](https://github.com/kelseyhightower/kubernetes-the-hard-way), das ursprünglich von Kelsey Hightower geschrieben wurde (GitHub: kelseyhightower). Im Gegensatz zum Original, das auf Debian-ähnlichen Distributionen für die ARM64-Architektur basiert, zielt dieser Fork auf Enterprise-Linux-Distributionen wie Rocky Linux ab, das auf der x86_64-Architektur läuft.

In diesem Labor richten Sie eine der vier Maschinen als „Jumpbox“ ein. Sie werden diese Maschine verwenden, um in diesem Tutorial Befehle auszuführen. Obwohl zur Gewährleistung der Konsistenz eine dedizierte Maschine verwendet wird, können Sie diese Befehle von nahezu jeder Maschine aus ausführen, einschließlich Ihrer persönlichen Workstation mit macOS oder Linux.

Stellen Sie sich die `jumpbox` als die Verwaltungsmaschine vor, die Sie als Basis verwenden, wenn Sie Ihren Kubernetes-Cluster von Grund auf einrichten. Bevor Sie beginnen, müssen Sie einige Befehlszeilenprogramme installieren und das Git-Repository `Kubernetes The Hard Way` klonen. Dieses enthält einige zusätzliche Konfigurationsdateien, die Sie im Verlauf dieses Lernprogramms zum Konfigurieren verschiedener Kubernetes-Komponenten verwenden werden.

Melden Sie sich bei der `jumpbox` an:

```bash
ssh root@jumpbox
```

Der Einfachheit halber führen Sie alle Befehle als `root`-Benutzer aus, wodurch die Anzahl der zum Einrichten erforderlichen Befehle reduziert wird.

## Installation der Command Line Utilities

Sobald Sie sich als `root`-Benutzer bei der `jumpbox`-Maschine angemeldet haben, installieren Sie die Befehlszeilenprogramme, die Sie im Verlauf des Lernprogramms zum Ausführen verschiedener Aufgaben verwenden werden:

```bash
sudo dnf -y install wget curl vim openssl git
```

## Synchronisation der GitHub-Repository

Jetzt ist es an der Zeit, eine Kopie dieses Tutorials herunterzuladen, das die Konfigurationsdateien und Vorlagen enthält, die Sie zum Erstellen Ihres Kubernetes-Clusters von Grund auf verwenden werden. Klonen Sie das `Kubernetes The Hard Way`-Git-Repository mit dem Befehl `git`:

```bash
git clone --depth 1 \
  https://github.com/wsoyinka/kubernetes-the-hard-way.git
```

Wechseln Sie in das Verzeichnis `kubernetes-the-hard-way`:

```bash
cd kubernetes-the-hard-way
```

Dies wird das Arbeitsverzeichnis für den Rest des Tutorials sein. Wenn Sie einmal nicht weiterkommen, führen Sie den Befehl `pwd` aus, um zu überprüfen, ob Sie sich im richtigen Verzeichnis befinden, wenn Sie Befehle auf der `jumpbox` ausführen:

```bash
pwd
```

```text
/root/kubernetes-the-hard-way
```

## Herunterladen der Binaries

Hier laden Sie die Binärdateien für die verschiedenen Kubernetes-Komponenten herunter. Speichern Sie diese Binärdateien im Verzeichnis `Downloads` auf der `jumpbox`. Dadurch wird die zum Abschließen dieses Lernprogramms erforderliche Internetbandbreite reduziert, da Sie die Binärdateien nicht für jede Maschine in unserem Kubernetes-Cluster mehrmals herunterladen müssen.

Die Datei `download.txt` listet die Binärdateien auf, die Sie herunterladen werden. Sie können diese mit dem Befehl `cat` überprüfen:

```bash
cat downloads.txt
```

Laden Sie die in der Datei `downloads.txt` aufgeführten Binärdateien mit dem Befehl `wget` in ein Verzeichnis namens `downloads` herunter:

```bash
wget -q --show-progress \
  --https-only \
  --timestamping \
  -P downloads \
  -i downloads.txt
```

Abhängig von der Geschwindigkeit Ihrer Internetverbindung kann das Herunterladen der `584` Megabyte Binärdateien eine Weile dauern. Sobald der Download abgeschlossen ist, können Sie sie mit dem Befehl `ls` auflisten:

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

## Installation von `kubectl`

In diesem Abschnitt installieren Sie `kubectl`, das offizielle Befehlszeilentool des Kubernetes-Clients, auf der `jumpbox`-Maschine. Sie werden `kubectl` verwenden, um mit der Kubernetes-Steuerebene zu interagieren, nachdem die Bereitstellung Ihres Clusters später in diesem Tutorial abgeschlossen ist.

Verwenden Sie den Befehl `chmod`, um die Binärdatei `kubectl` ausführbar zu machen und sie in das Verzeichnis `/usr/local/bin/` zu verschieben:

```bash
  chmod +x downloads/kubectl
  cp downloads/kubectl /usr/local/bin/
```

Da Ihre Installation von `kubectl` abgeschlossen ist, können Sie dies überprüfen, indem Sie den Befehl `kubectl` ausführen:

```bash
kubectl version --client
```

```text
Client Version: v1.32.0
Kustomize Version: v5.5.0
```

An diesem Punkt haben Sie eine `jumpbox` mit allen Befehlszeilentools und Dienstprogrammen eingerichtet, die zum Abschließen der Übungen in diesem Lernprogramm erforderlich sind.

Fortsetzung folgt: [Provisionierung der Computer-Ressourcen](lab3-compute-resources.md)
