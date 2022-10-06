---
title: User Management
---

# User Management

In this chapter you will learn how to manage users.

****
**Objectives**: In this chapter, future Linux administrators will learn how to:

:heavy_check_mark: add, delete or modify a **group**;
:heavy_check_mark: add, delete or modify a **user**;
:heavy_check_mark: Understand the files associated with users and groups and learn how to manage them;
:heavy_check_mark: change the *owner* or the *group owner* of a file;
:heavy_check_mark: *secure* user accounts;
:heavy_check_mark: change identity.

:checkered_flag: **users**

**Knowledge**: :star: :star:   
**Complexity**: :star: :star:

**Reading time**: 30 minutes
****

## General

Each user must have a group, which is called the user's **primary group**.

Several users can be part of the same group.

Groups other than the primary group are called the user's **supplementary groups**.

!!! Note

    Each user has a primary group and can be invited into one or more supplementary groups.

Groups and users are managed by their unique numerical identifiers `GID` and `UID`.

* `UID`: _User IDentifier_. Unique user ID.
* `GID`: _Group IDentifier_. Unique group identifier.

Both UID and GID are recognized by the kernel, which means that the Super Admin is not necessarily the **root** user, as long as the **uid=0** user is the Super Admin.

The files related to users/groups are:

* /etc/passwd
* /etc/shadow
* /etc/group
* /etc/gshadow
* /etc/skel/
* /etc/default/useradd
* /etc/login.defs

!!! Danger

    You should always use the administration commands instead of manually editing the files.

## Group management

Modified files, added lines:

* `/etc/group`
* `/etc/gshadow`

### `groupadd` command

The `groupadd` command adds a group to the system.
```
groupadd [-f] [-g GID] group
```

Example:

```
$ sudo groupadd -g 1012 GroupeB
```

| Option  |	Description                   |
| --------| ----------------------------- |
|`-g GID` |	`GID` of the group to create. |
|`-f` |	The system chooses a `GID` if the one specified by the `-g` option already exists. |
|`-r` |	Creates a system group with a `GID` between `SYS_GID_MIN` and `SYS_GID_MAX`. These two variables are defined in `/etc/login.defs`. |

Group naming rules:

* No accents or special characters;
* Different from the name of an existing user or system files.

!!! Note

    Under **Debian**, the administrator should use, except in scripts intended to be portable to all Linux distributions, the `addgroup` and `delgroup` commands as specified in the `man`:

    ```
    $ man addgroup
    DESCRIPTION
    adduser and addgroup add users and groups to the system according to command line options and configuration information
    in /etc/adduser.conf. They are friendlier front ends to the low-level tools like useradd, groupadd and usermod programs,
    by default choosing Debian policy conformant UID and GID values, creating a home directory with skeletal configuration,
    running a custom script, and other features.
    ```

### Command `groupmod`

The `groupmod` command allows you to modify an existing group on the system.

```
groupmod [-g GID] [-n nom] group
```

Example:

```
$ sudo groupmod -g 1016 GroupP
$ sudo groupmod -n GroupC GroupB
```

|Option |	Description |
| ------| ----------- |
|`-g GID` |	New `GID` of the group to modify.
|`-n name` | New name.

It is possible to change the name of a group, its `GID` or both simultaneously.

After modification, the files belonging to the group have an unknown `GID`. They must be reassigned the new `GID`.

```
$ sudo find / -gid 1002 -exec chgrp 1016 {} \;
```

### `groupdel` command

The `groupdel` command is used to delete an existing group on the system.

```
groupdel group
```

Example:

```
$ sudo groupdel GroupC
```

!!! Tip

    When deleting a group, there are two conditions that can occur:
    
    * If a user has a unique primary group and you issue the `groupdel` command on that group, you will be prompted that there is a specific user under the group and it cannot be deleted.
    * If a user belongs to a supplementary group (not the primary group for the user) and that group is not the primary group for antoher user on the system, then the `groupdel` command will delete the group without any additional prompts.
    
    Examples: 
  
    ```bash
    Shell > useradd testa
    Shell > id testa
    uid=1000(testa) gid=1000(testa) group=1000(testa)
    Shell > groupdel testa
    groupdel: cannot remove the primary group of user 'testa'
    
    Shell > groupadd -g 1001 testb
    Shell > usermod -G testb root
    Shell > id root
    uid=0(root) gid=0(root) group=0(root),1001(testb)
    Shell > groupdel testb
    ```

