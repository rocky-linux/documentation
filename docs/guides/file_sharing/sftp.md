---
title: Secure Server - sftp
author: Steven Spencer
contributors:
tested with: 8.5
tags:
  - security
  - file transfer
  - sftp
  - web
  - multisite
---
# Secure Server - SFTP with SSH Lock Down Procedures

## Introduction

It may seem strange to have a document dedicated to the "secure" use of SFTP (a part of openssh-server package) when SSH is itself secure. I hear what you are thinking. But most system administrators do not want to open up SSH to everyone in order to implement SFTP for everyone.  This document will describe how to implement a change root jail for SFTP while keeping SSH access limited. There are many documents out there that deal with creating an SFTP change root jail, but most do not take into account a use case where the user that is set up would be accessing a web directory on a server with multiple websites. This document deals with that. If that isn't your use case, you can easily adapt these concepts to use in different situations.

The author also doesn't feel like making the change root jail document for SFTP without also discussing the other things that you should do as a system administrator to minimize the SSH target that you offer to the world is a good idea. For this reason, this document is divided into four parts. The first deals with the general information that we will use for the entire document. The second deals with the setup of the change root jail, and if you decide that you want to stop with that, that's totally up to you. The third part deals with setting up public/private key SSH access for your system administrators and turning off remote password based authentication. The fourth, and last section of this document deals with turning off remote root logins.

Taking all of these steps will allow you to offer secure SFTP access for your customers while also minimizing the possibility that port 22 (SSH) will be compromised by a bad actor.

## Part 1: General Information

### Assumptions and Conventions

We assume:

* you are comfortable executing commands at the command line
* you can use a command line editor, such as `vi` (used here), `nano`, `micro`, etc.
* you understand basic Linux commands used for adding groups and users, or can follow along well
* your multisite website is set up like this: [Apache Multisite](../web/apache-sites-enabled/)
* that `httpd` has already been installed on the server

!!! note

    You can apply these concepts to any server set up, and to any web daemon. While we are assuming Apache here, you can definitely use this for Nginx as well.

### Sites, Users, Administrators

Everything is made up here. Any resemblance to persons or sites that are real, is purely accidental:

**Sites:**

    * mybrokenaxel.com
        user = mybroken
    * myfixedaxel.com
        user = myfixed

**Administrators**

    * Steve Simpson = ssimpson
    * Laura Blakely = lblakely

## Part 2: SFTP Change Root Jail

### Installation

Installation is simple. You just need to have openssh-server installed, which is probably installed already. Enter this command to be sure:

```
dnf install openssh-server
```

### Setup

#### Directories

* The directory path structure will be `/var/www/sub-domains/[ext.domainname]/html` and the `html` directory in this path will be the change root jail for the SFTP user.

Creating the configuration directories:

```
mkdir -p /etc/httpd/sites-available
mkdir -p /etc/httpd/sites-enabled
```

Creating the web directories:

```
mkdir -p /var/www/sub-domains/com.mybrokenaxel/html
mkdir -p /var/www/sub-domains/com.myfixedaxel/html
```
We will deal with the ownership of these directories in the script application found below.

### `httpd` Configuration

We need to modify the built-in `httpd.conf` file to make it load the configuration files in the `/etc/httpd/sites-enabled` directory. This is done with one line at the bottom of the `httpd.conf` file.

Edit the file with your favorite editor. I'm using `vi` here:

```
vi /etc/httpd/conf/httpd.conf
```
and add this at the very bottom of the file:

```
Include /etc/httpd/sites-enabled
```
Then save the file and exit.

### Website Configuration

!!! hint "About the Following"

    While we are setting up the web environment here, we aren't going to enable or start `httpd`. We know that this setup works. If you want to complete the process, all that you would need to do is populate your domain `../html` directories with an index.html file (using `sftp`) and then enable and start `httpd`. The enabling of `httpd` is discussed in the previously referenced  [Apache Multisite](../web/apache-sites-enabled/) document. Once you have completed all of the setup in this document, feel free to continue on to enabling, starting, and testing the web service.

We need two sites created. We will create the configurations in `/etc/httpd/sites-available` and then link them to `../sites-enabled`:

```
vi /etc/httpd/sites-available/com.mybrokenaxel
```

!!! note

    We are only using the HTTP protocol for our example. Any real website would need an HTTPS protocol configuration, SSL certificates, and possibly more.

