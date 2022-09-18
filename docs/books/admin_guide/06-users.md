---
title: User Management
---

# User Management

In this chapter you will learn how to manage user.

****
**Objectives** : In this chapter, future Linux administrators will learn how to:

:heavy_check_mark: add, delete or modify a **group** ;
:heavy_check_mark: add, delete or modify a **user** ;
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

A group other than the primary group is called the user's **supplementary groups**.

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
    in /etc/adduser.conf. They are friendlier front ends to the low level tools like useradd, groupadd and usermod programs,
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
    * If a user belongs to a suplementary group (not the primary group for the user) and that group is not the primary group for antoher user on the system, then the `groupdel` command will delete the group without any additional prompts.
    
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

    When you delete a user using the `userdel -r` command, the corresponding primary group is also deleted. The primary group name is usually the same as the user name.

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

A `!` in the password indicates that it is locked.
Thus no user can use the password to access the group (since group members do not need it).

## User management

### Definition

A user is defined as follows in the `/etc/passwd` file:

* 1: Login name;
* 2: Password identification, `x` indicates that the user has a password;
* 3: UID;
* 4: GID of the primary group;
* 5: Comments;
* 6: Home directory;
* 7: Shell (`/bin/bash`, `/bin/nologin`, ...).

There are three types of users:

* **root(uid=0)**: the system administrator ;
* **system users(uid is one of the 201~999)**:	Used by the system to manage application access rights ;
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
|`-G GID1,[GID2]...`       |	`GID` of the primary group. The `GID` here can also be a `group name`. Multiple supplementary groups can be specified, separated by commas. |
|`-d directory` |	Home directory.                                                    |
|`-s shell`     | Shell.                                                             |
|`-c COMMENT`           | Add a comment.                                                     |
|`-U`           | Adds the user to a group with the same name created simultaneously. If this option is not written by default, a group with the same name will be created when the user is created. |
|`-M`           | Do not create the user's home directory.                          |
|`-r`           | Create a system account. |

At creation, the account has no password and is locked.

A password must be assigned to unlock the account.

Account naming rules:

* No accents, capital letters or special characters;
* Different from the name of an existing group or system file;
* Set the options `-u`, `-g`, `-d` and `-s` at creation.

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
        **useradd** is a low level utility for adding users. On Debian, administrators should usually use **adduser(8)**
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
|`-m`            | Associated with the `-d` option, moves the contents of the old login directory to the new one.|
|`-l login`      | New name.                                                                                     |
|`-e AAAA-MM-JJ` | Account expiration date.                                                                      |
|`-L`            | Locks the account.                                                                            |
|`-U`            | Unlocks the account.                                                                          |
|`-a`            | Prevents the user from being deleted from a subgroup when added to another subgroup.          |
|`-G`            | Specifies multiple subgroups when adding.                                                     |

With the `usermod` command, locking an account results in the addition of `!` before the password in the `/etc/shadow` file.

!!! Tip

    To be modified, a user must be disconnected and have no running processes.

After changing the identifier, the files belonging to the user have an unknown `UID`. It must be reassigned the new `UID`.

```
$ sudo find / -uid 1000 -exec chown 1044: {} \;
```

Where `1000` is the old `UID` and `1044` is the new one.

It is possible to invite a user into one or more subgroups with the options *-a* and *-G*.

Example:

```
$ sudo usermod -aG GroupP,GroupC albert
```

The `usermod` command acts as a modification and not as an addition.

For a user invited to a group by this command and already positioned as a guest in other supplementary groups, it will be necessary to indicate in the group management command all the groups to which he belongs otherwise he will disappear from them.

The *-a* option changes this behavior.

Examples:

* Invite `albert` in the group `GroupP`.

```
$ sudo usermod -G GroupP albert
```

* Invites `albert` into the `GroupG` group, but removes him from the `GroupP` guest list.

```
$ sudo usermod -G GroupG albert
```

* So either :

```
$ sudo usermod -G GroupP,GroupG albert
```

* Or :

```
$ sudo usermod -aG GroupG albert
```

### `userdel` command

The `userdel` command allows you to delete a user's account.

```
$ sudo userdel -r carine
```

| Option |	Description                                              |
| -------| --------------------------------------------------------- |
| `-r`   | Deletes the connection directory and the contained files. |

!!! Tip

    To be deleted, a user must be logged out and have no running processes.

`userdel` removes the user's line from the `/etc/passwd` and `/etc/gshadow` files.

### `/etc/passwd` file

This file contains user information (separated by `:`).

```
$ sudo head -1 /etc/passwd
root:x:0:0:root:/root:/bin/bash
(1)(2)(3)(4)(5)  (6)    (7)
```

* 1: Login.   
* 2: Password (`x` if defined in `/etc/shadow`).   
* 3: UID.   
* 4: GID of the primary group.   
* 5: Comment.   
* 6: Home directory.   
* 7: Shell.

### `/etc/shadow` file

This file contains the users' security information (separated by `:`).
```
$ sudo tail -1 /etc/shadow
root:$6$...:15399:0:99999:7:::
 (1)    (2)  (3) (4) (5) (6)(7,8,9)
```

* 1: Login.   
* 2: Encrypted password.   
* 3: Date of last change.   
* 4: Minimum lifetime of the password.   
* 5: Maximum lifetime of the password.   
* 6: Number of days before warning.   
* 7: Time to deactivate account after expiration.   
* 8: Account expiration time.   
* 9: Reserved for future use.   

!!! Danger

    For each line in the `/etc/passwd` file there must be a corresponding line in the `/etc/shadow` file.

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
| `-R`   |	Changes the owners of the directory and its contents. |
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
| `-R`   | Modifies the owner groups of the directory and its contents (recursion). |
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
gpasswd [-a login] [-A login] [-d login] [-M login] group
```

Examples:

```
$ sudo gpasswd -A alain GroupA
[alain]$ gpasswd -a patrick GroupA
```

| Option     |	Description                         |
| ---------- | ------------------------------------ |
| `-a login` |	Adds the user to the group.         |
| `-A login` |	Sets the group administrator.       |
| `-d login` |	Remove the user from the group.     |
| `-M login` |	Defines the complete list of guests.|

The command `gpasswd -M` acts as a modification, not an addition.
```
# gpasswd GroupeA
New Password :
Re-enter new password :
```

### `id` command

The `id` command displays the group names of a user.
```
id login
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

Using the command `usermod -U` command only removes one of the `!`. So the account remains locked.

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
* Passwords ;
* UID and GID ;
* Umask ;
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
