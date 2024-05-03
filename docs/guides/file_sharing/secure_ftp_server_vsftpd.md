---
title: Secure FTP Server - vsftpd
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 8.5, 8.6, 9.0
tags:
  - security
  - ftp
  - vsftpd
---

# Secure FTP server - `vsftpd`

## Prerequisites

- Proficiency with a command-line editor (using `vi` in this example)
- A heavy comfort level with issuing commands from the command-line, viewing logs, and other general systems administrator duties
- An understanding of PAM, and `openssl` commands are helpful
- Running commands here with the root user or a regular user and `sudo`

## Introduction

`vsftpd` is the  Very Secure FTP Daemon (FTP being the file transfer protocol). It has been available for many years, and is the default FTP daemon in Rocky Linux and many other Linux distributions.

`vsftpd` allows for the use of virtual users with pluggable authentication modules (PAM). These virtual users do not exist in the system and have no other permissions except FTP. If a virtual user gets compromised, the person with those credentials will have no other permissions after gaining access as that user. This setup is very secure but requires a bit of extra work.

!!! tip "Consider `sftp`"

    Even with the security settings used here to set up `vsftpd`, you may want to consider `sftp` instead. `sftp` will encrypt the entire connection stream and is more secure. We have created a document called [Secure Server - `sftp`](sftp.md) that deals with setting up `sftp` and the locking down SSH. 

## Installing `vsftpd`

You must also ensure the `openssl` installation. If you are running a web server, this probably **is** already installed, but just to verify you can run:

```bash
dnf install vsftpd openssl
```

You will also want to enable the vsftpd service:

```bash
systemctl enable vsftpd
```

Do not start the service just yet.

## Configuring `vsftpd`

You want to ensure the disabling of some settings and enabling others. Generally, installing `vsftpd` includes the most sane options already set. It is still a good idea to verify them.

To check the configuration file and make changes when necessary, run:

```bash
vi /etc/vsftpd/vsftpd.conf
```

Look for the line "anonymous_enable=" and ensure that it is "NO" and that it is **NOT** commented out. (Commenting out this line will enable anonymous logins).  The line will look like this when it is correct:

```bash
anonymous_enable=NO
```

Ensure that "local_enable" is yes:

```bash
local_enable=YES
```

Add a line for the local root user. If the server is a web server, and you use the [Apache Web Server Multi-Site Setup](../web/apache-sites-enabled.md), your local root will reflect that. If your setup is different, or if this is not a web server, adjust the "local_root" setting:

```bash
local_root=/var/www/sub-domains
```

Ensure that "write_enable" is yes also:

```bash
write_enable=YES
```

Find the line to "chroot_local_users" and remove the remark. Add two lines after that shown here:

```bash
chroot_local_user=YES
allow_writeable_chroot=YES
hide_ids=YES
```

Beneath this you want to add a section that will deal with virtual users:

```bash
# Virtual User Settings
user_config_dir=/etc/vsftpd/vsftpd_user_conf
guest_enable=YES
virtual_use_local_privs=YES
pam_service_name=vsftpd
nopriv_user=vsftpd
guest_username=vsftpd
```

You need to add a section near the bottom of the file to force encryption of passwords sent over the internet. You need `openssl` installed and you must also create the certificate for this.

Start by adding these lines at the bottom of the file:

```bash
rsa_cert_file=/etc/vsftpd/vsftpd.pem
rsa_private_key_file=/etc/vsftpd/vsftpd.key
ssl_enable=YES
allow_anon_ssl=NO
force_local_data_ssl=YES
force_local_logins_ssl=YES
ssl_tlsv1=YES
ssl_sslv2=NO
ssl_sslv3=NO

pasv_min_port=7000
pasv_max_port=7500
```

Save your configuration. (++shift+colon+w+q++ for `vi`.)

## Setting up the RSA certificate

You need to create the `vsftpd` RSA certificate file. The author generally figures that a server is good for 4 or 5 years. Set the number of days for this certificate based on the number of years you believe you will have the server up and running on this hardware.

Edit the number of days as you see fit, and use the format of this command to create the certificate and private key files:

```bash
openssl req -x509 -nodes -days 1825 -newkey rsa:2048 -keyout /etc/vsftpd/vsftpd.key -out /etc/vsftpd/vsftpd.pem
```

Like all certificate creation processes, this will start a script that will ask you for some information. This is not a difficult process. You will leave many fields blank.

The first field is the country code field, fill this one in with your country two letter code:

```text
Country Name (2 letter code) [XX]:
```

Next comes the state or province, fill this in by typing the whole name, not the abbreviation:

```text
State or Province Name (full name) []:
```

Next is the locality name. This is your city:

```text
Locality Name (eg, city) [Default City]:
```

Next is the company or organizational name. You can leave this blank or fill it in. It is optional:

```text
Organization Name (eg, company) [Default Company Ltd]:
```

Next is the organizational unit name. You can fill this in if the server is for a specific division, or leave it blank:

```text
Organizational Unit Name (eg, section) []:
```

