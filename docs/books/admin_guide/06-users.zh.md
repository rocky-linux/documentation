---
title: 用户管理
---

# 用户管理

在本章中您将学到如何管理用户。

****
**目标**: 在本章中，未来的 Linux 管理员将学习如何：

:heavy_check_mark: 添加、删除或修改 **用户组** ;   
； :heavy_check_mark: 添加、删除或修改 **用户** ;   
； :heavy_check_mark: 了解与用户和组相关的文件，并学习如何管理它们； :heavy_check_mark: 更改文件的*所有者*或*所属组*； :heavy_check_mark: *保护*用户的账号； :heavy_check_mark: 变更身份。

:checkered_flag: **用户**

**知识性**: :star:   
**复杂度**: :star: :star:

**阅读时间**: 30 分钟
****

## 常规信息

每个用户必须有一个组，该用户组称为用户的**主组**(primary group)。

多个用户可以属于同一个用户组。

主组以外的组称为用户的 **附加组**(supplementary groups) 。

!!! Note "说明"

    每个用户有一个主组，并且可以被添加到多个附加用户组中。

用户组和用户由其唯一的数字标识符 `UID` 和 `GID`来管理。

* `UID`：_用户识别符_ 。 唯一的用户ID。
* `GID`：_用户组标识符_。 唯一的用户组ID。

UID和GID都被内核识别，这意味着超级管理员不一定是 **root** 用户，只要**uid=0**的用户就是超级管理员。

与用户/用户组相关的文件有：

* /etc/passwd
* /etc/shadow
* /etc/group
* /etc/gshadow
* /etc/skel/
* /etc/default/useradd
* /etc/login.defs

!!! Danger "危险"

    你应该始终使用管理命令，而不是手动编辑文件。

## 用户组管理

修改文件添加行：

* `/etc/group`
* `/etc/gshadow`

### `groupadd` 命令

`groupadd`命令可以向系统中添加一个用户组
```
groupadd [-f] [-g GID] group
```

示例：

```
$ sudo groupadd -g 1012 GroupeB
```

| 选项       | 说明                                                                                  |
| -------- | ----------------------------------------------------------------------------------- |
| `-g GID` | 定义要创建组的 `GID` 。                                                                     |
| `-f`     | 如果选项`-g`中提供的GID已经存在，系统将指定一个新的`GID`。                                                 |
| `-r`     | 创建一个伪用户组，其 `GID` 介于 `SYS_GID_MIN` 和 `SYS_GID_MAX`之间。 这两个变量在 `/etc/login.defs` 中有定义。 |

用户组命名规则：

* 没有音标或特殊字符；
* 与现有用户或系统文件的名称不同。

!!! Note "说明"

    在 **Debian** 下，除非是针对所有 Linux 发行版的可移植脚本，管理员应该使用 `man` 中指定的 `addgroup` 和 `delgroup` 命令：

    ```
    $ man addgroup
    DESCRIPTION
    adduser and addgroup add users and groups to the system according to command line options and configuration information
    in /etc/adduser.conf. They are friendlier front ends to the low-level tools like useradd, groupadd and usermod programs,
    by default, choosing Debian policy conformant UID and GID values, creating a home directory with skeletal configuration,
    running a custom script, and other features.
    ```

### `groupmod`命令

`groupmod` 命令允许您修改系统中已有的用户组。

```
groupmod [-g GID] [-n nom] group
```

示例：

```
$ sudo groupmod -g 1016 GroupP
$ sudo groupmod -n GroupC GroupB
```

| 选项        | 说明            |
| --------- | ------------- |
| `-g GID`  | 赋予用户组新的`GID`。 |
| `-n name` | 更改为新的组名称。     |

你可以更改用户组名、 `GID` 或同时更改二者。

修改后，原本属于该用户组的文件将具有未知的`GID`。 这些文件必须重新分配新的`GID`。

```
$ sudo find / -gid 1002 -exec chgrp 1016 {} \;
```

### `groupdel` 命令

`groupdel`命令用于删除系统上已存在的用户组。

```
groupdel group
```

示例：

```
$ sudo groupdel GroupC
```

