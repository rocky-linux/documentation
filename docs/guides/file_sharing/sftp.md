---
title: Secure Server - sftp
author: Steven Spencer
contributors: Ezequiel Bruni
tested_with: 8.5, 8.6, 9.0
tags:
  - security
  - file transfer
  - sftp
  - ssh
  - web
  - multisite
---
# Secure Server - SFTP with SSH Lock Down Procedures

## Introduction

It may seem strange to have a document dedicated to the "secure" use of SFTP (a part of openssh-server package) when the SSH protocol is itself secure. I hear what you are thinking. But most system administrators do not want to open up SSH to everyone in order to implement SFTP for everyone. This document will describe how to implement a change root jail<sup>1</sup> for SFTP while keeping SSH access limited.

There are many documents out there that deal with creating an SFTP change root jail, but most do not take into account a use case where the user that is set up would be accessing a web directory on a server with multiple websites. This document deals with that. If that isn't your use case, you can easily adapt these concepts to use in different situations.

The author also feels that it is necessary when making the change root jail document for SFTP to also discuss the other things that you should do as a system administrator to minimize the target that you offer to the world via SSH. For this reason, this document is divided into four parts:

1. The first deals with the general information that we will use for the entire document.
2. The second deals with the setup of the change root jail, and if you decide that you want to stop there, that's totally up to you.
3. The third part deals with setting up public/private key SSH access for your system administrators and turning off remote password-based authentication.
4. The fourth, and last section of this document deals with turning off remote root logins.

Taking all of these steps will allow you to offer secure SFTP access for your customers while also minimizing the possibility that port 22 (the one reserved for SSH access) will be compromised by a bad actor.

!!! Note "<sup>1</sup> Change root jails for beginners:"

    Change root (or chroot) jails are a way to restrict what a process and all of its various child processes can do on your computer. It essentially allows you to choose a specific directory/folder on your machine, and make that the "root" dirtectory for any given process or program.

    From there on, that process or program can *only* access that folder and its subfolders.

!!! tip "Updates for Rocky Linux 8.6"

    This document has been updated to include new changes that came out with version 8.6 that will make this procedure even safer. If you are using 8.6, then there are specific sections in the document below, prefixed with "8.6 -". For clarity sake, the sections specific to Rocky Linux 8.5 have been prefixed with "8.5 - ". Other than those sections specifically prefixed, this document is generic for both versions of the OS.

## Part 1: General Information

### Assumptions and Conventions

We assume that:

* you are comfortable executing commands at the command line.
* you can use a command line editor, such as `vi` (used here), `nano`, `micro`, etc.
* you understand basic Linux commands used for adding groups and users, or can follow along well.
* your multisite website is set up like this: [Apache Multisite](../../web/apache-sites-enabled/)
* `httpd` (Apache) has already been installed on the server.

!!! note

    You can apply these concepts to any server set up, and to any web daemon. While we are assuming Apache here, you can definitely use this for Nginx as well.

### Sites, Users, Administrators

Everything is made up here. Any resemblance to persons or sites that are real, is purely accidental:

**Sites:**

* mybrokenaxel = (site1.com)
    user = mybroken
* myfixedaxel = (site2.com)
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
mkdir -p /var/www/sub-domains/com.site1/html
mkdir -p /var/www/sub-domains/com.site2/html
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

We need two sites created. We will create the configurations in `/etc/httpd/sites-available` and then link them to `../sites-enabled`:

```
vi /etc/httpd/sites-available/com.site1
```

!!! note

    We are only using the HTTP protocol for our example. Any real website would need an HTTPS protocol configuration, SSL certificates, and possibly more.

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

Once the two configuration files are created, go ahead and link them from within `/etc/httpd/sites-enabled`:

```
ln -s ../sites-available/com.site1
ln -s ../sites-available/com.site2
```
Now enable and start the `httpd` process:

```
systemctl enable --now httpd
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

* use `ssh` to log in as one of the administrative users to the server. (Example: `ssh lblakely@192.168.1.116` or `ssh lblakely@mywebserver.com`)
* once the server is accessed, you should be able to access root with `sudo -s` and entering the administrative user's password.

If this works for both administrative users, you should be ready to go to the next step.

#### Web Users (SFTP)

We need to add our web users. That `../html` directory structure already exists, so we don't want to create it when we add the user, but we *do* want to specify it. We also do not want any login other than via SFTP so we need to use a shell that denies logins.

```
useradd -M -d /var/www/sub-domains/com.site1/html -g apache -s /usr/sbin/nologin mybroken
useradd -M -d /var/www/sub-domains/com.site2/html -g apache -s /usr/sbin/nologin myfixed
```

Let's break down those commands a bit:

* The `-M` option says to *not* create the standard home directory for the user.
* `-d` specifies that what comes after is the *actual* home directory.
* `-g` says that the group that this user belongs to is `apache`.
* `-s` says that the shell the user is assigned is `/usr/sbin/nologin`
* At the end is the actual username for the user.

**Note:** For an Nginx server, you would use `nginx` as the group.

Our SFTP users still need a password. So let's go ahead and setup a secure password for each now. Since we have already seen the command output above, we won't be repeating it here:

```
passwd mybroken
passwd myfixed
```

### SSH Configuration

!!! warning

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
 
### The Template and The Script

Why are we creating a template and a script for this next part? The reason is simply to avoid human error as much as possible. We aren't done modifying that `/etc/ssh/sshd_config` file yet, but we want to eliminate as many errors as possible whenever we need to make these modifications. We will create all of this in `/usr/local/sbin`.

#### The Template

First, let's create our template:

```
vi /usr/local/sbin/sshd_template
```

This template should have the following:

```
Match User replaceuser
  PasswordAuthentication yes
  ChrootDirectory replacedirectory
  ForceCommand internal-sftp
  AllowTcpForwarding no
  X11Forwarding no
