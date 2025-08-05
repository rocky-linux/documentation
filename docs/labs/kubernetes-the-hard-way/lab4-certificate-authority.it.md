---
author: Wale Soyinka
contributors: Steven Spencer, Ganna Zhyrnova
tags:
  - kubernetes
  - k8s
  - lab exercise
---

# Laboratorio 4: Provisioning di una CA e generazione di certificati TLS

!!! info

    Si tratta di un fork dell'originale ["Kubernetes the hard way"](https://github.com/kelseyhightower/kubernetes-the-hard-way) scritto originariamente da Kelsey Hightower (GitHub: kelseyhightower). A differenza dell'originale, che si basa su distribuzioni simili a Debian per l'architettura ARM64, questo fork si rivolge a distribuzioni Enterprise Linux come Rocky Linux, che gira su architettura x86_64.

In questo laboratorio, si provvederà alla fornitura di un'[infrastruttura PKI](https://en.wikipedia.org/wiki/Public_key_infrastructure) utilizzando OpenSSL per avviare un'autorità di certificazione e generare certificati TLS per i seguenti componenti:

- kube-apiserver
- kube-controller-manager
- kube-scheduler
- kubelet
- kube-proxy

Eseguire i comandi di questa sezione dalla `jumpbox`.

## Autorità di certificazione

In questa sezione, si provvederà al provisioning di un'autorità di certificazione che verrà utilizzata per generare ulteriori certificati TLS per gli altri componenti di Kubernetes. L'impostazione della CA e la generazione dei certificati con `openssl` possono richiedere molto tempo, soprattutto se si tratta della prima volta. Per ottimizzare questo laboratorio, è necessario includere un file di configurazione `openssl`, `ca.conf`, che definisce tutti i dettagli necessari per generare certificati per ciascun componente Kubernetes.

Prendetevi un momento per rivedere il file di configurazione `ca.conf`:

```bash
cat ca.conf
```

Per completare questa esercitazione, non è necessario comprendere tutto ciò che è contenuto nel file `ca.conf`. Tuttavia, dovreste considerarlo come un punto di partenza per imparare a usare `openssl` e la configurazione necessaria per gestire i certificati di alto livello.

Ogni autorità di certificazione inizia con una chiave privata e un certificato radice. In questa sezione, si creerà un'autorità di certificazione autofirmata, che è tutto ciò che serve per questa esercitazione, ma che non dovrebbe essere presa in considerazione in un ambiente di produzione reale.

Generare il file di configurazione della CA, il certificato e la chiave privata:

```bash
  openssl genrsa -out ca.key 4096
  openssl req -x509 -new -sha512 -noenc \
    -key ca.key -days 3653 \
    -config ca.conf \
    -out ca.crt
```

Risultati:

```txt
ca.crt ca.key
```

!!! tip "Suggerimento"

    Per visualizzare i dettagli codificati nel file del certificato generato (ca.crt), è possibile utilizzare il comando OpenSSL `openssl x509 -in ca.crt -text -noout | less`.

## Creazione dei certificati client e server

In questa sezione, si genereranno i certificati client e server per ogni componente Kubernetes e un certificato client per l'utente Kubernetes `admin`.

Generare i certificati e le chiavi private:

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

I risultati del comando di cui sopra genereranno una chiave privata, una richiesta di certificato e un certificato SSL firmato per ogni componente di Kubernetes. È possibile elencare i file generati con il seguente comando:

```bash
ls -1 *.crt *.key *.csr
```

## Distribuzione dei certificati del client e del server

In questa sezione, si copieranno i vari certificati su ogni macchina utilizzando un percorso in cui ogni componente Kubernetes cercherà la propria coppia di certificati. In un ambiente reale, questi certificati verrebbero trattati come un insieme di segreti sensibili, perché Kubernetes utilizza questi componenti come credenziali per l'autenticazione reciproca.

Copiare i certificati e le chiavi private appropriate sulle macchine `node-0` e `node-1`:

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

Copiare i certificati e le chiavi private appropriate sul computer `server`:

```bash
scp \
  ca.key ca.crt \
  kube-api-server.key kube-api-server.crt \
  service-accounts.key service-accounts.crt \
  root@server:~/
```

Nel prossimo laboratorio, si utilizzeranno i certificati client `kube-proxy`, `kube-controller-manager`, `kube-scheduler` e `kubelet` per generare i file di configurazione dell'autenticazione client.

Successivo: [Generazione dei file di configurazione di Kubernetes per l'autenticazione](lab5-kubernetes-configuration-files.md)
