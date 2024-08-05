---
author: Antoine Le Morvan
contributors: Steven Spencer
title: Part 4.3 MariaDB database replication
---

## Secondary server with MariaDB

In this chapter, you will learn how to configure a Primary/Secondary system servers with MariaDB.

****

**Objectives**: In this chapter, you will learn how to:

:heavy_check_mark: activate the binlogs in your servers;  
:heavy_check_mark: setup a secondary server to replicate data from primary server.  

:checkered_flag: **MariaDB**, **Replication**, **Primary**, **Secondary**

**Knowledge**: :star: :star:  
**Complexity**: :star: :star: :star:  

**Reading time**: 10 minutes

****

### Generalities secondary server with MariaDB

As soon as you start using your database more intensively, you will need to replicate your data on several servers.

This can be done in several ways:

* Distribute write requests to the primary server and read requests to the secondary server.
* Perform database backups on the secondary server, which avoids blocking writes to the primary server for the duration of the backups.

If your usage becomes even more demanding, you may consider switching to a primary/primary system: replications are then made crosswise, but beware of the risk of blocking the uniqueness of primary keys. Otherwise, you will need to switch to a more advanced clustering system.

### Configuration secondary server with MariaDB

#### How to activate the binlogs

Perform this action on the primary and secondary servers:

Add the following options to your `/etc/my.cnf.d/mariadb-server.cnf` file, under the `[mariadb]` key:

```file
[mariadb]
log-bin
server_id=1
log-basename=server1
binlog-format=mixed
```

for the primary server, and for the secondary server:

```file
[mariadb]
log-bin
server_id=2
log-basename=server2
binlog-format=mixed
```

The `server_id` option must be unique on each server in the cluster, while the `log-basename` option allows you to specify a prefix to the binlog files. If you do not do this, you will not be able to rename your server in the future.

You can now restart the mariadb service on both servers:

```bash
sudo systemctl restart mariadb
```

You can check that binlogs files are well created:

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

#### How to configure the replication

First of all, on the primary, you will need to create users authorized to replicate data (be careful to restrict the IPs authorized):

```bash
$ sudo mariadb

MariaDB [(none)]> CREATE USER 'replication'@'%' IDENTIFIED BY 'PASSWORD';
Query OK, 0 rows affected (0.002 sec)

MariaDB [(none)]> GRANT REPLICATION SLAVE ON *.* TO 'replication'@'%';
Query OK, 0 rows affected (0.002 sec)
```

or better for security (change '192.168.1.101' with your own secondary IP):

```bash
$ sudo mariadb

MariaDB [(none)]> CREATE USER 'replication'@'192.168.1.101' IDENTIFIED BY 'PASSWORD';
Query OK, 0 rows affected (0.002 sec)

MariaDB [(none)]> GRANT REPLICATION SLAVE ON *.* TO 'replication'@'192.168.1.101';
Query OK, 0 rows affected (0.002 sec)
```

If your primary server already contains data, you will need to lock new transactions while the exporting or importing of data occurs to the secondary server(s), and tell the secondary servers when to start replication. If your server does not yet contain any data, the procedure is greatly simplified.

Prevent any changes to the data while you view the binary log position:

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

Do not quit your session to keep the lock.

Record the File and Position details.

If your server contains data, it is time to create a backup and import it onto your secondary server(s). Keep the lock for the duration of the backup, and release it as soon as the backup is complete. This reduces downtime (the time it takes to copy and import the data on the secondary servers).

You can remove the lock now:

```bash
$ sudo mariadb

MariaDB [(none)]> UNLOCK TABLES;
Query OK, 0 rows affected (0.000 sec)
```

On the secondary server, you can now ready to setup the primary server to replicate with:

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

Replace the primary server IP with yours and the `MASTER_LOG_FILE` and `MASTER_LOG_POS` values with those you previously registered.

Check if the replication is ok:

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

The `Seconds_Behind_Master` is an interesting value to monitor as it can help you see if there is a replication issue.

### Workshop secondary server using MariaDB

For this workshop, you will need two servers with MariaDB services installed, configured and secured as described in the previous chapters.

You will configure replication on the secondary server, then create a new database, insert data into it and check that the data is accessible on the secondary server.

Our two servers have the following IP addresses:

* server1: 192.168.1.100
* server2: 192.168.1.101

Remember to replace these values with your own.

#### Task 1: Create a dedicated replication user

On the primary server:

```bash
$ sudo mariadb

MariaDB [(none)]> CREATE USER 'replication'@'192.168.1.101' IDENTIFIED BY 'PASSWORD';
Query OK, 0 rows affected (0.002 sec)

MariaDB [(none)]> GRANT REPLICATION SLAVE ON *.* TO 'replication'@'192.168.1.101';
Query OK, 0 rows affected (0.002 sec)
```

#### Task 2: Record the primary server values

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

#### Task 3: Activate the replication

On the secondary server:

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

Check if the replication is ok:

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

#### Task 4: Create a new database and a user

On the primary:

```bash
MariaDB [(none)]> create database NEW_DATABASE_NAME;
Query OK, 1 row affected (0.002 sec)

MariaDB [(none)]> grant all privileges on NEW_DATABASE_NAME.* TO 'NEW_USER_NAME'@'localhost' identified by 'PASSWORD';
Query OK, 0 rows affected (0.004 sec)
```

On the secondary, check for creation of the database:

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

Magic !

On the secondary, try connecting the new user created on the primary:

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

#### Task 5: Insert new data

Insert new data on the primary server:

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

On the secondary, check that data are replicated:

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

### Check your Knowledge secondary server with MariaDB

:heavy_check_mark: Each server must have the same id within a cluster?

* [ ] True
* [ ] False

:heavy_check_mark: Binary logs must be enabled before replication is activated.?

* [ ] True
* [ ] False
* [ ] It depends

### Conclusion secondary server with MariaDB

As you can see, creating one or more secondary servers is a relatively easy action, but it does require service interruption on the main server.

It does, however, offer many advantages: high data availability, load balancing, and simplified backup.

It goes without saying that, in the event of a main server crash, promotion of one of the secondary servers to main server can occur.

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