!!! Tip

    When you delete a user using the `userdel -r` command, the corresponding primary group is also deleted. The primary group name is usually the same as the username.

!!! Tip

    Each group has a unique `GID`. A group can be used by multiple users as a supplementary group. By convention, The GID of super administrator is 0. The GIDS reserved for some services or processes are 201~999, which are called system groups or pseudo user groups. The GID for users is usually greater than or equal to 1000. These are related to <font color=red>/etc/login.defs</font>, which we will talk about later.

    ```bash
    shell > egrep -v "^#|^$" /etc/login.defs
    MAIL_DIR        /var/spool/mail
    UMASK           022
    HOME_MODE       0700
    PASS_MAX_DAYS   99999
    PASS_MIN_DAYS   0
    PASS_MIN_LEN    5
    PASS_WARN_AGE   7
    UID_MIN                  1000
    UID_MAX                 60000
    SYS_UID_MIN               201
    SYS_UID_MAX               999
    GID_MIN                  1000
    GID_MAX                 60000
    SYS_GID_MIN               201
    SYS_GID_MAX               999
    CREATE_HOME     yes
    USERGROUPS_ENAB yes
    ENCRYPT_METHOD SHA512
    ```

!!! Tip

    Since a user is necessarily part of a group, it is best to create the groups before adding the users. Therefore, a group may not have any members.

### `/etc/group` file

This file contains the group information (separated by `:`).

```
$ sudo tail -1 /etc/group
GroupP:x:516:patrick
  (1)  (2)(3)   (4)
```

* 1: Name of the group.
* 2: The group password is identified by `x`. The group password is stored in `/etc/gshadow`.
* 3: GID.
* 4: Supplementary users in the group (excluding the unique primary user).

!!! Note

   Each line in the `/etc/group` file corresponds to a group. The primary user info is stored in `/etc/passwd`.

### `/etc/gshadow` file

This file contains the security information about the groups (separated by `:`).

```
$ sudo grep GroupA /etc/gshadow
GroupA:$6$2,9,v...SBn160:alain:rockstar
   (1)      (2)            (3)      (4)
```

* 1: Name of the group.
* 2: Encrypted password.
* 3: Name of the group administrator.
* 4: Supplementary users in the group (excluding the unique primary user).

!!! Warning

    The name of the group in **/etc/group** and **/etc/gshadow** must correspond one by one, that is, each line in the **/etc/group** file must have a corresponding line in the **/etc/gshadow** file.

An `!` in the password indicates that it is locked.
Thus, no user can use the password to access the group (since group members do not need it).

## User management

### Definition

A user is defined as follows in the `/etc/passwd` file:

* 1: Login name;
* 2: Password identification, `x` indicates that the user has a password, the encrypted password is stored in the second field of `/etc/shadow`;
* 3: UID;
* 4: GID of the primary group;
* 5: Comments;
* 6: Home directory;
* 7: Shell (`/bin/bash`, `/bin/nologin`, ...).

There are three types of users:

* **root(uid=0)**: the system administrator;
* **system users(uid is one of the 201~999)**:	Used by the system to manage application access rights;
* **regular user(uid>=1000)**:	Other account to log in to the system.

Modified files, added lines:

* `/etc/passwd`
* `/etc/shadow`

### `useradd` command

The `useradd` command is used to add a user.

```
useradd [-u UID] [-g GID] [-d directory] [-s shell] login
```

Example:

```
$ sudo useradd -u 1000 -g 1013 -d /home/GroupC/carine carine
```

| Option        |	Description                                                        |
| --------------| ------------------------------------------------------------------ |
|`-u UID`       |	`UID` of the user to create.                                       |
|`-g GID`       |	`GID` of the primary group. The `GID` here can also be a `group name`.                                          |
|`-G GID1,[GID2]...`       |	`GID` of the supplementary groups. The `GID` here can also be a `group name`. Multiple supplementary groups can be specified, separated by commas. |
|`-d directory` |	Home directory.                                                    |
|`-s shell`     | Shell.                                                             |
|`-c COMMENT`           | Add a comment.                                                     |
|`-U`           | Adds the user to a group with the same name created simultaneously. If this option is not written by default, a group with the same name will be created when the user is created. |
|`-M`           | Do not create the user's home directory.                          |
|`-r`           | Create a system account. |

