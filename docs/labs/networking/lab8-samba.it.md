---
author: Wale Soyinka
contributors: Ganna Zhyrnova
tested on: All Versions
tags:
  - samba
  - cifs
  - smbd
  - nmbd
  - smb.conf
  - smbpasswd
  - network file system
---

# Laboratorio 8: Samba

## Obiettivi

Dopo aver completato questo laboratorio, sarete in grado di

- installare e configurare Samba
- condividere file e directory tra sistemi Linux utilizzando Samba
- utilizzare le comuni utilità di Samba

Tempo stimato per completare questo laboratorio: 40 minuti

## Introduzione

Samba consente la condivisione di file e servizi di stampa tra sistemi Unix/Linux e Windows.

Samba è un'implementazione open-source del "Common Internet File System" (CIFS). CIFS viene anche chiamato Server Message Block (SMB), LAN manager o protocollo NetBIOS.
Il server Samba comprende due demoni principali: smbd e nmbd.

_smbd_: Questo demone fornisce servizi di file e di stampa ai client SMB, come le macchine che eseguono vari sistemi operativi Microsoft.

_nmbd_: Questo demone fornisce il supporto per i nomi NETBIOS e la navigazione.

Gli esercizi di questo laboratorio si concentrano sulla configurazione di Samba come server e client su un server Rocky Linux.

## Esercizio 1

### Installare Samba e configurare una directory condivisa di base

#### Per installare l'applicazione server Samba

0. Utilizzare l'utilità dnf per installare il pacchetto server e client Samba sul server.
   Digitare:
   ```bash
   sudo dnf install -y samba
   ```

#### Configurazione di Samba

1. Creare una directory denominata samba-share sotto la cartella /tmp da condividere. Digitare:

   ```bash
   mkdir /tmp/samba-share
   ```

2. Creiamo una configurazione Samba di base per condividere la cartella /tmp/samba-share.
   A questo scopo, creare una nuova definizione di condivisione nel file di configurazione di Samba:

   ```bash
   sudo tee -a /etc/samba/smb.conf << 'EOF'
   [Shared]
   path = /tmp/samba-share
   browsable = yes
   writable = yes
   EOF
   ```

#### Per avviare e abilitare il servizio Samba

1. Avviare e abilitare i servizi Samba:

   ```bash
   sudo systemctl start smb nmb
   sudo systemctl enable smb nmb
   ```

2. Verificare che i demoni utilizzati dal servizio Samba siano in esecuzione:

   ```bash
   sudo systemctl status smb nmb
   ```

## Esercizio 2

### Utenti Samba

Un'attività amministrativa importante e comune per la gestione di un server Samba è la creazione di utenti e password per gli utenti che devono accedere alle risorse condivise.

Questo esercizio mostra come creare utenti Samba e impostare le credenziali di accesso per gli utenti.

#### Per creare un utente Samba e una password Samba

1. Per prima cosa, creare un normale utente di sistema chiamato sambarockstar. Digitare:

   ```bash
   sudo useradd sambarockstar
   ```

2. Verificare che l'utente sia stato creato correttamente. Digitare:
   ```bash
   id sambarockstar
   ```

3. Aggiungere il nuovo utente di sistema sambarockstar al database degli utenti Samba e contemporaneamente impostare una password per l'utente Samba:

   ```bash
   sudo smbpasswd -a sambarockstar
   ```

   Quando viene richiesto, inserire la password selezionata e premere INVIO dopo ogni inserimento.

4. Riavviare i servizi Samba:
   ```bash
   sudo systemctl restart smb nmb
   ```

## Esercizio 3

### Accesso alla condivisione Samba (test locale)

In questo esercizio, proveremo ad accedere alla nuova condivisione Samba dallo stesso sistema. Ciò significa che utilizzeremo lo stesso host sia come server che come client.

#### Per installare gli strumenti del client Samba

0. Installare Client Utilities eseguendo:

   ```bash
   sudo dnf -y install cifs-utils
   ```

#### Per creare un punto di montaggio Samba

0. Creare il punto di montaggio:
   ```bash
   mkdir ~/samba-client
   ```

#### Per montare un file system SMB localmente

1. Montare la condivisione Samba in locale:

   ```bash
   sudo mount -t cifs //localhost/Shared ~/samba-client -o user=sambarockstar
   ```

2. Usare il comando `mount` per elencare tutti i file system di tipo CIFS montati. Digitare:
   ```bash
   mount -t cifs
   ```
   OUTPUT
   ```bash
   //localhost/Shared on ~/samba-client type cifs (rw,relatime,vers=3.1.1,cache=strict,username=sambarockstar....
   ...<SNIP>...
   ```

