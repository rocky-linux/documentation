---
author: Wale Soyinka 
contributors: Steven Spencer, Ganna Zhyrnova 
tested on: All versions
tags:
  - introduction system administration
  - lab exercise
  - users
  - groups
---



# Lab 6: User and group management

## Objectives

After completing this lab, you will be able to

-  Add and remove users on the system
-  Add and remove groups on the system
-  Modify users and groups on the system
-  Change passwords

Estimated time to complete this lab: 40 minutes

## User accounts

User management is important in any multi-user network operating system. Linux is a multi-user network operating system. Without the users, there wouldn’t be any need for a multi-user network operating system in the first place!

Managing users on a system is intricately tied to the system's security. There is an old saying that:

>A system is as secure as its weakest user. 
    
Linux inherits the old UNIX tradition of governing access to files, programs and other resources on a per-user and per-group basis.

Just like almost all other configurations in Linux, user management can be carried out by directly editing configuration files that can be found in the file system hierarchy. This lab will explore user management through the manual way and also through the use of system utilities.

We'll also briefly examine file permissions and ownership.

Important user and group management files are below. Some of the fields or entries in the files are also discussed.

### /etc/passwd

* **Purpose:** user account information
* **Content:**
    * login name
    * encrypted password
    * user id (UID)
    * group id (GID)
    * user full name
    * user home directory
    * default shell

### /etc/shadow

* **Purpose:** secure user account information
* **Content:**
    * login name
    * hashed password
    * days since Jan. 1, 1970 that password was last changed
    * days before which password may not be changed. Usually zero.
    * days after which password must be changed
    * days before password expiry that user is warned of pending expiration
    * days after password expiry that account is considered inactive and disabled
    * days since Jan. 1, 1970 when account will be disabled
    * reserved

### /etc/group

* **Purpose:** group information
* **Content:**
    * name of the group
    * the group's password
    * the group id (GID)
    * list of users belonging to the group

### /etc/skel

* **Purpose:** Stores templates to be applied to new accounts

## Common utilities

Some common utilities used in the day-to-day user and group management tasks are listed below:

### `useradd`

    ```bash

    Usage: useradd [options] LOGIN
        useradd -D
        useradd -D [options]

    Options:
        --badname                 do not check for bad names
    -b, --base-dir BASE_DIR       base directory for the home directory of the new account
        --btrfs-subvolume-home    use BTRFS subvolume for home directory
    -c, --comment COMMENT         GECOS field of the new account
    -d, --home-dir HOME_DIR       home directory of the new account
    -D, --defaults                print or change default useradd configuration
    -e, --expiredate EXPIRE_DATE  expiration date of the new account
    -g, --gid GROUP               name or ID of the primary group of the new account
    -G, --groups GROUPS           list of supplementary groups of the new account
    -h, --help                    display this help message and exit
    -k, --skel SKEL_DIR           use this alternative skeleton directory
    -K, --key KEY=VALUE           override /etc/login.defs defaults
    -l, --no-log-init             do not add the user to the lastlog and faillog databases
    -m, --create-home             create the user's home directory
    -M, --no-create-home          do not create the user's home directory
    -N, --no-user-group           do not create a group with the same name as the user
    -o, --non-unique              allow to create users with duplicate (non-unique) UID
    -p, --password PASSWORD       encrypted password of the new account
    -r, --system                  create a system account
    -R, --root CHROOT_DIR         directory to chroot into
    -P, --prefix PREFIX_DIR       prefix directory where are located the /etc/* files
    -s, --shell SHELL             login shell of the new account
    -u, --uid UID                 user ID of the new account
    -U, --user-group              create a group with the same name as the user
    -Z, --selinux-user SEUSER     use a specific SEUSER for the SELinux user mapping
    ```

### `groupadd`

    ```bash
    Usage: groupadd [options] GROUP
    
    Options:
    -f, --force                   exit successfully if the group already exists, and cancel -g if the GID is already used
    -g, --gid GID                 use GID for the new group
    -h, --help                    display this help message and exit
    -K, --key KEY=VALUE           override /etc/login.defs defaults
    -o, --non-unique              allow to create groups with duplicate (non-unique) GID
    -p, --password PASSWORD       use this encrypted password for the new group
    -r, --system                  create a system account
    -R, --root CHROOT_DIR         directory to chroot into
    -P, --prefix PREFIX_DI        directory prefix
    -U, --users USERS             list of user members of this group
    ```