```
<VirtualHost *:80>
        ServerName www.mybrokenaxel.com
        ServerAdmin username@rockylinux.org
        DocumentRoot /var/www/sub-domains/com.mybrokenaxel.www/html
        DirectoryIndex index.php index.htm index.html
        Alias /icons/ /var/www/icons/


    CustomLog "/var/log/httpd/com.mybrokenaxel.www-access_log" combined
    ErrorLog  "/var/log/httpd/com.mybrokenaxel.www-error_log"

        <Directory /var/www/sub-domains/com.mybrokenaxel.www/html>
                Options -ExecCGI -Indexes
                AllowOverride None

                Order deny,allow
                Deny from all
                Allow from all

                Satisfy all
        </Directory>
</VirtualHost>
```
Save this file and exit.

```
vi /etc/httpd/sites-available/com.myfixedaxel
```

```
<VirtualHost *:80>
        ServerName www.myfixedaxel.com
        ServerAdmin username@rockylinux.org
        DocumentRoot /var/www/sub-domains/com.myfixedaxel.www/html
        DirectoryIndex index.php index.htm index.html
        Alias /icons/ /var/www/icons/


    CustomLog "/var/log/httpd/com.myfixedaxel.www-access_log" combined
    ErrorLog  "/var/log/httpd/com.myfixedaxel.www-error_log"

        <Directory /var/www/sub-domains/com.myfixedaxel.www/html>
                Options -ExecCGI -Indexes
                AllowOverride None

                Order deny,allow
                Deny from all
                Allow from all

                Satisfy all
        </Directory>
</VirtualHost>
```
Save this file and exit.

Once the two configuration files are created, go ahead and link them from within `/etc/httpd/sites-enabled`:

```
ln -s ../sites-available/com.mybrokenaxel
ln -s ../sites-available/com.myfixedaxel
```

### User Creation

For our example environment, we are assuming that none of the users are set up. Let's start with our administrative users. Note that at this point in our process, we can still log in as the root user to add the other users and set them up the way we want. We will remove root logins once we have the users set up and tested.

#### Administrators

```
useradd -g wheel ssimpson
useradd -g wheel lblakely
```
By adding our users to the group "wheel" we give them `sudo` access.

You still need a password for `sudo` access. There are ways around this, but none are all that secure. Frankly, if you have problems with security using `sudo` on your server, then you've got much bigger problems with your entire setup. Set the two administrative passwords with secure passwords:

```
passwd ssimpson
Changing password for user ssimpson.
New password:
Retype new password:
passwd: all authentication tokens updated successfully.

passwd lblakely
Changing password for user lblakely.
New password:
Retype new password:
passwd: all authentication tokens updated successfully.
```

Now test access to the server via ssh for your two administrative users. You should be able to:

* `ssh` as one of the administrative users to the server. (Example: `ssh lblakely@192.168.1.116` or `ssh lblakely@mywebserver.com`)
* once the server is accessed, you should be able to access root with `sudo -s` and entering the administrative user's password

If this works for both administrative users, you should be ready to go to the next step.

#### Web Users (SFTP)

We need to add our web users. That `../html` directory structure already exists, so we don't want to create it when we add the user, but we *do* want to specify it. We also do not want any login other than via SFTP so we need to use a shell that denies logins.

```
useradd -M -d /var/www/sub-domains/com.mybrokenaxel/html -g apache -s /usr/sbin/nologin mybroken
useradd -M -d /var/www/sub-domains/com.myfixedaxel/html -g apache -s /usr/sbin/nologin myfixed
```

Let's break down that command a bit. The `-M` option says don't create the home directory, `-d` specifies that what comes after is the actual home directory, `-g` says that the group that this user belongs to is `apache`, and `-s` says that the shell the user is assigned is `/usr/sbin/nologin` which is followed by the actual user we are adding. For an Nginx server, you would use `nginx` as the group.

Our SFTP users still need a password. So let's go ahead and setup a secure password for each now. Since we have already seen the command output above, we won't be repeating it here:

```
passwd mybroken
passwd myfixed
```

### SSH Configuration

!!! caution

    Before we start this next process, it is highly recommended that you make a backup of the system file we are going to be modifying: `/etc/ssh/sshd_config`. Breaking this file and not being able to go back to the original could cause you a world of heartache!

    ```
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
    ```

We need to make one change to the `/etc/ssh/sshd_config` file and then we are going to build a template so that we can make our web directory changes outside of the configuration file and script the additions we are going to need.

First, let's make the manual change we need:

```
vi /etc/ssh/sshd_config
```

Near the bottom of the file, you will find this:

```
# override default of no subsystems
Subsystem     sftp    /usr/libexec/openssh/sftp-server
```

We want to change that to read as follows:

```
# override default of no subsystems
# Subsystem     sftp    /usr/libexec/openssh/sftp-server
Subsystem       sftp    internal-sftp
```
Save and exit the file.