At creation, the account has no password and is locked.

A password must be assigned to unlock the account.

When the `useradd` command does not have any options, it appears:

* Create a home directory with the same name; 
* Create a primary group with the same name;
* The default shell is bash;
* The user's `uid` and primary group `gid` are automatically recorded from 1000, and usually uid and gid are the same.

```bash
Shell > useradd test1

Shell > tail -n 1 /etc/passwd
test1:x:1000:1000::/home/test1:/bin/bash

Shell > tail -n 1 /etc/shadow
test1:!!:19253:0:99999:7:::

Shell > tail -n 1 /etc/group ; tail -n 1 /etc/gshadow
test1:x:1000:
test1:!::
```

Account naming rules:

* No accents, capital letters or special characters;
* Different from the name of an existing group or system file;
* Optional: set the options `-u`, `-g`, `-d` and `-s` at creation.

!!! Warning

    The home directory tree must be created except for the last directory.

The last directory is created by the `useradd` command, which takes the opportunity to copy the files from `/etc/skel` into it.

**A user can belong to several groups in addition to their primary group.**

Example:

```
$ sudo useradd -u 1000 -g GroupA -G GroupP,GroupC albert
```

!!! Note

    Under **Debian**, you will have to specify the `-m` option to force the creation of the login directory or set the `CREATE_HOME` variable in the `/etc/login.defs` file. In all cases, the administrator should use the `adduser` and `deluser` commands as specified in the `man`, except in scripts intended to be portable to all Linux distributions:

    ```
    $ man useradd
    DESCRIPTION
        **useradd** is a low-level utility for adding users. On Debian, administrators should usually use **adduser(8)**
         instead.
    ```

#### Default value for user creation.

Modification of the file `/etc/default/useradd`.

```
useradd -D [-b directory] [-g group] [-s shell]
```

Example:

```
$ sudo useradd -D -g 1000 -b /home -s /bin/bash
```

| Option         | 	Description                                                                 |
| -------------- | ---------------------------------------------------------------------------- |
| `-D`           | Sets the default values for user creation.                                   |
| `-b directory` | Sets the default login directory.                                            |
| `-g group`     | Sets the default group.                                                      |
| `-s shell`     | Sets the default shell.                                                      |
| `-f`           | The number of days after the password expires before the account is disabled.|
| `-e`           | The date the account will be disabled.                                       |

### `usermod` command

The `usermod` command allows to modify a user.

```
usermod [-u UID] [-g GID] [-d directory] [-m] login
```

Example:

```
$ sudo usermod -u 1044 carine
```

Options identical to the `useradd` command.

| Option         |	Description                                                                                  |
| -------------- | --------------------------------------------------------------------------------------------- |
|`-m`            | Associated with the `-d` option, moves the contents of the old login directory to the new one.If the old home directory does not exist, a new home directory will not be created; If the new home directory does not exist, it is created.|
|`-l login`      | New login name. After you modify the login name, you also need to modify the name of the home directory to match it.     |
|`-e YYYY-MM-DD` | Account expiration date.                                                                      |
|`-L`            | Permanently lock account. That is, an `!` is added at the beginning of the `/etc/shadow` password field     |
|`-U`            | Unlocks the account.                                                                          |
|`-a`            | Append the user's supplementary groups, which must be used together with the `-G` option.         |
|`-G`            | Modify the user's supplementary groups to overwrite the previous supplementary groups.        |

!!! Tip

    To be modified, a user must be disconnected and have no running processes.

After changing the identifier, the files belonging to the user have an unknown `UID`. It must be reassigned to the new `UID`. 

Where `1000` is the old `UID` and `1044` is the new one. Examples are as follows:

```
$ sudo find / -uid 1000 -exec chown 1044: {} \;
```

Locking and unlocking of user account, Examples are as follows:

```
Shell > usermod -L test1
Shell > grep test1 /etc/shadow
test1:!$6$n.hxglA.X5r7X0ex$qCXeTx.kQVmqsPLeuvIQnNidnSHvFiD7bQTxU7PLUCmBOcPNd5meqX6AEKSQvCLtbkdNCn.re2ixYxOeGWVFI0:19259:0:99999:7:::

Shell > usermod -U test1
```