### `passwd`

    ```bash
    Usage: passwd [OPTION...] <accountName>
    -k, --keep-tokens       keep non-expired authentication tokens
    -d, --delete            delete the password for the named account (root only); also removes password lock if any
    -l, --lock              lock the password for the named account (root only)
    -u, --unlock            unlock the password for the named account (root only)
    -e, --expire            expire the password for the named account (root only)
    -f, --force             force operation
    -x, --maximum=DAYS      maximum password lifetime (root only)
    -n, --minimum=DAYS      minimum password lifetime (root only)
    -w, --warning=DAYS      number of days warning users receives before password expiration (root only)
    -i, --inactive=DAYS     number of days after password expiration when an account becomes disabled (root only)
    -S, --status            report password status on the named account (root only)
      --stdin             read new tokens from stdin (root only)

    Help options:
      -?, --help              Show this help message
      --usage             Display brief usage message
    ```

## Exercise 1

### Manually creating a new user

So far, throughout the previous labs, you have been using the system as the most powerful user on the system – the `root` user. This is not good practice in a production system because it makes the system vulnerable, securityi-wise. The root user can, do and undo unlimited damage to the system.

Other than the superuser, every other user has limited access to files and directories.
Always use your machine as a normal user. Two confusing concepts will be made clear here.

- Firstly the home directory of the root user is  “ /root “.
- Secondly the root directory is the topmost directory, known as the /  (slash) directory.
  (“/root” is different from  “/ “)

In this lab you will create a new user called “Me Mao”. The user name for “Me Mao" will be the first name - “me”. This new user will belong to the group “me”. The password will be “a1b2c3”

!!! Warning

    System configurations usually conform to a specific format. It is always important to adhere to this format when manually editing the configuration files. One way to do this is to find and copy an existing entry in the file and then modify the copied line/section with any new changes. This will help reduce the chances of you making errors.


1. Log in to the computer as root

2. Use the `tail` command to view the last 4 entries at the bottom of the `/etc/passwd` file.

    ```bash
    [root@localhost root]# tail -n 4 /etc/passwd
    apache:x:48:48:Apache:/var/www:/sbin/nologin
    xfs:x:43:43:X Font Server:/etc/X11/fs:/sbin/nologin
    ntp:x:38:38::/etc/ntp:/sbin/nologin
    gdm:x:42:42::/var/gdm:/sbin/nologin    
    ```
    
    You will edit the passwd file using the format displayed above.	


#### To create the user

1. We'll need to edit the `/etc/passwd` file. 

    Launch your editor of choice and open up the file “/etc/passwd”

    Add the text below to the bottom or end of the file:

    ```bash
    me:x:500:500:me mao:/home/me:/bin/bash    
    ```
    
2. Save your changes and close the passwd file.

3. Next we'll edit the `/etc/shadow` file.
    Launch your editor and open up the “/etc/shadow” file.
    Add a new entry like the one below to the bottom of the file - put an asterisk  (*) in the password field. Type:
    
    ```bash
    me:x:11898:11898:99999:7:::   
    ```

4. Save your changes and close the shadow file.

5. We'll edit the `/etc/group` file next.
    Launch your editor and open up the `/etc/group` file.
    At the bottom of the file add a new entry like:
    
    ```bash
    me:x:1000:me
    ```
    
6. Save your changes and close the group file.

7. Time to create the home directory.
 
    Copy the entire contents of the “/etc/skel” directory into /home directory, renaming the new directory to the name of the user i.e. “/home/me”. Type :

    ```bash
    [root@localhost root]# cp -r /etc/skel /home/me
    ```
    
8. The root user owns the directory you just created, because she created it. In order for the user “me mao” to be able to use the directory you will change the permissions/ownership of the folder. Type:
    
    ```bash
    [root@localhost root]# chown -R me:me /home/me		
    ```
9. Create a password for the user. Set the value of the password to be `a!b!c!d!`.
    You will use the “passwd” utility. 
    Type “passwd” and follow the prompts
    
    ```bash
    [root@localhost root]# passwd me
    Changing password for user me.
        New password:
        Retype new password:
        passwd: all authentication tokens updated successfully.
    ```

10. Logout of the system when you are done.

## Exercise 2

### Automatically creating a new user

There are loads of utilities available to simplify all the tasks/steps that we manually performed in the previous exercise. We only walked through the manual process of creating a user, so that you can see what actually goes on in the background.

In this exercise we will use some common utilities to manage and simplify the process.

You will create another user account for the user “Ying Yang” the login name will be “ying”.

And the password for "ying" will be “y@i@n@g@”.

You will also create a group called “common” and add the user "me" and "ying" to the group.

