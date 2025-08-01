---
author: Wale Soyinka
contributors: Steven Spencer
tags:
  - kubernetes
  - k8s
  - lab exercise
---

# Laboratorio 3: Provisioning delle risorse di calcolo

!!! info

    Si tratta di un fork dell'originale ["Kubernetes the hard way"](https://github.com/kelseyhightower/kubernetes-the-hard-way) scritto originariamente da Kelsey Hightower (GitHub: kelseyhightower). A differenza dell'originale, che si basa su distribuzioni simili a Debian per l'architettura ARM64, questo fork si rivolge a distribuzioni Enterprise Linux come Rocky Linux, che gira su architettura x86_64.

Kubernetes richiede un insieme di macchine per ospitare il piano di controllo di Kubernetes e i nodi worker dove vengono eseguiti i container. In questo laboratorio, si forniranno le macchine necessarie per configurare un cluster Kubernetes.

## Database macchine

Questa esercitazione sfrutterà un file di testo, che servirà come database delle macchine, per memorizzare i vari attributi delle macchine che verranno utilizzati durante la configurazione del piano di controllo e dei nodi worker di Kubernetes. Il seguente schema rappresenta le voci del database delle macchine, una voce per riga:

```text
IPV4_ADDRESS FQDN HOSTNAME POD_SUBNET
```

Ogni colonna corrisponde a un indirizzo IP della macchina `IPV4_ADDRESS`, a un nome di dominio completamente qualificato `FQDN`, a un nome host `HOSTNAME` e alla sottorete IP `POD_SUBNET`. Kubernetes assegna un indirizzo IP per `pod` e il `POD_SUBNET` rappresenta l'intervallo di indirizzi IP unico assegnato a ciascuna macchina del cluster.

Ecco un esempio di database macchina simile a quello utilizzato per creare questa esercitazione. Date un'occhiata agli indirizzi IP nascosti. È possibile assegnare qualsiasi indirizzo IP alle macchine, purché siano raggiungibili tra loro e dalla `jumpbox`.

```bash
cat machines.txt
```

```text
XXX.XXX.XXX.XXX server.kubernetes.local server  
XXX.XXX.XXX.XXX node-0.kubernetes.local node-0 10.200.0.0/24
XXX.XXX.XXX.XXX node-1.kubernetes.local node-1 10.200.1.0/24
```

Ora tocca a voi creare un file `machines.txt` con i dettagli delle tre macchine che userete per creare il cluster Kubernetes. È possibile utilizzare l'esempio di database delle macchine di cui sopra per aggiungere i dettagli delle proprie macchine.

## Configurazione dell'accesso SSH

Si utilizzerà SSH per configurare le macchine del cluster. Verificare di avere accesso SSH `root` a ogni macchina elencata nel database. Potrebbe essere necessario abilitare l'accesso SSH root su ogni nodo aggiornando il file `sshd_config` e riavviando il server SSH.

### Abilitare l'accesso SSH di root

È possibile saltare questa sezione se si dispone di un accesso SSH `root` per ogni macchina.

Una nuova installazione di `Rocky Linux` disabilita l'accesso SSH per l'utente `root` per impostazione predefinita. Questo per ragioni di sicurezza, dato che l'utente `root' ha il controllo amministrativo totale dei sistemi Unix-like. Le password deboli sono terribili per le macchine connesse a Internet. Come accennato in precedenza, si abiliterà l'accesso `root\` su SSH per semplificare i passaggi di questa esercitazione. La sicurezza è un compromesso; in questo caso, si sta ottimizzando la convenienza.

Accedere a ogni macchina utilizzando SSH e il proprio account utente, quindi passare all'utente `root` con il comando `su`:

```bash
su - root
```

Modificare il file di configurazione del demone SSH `/etc/ssh/sshd_config` e impostare l'opzione `PermitRootLogin` su `yes`:

```bash
sed -i \
  's/^#PermitRootLogin.*/PermitRootLogin yes/' \
  /etc/ssh/sshd_config
```

Riavviare il server SSH `sshd` per caricare il file di configurazione aggiornato:

```bash
systemctl restart sshd
```

### Generare e distribuire le chiavi SSH

Qui si genererà e distribuirà una coppia di chiavi SSH alle macchine `server`, `node-0` e `node-1`, che verranno utilizzate per eseguire comandi su tali macchine nel corso di questa esercitazione. Eseguite i seguenti comandi dalla macchina `jumpbox`.

Generare una nuova chiave SSH:

```bash
ssh-keygen
```

