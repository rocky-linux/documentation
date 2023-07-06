---
title: 9 Server Snapshot
author: Steven Spencer
contributors: Ezequiel Bruni, Franco Colussi
tested_with: 8.8, 9.2
tags:
  - lxd
  - enterprise
  - lxd snapshot server
---

# Capitolo 9: server snapshot

In questo capitolo si utilizza una combinazione di utenti privilegiati (root) e non privilegiati (lxdadmin), a seconda dei compiti che si stanno eseguendo.

Come indicato all'inizio, il server snapshot per LXD deve essere in tutto e per tutto un mirror del server di produzione. Il motivo è che potrebbe essere necessario passare alla produzione in caso di guasto dell'hardware del server principale, e disporre di backup e di un modo rapido per riavviare i container di produzione consente di ridurre al minimo le telefonate e i messaggi di panico dell'amministratore di sistema. QUESTO è SEMPRE un bene!

Il processo di creazione del server snapshot è identico a quello del server di produzione. Per emulare completamente la nostra configurazione del server di produzione, eseguite nuovamente tutti i **capitoli da 1 a 4** sul server snapshot e, una volta completati, tornate a questo punto.

Sei tornato!!! Congratulazioni, questo significa che l'installazione di base del server snapshot è stata completata con successo.

## Impostazione del rapporto tra server primario e snapshot

Prima di continuare è necessario fare un po' di pulizia. Innanzitutto, se si opera in un ambiente di produzione, probabilmente si ha accesso a un server DNS che si può utilizzare per impostare la risoluzione IP-nome.

Nel nostro laboratorio non abbiamo questo lusso. Forse anche voi avete lo stesso scenario. Per questo motivo, si aggiungeranno gli indirizzi IP e i nomi di entrambi i server al file /etc/hosts sul server primario e sul server snapshot. È necessario farlo come utente root (o _sudo_).

Nel nostro laboratorio, il server LXD primario è in esecuzione su 192.168.1.106 e il server LXD snapshot è in esecuzione su 192.168.1.141. Accedere a ciascun server tramite SSH e aggiungere quanto segue al file /etc/hosts:

```
192.168.1.106 lxd-primary
192.168.1.141 lxd-snapshot
```

Successivamente, è necessario consentire tutto il traffico tra i due server. A tale scopo, occorre modificare le regole di `firewalld`. Per prima cosa, sul server lxd-primario, aggiungere questa riga:

```
firewall-cmd zone=trusted add-source=192.168.1.141 --permanent
```

e sul server snapshot aggiungere questa regola:

```
firewall-cmd zone=trusted add-source=192.168.1.106 --permanent
```

poi ricaricare:

```
firewall-cmd reload
```

Successivamente, come utente non privilegiato (lxdadmin), è necessario impostare la relazione di fiducia tra le due macchine. Per farlo, eseguire il seguente comando su lxd-primary:

```
lxc remote add lxd-snapshot
```

Visualizza il certificato da accettare. Accettate e vi verrà richiesta la password. Si tratta della "trust password" impostata durante la fase di inizializzazione di LXD. Si spera che teniate traccia di tutte queste password in modo sicuro. Quando si inserisce la password, si riceve questo messaggio:

```
Client certificate stored at server:  lxd-snapshot
```

Non fa male avere anche la retromarcia. Ad esempio, impostare la relazione di fiducia anche sul server lxd-snapshot. In questo modo, se necessario, il server lxd-snapshot può inviare le istantanee al server lxd-primario. Ripetere i passaggi e sostituire "lxd-primary" con "lxd-snapshot"

### Migrazione del primo snapshot

Prima di poter migrare il primo snapshot, è necessario che su lxd-snapshot vengano creati i profili che sono stati creati su lxd-primary. Nel nostro caso, si tratta del profilo "macvlan".

È necessario crearlo per lxd-snapshot. Tornare al [Capitolo 6](06-profiles.md) e creare il profilo "macvlan" su lxd-snapshot, se necessario. Se i due server hanno gli stessi nomi di interfaccia madre ("enp3s0", ad esempio), è possibile copiare il profilo "macvlan" in lxd-snapshot senza ricrearlo:

```
lxc profile copy macvlan lxd-snapshot
```

Dopo aver impostato tutte le relazioni e i profili, il passo successivo è l'invio effettivo snapshot da lxd-primary a lxd-snapshot. Se avete seguito esattamente la procedura, probabilmente avete cancellato tutti i vostri snapshot. Create un'altro snapshot:

```
lxc snapshot rockylinux-test-9 rockylinux-test-9-snap1
```

Se si esegue il comando "info" per `lxc`, si può vedere l'istantanea in fondo al nostro elenco:

```
lxc info rockylinux-test-9
```

Che mostrerà qualcosa di simile in basso:

```
rockylinux-test-9-snap1 at 2021/05/13 16:34 UTC) (stateless)
```

Ok, incrociamo le dita! Proviamo a migrare in nostro snapshot:

```
lxc copy rockylinux-test-9/rockylinux-test-9-snap1 lxd-snapshot:rockylinux-test-9
```

Questo comando dice che, all'interno del container rockylinux-test-9, si vuole inviare lo snapshot rockylinux-test-9-snap1 a lxd-snapshot e chiamarla rockylinux-test-9.

Dopo poco tempo, la copia sarà completa. Volete scoprirlo con certezza? Eseguire un `lxc list` sul server lxd-snapshot. Che dovrebbe restituire quanto segue:

```
+-------------------+---------+------+------+-----------+-----------+
|    NAME           |  STATE  | IPV4 | IPV6 |   TYPE    | SNAPSHOTS |
+-------------------+---------+------+------+-----------+-----------+
| rockylinux-test-9 | STOPPED |      |      | CONTAINER | 0         |
+-------------------+---------+------+------+-----------+-----------+
```

Riuscito! Provate ad avviarlo. Poiché lo stiamo avviando sul server lxd-snapshot, è necessario fermarlo prima sul server lxd-primario per evitare un conflitto di indirizzi IP:

```
lxc stop rockylinux-test-9
```

E sul server lxd-snapshot:

```
lxc start rockylinux-test-9
```

Supponendo che tutto questo funzioni senza errori, arrestare il container su lxd-snapshot e riavviarlo su lxd-primary.

## Impostazione di boot.autostart su off per i container

Gli snapshot copiate su lxd-snapshot saranno inattivi durante la migrazione, ma se si verifica un evento di alimentazione o se è necessario riavviare il server di snapshot a causa di aggiornamenti o altro, si verificherà un problema. Questi container cercheranno di avviarsi sul server snapshot creando un potenziale conflitto di indirizzi IP.

Per eliminare questo problema, è necessario impostare i container migrati in modo che non vengano avviati al riavvio del server. Per il nostro container rockylinux-test-9 appena copiato, lo si farà con:

```
lxc config set rockylinux-test-9 boot.autostart 0
```

Eseguire questa operazione per ogni snapshot sul server lxd-snapshot. Lo "0" nel comando assicura che `boot.autostart` sia disattivato.

## Automatizzazione del processo di snapshot

È fantastico poter creare snapshot quando è necessario, ma a volte _è_ necessario creare manualmente uno snapshot. Si potrebbe anche copiare manualmente su lxd-snapshot. Ma per tutte le altre volte, in particolare per molti container in esecuzione sul server lxd-primario, l'**ultima** cosa da fare è passare un pomeriggio a cancellare le istantanee sul server snapshot, creare nuove istantanee e inviarle al server snapshot. Per la maggior parte delle operazioni, è preferibile automatizzare il processo.

La prima cosa da fare è pianificare un processo per automatizzare la creazione di snapshot su lxd-primary. Questa operazione viene eseguita per ogni container sul server lxd-primary. Una volta completata, si occuperà di questo aspetto in futuro. Per farlo, si utilizza la seguente sintassi. Si noti la somiglianza con una voce di crontab per il timestamp:

```
lxc config set [container_name] snapshots.schedule "50 20 * * *"
```

Ciò significa che bisogna eseguire un'istantanea del nome del container ogni giorno alle 20:50.

Per applicare questo al nostro container rockylinux-test-9:

```
lxc config set rockylinux-test-9 snapshots.schedule "50 20 * * *"
```

È inoltre necessario impostare il nome dello snapshot in modo che sia significativo per la nostra data. LXD utilizza ovunque UTC, quindi la cosa migliore per tenere traccia delle cose è impostare il nome del container con una data e un'ora in un formato più comprensibile:

```
lxc config set rockylinux-test-9 snapshots.pattern "rockylinux-test-9{{ creation_date|date:'2006-01-02_15-04-05' }}"
```

GRANDE, ma di certo non volete una nuova istantanea ogni giorno senza sbarazzarvi di quella vecchia, giusto? L'unità si riempirebbe di istantanee. Per risolvere questo problema si esegue:

```
lxc config set rockylinux-test-9 snapshots.expiry 1d
```
