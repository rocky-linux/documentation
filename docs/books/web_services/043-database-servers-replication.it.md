---
author: Antoine Le Morvan
contributors: Steven Spencer, Ganna Zhyrnova
title: Parte "4.3" Replica di database MariaDB
---

## Server secondario con MariaDB

In questo capitolo si apprenderà come configurare server primari e secondari su macchine con MariaDB.

****

**Obiettivi**: si imparerà come:

:heavy_check_mark: Attiva i binlogs nei server;
:heavy_check_mark: Configura un server secondario per replicare i dati presenti sul server primario

:checkered_flag: **MariaDB**, **Replication**, **Primary**, **Secondary**

**Conoscenza**: :star: :star:
**Complessità**: :star: :star: :star:

**Tempo di lettura**: 10 minuti

****

### Generalità del server secondario con MariaDB

Appena si inizierà a utilizzare in modo più intensivo sarà necessario replicare i dati su più server.

Questo può essere fatto in vari modi:

- Distribuire le richieste, quelle di scrittura al server primario e quelle di lettura a quello secondario.
- Effettuare i backup del database sul server secondario, così si evita di bloccare le scritture sul server primario durante la procedura di backup.

Se l'utilizzo diventa ancora più intensivo, si può considerare la possibilità di passare a un sistema primario/primario: le repliche saranno effettuate trasversalmente, tuttavia bisogna prestare attenzione al rischio di bloccare l'unicità delle chiavi primarie. Altrimenti sarà necessario passare a un sistema di clustering più avanzato.

### Configurazione del server secondario con MariaDB

#### Come attivare i binlogs

Effettuare la seguente azione sui server primari e secondari:

Aggiungere le seguenti opzioni al file `/etc/my.cnf.d/mariadb-server.cnf`, sotto la chiave `[mariadb]`:

```file
[mariadb]
log-bin
server_id=1
log-basename=server1
binlog-format=mixed
```

per il server primario e per il server secondario

```file
[mariadb]
log-bin
server_id=2
log-basename=server2
binlog-format=mixed
```

L'opzione `server_id` deve essere diversa in ogni server nel cluster, mentre l'opzione `log-basename` permette di specificare un prefisso per i file binlog. Se non si aggiungono queste opzioni il server non potrà essere rinominato.

Ora si potrà riavviare il servizio MariaDB su entrambi i server:

```bash
sudo systemctl restart mariadb
```

Ora si può verificare se i file binlog sono stati creati correttamente:

```bash
$ ll /var/lib/mysql/
total 123332
...
-rw-rw----. 1 mysql mysql         0 Jun 21 11:07 multi-master.info
drwx------. 2 mysql mysql      4096 Jun 21 11:07 mysql
srwxrwxrwx. 1 mysql mysql         0 Jun 21 11:16 mysql.sock
-rw-rw----. 1 mysql mysql       330 Jun 21 11:16 server1-bin.000001
-rw-rw----. 1 mysql mysql        21 Jun 21 11:16 server1-bin.index
...
```

#### Come configurare la replicazione

Prima di tutto, sul server primario, è necessario creare utenti autorizzati a replicare dati (attenzione a limitare gli indirizzi IP autorizzati):

```bash
$ sudo mariadb

MariaDB [(none)]> CREATE USER 'replication'@'%' IDENTIFIED BY 'PASSWORD';
Query OK, 0 rows affected (0.002 sec)

MariaDB [(none)]> GRANT REPLICATION SLAVE ON *.* TO 'replication'@'%';
Query OK, 0 rows affected (0.002 sec)
```

per una maggiore sicurezza (cambiare '192.168.1.101' con il proprio indirizzo IP secondario):

```bash
$ sudo mariadb

MariaDB [(none)]> CREATE USER 'replication'@'192.168.1.101' IDENTIFIED BY 'PASSWORD';
Query OK, 0 rows affected (0.002 sec)

MariaDB [(none)]> GRANT REPLICATION SLAVE ON *.* TO 'replication'@'192.168.1.101';
Query OK, 0 rows affected (0.002 sec)
```

È necessario bloccare le nuove transazioni se il server primario contiene già dei dati. Contrariamente, l'esportazione e l'importazione di dati avviene nel server secondario e dice ai server secondari quando iniziare la replicazione. Se il server non contiene ancora dei dati la procedura sarà molto semplificata.

Prevenire qualsiasi modifica ai dati mentre si visualizza la posizione del binary log:

```bash
$ sudo mariadb

MariaDB [(none)]> FLUSH TABLES WITH READ LOCK;
Query OK, 0 rows affected (0.021 sec)

MariaDB [(none)]> SHOW MASTER STATUS;
+--------------------+----------+--------------+------------------+
| File               | Position | Binlog_Do_DB | Binlog_Ignore_DB |
+--------------------+----------+--------------+------------------+
| server1-bin.000001 |     1009 |              |                  |
+--------------------+----------+--------------+------------------+
1 row in set (0.000 sec)

```

Non interrompere la sessione per mantenere il blocco.

Registrare il file e i dettagli della posizione

Se il vostro server contiene dati, è il momento di creare un backup e di importarlo sui vostri server secondari. Mantenere il blocco durante il processo di backup, rimuoverlo non appena il backup è stato completato. Questo riduce il downtime (il tempo necessario a copiare e importare i dati sui server secondari).

Ora si può rimuovere il blocco:

```bash
$ sudo mariadb

MariaDB [(none)]> UNLOCK TABLES;
Query OK, 0 rows affected (0.000 sec)
```

Ora sul server secondario si può configurare il server primario per la replicazione, come segue:

```bash
MariaDB [(none)]> CHANGE MASTER TO
  MASTER_HOST='192.168.1.100',
  MASTER_USER='replication',
  MASTER_PASSWORD='PASSWORD',
  MASTER_PORT=3306,
  MASTER_LOG_FILE='server1-bin.000001',
  MASTER_LOG_POS=1009,
  MASTER_CONNECT_RETRY=10;
Query OK, 0 rows affected, 1 warning (0.021 sec)

MariaDB [(none)]> START SLAVE;
Query OK, 0 rows affected (0.001 sec)
```

Sostituire l'indirizzo IP del server primario con il proprio, sostituire anche i valori in `MASTER_LOG_FILE` e `MASTER_LOG_POS` con quelli registrati precedentemente.

Controllare se la replica è corretta:

```bash
MariaDB [(none)]> SHOW SLAVE STATUS \G
*************************** 1. row ***************************
                Slave_IO_State: Waiting for master to send event
                   Master_Host: 192.168.1.100
                   Master_User: replication
               Master_Log_File: server1-bin.000001
           Read_Master_Log_Pos: 1009
...
         Seconds_Behind_Master: 0
       Slave_SQL_Running_State: Slave has read all relay log; waiting for more updates
...
1 row in set (0.001 sec)
```

Il `Seconds_Behind_Master` è un valore rilevante da monitorare, dato che può aiutare a capire se c'è un problema con la replica.

### Workshop server secondario con MariaDB

Per questo workshop sono necessari due server con i servizi MariaDB installati, configurati e protetti, come descritto nei capitoli precedenti.

Si configurerà una copia sul server secondario, si creerà un nuovo database su quello primario, vi si inseriranno i dati e si verificherà che sia accessibile sul server secondario.

I due server in questo esempio avranno i seguenti indirizzi IP:

- server1: 192.168.1.100
- server2: 192.168.1.101

Ricordate di sostituire questi valori con i vostri.

#### Compito 1: Creare un utente per la replicazione

Sul server primario:

```bash
$ sudo mariadb

MariaDB [(none)]> CREATE USER 'replication'@'192.168.1.101' IDENTIFIED BY 'PASSWORD';
Query OK, 0 rows affected (0.002 sec)

MariaDB [(none)]> GRANT REPLICATION SLAVE ON *.* TO 'replication'@'192.168.1.101';
Query OK, 0 rows affected (0.002 sec)
```

#### Task 2: Salvare i valori del server primario

```bash
$ sudo mariadb

MariaDB [(none)]> FLUSH TABLES WITH READ LOCK;
Query OK, 0 rows affected (0.021 sec)

MariaDB [(none)]> SHOW MASTER STATUS;
+--------------------+----------+--------------+------------------+
| File               | Position | Binlog_Do_DB | Binlog_Ignore_DB |
+--------------------+----------+--------------+------------------+
| server1-bin.000001 |     1009 |              |                  |
+--------------------+----------+--------------+------------------+
1 row in set (0.000 sec)

MariaDB [(none)]> UNLOCK TABLES;
Query OK, 0 rows affected (0.000 sec)
```

#### Task 3: Attivare la replicazione

Sul server secondario eseguire:

```bash
MariaDB [(none)]> CHANGE MASTER TO
  MASTER_HOST='192.168.1.100',
  MASTER_USER='replication',
  MASTER_PASSWORD='PASSWORD',
  MASTER_PORT=3306,
  MASTER_LOG_FILE='server1-bin.000001',
  MASTER_LOG_POS=1009,
  MASTER_CONNECT_RETRY=10;
Query OK, 0 rows affected, 1 warning (0.021 sec)

MariaDB [(none)]> START SLAVE;
Query OK, 0 rows affected (0.001 sec)
```