!!! Tip "提示"

    删除用户组时，可能会出现两种情况：

    * 如果用户具有唯一的主组且您在该用户组上发出`groupdel`命令时，系统将提示您该用户组下有特定用户，无法删除该用户组。
    * 如果一个用户属于附加组（而不是用户的主组），并且该组不是系统上该用户的主组，则`groupdel`命令删除该组时将不会出现任何其他提示。

    示例：

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

!!! Tip "提示"

    使用 `userdel -r` 命令删除用户时，相应的主组也会被删除。 主组名称通常与用户名相同。

!!! Tip "提示"

    每个组都有一个唯一的 `GID` ， 一个组可以被多个用户用作附加组。 根据惯例，超级管理员的 GID 是 0； 为某些服务或进程保留的 GID 为201~999，称为系统组或伪用户组； 用户的 GID 通常大于或等于1000。 这些都与 <font color=red>/etc/login.defs</font> 文件相关，我们将在后面讨论。

    ```bash
    # 已忽略注释行
    shell > cat  /etc/login.defs
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

!!! Tip "提示"

    由于用户必须是用户组的一部分，因此最好在添加用户之前创建用户组。 因此，一个组可能没有任何成员。

### `/etc/group` 文件

该文件包含用户组的信息(由 `:` 进行分割)。

```
$ sudo tail -1 /etc/group
GroupP:x:516:patrick
  (1)  (2)(3)   (4)
```

* 1：用户组组名；
* 2：用户组密码由 `x` 标识。 用户组密码存储在 `/etc/gshadow` 中。
* 3：GID；
* 4：用户组中的附加用户（排除唯一的主用户）；

!!! note "说明"

   `/etc/group` 文件中的每一行对应一个用户组。 主用户的信息存储在 `/etc/passwd` 中。

### `/etc/gshadow` 文件

此文件包含有关用户组的安全信息(由 `:` 进行分隔)。

```
$ sudo grep GroupA /etc/gshadow
GroupA:$6$2,9,v...SBn160:alain:rockstar
   (1)      (2)            (3)      (4)
```

* 1：用户组组名；
* 2：加密密码；
* 3：用户组管理员的名称；
* 4：用户组中的附加用户（排除唯一的主用户）；

!!! Wanning "警告"

    **/etc/group** 和 **/etc/gshadow** 中的组名必须一一对应，即 **/etc/group** 文件中的每一行在**/etc/gshadow** 文件中必须有对应的一行。

密码中的 `!` 表示它已锁定。 因此，任何用户都不能使用密码访问该用户组（因为用户组成员已经不需要密码）。

## 用户管理

### 定义

在`/etc/passwd`文件中，用户定义如下：

* 1：登录名；
* 2：密码标识，`x`标识用户有密码，加密密码存储在 `/etc/shadow` 的第二个字段中；
* 3：UID；
* 4：主组的GID；
* 5：注释；
* 6：主目录；
* 7：Shell (`/bin/bash`, `/bin/nologin`, ...)。

有三种类型的用户：

* **root（uid=0）**：系统管理员；
* **系统用户（uid是201~999的其中一个）**：用于系统管理应用程序的访问权限；
* **普通用户（uid>=1000）**：其他登录到系统的帐户。

修改文件添加行：

* `/etc/passwd`
* `/etc/shadow`

### `useradd` 命令

`useradd` 命令用于添加用户。

```
useradd [-u UID] [-g GID] [-d directory] [-s shell] login
```

示例：

```
$ sudo useradd -u 1000 -g 1013 -d /home/GroupC/carine carine
```

| 选项                  | 说明                                                   |
| ------------------- | ---------------------------------------------------- |
| `-u UID`            | 创建用户时的 `UID`。                                        |
| `-g GID`            | 主组的 `GID`。 此处的 `GID` 也可以是 `组名称`。                     |
| `-G GID1,[GID2]...` | 附加组的 `GID`。 此处的 `GID` 也可以是 `用户组名称`。 可以指定多个附加组，以逗号分隔。 |
| `-d directory`      | 主目录。                                                 |
| `-s shell`          | 指定用户的 shell。                                         |
| `-c COMMENT`        | 添加注释。                                                |
| `-U`                | 将用户添加到同时创建的同名组中。 如果未指定，则在创建用户时会创建具有相同名称的组。           |
| `-M`                | 不创建用户的主目录。                                           |
| `-r`                | 创建系统账户。                                              |

在创建时，帐户没有密码并被锁定。

必须分配密码才能解锁账户。

当使用没有任何选项的 `useradd` 命令时，将为新用户设置以下默认设置：

* 创建与用户名同名的主目录；
* 创建与用户名同名的主组；
* 为用户分配 `/bin/bash` 的默认 shell。
* 用户的 UID 和主组 GID 的值被自动推导出。 这通常是一个介于 1000~60000 之间的唯一值。

!!! note "说明"

    默认设置和值来自以下配置文件：
    
    `/etc/login.defs` 和 `/etc/default/useradd`

```bash
Shell > useradd test1

