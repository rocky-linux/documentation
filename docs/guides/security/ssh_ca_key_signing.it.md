---
title: Autorità di certificazione SSH e firma delle chiavi
author: Julian Patocki
contributors: Steven Spencer, Ganna Zhyrnova
tags:
  - security
  - ssh
  - keygen
  - certificati
---

## Prerequisiti

- Capacità di utilizzare strumenti a riga di comando
- Gestione dei contenuti dalla riga di comando
- L'esperienza precedente con la generazione di chiavi SSH è utile ma non necessaria
- Una conoscenza di base di SSH e dell'infrastruttura a chiave pubblica è utile ma non necessaria
- Un server che esegue il demone sshd.

## Introduzione

La connessione iniziale SSH con un host remoto è insicura se non è possibile verificare l'impronta digitale della chiave dell'host remoto. L'uso di un'autorità di certificazione per firmare le chiavi pubbliche degli host remoti rende la connessione iniziale sicura per ogni utente che si fida della CA.

Le CA possono essere utilizzate anche per firmare le chiavi SSH degli utenti. Invece di distribuire la chiave a ogni host remoto, una sola firma è sufficiente per autorizzare l'utente ad accedere a più server.

## Obiettivi

- Migliorare la sicurezza delle connessioni SSH.
- Migliorare il processo di inserimento e della gestione delle chiavi.

## Note

- Vim è l'editor di testo scelto dall'autore. L'uso di altri editor di testo, come nano o altri, è perfettamente accettabile.
- L'uso di `sudo` o `root` implica privilegi elevati.

## Connessione iniziale

Per proteggere la connessione iniziale, è necessario conoscere in anticipo l'impronta digitale della chiave. È possibile ottimizzare e integrare questo processo di distribuzione per i nuovi host.

Visualizzazione dell'impronta digitale della chiave sull'host remoto:

```bash
user@rocky-vm ~]$ ssh-keygen -E sha256 -l -f /etc/ssh/ssh_host_ed25519_key.pub 
256 SHA256:bXWRZCpppNWxXs8o1MyqFlmfO8aSG+nlgJrBM4j4+gE no comment (ED25519)
```

Effettuare la connessione iniziale SSH dal client. L'impronta digitale della chiave viene visualizzata e può essere confrontata con quella acquisita in precedenza:

```bash
[user@rocky ~]$ ssh user@rocky-vm.example.com
The authenticity of host 'rocky-vm.example (192.168.56.101)' can't be established.
ED25519 key fingerprint is SHA256:bXWRZCpppNWxXs8o1MyqFlmfO8aSG+nlgJrBM4j4+gE.
This key is not known by any other names
Are you sure you want to continue connecting (yes/no/[fingerprint])?
```

## Creazione di una certificazione di autorità

Creare una CA (chiave privata e pubblica) e inserire la chiave pubblica nel file `known_hosts` del client per identificare tutti gli host appartenenti al dominio example.com:

```bash
[user@rocky ~]$ ssh-keygen -b 4096 -t ed25519 -f CA
[user@rocky ~]$ echo '@cert-authority *.example.com' $(cat CA.pub) >> ~/.ssh/known_hosts
```

Dove:

- **-b**: lunghezza della chiave in byte
- **-t**: tipo di chiave: rsa, ed25519, ecdsa...
- **-f**: file chiave di output

In alternativa, è possibile specificare il file `known_hosts` a livello di sistema modificando il file di configurazione SSH `/etc/ssh/ssh_config`:

```bash
Host *
    GlobalKnownHostsFile /etc/ssh/ssh_known_hosts
```

## Firma delle chiavi pubbliche

Creare una chiave SSH utente e firmarla:

```bash
[user@rocky ~]$ ssh-keygen -b 4096 -t ed2119
[user@rocky ~]$ ssh-keygen -s CA -I user -n user -V +55w  id_ed25519.pub
```

Acquisire la chiave pubblica del server tramite `scp` e firmarla:

```bash
[user@rocky ~]$ scp user@rocky-vm.example.com:/etc/ssh/ssh_host_ed25519_key.pub .
[user@rocky ~]$ ssh-keygen -s CA -I rocky-vm -n rocky-vm.example.com -h -V +55w ssh_host_ed25519_key.pub
```

Dove:

- **-s**: chiave di firma
- **-I**: nome che identifica il certificato a scopo di registrazione
- **-n**: identifica il nome (host o utente, uno o più) associato al certificato (se non viene specificato, i certificati sono validi per tutti gli utenti o host)
- **-h**: definisce il certificato come chiave host, anziché come chiave client
- **-V**: periodo di validità del certificato

