# Rocky Linux - SSH 公钥和私钥

## 准备工作

* 熟悉命令行操作。
* 安装有 *openssh* 的 Rocky Linux 服务器或工作站。
    * 从技术上讲，本文所述的过程在任何已安装 openssh 的 Linux 系统上都可以运行。
* 可选：熟悉 linux 文件和目录权限。

# 简介

SSH 是一种协议，通常用于通过命令行从一台计算机访问另一台计算机。使用 SSH，您可以在远程计算机和服务器上运行命令、发送文件，通常还可以从一个位置管理您所做的一切。

当您在多个位置使用多个 Rocky Linux 服务器时，或者只是想节省访问这些服务器的时间，则可以使用 SSH 公钥和私钥对。密钥对从根本上使登录远程计算机和运行命令变得更容易。

本文将指导您完成创建密钥，并设置服务器以易于访问。

### 生成密钥的过程

以下命令都是在 Rocky Linux 工作站的命令行中执行：

`ssh-keygen -t rsa`

将显示以下内容：

```
Generating public/private rsa key pair.
Enter file in which to save the key (/root/.ssh/id_rsa):
```

按 Enter 键表示保存在默认位置。接下来，系统将显示：

`Enter passphrase (empty for no passphrase):`

因此，只需按 Enter 键。最后，系统将要求您重新输入密码：

`Enter same passphrase again:`

最后再按一次 Enter 键。

现在，您的 .ssh 目录中应该有一个 RSA 类型的公钥和私钥对：

```
ls -a .ssh/
.  ..  id_rsa  id_rsa.pub
```

现在，需要将公钥（id_rsa.pub）发送到将要访问的每台计算机上。在执行此操作前，需要确保可以通过 SSH 连接到服务器。本示例将仅使用三台服务器。

您可以使用 DNS 名称或 IP 地址通过 SSH 访问它们，本示例将使用 DNS 名称。示例服务器是 Web、邮件和门户。对于每台服务器，尝试以 SSH 登入，并为每台计算机打开终端窗口：

`ssh -l root web.ourourdomain.com` 

假设顺利登录到三台计算机上，那么下一步就是将公钥发送到每个服务器：

`scp .ssh/id_rsa.pub root@web.ourourdomain.com:/root/` 

对每台计算机重复此步骤。

在每个打开的终端窗口中，输入以下命令，您应该看到 *id_rsa.pub*：

`ls -a | grep id_rsa.pub` 

如果正确，现在准备在每台服务器的 *.ssh* 目录中创建或添加 *authorized_keys* 文件。在每台服务器上，输入以下命令：

`ls -a .ssh` 

**重要！请务必仔细阅读以下内容。如果您不确定是否会破坏某些内容，那么在继续之前，请在每台计算机上创建 authorized_keys（如果存在）的备份副本。**

如果没有列出 *authorized_keys* 文件，那么通过在 _/root_ 目录中输入以下命令来创建它：

`cat id_rsa.pub > .ssh/authorized_keys`

如果 _authorized_keys_ 已存在，那么只需要将新的公钥附加到已存在的公钥上：

`cat id_rsa.pub >> .ssh/authorized_keys`

将密钥添加到 _authorized_keys_ 或创建的 _authorized_keys_ 文件后，请再次尝试从 Rocky Linux 工作站通过 SSH 连接到服务器。此时将没有提示您输入密码。

确认无需密码即可进行 SSH 登录后，请从每台计算机的 _/root_ 目录中删除 id_rsa.pub 文件。

`rm id_rsa.pub`

### 目录和 authorized_keys 安全

在每台目标计算机上，确保应用了以下权限：

`chmod 700 .ssh/`
`chmod 600 .ssh/authorized_keys`