3. Allo stesso modo, utilizzare il comando `df` per verificare che la condivisione montata sia disponibile. Digitare:

   ```bash
   df -t cifs
   ```

   OUTPUT:

   ```
   Filesystem         1K-blocks     Used Available Use% Mounted on
   //localhost/Shared  73364480 17524224  55840256  24% ~/samba-client
   ```

4. Quindi, elencare il contenuto della condivisione montata. Digitare:

   ```bash
   ls ~/samba-client
   ```

5. Creare un file di prova in Share:

   ```bash
   touch ~/samba-client/testfile.txt
   ```

## Esercizio 4

### Modifica delle autorizzazioni di condivisione

#### Per regolare le autorizzazioni di condivisione

1. Rendere la definizione della condivisione samba "Shared" di sola lettura. Questo può essere fatto cambiando il valore del parametro writable da yes a no nel file di configurazione smb.conf. Usiamo un comando `sed` onliner per ottenere questo risultato eseguendo:

   ```bash
   sudo  sed -i'' -E \
    '/\[Shared\]/,+3 s/writable =.*$/writable = no/'  /etc/samba/smb.conf
   ```

2. Riavviare i servizi Samba:
   ```bash
   sudo systemctl restart smb nmb
   ```

3. A questo punto, si può testare la scrittura sulla condivisione provando a creare un file sulla condivisione montata:

   ```bash
   touch ~/samba-client/testfile2.txt
   ```

## Esercizio 5

### Utilizzo di Samba per gruppi di utenti specifici

Questo esercizio illustra come limitare l'accesso alle condivisioni Samba tramite l'appartenenza al gruppo locale di un utente. Si tratta di un comodo meccanismo per rendere accessibili le risorse condivise solo a gruppi di utenti specifici.

#### Per creare un nuovo gruppo per l'utente Samba

1. Usare l'utilità groupadd per creare un nuovo gruppo di sistema chiamato rockstars. Nel nostro esempio utilizzeremo questo gruppo per ospitare gli utenti del sistema che possono accedere a una determinata risorsa. Digitare:
   ```bash
   sudo groupadd rockstars
   ```
2. Aggiungere al gruppo un utente di sistema/Samba esistente. Digitare:
   ```bash
   sudo usermod -aG rockstars sambarockstar
   ```

#### Per configurare gli utenti autorizzati nella configurazione di Samba

1. Utilizzare l'utilità sed per aggiungere nuovi parametri utente validi alla definizione di condivisione nel file di configurazione di Samba. Digitare:
   ```bash
   sudo sed -i '/\[Shared\]/a valid users = @sambagroup' /etc/samba/smb.conf
   ```
2. Riavviare i servizi Samba:
   ```bash
   sudo systemctl restart smb nmb
   ```
3. Ora testate l'accesso alla condivisione con sambarockstar e verificate l'accesso.

## Esercizio 6

Questo esercizio simula uno scenario reale in cui si agisce come amministratore di un sistema client e poi si prova ad accedere al servizio Samba sul sistema remoto (server HQ), al quale non si ha alcun accesso o privilegio amministrativo.  Come studenti, configurerete un client Samba sulla vostra macchina (serverXY) per accedere a un servizio Samba ospitato su una macchina diversa (serverHQ). Questo riflette le configurazioni standard del posto di lavoro.

Presupposti:

- Non si dispone dell'accesso root al serverHQ.
- La condivisione Samba sul serverHQ è già configurata e accessibile.

#### Per configurare il client Samba sul serverXY

Configurate la vostra macchina (serverXY) come client Samba per accedere a una directory condivisa su un host separato (serverHQ).

1. Assicurarsi che le necessarie utilità del client Samba siano installate sul sistema locale.
   Se necessario, installarli eseguendo:

   ```bash
   sudo dnf install samba-client cifs-utils -y
   ```

2. Creare un punto di montaggio sul serverXY:

   ```bash
   mkdir ~/serverHQ-share
   ```

#### Per montare la condivisione Samba dal serverHQ

Sono necessari l'indirizzo IP o l'hostname di serverHQ, il nome della condivisione e le credenziali di Samba.

Sostituire serverHQ, sharedFolder e yourUsername con i valori reali.

````
```bash
sudo mount -t cifs //serverHQ/sharedFolder ~/serverHQ-share -o user=yourUsername
```
````

#### Per verificare e accedere alla condivisione montata

1. Verificare se la directory condivisa dal serverHQ è stata montata con successo sul computer:

   ```bash
   ls ~/serverHQ-share
   ```

2. Provare ad accedere e modificare i file all'interno della condivisione montata. Ad esempio, per creare un nuovo file:

   ```bash
   touch ~/serverHQ-share/newfile.txt
   ```

#### Per smontare la condivisione remota

Una volta fatto, smontare la condivisione:

````
```bash
sudo umount ~/serverHQ-share
```
````
