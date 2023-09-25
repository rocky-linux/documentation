---
author: Hayden Young
contributors: Steven Spencer, Sambhav Saggi, Antoine Le Morvan, Krista Burdine, Ganna Zhyrnova
---

# Autenticazione Active Directory

## Prerequisiti

- Alcune conoscenze di Active Directory
- Alcune conoscenze di LDAP

## Introduzione

Nella maggior parte delle aziende, Active Directory (AD) di Microsoft è il sistema di autenticazione predefinito per i sistemi Windows e per i servizi esterni collegati a LDAP. Consente di configurare utenti e gruppi, controllo degli accessi, autorizzazioni, montaggio automatico e altro ancora.

Ora, mentre la connessione di Linux a un cluster AD non può supportare _tutte_ le funzionalità menzionate, può gestire utenti, gruppi e controllo degli accessi. È possibile (attraverso alcune modifiche di configurazione sul lato Linux e alcune opzioni avanzate sul lato AD) distribuire chiavi SSH utilizzando AD.

Questa guida, tuttavia, tratterà solo la configurazione dell'autenticazione rispetto ad Active Directory e non includerà alcuna configurazione aggiuntiva sul lato Windows.

## Scoprire e unire AD utilizzando SSSD

!!! Note "Nota"

    In questa guida il nome di dominio `ad.company.local` rappresenterà il dominio Active Directory. Per seguire questa guida, sostituitelo con il nome effettivo del dominio AD.

Il primo passo per unire un sistema Linux ad AD è quello di rilevare il cluster AD, per assicurarsi che la configurazione di rete sia corretta su entrambi i lati.

### Preparazione

- Assicurarsi che le seguenti porte siano aperte per l'host Linux sul domain controller:

  | Servizio | Porta(e)          | Note                                                       |
  | -------- | ----------------- | ---------------------------------------------------------- |
  | DNS      | 53 (TCP+UDP)      |                                                            |
  | Kerberos | 88, 464 (TCP+UDP) | Usato da `kadmin` per impostare & aggiornare le password   |
  | LDAP     | 389 (TCP+UDP)     |                                                            |
  | LDAP-GC  | 3268 (TCP)        | LDAP Global Catalog - consente di generare ID utenti da AD |

- Assicurarsi di aver configurato il domain controller AD come server DNS sull'host Rocky Linux:

  **Con NetworkManager:**

  ```sh
  # dove la tua connessione principale a NetworkManager è 'System eth0' e il tuo server AD
  # è accessibile all'indirizzo IP 10.0.0.2.
  [root@host ~]$ nmcli con mod 'System eth0' ipv4.dns 10.0.0.2
  ```

- Assicurarsi che l'ora su entrambi i lati (host AD e sistema Linux) sia sincronizzata (vedere chronyd)

  **Per verificare l'ora su Rocky Linux:**

  ```sh
  [user@host ~]$ date
  Mer 22 set 17:11:35 BST 2021
  ```

- Installare i pacchetti richiesti per la connessione AD sul lato Linux:

  ```sh
  [user@host ~]$ sudo dnf install realmd oddjob oddjob-mkhomedir ssd adcli krb5-workstation
  ```


### Scoprire

Ora dovreste essere in grado di rilevare i vostri server AD dall'host Linux.

```sh
[user@host ~]$ realm discover ad.company.local
ad.company.local
  type: kerberos
  realm-name: AD.COMPANY.LOCAL
  domain-name: ad.company. ocal
  configured: no
  server-software: active-directory
  client-software: ssd
  required-package: oddjob
  required-package: oddjob-mkhomedir
  required-package: ssd
  required-package: adcli
  required-package: samba-common
```

Questo viene rilevato utilizzando i record SRV pertinenti memorizzati nel servizio DNS di Active Directory.

### Unirsi

Una volta rilevata con successo l'installazione di Active Directory dall'host Linux, si dovrebbe essere in grado di usare `realmd` per unirsi al dominio, che organizzerà la configurazione di `sssd` usando `adcli` e altri strumenti simili.