The difference between the `-aG` option and the `-G` option can be explained by the following example:

```bash
Shell > useradd test1
Shell > passwd test1
Shell > groupadd groupA ; groupadd groupB ; groupadd groupC ; groupadd groupD
Shell > id test1
uid=1000(test1) gid=1000(test1) groups=1000(test1)

Shell > gpasswd -a test1 groupA
Shell > id test1
uid=1000(test1) gid=1000(test1) groups=1000(test1),1002(groupA)

Shell > usermod -G groupB,groupC test1
Shell > id test1 
uid=1000(test1) gid=1000(test1) gorups=1000(test1),1003(groupB),1004(groupC)

Shell > usermod -aG groupD test1
uid=1000(test1) gid=1000(test1) groups=1000(test1),1003(groupB),1004(groupC),1005(groupD)
```

### `userdel` command

The `userdel` command allows you to delete a user's account.

```
$ sudo userdel -r carine
```

| Option |	Description                                              |
| -------| --------------------------------------------------------- |
| `-r`   | Delete the user's home directory and mail files located in the `/var/spool/mail/` directory |

!!! Tip

    To be deleted, a user must be logged out and have no running processes.

The `userdel` command removes the corresponding lines in `/etc/passwd`, `/ etc/shadow`, `/etc/group`, `/etc/gshadow`. As mentioned above, `userdel -r` will also delete the corresponding primary group of the user. 

### `/etc/passwd` file

This file contains user information (separated by `:`).

```
$ sudo head -1 /etc/passwd
root:x:0:0:root:/root:/bin/bash
(1)(2)(3)(4)(5)  (6)    (7)
```

* 1: Login name;
* 2: Password identification, `x` indicates that the user has a password, the encrypted password is stored in the second field of `/etc/shadow`;
* 3: UID;
* 4: GID of the primary group;
* 5: Comments;
* 6: Home directory;
* 7: Shell (`/bin/bash`, `/bin/nologin`, ...).

### `/etc/shadow` file

This file contains the users' security information (separated by `:`).
```
$ sudo tail -1 /etc/shadow
root:$6$...:15399:0:99999:7:::
 (1)    (2)  (3) (4) (5) (6)(7,8,9)
```

* 1: Login name.   
* 2: Encrypted password. Uses the SHA512 encryption algorithm, defined by the `ENCRYPT_METHOD` of `/etc/login.defs`.
* 3: The time when the password was last changed, the timestamp format, in days. The so-called timestamp is based on January 1, 1970 as the standard time. Every time one day goes by, the timestamp is +1. 
* 4: Minimum lifetime of the password. That is, The time interval between two password changes (related to the third field), in days.  Defined by the `PASS_MIN_DAYS` of `/etc/login.defs`, the default is 0, that is, when you change the password for the second time, there is no restriction. However, if it is 5, it means that it is not allowed to change the password within 5 days, and only after 5 days.  
* 5: Maximum lifetime of the password. That is, the validity period of the password (related to the third field). Defined by the `PASS_MAX_DAYS` of `/etc/login.defs`.
* 6: The number of warning days before the password expires (related to the fifth field). The default is 7 days, defined by the `PASS_WARN_AGE` of `/etc/login.defs`.
* 7: Number of days of grace after password expiration (related to the fifth field).  
* 8: Account expiration time, the timestamp format, in days. **Note that an account expiration differs from a password expiration. In case of an account expiration, the user shall not be allowed to login. In case of a password expiration, the user is not allowed to login using her password.**
* 9: Reserved for future use.   

!!! Danger

    For each line in the `/etc/passwd` file there must be a corresponding line in the `/etc/shadow` file.

For time stamp and date conversion, please refer to the following command format:

```bash
# The timestamp is converted to a date, "17718" indicates the timestamp to be filled in.
Shell > date -d "1970-01-01 17718 days" 

# The date is converted to a timestamp, "2018-07-06" indicates the date to be filled in.
Shell > echo $(($(date --date="2018-07-06" +%s)/86400+1))
```

## File owners

!!! Danger

    All files necessarily belong to one user and one group.

The primary group of the user creating the file is, by default, the group that owns the file.

### Modification commands

#### `chown` command

