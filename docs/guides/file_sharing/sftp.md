---
title: Secure Server - sftp
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 8.5, 8.6, 9.0
tags:
  - security
  - file transfer
  - sftp
  - ssh
  - web
  - multisite
---
# Secure server - SFTP with SSH lock down procedures

## Introduction

When the SSH protocol itself is secure, it may seem strange to have a document dedicated to the "secure" use of SFTP (a part of openssh-server package). But most system administrators do not want to open SSH to everyone to implement SFTP for everyone. This document describes implementing a change root (**chroot**) jail for SFTP while limiting SSH access.

Many documents deal with creating an SFTP chroot jail, but most do not consider a use case where the user might be accessing a web directory on a server with many websites. This document deals with that. If that is not your use case, you can quickly adapt these concepts to different situations.

The author also feels that it is necessary when making the chroot jail document for SFTP to also discuss the other things that you should do as a system administrator to minimize the target that you offer to the world via SSH. For this reason, division of this document is in four parts:

1. The first deals with the general information that you will use for the entire document.
2. The second deals with the chroot setup. If you stop there that is totally up to you.
3. The third part deals with setting up public/private key SSH access for your system administrators and turning off remote password-based authentication.
4. This document's fourth and last section deals with turning off remote root logins.

All of these steps will allow you to offer secure SFTP access for your customers while minimizing the possibility that a bad actor will compromise port 22 (the one reserved for SSH access).

!!! Note "chroot jails for beginners:"

    chroot jails are a way to restrict what a process and all of its various child processes can do on your computer. It allows you to choose a specific directory or folder on your machine, and make that the "root" dirtectory for any process or program.

    From there on, that process or program can *only* access that folder and its subfolders.

!!! tip "Updates for Rocky Linux 8.x and 9.x"

    This document has been updated to include new changes in version 8.6 that will make this procedure even safer. If you are using 8.6 or newer, or any version of 9.x, this procedure should work for you. The sections specific to Rocky Linux 8.5 have been removed, as the current release of 8 (8.8 at the time of the rewrite) should be where any version of 8.x is after updating packages. 

## Part 1: General information

### Assumptions and conventions

Assumptions are that:

* you are comfortable executing commands at the command line.
* you can use a command line editor, such as `vi` (used here), `nano`, `micro`, etc.
* you understand basic Linux commands used for adding groups and users, or can follow along well.
* your multisite website is like this: [Apache Multisite](../../web/apache-sites-enabled/)
* you have already installed `httpd` (Apache) on the server.

!!! note

    You can apply these concepts to any server set up and any web daemon. While we are assuming Apache here, you can also use this for Nginx.

### Sites, users, administrators

These are fictitious scenarios. Any resemblance to persons or sites that are real, is purely accidental:

**Sites:**

* mybrokenaxel = (site1.com)
    user = mybroken
* myfixedaxel = (site2.com)
    user = myfixed

**Administrators**

* Steve Simpson = ssimpson
* Laura Blakely = lblakely

## Part 2: SFTP chroot jail

### Installation

Installation is not difficult. You just need to have `openssh-server` installed, which is probably installed already. Enter this command to be sure:

```
dnf install openssh-server
```

### Setup

#### Directories

The directory path structure will be `/var/www/sub-domains/[ext.domainname]/html` and the `html` directory in this path will be the chroot jail for the SFTP user.

Creating the configuration directories:

```
mkdir -p /etc/httpd/sites-available
mkdir -p /etc/httpd/sites-enabled
```

Creating the web directories:

```
mkdir -p /var/www/sub-domains/com.site1/html
mkdir -p /var/www/sub-domains/com.site2/html
```
You will deal with the ownership of these directories in the script application later.

### `httpd` configuration

You need to change the built-in `httpd.conf` file to make it load the configuration files in the `/etc/httpd/sites-enabled` directory. Do this by adding one line at the bottom of the `httpd.conf` file.

Edit the file with your favorite editor. The author uses `vi` here:

```
vi /etc/httpd/conf/httpd.conf
```

and add this at the bottom of the file:

```
Include /etc/httpd/sites-enabled
```

Save the file and exit.

### Website configuration

You need two sites created. You will create the configurations in `/etc/httpd/sites-available` and link them to `../sites-enabled`:

```
vi /etc/httpd/sites-available/com.site1
```

!!! note

    The example only uses the HTTP protocol. Any real website would need the HTTPS protocol configuration, SSL certificates, and possibly more.

