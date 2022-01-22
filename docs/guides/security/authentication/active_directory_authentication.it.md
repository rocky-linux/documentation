---
author: Hayden Young
contributors: Steven Spencer, Sambhav Saggi, Franco Colussi
---

# Autenticazione Active Directory

## Prerequisiti

- Alcune conoscenze di Active Directory
- Alcune conoscenze di LDAP

## Introduzione

Active Directory (AD) di Microsoft è, nella maggior parte delle imprese, il sistema di autenticazione de facto per i sistemi Windows e per i servizi esterni connessi con LDAP. Consente di configurare utenti e gruppi, controllo accessi, permessi, montaggio automatico e altro ancora.

Ora, mentre si collega Linux a un cluster AD non è possibile supportare _tutte_ le funzionalità menzionate, è in grado di gestire utenti, gruppi e controllo di accesso. È anche possibile (attraverso alcuni tweaks di configurazione sul lato Linux e alcune opzioni avanzate sul lato AD) distribuire le chiavi SSH usando AD.

Questa guida, tuttavia, coprirà solo la configurazione di autenticazione per Active Directory, e non includerà alcuna configurazione extra sul lato di Windows.

## Scoprire e unire AD utilizzando SSSD

!!! Note "Nota"

    In tutta questa guida, il nome di dominio `ad.company.local` verrà utilizzato per
    rappresentare il dominio Active Directory. Per seguire questa guida, sostituiscila con
    il nome di dominio utilizzato dal tuo dominio AD.

Il primo passo lungo la strada per unire un sistema Linux in AD è quello di scoprire il tuo cluster AD, per garantire che la configurazione di rete sia corretta su entrambi i lati.

### Preparazione

- Assicurati che le seguenti porte siano aperte al tuo host Linux sul tuo controller di dominio:

  | Servizio | Porta(e)          | Note                                                       |
  | -------- | ----------------- | ---------------------------------------------------------- |
  | DNS      | 53 (TCP+UDP)      |                                                            |
  | Kerberos | 88, 464 (TCP+UDP) | Usato da `kadmin` per impostare & aggiornare le password   |
  | LDAP     | 389 (TCP+UDP)     |                                                            |
  | LDAP-GC  | 3268 (TCP)        | LDAP Global Catalog - consente di generare ID utenti da AD |

- Assicurati di aver configurato il tuo controller di dominio AD come server DNS sul tuo host Rocky Linux:

  **Con NetworkManager:**
  ```sh
  # dove la tua connessione principale a NetworkManager è 'System eth0' e il tuo server AD
  # è accessibile all'indirizzo IP 10.0.0.2.
  [root@host ~]$ nmcli con mod 'System eth0' ipv4.dns 10.0.0.2
  ```

  **Modifica manuale del file /etc/resolv.conf:**
  ```sh
  # Modificare il file resolv.conf
  [user@host ~]$ sudo vi /etc/resolv.conf
  Search lan
  nameserver 10.0.0.2
  nameserver 1.1.1.1 # sostituiscilo con il tuo DNS pubblico preferito (come backup)

  # Rendere il resolv.conf file non scrivibile, impedendo a NetworkManager di
  # sovrascriverlo.
  [user@host ~]$ sudo chattr +i /etc/resolv.conf
  ```

- Assicurarsi che l'ora su entrambi i lati (host AD e sistema Linux) sia sincronizzata

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

Ora, dovresti essere in grado di scoprire con successo i tuoi server AD dal tuo host Linux.

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

Questo verrà scoperto utilizzando i record SRV pertinenti memorizzati nel servizio DNS Active Directory.

### Unirsi

Una volta che hai scoperto con successo la tua installazione di Active Directory dall'host Linux, dovresti essere in grado di usare `realmd` per entrare nel dominio, che orchestrerà la configurazione di `sssd` usando `adcli` e alcuni altri strumenti.

```sh
[user@host ~]$ sudo realm join ad.company.local
```

Se questo processo si lamenta della crittografia con `KDC has no support for encryption type`, prova ad aggiornare la politica globale di crittografia per consentire gli algoritmi di crittografia più vecchi:

```sh
[user@host ~]$ sudo update-crypto-policies --set DEFAULT:AD-SUPPORT
```

Se questo processo ha successo, dovresti ora essere in grado di estrarre le informazioni `passwd` per un utente di Active Directory.

```sh
[user@host ~]$ sudo getent passwd administrator@ad.company.local
administrator@ad.company.local:*:1450400500:1450400513:Amministrator:/home/administrator@ad.company.local:/bin/bash
```

### Tentativo di Autenticazione

Ora i tuoi utenti dovrebbero essere in grado di autenticare il tuo host Linux con Active Directory.

**Su Windows 10:** (che fornisce la propria copia di OpenSSH)

```
C:\Users\John.Doe> ssh -l john.doe@ad.company.local linux.host
Password for john.doe@ad.company.local:

Activate the web console with: systemctl enable --now cockpit.socket

Last login: Wed Sep 15 17:37:03 2021 from 10.0.10.241
[john.doe@ad.company.local@host ~]$
```

In caso di successo, hai configurato con successo Linux per utilizzare Active Directory come fonte di autenticazione.

### Impostazione del dominio predefinito

In una configurazione predefinita completa, dovrai accedere con il tuo account AD specificando il dominio nel tuo nome utente (e.. `john.doe@ad.company.local`). Se questo non è il comportamento desiderato, e si desidera invece essere in grado di omettere il nome di dominio al momento dell'autenticazione, puoi configurare SSSD come predefinito per un dominio specifico.

Questo è in realtà un processo relativamente semplice, e richiede solo una configurazione nel vostro file di configurazione SSSD.

```sh
[user@host ~]$ sudo vi /etc/ssd/sssd.conf
[sssd]
...
default_domain_suffix = ad.company.local
```

Aggiungendo il `default_domain_suffix`, stai istruendo SSSD a (se non è specificato nessun altro dominio) dedurre che l'utente sta cercando di autenticarsi dal dominio `ad.company.local`. Questo ti permette di autenticarti con qualcosa come `john.doe` invece di `john.doe@ad.company.local`.

Per rendere effettiva questa modifica della configurazione, è necessario riavviare l'unità `sssd.service` con `systemctl`.

```sh
[user@host ~]$ sudo systemctl restart sssd
```
