---
title: Basic e-mail system
auther: tianci li
---

# Overview

The purpose of this document is to provide the reader with a detailed understanding of the various components of an email system, including installation, basic configuration, and association. Attention please! In a real production environment, we recommend that you use an open-source e-mail servers, which applies to most GNU/Linux system administrators.

All commands in this document are executed using **root(uid=0)**.

## List of basic information

| Role played   | OS     |  IP address      | version |
| :---:         |  :---: | :---:            | :---:   |
| Mysql  Dadabase  | RL 8.8 | 192.168.100.5/24 | 8.0.33        |
| E-mail system | RL 8.8 | 192.168.100.6/24 |  postfix: 3.5.8<br/>dovecot: 2.3.16       |
| `bind` DNS      | RL 8.8 | 192.168.100.7/24 | 9.11.36     |

!!! info

    In fact, without a database, `postfix` + `dovecot` can also be combined to form a working email system.

### Install and configure `bind`

```bash
Shell(192.168.100.7) > dnf -y install bind bind-utils
```

```bash
# Modify the main configuration file
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
# Modify the zone file
## In practice, you can replace rockylinux.me with your domain name, such as rockylinux.org
Shell(192.168.100.7) > vim /etc/named.rfc1912.zones
zone "rockylinux.me" IN {
        type master;
        file "rockylinux.localhost";
        allow-update { none; };
};
```

!!! question 

    **What is DNS zone?**<br/>A DNS zone is the specific portion of a DNS namespace that's hosted on a DNS server. A DNS zone contains resource records, and the DNS server responds to queries for records in that namespace. A DNS server can have multiple DNS zone.Simply put, a dns zone is the equivalent of a book catalog.

```bash
# Modify data file
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

Start your bind service - `systemctl start named.service`

We can test whether the hosts under the domain name can resolve properly.

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

!!! info

    one domain name cannot represent a specific host.

### Install and configure `Mysql`

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

!!! info 

    You don't have to use the same method as the author, it is also possible to install Mysql from a repository or docker.

#### Create tables and insert data

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
        password varchar(100) not null,
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
Mysql > insert into virtual_domains(id,name) values(1,'mail.rockyllinux.me'),(2,'rockylinyx.me');

# For convenience, I use a plaintext password here.
Mysql > insert into virtual_users(id,email,password,domain_id) values(1,'frank@mail.rockylinux.me','onetestandone',1);

Mysql > insert into virtual_users(id,email,password,domain_id) values(2,'leeo@mail.rockylinux.me','twotestandtwo',1);

Mysql > insert into virtual_aliases(id,domain_id,source,destination) values(1,1,'all@mail.rockylinux.me','frank@mail.rockylinux.me');

Mysql > insert into virtual_aliases(id,domain_id,source,destination) values(2,1,'all@mail.rockylinux.me','leeo@mail.rockylinux.me');
```

### Install and configure `postfix`

```bash
Shell(192.168.100.6) > dnf -y install postfix postfix-mysql
```

When you install postfix, the following files need to be know:

* **/etc/postfix/main.cf**. The main and most important configuration file
* **/etc/postfix/master.cf**. Used to set runtime parameters for each component. In general, no changes are required, except when performance optimization is required.
* **/etc/postfix/access**. Access control file for SMTP.
* **/etc/postfix/transport**. Maps email addresses to relay hosts.

These executable binaries need to know:

* /**usr/sbin/postalias**. Alias database generation instruction. After this command is executed, /etc/aliases.db is generated based on the /etc/aliases file
* **/usr/sbin/postcat**. This command is used to view the mail content in the mail queue.
* **/usr/sbin/postconf**. Querying Configuration Information.
* **/usr/sbin/postfix**. The main daemon commands. It can be used as follows:

  * `postfix check`
  * `postfix start`
  * `postfix stop`
  * `postfix reload`
  * `postfix status`

!!! tip

    If you have more than one MTA on your server, you can specify the default MTA using the `alternatives --config mta` command.

#### Explanation of the /etc/postfix/main.cf file