```
<VirtualHost *:80>
        ServerName www.site1.com
        ServerAdmin username@rockylinux.org
        DocumentRoot /var/www/sub-domains/com.site1/html
        DirectoryIndex index.php index.htm index.html
        Alias /icons/ /var/www/icons/


    CustomLog "/var/log/httpd/com.site1.www-access_log" combined
    ErrorLog  "/var/log/httpd/com.site1.www-error_log"

        <Directory /var/www/sub-domains/com.site1/html>
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
vi /etc/httpd/sites-available/com.site2
```

```
<VirtualHost *:80>
        ServerName www.site2.com
        ServerAdmin username@rockylinux.org
        DocumentRoot /var/www/sub-domains/com.site2/html
        DirectoryIndex index.php index.htm index.html
        Alias /icons/ /var/www/icons/


    CustomLog "/var/log/httpd/com.site2.www-access_log" combined
    ErrorLog  "/var/log/httpd/com.site2.www-error_log"

        <Directory /var/www/sub-domains/com.site2/html>
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

When finished creating the two configuration files, link them from within `/etc/httpd/sites-enabled`:

```
ln -s ../sites-available/com.site1
ln -s ../sites-available/com.site2
```
Enable and start the `httpd` process:

```
systemctl enable --now httpd
```

### User creation

For our example environment, the assumption is that none of the users exist yet. Start with your administrative users. Note that at this point in your process, you can still log in as the root user to add the other users and set them up the way you want. When the users are setup and tested, you can remove root logins.

#### Administrators

```
useradd -g wheel ssimpson
useradd -g wheel lblakely
```
By adding our users to the group "wheel" you give them `sudo` access.

You still need a password for `sudo` access. There are ways around this, but none are all that secure. Frankly, if you have problems with security using `sudo` on your server, then you have much bigger problems with your entire setup. Set the two administrative passwords with secure passwords:

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

Test access to the server with `ssh` for your two administrative users. You should be able to:

* use `ssh` to log in as one of the administrative users of the server. (Example: `ssh lblakely@192.168.1.116` or `ssh lblakely@mywebserver.com`)
* you should be able to access root with `sudo -s` and entering the administrative user's password.

You will be ready for the next step if this works for all administrative users.

#### Web users (SFTP)

You need to add our web users. That `../html` directory structure already exists, so you do not want to create it when adding the user, but you *do* want to specify it. You also do not want any login other than with SFTP so you need to use a shell that denies logins.

```
useradd -M -d /var/www/sub-domains/com.site1/html -g apache -s /usr/sbin/nologin mybroken
useradd -M -d /var/www/sub-domains/com.site2/html -g apache -s /usr/sbin/nologin myfixed
```

Breaking down those commands a bit:

* The `-M` option says to *not* create the standard home directory for the user.
* `-d` specifies that what comes after is the *actual* home directory.
* `-g` says that the group that this user belongs to is `apache`.
* `-s` says the assigned shell is `/usr/sbin/nologin`
* At the end is the actual username for the user.

**Note:** For an Nginx server, you would use `nginx` as the group.

Our SFTP users still need  passwords. Setup a secure password for each now. You have already seen the command output above:

```
passwd mybroken
passwd myfixed
```

### SSH configuration

!!! warning

    Before you start this process, it is highly recommended that you make a backup of the system file you will modify: `/etc/ssh/sshd_config`. Breaking this file and being unable to return to the original could cause you a world of heartache!

    ```
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
    ```

You need to make one change to the `/etc/ssh/sshd_config` file. You are going to build a template to make your web directory changes outside of the configuration file and script the additions you are going to need.

First, make the manual change you need:

```
vi /etc/ssh/sshd_config
```

Near the bottom of the file, you will find this:

```
# override default of no subsystems
Subsystem     sftp    /usr/libexec/openssh/sftp-server
```

You want to change that to read as follows:

```
# override default of no subsystems
# Subsystem     sftp    /usr/libexec/openssh/sftp-server
Subsystem       sftp    internal-sftp
```
Save and exit the file.

The `sftp-server` and `internal-sftp` are part of OpenSSH. The `internal-sftp`, while not too different from the `sftp-server`, simplifies configurations using `ChrootDirectory` to force a different file system root on clients. That is why you use `internal-sftp`.
 
### The template and script

Why are you creating a template and a script for this next part? The reason is to avoid human error as much as possible. You are not done modifying that `/etc/ssh/sshd_config` file yet, but you want to eliminate as many errors as possible whenever you need to make these modifications. You will create all of this in `/usr/local/sbin`.

#### The template

First, create your template:

```
vi /usr/local/sbin/sshd_template
```

This template will have the following:

```
Match User replaceuser
  PasswordAuthentication yes
  ChrootDirectory replacedirectory
  ForceCommand internal-sftp
  AllowTcpForwarding no
  X11Forwarding no
