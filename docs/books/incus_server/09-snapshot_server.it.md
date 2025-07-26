---
title: 9 Server Snapshot
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 9.4
tags:
  - incus
  - enterprise
  - incus snapshot server
---

In questo capitolo si utilizzeranno una combinazione di utenti privilegiati (root) e non privilegiati (incusadmin) in base alle attività che si eseguiranno.

Come indicato all'inizio, il server snapshot di Incus deve essere un mirror in tutto e per tutto al server di produzione. Potrebbe essere necessario metterlo in produzione se l'hardware del server principale si guastasse, infatti disporre di un backup e di un modo rapido per riavviare i container di produzione consente di ridurre al minimo le telefonate e gli SMS di panico degli amministratori di sistema. E questo è SEMPRE un bene!

Il processo di creazione del server snapshot è esattamente come quello del server di produzione. Per emulare pienamente la configurazione del server di produzione, si ripetano i capitoli 1-4 sul server snapshot e, una volta completati, tornare a questo punto.

Se si è arrivati fino a qui, è stata completata l'installazione di base del server snapshot.

## Impostazione del rapporto tra server primario e snapshot

È necessario fare un po' d'ordine prima di proseguire. Innanzitutto, se si opera in un ambiente di produzione, probabilmente si ha accesso a un server DNS per impostare la risoluzione dei nomi ed IP.

