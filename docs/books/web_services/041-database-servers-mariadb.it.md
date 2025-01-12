---
author: Antoine Le Morvan
contributors: Steven Spencer, Ganna Zhyrnova
title: Part 4.1 MariaDB Database server
tags:
  - mariadb
  - mysql
  - database
  - rdbms
---

MySQL, MariaDB e PostgreSQL sono RDBMS (Relational DataBase Management System) open-source.

## MariaDB e MySQL

In questo capitolo, imparerete a conoscere gli RDBMS MariaDB e MySQL.

****

**Obiettivi**: si imparerà a:

:heavy_check_mark: installare, configurare e proteggere il server MariaDB e il server MySQL;\
:heavy_check_mark: eseguire alcune azioni amministrative su database e utenti.

:checkered_flag: **RDBMS**, **database**, **MariaDB**, **MySQL**

**Conoscenza**: :star: :star: :star:\
**Complessità**: :star: :star: :star:

**Tempo di lettura**: 30 minuti

****

### Generalità

MySQL è stato sviluppato da Michael “Monty” Widenius (un informatico finlandese), che ha fondato MySQL AB nel 1995. MySQL AB è stata acquisita da SUN nel 2008, che a sua volta è stata acquisita da Oracle nel 2009. Oracle è ancora proprietaria del software MySQL e lo distribuisce con una doppia licenza GPL e proprietaria.

Nel 2009, Michael Widenius ha lasciato SUN, ha fondato Monty Program AB e ha avviato lo sviluppo del suo fork comunitario di MySQL: MariaDB sotto licenza GPL. La MariaDB Foundation governa il progetto e garantisce che rimanga libero.

Non passò molto tempo prima che la maggior parte delle distribuzioni Linux offrisse pacchetti MariaDB al posto di quelli MySQL, e anche account importanti come Wikipedia e Google adottarono il fork della comunità.

MySQL e MariaDB sono tra i RDBMS più utilizzati al mondo (a livello professionale e dal grande pubblico), in particolare per le applicazioni web (**LAMP**: Linux + Apache + Mysql-MariaDB + Php).

I principali concorrenti di Mysql-MariaDB sono:

- PostgreSQL,
- OracleDB,
- Microsoft SQL Server.

I servizi di database sono multi-thread e multi-utente, funzionano sulla maggior parte dei sistemi operativi (Linux, Unix, BSD, Mac OSx, Windows) e sono accessibili da molti linguaggi di programmazione (PHP, Java, Python, C, C++, Perl e altri).

Viene offerto il supporto per diversi engines, consentendo l'assegnazione di engines diversi a tabelle diverse all'interno dello stesso database, a seconda delle esigenze:

MyISAM : il più semplice, ma non supporta le transazioni o le chiavi esterne. È un engine sequenziale indicizzato. MyISAM è ora abbandonato.

InnoDB : gestisce l'integrità della tabella (chiavi esterne e transazioni), ma occupa più spazio su disco. Questo è il motore predefinito dalla versione 5.6 di MySQL. È un motore transazionale.

Memory
: le tabelle sono salvate in memoria.

Archive
: La compressione dei dati all'inserimento fa risparmiare spazio su disco, ma rallenta le query di ricerca (cold data).

Si tratta di adottare un motore in base alle esigenze: Archive per la memorizzazione dei log, Memory per i dati temporanei e così via.

MariaDB/MySQL utilizza la porta 3306/TCP per la comunicazione di rete.

Questo capitolo tratterà questa versione, poiché la versione predefinita fornita con Rocky è la versione comunitaria di MariaDB del database. Vengono trattate in modo specifico solo le differenze tra MySQL e MariaDB.

### Installazione

Usare il comando `dnf` per installare il pacchetto `mariadb-server`:

```bash
sudo dnf install -y mariadb-server
```

Per impostazione predefinita, la versione installata su un Rocky 9 è la 10.5.

Attivare il servizio all'avvio e avviarlo:

```bash
sudo systemctl enable mariadb --now
```

È possibile verificare lo stato del servizio `mariadb`:

```bash
sudo systemctl status mariadb
```

Per installare una versione più recente, è necessario utilizzare i moduli `dnf`:

```bash
$ sudo dnf module list mariadb
Last metadata expiration check: 0:00:09 ago on Thu Jun 20 11:39:10 2024.
Rocky Linux 9 - AppStream
Name                          Stream                      Profiles                                        Summary
mariadb                       10.11                       client, galera, server [d]                      MariaDB Module

Hint: [d]efault, [e]nabled, [x]disabled, [i]nstalled
```

Se non si è ancora installato il server mariadb, sarà sufficiente attivare la versione del modulo desiderata:

```bash
$ sudo dnf module enable mariadb:10.11
Last metadata expiration check: 0:02:23 ago on Thu Jun 20 11:39:10 2024.
Dependencies resolved.
============================================================================================================================================= Package                          Architecture                    Version                             Repository                        Size
=============================================================================================================================================
Enabling module streams:
 mariadb                                                          10.11

Transaction Summary
=============================================================================================================================================
Is this ok [y/N]: y
Complete!
```

Ora è possibile installare il pacchetto. La versione desiderata verrà installata automaticamente:

```bash
sudo dnf install -y mariadb-server
```

#### Informazioni sugli utenti predefiniti

Si prega di notare i log forniti da mariadb al primo avvio (`/var/log/messages`):

```text
mariadb-prepare-db-dir[6560]: Initializing MariaDB database
mariadb-prepare-db-dir[6599]: Two all-privilege accounts were created.
mariadb-prepare-db-dir[6599]: One is root@localhost, it has no password, but you need to
mariadb-prepare-db-dir[6599]: be system 'root' user to connect. Use, for example, sudo mysql
mariadb-prepare-db-dir[6599]: The second is mysql@localhost, it has no password either, but
mariadb-prepare-db-dir[6599]: you need to be the system 'mysql' user to connect.
mariadb-prepare-db-dir[6599]: After connecting you can set the password, if you would need to be
mariadb-prepare-db-dir[6599]: able to connect as any of these users with a password and without sudo
```

### Configurazione

I file di configurazione sono `/etc/my.cnf` e `/etc/my.cnf.d/`.

Alcune importanti opzioni predefinite sono state impostate in `/etc/my.cnf.d/mariadb-server.cnf`:

```text
[server]

[mysqld]
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock
log-error=/var/log/mariadb/mariadb.log
pid-file=/run/mariadb/mariadb.pid
...
```

Come si può vedere, i dati si trovano in `/var/lib/mysql` per impostazione predefinita. Questa cartella può richiedere molto spazio di archiviazione e aumenti di volume ricorrenti. È quindi consigliabile montare questa cartella su una partizione dedicata.

### Sicurezza

MariaDB e Mysql includono uno script che aiuta a proteggere il server. Rimuove ad esempio i login di root remoti e gli utenti campione, le opzioni predefinite meno sicure.

Utilizzare `mariadb-secure-installation` e proteggere il server:

```bash
sudo mariadb-secure-installation
```

Lo script chiederà di fornire una password per l'utente root.

!!! NOTE "Nota"

````
The `mysql_secure_installation` command is now a symlink to the `mariadb-secure-installation` command:

```bash
$ ll /usr/bin/mysql_secure_installation
lrwxrwxrwx. 1 root root 27 Oct 12  2023 /usr/bin/mysql_secure_installation -> mariadb-secure-installation
```
````

Se fornire una password ogni volta che si devono usare i comandi di mariadb è un problema, si può impostare un file `~/.my.cnf` con le proprie credenziali, che sarà usato di default da mariadb per connettersi al server.

```bash
[client]
user="root"
password="#######"
```

Assicurarsi che le autorizzazioni siano abbastanza restrittive da consentire l'accesso solo all'utente corrente:

```bash
chmod 600 ~/.my.cnf
```

!!! WARNING "Attenzione"