Shell > tail -n 1 /etc/passwd
test1:x:1000:1000::/home/test1:/bin/bash

Shell > tail -n 1 /etc/shadow
test1:!!:19253:0:99999:7
:::

Shell > tail -n 1 /etc/group ; tail -n 1 /etc/gshadow
test1:x:1000:
test1:!::
```

账户命名规则：

* 允许使用小写字母、数字和下划线，不接受其他特殊字符（如星号、百分号、全角符号）。
* 虽然您可以在 RockyLinux 中使用大写用户名，但我们不建议这样做；
* 不建议以数字和下划线开头，尽管您可以这样做;
* 与现有用户组或系统文件的名称不同；
* 用户名最多可以包含 32 个字符。

!!! Wanning "警告"

    除最后一个目录外，必须创建主目录树。

最后一个目录是由 `useradd` 命令创建的，该命令可以将 `/etc/skel` 中的文件复制到该目录中。

**用户除了属于其主组之外，还可以属于多个组。**

示例：

```
$ sudo useradd -u 1000 -g GroupA -G GroupP,GroupC albert
```

!!! Note "说明"

    在 **Debian** 下，您需要指定 `-m` 选项强制创建登录目录，或者在 `/etc/login.defs` 文件中设置 `CREATE_HOME` 变量。 在所有情况下，管理员都应该使用 `man` 中指定的 `adduser` 和 `deluser` 命令，但在可移植到所有 Linux 发行版的脚本中除外：

    ```
    $ man useradd
    DESCRIPTION
        **useradd** is a low level utility for adding users. On Debian, administrators should usually use **adduser(8)**
         instead.
    ```

#### 用户创建时的默认值。

修改文件 `/etc/default/useradd`。

```
useradd -D [-b directory] [-g group] [-s shell]
```

示例：

```
$ sudo useradd -D -g 1000 -b /home -s /bin/bash
```

| 选项             | 说明                 |
| -------------- | ------------------ |
| `-D`           | 设置用户创建时的默认值。       |
| `-b directory` | 设置默认的登录目录。         |
| `-g group`     | 设置默认用户主组。          |
| `-s shell`     | 设置默认 shell。        |
| `-f`           | 设置密码过期后在禁用账户之前的天数。 |
| `-e`           | 设置禁用账户的日期。         |

### `usermod` 命令

`usermod` 命令允许修改用户。

```
usermod [-u UID] [-g GID] [-d directory] [-m] login
```

示例：

```
$ sudo usermod -u 1044 carine
```

其选项与 `useradd` 命令相同。

| 选项              | 说明                                                                          |
| --------------- | --------------------------------------------------------------------------- |
| `-m`            | 与 `-d` 选项相关联。 将旧的登录目录的内容移动到新的目录。 如果旧的主目录不存在，则不会创建新的主目录；当新的主目录不存在时，将创建新的主目录。 |
| `-l login`      | 新的登录名。 修改登录名后，您还需要修改主目录的名称以与其匹配。                                            |
| `-e YYYY-MM-DD` | 账户到期日期。                                                                     |
| `-L`            | 永久锁定账号。 即将 `!` 添加在 `/etc/shadow` 密码字段的开头。                                   |
| `-U`            | 解锁账号。                                                                       |
| `-a`            | 追加用户的附加组，必须与 `-G` 选项一起使用。                                                   |
| `-G`            | 修改用户的附加组以覆盖以前的附加组。                                                          |

!!! Tip "提示"

    要进行修改，用户必须断开连接并且没有正在运行的进程。

更改标识符后，属于用户的文件具有未知的 `UID`。 必须为其重新分配新的 `UID`。

其中 `1000` 是旧 `UID`，`1044` 是新 UID。 示例如下：

```
$ sudo find / -uid 1000 -exec chown 1044: {} \;
```

锁定和解锁用户账号，示例如下：

```
Shell > usermod -L test1
Shell > grep test1 /etc/shadow
test1:!$6$n.hxglA.X5r7X0ex$qCXeTx.kQVmqsPLeuvIQnNidnSHvFiD7bQTxU7PLUCmBOcPNd5meqX6AEKSQvCLtbkdNCn.re2ixYxOeGWVFI0:19259:0:99999:7
:::