```sh
[user@host ~]$ sudo realm join ad.company.local
```

Se questo processo si lamenta della crittografia con `KDC has no support for encryption type`, prova ad aggiornare la politica globale di crittografia per consentire gli algoritmi di crittografia più vecchi:

```sh
[user@host ~]$ sudo update-crypto-policies --set DEFAULT:AD-SUPPORT
```

Se questo processo ha successo, dovreste essere in grado di estrarre le informazioni `passwd` di un utente di Active Directory.

```sh
[user@host ~]$ sudo getent passwd administrator@ad.company.local
administrator@ad.company.local:*:1450400500:1450400513:Amministrator:/home/administrator@ad.company.local:/bin/bash
```

!!! Note "Nota" 

    `getent` ottiene voci dalle librerie Name Service Switch (NSS). Significa che, al contrario di `passwd` o `dig` per esempio, interrogherà diversi database, tra cui `/etc/hosts` per `getent hosts` o da `sssd` nel caso di `getent passwd`.

`realm` fornisce alcune opzioni interessanti che si possono utilizzare:

| Opzione                                                    | Osservazione                                                      |
| ---------------------------------------------------------- | ----------------------------------------------------------------- |
| --computer-ou='OU=LINUX,OU=SERVERS,dc=ad,dc=company.local' | L'OU in cui memorizzare l'account del server                      |
| --os-name='rocky'                                          | Specificare il nome del sistema operativo memorizzato in AD       |
| --os-version='8'                                           | Specificare la versione del sistema operativo memorizzata nell'AD |
| -U admin_username                                          | Specificare un account di amministratore                          |

### Tentativo di Autenticazione

Ora gli utenti dovrebbero essere in grado di autenticarsi all'host Linux tramite Active Directory.

**Su Windows 10:** (che fornisce la propria copia di OpenSSH)

```
C:\Users\John.Doe> ssh -l john.doe@ad.company.local linux.host
Password for john.doe@ad.company.local:

Activate the web console with: systemctl enable --now cockpit.socket

Last login: Wed Sep 15 17:37:03 2021 from 10.0.10.241
[john.doe@ad.company.local@host ~]$
```

Se l'operazione ha successo, si è configurato Linux per utilizzare Active Directory come fonte di autenticazione.

### Impostazione del dominio predefinito

In una configurazione completamente predefinita, è necessario accedere con il proprio account AD specificando il dominio nel nome utente (ad esempio, `john.doe@ad.company.local`). Se questo non è il comportamento desiderato e si vuole invece poter omettere il nome del dominio al momento dell'autenticazione, è possibile configurare SSSD in modo che abbia come default un dominio specifico.

Si tratta di un processo relativamente semplice, che richiede una modifica al file di configurazione di SSSD.

```sh
[user@host ~]$ sudo vi /etc/sssd/sssd.conf
[sssd]
...
default_domain_suffix = ad.company.local
```

Aggiungendo il suffisso `default_domain_suffix`, si indica a SSSD di dedurre (se non viene specificato un altro dominio) che l'utente sta cercando di autenticarsi come utente del dominio `ad.company.local`. Ciò consente di autenticarsi come `john.doe` invece di `john.doe@ad.company.local`.

Per rendere effettiva questa modifica della configurazione, è necessario riavviare l'unità `sssd.service` con `systemctl`.

```sh
[user@host ~]$ sudo systemctl restart sssd
```

Allo stesso modo, se non si vuole che le directory home abbiano il suffisso del nome di dominio, si possono aggiungere queste opzioni nel file di configurazione `/etc/sssd/sssd.conf`:

```
[domain/ad.company.local]
use_fully_qualified_names = False
override_homedir = /home/%u
```

Non dimenticare di riavviare il servizio `ssd`.

### Limita a determinati utenti

Esistono vari metodi per limitare l'accesso al server a un elenco limitato di utenti, ma questo, come suggerisce il nome, è certamente il più semplice:

Aggiungete queste opzioni nel file di configurazione `/etc/sssd/sssd.conf` e riavviate il servizio:

```
access_provider = simple
simple_allow_groups = group1, group2
simple_allow_users = user1, user2
```

Ora, solo gli utenti del gruppo1 e del gruppo2, o l'utente1 e l'utente2 saranno in grado di connettersi al server utilizzando sssd!

## Interagire con l'AD utilizzando `adcli`

`adcli` è una CLI per eseguire azioni su un dominio Active Directory.

- Se non è ancora installato, installare il pacchetto richiesto:

```sh
[user@host ~]$ sudo dnf install adcli
```

- Verificate se vi siete mai uniti a un dominio Active Directory:

```sh
[user@host ~]$ sudo adcli testjoin
Successfully validated join to domain ad.company.local
```

- Ottenere informazioni più avanzate sul dominio:

```sh
[user@host ~]$ adcli info ad.company.local
[domain]
domain-name = ad.company.local
domain-short = AD
domain-forest = ad.company.local
domain-controller = dc1.ad.company.local
domain-controller-site = site1
domain-controller-flags = gc ldap ds kdc timeserv closest writable full-secret ads-web
domain-controller-usable = yes
domain-controllers = dc1.ad.company.local dc2.ad.company.local
[computer]
computer-site = site1
```

- Più che uno strumento di consultazione, potete usare adcli per interagire con il vostro dominio: gestire utenti o gruppi, cambiare password, ecc.

Esempio: usare `adcli` per ottenere informazioni su un computer:

!!! Note "Nota"

    Questa volta forniremo un nome utente amministratore grazie all'opzione `-U`

```sh
[user@host ~]$ adcli show-computer pctest -U admin_username
Password for admin_username@AD: 
sAMAccountName:
 pctest$
userPrincipalName:
 - not set -
msDS-KeyVersionNumber:
 9
msDS-supportedEncryptionTypes:
 24
dNSHostName:
 pctest.ad.company.local
servicePrincipalName:
 RestrictedKrbHost/pctest.ad.company.local
 RestrictedKrbHost/pctest
 host/pctest.ad.company.local
 host/pctest
operatingSystem:
 Rocky
operatingSystemVersion:
 8
operatingSystemServicePack:
 - not set -
pwdLastSet:
 133189248188488832
userAccountControl:
 69632
description:
 - not set -
```

Esempio: usare `adcli` per cambiare la password dell'utente:

```sh
[user@host ~]$ adcli passwd-user user_test -U admin_username
Password for admin_username@AD: 
Password for user_test: 
[user@host ~]$ 
```

## Risoluzione dei problemi

A volte, il servizio di rete si avvia dopo l'SSSD, causando problemi con l'autenticazione.

Nessun utente AD potrà connettersi fino al riavvio del servizio.

In questo caso, si dovrà sovrascrivere il file di servizio di systemd per gestire questo problema.

Copiare questo contenuto in `/etc/systemd/system/sssd.service`:

```
[Unit]
Description=System Security Services Daemon
# SSSD must be running before we permit user sessions
Before=systemd-user-sessions.service nss-user-lookup.target
Wants=nss-user-lookup.target
After=network-online.target


[Service]
Environment=DEBUG_LOGGER=--logger=files
EnvironmentFile=-/etc/sysconfig/sssd
ExecStart=/usr/sbin/sssd -i ${DEBUG_LOGGER}
Type=notify
NotifyAccess=main
PIDFile=/var/run/sssd.pid

[Install]
WantedBy=multi-user.target
```

Al successivo riavvio, il servizio si avvierà in base ai suoi requisiti e tutto andrà bene.

## Uscire da Active Directory

A volte è necessario abbandonare l'AD.

È possibile, ancora una volta, procedere con `realm` e poi rimuovere i pacchetti non più necessari:

```sh
[user@host ~]$ sudo realm leave ad.company.local
[user@host ~]$ sudo dnf remove realmd oddjob oddjob-mkhomedir sssd adcli krb5-workstation
```