Controllare se la replica è corretta:

```bash
MariaDB [(none)]> SHOW SLAVE STATUS \G
*************************** 1. row ***************************
                Slave_IO_State: Waiting for master to send event
                   Master_Host: 192.168.1.100
                   Master_User: replication
               Master_Log_File: server1-bin.000001
           Read_Master_Log_Pos: 1009
...
         Seconds_Behind_Master: 0
       Slave_SQL_Running_State: Slave has read all relay log; waiting for more updates
...
1 row in set (0.001 sec)
```

#### Task 4: Creare un nuovo database ed un utente

Sul server primario:

```bash
MariaDB [(none)]> create database NEW_DATABASE_NAME;
Query OK, 1 row affected (0.002 sec)

MariaDB [(none)]> grant all privileges on NEW_DATABASE_NAME.* TO 'NEW_USER_NAME'@'localhost' identified by 'PASSWORD';
Query OK, 0 rows affected (0.004 sec)
```

Sul server secondario, verificare la creazione del database:

```bash
MariaDB [(none)]> show databases;
+--------------------+
| Database           |
+--------------------+
| NEW_DATABASE_NAME  |
| information_schema |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
```

Sul server secondario, provare a collegare il nuovo utente creato sul primario:

```bash
$ mariadb -u NEW_USER_NAME -p
Enter password:
Welcome to the MariaDB monitor.  Commands end with ; or \g.

MariaDB [(none)]> show databases;
+--------------------+
| Database           |
+--------------------+
| NEW_DATABASE_NAME  |
| information_schema |
+--------------------+
2 rows in set (0.000 sec)
```

#### Task 5: Inserire nuovi dati

Inserire nuovi dati sul server primario:

```bash
MariaDB [(none)]> use NEW_DATABASE_NAME
Database changed

MariaDB [(none)]>  CREATE TABLE users(
    ->     id INT NOT NULL AUTO_INCREMENT,
    ->     first_name VARCHAR(30) NOT NULL,
    ->     last_name VARCHAR(30) NOT NULL,
    ->     age INT DEFAULT NULL,
    ->     PRIMARY KEY (id));

MariaDB [NEW_DATABASE_NAME]> INSERT INTO users (first_name, last_name, age) VALUES ("Antoine", "Le Morvan", 44);
Query OK, 1 row affected (0.004 sec)
```

Sul server secondario, verificare che i dati siano replicati:

```bash
MariaDB [(none)]> use NEW_DATABASE_NAME
Database changed

MariaDB [NEW_DATABASE_NAME]> show tables;
+-----------------------------+
| Tables_in_NEW_DATABASE_NAME |
+-----------------------------+
| users                       |
+-----------------------------+
1 row in set (0.000 sec)

MariaDB [NEW_DATABASE_NAME]> SELECT * FROM users;
+----+------------+-----------+------+
| id | first_name | last_name | age  |
+----+------------+-----------+------+
|  1 | Antoine    | Le Morvan |   44 |
+----+------------+-----------+------+
1 row in set (0.000 sec)
```

### Verificare le competenze sul server secondario con MariaDB

:heavy_check_mark: Ogni server deve avere lo stesso ID all'interno di un cluster.

- [ ] Vero
- [ ] Falso

:heavy_check_mark: I log binari devono essere abilitati prima di attivare la replica.

- [ ] Vero
- [ ] Falso
- [ ] Dipende

### Conclusione sul server secondario con MariaDB

Come si può notare, la creazione di uno o più server secondari è un'azione relativamente facile, ma richiede l'interruzione del servizio sul server principale.

Tuttavia, offre molti vantaggi: elevata disponibilità dei dati, load balancing e backup semplificato.

In caso di crash del server centrale, uno dei server secondari può essere promosso a server centrale.

<!---

## PostgreSQL

In this chapter, you will learn about XXXXXXX.

****

**Objectives**: In this chapter, you will learn how to:

:heavy_check_mark: XXX
:heavy_check_mark: XXX

:checkered_flag: **XXX**, **XXX**

**Knowledge**: :star:
**Complexity**: :star:

**Reading time**: XX minutes

****

### Generalities

### Configuration

### Security

### Workshop

#### Task 1 : XXX

#### Task 2 : XXX

#### Task 3 : XXX

#### Task 4 : XXX

### Check your Knowledge

:heavy_check_mark: Simple question? (3 answers)

:heavy_check_mark: Question with multiple answers?

* [ ] Answer 1
* [ ] Answer 2
* [ ] Answer 3
* [ ] Answer 4

-->