Shell > usermod -U test1
```

可以通过以下示例解释 `-aG` 选项和 `-G` 选项之间的区别：

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

### `userdel` 命令

`userdel` 命令允许您删除用户的账号。

```
$ sudo userdel -r carine
```

| 选项   | 说明                                    |
| ---- | ------------------------------------- |
| `-r` | 删除用户的主目录和 `/var/spool/mail/` 目录中的邮件文件 |

!!! Tip "提示"

    要删除用户，用户必须注销并且没有正在运行的进程。

`userdel`命令删除在`/etc/passwd`、`/ etc/shadow`、`/etc/group`和`/etc/gshadow`中的相应行。 如上所述，`userdel -r`还将删除用户相应的主组。

### `/etc/passwd` 文件

此文件包含用户信息(由 `:` 分隔)。

```
$ sudo head -1 /etc/passwd
root:x:0:0:root:/root:/bin/bash
(1)(2)(3)(4)(5)  (6)    (7)
```

* 1：登录名；
* 2：密码标识，`x`标识用户有密码，加密密码存储在 `/etc/shadow` 的第二个字段中；
* 3：UID；
* 4：主组的GID；
* 5：注释；
* 6：主目录；
* 7：Shell (`/bin/bash`, `/bin/nologin`, ...)。

### `/etc/shadow` 文件

此文件包含用户的安全信息(由 `:` 分隔)。
```
$ sudo tail -1 /etc/shadow
root:$6$...:15399:0:99999:7
:::
 (1)    (2)  (3) (4) (5) (6)(7,8,9)
```

* 1：登录名；
* 2：加密密码。 使用 SHA512 加密算法，该算法由 `/etc/login.defs` 的 `ENCRYPT_METHOD` 定义；
* 3：最后一次更改密码的时间，时间戳格式，以天为单位。 所谓的时间戳，是以1970年1月1日作为标准时间。 每过去一天，时间戳 +1。
* 4：密码的最小存活时间。 即两次修改密码之间的时间间隔（与第三个字段相关），以天为单位。  由 `/etc/login.defs` 的 `PASS_MIN_DAYS` 定义，默认为0，即第二次修改密码时没有限制。 但如果为5，则表示5天内不允许更改密码，5天后才能更改密码。
* 5：密码的最大存活时间。 即密码的有效期（与第三个字段有关）。 由 `/etc/login.defs` 的 `PASS_MAX_DAYS` 定义。
* 6：密码过期之前的警告天数（与第五个字段相关）。 默认为7天，由 `/etc/login.defs` 的 `PASS_WARN_AGE` 定义。
* 7：密码过期后的宽限期天数（与第五个字段相关）。
* 8：账号到期时间，时间戳格式，以天为单位。 **请注意，账号过期与密码过期不同。 如果账号过期，则不允许用户登录。 如果密码过期，则不允许用户使用其密码登录。**
* 9：保留以备将来使用。

!!! Danger "危险"

    对于 `/etc/passwd` 文件中的每一行， `/etc/shadow` 文件中都必须有对应的一行。

时间戳和日期转换请参考以下命令格式：

```bash
# 时间戳转换为日期，“17718” 表示需要填写的时间戳。
Shell > date -d "1970-01-01 17718 days" 