The `chown` command allows you to change the owners of a file.
```
chown [-R] [-v] login[:group] file
```

Examples:
```
$ sudo chown root myfile
$ sudo chown albert:GroupA myfile
```

| Option |	Description                                           |
| ------ | ------------------------------------------------------ |
| `-R`   |	Recursively changes the owners of the directory and all files under the directory.|
| `-v`   |	Displays the executed changes.                        |

To change only the owner user:

```
$ sudo chown albert file
```

To modify only the owner group:

```
$ sudo chown :GroupA file
```

Changing the user and owner group:

```
$ sudo chown albert:GroupA file
```

In the following example the group assigned will be the primary group of the specified user.

```
$ sudo chown albert: file
```

Change the owner and group of all files in a directory

```
$ sudo chown -R albert:GroupA /dir1
```

### `chgrp` command

The `chgrp` command allows you to change the owner group of a file.

```
chgrp [-R] [-v] group file
```

Example:
```
$ sudo chgrp group1 file
```

| Option | Description                                                              |
| ------ | ------------------------------------------------------------------------ |
| `-R`   | Recursively changes the groups of the directory and all files under the directory. |
| `-v`   | Displays the executed changes.                                           |

!!! Note

    It is possible to apply to a file an owner and an owner group by taking as reference those of another file:

```
chown [options] --reference=RRFILE FILE
```

For example:

```
chown --reference=/etc/groups /etc/passwd
```

## Guest management

### `gpasswd` command

The command `gpasswd` allows to manage a group.

```
gpasswd [option] group
```

Examples:

```
$ sudo gpasswd -A alain GroupA
[alain]$ gpasswd -a patrick GroupA
```

| Option        |	Description                         |
| ----------    | ------------------------------------ |
| `-a USER`     | Adds the user to the group. For the added user, this group is a supplementary group. |
| `-A USER,...` | Set the list of administrative users.       |
| `-d USER`     | Remove the user from the group.     |
| `-M USER,...` | Set the list of group members.|

The command `gpasswd -M` acts as a modification, not an addition.

```
# gpasswd GroupeA
New Password:
Re-enter new password:
```

!!! note

    In addition to using `gpasswd -a` to add users to a group, you can also use the `usermod -G` or `usermod -AG` mentioned earlier.

### `id` command

The `id` command displays the group names of a user.

```
id USER
```

Example:

```
$ sudo id alain
uid=1000(alain) gid=1000(GroupA) groupes=1000(GroupA),1016(GroupP)
```

### `newgrp` command

The `newgrp` command allows you to temporarily use a secondary group for file creation.

```
newgrp [secondarygroups]
```

Example:

```
[alain]$ newgrp GroupB
```

!!! Note

    After using this command, the files will be created with the `GID` of its subgroup.

The command `newgrp` without parameters reassigns the primary group.

## Securing

### `passwd` command

The `passwd` command is used to manage a password.
```
passwd [-d] [-l] [-S] [-u] [login]
```
Examples:
```
$ sudo passwd -l albert
$ sudo passwd -n 60 -x 90 -w 80 -i 10 patrick
```

| Option | Description                                            |
| ------ | ------------------------------------------------------ |
| `-d` | Removes the password.                                    |
| `-l` | Locks the account.                                       |
| `-S` | Displays the account status.                             |
| `-u` | Unlocks the account.                                     |
| `-e` | Expires the password.                                    |
| `-n days` | Minimum password lifetime.                          |
| `-x days` | Maximum password lifetime.                          |
| `-w days` | Warning time before expiration.                     |
| `-i days` | Delay before deactivation when the password expires.|

With the `passwd` command, locking an account is accomplished by adding `!!` before the password in the `/etc/shadow` file.

Using the command `usermod -U` command only removes one of the `!`. So, the account remains locked.

Example:

* Alain changes his password:

```
[alain]$ passwd
```

* root changes Alain's password

```
$ sudo passwd alain
```

!!! Note

    The `passwd` command is available to users to change their password (the old password is requested). The administrator can change the passwords of all users without restriction.

They will have to comply with the security restrictions.

When managing user accounts by shell script, it may be useful to set a default password after creating the user.

This can be done by passing the password to the `passwd` command.

Example:

```
$ sudo echo "azerty,1" | passwd --stdin philippe
```

!!! Warning

    The password is entered in clear text, `passwd` takes care of encrypting it.

