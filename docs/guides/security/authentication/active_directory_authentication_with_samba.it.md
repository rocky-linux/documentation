---
title: Autenticazione Active Directory con Samba
author: Neel Chauhan
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 9.4
---

## Prerequisiti

- Conoscenza di Active Directory
- Conoscenza di LDAP

## Introduzione

Nella maggior parte delle aziende, Active Directory (AD) di Microsoft è il sistema di autenticazione predefinito per i sistemi Windows e per i servizi esterni collegati a LDAP. Consente di configurare utenti e gruppi, controllo degli accessi, autorizzazioni, auto-mounting e altro ancora.

Sebbene la connessione di Linux a un cluster AD non possa supportare _tutte_ le funzionalità menzionate, può gestire utenti, gruppi e controllo degli accessi. È possibile (attraverso alcune modifiche di configurazione sul lato Linux e alcune opzioni avanzate sul lato AD) distribuire chiavi SSH utilizzando AD.

Il modo predefinito di utilizzare Active Directory su Rocky Linux è SSSD, ma Samba è un'alternativa più completa. Ad esempio, la condivisione dei file può essere effettuata con Samba ma non con SSSD. Questa guida, tuttavia, tratterà la configurazione dell'autenticazione per Active Directory utilizzando Samba e non includerà alcuna configurazione aggiuntiva sul lato Windows.

## Trovare e join AD usando Samba

!!! Note

```
Il nome del dominio `ad.company.local` in questa guida rappresenta il dominio Active Directory. Per seguire questa guida, sostituitelo con il nome del vostro dominio AD.
```

Il primo passo per unire un sistema Linux ad AD è quello di scoprire il cluster AD, per assicurarsi che la configurazione di rete sia corretta su entrambi i lati.

### Preparazione

- Assicurarsi che le seguenti porte siano aperte per l'host Linux sul domain controller:

  | Servizio | Porta(e)          | Note                                                                         |
  | -------- | ------------------------------------ | ---------------------------------------------------------------------------- |
  | DNS      | 53 (TCP+UDP)      |                                                                              |
  | Kerberos | 88, 464 (TCP+UDP) | Usato da `kadmin` per impostare & aggiornare le password |
  | LDAP     | 389 (TCP+UDP)     |                                                                              |
  | LDAP-GC  | 3268 (TCP)        | LDAP Global Catalog - consente di generare ID utenti da AD                   |

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
  [user@host ~]$ sudo dnf install samba samba-winbind samba-client
  ```

### Rilevare

Ora dovreste essere in grado di rilevare i vostri server AD dall'host Linux.

```sh
[user@host ~]$ realm discover ad.company.local
ad.company.local
  type: kerberos
  realm-name: AD.COMPANY.LOCAL
  domain-name: ad.company.local
  configured: no
  server-software: active-directory
  client-software: sssd
  required-package: oddjob
  required-package: oddjob-mkhomedir
  required-package: sssd
  required-package: adcli
  required-package: samba-common
```

I record SRV pertinenti memorizzati nel servizio DNS di Active Directory consentiranno la scoperta.

### Unirsi

Una volta individuata con successo l'installazione di Active Directory dall'host Linux, si dovrebbe essere in grado di usare `realmd` per unirsi al dominio, che orchestrerà la configurazione di Samba usando `adcli` e altri strumenti simili.

```sh
[user@host ~]$ sudo realm join -v --membership-software=samba --client-software=winbind ad.company.local
```

Verrà richiesto di inserire la password di amministratore del dominio, quindi inserirla.

Se questo processo si lamenta della crittografia con `KDC has no support for encryption type`, provare ad aggiornare la politica globale di crittografia per consentire algoritmi di crittografia più vecchi:

```sh
[user@host ~]$ sudo update-crypto-policies --set DEFAULT:AD-SUPPORT
```

Se il processo ha successo, si dovrebbe essere in grado di estrarre le informazioni `passwd` per un utente di Active Directory.

```sh
[user@host ~]$ sudo getent passwd administrator@ad.company.local
AD\administrator:*:1450400500:1450400513:Administrator:/home/administrator@ad.company.local:/bin/bash
```

!!! Note

```
`getent` ottiene le voci dalle librerie Name Service Switch (NSS). Ciò significa che, al contrario di `passwd` o `dig` per esempio, interrogherà diversi database, tra cui `/etc/hosts` per `getent hosts` o da `samba` nel caso di `getent passwd`.
```

`realm` fornisce alcune opzioni interessanti che si possono utilizzare:

| Opzione                                                                    | Osservazione                                                      |
| -------------------------------------------------------------------------- | ----------------------------------------------------------------- |
| --computer-ou='OU=LINUX,OU=SERVERS,dc=ad,dc=company.local' | L'OU in cui memorizzare l'account del server                      |
| --os-name='rocky'                                                          | Specificare il nome del sistema operativo memorizzato in AD       |
| --os-version='8'                                                           | Specificare la versione del sistema operativo memorizzata nell'AD |
| -U admin_username                                     | Specificare un account di amministratore                          |

### Tentativo di autenticazione

Ora gli utenti dovrebbero essere in grado di autenticarsi all'host Linux tramite Active Directory.

**Su Windows 10:** (che fornisce la propria copia di OpenSSH)

```dos
C:\Users\John.Doe> ssh -l john.doe@ad.company.local linux.host
Password for john.doe@ad.company.local:

Activate the web console with: systemctl enable --now cockpit.socket

Last login: Wed Sep 15 17:37:03 2021 from 10.0.10.241
[john.doe@ad.company.local@host ~]$
```

Se l'operazione ha successo, si è configurato Linux per utilizzare Active Directory come fonte di autenticazione.

### Eliminazione del nome di dominio nei nomi utente

In una configurazione completamente predefinita, è necessario accedere con il proprio account AD specificando il dominio nel nome utente (ad esempio, `john.doe@ad.company.local`). Se questo non è il comportamento desiderato e si vuole invece essere in grado di omettere il nome di dominio predefinito al momento dell'autenticazione, è possibile configurare Samba in modo che sia predefinito un dominio specifico.

Si tratta di un processo relativamente semplice, che richiede una modifica al file di configurazione `smb.conf`.

```sh
[user@host ~]$ sudo vi /etc/samba/smb.conf
[global]
...
winbind use default domain = yes
```

Aggiungendo l'opzione `winbind use default domain`, si indica a Samba di dedurre che l'utente sta cercando di autenticarsi come utente del dominio `ad.company.local`. Ciò consente di autenticarsi come `john.doe` invece di `john.doe@ad.company.local`.

Per rendere effettiva questa modifica della configurazione, è necessario riavviare i servizi `smb` e `winbind` con `systemctl`.

```sh
[user@host ~]$ sudo systemctl restart smb winbind
```

Allo stesso modo, se non si vuole che le directory home abbiano il suffisso del nome di dominio, è possibile aggiungere queste opzioni nel file di configurazione `/etc/samba/smb.conf`:

```bash
[global]
template homedir = /home/%U
```

Non dimenticare di riavviare i servizi `smb` e `winbind`.