```

!!! note

    The `PasswordAuthentication yes` would not normally be required for the chroot jail. However, you will be turning off `PasswordAuthentication` later on for everyone else, so having this line in the template is essential.

You want a directory for your user files that you will create from the template too:

```
mkdir /usr/local/sbin/templates
```


#### The script and `sshd_config` changes

With the releases of Rocky Linux 8.6 and 9.0, a new option for the `sshd_config` file allows for drop-in configurations. This is a **GREAT** change. This means that you will make a single additional change to the `sshd_config` file, and our script will build out sftp changes in a separate configuration file. This new change makes things even safer. Safety is good!!

Because of the changes allowed for the `sshd_config` file in Rocky Linux 8.6 and 9.0, our script will use a new drop-in configuration file: `/etc/ssh/sftp/sftp_config`.

To start with, create that directory:

```
mkdir /etc/ssh/sftp
```

Now make a backup copy of the `sshd_config`:

```
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
```

And finally edit the `sshd_config` file, scroll to the very bottom of the file, and add this line:

```bash
Include /etc/ssh/sftp/sftp_config
```

Save your changes and exit the file. You will need to restart `sshd` but our script will do that for us after you update `sftp_config` file, so create the script and run it.

```
vi /usr/local/sbin/webuser
```

And put this code in it:

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
        # Ensure directory permissions are correct
        # The root user owns all directories except the chroot, which is owned by the sftpuser
        # when connecting, you will end up one directory down, and you must actually change to the html directory
        # With a graphical SFTP client, this will be visible to you, you just need to double-click on the html 
        # directory before attmpting to drop in files.
        chmod 755 $dompath
        chmod 755 $dompath$dom
        chmod 755 $dompath$dom/html
        chmod 744 -R $dompath$dom/html/
    fi

    ## Make a backup of /etc/ssh/sftp/sftp_config

    /usr/bin/rm -f /etc/ssh/sftp/sftp_config.bak

    /usr/bin/cp /etc/ssh/sftp/sftp_config /etc/ssh/sftp/sftp_config.bak

    ## Now append our new user information to to the file

    cat /usr/local/sbin/templates/$dom.txt >> /etc/ssh/sftp/sftp_config

    ## Restart sshd

    /usr/bin/systemctl restart sshd

    echo " "
    echo "Please check the status of sshd with systemctl status sshd."
    echo "You can verify that your information was added by doing a more of the sftp_config"
    echo "A backup of the working sftp_config was created when this script was run: sftp_config.bak"
```

### Final changes and script notes 