# 日期转换为时间戳，“2018-07-06”表示要填写的日期。
Shell > echo $(($(date --date="2018-07-06" +%s)/86400+1))
```

## 文件所有者

!!! Danger "危险"

    所有文件必须属于一个用户和一个用户组。

默认情况下，创建文件的用户的主组是拥有该文件的所属组。

### 修改命令

#### `chown` 命令

`chown` 命令允许您更改文件的所有者。
```
chown [-R] [-v] login[:group] file
```

示例：
```
$ sudo chown root myfile
$ sudo chown albert:GroupA myfile
```

| 选项   | 说明                  |
| ---- | ------------------- |
| `-R` | 递归更改目录及目录下所有文件的所有者。 |
| `-v` | 显示变更。               |

仅更改所有者用户：

```
$ sudo chown albert file
```

仅修改所属组：

```
$ sudo chown :GroupA file
```

更改所有者和所属组：

```
$ sudo chown albert:GroupA file
```

在以下示例中，分配的组将是指定的用户主组。

```
$ sudo chown albert: file
```

更改目录中所有文件的所有者和所属组

```
$ sudo chown -R albert:GroupA /dir1
```

### `chgrp` 命令

`chgrp` 命令允许您更改文件的所属组。

```
chgrp [-R] [-v] group file
```

示例：
```
$ sudo chgrp group1 file
```

| 选项   | 说明                   |
| ---- | -------------------- |
| `-R` | 递归地更改目录和目录下所有文件的所属组。 |
| `-v` | 显示变更。                |

!!! Note "说明"

    通过参考另一个文件的所有者和所有者组，可以向一个文件应用所有者和所属组：

```
chown [options] --reference=RRFILE FILE
```

例如：

```
chown --reference=/etc/groups /etc/passwd
```

## 访客管理

### `gpasswd` 命令

命令 `gpasswd` 允许管理用户组。

```
gpasswd [option] group
```

示例：

```
$ sudo gpasswd -A alain GroupA
[alain]$ gpasswd -a patrick GroupA
```

| 选项            | 说明                         |
| ------------- | -------------------------- |
| `-a USER`     | 将用户添加到组。 对于添加的用户来说，此组为附加组。 |
| `-A USER,...` | 设置管理员用户列表。                 |
| `-d USER`     | 从组中删除用户。                   |
| `-M USER,...` | 设置组成员列表。                   |

命令 `gpasswd -M` 用作修改，而不是添加。

```
# gpasswd GroupeA
New Password:
Re-enter new password:
```

!!! note "说明"

    除了使用 `gpasswd -a` 将用户添加到组之外，您还可以使用前面提到的 `usermod -G` 或 `usermod -AG` 。

### `id` 命令

`id` 命令用来显示用户的组名。

```
id USER
```

示例：

```
$ sudo id alain
uid=1000(alain) gid=1000(GroupA) groupes=1000(GroupA),1016(GroupP)
```

### `newgrp` 命令

`newgrp` 命令可以从用户的附加组中选择一个组作为用户的新 **临时** 主组。 `newgrp` 命令在每次切换用户的主组时，都会有一个新的 **child shell**(子进程)。 小心！ **child shell** 和 **sub shell** 是不同的。

```
newgrp [secondarygroups]
```

示例：

```
Shell > useradd test1
Shell > passwd test1
Shell > groupadd groupA ; groupadd groupB 
Shell > usermod -G groupA,groupB test1
Shell > id test1
uid=1000(test1) gid=1000(test1) groups=1000(test1),1001(groupA),1002(groupB)
Shell > echo $SHLVL ; echo $BASH_SUBSHELL
1
0

Shell > su - test1
Shell > touch a.txt
Shell > ll
-rw-rw-r-- 1 test1 test1 0 10月  7 14:02 a.txt
Shell > echo $SHLVL ; echo $BASH_SUBSHELL
1
0

# 生成新的 child shell
Shell > newgrp groupA
Shell > touch b.txt
Shell > ll
-rw-rw-r-- 1 test1 test1  0 10月  7 14:02 a.txt
-rw-r--r-- 1 test1 groupA 0 10月  7 14:02 b.txt
Shell > echo $SHLVL ; echo $BASH_SUBSHELL
2
0

