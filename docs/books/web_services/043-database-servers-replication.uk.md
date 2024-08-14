---
author: Antoine Le Morvan
contributors: Steven Spencer
title: Частина 4.3 Реплікація бази даних MariaDB
---

## Вторинний сервер з MariaDB

Цей розділ навчить вас, як налаштувати первинний/вторинний сервери системи за допомогою MariaDB.

****

**Цілі**: Ви дізнаєтеся, як:

:heavy_check_mark: активувати binlogs на своїх серверах;\
:heavy_check_mark: налаштувати вторинний сервер для реплікації даних з основного сервера.

:checkered_flag: **MariaDB**, **Реплікація**, **Первинний**, **Вторинний**

**Знання**: :star: :star:\
**Складність**: :star: :star: :star:

**Час читання**: 10 хвилин

****

### Загальні відомості про вторинний сервер із MariaDB

Як тільки ви починаєте більш інтенсивно використовувати свою базу даних, ви повинні відтворити свої дані на кількох серверах.

Це можна зробити кількома способами:

- Розповсюдити запити на запис на основний сервер і запити на читання на вторинний сервер.
- Виконати резервне копіювання бази даних на вторинному сервері, що дозволяє уникнути блокування запису на основний сервер протягом тривалості резервного копіювання.

Якщо ваше використання стане ще більш вимогливим, ви можете розглянути можливість переходу на первинну/первинну систему: реплікації виконуються навхрест, але остерігайтеся ризику блокування унікальності первинних ключів. В іншому випадку вам доведеться перейти на більш просунуту систему кластеризації.

### Конфігурація вторинного сервера з MariaDB

#### Як активувати binlogs

Виконайте цю дію на первинному та додатковому серверах:

Додайте наступні параметри до свого файлу `/etc/my.cnf.d/mariadb-server.cnf` під ключ `[mariadb]`:

```file
[mariadb]
log-bin
server_id=1
log-basename=server1
binlog-format=mixed
```

для основного сервера та для додаткового сервера:

```file
[mariadb]
log-bin
server_id=2
log-basename=server2
binlog-format=mixed
```

Параметр `server_id` має бути унікальним на кожному сервері в кластері, тоді як параметр `log-basename` дозволяє вказати префікс для файлів binlog. Якщо ви цього не зробите, ви не зможете перейменувати свій сервер.

Тепер ви можете перезапустити службу MariaDB на обох серверах:

```bash
sudo systemctl restart mariadb
```

Ви можете перевірити, чи правильно створені файли binlogs:

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

#### Як налаштувати реплікацію

Перш за все, на основному пристрої вам потрібно буде створити користувачів, авторизованих для реплікації даних (будьте обережні, щоб обмежити авторизовані IP-адреси):

```bash
$ sudo mariadb

MariaDB [(none)]> CREATE USER 'replication'@'%' IDENTIFIED BY 'PASSWORD';
Query OK, 0 rows affected (0.002 sec)

MariaDB [(none)]> GRANT REPLICATION SLAVE ON *.* TO 'replication'@'%';
Query OK, 0 rows affected (0.002 sec)
```

або краще для безпеки (змініть '192.168.1.101' на власний вторинний IP):

```bash
$ sudo mariadb

MariaDB [(none)]> CREATE USER 'replication'@'192.168.1.101' IDENTIFIED BY 'PASSWORD';
Query OK, 0 rows affected (0.002 sec)

MariaDB [(none)]> GRANT REPLICATION SLAVE ON *.* TO 'replication'@'192.168.1.101';
Query OK, 0 rows affected (0.002 sec)
```

Ви повинні заблокувати нові транзакції, якщо ваш основний сервер уже містить дані. Навпаки, експорт або імпорт даних відбувається на вторинному сервері та повідомляє вторинним серверам, коли починати реплікацію. Якщо ваш сервер ще не містить жодних даних, процедура значно спрощується.

Запобігайте будь-яким змінам даних під час перегляду позиції двійкового журналу:

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

Не припиняйте сеанс, щоб зберегти блокування.

Запишіть деталі файлу та позиції.

Якщо ваш сервер містить дані, настав час створити резервну копію та імпортувати її на вторинний сервер(и). Тримайте блокування на час резервного копіювання та зніміть його, щойно резервне копіювання завершиться. Це зменшує час простою (час, необхідний для копіювання та імпорту даних на вторинних серверах).

Ви можете зняти блокування зараз:

```bash
$ sudo mariadb

MariaDB [(none)]> UNLOCK TABLES;
Query OK, 0 rows affected (0.000 sec)
```

Тепер на додатковому сервері можна налаштувати основний сервер для реплікації з наступним:

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

Замініть IP основного сервера на свій, а значення `MASTER_LOG_FILE` і `MASTER_LOG_POS` на ті, які ви раніше зареєстрували.

Перевірте, чи реплікація в порядку:

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

`Seconds_Behind_Master` - це захоплююче значення для моніторингу, оскільки воно може допомогти вам побачити, чи є проблема реплікації.

### Практичне завдання для вторинного серверу з використанням MariaDB

Вам знадобляться два сервери з установленими, налаштованими та захищеними службами MariaDB, як описано в попередніх розділах.

Ви налаштуєте реплікацію на вторинному сервері, створите нову базу даних, вставите в неї дані та перевірите, чи вони доступні на вторинному сервері.

Наші два сервери мають такі IP-адреси:

- server1: 192.168.1.100
- server2: 192.168.1.101

Не забудьте замінити ці значення своїми.

#### Завдання 1: Створення виділеного користувача реплікації

На основному сервері:

```bash
$ sudo mariadb

MariaDB [(none)]> CREATE USER 'replication'@'192.168.1.101' IDENTIFIED BY 'PASSWORD';
Query OK, 0 rows affected (0.002 sec)

MariaDB [(none)]> GRANT REPLICATION SLAVE ON *.* TO 'replication'@'192.168.1.101';
Query OK, 0 rows affected (0.002 sec)
```

#### Завдання 2: Запишіть значення основного сервера

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

#### Завдання 3: Активувати реплікацію

На вторинному сервері:

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

Перевірте, чи реплікація в порядку:

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

#### Завдання 4: Створити нову базу даних і користувача

На первинному:

```bash
MariaDB [(none)]> create database NEW_DATABASE_NAME;
Query OK, 1 row affected (0.002 sec)

MariaDB [(none)]> grant all privileges on NEW_DATABASE_NAME.* TO 'NEW_USER_NAME'@'localhost' identified by 'PASSWORD';
Query OK, 0 rows affected (0.004 sec)
```

На додатковому сервері перевірте створення бази даних:

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

магія!

На додатковому сервері спробуйте підключити нового користувача, створеного на основному:

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

#### Завдання 5: Вставте нові дані

Вставте нові дані на основний сервер:

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

На вторинному сервері перевірте, чи реплікуються дані:

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

### Перевірте свої знання про вторинний сервер за допомогою MariaDB

:heavy_check_mark: Кожен сервер повинен мати однаковий ідентифікатор у кластері.

- [ ] Так
- [ ] Ні

:heavy_check_mark: Перед активацією реплікації потрібно ввімкнути двійкові журнали.

- [ ] Так
- [ ] Ні
- [ ] Залежить від

### Висновок про вторинний сервер з MariaDB

Як ви бачите, створення одного або кількох вторинних серверів є відносно легкою дією, але це вимагає переривання служби на центральному сервері.

Однак він пропонує багато переваг: високу доступність даних, балансування навантаження та спрощене резервне копіювання.

У разі збою центрального сервера один із вторинних серверів може бути підвищений до центрального.

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
