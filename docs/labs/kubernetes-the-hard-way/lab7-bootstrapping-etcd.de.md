---
author: Wale Soyinka
contributors: Steven Spencer, Ganna Zhyrnova
tags:
  - kubernetes
  - k8s
  - Laborübung
---

# Labor 7: Bootstrapping des `etcd`-Clusters

!!! info

    Dies ist ein Fork des ursprünglichen ["Kubernetes the hard way"](https://github.com/kelseyhightower/kubernetes-the-hard-way), das ursprünglich von Kelsey Hightower geschrieben wurde (GitHub: kelseyhightower). Im Gegensatz zum Original, das auf Debian-ähnlichen Distributionen für die ARM64-Architektur basiert, zielt dieser Fork auf Enterprise-Linux-Distributionen wie Rocky Linux ab, das auf der x86_64-Architektur läuft.

Kubernetes-Komponenten sind zustandslos und speichern den Clusterstatus in [etcd](https://github.com/etcd-io/etcd). In diesem Labor booten Sie einen `etcd`-Cluster mit drei Knoten und konfigurieren ihn für hohe Verfügbarkeit und sicheren Remotezugriff.

## Voraussetzungen

Kopieren Sie `etcd`-Binärdateien und `systemd`-Unit-Dateien in die `server`-Instanz:

```bash
scp \
  downloads/etcd-v3.4.36-linux-amd64.tar.gz \
  units/etcd.service \
  root@server:~/
```

Führen Sie die Befehle in den folgenden Abschnitten dieses Labors auf dem `server`-Computer aus. Melden Sie sich mit dem Befehl `ssh` beim `server`-Computer an. Beispiel:

```bash
ssh root@server
```

## Bootstrapping eines `etcd`-Clusters

### Installieren Sie die `etcd`-Binärdateien

Wenn Sie es noch nicht installiert haben, installieren Sie zuerst das Dienstprogramm `tar` mit `dnf`. Extrahieren und installieren Sie dann den `etcd`-Server und das `etcdctl`-Befehlszeilenprogramm:

```bash
  dnf -y install tar
  tar -xvf etcd-v3.4.36-linux-amd64.tar.gz
  mv etcd-v3.4.36-linux-amd64/etcd* /usr/local/bin/
```

### Konfigurieren Sie den `etcd`-Server

```bash
  mkdir -p /etc/etcd /var/lib/etcd
  chmod 700 /var/lib/etcd
  cp ca.crt kube-api-server.key kube-api-server.crt \
    /etc/etcd/
```

Jedes `etcd`-Mitglied muss innerhalb eines `etcd`-Clusters einen eindeutigen Namen haben. Legen Sie den `etcd`-Namen so fest, dass er mit dem Hostnamen der aktuellen Compute-Instanz übereinstimmt:

Erstellen Sie die `etcd.service` `systemd`-Unit-Datei:

```bash
mv etcd.service /etc/systemd/system/
chmod 644 /etc/systemd/system/etcd.service
```

!!! note "Anmerkung"

    Obwohl es als sicherheitsschädlich gilt, müssen Sie SELinux möglicherweise vorübergehend oder dauerhaft deaktivieren, wenn beim Starten des Dienstes `etcd` `systemd` Probleme auftreten. Die Lösung besteht darin, die erforderlichen Richtliniendateien mit Tools wie `ausearch`, `audit2allow` und anderen zu untersuchen und zu erstellen.
    
    Die folgenden Befehle entfernen SELinux und deaktivieren es:

  ```bash
  sudo sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
  setenforce 0
  ```

### Starten Sie den `etcd`-Server

```bash
  systemctl daemon-reload
  systemctl enable etcd
  systemctl start etcd
```

## Verifizierung

Listen Sie die `etcd`-Clustermitglieder auf:

```bash
etcdctl member list
```

```text
6702b0a34e2cfd39, started, controller, http://127.0.0.1:2380, http://127.0.0.1:2379, false
```

Fortsetzung folgt: [Bootstrapping the Kubernetes Control Plane](lab8-bootstrapping-kubernetes-controllers.md)
