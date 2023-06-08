---
title: Host-based Intrustion Detection System (HIDS)
author: Steven Spencer
contributors: Ezequiel Bruni
tested with: 8.5
tags:
  - web
  - security
  - ossec-hids
  - hids
---

# Host-based intrusion detection system (HIDS)

## Prerequisites

* Proficiency with a command-line text editor (using `vi` in this example)
* A heavy comfort level with issuing commands from the command-line, viewing logs, and other general systems administrator duties
* An understanding that installing this tool also requires monitoring of actions and tuning to your environment
* The root user runs all commands or a regular user with `sudo`

## Introduction

`ossec-hids` is a host intrusion detection system that offers automatic action-response steps to help mitigate host intrusion attacks. It is just one possible piece of a hardened Apache web server setup. You can use it with or without other tools.

If you want to use this along with other tools for hardening, refer back to the [Apache Hardened Web Server](index.md) document. This document also uses all of the assumptions and conventions outlined in that original document. It is a good idea to review it before continuing.

## Installing Atomicorp's repository

To install `ossec-hids`, we need a third-party repository from Atomicorp. Atomicorp also offers a reasonably priced fee-based supported version for those who want professional support if they run into trouble.

If you prefer support, and have the budget for it, check out [Atomicorp's paid `ossec-hids`](https://atomicorp.com/atomic-enterprise-ossec/) version. You are going to need just a few packages from Atomicorp's no cost repository. You are going to change the repository after downloading.

Downloading the repository requires `wget`. Install that first, and install the EPEL repository if you do not have it installed already, with:

```
dnf install wget epel-release
```

Download and enable Atomicorp's no cost repository:

```
wget -q -O - http://www.atomicorp.com/installers/atomic | sh
```

This script will ask you to agree to the terms. Enter "yes" or <kbd>Enter</kbd> to accept the default.

Next, it will ask you if you want to enable the repository by default, and again you want to accept the default or enter "yes".

### Configuring the Atomicorp repository

You only need the atomic repository for a couple of packages. For this reason, you are going to change the repository and specify only those packages needed:

```
vi /etc/yum.repos.d/atomic.repo
```

Add this line beneath the "enabled = 1" in the top section:

```
includepkgs = ossec* inotify-tools
```

That is the only change you need. Save your changes and get out of the repository (in `vi` that is <kbd>esc</kbd> to enter command mode, then <kbd>SHIFT</kbd>+<kbd>:</kbd>+<kbd>wq</kbd> to save and quit).

This restricts the Atomicorp repository to only install and update these packages.

## Installing `ossec-hids`

With the repository configured, you need to install the packages:

```
dnf install ossec-hids-server ossec-hids inotify-tools
```

### Configuring `ossec-hids`

The default configuration is in a state requiring many changes. Most of these have to do with server administrator notification and log locations.

`ossec-hids` looks at the logs to try and decide if an attack is underway, and whether to apply mitigation. It also sends reports to the server administrator with a notification, or a message regarding a mitigation procedure launched based on what `ossec-hids` has seen.

To edit the configuration file, enter:

```
vi /var/ossec/etc/ossec.conf
```

We will break apart this configuration showing the changes in line and explaining them:

```
<global>
  <email_notification>yes</email_notification>  
  <email_to>admin1@youremaildomain.com</email_to>
  <email_to>admin2@youremaildomain.com</email_to>
  <smtp_server>localhost</smtp_server>
  <email_from>ossec-webvms@yourwebserverdomain.com.</email_from>
  <email_maxperhour>1</email_maxperhour>
  <white_list>127.0.0.1</white_list>
  <white_list>192.168.1.2</white_list>
</global>
```

By default, email notifications are off and the `<global>` configuration is basically empty. You want to turn on email notification and identify the people who will receive the email reports by their email address.

The `<smtp_server>` section currently shows localhost, however you can specify an email server relay if you prefer, or setup the postfix email settings for the local host by following [this guide](../../email/postfix_reporting.md).

You need to set the "from" email address. You need this to deal with SPAM filters on your email server which might see this email as SPAM. To avoid getting inundated with email, set the email reporting to 1 per hour. You can expand this or remark out this command while you are getting started with `ossec-hids` and need to see things quickly.

The `<white_list>` sections deal with the server's localhost IP and with the "public" IP address (remember our substitution of a private IP address) of the firewall, from which all connections on the trusted network will show. You can add many `<white_list>` entries.

```
<syscheck>
  <!-- Frequency that syscheck is executed -- default every 22 hours -->
  <frequency>86400</frequency>
...
</syscheck>
```

The `<syscheck>` section reviews a list of directories to include and exclude when looking for compromised files. Think of this as yet another tool for watching and protecting the file system against vulnerabilities. You need to review the list of directories and add others you want to the `<syscheck>` section.

The `<rootcheck>` section just beneath the `<syscheck>` section is yet another protection layer. The locations that `<syscheck>` and `<rootcheck>` watch are editable, but you probably will not need to make any changes to them.  

Changing the `<frequency>` for the running of `<rootcheck>` to once every 24 hours (86400 seconds) from the default of 22 hours is an optional change shown.

```
<localfile>
  <log_format>apache</log_format>
  <location>/var/log/httpd/*access_log</location>
</localfile>
<localfile>
  <log_format>apache</log_format>
  <location>/var/log/httpd/*error_log</location>
</localfile>
```

The `<localfile>` section deals with the locations of the logs you want to watch. Entries are already in place for the _syslog_ and _secure_ logs that you just need to verify the path to, but everything else can remain.

You need to add in the Apache log locations, and you want to add these in as wild cards because you could have a bunch of logs for many different web customers.

```
  <command>
    <name>firewall-drop</name>
    <executable>firewall-drop.sh</executable>
    <expect>srcip</expect>
  </command>

  <active-response>
    <command>firewall-drop</command>
    <location>local</location>
    <level>7</level>
    <timeout>1200</timeout>
  </active-response>
```

Finally, towards the end of the file you need to add the active response section. This section has two parts: the `<command>` section, and the `<active-response>` section.

The "firewall-drop" script already exists within the `ossec-hids` path. It tells `ossec-hids` that if a level of 7 occurs, add a firewall rule to block the IP address for 20 minutes. You can change the timeout value. Just remember that the configuration file times are all in seconds.

When you have made all of the configuration changes you need, enable, and start the service. If everything starts correctly, you are ready to move on:

```
systemctl enable ossec-hids
systemctl start ossec-hids
```

Many options exist for the `ossec-hids` configuration file. You can find out about these options by visiting the [official documentation site](https://www.ossec.net/docs/).

## Conclusion

`ossec-hids` is just one element of an Apache hardened web server. You can gain better security by selecting it with other tools.

While the installation and configuration are relatively straightforward, you will find that this is **not** an 'install it and forget it' application. You will need to tune it to your environment to gain the most security with the least number of false-positive responses.