Premete ++enter++ per accettare tutti i valori predefiniti delle richieste:

```text
Generating public/private rsa key pair.
Enter file in which to save the key (/root/.ssh/id_rsa): 
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /root/.ssh/id_rsa
Your public key has been saved in /root/.ssh/id_rsa.pub
```

Copiare la chiave pubblica SSH su ogni macchina:

```bash
while read IP FQDN HOST SUBNET; do 
  ssh-copy-id root@${IP}
done < machines.txt
```

Una volta aggiunta ogni chiave, verificare che l'accesso alla chiave pubblica SSH funzioni:

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

## Hostnames

In questa sezione, si assegneranno i nomi host alle macchine `server`, `node-0` e `node-1`. Si utilizzerà il nome dell'host quando si eseguiranno i comandi dalla `jumpbox` a ogni macchina. Anche il nome dell'host svolge un ruolo importante all'interno del cluster. Invece di utilizzare un indirizzo IP per inviare comandi al server API Kubernetes, i client Kubernetes utilizzeranno il nome host `server`. I nomi di host sono utilizzati anche da ogni macchina worker, `node-0` e `node-1`, quando si registra con un determinato cluster Kubernetes.

Per configurare l'hostname di ogni macchina, eseguire i seguenti comandi su `jumpbox`.

Impostare il nome host di ogni macchina elencata nel file `machines.txt`:

```bash
while read IP FQDN HOST SUBNET; do
    ssh -n root@${IP} cp /etc/hosts /etc/hosts.bak 
    CMD="sed -i 's/^127.0.0.1.*/127.0.0.1\t${FQDN} ${HOST}/' /etc/hosts"
    ssh -n root@${IP} "$CMD"
    ssh -n root@${IP} hostnamectl hostname ${HOST}
done < machines.txt
```

Verificare l'hostname impostato su ogni macchina:

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

## Tabella di ricerca host

In questa sezione, si genererà un file `hosts` e lo si aggiungerà al file `/etc/hosts` su `jumpbox` e ai file `/etc/hosts` su tutti e tre i membri del cluster utilizzati per questa esercitazione. In questo modo ogni macchina sarà raggiungibile con un nome di host come `server`, `node-0` o `node-1`.

Creare un nuovo file `hosts` e aggiungere un'intestazione per identificare le macchine da aggiungere:

```bash
echo "" > hosts
echo "# Kubernetes The Hard Way" >> hosts
```

Generare una voce di host per ogni macchina nel file `machines.txt` e aggiungerla al file `hosts`:

```bash
while read IP FQDN HOST SUBNET; do 
    ENTRY="${IP} ${FQDN} ${HOST}"
    echo $ENTRY >> hosts
done < machines.txt
```

Esaminare le voci degli host nel file `hosts`:

```bash
cat hosts
```

```text

# Kubernetes The Hard Way
XXX.XXX.XXX.XXX server.kubernetes.local server
XXX.XXX.XXX.XXX node-0.kubernetes.local node-0
XXX.XXX.XXX.XXX node-1.kubernetes.local node-1
```

## Aggiunta di voci `/etc/hosts` a una macchina locale

In questa sezione, si aggiungeranno le voci DNS dal file `hosts` al file locale `/etc/hosts` sulla macchina `jumpbox`.

Aggiungere le voci DNS da `hosts` a `/etc/hosts`:

```bash
cat hosts >> /etc/hosts
```

Verificare l'aggiornamento del file `/etc/hosts`:

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

Dovresti essere in grado di collegarti tramite SSH a ciascuna macchina elencata nel file `machines.txt` utilizzando un nome host.

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

## Aggiunta di voci `/etc/hosts` alle macchine remote

In questa sezione, si aggiungeranno le voci di host da `hosts` a `/etc/hosts` su ogni macchina elencata nel file di testo `machines.txt`.

Copiare il file `hosts` su ogni macchina e aggiungerne il contenuto a `/etc/hosts`:

```bash
while read IP FQDN HOST SUBNET; do
  scp hosts root@${HOST}:~/
  ssh -n \
    root@${HOST} "cat hosts >> /etc/hosts"
done < machines.txt
```

È possibile utilizzare i nomi host quando ci si connette alle macchine dalla propria macchina `jumpbox` o da una qualsiasi delle tre macchine del cluster Kubernetes. Invece di usare gli indirizzi IP, è ora possibile connettersi alle macchine usando un nome di host come `server`, `node-0` o `node-1`.

Successivo: [Provisioning di una CA e generazione di certificati TLS](lab4-certificate-authority.md)