Nel vostro ambiente di prova non si ha questo lusso. Forse anche voi avete lo stesso scenario. Per questo motivo, si aggiungeranno gli indirizzi IP e i nomi dei server nel file \`/etc/hosts' sul server primario e sul server snapshot. È necessario eseguire questa operazione come utente root (o _sudo_).

Nell'ambiente di prova, il server primario di Incus è in esecuzione su 192.168.1.106 e il server snapshot di Incus è in esecuzione su 192.168.1.141. Accedere a ciascun server tramite SSH e aggiungere quanto segue al file `/etc/hosts`:

```bash
192.168.1.106 incus-primary
192.168.1.141 incus-snapshot
```

Successivamente, è necessario consentire tutto il traffico tra i due server. Per farlo, si modificheranno le regole di `firewalld`. Per prima cosa, sul server incus-primario, si aggiunga questa riga:

```bash
firewall-cmd zone=trusted add-source=192.168.1.141 --permanent
```

E sul server snapshot, aggiungere questa regola:

```bash
firewall-cmd zone=trusted add-source=192.168.1.106 --permanent
```

Quindi ricaricare:

```bash
firewall-cmd reload
```

Successivamente, come utente non privilegiato (incusadmin), è necessario stabilire una relazione di trusting tra le due macchine. Questo si ottiene eseguendo su incus-primary quanto segue:

```bash
incus remote add incus-snapshot
```

Visualizza il certificato da accettare. Accettate e vi verrà richiesta la password. Si tratta della “trust password” impostata durante la fase di inizializzazione di Incus. Spero che stiate tenendo traccia di tutte queste password. Quando si inserisce la password, si riceve questo messaggio:

```bash
Client certificate stored at server:  incus-snapshot
```

Si può fare anche al contrario. Ad esempio, la trust relation può essere impostata anche sul server incus-snapshot. Se richiesto, il server incus-snapshot può inviare gli snapshots al server incus-primario. Ripetete i passaggi e sostituite “incus-primary” con “incus-snapshot”

### Migrazione del primo snapshot

Prima di migrare la prima snapshot, è necessario ricreare tutti i profili sull'incus-snapshot creati sull'incus-primario. In questo caso specifico, si tratta del profilo “macvlan”.

È necessario crearlo per incus-snapshot. Tornare al [Capitolo 6](06-profiles.md) e creare il profilo “macvlan” su incus-snapshot, se necessario. Se i due server hanno gli stessi nomi di interfaccia madre (“enp3s0”, ad esempio), è possibile copiare il profilo “macvlan” su incus-snapshot senza ricrearlo:

```bash
incus profile copy macvlan incus-snapshot
```

Avendo tutte le relazioni e i profili impostati, il prossimo passo è quello di inviare uno snapshot dal incus-primario al incus-snapshot. Se si è seguito esattamente questa procedura, probabilmente si avrà cancellato tutti gli snapshot. Creare un'altro snapshot:

```bash
incus snapshot rockylinux-test-9 rockylinux-test-9-snap1
```

Se si esegue il comando “info” per `incus`, si può vedere lo snapshot in fondo all'elenco:

```bash
incus info rockylinux-test-9
```

Che mostrerà qualcosa di simile in basso:

```bash
rockylinux-test-9-snap1 at 2021/05/13 16:34 UTC) (stateless)
```

Provare a migrare lo snapshot:

```bash
incus copy rockylinux-test-9/rockylinux-test-9-snap1 incus-snapshot:rockylinux-test-9
```

Questo comando dice che all'interno del container rockylinux-test-9, si vuole inviare lo snapshot rockylinux-test-9-snap1 a incus-snapshot e nominarlo rockylinux-test-9.

Dopo poco tempo, la copia sarà completa. Volete scoprirlo con certezza? Eseguire `incus list` sul server incus-snapshot. Che dovrebbe restituire quanto segue:

```bash
+-------------------+---------+------+------+-----------+-----------+
|    NAME           |  STATE  | IPV4 | IPV6 |   TYPE    | SNAPSHOTS |
+-------------------+---------+------+------+-----------+-----------+
| rockylinux-test-9 | STOPPED |      |      | CONTAINER | 0         |
+-------------------+---------+------+------+-----------+-----------+
```

Successo! Provate ad avviarlo. Poiché si avvia sul server incus-snapshot, è necessario arrestarlo prima sul server incus-primary per evitare un conflitto di indirizzi IP:

```bash
incus stop rockylinux-test-9
```

E sul server incus-snapshot:

```bash
incus start rockylinux-test-9
```

Supponendo che tutto questo funzioni senza errori, arrestare il container su incus-snapshot e riavviarlo su incus-primary.

## Impostazione di `boot.autostart` su off per i containers

Gli snapshot copiati su incus-snapshot saranno disattivati durante la migrazione, ma se si verifica una anomalia nell'alimentazione del server o è necessario riavviare il server di snapshot a causa di aggiornamenti o altro, si verificherà un problema. Questi container cercheranno di avviarsi sul server snapshot, creando un potenziale conflitto di indirizzi IP.

Allo scopo di evitare questo problema, è necessario impostare i container migrati in modo che non vengano avviati al riavvio del server. Per il container rockylinux-test-9 appena copiato, si procederà come segue:

```bash
incus config set rockylinux-test-9 boot.autostart 0
```

Eseguire questa operazione per ogni snapshot sul server incus-snapshot. Lo "0" nella riga di comando imposta `boot.autostart` in off.

## Automatizzazione del processo di snapshot

È importante avere la possibilità di creare snapshot quando necessario, ma a volte è necessario creare un snapshot manualmente. Si potrebbe anche copiare manualmente su incus-snapshot. Ma per tutte le altre volte, in particolare per molti container in esecuzione sul server incus-primary, l'ultima cosa da fare è passare un pomeriggio a cancellare le istantanee sul server snapshot, creare nuove istantanee e inviarle al server snapshot. Per la maggior parte delle operazioni, è preferibile automatizzare il processo.

È necessario pianificare un processo per automatizzare la creazione di snapshot su incus-primary. Questa operazione viene eseguita per ogni container sul server incus-primary. Una volta completata, si occuperà di questo aspetto in futuro. Per farlo, si utilizza la seguente sintassi. Si noti la somiglianza con una voce di crontab per il timestamp:

```bash
incus config set [container_name] snapshots.schedule "50 20 * * *"
```

Questo significa: eseguire un snapshot del container_name ogni giorno alle 20.50.

Per applicare questo al container rockylinux-test-9:

```bash
incus config set rockylinux-test-9 snapshots.schedule "50 20 * * *"
```

È inoltre necessario impostare il nome del snapshot in modo che sia significativo per la sua data. Incus utilizza ovunque UTC, quindi la cosa migliore per tenere traccia delle cose è impostare il nome del snapshot con una data e un'ora in un formato più comprensibile:

```bash
incus config set rockylinux-test-9 snapshots.pattern "rockylinux-test-9{{ creation_date|date:'2006-01-02_15-04-05' }}"
```

OTTIMO, ma di certo non volete un nuovo snapshot ogni giorno senza sbarazzarvi di quello vecchio. L'unità si riempirebbe di istantanee. Per risolvere questa cosa, eseguire il seguente comando:

```bash
incus config set rockylinux-test-9 snapshots.expiry 1d
```