```

!!! note

    The `PasswordAuthentication yes` would not normally be required for the change root jail, BUT, we will be turning off `PasswordAuthentication` later on for everyone else, so it is important to have this line in the template.

We want a directory for our user files that we will create from the template too:

```
mkdir /usr/local/sbin/templates
```


=== "8.6 & 9.0"

    #### 8.6 & 9.0 - The Script and `sshd_config` Changes

    With the releases of Rocky Linux 8.6 and 9.0, a new option is available for the `sshd_config` file that allows for drop in configurations. This is a **GREAT** change. What this means is that for these versions we will make a single additional change to the `sshd_config` file, and then our script will build out sftp changes in a separate configuration file. This new change makes things even safer. Safety is good!!

    Because of the changes allowed for the `sshd_config` file in Rocky Linux 8.6 and 9.0, our script will use a new drop in configuration file: `/etc/ssh/sftp/sftp_config`.

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

    Save your changes and exit the file. We will need to restart `sshd` but our script will do that for us after we update `sftp_config` file, so let's create the script and run it.

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
=== "8.5"

    #### 8.5 - The Script

    Now let's create our script:

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
    fi

    ## Make a backup of /etc/ssh/sshd_config

    /usr/bin/rm -f /etc/ssh/sshd_config.bak

    /usr/bin/cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

    ## Now append our new user information to the file

    cat /usr/local/sbin/templates/$dom.txt >> /etc/ssh/sshd_config

    ## Restart sshd

    /usr/bin/systemctl restart sshd

    echo " "
    echo "Please check the status of sshd with systemctl status sshd."
    echo "You can verify that your information was added to the sshd_config by doing a more of the sshd_config"
    echo "A backup of the working sshd_config was created when this script was run: sshd_config.bak"
    ```


### Final Changes and Script Notes 