```
Questo non è il modo migliore. Esiste un'altra soluzione più sicura della memorizzazione di una password in testo normale. A partire da MySQL 5.6.6, è ora possibile memorizzare le credenziali di accesso in un `.mylogin.cnf` criptato, grazie al comando `mysql_config_editor`.
```

Se il server è dotato di un firewall (il che è una buona cosa), potreste prendere in considerazione la possibilità di aprirlo, ma solo se avete bisogno che il vostro servizio sia accessibile dall'esterno.

```bash
sudo firewall-cmd --zone=public --add-service=mysql
sudo firewall-cmd --reload
```

!!! NOTE "Nota"

```
La migliore sicurezza consiste nel non aprire il server del database al mondo esterno (se il server delle applicazioni è ospitato sullo stesso server) o nel limitare l'accesso solo agli IP autorizzati.
```

### Amministrazione

#### Il comando `mariadb`

Il comando `mariadb` è una semplice shell SQL che supporta l'uso interattivo e non interattivo.

```bash
mysql -u user -p [base]
```

| Opzione   | Informazione                                                 |
| --------- | ------------------------------------------------------------ |
| `-u user` | Fornisce un nome utente con cui connettersi. |
| `-p`      | Richiede la password.                        |
| `base`    | Il nome del database al quale collegarsi.    |

!!! NOTE "Nota"

````
The `mysql` command is now a symlink to the `mariadb` command:

```bash
$ ll /usr/bin/mysql
lrwxrwxrwx. 1 root root 7 Oct 12  2023 /usr/bin/mysql -> mariadb
```
````

Esempio:

```bash
$ sudo mariadb -u root
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 15
Server version: 10.5.22-MariaDB MariaDB Server

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
+--------------------+
3 rows in set (0.003 sec)
```

#### Il comando `mariadb-admin`

Il comando `mariadb-admin` è un client per amministrare un server MariaDB.

```bash
mariadb-admin -u user -p command
```

| Opzione   | Informazione                                                 |
| --------- | ------------------------------------------------------------ |
| `-u user` | Fornisce un nome utente con cui connettersi. |
| `-p`      | Richiede la password.                        |
| `command` | Un comando da eseguire.                      |

`mariadb-admin` fornisce diversi comandi come `version`, `variables`, `stop-slave` o `start-slave`, `create databasename` e così via.

Esempio:

```bash
mariadb-admin -u root -p version
```

!!! NOTE "Nota"

````
The `mysqladmin` command is now a symlink to the `mariadb-admin` command:

```bash
$ ll /usr/bin/mysqladmin
lrwxrwxrwx. 1 root root 13 Oct 12  2023 /usr/bin/mysqladmin -> mariadb-admin
```
````

### Informazioni sui logs

MariaDB fornisce diversi logs:

- **Log di errore**: Contiene i messaggi generati all'avvio e all'arresto del servizio e gli eventi importanti (avvisi ed errori).
- **Log binary**: Questo registro (in formato binario) registra tutte le azioni che modificano la struttura o i dati del database. Se è necessario ripristinare un database, è necessario ripristinare il backup E riprodurre il registro binario per ripristinare lo stato del database prima dell'arresto anomalo.
- **Log delle query**: Tutte le richieste dei client sono registrate qui.
- **Registro delle query slow**: Le query slow, cioè quelle che richiedono più tempo per essere eseguite, vengono registrate separatamente in questo registro. Esaminando questo file, è possibile adottare misure per ridurre il tempo di esecuzione (ad esempio, impostando indici o modificando l'applicazione client).

Ad eccezione del log binary, questi log sono in formato testo e possono essere utilizzati direttamente!

Per abilitare la registrazione delle long query, modificare il file di configurazione `my.cnf` aggiungendo le seguenti righe:

```bash
slow_query_log      = 1
slow_query_log_file = /var/log/mysql/mysql-slow.log
long_query_time     = 2
```

Il valore minimo della variabile `long_query_time` è 0 e il valore predefinito è `10` secondi.

Riavviare il servizio per rendere effettive le modifiche.

Una volta che il file di log è pieno, è possibile analizzarlo con il comando `mariadb-dumpslow`.

```bash
mariadb-dumpslow [options] [log_file ...]
```

| Opzione        | Informazione                                      |
| -------------- | ------------------------------------------------- |
| `-t n`         | Visualizza solo le prime n query. |
| `-s sort_type` | Ordina per numero di query.       |
| `-r`           | Inverte la lista dei risultati.   |

I tipi di ordinamento possono essere :

| Opzione    | Informazione                                                                                                    |
| ---------- | --------------------------------------------------------------------------------------------------------------- |
| `c`        | in base al numero di richieste.                                                                 |
| `t` o `at` | in base al tempo di esecuzione o al tempo medio di esecuzione (a per media). |
| `l` o `al` | in base al tempo di blocco o alla sua media.                                                    |
| `r` o `aR` | in funzione del numero di righe restituite o della sua media.                                   |

### Indicazioni sul backup

Come per qualsiasi RDBMS, il backup di un database viene eseguito mentre la modifica dei dati è offline. È possibile farlo nel modo seguente:

- interrompere il servizio, noto come backup offline;
- mentre il servizio funziona, bloccando temporaneamente gli aggiornamenti (sospendendo tutte le modifiche). Questo è un backup online.
- utilizzando un'istantanea del file system LVM, consentendo il backup dei dati con un file system "a freddo".

Il formato del backup può essere un file ASCII (testo), che rappresenta lo stato del database e i suoi dati sotto forma di comandi SQL, oppure un file binario corrispondente ai file di archiviazione MySQL.

Mentre è possibile eseguire il backup di un file binario utilizzando utility comuni come tar o cpio, un file ASCII richiede un'utility come `mariadb-dump`.

Il comando `mariadb-dump` può eseguire un dump del database.

Durante il processo, l'accesso ai dati è bloccato.

```bash
mariadb-dump -u root -p DATABASE_NAME > backup.sql
```

!!! NOTE "Nota"

```
Non dimenticare che dopo il ripristino di un backup completo, il ripristino dei file binari (binlog) completa la ricostituzione dei dati.
```

Il file risultante è utilizzabile per ripristinare i dati del database. Il database deve ancora esistere, oppure deve essere stato ricreato in precedenza!:

```bash
mariadb -u root -p DATABASE_NAME < backup.sql
```

### Strumenti Grafici

Esistono strumenti grafici per facilitare l'amministrazione e la gestione dei dati del database. Ecco qui alcuni esempi:

- [DBeaver](https://dbeaver.io/)

### Workshop

In questo workshop, si installerà, configurerà e metterà in protezione il vostro server MariaDB.

#### Task 1: Installazione

Installare il package MariaDB-server:

```bash
$ sudo dnf install mariadb-server
Last metadata expiration check: 0:10:05 ago on Thu Jun 20 11:26:03 2024.
Dependencies resolved.
============================================================================================================================================= Package                                       Architecture            Version                              Repository                  Size
=============================================================================================================================================
Installing:
 mariadb-server                                x86_64                  3:10.5.22-1.el9_2                    appstream                  9.6 M
Installing dependencies:
...
```

L'installazione aggiunge un utente `mysql` al sistema, con `/var/lib/mysql` come home directory:

```bash
$ cat /etc/passwd
...
mysql:x:27:27:MySQL Server:/var/lib/mysql:/sbin/nologin
...
```

Attivare e avviare il servizio con il seguente comando:

```bash
$ sudo systemctl enable mariadb --now
Created symlink /etc/systemd/system/mysql.service → /usr/lib/systemd/system/mariadb.service.
Created symlink /etc/systemd/system/mysqld.service → /usr/lib/systemd/system/mariadb.service.
Created symlink /etc/systemd/system/multi-user.target.wants/mariadb.service → /usr/lib/systemd/system/mariadb.service.
```

Controllare l'installazione:

```bash
$ sudo systemctl status mariadb
● mariadb.service - MariaDB 10.5 database server
     Loaded: loaded (/usr/lib/systemd/system/mariadb.service; enabled; preset: disabled)
     Active: active (running) since Thu 2024-06-20 11:48:56 CEST; 1min 27s ago
       Docs: man:mariadbd(8)
             https://mariadb.com/kb/en/library/systemd/
    Process: 6538 ExecStartPre=/usr/libexec/mariadb-check-socket (code=exited, status=0/SUCCESS)
    Process: 6560 ExecStartPre=/usr/libexec/mariadb-prepare-db-dir mariadb.service (code=exited, status=0/SUCCESS)
    Process: 6658 ExecStartPost=/usr/libexec/mariadb-check-upgrade (code=exited, status=0/SUCCESS)
   Main PID: 6643 (mariadbd)
     Status: "Taking your SQL requests now..."
      Tasks: 9 (limit: 11110)
     Memory: 79.5M
        CPU: 1.606s
     CGroup: /system.slice/mariadb.service
             └─6643 /usr/libexec/mariadbd --basedir=/usr

Jun 20 11:48:56 localhost.localdomain mariadb-prepare-db-dir[6599]: The second is mysql@localhost, it has no password either, but
Jun 20 11:48:56 localhost.localdomain mariadb-prepare-db-dir[6599]: you need to be the system 'mysql' user to connect.
Jun 20 11:48:56 localhost.localdomain mariadb-prepare-db-dir[6599]: After connecting you can set the password, if you would need to be
Jun 20 11:48:56 localhost.localdomain mariadb-prepare-db-dir[6599]: able to connect as any of these users with a password and without sudo
Jun 20 11:48:56 localhost.localdomain mariadb-prepare-db-dir[6599]: See the MariaDB Knowledgebase at https://mariadb.com/kb
Jun 20 11:48:56 localhost.localdomain mariadb-prepare-db-dir[6599]: Please report any problems at https://mariadb.org/jira
Jun 20 11:48:56 localhost.localdomain mariadb-prepare-db-dir[6599]: The latest information about MariaDB is available at https://mariadb.org>Jun 20 11:48:56 localhost.localdomain mariadb-prepare-db-dir[6599]: Consider joining MariaDB's strong and vibrant community:
Jun 20 11:48:56 localhost.localdomain mariadb-prepare-db-dir[6599]: https://mariadb.org/get-involved/
Jun 20 11:48:56 localhost.localdomain systemd[1]: Started MariaDB 10.5 database server.
```

Provare a connettersi al server:

```bash
$ sudo mariadb
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 9
Server version: 10.5.22-MariaDB MariaDB Server

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
+--------------------+
3 rows in set (0.001 sec)

MariaDB [(none)]> exit
Bye
```

```bash
$ sudo mariadb-admin version
mysqladmin  Ver 9.1 Distrib 10.5.22-MariaDB, for Linux on x86_64
Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Server version          10.5.22-MariaDB
Protocol version        10
Connection              Localhost via UNIX socket
UNIX socket             /var/lib/mysql/mysql.sock
Uptime:                 7 min 24 sec

Threads: 1  Questions: 9  Slow queries: 0  Opens: 17  Open tables: 10  Queries per second avg: 0.020
```

Come si può vedere, l'utente \`root' non ha bisogno di fornire una password. Lo si correggerà durante il prossimo task.

#### Task 2: Proteggere il server

Lanciare `mariadb-secure-installation` e seguire le istruzioni:

```bash
$ sudo mariadb-secure-installation

NOTE: RUNNING ALL PARTS OF THIS SCRIPT IS RECOMMENDED FOR ALL MariaDB
      SERVERS IN PRODUCTION USE!  PLEASE READ EACH STEP CAREFULLY!

In order to log into MariaDB to secure it, we'll need the current
password for the root user. If you've just installed MariaDB, and
haven't set the root password yet, you should just press enter here.

Enter current password for root (enter for none):
OK, successfully used password, moving on...

Setting the root password or using the unix_socket ensures that nobody
can log into the MariaDB root user without the proper authorisation.

You already have your root account protected, so you can safely answer 'n'.

Switch to unix_socket authentication [Y/n] y
Enabled successfully!
Reloading privilege tables..
 ... Success!


You already have your root account protected, so you can safely answer 'n'.

Change the root password? [Y/n] y
New password:
Re-enter new password:
Password updated successfully!
Reloading privilege tables..
 ... Success!


By default, a MariaDB installation has an anonymous user, allowing anyone
to log into MariaDB without having to have a user account created for
them.  This is intended only for testing, and to make the installation
go a bit smoother.  You should remove them before moving into a
production environment.

Remove anonymous users? [Y/n] y
 ... Success!

Normally, root should only be allowed to connect from 'localhost'.  This
ensures that someone cannot guess at the root password from the network.

Disallow root login remotely? [Y/n] y
 ... Success!

By default, MariaDB comes with a database named 'test' that anyone can
access.  This is also intended only for testing, and should be removed
before moving into a production environment.

Remove test database and access to it? [Y/n] y
 - Dropping test database...
 ... Success!
 - Removing privileges on test database...
 ... Success!

Reloading the privilege tables will ensure that all changes made so far
will take effect immediately.

Reload privilege tables now? [Y/n] y
 ... Success!

Cleaning up...

All done!  If you've completed all of the above steps, your MariaDB
installation should now be secure.

Thanks for using MariaDB!
 
No identifier (key)

```

Provare a connettersi nuovamente al server con e senza password:

```bash
$ mariadb -u root
ERROR 1045 (28000): Access denied for user 'root'@'localhost' (using password: NO)

$ mariadb -u root -p
Enter password:
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 4
Server version: 10.5.22-MariaDB MariaDB Server

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]>
```

Configurare il firewall:

```bash
sudo firewall-cmd --zone=public --add-service=mysql --permanent
sudo firewall-cmd --reload
```

#### Task 3: Testare l'installazione

Verificare l'installazione:

```bash
$ mysqladmin -u root -p version
Enter password:
mysqladmin  Ver 9.1 Distrib 10.5.22-MariaDB, for Linux on x86_64
Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Server version          10.5.22-MariaDB
Protocol version        10
Connection              Localhost via UNIX socket
UNIX socket             /var/lib/mysql/mysql.sock
Uptime:                 29 min 18 sec

Threads: 1  Questions: 35  Slow queries: 0  Opens: 20  Open tables: 13  Queries per second avg: 0.019
```

Il parametro `version` fornisce le informazioni sul server.

#### Task 4: Creare un nuovo database ed un user

Creare un nuovo database:

```sql
MariaDB [(none)]> create database NEW_DATABASE_NAME;
```

Creare un nuovo utente e dargli tutti i diritti su tutte le tabelle del database:

```sql
MariaDB [(none)]> grant all privileges on NEW_DATABASE_NAME.* TO 'NEW_USER_NAME'@'localhost' identified by 'PASSWORD';
```

Sostituire `localhost` con `%` se si vuole garantire l'accesso da ogni luogo, oppure sostituire per indirizzo IP, se possibile.

È sempre possibile limitare i privilegi concessi. Esistono diversi tipi di autorizzazioni da offrire agli utenti:

- **SELECT**: leggere i dati
- **USAGE**: autorizzazione a connettersi al server (fornita di default quando viene creato un nuovo utente)
- **INSERT**: aggiunge nuove tuple a una tabella.
- **UPDATE**: modifica delle tuple esistenti
- **DELETE**: cancella le tuples
- **CREATE**: crea nuove tabelle o database
- **DROP**: cancella tabelle o database esistenti
- **ALL PRIVILEGES**: tutti i diritti
- **GRANT OPTION**: fornire o rimuovere diritti ad altri utenti

Non dimenticate di riavviare e applicare i nuovi diritti:

```sql
MariaDB [(none)]> flush privileges;
```

Verifica:

```bash
$ mariadb -u NEW_USER_NAME -p
Enter password:
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 8
Server version: 10.5.22-MariaDB MariaDB Server

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> show databases;
+--------------------+
| Database           |
+--------------------+
| NEW_DATABASE_NAME  |
| information_schema |
+--------------------+
2 rows in set (0.001 sec)
```

Aggiungete i dati di esempio nel vostro database:

```bash
$ mariadb -u NEW_USER_NAME -p NEW_DATABASE_NAME
MariaDB [NEW_DATABASE_NAME]> CREATE TABLE users(
    id INT NOT NULL AUTO_INCREMENT,
    first_name VARCHAR(30) NOT NULL,
    last_name VARCHAR(30) NOT NULL,
    age INT DEFAULT NULL,
    PRIMARY KEY (id));
Query OK, 0 rows affected (0.017 sec)

MariaDB [NEW_DATABASE_NAME]> INSERT INTO users (first_name, last_name, age) VALUES ("Antoine", "Le Morvan", 44);
Query OK, 1 row affected (0.004 sec)
```

#### Task 5: Creare un utente remoto

In questa attività si creerà un nuovo utente, si concederà l'accesso da remoto e si testerà la connessione con tale utente.

```bash
MariaDB [(none)]> grant all privileges on NEW_DATABASE_NAME.* TO 'NEW_USER_NAME'@'%' identified by 'PASSWORD';
Query OK, 0 rows affected (0.005 sec)

MariaDB [(none)]> flush privileges;
Query OK, 0 rows affected (0.004 sec)
```

Utilizzare questo utente e l'opzione \`-h' per connettersi da remoto al server:

```bash
$ mariadb -h YOUR_SERVER_IP -u NEW_USER_NAME -p NEW_DATABASE_NAME
Enter password:
...

MariaDB [NEW_DATABASE_NAME]>
```

#### Task 6: Eseguire un upgrade

Abilitare il mobulo richiesto:

```bash
$ sudo dnf module enable mariadb:10.11
[sudo] password for antoine:
Last metadata expiration check: 2:00:16 ago on Thu Jun 20 11:50:27 2024.
Dependencies resolved.
============================================================================================================================================= Package                          Architecture                    Version                             Repository                        Size
=============================================================================================================================================Enabling module streams:
 mariadb                                                          10.11

Transaction Summary
=============================================================================================================================================
Is this ok [y/N]: y
Complete!
```

Aggiornare i packages:

```bash
$ sudo dnf update mariadb
Last metadata expiration check: 2:00:28 ago on Thu Jun 20 11:50:27 2024.
Dependencies resolved.
============================================================================================================================================= Package                            Architecture        Version                                                 Repository              Size
=============================================================================================================================================
Upgrading:
 mariadb                            x86_64              3:10.11.6-1.module+el9.4.0+20012+a68bdff7               appstream              1.7 M
 mariadb-backup                     x86_64              3:10.11.6-1.module+el9.4.0+20012+a68bdff7               appstream              6.7 M
 mariadb-common                     x86_64              3:10.11.6-1.module+el9.4.0+20012+a68bdff7               appstream               28 k
 mariadb-errmsg                     x86_64              3:10.11.6-1.module+el9.4.0+20012+a68bdff7               appstream              254 k
 mariadb-gssapi-server              x86_64              3:10.11.6-1.module+el9.4.0+20012+a68bdff7               appstream               15 k
 mariadb-server                     x86_64              3:10.11.6-1.module+el9.4.0+20012+a68bdff7               appstream               10 M
 mariadb-server-utils               x86_64              3:10.11.6-1.module+el9.4.0+20012+a68bdff7               appstream              261 k

Transaction Summary
=============================================================================================================================================
Upgrade  7 Packages

Total download size: 19 M
Is this ok [y/N]: y
Downloading Packages:
(1/7): mariadb-gssapi-server-10.11.6-1.module+el9.4.0+20012+a68bdff7.x86_64.rpm                               99 kB/s |  15 kB     00:00
(2/7): mariadb-server-utils-10.11.6-1.module+el9.4.0+20012+a68bdff7.x86_64.rpm                               1.1 MB/s | 261 kB     00:00
(3/7): mariadb-errmsg-10.11.6-1.module+el9.4.0+20012+a68bdff7.x86_64.rpm                                     2.5 MB/s | 254 kB     00:00
(4/7): mariadb-common-10.11.6-1.module+el9.4.0+20012+a68bdff7.x86_64.rpm                                     797 kB/s |  28 kB     00:00
(5/7): mariadb-10.11.6-1.module+el9.4.0+20012+a68bdff7.x86_64.rpm                                            5.7 MB/s | 1.7 MB     00:00
(6/7): mariadb-server-10.11.6-1.module+el9.4.0+20012+a68bdff7.x86_64.rpm                                     9.5 MB/s |  10 MB     00:01
(7/7): mariadb-backup-10.11.6-1.module+el9.4.0+20012+a68bdff7.x86_64.rpm                                     7.7 MB/s | 6.7 MB     00:00
---------------------------------------------------------------------------------------------------------------------------------------------
Total                                                                                                         13 MB/s |  19 MB     00:01
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction

...

Complete!
```

I database ora devono essere aggiornati (controllare \`/var/log/messages' per i problemi del servizio):

```text
mariadb-check-upgrade[8832]: The datadir located at /var/lib/mysql needs to be upgraded using 'mariadb-upgrade' tool. This can be done using the following steps:
mariadb-check-upgrade[8832]:  1. Back-up your data before with 'mariadb-upgrade'
mariadb-check-upgrade[8832]:  2. Start the database daemon using 'systemctl start mariadb.service'
mariadb-check-upgrade[8832]:  3. Run 'mariadb-upgrade' with a database user that has sufficient privileges
mariadb-check-upgrade[8832]: Read more about 'mariadb-upgrade' usage at:
mariadb-check-upgrade[8832]: https://mariadb.com/kb/en/mysql_upgrade/
```

Non dimenticate di eseguire lo script di aggiornamento fornito da MariaDB:

```bash
sudo mariadb-upgrade
Major version upgrade detected from 10.5.22-MariaDB to 10.11.6-MariaDB. Check required!
Phase 1/8: Checking and upgrading mysql database
Processing databases
mysql
mysql.column_stats                                 OK
mysql.columns_priv                                 OK
mysql.db                                           OK
...
Phase 2/8: Installing used storage engines... Skipped
Phase 3/8: Running 'mysql_fix_privilege_tables'
Phase 4/8: Fixing views
mysql.user                                         OK
...
Phase 5/8: Fixing table and database names
Phase 6/8: Checking and upgrading tables
Processing databases
NEW_DATABASE_NAME
information_schema
performance_schema
sys
sys.sys_config                                     OK
Phase 7/8: uninstalling plugins
Phase 8/8: Running 'FLUSH PRIVILEGES'
OK
```

#### Task 6: Eseguire un dump

Il comando `mariadb-dump` può eseguire un dump del database.

```bash
mariadb-dump -u root -p NEW_DATABASE_NAME > backup.sql
```

Verifica:

```bash
cat backup.sql
-- MariaDB dump 10.19  Distrib 10.11.6-MariaDB, for Linux (x86_64)
--
-- Host: localhost    Database: NEW_DATABASE_NAME
-- ------------------------------------------------------
-- Server version       10.11.6-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
...

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `first_name` varchar(30) NOT NULL,
  `last_name` varchar(30) NOT NULL,
  `age` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES
(1,'Antoine','Le Morvan',44);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

...
-- Dump completed on 2024-06-20 14:32:41
```

### Verificare le proprie Conoscenze

:heavy_check_mark: Quale versione di database è installata di default?

- [ ] MySQL 5.5
- [ ] MariaDB 10.5
- [ ] MariaDB 11.11
- [ ] Mysql 8

:heavy_check_mark: Quale di questi comandi si utilizza per applicare le modifiche sui diritti?

- [ ] flush rights
- [ ] flush privileges
- [ ] mariadb reload
- [ ] apply

### Conclusione

In questo capitolo è stato installato e protetto un server di database MariaDB e sono stati creati un database e un utente dedicato.

Queste competenze sono un prerequisito per l'amministrazione dei database.

Nella prossima sezione vedremo come installare il database MySQL invece del fork di MariaDB.
