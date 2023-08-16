---
title: Базова система електронної пошти
auther: tianci li
contributors:
---

# Огляд

Цей документ має на меті надати читачеві детальне розуміння різних компонентів системи електронної пошти, включаючи встановлення, базову конфігурацію та зв’язок. Рекомендовано використовувати сервер(и) електронної пошти з відкритим кодом у робочому середовищі.

Усі команди в цьому документі виконуються за допомогою **root(uid=0)**.

## Перелік основних відомостей

|           Роль            |   ОС   |    IP-адреса     |                  версія                  |
|:-------------------------:|:------:|:----------------:|:----------------------------------------:|
|     База даних Mysql      | RL 8.8 | 192.168.100.4/24 |                  8.0.33                  |
| Система електронної пошти | RL 8.8 | 192.168.100.6/24 | postfix: 3.5.8<br/>dovecot: 2.3.16 |
|        `bind` DNS         | RL 8.8 | 192.168.100.7/24 |                 9.11.36                  |

!!! info "Інформація"

    Без бази даних поєднання postfix+dovecot створить робочу систему електронної пошти.

### Встановіть і налаштуйте `bind`

```bash
Shell(192.168.100.7) > dnf -y install bind bind-utils
```

```bash
# Змініть основний файл конфігурації
Shell(192.168.100.7) > vim /etc/named.conf
options {
    listen-on port 53 { 192.168.100.7; };
    ...
    allow-query     { any; };
    ...
};
...
include "/etc/named.rfc1912.zones";
include "/etc/named.root.key";

Shell(192.168.100.7) > named-checkconf /etc/named.conf
```

```bash
# Змініть файл зони
## На практиці ви можете замінити rockylinux.me своїм доменним іменем, наприклад rockylinux.org
Shell(192.168.100.7) > vim /etc/named.rfc1912.zones
zone "rockylinux.me" IN {
        type master;
        file "rockylinux.localhost";
        allow-update { none; };
};
```

!!! question "Питання" 

    **Що таке зона DNS?** Зона DNS — це конкретна частина простору імен DNS, розміщена на сервері DNS. Зона DNS містить записи ресурсів, а сервер DNS відповідає на запити щодо записів у цьому просторі імен. DNS-сервер може мати кілька зон DNS. Простіше кажучи, зона DNS є еквівалентом каталогу книг.

```bash
# Змінити файл даних
Shell(192.168.100.7) > cp -p /var/named/named.localhost /var/named/rockylinux.localhost
Shell(192.168.100.7) > vim /var/named/rockylinux.localhost
$TTL 1D
@       IN SOA   rockylinux.me. rname.invalid. (
                                        0       ; serial
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        3H )    ; minimum
        NS      dns.rockylinux.me.
        MX 2    mail.rockylinux.me.
dns     A       192.168.100.7
mail    A       192.168.100.6

Shell(192.168.100.7) > named-checkzone  rockylinux.me  /var/named/rockylinux.localhost
zone rockylinux.me/IN: loaded serial 0
OK
```

Запустіть службу зв’язування - `systemctl start named.service`

Ми можемо перевірити, чи можуть хости під доменним іменем правильно розпізнавати.

```bash
Shell(192.168.100.7) > systemctl start named.service
Shell(192.168.100.7) > nmcli connection modify ens160 ipv4.dns "192.168.100.7,8.8.8.8"
Shell(192.168.100.7) > systemctl restart NetworkManager.service

Shell(192.168.100.7) > dig mail.rockylinux.me
...
;mail.rockylinux.me.            IN      A

;; ANSWER SECTION:
mail.rockylinux.me.     86400   IN      A       192.168.100.6

;; AUTHORITY SECTION:
rockylinux.me.          86400   IN      NS      dns.rockylinux.me.

;; ADDITIONAL SECTION:
dns.rockylinux.me.      86400   IN      A       192.168.100.7
...
```

!!! info "Інформація"

    одне доменне ім’я не може представляти конкретний хост.

### Встановіть і налаштуйте `Mysql`

