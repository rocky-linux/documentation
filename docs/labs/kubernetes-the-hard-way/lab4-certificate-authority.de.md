---
author: Wale Soyinka
contributors: Steven Spencer, Ganna Zhyrnova
tags:
  - kubernetes
  - k8s
  - Laborübung
---

# Labor 4: Bereitstellung einer Zertifizierungsstelle und Generieren von TLS-Zertifikaten

!!! info

    Dies ist ein Fork des ursprünglichen ["Kubernetes the hard way"](https://github.com/kelseyhightower/kubernetes-the-hard-way), das ursprünglich von Kelsey Hightower geschrieben wurde (GitHub: kelseyhightower). Im Gegensatz zum Original, das auf Debian-ähnlichen Distributionen für die ARM64-Architektur basiert, zielt dieser Fork auf Enterprise-Linux-Distributionen wie Rocky Linux ab, das auf der x86_64-Architektur läuft.

In diesem Labor stellen wir eine [PKI-Infrastruktur](https://en.wikipedia.org/wiki/Public_key_infrastructure) mit OpenSSL bereit, um eine Zertifizierungsstelle zu betreiben und TLS-Zertifikate für die folgenden Komponenten zu generieren:

- kube-apiserver
- kube-controller-manager
- kube-scheduler
- kubelet
- kube-proxy

Führen Sie Befehle in diesem Abschnitt aus der `jumpbox` aus.

## Zertifizierungsstelle

In diesem Abschnitt stellen Sie eine Zertifizierungsstelle bereit, die Sie zum Generieren zusätzlicher TLS-Zertifikate für die anderen Kubernetes-Komponenten verwenden. Das Einrichten einer Zertifizierungsstelle und das Generieren von Zertifikaten mit `openssl` kann zeitaufwändig sein, insbesondere wenn Sie dies zum ersten Mal tun. Um dieses Labor zu optimieren, muss eine `OpenSSL`-Konfigurationsdatei, `ca.conf`, eingefügt werden, die alle Details definiert, die zum Generieren von Zertifikaten für jede Kubernetes-Komponente erforderlich sind.

Nehmen Sie sich einen Moment Zeit, um die Konfigurationsdatei `ca.conf` zu überprüfen:

```bash
cat ca.conf
```

Um dieses Lernprogramm abzuschließen, müssen Sie nicht alles in der Datei `ca.conf` verstehen. Dennoch sollten Sie es als Ausgangspunkt für das Erlernen von `openssl` und der Konfiguration betrachten, die für die Verwaltung von Zertifikaten auf hoher Ebene erforderlich ist.

Jede Zertifizierungsstelle beginnt mit einem privaten Schlüssel und einem Stammzertifikat. In diesem Abschnitt erstellen Sie eine selbst-signierte Zertifizierungsstelle. Dies ist zwar alles, was Sie für dieses Tutorial benötigen, in einer realen Produktionsumgebung sollten Sie dies jedoch nicht in Betracht ziehen.

Generieren Sie die CA-Konfigurationsdatei, das Zertifikat und den privaten Schlüssel:

```bash
  openssl genrsa -out ca.key 4096
  openssl req -x509 -new -sha512 -noenc \
    -key ca.key -days 3653 \
    -config ca.conf \
    -out ca.crt
```

Ergebnisse:

```txt
ca.crt ca.key
```

!!! tip "Hinweis"

    Um die in der generierten Zertifikatsdatei (`ca.crt`) codierten Details anzuzeigen, können Sie diesen OpenSSL-Befehl verwenden:
    `openssl x509 -in ca.crt -text -noout | less`.  
    

## Erstellen von Client- und Serverzertifikaten

In diesem Abschnitt generieren Sie Client- und Serverzertifikate für jede Kubernetes-Komponente und ein Clientzertifikat für den Kubernetes-Benutzer `admin`.

Generieren Sie die Zertifikate und privaten Schlüssel:

```bash
certs=(
  "admin" "node-0" "node-1"
  "kube-proxy" "kube-scheduler"
  "kube-controller-manager"
  "kube-api-server"
  "service-accounts"
)
```

```bash
for i in ${certs[*]}; do
  openssl genrsa -out "${i}.key" 4096

  openssl req -new -key "${i}.key" -sha256 \
    -config "ca.conf" -section ${i} \
    -out "${i}.csr"
  
  openssl x509 -req -days 3653 -in "${i}.csr" \
    -copy_extensions copyall \
    -sha256 -CA "ca.crt" \
    -CAkey "ca.key" \
    -CAcreateserial \
    -out "${i}.crt"
done
```

Die Ergebnisse des obigen Befehls generieren einen privaten Schlüssel, eine Zertifikatsanforderung und ein signiertes SSL-Zertifikat für jede Kubernetes-Komponente. Mit dem folgenden Befehl können Sie die generierten Dateien auflisten:

```bash
ls -1 *.crt *.key *.csr
```

## Verteilen der Client- und Serverzertifikate

In diesem Abschnitt kopieren Sie die verschiedenen Zertifikate mithilfe eines Pfads auf jede Maschine, in dem jede Kubernetes-Komponente nach ihrem Zertifikatspaar sucht. In einer realen Umgebung würden Sie diese Zertifikate als eine Reihe vertraulicher Geheimnisse behandeln, da Kubernetes diese Komponenten als Anmeldeinformationen zur gegenseitigen Authentifizierung verwendet.

Kopieren Sie die entsprechenden Zertifikate und privaten Schlüssel auf die Maschinen `node-0` und `node-1`:

```bash
for host in node-0 node-1; do
  ssh root@$host mkdir /var/lib/kubelet/
  
  scp ca.crt root@$host:/var/lib/kubelet/
    
  scp $host.crt \
    root@$host:/var/lib/kubelet/kubelet.crt
    
  scp $host.key \
    root@$host:/var/lib/kubelet/kubelet.key
done
```

Kopieren Sie die entsprechenden Zertifikate und privaten Schlüssel auf die `server`-Maschine:

```bash
scp \
  ca.key ca.crt \
  kube-api-server.key kube-api-server.crt \
  service-accounts.key service-accounts.crt \
  root@server:~/
```

Im nächsten Labor werden wir die Client-Zertifikate `kube-proxy`, `kube-controller-manager`, `kube-scheduler` und `kubelet` verwenden, um Konfigurationsdateien für die Client-Authentifizierung zu generieren.

Fortsetzung folgt: [Kubernetes-Authentifizierung](lab5-kubernetes-configuration-files.md)