!!! tip

    If you take a look at the script above, you will note the changing of the delimiter that `sed` uses by default from `/` to `,`. `sed` allows you to use any single-byte character as a delimiter. What you are searching for in the file has a bunch of "/" characters in it, and you would have had to escape each one (add a "\" in front of them) to search and replace these strings. Changing the delimiter makes this infinitely easier to do because it eliminates the need to do those escapes.

A couple of things are notable about the script and about an SFTP chroot in general. First, you prompt for the needed information and echo it back to the user for verification. If you answer "N" to the confirmation question, the script bails and does nothing. The script for 8.5 makes a backup of `sshd_config` (`/etc/ssh/sshd_config.bak`) the way it was prior to our running of the script. The 8.6 or 9.0 script does the same for the `sftp_config` file (`/etc/ssh/sftp/sftp_config.bak`). In this way, if you make errors in an entry, you can restore the appropriate backup file and restart `sshd` to get things working again.

The SFTP chroot requires that the path given in the `sshd_config` has root ownership. For this reason, you do not need the `html` directory added to the end of the path. Once the user authenticates, the chroot will switch the user's home directory, in this case the `../html` directory, to whichever domain you are entering. Your script has appropriately changed the owner of the `../html` directory to the sftpuser and the apache group.

Make the script executable:

```
chmod +x /usr/local/sbin/webuser
```

Run the script for our two test domains.

### Testing SSH denial and SFTP access

First, test with `ssh` from another machine to our host machine as one of the SFTP users. You should receive this after entering a password:

```
This service allows sftp connections only.
```
#### Graphical tool testing

If you *do* receive that message, the next thing is to test SFTP access. For ease of testing, you can use a graphical FTP application that supports SFTP such as Filezilla. In such cases, your fields will look something like this:

* **Host:** sftp://hostname_or_IP_of_the_server
* **Username:** (Example: myfixed)
* **Password:** (the password of the SFTP user)
* **Port:** If you use SSH and SFTP on the default port 22, enter that port

Once filled in, you can click the "Quickconnect" (Filezilla) button and you will connect to the `../html` directory of the appropriate site. Double-click on the "html" directory to put yourself inside it and try to drop a file into the directory. If you are successful, everything is working correctly.

#### Command line tool testing

You can do all of this from the command line on a machine with SSH installed (most Linux installations). Here is a brief overview of the command line method for connection and a few options:

* sftp username (Example: myfixed@ hostname or IP of the server: sftp myfixed@192.168.1.116)
* Enter the password when prompted
* cd html (change to the html directory)
* pwd (should show that you are in the html directory)
* lpwd (should show your local working directory)
* lcd PATH (should change your local working directory to something you want to use)
* put filename (will copy a file to `..html` directory)

For an exhaustive list of options and more, view the [SFTP manual page](https://man7.org/linux/man-pages/man1/sftp.1.html).

### Web test files

For our dummy domains, you want to create a couple of `index.html` files that you can populate the `../html` directory with. When created, you need to put them in the directory for each domain with the SFTP credentials for that domain. These files are simplistic. You just want something to verify that your sites are up and running and that SFTP is working as expected. Here is an example of this file. You can change it if you want to:

```
<!DOCTYPE html>
<html>
<head>
<title>My Broken Axel</title>
</head>
<body>

<h1>My Broken Axel</h1>
<p>A test page for the site.</p>

</body>
</html>
```

### Web tests

You need to change the _hosts_ file on your workstation to test that these files show up and load as expected. For Linux that will be `sudo vi /etc/hosts` and add in the IP and host names you are testing with like this:

```
127.0.0.1	localhost
192.168.1.116	www.site1.com site1.com
192.168.1.116	www.site2.com site2.com
# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
```

!!! tip

    You would want to populate your DNS servers with the hosts above for real domains. You can, though, use this *Poor Man's DNS* for testing any domain, even one that has not been taken live on real DNS servers.

Open your web browser and ensure that your `index.html` file for each domain displays by entering the URL in your browser's address bar. (Example: "http://site1.com") If your test index files load, everything is working correctly.

## Part 3: Administrative access with SSH key pairs

Note that you will use concepts discussed in the document [SSH Public and Private Keys](../../security/ssh_public_private_keys) here, but also improving on it. If you are new to the process, read that article before continuing.

### Creating the public/private key pairs

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

Repeat whatever passphrase you entered earlier or enter for none.

At this point the public and private keys exist. Repeat this step for our other system administrator example user.

### Transferring the public key to the SFTP server

The next step is to export our key to the server. In reality, a system administrator responsible for managing multiple servers will transfer their public key to all the servers they are responsible for.  

The user can send the key to the server securely with `ssh-id-copy` when created:

```
ssh-id-copy lblakely@192.168.1.116
```

The server will prompt for the user's password one time, and copy the key into _authorized_keys_. You will get this message too:

```
Number of key(s) added: 1

Now try logging into the machine, with:   "ssh 'lblakely@192.168.1.116'"
and check to make sure that only the key(s) you wanted were added.
```

If you are able to login with this account, repeat the process with the other administrator.

### Allowing ONLY key-based logins

If everything has worked out as planned and our keys for our administrators are now in place on the SFTP server, you need to turn off password authentication on the server. For safety sake, ensure you have two connections to the server to reverse any changes if you have unintended consequences.

To accomplish this step, you need to change the `sshd_config` again, and just like before, you want to make a backup of the file first:

```
cp -f /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
```

Next, edit the `sshd_config` file:

```
vi /etc/ssh/sshd_config
```

You want to turn off tunneled passwords. Find this line in the configuration:

```
PasswordAuthentication yes
```

Change it to "no" - note that just remarking out this line will fail, as the default is always "yes".

```
PasswordAuthentication no
```

Public key authentication is on by default, but ensure that it is by removing the remark in front of this line:

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

Attempting to login as one of your administrative users to the server using their keys should work just like before. If not, restore your backup, ensure you have followed all of the steps, and try again.

## Part 4: Turn off remote root login

You have functionally done that already. If you attempt to login with the root user to the server now, you will get the following:

```
root@192.168.1.116: Permission denied (publickey,gssapi-keyex,gssapi-with-mic).
```

But you want to ensure that someone cannot create a public/private key for the root user and access the server that way. To do this, you will need one final step. You will make that change...You guessed it! ... in the `sshd_config` file.

Just like every other step here when changing the `sshd_config` file, you want to make a backup copy of the file before continuing:

```
cp -f /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
```

Edit the `sshd_config`:

```
vi /etc/ssh/sshd_config
```

Find this line:

```
PermitRootLogin yes
```

Change it to "no":

```
PermitRootLogin no
```

Save, quit out of the file, and restart `sshd`:

```
systemctl restart sshd
```

A login as the root user remotely over `ssh` will get the same denial message as before, but will **still** not be able to access the server even if they have a public/private key pair for root.

## Addendum: New system administrators

Not discussed yet is what happens when adding another system administrator. `ssh-copy-id` will not work with password authentication off. Here is what the author recommends for these situations. Note more than one solution exists. In addition, to the methods mentioned here, an existing administrator can generate and deploy the keys for another administrator. 

### Solution one - sneaker net

This solution assumes physical access to the server and that the server is physical hardware and not virtual (container or VM):

* Add the user to the "wheel" group on the SFTP server
* Have the user generate his SSH public and private keys
* Using a USB drive, copy the public key to the drive and physically walk it over to the server and install it manually in the new system administrators `/home/[username]/.ssh` directory

### Solution two - temporarily edit the `sshd_config`

This solution is prone to human error, but since it is not done often, it would probably be OK if carefully done:

* Add the user to the "wheel" group on the SFTP server
* Have another system administrator who already has key based authentication, temporarily turn on "PasswordAuthentication yes" in the `sshd_config` file and restart `sshd`
* Have the new system administrator run `ssh-copy-id` using their password to copy the ssh key to the server.

### Solution three - script the process

This process uses a system administrator that already has key-based access and a script that must run with `bash [script-name]` to accomplish the same thing as "Solution Two" above:

* manually edit the `sshd_config` file and remove the remarked-out line that looks like this: `#PasswordAuthentication no`. This line is documenting the process of turning password authentication off, but it will get in the way of the script below, because our script will look for the first occurrence of `PasswordAuthentication no` and later the first occurrence of `PasswordAuthentication yes`. If you remove this one line, our script will work fine.
* create a script on the SFTP server called "quickswitch", or whatever you want to call it. The contents of this script would look like this:

```
#!/bin/bash
# for use in adding a new system administrator

/usr/bin/cp -f /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

/usr/bin/sed -i '0,/PasswordAuthentication no/ s/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
/usr/bin/systemctl restart sshd
echo "Have the user send his keys, and then hit enter."
read yn
/usr/bin/sed -i '0,/PasswordAuthentication yes/ s/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
/usr/bin/systemctl restart sshd
echo "Changes reversed"
```
Script explanation: You do not make this script executable. The reason is that you do not want it to run accidentally. The script runs (as noted above) like this: `bash /usr/local/sbin/quickswitch`. This script makes a backup copy of the `sshd_config` file just like all of our other examples above. It then edits the `sshd_config` file in place and searches for the *FIRST* occurrence of `PasswordAuthentication no` and changes it to `PasswordAuthentication yes` then restarts `sshd` and waits for the script user to hit <kbd>ENTER</kbd> before continuing. The system administrator running the script would be in communication with the new system administrator, and once that new system administrator runs `ssh-copy-id` to copy his key to the server, the system administrator who is running the script hits enter and that reverses the change.

In short, many ways exist for adding another system administrator after the implementation of SSH lock down procedures.

## Conclusion

This document is extensive. It will make a multisite web server more secure and less prone to attack vectors over SSH when turning on SFTP for customer access. SFTP is much more secure than FTP, even if you use a really *GOOD* FTP servers and have them set up as securely as possible as noted in this [document on VSFTPD](../secure_ftp_server_vsftpd). By implementing *all* of the steps in this document, you can feel comfortable opening up port 22 (SSH) to your public zone and still know that your environment is secure.
