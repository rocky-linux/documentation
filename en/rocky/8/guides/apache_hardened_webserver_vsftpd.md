# Apache Hardened Web Server - vsftpd

# Introduction 

_vsftpd_ is the  Very Secure FTP Daemon. (FTP is file transfer protocol) It has been available for many years now and is actually the default ftp daemon in Rocky Linux as well as many other Linux distributions. _vsftpd_ allows for the use of virtual users with pluggable authentication modules (PAM). These virtual users don't exist in the system and have no other permissions except to ftp. This means that assuming a compromised virtual user, the person with those credentials would have no other permissions once they gained access. Using this setup is very secure indeed, but does require a bit of extra work. _vsftpd_ is just one possible component of a hardened Apache web server setup and can be used with or without other tools. If you'd like to use this along with other tools for hardening, refer back to the [Apache Hardened Web Server routine](apache_hardened_webserver.md). This document also uses all of the assumptions and conventions outlined in that original document, so it is a good idea to review it before continuing.

# Prerequisites

* A Rocky Linux Web Server running Apache
* Proficiency with a command-line editor (we are using _vi_ in this example)
* A heavy comfort level with issuing commands from the command-line, viewing logs, and other general systems administrator duties
* An understanding of PAM, as well as _openssl_ commands is helpful.
* All commands are run as the root user or sudo

## Installing vsftpd

We also need to make sure openssl is installed. If you are running a web server, this probably **is** already installed, but just make sure:

`dnf install vsftpd openssl`

You will also want to enable the service:

`systemctl enable vsftpd` 

but don't start the service just yet.

## vConfiguring vsftpd

We want to make sure that some settings are disabled and that others are enabled. Generally, when you install _vsftpd_ the most sane options are set these days, but it is a good idea to make sure.

To check the configuration file and make changes as necessary:

`vi /etc/vsftpd/vsftpd.conf`

Look for the line "anonymous_enable=" and make sure that it is set to "NO" and that it is **NOT** remarked out. (remarking out this line will enable anonymous logins).  The line should look like this when it is correct:

`anonymous_enable=NO`

Make sure that local_enable is set to yes:

`local_enable=YES`

Add a line for the local root. We are assuming that you are using the configuration directory setup as specified in the [Apache Web Server Multi-Site Setup](apache-sites-enabled.md). If your setup is different, adjust the local_root setting:

`local_root=/var/www/sub-domains`

Make sure that write_enable is set to yes as well:

`write_enable=YES`

Find the line to "chroot_local_users" and remove the remark and then add two lines below so that it looks like this:

```
chroot_local_user=YES
allow_writeable_chroot=YES
hide_ids=YES
```
Beneath this, we want to add an entirely new section that will deal with virtual users:

```
# Virtual User Settings
user_config_dir=/etc/vsftpd/vsftpd_user_conf
guest_enable=YES
virtual_use_local_privs=YES
pam_service_name=vsftpd
nopriv_user=vsftpd
guest_username=vsftpd
```

We need to add a section near the bottom of the file to force passwords sent over the internet to be encrypted. We need _openssl_ installed and we will need to create the certificate file for this as well. Start by adding these lines at the bottom of the file:

```
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
Now save your configuration. (`SHIFT:wq` if using _vi_)

## Setting Up The RSA Certificate

We need to create the _vsftpd_ rsa certificate file. The author generally figure that a server is good for 4 or 5 years, so set the number of days for this certificate based on the number of years you believe you'll have the server up and running on this hardware. Edit the number of days as you see fit, and then use the below format of the command to create the certificate and private key files:

`openssl req -x509 -nodes -days 1825 -newkey rsa:2048 -keyout /etc/vsftpd/vsftpd.key -out /etc/vsftpd/vsftpd.pem`

Like all certificate creation processes, this will start a script that will ask you for some information. This is not a difficult process. Many fields can be left blank. The first field is the country code field, fill this one in with your country two letter code:

`Country Name (2 letter code) [XX]:`

Next comes the state or province, fill this in by typing the whole name, not the abbreviation: 

`State or Province Name (full name) []:`

Next is the locality name. This is your city:

`Locality Name (eg, city) [Default City]:`

Next is the company or organizational name. You can leave this blank or fill it in as you see fit:

`Organization Name (eg, company) [Default Company Ltd]:`

Next is the organizational unit name. You can fill this in if the server is for a specific division, or leave it blank:

`Organizational Unit Name (eg, section) []:`

The next field should be filled in, however you can decide how you want to fill it in. This is the common name of your server. You might want to differentiate this from the web server name by perhaps calling it "webftp", example: `webftp.domainname.ext`:

`Common Name (eg, your name or your server's hostname) []:`

Finally, there is the email field, which you can certainly leave blank without issue:

`Email Address []:`

Once you have completed the form, the certificate will be created.


## <a name="virtualusers"></a>Setting Up Virtual Users

As stated earlier, using virtual users for _vsftpd_ is much more secure, because they have no system privileges at all. That said, we need to add a user for the virtual users to use. We also need to add a group:

`groupadd nogroup`

and then:

`useradd --home-dir /home/vsftpd --gid nogroup -m --shell /bin/false vsftpd`

The user must match the `guest_username=` line in the vsftpd.conf.

Now change to the configuration directory for _vsftpd_:

`cd /etc/vsftpd`

We need to create a new password database that will be used to authenticate our virtual users. We need to create a file to read the virtual users and passwords from that will create the database. In the future, when adding new users, we will want to duplicate this process as well:

`vi vusers.txt`

The user and password are line separated, so simply type the user, hit enter, and then type the password. Continue until you have added all of the users you currently want to have access to the system. Example:

```
user_name_a
user_password_a
user_name_b
user_password_b
```
Once the text file is created, we now want to generate the password database that _vsftpd_ will use for the virtual users. This is done with _db\_load_. _db\_load_ is provided by _libdb-utils_ which should be loaded on your system, but if it is not, you can simply install it with:

`dnf install libdb-utils`

Create the database from the text file with:

`db_load -T -t hash -f vusers.txt vsftpd-virtual-user.db`

We need to take just a moment here to reference what _db\_load_ is doing here:

* the -T is used to easily allow the import of a text file into the database
* the -t says to specify the underlying access method
* the _hash_ is the underlying access method we are specifying
* the -f says to read from a specified file
* the specified file is _vusers.txt_ 
* and the database we are creating or adding to is _vsftpd-virtual-user.db_

Change the default permissions of the database file:

`chmod 600 vsftpd-virtual-user.db`

And remove the vusers.txt file:

`rm vusers.txt`

When adding new users, simply _vi_ a new vusers.txt file and re-run the _db\_load_ command, which will add the new user to the database.

## Setting Up PAM

_vsftpd_ installs a default pam file when you install the package. We are going to replace this with our own content, so **always** make a backup copy of the old file first. Make a directory for your backup file in /root:

`mkdir /root/backup_vsftpd_pam`

Then copy the pam file to this directory:

`cp /etc/pam.d/vsftpd /root/backup_vsftpd_pam/`

Now edit the original file:

`vi /etc/pam.d/vsftpd`

Remove everything in this file except the "#%PAM-1.0" and then add in the following two lines:

```
auth       required     pam_userdb.so db=/etc/vsftpd/vsftpd-virtual-user
account    required     pam_userdb.so db=/etc/vsftpd/vsftpd-virtual-user
session    required     pam_loginuid.so
```
Save your changes and exit (`SHIFT:wq` in _vi_).

This will enable login for your virtual users defined in `vsftpd-virtual-user.db` and will disable local logins.

## Setting Up The Virtual User's Configuration

Each virtual user has their own configuration file. It specifies their own local_root. This local root must be owned by the user "vsftpd" and the group "nogroup". Remember that this was setup in the [Setting Up Virtual Users section above.](#virtualusers) To change the ownership for the directory, simply change the ownership of the directory:

`chown vsftpd.nogroup /var/www/sub-domains/whatever_the_domain_name_is/html`

We need to create the file that contains the virtual user's configuration:

`vi /etc/vsftpd/vsftpd_user_conf/username`

This will have a single line in it that specifies the virtual user's local_root:

`local_root=local_root=/var/www/sub-domains/com.testdomain/html`

This file path is specified in the "Virtual User" section of the vsftpd.conf file.

## Starting vsftpd

Once all of this is completed, start the _vsftpd_ service and then test your users, assuming that the service starts correctly:

`systemctl restart vsftpd`

### Testing vsftpd

You can test your setup using the command line on a machine and test access to the machine using ftp. That said, the easiest way to test is to test with an FTP client, such as [FileZilla](https://filezilla-project.org/). When you test with a virtual user to the server running _vsftpd_, you should get an SSL certificate trust message. This trust message is saying to the person using the FTP client that the server uses a certificate ans asks them to approve the certificate before continuing. Once connected as a virtual user, you should be able to place files in the "local_root" that we setup for that user. If you are unable to upload a file, then you may need to go back and make sure that each of the above steps is completed. For instance, it could be that the ownership permissions for the "local_root" have not been set to the "vsftpd" user and the "nogroup" group.

# Conclusions

_vsftpd_ is just another tool in a hardened web server setup. If set up to use virtual users and a certificate, it is quite secure. While there are a number of steps to setting up _vsftpd_ as outlined in this document, taking the extra time to set it up correctly will ensure that your server is as secure as it can be.
