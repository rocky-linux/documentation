---
title: FreeRADIUS RADIUS Server with MariaDB
author: Neel Chauhan
contributors:
tested_with: 10.1
tags:
  - security
---

## Introduction

RADIUS is an AAA (authentication, authorization, and accounting) protocol to manage network access. [FreeRADIUS](https://www.freeradius.org/) is the de facto RADIUS server for Linux and other Unix-like systems.

You can make FreeRADIUS work with MariaDB, say for 802.1X, Wi-Fi, or VPN authentication.

## Prerequisites and assumptions

The following are the minimum requirements for this procedure:

* The ability to run commands as the root user or use `sudo` to elevate privileges
* A MariaDB server
* A RADIUS client, such as a router, switch, or Wi-Fi access point

## Installing FreeRADIUS

You first need EPEL and CRB installed:

```bash
dnf install epel-release
crb enable
```

You can then install FreeRADIUS from the `dnf` repositories:

```bash
dnf install -y freeradius freeradius-mysql
```

## Installing MariaDB

You need to install MariaDB:

```bash
dnf install mariadb-server
```

## Configuring FreeRADIUS

With the packages installed, you need first to generate the TLS encryption certificates for FreeRADIUS:

```bash
cd /etc/raddb/certs
./bootstrap
```

Subsequently, you will need to enable `sql`. Edit the `/etc/raddb/sites-enabled/default` file and replace `-sql` with `sql`:

```bash
authorize {
   ...
   sql
   ...
}
...
accounting {
   ...
   sql
   ...
}
...
session {
   ...
   sql
   ...
}
...
post-auth {
    ...
    sql
    ...
    Post-Auth-Type REJECT {
        sql
    }
    ....

}
```

Do the same in `/etc/raddb/sites-enabled/inner-tunnel`:

```bash
authorize {
   ...
   sql
   ...
}
...
session {
   ...
   sql
   ...
}
...
post-auth {
    ...
    sql
    ...
    Post-Auth-Type REJECT {
        sql
    }
    ....

}
```

Change the `program` line in `/etc/raddb/mods-enabled/ntlm_auth` to this:

In the `/etc/raddb/mods-available/sql` file, change the `dialect` to `mysql`:

```bash
        dialect = "mysql"
```

Then change the `driver`:

```bash
        driver = "rlm_sql_${dialect}"
```

In the `mysql {` section, delete the `tls {` subsection.

Then, set the database name, username and password:

```bash
        server = "127.0.0.1"
        port = 3306
        login = "radius"
        password = "password"
        ...
        radius_db = "radius"
```

Replace the above fields with your respective server, username.


You will also need to define clients. This is to prevent unauthorized access to our RADIUS server. Edit the `clients.conf` file:

```bash
vi clients.conf
```

Insert the following:

```bash
client 172.20.0.254 {
        secret = secret123
}
```

Replace `172.20.0.254` and `secret123` with the IP address and secret value the clients will use. Repeat this for other clients.

## Inserting the MariaDB schema

First, enable MariaDB and run the setup.

```bash
systemctl enable --now mysql
mysql_secure_installation
```

Next log into MariaDB:

```bash
mysql -u root -p
```

Now create the RADIUS user and database:

```bash
create database radius;
create user 'radius'@'localhost' identified by 'password';
grant all privileges on radius.* to 'radius'@'localhost';
```

Replace the username, password and database name with the desired values.

Then insert the MariaDB schema:

```bash
mysql -u root -p radius < /etc/raddb/mods-config/sql/dhcp/mysql/schema.sql
```

Replace the database name with the one you selected.

## Creating users

First log into MariaDB:

```bash
mysql -u root -p radius
```

Then you can add users:

```bash
insert into radcheck (username,attribute,op,value) values("neha", "Cleartext-Password", ":=", "iloveicecream");
```

Replace `neha` and `iloveicecream` with the desired respective username and password.

You can also use third-party software to add users. For instance, WHMCS and multiple ISP billing systems allow this.

## Enabling FreeRADIUS

After the initial configuration, you can start `radiusd`:

```bash
systemctl enable --now radiusd
```

## Configuring RADIUS on a switch

After setting up the FreeRADIUS server, you will configure a RADIUS client.

As an example, the author's MikroTik switch can be configured like:

```bash
/radius
add address=172.20.0.12 secret=secret123 service=dot1x
/interface dot1x server
add interface=combo3
```

Replace `172.20.0.12` with the FreeRADIUS server's IP address and `secret123` with the secret you set earlier.