```bash
Shell(192.168.100.5) > groupadd mysql && useradd -r -g mysql -s /sbin/nologin mysql
Shell(192.168.100.5) > id mysql
uid=995(mysql) gid=1000(mysql) groups=1000(mysql)
Shell(192.168.100.5) > dnf config-manager --enable powertools
Shell(192.168.100.5) > dnf -y install libaio ncurses-compat-libs ncurses-devel make cmake gcc bison git libtirpc-devel openssl  openssl-devel rpcgen wget tar gzip bzip2 zip unzip  gcc-toolset-12-gcc gcc-toolset-12-gcc-c++ gcc-toolset-12-binutils gcc-toolset-12-annobin-annocheck gcc-toolset-12-annobin-plugin-gcc
Shell(192.168.100.5) > wget https://dev.mysql.com/get/Downloads/MySQL-8.0/mysql-boost-8.0.33.tar.gz  && tar -zvxf mysql-boost-8.0.33.tar.gz  -C /usr/local/src/

Shell(192.168.100.5) > cd /usr/local/src/mysql-8.0.33 && mkdir build && cd build && cmake .. \
-DDEFAULT_CHARSET=utf8mb4 \
-DDEFAULT_COLLATION=utf8mb4_0900_ai_ci \
-DCMAKE_INSTALL_PREFIX=/usr/local/mysql \
-DCMAKE_BUILD_TYPE=RelWithDebInfo \
-DENABLED_LOCAL_INFILE=1 \
-DMYSQL_TCP_PORT=3306 \
-DWITH_BOOST=/usr/local/src/mysql-8.0.33/boost/ \
-DMYSQL_DATADIR=/usr/local/mysql/data \
&& make && make install 
```

```bash
Shell(192.168.100.5) > chown -R mysql:mysql /usr/local/mysql
Shell(192.168.100.5) > chmod -R 755 /usr/local/mysql
Shell(192.168.100.5) > /usr/local/mysql/bin/mysqld  --initialize  --user=mysql  --basedir=/usr/local/mysql  --datadir=/usr/local/mysql/data
2023-07-14T14:46:49.474684Z 0 [System] [MY-013169] [Server] /usr/local/mysql/bin/mysqld (mysqld 8.0.33) initializing of server in progress as process 42038
2023-07-14T14:46:49.496908Z 1 [System] [MY-013576] [InnoDB] InnoDB initialization has started.
2023-07-14T14:46:50.210118Z 1 [System] [MY-013577] [InnoDB] InnoDB initialization has ended.
2023-07-14T14:46:51.305307Z 6 [Note] [MY-010454] [Server] A temporary password is generated for root@localhost: pkqaXRuTn1/N
```

```bash
Shell(192.168.100.5) > vim /etc/my.cnf
[client]
port=3306
socket=/tmp/mysql.sock

[mysqld]
bind-address=192.168.100.5
port=3306
socket=/tmp/mysql.sock
basedir=/usr/local/mysql
datadir=/usr/local/mysql/data
user=mysql
log-error=/usr/local/mysql/data/mysql_log.error

Shell(192.168.100.5) > /usr/local/mysql/bin/mysqld_safe  --user=mysql &
Shell(192.168.100.5) > /usr/local/mysql/bin/mysql -u root --password="pkqaXRuTn1/N"
```

```sql
Mysql > ALTER USER 'root'@'localhost' IDENTIFIED BY 'rockylinux.me';

Mysql > create user 'mailrl'@'%' identified by 'mail.rockylinux.me'; 

Mysql > grant all privileges on *.* to 'mailrl'@'%' with grant option;
```

!!! info "Інформація" 

    Вам не обов’язково використовувати той самий метод, що й автор. Також можливе встановлення Mysql зі сховища або докера.

#### Створіть таблиці та вставте дані

```sql
Shell(192.168.100.5) >  /usr/local/mysql/bin/mysql -u mailrl --password="mail.rockylinux.me"

Mysql > create database mailserver;

Mysql > use mailserver;

Mysql > create table if not exists virtual_domains (
        id int(11) primary key  auto_increment,
        name varchar(50) not null
);

Mysql > create table if not exists virtual_users (
        id int(11) primary key auto_increment,
        email varchar(128) NOT NULL unique,
        password varchar(150) not null,
        domain_id int(11) not null,
        FOREIGN KEY (domain_id) REFERENCES virtual_domains(id) ON DELETE CASCADE
);

Mysql > create table if not exists virtual_aliases (
        id int(11) primary key auto_increment,
        domain_id int(11) NOT NULL,
        source varchar(100) NOT NULL,
        destination varchar(100) NOT NULL,
        FOREIGN KEY (domain_id) REFERENCES virtual_domains(id) ON DELETE CASCADE
);
```

```sql
Mysql > insert into virtual_domains(id,name) values(1,'mail.rockylinux.me'),(2,'rockylinux.me');

Mysql > insert into virtual_aliases(id,domain_id,source,destination) values(1,1,'all@mail.rockylinux.me','frank@mail.rockylinux.me');

Mysql > insert into virtual_aliases(id,domain_id,source,destination) values(2,1,'all@mail.rockylinux.me','leeo@mail.rockylinux.me');
```