#### To automatically create a new account

1. Login to the system as root.

2. You will create the user ying using all the defaults of the `useradd` command. Type:
    
    ```bash
    [root@localhost root]# useradd -c "Ying Yang" ying
    ```

3. Use the `tail` command to examine the addition you just made to the `/etc/passwd` file. Type:
    
    ```bash
    flatpak:x:982:982:User for flatpak system helper:/:/sbin/nologin
    pesign:x:981:981:Group for the pesign signing daemon:/run/pesign:/sbin/nologin
    me:x:1000:1000:99999:7:::
    ying:x:1001:1001:Ying Yang:/home/ying:/bin/bash
    ```
    
    !!! Question
    
        List the new entry here?
    
4.  The user ying will not be able to login to the system until you create a password for the user. Set ying's password to be `y@i@n@g@`. Type:
    
    ```bash
    [root@localhost root]# passwd ying
    Changing password for user ying.
        New password:   **********
        Retype new password: **********
        passwd: all authentication tokens updated successfully.
    ```
    
5. Use the `id` utility to quickly view information about the new users you just created. Type:
    
    ```bash
    [root@localhost root]# id me
        uid=1000(me) gid=1000(me) groups=1000(me)
    ```
    
6. Do the same thing for the user ying. Type:

    ```bash
    [root@localhost root]# id ying
        uid=501(ying) gid=501(ying) groups=501(ying)
    ```
    
#### To automatically create a new group

1. Use the `groupadd` program to create the new group “common”.
    
    ```bash
    [root@localhost root]# groupadd common
    ```
    
2. Examine the tail end of the `/etc/group` file to see the new addition. 
    
    !!! Question
        
        What is the command to do this?
    
3. Use the `usermod` command to add an existing user to an existing group. Let's add the user ying to the `common` group we just created in Step 1. Type:
    
    ```bash
    [root@localhost root]# usermod -G common -a ying
    ```

4. Do the same things for the user me. Type:
    
    ```bash
    [root@localhost root]# usermod -G common -a me
    ```
    
5. Run the `id` command again on the users “ying” and "me" . What has changed?

6. Use the `grep` command to view changes to the `common` group entry in the file. Type:
    
     ```bash
    [root@localhost root]# grep common /etc/group
        common:x:1002:ying,me
    ```
    
#### To modify a user account


1. Use the `usermod` command to change the comment field for the user “me”. The new comment you will add will be “first last”. Type:
    
    ```bash
    [root@localhost root]# usermod -c "first last" me
    ```

    Use the `tail` command to examine your changes to the `/etc/passwd` file. Write the changed line below?

2. What is the user me’s login shell?

3. Use the `usermod` command again to change me’s login shell to the csh shell. Type:
    
    ```bash
    [root@localhost root]# usermod -s /bin/csh me
    ```
    
4. Finally use the `usermod` command to undo all the changes you made to the user “me” above.
    
    Restore the values ( login shell etc..) to their original values. Write down the commands to do this?
    
## Exercise 3

### Set user

It is not always convenient to log completely out of the system completely to log in as another user. This may be because you have certain tasks running and you don’t want to end them. The `su` (set user) program is used to become another user temporarily. You can “su” from a regular user account to the root account or vice-versa.

It changes the current user to have the access rights of the temporary user.

The HOME, LOGNAME, and USER environment variables will be set to those of the temporary user by default.

#### To temporarily become another user

1. While logged in as the root user, switch to the user “me”. Type:
    
    ```bash
    [root@localhost root]# su   me
    
    [me@localhost root]$
    ```
    
    The `su` command did not prompt you for the user me’s password because you are root

2. Change to me’s home directory.
    
    ```bash
    [me@localhost root]$ cd

    [me@localhost me]$ cd
    ```
    
3. While temporarily logged in as me, use `su` to login as the user ying. Type:
    
    ```bash
    [me@localhost me]$ su  ying
    password:
    [ying@localhost me]$
    ```
    
4. To logout of ying’s account type:
    
    ```bash
    [ying@localhost me]$ exit
    ```
    
    This will throw you back into me’s account.
    
5. Logout of me’s account to get back to the root account. What is the command?

#### To make `su` inherit all environmental variables of the new user

1. To force `su` to use all the environmental variables of the temporary user. Type:
    
    ```bash
    [root@system1 root]# su - me
    
    [me@system1 me]$
    ```
    
    The difference is immediately obvious. Notice the current working directory.
    
2. Logout of the system completely and reboot the machine.

3. All done with Lab 6!