## Stabilire la fiducia

Copiare il certificato dell'host remoto per presentarlo insieme alla sua chiave pubblica durante la connessione:

```bash
[user@rocky ~]$ scp ssh_host_ed25519_key-cert.pub root@rocky-vm.example.com:/etc/ssh/
```

Copiare la chiave pubblica della CA sull'host remoto per far sì che questo si fidi dei certificati firmati dalla CA:

```bash
[user@rocky ~]$ scp CA.pub root@rocky-vm.example.com:/etc/ssh/
```

Aggiungere le righe seguenti al file `/etc/ssh/sshd_config` per specificare la chiave e il certificato precedentemente copiati da utilizzare dal server e fidarsi della CA per identificare gli utenti:

```bash
[user@rocky ~]$ ssh user@rocky-vm.example.com
[user@rocky-vm ~]$ sudo vim /etc/ssh/sshd_config
```

```bash
HostKey /etc/ssh/ssh_host_ed25519_key
HostCertificate /etc/ssh/ssh_host_ed25519_key-cert.pub
TrustedUserCAKeys /etc/ssh/CA.pub
```

Riavviare il servizio `sshd` sul server:

```bash
[user@rocky-vm ~]$ systemctl restart sshd
```

## Verifica della connessione

Rimuovere l'impronta digitale del server remoto dal file `known_hosts` e verificare le impostazioni stabilendo una connessione SSH:

```bash
[user@rocky ~]$ ssh-keygen -R rocky-vm.example.com
[user@rocky ~]$ ssh user@rocky-vm.example.com
```

## Revoca della chiave

La revoca delle chiavi host o utente può essere fondamentale per la sicurezza dell'intero ambiente. Pertanto, è importante conservare le chiavi pubbliche precedentemente firmate in modo da poterle revocare in un secondo momento.

Creare un elenco di revoca vuoto e revocare la chiave pubblica dell'utente2:

```bash
[user@rocky ~]$ sudo ssh-keygen -k -f /etc/ssh/revokation_list.krl
[user@rocky ~]$ sudo ssh-keygen -k -f /etc/ssh/revokation_list.krl -u /path/to/user2_id_ed25519.pub
```

Copiare l'elenco di revoca sull'host remoto e specificarlo nel file `sshd_config`:

```bash
[user@rocky ~]$ scp /etc/ssh/revokation_list.krl root@rocky-vm.example.com:/etc/ssh/
[user@rocky ~]$ ssh user@rocky-vm.example.com
[user@rocky ~]$ sudo vim /etc/ssh/sshd_config
```

La riga seguente specifica l'elenco di revoca:

```bash
RevokedKeys /etc/ssh/revokation_list.krl
```

È necessario riavviare il demone SSHD per ricaricare la configurazione:

```bash
[user@rocky-vm ~]$ sudo systemctl restart sshd
```

L'utente2 viene rifiutato dal server:

```bash
[user2@rocky ~]$ ssh user2@rocky-vm.example.com
user2@rocky-vm.example.com: Permission denied (publickey,gssapi-keyex,gssapi-with-mic).
```

È possibile anche revocare le chiavi del server:

```bash
[user@rocky ~]$ sudo ssh-keygen -k -f /etc/ssh/revokation_list.krl -u /path/to/ssh_host_ed25519_key.pub
```

Le righe seguenti in `/etc/ssh/ssh_config` applicano l'elenco di revoca degli host a livello di sistema:

```bash
Host *
        RevokedHostKeys /etc/ssh/revokation_list.krl
```

Se si tenta di connettersi all'host, si ottiene il seguente risultato:

```bash
[user@rocky ~]$ ssh user@rocky-vm.example.com
Host key ED25519-CERT SHA256:bXWRZCpppNWxXs8o1MyqFlmfO8aSG+nlgJrBM4j4+gE revoked by file /etc/ssh/revokation_list.krl
```

È importante mantenere e aggiornare gli elenchi di revoca. È possibile automatizzare il processo per garantire che tutti gli host e gli utenti possano accedere agli elenchi di revoca più recenti.

## Conclusione

SSH è uno dei protocolli più validi per gestire i server remoti. L'implementazione di autorità di certificazione può essere utile, soprattutto in ambienti di grandi dimensioni con molti server e utenti.
È importante mantenere elenchi di revoca. Revoca facilmente le chiavi compromesse senza sostituire l'intera infrastruttura critica.