# 你可以使用 `exit` 命令退出 child shell
Shell > exit
Shell > logout
Shell > whoami
root
```

## 安全

### `passwd` 命令

`passwd` 命令用于管理密码。

```
passwd [-d] [-l] [-S] [-u] [login]
```

示例：

```
Shell > passwd -l albert
Shell > passwd -n 60 -x 90 -w 80 -i 10 patrick
```

| 选项        | 说明                                        |
| --------- | ----------------------------------------- |
| `-d`      | 永久删除密码。 仅对于root用户(uid=0)使用。               |
| `-l`      | 永久锁定用户帐号。 仅对于root用户(uid=0)使用。             |
| `-S`      | 显示账号状态。 仅对于root用户(uid=0)使用。               |
| `-u`      | 永久解锁用户账号。 仅对于root用户(uid=0)使用。             |
| `-e`      | 使密码永久过期。 仅对于root用户(uid=0)使用。              |
| `-n DAYS` | 定义密码的最小存活时间。 永久性的更改。 仅对于root用户(uid=0)使用。  |
| `-x DAYS` | 定义密码的最大存活时间。 永久性的更改。 仅对于root用户(uid=0)使用。  |
| `-w DAYS` | 定义密码到期前的警告时间。 永久性的更改。 仅对于root用户(uid=0)使用。 |
| `-i DAYS` | 定义密码过期时的推迟天数。 永久性的更改。 仅对于root用户(uid=0)使用。 |

使用`password -l`，即在 `/etc/shadow` 对应用户的密码字段的开头添加 "!!"。

示例：

* Alain更改自身的密码：

```
[alain]$ passwd
```

* root 更改 Alain 的密码

```
$ sudo passwd alain
```

!!! Note "说明"

    用户可以使用 `passwd` 命令更改密码（需请求旧密码）。 管理员可以不受限制地更改所有用户的密码。

他们必须遵守安全限制。

通过 shell 脚本管理用户账户时，在创建用户后设置默认密码可能很有用。

这可以通过将密码传递给 `passwd` 命令来完成。

示例：

```
$ sudo echo "azerty,1" | passwd --stdin philippe
```

!!! Wanning "警告"

    密码以明文形式输入，`passwd` 负责加密它。

### `chage` 命令

`chage` 命令用来更改用户密码过期信息。

```
chage [-d date] [-E date] [-I days] [-l] [-m days] [-M days] [-W days] [login]
```

示例：

```
$ sudo chage -m 60 -M 90 -W 80 -I 10 alain
```

| 选项               | 说明                                                  |
| ---------------- | --------------------------------------------------- |
| `-I DAYS`        | 定义密码过期前往后推迟的天数。 永久性的更改。                             |
| `-l`             | 显示策略详细信息。                                           |
| `-m DAYS`        | 定义密码的最小存活时间。 永久性的更改。                                |
| `-M DAYS`        | 定义密码的最大存活时间。 永久性的更改。                                |
| `-d LAST_DAY`    | 定义最后一次密码更改的时间。 您可以使用天的时间戳样式或 YYYY-MM-DD 样式。 永久性的更改。 |
| `-E EXPIRE_DATE` | 定义账号到期日期。 您可以使用天的时间戳样式或 YYYY-MM-DD 样式。 永久性的更改。      |
| `-W WARN_DAYS`   | 定义密码到期前的警告时间。 永久性的更改。                               |

示例：

```
# `chage` 命令还提供交互模式。
$ sudo chage philippe