!!! tip

    If you take a look at either of the scripts above, you will note that we have changed the delimiter that `sed` uses by default from `/` to `,`. `sed` allows you to use any single-byte character as a delimiter. What we are searching for in the file has a bunch of "/" characters in it, and we would have had to escape each one (add a "\" in front of them) to search and replace these strings. Changing the delimiter makes this infinitely easier to do because it eliminates the need to do those escapes.

A couple of things to know about the script and about an SFTP change root in general. First, we are prompting for the needed information and then echoing it back to the user so they can verify it. If we answer "N" to the confirmation question, the script bails and does nothing. The script for 8.5 makes a backup of `sshd_config` (`/etc/ssh/sshd_config.bak`) the way it was prior to our running of the script. The 8.6 or 9.0 script does the same for the `sftp_config` file (`/etc/ssh/sftp/sftp_config.bak`). In this way, if we screw something up with an entry, we can simply restore the appropriate backup file and then restart `sshd` to get things working again.

The SFTP change root requires that the path given in the `sshd_config` is owned by root. For this reason, we do not need the `html` directory added to the end of the path. Once the user is authenticated, the change root will switch the user's home directory, in this case the `../html` directory, to whichever domain we are entering. Our script has appropriately changed the owner of the `../html` directory to the sftpuser and the apache group.

!!! warning "Script Compatibility"

    While you can use the script that we created for Rocky Linxux 8.5 on 8.5, 8.6 or 9.0 successfully, the same cannot be said for the script for 8.6 and 9.0. Since the drop in configuration file option (`Include` directive) was not enabled in 8.5, attempting to use the script written for those newer versions in Rocky Linux 8.5 will fail.

Now that our script is created, let's make it executable:

```
chmod +x /usr/local/sbin/webuser
```

Then run the script for our two test domains.

### Testing SSH Denial and SFTP Access

First, test using `ssh` from another machine to our host machine as one of the SFTP users. You should receive this after entering a password:

```
This service allows sftp connections only.
```
#### Graphical Tool Testing

If you *do* receive that message, then the next thing is to test SFTP access. If you would like to do things the easy way, you can use a graphical FTP application that supports SFTP such as Filezilla. In such cases, your fields would look something like this:

* **Host:** sftp://hostname_or_IP_of_the_server
* **Username:** (Example: myfixed)
* **Password:** (the password of the SFTP user)
* **Port:** (You shouldn't need to enter one, provided you are using SSH and SFTP on the default port 22)

Once filled in, you can click the "Quickconnect" (Filezilla) button and you should be connected to the `../html` directory of the appropriate site. Then double-click on the "html" directory to put yourself inside it and try to drop a file into the directory. If you are successful, then you are good.

#### Command Line Tool Testing

You can obviously do all of this from the command line on a machine that has SSH installed (most Linux installations). Here's a very brief overview of the command line method for connection and a few options:

* sftp username (Example: myfixed@ hostname or IP of the server: sftp myfixed@192.168.1.116)
* Enter the password when prompted
* cd html (change to the html directory)
* pwd (should show that you are in the html directory)
* lpwd (should show your local working directory)
* lcd PATH (should change your local working directory to something you want to use)
* put filename (will copy a file to `..html` directory)

For an exhaustive list of options and more, take a look at the [SFTP manual page](https://man7.org/linux/man-pages/man1/sftp.1.html).

### Web Test Files

For our dummy domains, we want to create a couple of `index.html` files that we can populate the `../html` directory with. Once these are created, you simply need to put them in the directory for each domain using the SFTP credentials for that domain. These files are super simple. We just want something so that we can see definitively that our sites are up and running and that the SFTP portion is working as expected. Here's an example of this file. You can of course modify it as you like:

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

### Web Tests

To test that these files show up and load as expected, you simply need to modify your hosts file on your workstation. For Linux, that would be `sudo vi /etc/hosts` and then simply add in the IP and host names we are testing with like this:

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

    For real domains, you would want to populate your DNS servers with the hosts above. You can, though, use this *Poor Man's DNS* for testing any domain, even one that hasn't been taken live on real DNS servers.

Now, open your web browser and check to make sure that your `index.html` file for each domain displays by entering the URL in your browser's address bar. (Example: "http://site1.com") If your test index files load, everything is working correctly.

## Part 3: Administrative Access with SSH key pairs

Please note that we will be using concepts discussed in the document [SSH Public and Private Keys](../../security/ssh_public_private_keys) in this section, but also improving on it. If you are new to the process, feel free to read that article first before continuing.

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

At this point both the public and private keys have been created. Repeat this step for our other system administrator example user.

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

## Addendum: New System Administrators

One thing that we haven't discussed yet is what happens when a new system administrator comes on board? With password authentication off, `ssh-copy-id` will not work. Here's what the author recommends for these situations. Note that there is more than one solution:

### Solution One - Sneaker Net

This solution assumes physical access to the server and that the server is physical hardware and not virtual (container or VM):

* Add the user to the "wheel" group on the SFTP server
* Have the user generate his SSH public and private keys
* Using a USB drive, copy the public key to the drive and physically walk it over to the server and install it manually in the new system administrators `/home/[username]/.ssh` directory

### Solution Two - Temporarily Edit The `sshd_config`

This solution is prone to human error, but since it isn't done often, it would probably be OK if carefully done:

* Add the user to the "wheel" group on the SFTP server
* Have another system administrator who already has key based authentication, temporarily turn on "PasswordAuthentication yes" in the `sshd_config` file and restart `sshd`
* Have the new system administrator run `ssh-copy-id` using his/her password to copy the ssh key to the server.

### Solution Three - Script The Process

This is the author's favorite. It uses a system administrator which already has key-based access and a script that must be run with `bash [script-name]` to accomplish the same thing as "Solution Two" above:

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
Script explanation: We don't make this script executable. The reason is that we don't want it accidentally run. The script would need to be run (as noted above) like this: `bash /usr/local/sbin/quickswitch`. This script makes a backup copy of the `sshd_config` file just like all of our other examples above. It then edits the `sshd_config` file in place and searches for the *FIRST* occurrence of `PasswordAuthentication no` and changes it to `PasswordAuthentication yes` then restarts `sshd` and waits for the script user to hit <kbd>ENTER</kbd> before continuing. The system administrator running the script would be in communication with the new system administrator, and once that new system administrator runs `ssh-copy-id` to copy his key to the server, the system administrator who is running the script hits enter and the change is reversed.

## Conclusion

We've covered a lot of bits and pieces in this document but they are all designed to make a multisite web server more secure and less prone to attack vectors over SSH when turning on SFTP for customer access. Turning on and using SFTP is much more secure than using FTP, even if you are using really *GOOD* ftp servers and have them set up as securely as possible as noted in this [document on VSFTPD](../secure_ftp_server_vsftpd). By implementing *all* of the steps in this document, you can feel comfortable opening up port 22 (SSH) to your public zone and still know that your environment is secure.