Тут я не вставив зашифрований пароль для відповідних користувачів електронної пошти, який потребує використання команди `doveadm pw -s SHA512-crypt -p twotestandtwo`. Перегляньте [тут](#ap1)

#### Знання SHA512 (SHA-2)

SHA-2 (Secure Hash Algorithm 2): стандарт алгоритму криптографічної хеш-функції. Він є наступником SHA-1.

Основні стандарти:

* SHA-0
* SHA-1
* SHA-2: містить -- SHA-224, SHA-256, SHA-384, SHA-512, SHA-512/224, SHA-512/256
* SHA-3

У стандарті шифрування SHA-2 число в алгоритмі означає довжину дайджесту в бітах.

Добре відомо, що в RockyLinux 8 та інших варіантах RHEL 8 для шифрування паролів користувачів використовується алгоритм SHA-512.

```bash
Shell(192.168.100.5) > grep -i method /etc/login.defs
ENCRYPT_METHOD SHA512
```

Його структуру можна побачити у файлі /etc/shadow:

```bash
Shell(192.168.100.5) > grep -i root /etc/shadow | cut -f 2 -d ":"
$6$8jpmvCw8RqNfHYW4$pOlsEZG066eJuTmNHoidtvfWHe/6HORrKkQPwv4eyFxqGXKEXhep6aIRxAtv7FDDIq/ojIY1SfWAQkk7XACeZ0
```

Використовуйте знак $, щоб розділити вихідну текстову інформацію.

* 6: Це означає ідентифікатор. Для алгоритму шифрування SHA-512 він встановлений на 6.
* 8jpmvCw8RqNfHYW4: також відомий як "salt". Його основна функція полягає в підвищенні безпеки та покращенні складності злому. Система може генерувати його випадковим чином або вказати вручну.
* pOlsEZG066eJuTmNHoidtvfWHe/6HORrKkQPwv4eyFxqGXKEXhep6aIRxAtv7FDDIq/ojIY1SfWAQkk7XACeZ0: 86 фіксована кількість символів. Відноситься до зашифрованих паролів, згенерованих за допомогою алгоритмів шифрування.

### Встановіть і налаштуйте `postfix`

```bash
Shell(192.168.100.6) > dnf -y install postfix postfix-mysql
```

Після встановлення Postfix необхідно знати такі файли:

* **/etc/postfix/main.cf**. Основний і найважливіший конфігураційний файл
* **/etc/postfix/master.cf**. Використовується для встановлення параметрів виконання для кожного компонента. Загалом, жодних змін не потрібно, за винятком випадків, коли потрібна оптимізація продуктивності.
* **/etc/postfix/access**. Файл контролю доступу для SMTP.
* **/etc/postfix/transport**. Відображає адреси електронної пошти для хостів ретрансляції.

Вам потрібно знати ці двійкові виконувані файли:

* /**usr/sbin/postalias**. Інструкція створення бази даних псевдонімів. Після виконання цієї команди /etc/aliases.db створюється на основі файлу /etc/aliases
* **/usr/sbin/postcat**. Ця команда використовується для перегляду вмісту пошти в черзі пошти.
* **/usr/sbin/postconf**. Запит конфігураційної інформації.
* **/usr/sbin/postfix**. Основні команди демона. Його можна використовувати наступним чином:

  * `postfix check`
  * `postfix start`
  * `postfix stop`
  * `postfix reload`
  * `postfix status`

!!! tip "Підказка"

    Ви можете вказати MTA за замовчуванням за допомогою команди `alternatives -config mta`, якщо у вас більше одного MTA на вашому сервері.

#### Пояснення до файлу /etc/postfix/main.cf

```bash
Shell(192.168.100.6) > egrep -v "^#|^$" /etc/postfix/main.cf
compatibility_level = 2
queue_directory = /var/spool/postfix
command_directory = /usr/sbin
daemon_directory = /usr/libexec/postfix
data_directory = /var/lib/postfix
mail_owner = postfix
inet_interfaces = localhost
inet_protocols = all
mydestination = $myhostname, localhost.$mydomain, localhost
unknown_local_recipient_reject_code = 550
alias_maps = hash:/etc/aliases
alias_database = hash:/etc/aliases
debug_peer_level = 2
debugger_command =
         PATH=/bin:/usr/bin:/usr/local/bin:/usr/X11R6/bin
         ddd $daemon_directory/$process_name $process_id & sleep 5
sendmail_path = /usr/sbin/sendmail.postfix
newaliases_path = /usr/bin/newaliases.postfix
mailq_path = /usr/bin/mailq.postfix
setgid_group = postdrop
html_directory = no
manpage_directory = /usr/share/man
sample_directory = /usr/share/doc/postfix/samples
readme_directory = /usr/share/doc/postfix/README_FILES
smtpd_tls_cert_file = /etc/pki/tls/certs/postfix.pem
smtpd_tls_key_file = /etc/pki/tls/private/postfix.key
smtpd_tls_security_level = may
smtp_tls_CApath = /etc/pki/tls/certs
smtp_tls_CAfile = /etc/pki/tls/certs/ca-bundle.crt
smtp_tls_security_level = may
meta_directory = /etc/postfix
shlib_directory = /usr/lib64/postfix
```

* **compatibility_level = 2**. Новий механізм, представлений у Postfix 3, розроблено для сумісності з попередніми версіями.
* **data_directory = /var/lib/postfix**. Каталог, де зберігаються кешовані дані.
* **<font color="red">myhostname = host.domain.tld</font>**. Важливі параметри, які були закоментовані. Вам потрібно змінити його на ім’я хосту вашого доменного імені.
* **<font color="red">mydomain = domain.tld</font>**. Важливі параметри, які були закоментовані. Вам потрібно змінити його на ваше доменне ім’я.
* **<font color="red">myorigin = \$myhostname</font>** та **<font color="red">myorigin = $mydomain</font>**. Важливі параметри, які були закоментовані. Основна функція — доповнити поштовий суфікс відправника. **\$** представляє змінну параметра посилання.
* **<font color="red">inet_interfaces = localhost</font>**. Під час отримання пошти цей параметр вказує адресу, яку потрібно прослухати. Значення зазвичай змінюється на "all".
* **inet_protocols = all**. Увімкніть IPv4 та IPv6, якщо підтримується
* **<font color="red">mydestination = \$myhostname, localhost.\$mydomain, localhost</font>**. Вказує, звідки ви можете отримувати пошту.
* **unknown_local_recipient_reject_code = 550**. Код помилки повертається під час надсилання на обліковий запис, який не існує в локальному домені, або відхилення електронного листа.
* **mynetworks =**. Встановіть електронні листи яких хостів можна пересилати.
* **relay_domains = $mydestination**. Установіть електронні листи доменів, які можна пересилати.
* **alias_maps = hash:/etc/aliases**. Він використовується для визначення псевдонімів користувачів і потребує підтримки бази даних.
* **alias_database = hash:/etc/aliases**. База даних має використовуватися за псевдонімами.
* **<font color="red">home_mailbox = Maildir/</font>**. Важливі параметри, які були закоментовані. Це вказує, де зберігається локальна поштова скринька.
* **debug_peer_level = 2**. Рівень журнальних записів.
* **setgid_group = postdrop**. Ідентифікатор групи використовується для надсилання електронних листів або керування чергами.

За винятком елементів параметрів, згаданих або показаних вище, деякі параметри приховані, і їх можна переглянути за допомогою команди `postconf`. Найбільш важливими параметрами є:

* **message_size_limit = 10240000**. Установіть розмір одного електронного листа (включаючи тіло та вкладення). Одиницею вимірювання є B (байт).
* **mailbox_size_limit = 1073741824**. Встановіть обмеження ємності для однієї поштової скриньки користувача.
* **smtpd_sasl_type = cyrus**. Тип автентифікації SASL (проста автентифікація та рівень безпеки). Ви можете використовувати `postconf -a` для перегляду.
* **smtpd_sasl_auth_enable = no**. Чи вмикати автентифікацію SASL.
* **smtpd_sasl_security_options = noanonymous**. Параметри безпеки для SASL. Анонімну автентифікацію вимкнено за умовчанням.
* **smtpd_sasl_local_domain =**. Ім'я локального домену.
* **smtpd_recipient_restrictions =**. Фільтрація одержувачів. Значення за замовчуванням порожнє.

#### Модифікація /etc/postfix/main.cf

```bash
Shell(192.168.100.6) > vim /etc/postfix/main.cf
...
myhostname = mail.rockylinux.me
mydomain = rockylinux.me
myorigin = $myhostname
inet_interfaces = 192.168.100.6
inet_protocols = ipv4
mydestination = 
biff = no
append_dot_mydomain = no
smtpd_sasl_type = dovecot
smtpd_sasl_path = private/auth
smtpd_sasl_auth_enable = yes
smtpd_sasl_local_domain = $myhostname
virtual_transport = lmtp:unix:private/dovecot-lmtp
virtual_mailbox_domains = mysql:/etc/postfix/mysql-virtual-mailbox-domains.cf
virtual_mailbox_maps = mysql:/etc/postfix/mysql-virtual-mailbox-maps.cf
virtual_alias_maps = mysql:/etc/postfix/mysql-virtual-alias-maps.cf,mysql:/etc/postfix/mysql-virtual-email2email.cf
...
```

Остаточний вміст файлу виглядає так:

```text
compatibility_level = 2
queue_directory = /var/spool/postfix
command_directory = /usr/sbin
daemon_directory = /usr/libexec/postfix
data_directory = /var/lib/postfix
mail_owner = postfix
myhostname = mail.rockylinux.me
mydomain = rockylinux.me
myorigin = $myhostname
inet_interfaces = 192.168.100.6
inet_protocols = ipv4
mydestination = 
biff = no
append_dot_mydomain = no
smtpd_sasl_type = dovecot
smtpd_sasl_path = private/auth
smtpd_sasl_auth_enable = yes
smtpd_sasl_local_domain = $myhostname
virtual_transport = lmtp:unix:private/dovecot-lmtp
virtual_mailbox_domains = mysql:/etc/postfix/mysql-virtual-mailbox-domains.cf
virtual_mailbox_maps = mysql:/etc/postfix/mysql-virtual-mailbox-maps.cf
virtual_alias_maps = mysql:/etc/postfix/mysql-virtual-alias-maps.cf,mysql:/etc/postfix/mysql-virtual-email2email.cf
unknown_local_recipient_reject_code = 550
alias_maps = hash:/etc/aliases
alias_database = hash:/etc/aliases
debug_peer_level = 2
debugger_command =
         PATH=/bin:/usr/bin:/usr/local/bin:/usr/X11R6/bin
         ddd $daemon_directory/$process_name $process_id & sleep 5
sendmail_path = /usr/sbin/sendmail.postfix
newaliases_path = /usr/bin/newaliases.postfix
mailq_path = /usr/bin/mailq.postfix
setgid_group = postdrop
html_directory = no
manpage_directory = /usr/share/man
sample_directory = /usr/share/doc/postfix/samples
readme_directory = /usr/share/doc/postfix/README_FILES
smtpd_tls_cert_file = /etc/pki/tls/certs/postfix.pem
smtpd_tls_key_file = /etc/pki/tls/private/postfix.key
smtpd_tls_security_level = may
smtp_tls_CApath = /etc/pki/tls/certs
smtp_tls_CAfile = /etc/pki/tls/certs/ca-bundle.crt
smtp_tls_security_level = may
meta_directory = /etc/postfix
shlib_directory = /usr/lib64/postfix
```

Створіть файл і запишіть відповідний вміст:

```bash
Shell(192.168.100.6) > vim /etc/postfix/mysql-virtual-mailbox-domains.cf
user = mailrl
password = mail.rockylinux.me
hosts = 192.168.100.5
dbname = mailserver
query = SELECT 1 FROM virtual_domains WHERE name='%s'

Shell(192.168.100.6) > vim /etc/postfix/mysql-virtual-mailbox-maps.cf
user = mailrl
password = mail.rockylinux.me
hosts = 192.168.100.5
dbname = mailserver
query = SELECT 1 FROM virtual_users WHERE email='%s'

Shell(192.168.100.6) > vim /etc/postfix/mysql-virtual-alias-maps.cf
user = mailrl
password = mail.rockylinux.me
hosts = 192.168.100.5
dbname = mailserver
query = SELECT destination FROM virtual_aliases WHERE source='%s'

Shell(192.168.100.6) > vim /etc/postfix/mysql-virtual-email2email.cf
user = mailrl
password = mail.rockylinux.me
hosts = 192.168.100.5
dbname = mailserver
query = SELECT email FROM virtual_users WHERE email='%s'
```

!!! warning "Важливо" 

    Якщо ви зіткнулися з такою помилкою після запуску `systemctl start postfix.service` -- "fatal: open lock file /var/lib/postfix/master.lock: unable to set exclusive lock: Resource temporarily unavailable." Видаліть наявний файл **/var/lib/postfix/master.lock**

Тестування конфігурації Postfix:

```bash
Shell(192.168.100.6) > systemctl start postfix.service
Shell(192.168.100.6) > postfix check
Shell(192.168.100.6) > postfix status

# If the command return 1, it is successful.
Shell(192.168.100.6) > postmap -q mail.rockylinux.me mysql:/etc/postfix/mysql-virtual-mailbox-domains.cf
Shell(192.168.100.6) > echo $?
1

Shell(192.168.100.6) > postmap -q frank@mail.rockylinux.me mysql:/etc/postfix/mysql-virtual-mailbox-maps.cf
Shell(192.168.100.6) > echo $?
1

Shell(192.168.100.6) > postmap -q all@mail.rockylinux.me mysql:/etc/postfix/mysql-virtual-alias-maps.cf
frank@mail.rockylinux.me,leeo@mail.rockylinux.me
```

#### Модифікація /etc/postfix/master.cf

Змінений файл виглядає так:

```bash
Shell(192.168.100.6) > egrep -v "^#|^$" /etc/postfix/master.cf
smtp      inet  n       -       n       -       -       smtpd
submission inet n       -       n       -       -       smtpd
  -o syslog_name=postfix/submission
  -o smtpd_tls_security_level=encrypt
  -o smtpd_sasl_auth_enable=yes
  -o smtpd_tls_auth_only=yes
  -o smtpd_reject_unlisted_recipient=no
  -o smtpd_client_restrictions=$mua_client_restrictions
  -o smtpd_helo_restrictions=$mua_helo_restrictions
  -o smtpd_sender_restrictions=$mua_sender_restrictions
  -o smtpd_recipient_restrictions=
  -o smtpd_relay_restrictions=permit_sasl_authenticated,reject
  -o milter_macro_daemon_name=ORIGINATING
smtps     inet  n       -       n       -       -       smtpd
  -o syslog_name=postfix/smtps
  -o smtpd_tls_wrappermode=yes
  -o smtpd_sasl_auth_enable=yes
  -o smtpd_reject_unlisted_recipient=no
  -o smtpd_client_restrictions=$mua_client_restrictions
  -o smtpd_helo_restrictions=$mua_helo_restrictions
  -o smtpd_sender_restrictions=$mua_sender_restrictions
  -o smtpd_recipient_restrictions=
  -o smtpd_relay_restrictions=permit_sasl_authenticated,reject
  -o milter_macro_daemon_name=ORIGINATING
...
```

Нарешті виконайте команду `systemctl restart postfix.service`. На цьому налаштування postfix закінчено.

### Встановлення і налаштування `dovecot`

```bash
Shell(192.168.100.6) > dnf config-manager --enable devel && dnf -y install dovecot dovecot-devel dovecot-mysql
```

Без зміни будь-яких файлів вихідна структура каталогу виглядає так:

```bash
Shell(192.168.100.6) > tree /etc/dovecot/
/etc/dovecot/
├── conf.d
│   ├── 10-auth.conf
│   ├── 10-director.conf
│   ├── 10-logging.conf
│   ├── 10-mail.conf
│   ├── 10-master.conf
│   ├── 10-metrics.conf
│   ├── 10-ssl.conf
│   ├── 15-lda.conf
│   ├── 15-mailboxes.conf
│   ├── 20-imap.conf
│   ├── 20-lmtp.conf
│   ├── 20-pop3.conf
│   ├── 20-submission.conf
│   ├── 90-acl.conf
│   ├── 90-plugin.conf
│   ├── 90-quota.conf
│   ├── auth-checkpassword.conf.ext
│   ├── auth-deny.conf.ext
│   ├── auth-dict.conf.ext
│   ├── auth-ldap.conf.ext
│   ├── auth-master.conf.ext
│   ├── auth-passwdfile.conf.ext
│   ├── auth-sql.conf.ext
│   ├── auth-static.conf.ext
│   └── auth-system.conf.ext
└── dovecot.conf
```

Так, і Postfix, і Dovecot мають дуже складні конфігурації, тому більшості системних адміністраторів GNU/Linux рекомендується використовувати сервери електронної пошти з відкритим кодом.

Як і у випадку з postfix, введіть команду `doveconf`, щоб переглянути повну інформацію про налаштування.

Опис файлу такий:

* **dovecot.conf**: основний файл конфігурації dovecot.

  * Завантажте файли підконфігурації за допомогою методу `!include conf.d/*.conf`. Dovecot не хвилює, які налаштування в яких файлах.
  * Цифровий префікс підфайлу конфігурації призначений для полегшення розуміння людиною порядку його аналізу.
  * Через історичні причини все ще є деякі конфігураційні файли, зовнішні для основного `dovecot.conf`, які зазвичай називаються `*.conf.ext`.
  * У файлі конфігурації можна використовувати змінні, які поділено на **глобальні змінні** та **змінні користувача**, починаючи з `%`. Див. [тут](https://doc.dovecot.org/configuration_manual/config_file/config_variables/#config-variables).

* **10-auth.conf**. Конфігурація, пов’язана з автентифікацією особи.
* **10-logging.conf**. Конфігурація, пов'язана з журналом. Це може бути корисним для аналізу продуктивності, налагодження програмного забезпечення тощо.
* **10-mail.conf**. Конфігурація розташування поштових скриньок і просторів імен. За замовчуванням значення розташування поштової скриньки користувача порожнє, що означає, що Dovecot автоматично шукає розташування поштової скриньки. Якщо у користувача немає пошти, ви повинні явно повідомити Dovecot розташування всіх поштових скриньок.
* **10-metrics.conf**. Конфігурація, пов'язана зі статистичною інформацією.
* **15-mailboxes.conf**. Конфігурація визначення поштової скриньки.
* **auth-sql.conf.ext**. Аутентифікація для користувачів SQL.

#### Деякі важливі параметри конфігураційного файлу

* `protocols = imap pop3 lmtp submission`. Dovecot підтримує протоколи.
* `listen = *, ::`. Відокремлений комами список IP-адрес або хостів, на яких слід прослуховувати з’єднання. «*» прослуховує всі інтерфейси IPv4, «::» прослуховує всі інтерфейси IPv6.
* `disable_plaintext_auth = yes`. Чи вимкнути відкритий пароль для автентифікації.
* `auth_mechanisms =`. Тип механізму автентифікації, значення якого можуть бути кількома та розділені пробілами. Значення: plain, login, digest-md5, cram-md5, ntlm, rpa, apop, anonymous, gssapi, otp, skey, gss-spnego.
* `login_trusted_networks=`. Яким клієнтам (MUA) дозволено використовувати Dovecot. Це може бути окрема IP-адреса, це може бути сегмент мережі, або вона може бути змішана та розділена пробілами. Ось так-- `login_trusted_networks = 10.1.1.0/24 192.168.100.2`
* `mail_location =`. Якщо значення порожнє, Dovecot намагається автоматично знайти поштові скриньки (переглядаючи ~/Maildir, /var/mail/username, ~/mail і ~/Mail у такому порядку). Однак автоматичне виявлення зазвичай не вдається користувачам, чий поштовий каталог ще не створено, тому ви повинні чітко вказати тут повне місцезнаходження, якщо це можливо.
* `mail_privileged_group =`. Ця група тимчасово ввімкнена для привілейованих операцій. Це використовується лише з INBOX, коли його початкове створення або точкове блокування не вдається. Як правило, це значення "mail" для доступу до/var/mail.

#### Модифікація декількох файлів

```bash
Shell(192.168.100.6) > vim /etc/dovecot/dovecot.conf
...
protocols = imap pop3 lmtp
listen = 192.168.100.6
...
```

```bash
Shell(192.168.100.6) > vim /etc/dovecot/conf.d/10-mail.conf
...
# %u - ім'я користувача
# %n - частина користувача в user@domain, те саме, що %u, якщо домену немає
# %d - доменна частина в user@domain, пуста, якщо домену немає
# %h - домашній каталог
mail_location = maildir:/var/mail/vhosts/%d/%n...
mail_privileged_group = mail
...
```

Створіть пов’язані каталоги -- `mkdir -p /var/mail/vhosts/rockylinux.me`. `rockylinx.me` відноситься до доменного імені, на яке ви подали заявку (в електронній пошті називається доменом або локальним доменом).

Додайте пов’язаних користувачів і вкажіть домашній каталог -- `groupadd -g 2000 vmail && useradd -g vmail -u 2000 -d /var/mail/ vmail`

Змінити власника та групу -- `chown -R vmail:vmail /var/mail/`

Скасувати відповідні коментарі до файлу:

```bash
Shell(192.168.100.6) > vim /etc/dovecot/conf.d/auth-sql.conf.ext
passdb {
    driver = sql
    args = /etc/dovecot/dovecot-sql.conf.ext
}
userdb {
    driver = static
    args = uid=vmail gid=vmail home=/var/mail/vhosts/%d/%n
}
...
```

!!! warning "Важливо"

    Не пишіть наведену вище граматику в один рядок, наприклад «userdb {driver = sql args = uid=vmail gid=vmail home=/var/mail/vhosts/%d/%n}». Інакше не вийде.

Створіть файл /etc/dovecot/dovecot-sql.conf.ext і запишіть відповідний вміст:

```bash
Shell(192.168.100.6) > vim /etc/dovecot/dovecot-sql.conf.ext
driver = mysql
connect = host=192.168.100.5 dbname=mailserver user=mailrl password=mail.rockylinux.me
default_pass_scheme = SHA512-CRYPT
password_query = SELECT password FROM virtual_users WHERE email='%u'
```

Змінити власника та групу -- `chown -R vmail:dovecot /etc/dovecot`

Змінити дозволи папки -- `chmod -R 770 /etc/dovecot`

```bash
Shell(192.168.100.6) > vim /etc/dovecot/conf.d/10-auth.conf
disable_plaintext_auth = yes
...
auth_mechanisms = plain login
...
#!include auth-system.conf.ext
!include auth-sql.conf.ext
```

```bash
Shell(192.168.100.6) > vim /etc/dovecot/conf.d/10-master.conf
...
service lmtp {
  unix_listener /var/spool/postfix/private/dovecot-lmtp {
    mode = 0600
    user = postfix
    group = postfix
  }
}
...
service auth {
  unix_listener auth-userdb {
    mode = 0600
    user = vmail
    group = vmail
  }
  unix_listener /var/spool/postfix/private/auth {
    mode = 0660
    user = postfix
    group = postfix
  }
  user = dovecot
}

service auth-worker {
  user = vmail
}
...
```

Гаразд, використовуйте команду, щоб запустити службу-- `systemctl start dovecot.service`

!!! info "Інформація" 

    Під час ініціалізації dovecot файл **/usr/libexec/dovecot/mkcert.sh** виконується для створення самопідписаного сертифіката.

Ви можете перевірити зайнятість порту за допомогою такої команди:

```bash
Shell(192.168.100.6) > ss -tulnp
Netid    State     Recv-Q    Send-Q                           Local Address:Port       Peer Address:Port   Process
udp      UNCONN    0         0                                    127.0.0.1:323             0.0.0.0:*       users:(("chronyd",pid=715,fd=5))
udp      UNCONN    0         0                                        [::1]:323                [::]:*       users:(("chronyd",pid=715,fd=6))
udp      UNCONN    0         0            [fe80::20c:29ff:fe6f:8666]%ens160:546                [::]:*       users:(("NetworkManager",pid=710,fd=24))
tcp      LISTEN    0         128                                    0.0.0.0:22              0.0.0.0:*       users:(("sshd",pid=732,fd=3))
tcp      LISTEN    0         100                              192.168.100.6:25              0.0.0.0:*       users:(("master",pid=4066,fd=13))
tcp      LISTEN    0         100                              192.168.100.6:993             0.0.0.0:*       users:(("dovecot",pid=3808,fd=39))
tcp      LISTEN    0         100                              192.168.100.6:995             0.0.0.0:*       users:(("dovecot",pid=3808,fd=22))
tcp      LISTEN    0         100                              192.168.100.6:587             0.0.0.0:*       users:(("master",pid=4066,fd=17))
tcp      LISTEN    0         100                              192.168.100.6:110             0.0.0.0:*       users:(("dovecot",pid=3808,fd=21))
tcp      LISTEN    0         100                              192.168.100.6:143             0.0.0.0:*       users:(("dovecot",pid=3808,fd=38))
tcp      LISTEN    0         100                              192.168.100.6:465             0.0.0.0:*       users:(("master",pid=4066,fd=20))
tcp      LISTEN    0         128                                       [::]:22                 [::]:*       users:(("sshd",pid=732,fd=4))
```

Порти зайняті postfix -- 25, 587, 465 Порти зайняті dovecot -- 993, 995, 110, 143

Ви можете використати команду `doveadm`, щоб створити відповідний зашифрований пароль і вставити його в таблицю virtual_users.

<a id="ap1"></a>

```bash
Shell(192.168.100.6) > doveadm pw -s SHA512-crypt -p onetestandone
{SHA512-CRYPT}$6$dEqUVsCirHzV8kHw$hgC0x0ufah.N0PzUVvhLEMnoww5lo.JBmeLSsRNDkgWVylC55Gk6zA1KWsn.SiIAAIDEqHxtugGZWHl1qMex..

Shell(192.168.100.6) > doveadm pw -s SHA512-crypt -p twotestandtwo
{SHA512-CRYPT}$6$TF7w672arYUk.fGC$enDafylYnih4q140B2Bu4QfEvLCQAiQBHXpqDpHQPHruil4j4QbLXMvctWHdZ/MpuwvhmBGHTlNufVwc9hG34/
```

Вставте відповідні дані на хості 192.168.100.5.

```sql
Mysql > use mailserver;

Mysql > insert into virtual_users(id,email,password,domain_id) values(1,'frank@mail.rockylinux.me','$6$dEqUVsCirHzV8kHw$hgC0x0ufah.N0PzUVvhLEMnoww5lo.JBmeLSsRNDkgWVylC55Gk6zA1KWsn.SiIAAIDEqHxtugGZWHl1qMex..',1);

Mysql > insert into virtual_users(id,email,password,domain_id) values(2,'leeo@mail.rockylinux.me','$6$TF7w672arYUk.fGC$enDafylYnih4q140B2Bu4QfEvLCQAiQBHXpqDpHQPHruil4j4QbLXMvctWHdZ/MpuwvhmBGHTlNufVwc9hG34/',1);
```

### Тестування

#### Аутентифікація користувача

Скористайтеся іншим комп’ютером з Windows 10 і змініть бажаний DNS на 192.168.100.7. Як поштовий клієнт тут автор використовує foxmail.

На головному екрані виберіть «Інша поштова скринька» --> «Вручну» --> Введіть відповідний вміст для завершення. --> "Створити"

![test1](./email-images/test1.jpg)

![test2](./email-images/test2.jpg)

#### Надіслати електронний лист

Використовуйте цього користувача, щоб спробувати надіслати електронний лист користувачеві leeo.

![test3](./email-images/test3.jpg)

#### Отримати пошту

![test4](./email-images/test4.jpg)

### Додатковий опис

* Ви повинні мати законне доменне ім’я (домен)
* Вам слід подати заявку на сертифікат SSL/TLS для вашої системи електронної пошти