# `-d` 选项强制在登录时更改密码。
$ sudo chage -d 0 philippe
```

![使用 chage 进行用户账号管理](images/chage-timeline.png)

## 高级管理

配置文件：

* `/etc/default/useradd`
* `/etc/login.defs`
* `/etc/skel`

!!! Note "说明"

    使用 `useradd` 命令编辑 `/etc/default/useradd` 文件。
    
    其他文件将通过文本编辑器进行修改。

### `/etc/default/useradd` 文件

此文件包含默认数据设置。

!!! Tip "提示"

    在创建用户时，如果没有指定选项，系统将使用 `/etc/default/useradd` 中定义的默认值。

此文件由命令 `useradd -D` 修改 (`useradd -D` 在没有任何其他选项的情况下输入会显示 `/etc/default/useradd` 文件的内容)。

```
Shell > grep -v ^# /etc/default/useradd 
GROUP=100
HOME=/home
INACTIVE=-1
EXPIRE=
SHELL=/bin/bash
SKEL=/etc/skel
CREATE_MAIL_SPOOL=yes
```

| 参数                  | 说明                                                        |
| ------------------- | --------------------------------------------------------- |
| `GROUP`             | 定义默认主组GID。                                                |
| `HOME`              | 定义普通用户主目录的上级目录路径。                                         |
| `INACTIVE`          | 密码过期后的宽限天数。 对应于 `/etc/shadow` 文件的第7个字段。 `-1` 值表示关闭了宽限期功能。 |
| `EXPIRE`            | 定义账号到期日期。 对应于 `/etc/shadow` 文件的第8个字段。                     |
| `SHELL`             | 定义命令解释器。                                                  |
| `SKEL`              | 定义登录目录的框架目录。                                              |
| `CREATE_MAIL_SPOOL` | 在 `/var/spool/mail` 中定义创建邮箱。                              |

如果在创建用户时不需要同名的主组，可以执行以下操作：

```
Shell > useradd -N test2
Shell > id test2
uid=1001(test2) gid=100(users) groups=100(users)
```

### `/etc/login.defs` 文件

```bash
# 已忽略注释行
shell > cat  /etc/login.defs
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

`UMASK 022`：表示创建文件的权限为755(rwxr-xr-x)。 但出于安全性考虑，GNU/Linux 对新创建的文件没有 **x** 权限，这一限制适用于 root用户(uid=0) 和 普通用户(uid>=1000) 。 例如：

```
Shell > touch a.txt
Shell > ll
-rw-r--r-- 1 root root     0 Oct  8 13:00 a.txt
```

`HOME_MODE 0700`：普通用户主目录的权限。 不适用于 root 用户的主目录。

```
Shell > ll -d /root
dr-xr-x---. 10 root root 4096 Oct  8 13:12 /root

Shell > ls -ld /home/test1/
drwx------ 2 test1 test1 4096 Oct  8 13:10 /home/test1/
```

`USERGROUPS_ENAB yes`："使用 `userdel -r` 命令删除用户时，相应的主组也会被删除。" 为什么？ 这就是原因。

### `/etc/skel` 目录

当创建用户时，它们的主目录和环境文件也将被创建。 您可以将 `/etc/skel/` 目录中的文件视为创建用户所需的文件模板。

这些文件自动从 `/etc/skel` 目录中复制。

* `.bash_logout`
* `.bash_profile`
* `.bashrc`

放置在此目录中的所有文件和目录在创建时都将复制到用户树中。

## 身份更改

### `su` 命令

`su` 命令允许您变更连接用户的身份。

```
su [-] [-c command] [login]
```

示例：

```
$ sudo su - alain
[albert]$ su - root -c "passwd alain"
```

| 选项           | 说明         |
| ------------ | ---------- |
| `-`          | 加载用户的完整环境。 |
| `-c` command | 以用户身份执行命令。 |

如果未指定 login, 它将是 `root`。

标准用户必须输入新身份的密码。

!!! Tip "提示"

    You can use the `exit`/`logout` command to exit users who have been switched. 需要注意的是，切换用户后，没有新的 `child shell` 或 `sub shell`，例如：

    ```
    Shell > whoami
    root
    Shell > echo $SHLVL ; echo $BASH_SUBSHELL
    1
    0

    Shell > su - test1
    Shell > echo $SHLVL ; echo $BASH_SUBSHELL
    1
    0
    ```

请注意！ `su` 和 `su -` 是不同的，如以下示例所示：

```
Shell > whoami
test1
Shell > su root
Shell > pwd
/home/test1

Shell > env
...
USER=test1
PWD=/home/test1
HOME=/root
MAIL=/var/spool/mail/test1
LOGNAME=test1
...
```

```
Shell > whoami
test1
Shell > su - root
Shell > pwd
/root

Shell > env
...
USER=root
PWD=/root
HOME=/root
MAIL=/var/spool/mail/root
LOGNAME=root
...
```

因此，当您想要切换用户时，请记住不要丢失 `-`。 由于未加载必要的环境变量文件，因此运行某些程序可能会出现问题。