### `chage` command

The `chage` command is used to manage the account strategy.

```
chage [-d date] [-E date] [-I days] [-l] [-m days] [-M days] [-W days] [login]
```

Example:

```
$ sudo chage -m 60 -M 90 -W 80 -I 10 alain
```

| Option | Description                                    |
| ------ | ---------------------------------------------- |
| `-I days` | Delay before deactivation, password expired.|
| `-l`      | Displays the policy details.                |
| `-m days` | Minimum lifetime of the password.           |
| `-M days` | Maximum lifetime of the password.           |
| `-d AAAA-MM-JJ` | Last password change.                 |
| `-E AAAA-MM-JJ` | Account expiration date.              |
| `-W days` | Warning time before expiration.             |

The `chage` command also offers an interactive mode.

The `-d` option forces the password to be changed at login.

Examples:

```
$ sudo chage philippe
$ sudo chage -d 0 philippe
```

!!! Note

    If no user is specified, the order will concern the user who enters it.

![User account management with chage](images/chage-timeline.png)

## Advanced management

Configuration files:
* `/etc/default/useradd`
* `/etc/login.defs`
* `/etc/skel`

!!! Note

    Editing the `/etc/default/useradd` file is done with the `useradd` command.

    The other files are to be modified with a text editor.

### `/etc/default/useradd` file

This file contains the default data settings.

!!! Tip

    When creating a user, if the options are not specified, the system uses the default values defined in `/etc/default/useradd`.

This file is modified by the command `useradd -D` (`useradd -D` entered without any other option displays the contents of the `/etc/default/useradd` file).

| Value      | Comment                                                                  |
| ---------- | ------------------------------------------------------------------------ |
| `GROUP`    | Default group.                                                           |
| `HOME`     | Path where the login directory for the user's name will be created.      |
| `INACTIVE` | Number of days after the password expires before the account is disabled.|
| `EXPIRE`   | Account expiration date.                                                 |
| `SHELL`    | Command interpreter.                                                     |
| `SKEL`     | Skeleton directory of the login directory.                               |
| `CREATE_MAIL_SPOOL` |	Mailbox creation in `/var/spool/mail`.                          |

!!! Warning

    Without the `-g` option, the `useradd` command creates a group of the user's name name and places it there.

In order for the `useradd` command to retrieve the value of the `GROUP` field from the `/etc/default/useradd` file, you must specify the `-N` option.

Example:

```
$ sudo useradd -u 501 -N GroupeA
```

### `/etc/login.defs` file

This file contains many default parameters useful for creating or modifying users. This information is grouped by paragraph according to their use:

* Mailboxes;
* Passwords;
* UID and GID;
* Umask;
* Connections;
* Terminals.

### `/etc/skel` directory

When a user is created, their home directory and environment files are created.

These files are automatically copied from the `/etc/skel` directory.

* `.bash_logout`
* `.bash_profile`
* `.bashrc`

All files and directories placed in this directory will be copied to the user tree when they are created.

## Identity change

### `su` command

The `su` command allows you to change the identity of the connected user.

```
su [-] [-c command] [login]
```

Examples:

```
$ sudo su - alain
[albert]$ su -c "passwd alain"
```

| Option | Description                                           |
| ------ | ----------------------------------------------------- |
| `-` |	Loads the user's complete environment.                   |
| `-c` command |	Executes the command under the user's identity.|

If the login is not specified, it will be `root`.

Standard users will have to type the password for the new identity.

!!! Tip

    There are successive 'layers' created (a stack of `bash` environments). To switch from one user to another, you must first type the `exit` command to take back your identity and then the `su` command to take another identity.

#### Profile loading

`root` endorses the identity of the user `alain` with `su`:

```
...
/home/GroupA/alain/.bashrc
/etc/bashrc
...
```

`root` assumes the identity of the user `alain` with `su -`:

```
...
/home/GroupA/alain/.bash_profile
/home/GroupA/alain/.bashrc
/etc/bashrc
...
```

A user can temporarily (for another command or an entire session) assume the identity of another account.

If no user is specified, the command will be for `root` (`su -`).

It is necessary to know the password of the user whose identity is being endorsed unless it is `root` that is executing the command.

An administrator can thus work on a standard user account and use the rights of the `root` account only occasionally.
