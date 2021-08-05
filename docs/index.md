# 目录

你已经找到我们了! 欢迎来到Rocky Linux的文档中心；我们很高兴你在这里。我们有许多贡献者在添加内容，而且这些内容的缓存一直在增加。在这里你可以找到关于如何构建Rocky Linux本身的文件，以及关于对Rocky社区来说很重要的各种主题的文件。你问谁构成了这个社区？

事实上，你知道的。

现在，你所看到的是我们的指南索引，其中包括设置和使用Rocky Linux的具体方法。请看右边的分类来浏览我们的内容。在上面，你可以访问一本关于安装和设置Rocky的完整书籍，以及一些高级实验室，你可以通过它来进一步了解系统管理和更多。

你发现有什么遗漏吗？你是否发现了一个错误？你是否想知道如何创建一个属于你自己的文件，或者如何解决这里的问题？还记得我们说过，*你*是洛基社区吗？那么，这意味着*你*对我们很重要，我们希望你能加入我们，如果你愿意的话，并帮助使这个文档变得更好。如果你对此感兴趣，请到我们的[贡献指南](https://github.com/rocky-linux/documentation/blob/main/README.md)了解你如何能做到这一点!

## 操作系统的安装和设置
| Classic Rocky Installation | Rocky on Windows SubSystem For Linux (WSL) |
| --- |  --- |
| [Rocky 8 安装](guides/rocky-8-installation.md) | [Rocky & WSL (rinse method)](guides/rocky_to_wsl_howto.md) |
| [将CentOS 切换为Rocky Linux](guides/migrate2rocky.md) | [Rocky & WSL2 (virtualbox and docker)](guides/import_rocky_to_wsl_howto.md) |
| [在Rocky Linux上安装MATE](guides/mate_installation.md) |  |
| [在Rocky Linux上安装XFCE](guides/xfce_installation.md) |  |

## 开发和发布

Start Here | Sourcing SRPM | Rebranding | Building | Signing | Deployment
--- | --- | --- | --- | --- | ---
[Setup Development Environment](guides/development/package_dev_start.md) | [Rebranding HowTo](guides/development/package_debranding.md) | [Signing HowTo](guides/development/package_signing.md) <br /> [Build Troubleshooting](guides/development/package_build_troubleshooting.md)


## 安全

| Firewalls | Network Security | Cryptographic Security |
| --- | --- | --- |
|[IPTABLES](guides/enabling_iptables_firewall.md) | [Networking Configuration](guides/basic_network_configuration.md) | [SSH Keys](guides/ssh_public_private_keys.md) |
| | [SSL Keys](guides/ssl_keys_https.md) |
| | [Generating SSL Keys and LetsEncrypt](guides/generating_ssl_keys_lets_encrypt.md) |


## 服务

| Web Server | FTP | Content Management System | Database |
| --- | --- | --- | --- |
|[Hardened Apache Web server](guides/apache_hardened_webserver/index.md) | [VSFTPD](guides/secure_ftp_server_vsftpd.md) | [DokuWiki](guides/dokuwiki_server.md) | [MariaDB server](guides/database_mariadb-server.md) |
|[Enabling Website](guides/apache-sites-enabled.md) | | [Nextcloud](guides/cloud_server_using_nextcloud.md) |  |
|[ModSecurity](guides/apache_hardened_webserver/modsecurity.md) | | |
|[Ossec-Hids](guides/apache_hardened_webserver/ossec-hids.md) | | |
|[RkHunter](guides/apache_hardened_webserver/rkhunter.md) | |  |

## 系统维护和管理

| Data Security | System Management and Debugging | Managing Users and Groups |
| --- | --- | ---
| [Rsync over SSH](guides/rsync_ssh.md) | [Postfix](guides/postfix_reporting.md) |  |
| [RSnapshot](guides/rsnapshot_backup.md) | [Cron(tab)](guides/cron_jobs_howto.md) |  |
| [Lsyncd](guides/mirroring_lsyncd.md) | |
| [Bind](guides/private_dns_server_using_bind.md) |  |

## 虚拟化

| QEMU | KVM |
| --- | --- |
| | |

## 容器化

| LXC/LXD |
| --- |
| [Creating a full LXD Server](guides/lxd_server.md) |

## 教育/培训

| Administration | Security | General |
|----------------|----------|---------|
| [System Administration](books/admin_guide/00-toc.md) | [Security Labs](labs/security/index.md) | [Learning Ansible](books/learning_ansible/index.md)

## 系统自动化和维护

| Ansible           | Puppet | Salt | Chef |
|-------------------|--------|------|------|
| [VM Template Creation With Packer, Ansible deployment for Vmware](guides/templates-automation-packer-vsphere.md) |  |   |   |