```bash
Shell(192.168.100.5) > egrep -v "^#|^$" /etc/postfix/main.cf
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

* **compatibility_level = 2**. A new mechanism introduced in postfix 3 is designed to be compatible with previous versions of postfix.
* **data_directory = /var/lib/postfix**. The directory where the cached data is stored.
* **<font color="red">myhostname = host.domain.tld</font>**. Important parameters that have been commented out. You need to change it to the hostname under your domain name.
* **<font color="red">mydomain = domain.tld</font>**. Important parameters that have been commented out. You need to change it to your domain name.
* **<font color="red">myorigin = \$myhostname</font>** and **<font color="red">myorigin = $mydomain</font>**. Important parameters that have been commented out. The main function is to complement the sender's mail suffix. **\$** represents a reference parameter variable.
* **<font color="red">inet_interfaces = localhost</font>**. When receiving mails, this parameter indicates the address to be listened. The value is usually modified to "all".
* **inet_protocols = all**. Enable IPv4, and IPv6 if supported
* **<font color="red">mydestination = \$myhostname, localhost.\$mydomain, localhost</font>**. Indicates that I can receive mail from where.
* **unknown_local_recipient_reject_code = 550**. The error code returned when sending to an account that does not exist local domain or rejecting an email.
* **mynetworks =**. Set which hosts' emails can be forwarded.
* **relay_domains = $mydestination**. Set which domains' emails can be forwarded.
* **alias_maps = hash:/etc/aliases**. It is used to define user aliases and requires database support.
* **alias_database = hash:/etc/aliases**. The database to be used by aliases.
* **<font color="red">home_mailbox = Maildir/</font>**. Important parameters that have been commented out. This indicates where the local mailbox is stored.
* **debug_peer_level = 2**. Level of log records.
* **setgid_group = postdrop**. The group identifier used to submit emails or manage queues.

Except for the parameter items mentioned or displayed above, some parameters are hidden and can be viewed through the `postconf` command. The most important parameters are:

* **message_size_limit = 10240000**. Set the size of a single email (including the body and attachments). The unit of value is B (Bytes).
* **mailbox_size_limit = 1073741824**. Set the capacity limit for a single mailbox user.
* **smtpd_sasl_type = cyrus**. The type of SASL (Simple Authentication and Security Layer) authentication. You can use `postconf -a` to view.
* **smtpd_sasl_auth_enable = no**. Whether to enable SASL authentication. 
* **smtpd_sasl_security_options = noanonymous**. Security options for SASL. Anonymous authentication is disabled by default.
* **smtpd_sasl_local_domain =**. The name of the local domain.
* **smtpd_recipient_restrictions =**. Filtering of recipients. The default value is empty.

#### Modify /etc/postfix/main.cf

```bash
Shell(192.168.100.6) > vim /etc/postfix/main.cf
...
compatibility_level = 2
myhostname = mail.rockylinux.me
mydomain = rockylinux.me
myorigin = $myhostname
myorigin = $mydomain
inet_interfaces = all
inet_protocols = ipv4
mydestination = $myhostname, localhost.$mydomain, localhost
biff = no
append_dot_mydomain = no
smtpd_sasl_type = dovecot
smtpd_sasl_path = private/auth
smtpd_sasl_auth_enable = yes
virtual_transport = lmtp:unix:private/dovecot-lmtp
virtual_mailbox_domains = mysql:/etc/postfix/mysql-virtual-mailbox-domains.cf
virtual_mailbox_maps = mysql:/etc/postfix/mysql-virtual-mailbox-maps.cf
virtual_alias_maps = mysql:/etc/postfix/mysql-virtual-alias-maps.cf,mysql:/etc/postfix/mysql-virtual-email2email.cf
...
```

The final file content looks like this:

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
inet_interfaces = all
inet_protocols = ipv4
mydestination = $myhostname, localhost.$mydomain, localhost
biff = no
append_dot_mydomain = no
smtpd_sasl_type = dovecot
smtpd_sasl_path = private/auth
smtpd_sasl_auth_enable = yes
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
virtual_transport = lmtp:unix:private/dovecot-lmtp
virtual_mailbox_domains = mysql:/etc/postfix/mysql-virtual-mailbox-domains.cf
virtual_mailbox_maps = mysql:/etc/postfix/mysql-virtual-mailbox-maps.cf
virtual_alias_maps = mysql:/etc/postfix/mysql-virtual-alias-maps.cf,mysql:/etc/postfix/mysql-virtual-email2email.cf
```

