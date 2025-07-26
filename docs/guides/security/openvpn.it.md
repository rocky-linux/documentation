---
title: OpenVPN
author: Joseph Brinkman
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 9.4
tags:
  - security
  - vpn
---

## Introduzione

[OpenVPN](https://openvpn.net/) è una rete privata virtuale (VPN) gratuita e open-source. Questo articolo vi guiderà nella configurazione di OpenVPN con l'infrastruttura a chiave pubblica (PKI) X509. Questa guida richiede un sistema Rocky Linux con un indirizzo IP pubblico, poiché OpenVPN opera su un modello client/server. Il modo più semplice per raggiungere questo obiettivo è quello di creare un server privato virtuale (VPS) attraverso un provider cloud di vostra scelta. Al momento in cui scriviamo, Google Cloud Platform offre un livello gratuito per le sue istanze e2-micro. Se state cercando la configurazione più semplice di OpenVPN utilizzando una VPN punto-punto (p2p) senza PKI, fate riferimento al loro [Static Key Mini-HOWTO](https://openvpn.net/community-resources/static-key-mini-howto/).

## Prerequisiti e presupposti

I requisiti minimi per questa procedura sono i seguenti:

- La possibilità di eseguire comandi come utente root o di utilizzare `sudo` per elevare i privilegi
- Un sistema Rocky Linux con un IP accessibile pubblicamente

## Installare OpenVPN

Installare il repository Extra Packages for Enterprise Linux (EPEL):

```bash
sudo dnf install epel-release -y
```

Installare OpenVPN:

```bash
sudo dnf install openvpn -y
```

## Configurare l'autorità di certificazione

Installare easy-rsa:

```bash
sudo dnf install easy-rsa -y
```

Creare la directory `easy-rsa` in `/etc/openvpn`:

```bash
sudo mkdir /etc/openvpn/easy-rsa
```

Crea un collegamento simbolico ai file easy-rsa:

```bash
sudo ln -s /usr/share/easy-rsa /etc/openvpn/easy-rsa
```

Cambiare la directory in `/etc/openvpn/easy-rsa`:

```bash
cd /etc/openvpn/easy-rsa
```

Eseguire lo script `easyrsa` con il parametro `init-pki` per inizializzare la PKI dell'autorità di certificazione:

```bash
sudo ./easy-rsa/3/easyrsa init-pki
```

Eseguire lo script `easyrsa` con i parametri `build-ca` e `nopass` per creare l'Autorità di certificazione senza password:

```bash
sudo ./easy-rsa/3/easyrsa build-ca nopass
```

## Creare certificati

Eseguire lo script `easyrsa` con i parametri `gen-req` e `nopass` per generare il certificato del server senza password:

```bash
sudo ./easy-rsa/3/easyrsa gen-req server nopass
```

Eseguire lo script `easyrsa` con i parametri `sign-req` e `server` per firmare il certificato del server:

```bash
sudo ./easy-rsa/3/easyrsa sign-req server server
```

!!! Note

```
È possibile ripetere i passaggi seguenti tutte le volte che si desidera per altri client.
```

Eseguire lo script `easyrsa` con i parametri `gen-req` e `nopass` per generare certificati client senza password:

```bash
sudo ./easy-rsa/3/easyrsa gen-req client1 nopass
```

Eseguire lo script `easyrsa` con i parametri `sign-req` e `client` per firmare i certificati client senza password:

```bash
sudo ./easy-rsa/3/easyrsa sign-req client client1
```

OpenVPN richiede i parametri Diffie Hellman. Eseguire questo comando per generarli:

```bash
sudo ./easy-rsa/3/easyrsa gen-dh
```

## Configurare OpenVPN

Una volta completata la creazione della PKI, è il momento di configurare OpenVPN.

Copiare il file di esempio `server.conf` in `/etc/openvpn`:

```bash
sudo cp /usr/share/doc/openvpn/sample/sample-config-files/server.conf /etc/openvpn
```

Utilizzare l'editor preferito per aprire e scrivere il file `server.conf`:

```bash
sudo vim /etc/openvpn/server.conf
```

Successivamente, è necessario aggiungere i percorsi dei file dell'autorità di certificazione, del certificato del server e della chiave del server al file di configurazione del server OpenVPN.

Copiare e incollare i percorsi dei file delle chiavi e dei certificati alle righe 78-80:

!!! Note

```
In Vim, è possibile aggiungere numeri di riga alla modifica in corso con `:set nu`
```

```bash
ca /etc/openvpn/easy-rsa/pki/ca.crt
cert /etc/openvpn/easy-rsa/pki/issued/server.crt
key /etc/openvpn/easy-rsa/pki/private/server.key  # This file should be kept secret
```

Copiare e incollare il percorso del file Diffie Hellman alla riga 85 del file di esempio `server.conf`:

```bash
dh /etc/openvpn/easy-rsa/pki/dh.pem
```

OpenVPN utilizza SSL per impostazione predefinita, ma può opzionalmente utilizzare TLS. Questa guida utilizza il protocollo SSL.

Commentare i valori della coppia di chiavi `tls-auth ta.key` alla riga 244:

```bash
#tls-auth ta.key 0 # This file is secret
```

Salvare prima di chiudere `server.conf`.

## Configurare il firewall

OpenVPN funziona sulla porta UDP 1194 per impostazione predefinita. Si utilizzerà `firewalld` per consentire il traffico OpenVPN nel server.

Installare `firewalld`:

```bash
sudo dnf install firewalld -y
```

Abilitare `firewalld`:

```bash
sudo systemctl enable --now firewalld
```

Consentire OpenVPN attraverso il firewall aggiungendolo come servizio:

```bash
sudo firewall-cmd --add-service=openvpn --permanent
```

Attivate la traduzione degli indirizzi di rete (NAT) e nascondete gli indirizzi IP pubblici dei client aggiungendo una regola di masquerade al firewall:

```bash
sudo firewall-cmd --add-masquerade --permanent
```

Ricaricare il firewall:

```bash
sudo firewall-cmd --reload
```

## Configurare il routing

Consentire l'inoltro IP con il seguente comando:

```bash
sudo sysctl -w net.ipv4.ip_forward=1
```

## Avviare il server OpenVPN

Secondo la [documentazione OpenVPN](https://openvpn.net/community-resources/how-to/#starting-up-the-vpn-and-testing-for-initial-connectivity), "è meglio avviare inizialmente il server OpenVPN dalla riga di comando":

```bash
sudo openvpn /etc/openvpn/server.conf
```

Dopo aver avviato OpenVPN, premere `Ctrl + Z`, quindi inviare il lavoro in background:

```bash
bg
```

## Configurazione e avvio del client

Oltre al server, per funzionare è necessario installare OpenVPN su tutti i client. Installare OpenVPN sul client, se non lo si è già fatto:

```bash
sudo dnf install openvpn -y
```

Creare nuove directory per memorizzare le chiavi, i certificati e il file di configurazione del client:

```bash
sudo mkdir -p /etc/openvpn/pki`
```

Ora copiate le chiavi e i certificati utilizzando un metodo di trasporto sicuro e inseriteli in `/etc/openvpn/pki`. Alcuni modi potenziali per farlo sono i protocolli SFTP o SCP. Consultate la guida Rocky Linux [SSH Public and Private Key](https://docs.rockylinux.org/guides/security/ssh_public_private_keys/) per configurare l'accesso SSH.

Si tratta dei certificati e delle chiavi necessari per la configurazione del client e dei relativi percorsi dei file sul server:

- ca.crt
- client1.crt
- client1.key

Dopo aver memorizzato i certificati e le chiavi necessarie in `/etc/openvpn/pki`, copiare il file di esempio `client.conf` in `/etc/openvpn`:

```bash
sudo cp /usr/share/doc/openvpn/sample/sample-config-files/client.conf /etc/openvpn
```

Aprire `client.conf` con un editor di propria scelta:

```bash
sudo vim /etc/openvpn/client.conf`
```

Mappare i percorsi dei file dei certificati e delle chiavi necessari nel file di configurazione del client. È possibile farlo copiando e incollando queste righe di testo nelle righe 88-90 del file di esempio:

```bash
ca /etc/openvpn/pki/ca.crt
cert /etc/openvpn/pki/client1.crt
key /etc/openvpn/pki/client1.key
```

È inoltre necessario impostare il nome host o l'IP del server. È possibile lasciare la porta UDP predefinita 1194. Nel file di esempio, questo si trova alla riga 42:

```bash
remote server 1194
```

Salvare prima di uscire da `client.conf`.

Avviare OpenVPN sul client:

```bash
sudo openvpn /etc/openvpn/client.conf
```

Dopo aver avviato OpenVPN, premere `Ctrl + Z` e inviare il lavoro in background:

```bash
bg
```

Eseguite il comando seguente per visualizzare i lavori in esecuzione in background:

```bash
jobs
```

Inviare un ping di prova al server. Per impostazione predefinita, il suo indirizzo privato è `10.8.0.1`:

```bash
ping 10.8.0.1
```

## Conclusione

Ora dovreste avere il vostro server OpenVPN attivo e funzionante! Con questa configurazione di base, avete assicurato un tunnel privato per la comunicazione dei vostri sistemi su Internet. Tuttavia, OpenVPN è altamente personalizzabile e questa guida lascia molto all'immaginazione. È possibile approfondire la conoscenza di OpenVPN consultando il suo [sito web] (https://www.openvpn.net). È anche possibile leggere ulteriori informazioni su OpenVPN direttamente sul sistema - `man openvpn` - utilizzando la pagina man.