The following field needs filling in, but you can decide how you want it. This is the common name of your server. Example: `webftp.domainname.ext`:

```text
Common Name (eg, your name or your server's hostname) []:
```

The email field can be left blank:

```text
Email Address []:
```

When completed, the certificate creation will occur.

## Setting up virtual users

As stated earlier, using virtual users for `vsftpd` is much more secure because they have no system privileges. That said, you need to add a user for the virtual users. You also need to add a group:

```bash
groupadd nogroup
useradd --home-dir /home/vsftpd --gid nogroup -m --shell /bin/false vsftpd
```

The user must match the `guest_username=` line in the `vsftpd.conf` file.

Go to the configuration directory for `vsftpd`:

```bash
cd /etc/vsftpd
```

You need to create a password database. You use this database to authenticate our virtual users. You need to create a file to read the virtual users and passwords. This will create the database.

In the future, when adding users, you will want to duplicate this process again:

```bash
vi vusers.txt
```

The user and password are line separated, enter the user, hit ++enter++, and enter the password. Continue until you have added all of the users you currently want to have access to the system. Example:

```bash
user_name_a
user_password_a
user_name_b
user_password_b
```

When done creating the text file, you want to generate the password database that `vsftpd` will use for the virtual users. Do this with the command `db_load`. `db_load` is provided by `libdb-utils` which should be loaded on your system, but if it is not, you can simply install it with:

```bash
dnf install libdb-utils
```

Create the database from the text file with:

```bash
db_load -T -t hash -f vusers.txt vsftpd-virtual-user.db
```

 Take just a moment here to review what `db_load` is doing:

- The -T allows the import of a text file into the database
- The -t says to specify the underlying access method
- The *hash* is the underlying access method you are specifying
- The -f says to read from a specified file
- The specified file is *vusers.txt*
- And the database you are creating or adding to is *vsftpd-virtual-user.db*

Change the default permissions of the database file:

```bash
chmod 600 vsftpd-virtual-user.db
```

Remove the "vusers.txt" file:

```bash
rm vusers.txt
```

When adding users, use `vi` to create another "vusers.txt" file, and re-run the `db_load` command, which will add the users to the database.

## Setting up PAM

`vsftpd` installs a default pam file when you install the package. You are going to replace this with your own content.  **Always** make a backup copy of the old file first.

Make a directory for your backup file in /root:

```bash
mkdir /root/backup_vsftpd_pam
```

Copy the pam file to this directory:

```bash
cp /etc/pam.d/vsftpd /root/backup_vsftpd_pam/
```

Edit the original file:

```bash
vi /etc/pam.d/vsftpd
```

Remove everything in this file except the "#%PAM-1.0" and add in the following lines:

```bash
auth       required     pam_userdb.so db=/etc/vsftpd/vsftpd-virtual-user
account    required     pam_userdb.so db=/etc/vsftpd/vsftpd-virtual-user
session    required     pam_loginuid.so
```

Save your changes and exit (++shift+colon+w+q++ in `vi`).

This will enable login for your virtual users defined in `vsftpd-virtual-user.db`, and will disable local logins.

## Setting up the virtual user's configuration

Each virtual user has a configuration file, specifying their own "local_root" directory. Ownership of this local root is the user "vsftpd" and the group "nogroup".

Refer to [Setting Up Virtual Users section above.](#setting-up-virtual-users) To change the ownership for the directory, enter this at the command line:

```bash
chown vsftpd.nogroup /var/www/sub-domains/whatever_the_domain_name_is/html
```

You need to create the file that has the virtual user's configuration:

```bash
mkdir /etc/vsftpd/vsftpd_user_conf
vi /etc/vsftpd/vsftpd_user_conf/username
```

This will have a single line in it that specifies the virtual user's "local_root":

```bash
local_root=/var/www/sub-domains/com.testdomain/html
```

Specification of this path is in the "Virtual User" section of the `vsftpd.conf` file.

## Starting `vsftpd`

Start the `vsftpd` service and test your users, assuming that the service starts correctly:

```bash
systemctl restart vsftpd
```

### Testing `vsftpd`

You can test your setup with the command line on a machine and test access to the machine with FTP. That said, the easiest way to test is to test with an FTP client, such as [FileZilla](https://filezilla-project.org/).

When you test with a virtual user to the server running `vsftpd`, you will get an SSL/TLS certificate trust message. This trust message tells the person that the server uses a certificate and asks them to approve it before continuing. You can place files in the "local_root" folder when connected as a virtual user.

If you are unable to upload a file, you might need to go back and verify each of the steps again. For instance, it might be that the ownership permissions for the "local_root" are not set to the "vsftpd" user and the "nogroup" group.

## Conclusion

`vsftpd` is a popular and common FTP server and can be a stand-alone server, or part of an [Apache Hardened Web Server](../web/apache_hardened_webserver/index.md). It is pretty secure if set up to use virtual users and a certificate.

This procedure has many steps to for setting up `vsftpd`. Taking the extra time to set it up correctly will ensure that your server is as secure as it can be.