Create a file and write the relevant content:

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

!!! info

    For the sake of demonstration, we have not enabled the relevant SSL parameters here.

!!! warning 

    If you encounter this kind of error after running `systemctl start postfix.service` -- "fatal: open lock file /var/lib/postfix/master.lock: unable to set exclusive lock: Resource temporarily unavailable." Please delete the existing **/var/lib/postfix/master.lock** file

Testing Postfix configure:

```bash
Shell(192.168.100.6) > systemctl start postfix.service
Shell(192.168.100.6) > postfix check
Shell(192.168.100.6) > postfix status

Shell(192.168.100.6) > postmap -q mail.rockylinux.me mysql:/etc/postfix/mysql-virtual-mailbox-domains.cf
Shell(192.168.100.6) > echo $?
1

Shell(192.168.100.6) > postmap -q frank@mail.rockylinux.me mysql:/etc/postfix/mysql-virtual-mailbox-maps.cf
Shell(192.168.100.6) > echo $?
1

Shell(192.168.100.6) > postmap -q all@mail.rockylinux.me mysql:/etc/postfix/mysql-virtual-alias-maps.cf
frank@mail.rockylinux.me,leeo@mail.rockylinux.me
```

#### Modify /etc/postfix/master.cf

The modified file looks like this(I just cancelled the comments at the beginning of `submitsion` and `smtps`):

```bash
Shell(192.168.100.6) > egrep -v "^#|^$" /etc/postfix/master.cf
smtp      inet  n       -       n       -       -       smtpd
submission inet n       -       n       -       -       smtpd
smtps     inet  n       -       n       -       -       smtpd
pickup    unix  n       -       n       60      1       pickup
cleanup   unix  n       -       n       -       0       cleanup
qmgr      unix  n       -       n       300     1       qmgr
tlsmgr    unix  -       -       n       1000?   1       tlsmgr
rewrite   unix  -       -       n       -       -       trivial-rewrite
bounce    unix  -       -       n       -       0       bounce
defer     unix  -       -       n       -       0       bounce
trace     unix  -       -       n       -       0       bounce
verify    unix  -       -       n       -       1       verify
flush     unix  n       -       n       1000?   0       flush
proxymap  unix  -       -       n       -       -       proxymap
proxywrite unix -       -       n       -       1       proxymap
smtp      unix  -       -       n       -       -       smtp
relay     unix  -       -       n       -       -       smtp
        -o syslog_name=postfix/$service_name
showq     unix  n       -       n       -       -       showq
error     unix  -       -       n       -       -       error
retry     unix  -       -       n       -       -       error
discard   unix  -       -       n       -       -       discard
local     unix  -       n       n       -       -       local
virtual   unix  -       n       n       -       -       virtual
lmtp      unix  -       -       n       -       -       lmtp
anvil     unix  -       -       n       -       1       anvil
scache    unix  -       -       n       -       1       scache
postlog   unix-dgram n  -       n       -       1       postlogd
```

Finally execute the `systemctl restart postfix.service` command. At this point, the configuration of postfix is over.

### Install and configure `dovecot`

```bash
Shell(192.168.100.6) > dnf config-manager --enable devel && dnf -y install dovecot dovecot-devel
```

As with postfix, to view the complete configuration information, enter the `doveconf` command

Without changing any files, the original directory structure is as follows:

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

Yes, both postfix and dovecot have very complex configurations, which is why it is recommended that the vast majority of GNU/Linux system administrators use open-source email servers.

