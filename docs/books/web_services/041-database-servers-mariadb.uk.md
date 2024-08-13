---
author: Antoine Le Morvan
contributors: Steven Spencer, Ganna Zhyrnova
title: Частина 4.1 Сервери баз даних MariaDB
tags:
  - mariadb
  - mysql
  - бази даних
  - rdbms
---

MySQL, MariaDB і PostgreSQL є RDBMS (система керування реляційною базою даних) з відкритим кодом.

## MariaDB та MySQL

У цьому розділі ви дізнаєтеся про реляційну базу даних MariaDB і MySQL.

****

**Цілі**: Ви дізнаєтеся, як:

:heavy_check_mark: встановити, налаштувати та захистити сервер MariaDB і сервер MySQL;\
:heavy_check_mark: виконувати деякі адміністративні дії з базами даних і користувачами.

:checkered_flag: **RDBMS**, **database**, **MariaDB**, **MySQL**

**Знання**: :star: :star: :star:\
**Складність**: :star: :star: :star:

**Час читання**: 30 хвилин

****

### Загальні положення

MySQL був розроблений Майклом «Монті» Віденіусом (фінським комп’ютерним вченим), який заснував MySQL AB у 1995 році. MySQL AB була придбана компанією SUN у 2008 році, яка, у свою чергу, була придбана компанією Oracle у 2009 році. Oracle все ще володіє програмним забезпеченням MySQL і розповсюджує його за подвійною ліцензією GPL і пропрієтарною ліцензією.

У 2009 році Майкл Віденіус покинув SUN, заснував Monty Program AB і розпочав розробку спільнотного форка MySQL: MariaDB під ліцензією GPL. Управління проектом покладено на MariaDB Foundation, яка гарантує, що проект залишається безкоштовним.

Не так давно більшість дистрибутивів Linux пропонували пакети MariaDB замість MySQL. Значні облікові записи, такі як Wikipedia та Google, також прийняли форк спільноти.

MySQL і MariaDB є одними з найбільш широко використовуваних RDBMS у світі (професіоналами та широким загалом), особливо для веб-додатків (**LAMP**: Linux + Apache + Mysql-MariaDB + Php).

Основними конкурентами Mysql-MariaDB є:

- PostgreSQL,
- OracleDB,
- Microsoft SQL Server.

Служби баз даних є багатопоточними та багатокористувацькими, працюють у більшості операційних систем (Linux, Unix, BSD, Mac OSx, Windows) і доступні з багатьох мов програмування (PHP, Java, Python, C, C++, Perl тощо).

Пропонується підтримка кількох механізмів, що дозволяє призначати різні механізми до різних таблиць в одній базі даних залежно від вимог:

MyISAM
:   найпростіший, але не підтримує транзакції чи зовнішні ключі. Це індексована послідовна система. MyISAM тепер застарів.

InnoDB
:   керує цілісністю таблиці (зовнішні ключі та транзакції), але займає більше місця на диску. Це механізм за замовчуванням з MySQL версії 5.6. Це механізм транзакцій.

Пам'ять
:   таблиці зберігаються в пам'яті.

Архів
:   стиснення даних під час вставки економить місце на диску, але сповільнює пошукові запити (холодні дані).

Йдеться про прийняття механізму відповідно до потреб: Архів для зберігання журналів, Пам’ять для тимчасових даних тощо.

MariaDB/MySQL використовує порт 3306/tcp для мережевого зв’язку.

У цій главі буде розглянуто цю версію, оскільки стандартною версією, яку надає Rocky, є версія бази даних спільноти MariaDB. Спеціально розглядаються лише відмінності між MySQL і MariaDB.

### Встановлення

Використовуйте команду `dnf`, щоб встановити пакет `mariadb-server`:

```bash
sudo dnf install -y mariadb-server
```

За замовчуванням на Rocky 9 встановлена ​​версія 10.5.

Активуйте службу під час запуску та запустіть її:

```bash
sudo systemctl enable mariadb --now
```

Ви можете перевірити статус служби `mariadb`:

```bash
sudo systemctl status mariadb
```

Щоб інсталювати новішу версію, вам потрібно буде використати модулі `dnf`:

```bash
$ sudo dnf module list mariadb
Last metadata expiration check: 0:00:09 ago on Thu Jun 20 11:39:10 2024.
Rocky Linux 9 - AppStream
Name                          Stream                      Profiles                                        Summary
mariadb                       10.11                       client, galera, server [d]                      MariaDB Module

Hint: [d]efault, [e]nabled, [x]disabled, [i]nstalled
```

Якщо ви ще не встановили сервер mariadb, достатньо буде активувати потрібну версію модуля:

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

Тепер ви можете встановити пакет. Потрібна версія буде встановлена ​​автоматично:

```bash
sudo dnf install -y mariadb-server
```

#### Про користувачів за умовчанням

Зверніть увагу на журнали, надані mariadb під час першого запуску (`/var/log/messages`):

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

### Конфігурація

Конфігураційні файли можна зберігати в `/etc/my.cnf` та `/etc/my.cnf.d/`.

Деякі важливі параметри за замовчуванням налаштовано в `/etc/my.cnf.d/mariadb-server.cnf`:

```text
[server]

[mysqld]
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock
log-error=/var/log/mariadb/mariadb.log
pid-file=/run/mariadb/mariadb.pid
...
```

Як бачите, дані за замовчуванням знаходяться в `/var/lib/mysql`. Для цієї папки може знадобитися багато місця для зберігання та періодичне збільшення обсягу. Тому бажано змонтувати цю папку на спеціальному розділі.

### Безпека

MariaDB і Mysql включають сценарій, який допоможе вам захистити свій сервер. Він видаляє, наприклад, віддалені кореневі входи та вибіркових користувачів, які є менш безпечними параметрами за замовчуванням.

Використовуйте `mariadb-secure-installation` і захистіть свій сервер:

```bash
sudo mariadb-secure-installation
```

Сценарій запропонує вам ввести пароль для вашого користувача root.

!!! NOTE "Примітка"

````
Команда `mysql_secure_installation` тепер є символічним посиланням на команду `mariadb-secure-installation`:

```bash
$ ll /usr/bin/mysql_secure_installation
lrwxrwxrwx. 1 root root 27 Oct 12  2023 /usr/bin/mysql_secure_installation -> mariadb-secure-installation
```
````

Якщо надання пароля кожного разу, коли вам потрібно використовувати команди MariaDB, є проблемою, ви можете налаштувати файл `~/.my.cnf` з вашими обліковими даними, які за замовчуванням використовуватимуться Mariadb для підключення до вашого сервера.

```bash
[client]
user="root"
password="#######"
```

Переконайтеся, що дозволи достатньо обмежувальні, щоб надати поточному користувачеві доступ до:

```bash
chmod 600 ~/.my.cnf
```

!!! WARNING "Увага"

```
Це не найкращий спосіб. Є більш безпечне рішення, ніж зберігати пароль у звичайному тексті. Починаючи з MySQL 5.6.6, завдяки команді 'mysql_config_editor' тепер ви можете зберігати свої облікові дані в зашифрованому логіні `.mylogin.cnf`.
```

Якщо на вашому сервері встановлено брандмауер (хороша річ), вам, можливо, доведеться розглянути питання про його відкриття, але лише якщо вам потрібен доступ до служби ззовні.

```bash
sudo firewall-cmd --zone=public --add-service=mysql
sudo firewall-cmd --reload
```

!!! NOTE "Примітка"

```
Найкращими заходами безпеки є не відкривати сервер бази даних для зовнішнього світу (якщо сервер додатків розміщено на тому самому сервері) або обмежувати доступ лише авторизованими IP-адресами.
```

### Адміністрування

#### Команда `mariadb`

Команда `mariadb` — це проста оболонка SQL, яка підтримує інтерактивне та неінтерактивне використання.

```bash
mysql -u user -p [base]
```

| Опція     | Опис                                                    |
| --------- | ------------------------------------------------------- |
| `-u user` | Надає ім’я користувача для підключення. |
| `-p`      | Запитує пароль.                         |
| `base`    | База даних для підключення.             |

!!! NOTE "Примітка"

````
Команда `mysql` тепер є символічним посиланням на команду `mariadb`:

```bash
$ ll /usr/bin/mysql
lrwxrwxrwx. 1 root root 7 Oct 12  2023 /usr/bin/mysql -> mariadb
```
````

Приклад:

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

#### Команда `mariadb-admin`

Команда `mariadb-admin` — це клієнт, який адмініструє сервер MariaDB.

```bash
mariadb-admin -u user -p command
```

| Опція     | Опис                                                    |
| --------- | ------------------------------------------------------- |
| `-u user` | Надає ім’я користувача для підключення. |
| `-p`      | Запитує пароль.                         |
| `command` | Команда для виконання.                  |

`mariadb-admin` надає кілька команд як `version`, `variables`, `stop-slave` або `start-slaves`, `create databasename` тощо.

Приклад:

```bash
mariadb-admin -u root -p version
```

!!! NOTE "Примітка"

````
Команда `mysqladmin` тепер є символічним посиланням на команду `mariadb-admin`:

```bash
$ ll /usr/bin/mysqladmin
lrwxrwxrwx. 1 root root 13 Oct 12  2023 /usr/bin/mysqladmin -> mariadb-admin
```
````

### Про журналювання

MariaDB надає різні журнали:

- **Error log**: Містить повідомлення, що генеруються під час запуску та завершення служби, а також важливі події (попередження та помилки).
- **Binary log**: Цей журнал (у двійковому форматі) записує всі дії, які змінюють структуру бази даних або дані. Якщо вам потрібно відновити базу даних, вам потрібно буде відновити резервну копію ТА відтворити двійковий журнал, щоб відновити стан бази даних до збою.
- **Query log**: Тут реєструються всі запити клієнтів.
- **Slow requests log**: Повільні запити, тобто запити, які виконуються довше встановленого часу, реєструються окремо в цьому журналі. Аналізуючи цей файл, ви можете вжити заходів для скорочення часу виконання (наприклад, шляхом налаштування індексів або зміни клієнтської програми).

За винятком двійкового журналу, ці журнали мають текстовий формат і їх можна використовувати безпосередньо!

Щоб увімкнути журналювання довгих запитів, відредагуйте файл конфігурації `my.cnf`, щоб додати такі рядки:

```bash
slow_query_log      = 1
slow_query_log_file = /var/log/mysql/mysql-slow.log
long_query_time     = 2
```

Мінімальне значення для змінної `long_query_time` — 0, а значення за замовчуванням — 10 секунд.

Перезапустіть службу, щоб зміни вступили в силу.

Після заповнення файлу журналу ви можете проаналізувати його за допомогою команди `mariadb-dumpslow`.

```bash
mariadb-dumpslow [options] [log_file ...]
```

| Опція          | Опис                                               |
| -------------- | -------------------------------------------------- |
| `-t n`         | Відображає лише перші n запитів.   |
| `-s sort_type` | Сортує за кількістю запитів.       |
| `-r`           | Інвертує відображення результатів. |

Типи сортування можуть бути:

| Опція        | Опис                                                                                                              |
| ------------ | ----------------------------------------------------------------------------------------------------------------- |
| `c`          | за кількістю звернень.                                                                            |
| `t` або `at` | відповідно до часу виконання або середнього часу виконання (a для середнього). |
| `l` або `al` | відповідно до часу блокування або його середнього.                                                |
| `r` або `aR` | як функція кількості повернутих рядків або її середнього значення.                                |

### Про резервне копіювання

Як і в будь-якій RDBMS, резервне копіювання бази даних виконується, коли модифікація даних знаходиться в автономному режимі. Ви можете зробити це наступним чином:

- зупинка служби, відома як автономне резервне копіювання;
- поки служба працює шляхом тимчасового блокування оновлень (призупинення всіх змін). Це резервне копіювання онлайн.
- використання знімка файлової системи LVM, що дозволяє резервне копіювання даних за допомогою холодної файлової системи.

Формат резервної копії може бути файлом ASCII (текстовий), що представляє стан бази даних і її дані у формі команд SQL, або двійковий файл, що відповідає файлам зберігання MySQL.

Хоча ви можете створити резервну копію двійкового файлу за допомогою звичайних утиліт, таких як tar або cpio, для файлу ASCII потрібна така утиліта, як `mariadb-dump`.

Команда `mariadb-dump` може виконати дамп вашої бази даних.

Під час процесу доступ до даних заблоковано.

```bash
mariadb-dump -u root -p DATABASE_NAME > backup.sql
```

!!! NOTE "Примітка"

```
Не забувайте, що після відновлення повної резервної копії відновлення двійкових файлів (binlogs) завершує відновлення даних.
```

Отриманий файл можна використовувати для відновлення даних бази даних. База даних має все ще існувати, або ви повинні створити її заново!:

```bash
mariadb -u root -p DATABASE_NAME < backup.sql
```

### Графічні засоби

Існують графічні засоби для полегшення адміністрування та керування даними бази даних. Ось кілька прикладів:

- [DBeaver](https://dbeaver.io/)

### Практичне завдання

Під час виконання цього завдання ви встановите, налаштуєте та захистите свій сервер mariadb.

#### Завдання 1: Встановлення

Встановіть пакет mariadb-server:

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

Встановлення додає користувача `mysql` до системи з `/var/lib/mysql` як домашній каталог:

```bash
$ cat /etc/passwd
...
mysql:x:27:27:MySQL Server:/var/lib/mysql:/sbin/nologin
...
```

Увімкніть і запустіть службу:

```bash
$ sudo systemctl enable mariadb --now
Created symlink /etc/systemd/system/mysql.service → /usr/lib/systemd/system/mariadb.service.
Created symlink /etc/systemd/system/mysqld.service → /usr/lib/systemd/system/mariadb.service.
Created symlink /etc/systemd/system/multi-user.target.wants/mariadb.service → /usr/lib/systemd/system/mariadb.service.
```

Перевірте встановлення:

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

Спробуйте підключитися до сервера:

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

Як бачите, користувачеві `root` не потрібно вводити пароль. Ви виправите це під час наступного завдання.

#### Завдання 2: Захистіть свій сервер

Запустіть `mariadb-secure-installation` і дотримуйтесь інструкцій:

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
```

Спробуйте знову підключитися до свого сервера з паролем і без нього:

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

Налаштуйте брандмауер:

```bash
sudo firewall-cmd --zone=public --add-service=mysql --permanent
sudo firewall-cmd --reload
```

#### Завдання 3: Тестування

Перевірте встановлення:

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

`Версія` надає інформацію про сервер.

#### Завдання 4: Створити нову базу даних і користувача

Створіть нову базу даних:

```sql
MariaDB [(none)]> create database NEW_DATABASE_NAME;
```

Створіть нового користувача та надайте йому всі права на всі таблиці цієї бази даних:

```sql
MariaDB [(none)]> grant all privileges on NEW_DATABASE_NAME.* TO 'NEW_USER_NAME'@'localhost' identified by 'PASSWORD';
```

Замініть `localhost` на `%`, якщо ви хочете надати доступ звідусіль, або замініть на IP-адресу, якщо можливо.

Ви можете обмежити надані привілеї. Існують різні типи дозволів, які можна запропонувати користувачам:

- **SELECT**: читати дані
- **USAGE**: авторизація для підключення до сервера (надається за замовчуванням при створенні нового користувача)
- **INSERT**: додати нові кортежі до таблиці.
- **UPDATE**: змінити існуючі кортежі
- **DELETE**: видалити кортежі
- **CREATE**: створювати нові таблиці або бази даних
- **DROP**: видалити існуючі таблиці або бази даних
- **ALL PRIVILEGES**: всі права
- **GRANT OPTION**: надавати або знімати права іншим користувачам

Не забудьте перезавантажити та застосувати нові права:

```sql
MariaDB [(none)]> flush privileges;
```

Перевірте:

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

Додайте зразки даних у свою базу даних:

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

#### Завдання 5: Створити віддаленого користувача

У цьому завданні ви створите нового користувача, надасте віддалений доступ і перевірите з’єднання з цим користувачем.

```bash
MariaDB [(none)]> grant all privileges on NEW_DATABASE_NAME.* TO 'NEW_USER_NAME'@'%' identified by 'PASSWORD';
Query OK, 0 rows affected (0.005 sec)

MariaDB [(none)]> flush privileges;
Query OK, 0 rows affected (0.004 sec)
```

Використовуйте цього користувача та опцію `-h` для віддаленого підключення до вашого сервера:

```bash
$ mariadb -h YOUR_SERVER_IP -u NEW_USER_NAME -p NEW_DATABASE_NAME
Enter password:
...

MariaDB [NEW_DATABASE_NAME]>
```

#### Завдання 6: Виконайте оновлення

Увімкніть потрібний модуль:

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

Оновіть пакети:

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

Тепер ваші бази даних потребують оновлення (перевірте свій `/var/log/messages` як скарги на службу):

```text
mariadb-check-upgrade[8832]: The datadir located at /var/lib/mysql needs to be upgraded using 'mariadb-upgrade' tool. This can be done using the following steps:
mariadb-check-upgrade[8832]:  1. Back-up your data before with 'mariadb-upgrade'
mariadb-check-upgrade[8832]:  2. Start the database daemon using 'systemctl start mariadb.service'
mariadb-check-upgrade[8832]:  3. Run 'mariadb-upgrade' with a database user that has sufficient privileges
mariadb-check-upgrade[8832]: Read more about 'mariadb-upgrade' usage at:
mariadb-check-upgrade[8832]: https://mariadb.com/kb/en/mysql_upgrade/
```

Не забудьте виконати сценарій оновлення, наданий MariaDB:

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

#### Завдання 6: Виконайте дамп

Команда `mariadb-dump` може виконати дамп вашої бази даних.

```bash
mariadb-dump -u root -p NEW_DATABASE_NAME > backup.sql
```

Підтвердити:

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

### Перевірте свої знання

:heavy_check_mark: Яка версія бази даних встановлена ​​за замовчуванням?

- [ ] MySQL 5.5
- [ ] MariaDB 10.5
- [ ] MariaDB 11.11
- [ ] Mysql 8

:heavy_check_mark: Яку команду ви використовуєте для застосування змін прав?

- [ ] flush rights
- [ ] flush privileges
- [ ] mariadb reload
- [ ] apply

### Висновок

У цій главі ви встановили та захистили сервер бази даних MariaDB, а також створили базу даних і виділеного користувача.

Ці навички є необхідною умовою для адміністрування ваших баз даних.

У наступному розділі ви побачите, як встановити базу даних MySQL замість гілки MariaDB.