Just like before, let's describe what we are doing a little here. Both the `sftp-server` and `internal-sftp` are part of OpenSSH. The `internal-sftp`, while not too different from the `sftp-server`, simplifies configurations using `ChrootDirectory` to force a different file system root on clients. So that is why we want to use `internal-sftp`.

### The Template And The Script

Why are we creating a template and a script for this next part? The reason is simply to avoid human error as much as possible. We aren't done modifying that `/etc/ssh/sshd_config` file yet, but we want to eliminate as many errors as possible whenever we need to make these modifications. We will create all of this in `/usr/local/sbin`.

First, let's create our template:

```
vi /usr/local/sbin/sshd_template
```

This template should have the following:

```
Match User replaceuser
  ChrootDirectory replacedirectory
  ForceCommand internal-sftp
  AllowTcpForwarding no
  X11Forwarding no
```
We want a directory for our user files that we will create from the template too:

```
mkdir /usr/local/sbin/templates
```
Now let's create our script:

```
vi /usr/local/sbin/webuser
```

```
#!/bin/bash
# script to populate the SSHD configuration for web users.

# Set variables

tempfile="/usr/local/sbin/sshd_template"
dompath="/var/www/sub-domains/"

# Prompt for user and domain in reverse (ext.domainname):

clear

echo -n "Enter the web sftp user: "
read sftpuser
echo -n "Enter the domain in reverse. Example: com.domainname: "
read dom
echo -n "Is all of this correct: sftpuser = $sftpuser and domain = $dom (Y/N)? "
read yn
if [ "$yn" = "n" ] || [ "$yn" = "N" ]
then
	exit
fi
if [ "$yn" = "y" ] || [ "$yn" = "Y" ]
then
	/usr/bin/cat $tempfile > /usr/local/sbin/templates/$dom.txt
	/usr/bin/sed -i "s,replaceuser,$sftpuser,g" /usr/local/sbin/templates/$dom.txt
	/usr/bin/sed -i "s,replacedirectory,$dompath$dom,g" /usr/local/sbin/templates/$dom.txt
    /usr/bin/chown -R $sftpuser.apache $dompath$dom/html
fi

## Make a backup of /etc/ssh/sshd_config

/usr/bin/rm -f /etc/ssh/sshd_config.bak

/usr/bin/cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

## Now append our new user information to to the file

cat /usr/local/sbin/templates/$dom.txt >> /etc/ssh/sshd_config

## Restart sshd

/usr/bin/systemctl restart sshd

echo " "
echo "Please check the status of sshd with systemctl status sshd."
echo "You can verify that your information was added to the sshd_config by doing a more of the sshd_config"
echo "A backup of the working sshd_conf was created when this script was run: sshd_config.bak"
```

A couple of things to know about the script and about an SFTP change root in general. First, we are prompting for the needed information and then echoing it back to the user so they can verify it. If we answer "N" to the confirmation question, the script bails and does nothing. The script makes a backup of `sshd_config` the way it was prior to our running of the script. In this way, if we screw something up with an entry, we can simply restore `/etc/ssh/sshd_config.bak` to `sshd_config` and restart `sshd` to get things working again.

The SFTP change root requires that the path given in the `sshd_config` is owned by root. For this reason we do not need the `html` directory added to the end of the path. Once the user is authenticated, the change root will switch the user's home directory, in this case the `../html`, directory to whichever domain we are entering. Our script has appropriately changed the owner of the `../html` directory to the sftpuser and the apache group.

### Testing SSH Denial and SFTP Access

First, test using `ssh` from another machine to our host machine as one of the SFTP users. You should receive this after entering a password:

```
This service allows sftp connections only.
```
#### Graphical Tool Testing

If you *do* receive that message, then the next thing is to test SFTP access. If you would like to do things the easy way, you can use a graphical FTP application that supports SFTP such as Filezilla. In such cases, your fields would look something like this:

* Host: sftp://hostname_or_IP_of_the_server
* Username: (Example: myfixed)
* Password: (the password of the SFTP user)
* Port: (You shouldn't need to enter one, provided you are using SSH and SFTP on the default port 22)

Once filled in, you can click the "Quickconnect" (Filezilla) button and you should be connected to the `../html` directory of the appropriate site. Then double-click on the "html" directory to put yourself inside it, and try to drop a file into the directory. If you are successful, then you are good.

#### Command Line Tool Testing

You can obviously do all of this from the command line on a machine that has SSH installed. (most Linux installations). Here's a very brief overview of the command line method for connection and a few options:

* sftp username (Example: myfixed)@ hostname or IP of the server: sftp myfixed@192.168.1.116
* Enter the password when prompted
* cd html (change to the html directory)
* pwd (should show that you are in the html directory)
* lpwd (should show your local working directory)
* lcd PATH (should change your local working directory to something you want to use)
* put filename (will copy a file to `..html` directory)

For an exhaustive list of options and more, take a look at the [SFTP manual page](https://man7.org/linux/man-pages/man1/sftp.1.html).

## Part 3: Administrative Access with SSH key pairs

Please note that we will be using concepts discussed in the document [SSH Public and Private Keys](../security/ssh_public_private_keys) in this section, but also improving on it. If you are new to the process, feel free to read that article first before continuing.

### Creating the public/private Key Pairs

From one of the administrative user's workstations command line, (Example: lblakely) do the following:

```
ssh-keygen -t rsa
```

Which will give you this:

```
Generating public/private rsa key pair.
Enter file in which to save the key (/home/lblakely/.ssh/id_rsa):
```

Hit enter to create the private key in the location shown. This will give you this dialog:

```
Enter passphrase (empty for no passphrase):
```

You will need to decide personally whether you need a passphrase for this step. The author always just hits enter here.

```
Enter same passphrase again:
```

Repeat whatever passphrase you entered earlier or hit enter for none.

At this point both the public and private keys have been created.

### Transferring The Public key to the SFTP Server

The next step is to export our key to the server. In reality, a system administrator responsible for managing multiple servers would transfer his public key to all of the servers he/she is responsible for.  

Once the key is created, the user can send the key to the server securely with `ssh-id-copy`:

```
ssh-id-copy lblakely@192.168.1.116
```

The server will prompt for the user's password one time, and then copy the key into authorized_keys. You'll get this message as well:

```
Number of key(s) added: 1

Now try logging into the machine, with:   "ssh 'lblakely@192.168.1.116'"
and check to make sure that only the key(s) you wanted were added.
```

If you are able to login with this account, repeat the process with the other administrator.

### Allowing ONLY key-based Logins

Assuming that all of the above has worked out as planned and our keys for our administrators are now in place on the SFTP server, let's turn off password authentication on the server. For safety sake, make sure that you have two connections to the server so that you can reverse any changes if you have unintended consequences.

To accomplish this step, we need to modify the `sshd_config` once again, and just like before, we want to make a backup of the file first:

```
cp -f /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
```

Next, edit the `sshd_config` file:

```
vi /etc/ssh/sshd_config
```

We want to turn off tunneled passwords so find this line in the configuration:

```
PasswordAuthentication yes
```

And change it so that it says "no" - note that just remarking out this line will fail, as the default is always "yes".

```
PasswordAuthentication no
```

Public key authentication is on by default, but let's make sure that it is evident when you look at the file by removing the remark in front of this line:

```
#PubkeyAuthentication yes
```

So that it reads:

```
PubkeyAuthentication yes
```

This makes our `sshd_config` file self-documenting to a degree.

Save your changes. Cross your fingers, and restart `sshd`:

```
systemctl restart sshd
```

Attempting to login as one of your administrative users to the server using their keys should work just like before. If not, restore your backup, make sure that you've followed all of the steps, and try again.

## Part 4: Turn Off Remote root Login

Essentially, we have functionally done that already. If you attempt to login with the root user to the server now, you will get the following:

```
root@192.168.1.116: Permission denied (publickey,gssapi-keyex,gssapi-with-mic).
```

But we want to make sure that someone cannot create a public/private key for the root user and access the server that way. So there's one final step we need to perform and we need to do that...You guessed it! ... in the `sshd_config` file.

Since we are making a change to this file, just like every other step here, we want to make a backup copy of the file before continuing:

```
cp -f /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
```

Again, we want to edit the `sshd_config`:

```
vi /etc/ssh/sshd_config
```

Then we want to find this line:

```
PermitRootLogin yes
```

And change it to "no" so it reads:

```
PermitRootLogin no
```

Then save and quit out of the file and restart `sshd`:

```
systemctl restart sshd
```

Now anyone attempting to login as the root user remotely over `ssh` will get the same denial message as before, but will **still** not be able to access the server even if they have a public/private key pair for root.

## Conclusion

We've covered a lot of bits and pieces in this document but they are all designed to make a multisite web server more secure and less prone to attack vectors over SSH when turning on SFTP for customer access. Turning on and using SFTP is much more secure than using FTP, even if you are using really *GOOD* ftp servers and have them set up as securely as possible as noted in this [document on VSFTPD](secure_ftp_server_vsftpd). By implementing *all* of the steps in this document, you can feel comfortable opening up port 22 (SSH) to your public zone and still know that your environment is secure.
