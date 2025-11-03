---
author: Wale Soyinka
contributors: Steven Spencer
tags:
  - kubernetes
  - k8s
  - Laborübung
---

# Labor 3: Bereitstellen von Rechenressourcen

!!! info

    Dies ist ein Fork des ursprünglichen ["Kubernetes the hard way"](https://github.com/kelseyhightower/kubernetes-the-hard-way), das ursprünglich von Kelsey Hightower geschrieben wurde (GitHub: kelseyhightower). Im Gegensatz zum Original, das auf Debian-ähnlichen Distributionen für die ARM64-Architektur basiert, zielt dieser Fork auf Enterprise-Linux-Distributionen wie Rocky Linux ab, das auf der x86_64-Architektur läuft.

Kubernetes erfordert eine Reihe von Maschinen zum Hosten der Kubernetes-Steuerebene und der Worker-Knoten, auf denen die Container letztendlich ausgeführt werden. In diesem Labor stellen Sie die zum Einrichten eines Kubernetes-Clusters erforderlichen Maschinen bereit.

## Maschinen-Datenbank

In diesem Lernprogramm wird eine Textdatei genutzt, die als Maschinendatenbank dient, um die verschiedenen Maschinenattribute zu speichern, die Sie beim Einrichten der Kubernetes-Steuerebene und der Worker-Knoten verwenden. Das folgende Schema stellt Einträge in der Maschinendatenbank dar, ein Eintrag pro Zeile:

```text
IPV4_ADDRESS FQDN HOSTNAME POD_SUBNET
```

Jede Spalte entspricht einer Maschinen-IP-Adresse `IPV4_ADDRESS`, einem vollqualifizierten Domänennamen `FQDN`, einem Hostnamen `HOSTNAME` und dem IP-Subnetz `POD_SUBNET`. Kubernetes weist pro `Pod` eine IP-Adresse zu und `POD_SUBNET` stellt den eindeutigen IP-Adressbereich dar, der jeder Maschine im Cluster hierfür zugewiesen wird.

Hier ist ein Beispiel für eine Maschinendatenbank, die der Datenbank ähnelt, die zum Erstellen dieses Tutorials verwendet wurde. Bitte werfen Sie einen Blick auf die versteckten IP -Adressen. Sie können Ihren Maschinen jede beliebige IP-Adresse zuweisen, sofern diese untereinander und über die `jumpbox` erreichbar sind.

```bash
cat machines.txt
```

```text
XXX.XXX.XXX.XXX server.kubernetes.local server  
XXX.XXX.XXX.XXX node-0.kubernetes.local node-0 10.200.0.0/24
XXX.XXX.XXX.XXX node-1.kubernetes.local node-1 10.200.1.0/24
```

Jetzt sind Sie an der Reihe, eine `machines.txt`-Datei mit den Details zu den drei Maschinen zu erstellen, die Sie zum Erstellen Ihres Kubernetes-Clusters verwenden werden. Sie können die Beispielmaschinendatenbank von oben verwenden, um die Details für Ihre Maschinen hinzuzufügen.

## Konfiguration des SSH-Zugriffs

Sie verwenden SSH, um die Maschinen im Cluster zu konfigurieren. Stellen Sie sicher, dass Sie über SSH-Zugriff als `root` auf alle in Ihrer Maschinendatenbank aufgeführten Maschinen verfügen. Möglicherweise müssen Sie den Root-SSH-Zugriff auf jedem Knoten aktivieren, indem Sie die Datei `sshd_config` aktualisieren und den SSH-Server neu starten.

### Aktivierung vom Root-SSH-Zugriff

Sie können diesen Abschnitt überspringen, wenn Sie für jeden Ihrer Computer über SSH-Zugriff als `root` verfügen.

Eine neue `Rocky Linux`-Installation deaktiviert standardmäßig den SSH-Zugriff für den `root`-Benutzer. Dies geschieht aus Sicherheitsgründen, da der `root`-Benutzer die vollständige administrative Kontrolle über Unix-ähnliche Systeme hat. Schwache Passwörter sind für mit dem Internet verbundene Maschinen untragbar. Wie bereits erwähnt, aktivieren Sie den `root`-Zugriff über SSH, um die Schritte in diesem Tutorial zu optimieren. Sicherheit ist ein Kompromiss; in diesem Fall optimieren Sie auf Komfort.

Melden Sie sich mit SSH und Ihrem Benutzerkonto bei jedem Computer an und wechseln Sie dann mit dem Befehl `su` zum `root`-Benutzer:

```bash
su - root
```

Bearbeiten Sie die SSH-Daemon-Konfigurationsdatei `/etc/ssh/sshd_config` und setzen Sie die Option `PermitRootLogin` auf `yes`:

```bash
sed -i \
  's/^#PermitRootLogin.*/PermitRootLogin yes/' \
  /etc/ssh/sshd_config
```

Starten Sie den SSH-Server `sshd` neu, um die aktualisierte Konfigurationsdatei abzurufen:

```bash
systemctl restart sshd
```

### Generierung und Verteilung der SSH-Schlüssel

Hier generieren und verteilen Sie ein SSH-Schlüsselpaar an die Maschinen `server`, `node-0` und `node-1`, das Sie im Verlauf dieses Lernprogramms zum Ausführen von Befehlen auf diesen Maschinen verwenden werden. Führen Sie die folgenden Befehle vom `jumpbox`-Rechner aus.

Generieren Sie einen neuen SSH-Schlüssel:

```bash
ssh-keygen
```

Drücken Sie ++enter++, um alle Standardwerte für die Eingabeaufforderungen hier zu akzeptieren:

```text
Generating public/private rsa key pair.
Enter file in which to save the key (/root/.ssh/id_rsa): 
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /root/.ssh/id_rsa
Your public key has been saved in /root/.ssh/id_rsa.pub
```

Kopieren Sie den öffentlichen SSH-Schlüssel auf jeden Computer:

```bash
while read IP FQDN HOST SUBNET; do 
  ssh-copy-id root@${IP}
done < machines.txt
```

Nachdem Sie jeden Schlüssel hinzugefügt haben, überprüfen Sie, ob der SSH-Zugriff mit öffentlichem Schlüssel funktioniert:

```bash
while read IP FQDN HOST SUBNET; do 
  ssh -n root@${IP} uname -o -m
done < machines.txt
```

```text
x86_64 GNU/Linux
x86_64 GNU/Linux
x86_64 GNU/Linux
```

## Hostnamen

In diesem Abschnitt weisen Sie den Maschinen `server`, `node-0` und `node-1` Hostnamen zu. Sie verwenden den Hostnamen, wenn Sie Befehle von der `jumpbox` an die einzelnen Maschinen ausführen. Auch innerhalb des Clusters spielt der Hostname eine große Rolle. Anstatt dass Kubernetes-Clients eine IP-Adresse verwenden, um Befehle an den Kubernetes-API-Server zu senden, verwenden diese Clients stattdessen den Hostnamen `server`. Hostnamen werden auch von jeder Arbeitsmaschine, `node-0` und `node-1`, bei der Registrierung bei einem bestimmten Kubernetes-Cluster verwendet.

Um den Hostnamen für jede Maschine zu konfigurieren, führen Sie die folgenden Befehle auf der `jumpbox` aus.

Legen Sie den Hostnamen auf jedem Computer fest, der in der Datei `machines.txt` aufgeführt ist:

```bash
while read IP FQDN HOST SUBNET; do
    ssh -n root@${IP} cp /etc/hosts /etc/hosts.bak 
    CMD="sed -i 's/^127.0.0.1.*/127.0.0.1\t${FQDN} ${HOST}/' /etc/hosts"
    ssh -n root@${IP} "$CMD"
    ssh -n root@${IP} hostnamectl hostname ${HOST}
done < machines.txt
```

Überprüfen Sie den auf jedem Computer eingerichteten Hostnamen:

```bash
while read IP FQDN HOST SUBNET; do
  ssh -n root@${IP} hostname --fqdn
done < machines.txt
```

```text
server.kubernetes.local
node-0.kubernetes.local
node-1.kubernetes.local
```

## Host-Lookup-Tabelle

In diesem Abschnitt generieren Sie eine `hosts`-Datei und hängen sie an die Datei `/etc/hosts` auf `jumpbox` und an die `/etc/hosts`-Dateien auf allen drei Cluster-Mitgliedern an, die für dieses Tutorial verwendet werden. Dadurch ist jede Maschine über einen Hostnamen wie `server`, `node-0` oder `node-1` erreichbar.

Erstellen Sie eine neue „Hosts“-Datei und fügen Sie einen Header hinzu, um die hinzugefügten Maschinen zu identifizieren:

```bash
echo "" > hosts
echo "# Kubernetes The Hard Way" >> hosts
```

Erstellen Sie für jede Maschine einen Host-Eintrag in der Datei `machines.txt` und hängen Sie ihn an die Datei `hosts` an:

```bash
while read IP FQDN HOST SUBNET; do 
    ENTRY="${IP} ${FQDN} ${HOST}"
    echo $ENTRY >> hosts
done < machines.txt
```

Review the host entries in the `hosts` file:

```bash
cat hosts
```

```text

# Kubernetes The Hard Way
XXX.XXX.XXX.XXX server.kubernetes.local server
XXX.XXX.XXX.XXX node-0.kubernetes.local node-0
XXX.XXX.XXX.XXX node-1.kubernetes.local node-1
```

## Hinzufügen von `/etc/hosts`-Einträgen zu einem lokalen Computer

In diesem Abschnitt hängen Sie die DNS-Einträge aus der Datei `hosts` an die lokale Datei `/etc/hosts` auf Ihrem `jumpbox`-Computer an.

Hängen Sie die DNS-Einträge von `hosts` an `/etc/hosts` an:

```bash
cat hosts >> /etc/hosts
```

Überprüfen Sie die Aktualisierung der Datei `/etc/hosts`:

```bash
cat /etc/hosts
```

```text
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6

# Kubernetes The Hard Way
XXX.XXX.XXX.XXX server.kubernetes.local server
XXX.XXX.XXX.XXX node-0.kubernetes.local node-0
XXX.XXX.XXX.XXX node-1.kubernetes.local node-1
```

Sie sollten in der Lage sein, mit jedem in der Datei `machines.txt` aufgeführten Computer über einen Hostnamen eine SSH-Verbindung herzustellen.

```bash
for host in server node-0 node-1
   do ssh root@${host} uname -o -m -n
done
```

```text
server x86_64 GNU/Linux
node-0 x86_64 GNU/Linux
node-1 x86_64 GNU/Linux
```

## Hinzufügen von `/etc/hosts`-Einträgen zu den Remote-Maschinen

In diesem Abschnitt hängen Sie die Host-Einträge von `hosts` an `/etc/hosts` auf jedem Computer an, der in der Textdatei `machines.txt` aufgeführt ist.

Kopieren Sie die Datei `hosts` auf jeden Computer und hängen Sie den Inhalt an `/etc/hosts` an:

```bash
while read IP FQDN HOST SUBNET; do
  scp hosts root@${HOST}:~/
  ssh -n \
    root@${HOST} "cat hosts >> /etc/hosts"
done < machines.txt
```

Sie können Hostnamen verwenden, wenn Sie von Ihrer `jumpbox`-Maschine oder einer der drei Maschinen im Kubernetes-Cluster eine Verbindung zu Maschinen herstellen. Anstatt IP-Adressen zu verwenden, können Sie jetzt eine Verbindung zu Maschinen herstellen, indem Sie einen Hostnamen wie `server`, `node-0` oder `node-1` verwenden.

Weiter mit: [Bereitstellung einer CA und Generieren von TLS-Zertifikaten](lab4-certificate-authority.md)
