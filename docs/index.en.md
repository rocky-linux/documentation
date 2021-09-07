---
title: Table of Contents
---

# Table of Contents

You've found us! Welcome to the documentation hub for Rocky Linux; we're glad you're here. We have a number of contributors adding content, and that cache of content gets bigger all the time. Here you will find documents on how to build Rocky Linux itself, as well as documents on various subjects that are important to the Rocky community. Who makes up that community you ask?

Well actually, you do.

Right now, you're looking at an index of our guides, which cover specific ways to set up and use Rocky Linux. See the categories on the right to skim through what we have. Up top, you can access a complete book on installing and setting up Rocky, as well as some advanced labs you can work through to further your understanding of systems administration and more.

Did you find something missing? Did you find an error? Are you wondering how to create a document of your own or how to fix things here? Remember how we said that *you* were the Rocky community? Well, that means that *you* are important to us, and we want you to join us, if you like, and help make this documentation better. If you are interested in this, head over to our [Contribution Guide](https://github.com/rocky-linux/documentation/blob/main/README.md) to find out how you can do just that!

## OS Installation and Setup
| Classic Rocky Installation | Rocky on Windows SubSystem For Linux (WSL) |
| --- |  --- |
| [Rocky 8 Installation](guides/installation.md) | [Rocky & WSL (rinse method)](guides/rocky/rocky_to_wsl_howto.md) |
| [Convert CentOS (and Others) to Rocky Linux](guides/rocky/migrate2rocky.md) | [Rocky & WSL2 (virtualbox and docker)](guides/rocky/import_rocky_to_wsl_howto.md) |
| [Install MATE on Rocky Linux](guides/desktop/mate_installation.md) |  |
| [Install XFCE on Rocky Linux](guides/desktop/xfce_installation.md) |  |

## Development and Packaging

Start Here | Sourcing SRPM | Rebranding | Building | Signing | Deployment
--- | --- | --- | --- | --- | ---
[Setup Development Environment](guides/rocky/development/package_dev_start.md) | [Rebranding HowTo](guides/rocky/development/package_debranding.md) | [Signing HowTo](guides/rocky/development/package_signing.md) <br /> [Build Troubleshooting](guides/rocky/development/package_build_troubleshooting.md)


## Security

| Firewalls | Network Security | Cryptographic Security |
| --- | --- | --- |
|[IPTABLES](guides/security/enabling_iptables_firewall.md) | [Networking Configuration](guides/network/basic_network_configuration.md) | [SSH Keys](guides/security/ssh_public_private_keys.md) |
| | [SSL Keys](guides/security/ssl_keys_https.md) |
| | [Generating SSL Keys and LetsEncrypt](guides/security/generating_ssl_keys_lets_encrypt.md) |
| | [SELinux Introduction](guides/security/learning_selinux.md) |


## Daemons/Servers

| Web Server | FTP | Content Management System | Database |
| --- | --- | --- | --- |
|[Hardened Apache Web server](guides/web/apache_hardened_webserver/index.md) | [VSFTPD](guides/file_transfer/secure_ftp_server_vsftpd.md) | [DokuWiki](guides/cms/dokuwiki_server.md) | [MariaDB server](guides/database/database_mariadb-server.md) |
|[Enabling Website](guides/web/apache-sites-enabled.md) | | [Nextcloud](guides/cms/cloud_server_using_nextcloud.md) |  |
|[ModSecurity](guides/web/apache_hardened_webserver/modsecurity.md) | | |
|[Ossec-Hids](guides/web/apache_hardened_webserver/ossec-hids.md) | | |
|[RkHunter](guides/web/apache_hardened_webserver/rkhunter.md) | |  |

## System Maintenance and Administration

| Data Security | System Management and Debugging | Managing Users and Groups |
| --- | --- | ---
| [Rsync over SSH](guides/backup/rsync_ssh.md) | [Postfix](guides/email/postfix_reporting.md) |  |
| [RSnapshot](guides/backup/rsnapshot_backup.md) | [Cron(tab)](guides/automation/cron_jobs_howto.md) |  |
| [Lsyncd](guides/backup/mirroring_lsyncd.md) | |
| [Bind](guides/dns/private_dns_server_using_bind.md) |  |

## Virtualization

| QEMU | KVM |
| --- | --- |
| | |

## Containerization

| LXC/LXD |
| --- |
| [Creating a full LXD Server](guides/containers/lxd_server.md) |

## Educational / Training

| Administration | Security | General |
|----------------|----------|---------|
| [System Administration](books/admin_guide/00-toc.md) | [Security Labs](labs/security/index.md) | [Learning Ansible](books/learning_ansible/00-toc.md)

## System Automation And Maintenance

| Ansible           | Puppet | Salt | Chef |
|-------------------|--------|------|------|
| [VM Template Creation With Packer, Ansible deployment for Vmware](guides/automation/templates-automation-packer-vsphere.md) |  |   |   |
