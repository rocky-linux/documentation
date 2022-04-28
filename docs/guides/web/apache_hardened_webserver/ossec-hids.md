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

# Host-based Intrusion Detection System (HIDS)

## Prerequisites

* Proficiency with a command-line text editor (we are using _vi_ in this example)
* A heavy comfort level with issuing commands from the command-line, viewing logs, and other general systems administrator duties
* An understanding that installing this tool also requires monitoring of actions and tuning to your environment
* All commands are run as the root user or using sudo

## Introduction

_ossec-hids_ is a host intrusion detection system that offers automatic action-response steps to help mitigate host intrusion attacks. It is just one possible component of a hardened Apache web server setup and can be used with or without other tools.

If you'd like to use this along with other tools for hardening, refer back to the [Apache Hardened Web Server](index.md) document. This document also uses all of the assumptions and conventions outlined in that original document, so it is a good idea to review it before continuing.

## Installing Atomicorp's Repository

To install _ossec-hids_, we need a third-party repository from Atomicorp. Atomicorp also offers a reasonably priced fee-based supported version for those who would like professional support if they run into trouble.

If you'd prefer support, and have the budget for it, check out [Atomicorp's paid _ossec-hids_](https://atomicorp.com/atomic-enterprise-ossec/) version. Since we are going to need just a few packages from Atomicorp's free repository, we are going to modify the repository after we have it downloaded.

Downloading the repository requires _wget_ so install that first if you don't have it. Install the EPEL repository as well if you do not have it installed already, with:

`dnf install wget epel-release`

Now download and enable Atomicorp's free repository:

`wget -q -O - http://www.atomicorp.com/installers/atomic | sh`

This script will ask you to agree to the terms. Either type "yes" or hit 'Enter' to accept "yes" as the default.

Next, it will ask you if you want to enable the repository by default, and again we want to accept the default or type "yes".

### Configuring The Atomicorp Repository

We only need the atomic repository for a couple of packages. For this reason, we are going to modify the repository and specify only those packages be chosen:

`vi /etc/yum.repos.d/atomic.repo`

And then add this line beneath the "enabled = 1" in the top section:

`includepkgs = ossec* inotify-tools`

That's the only change we need, so save your changes and get out of the repository, (in vi that would be <kbd>esc</kbd> to enter command mode, then `: wq` to save and quit).

This restricts the Atomicorp repository to only install and update these packages.

## Installing ossec-hids

Now that we have the repository downloaded and configured, we need to install the packages:

`dnf install ossec-hids-server ossec-hids inotify-tools`

### Configuring ossec-hids

There are a number of changes that need to be made to the _ossec-hids_ configuration file. Most of these have to do with server administrator notification and log locations.

_ossec-hids_ looks at the logs to try and determine if there is an attack, and whether to apply mitigation. It also sends reports to the server administrator, either just as a notification, or that a mitigation procedure has been activated based on what _ossec-hids_ has seen.

To edit the configuration file type:

`vi /var/ossec/etc/ossec.conf`

We will break apart this configuration showing the changes in line and explaining them as we go:

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

By default, email notifications are turned off and the `<global>` configuration is basically empty. You want to turn on email notification and identify the people who should receive the email reports by email address.

The `<smtp_server>` section currently shows localhost, however you can specify an email server relay if you prefer, or simply setup the postfix email settings for the local host by following [this guide](../../email/postfix_reporting.md).

You need to set the "from" address, so that you can deal with SPAM filters on your email server which may see this email as SPAM. To avoid getting inundated with email, set the email reporting to 1 per hour. You can expand this or remark out this command if you like while you are getting started with _ossec-hids_ and need to see things quickly.

The `<white_list>` sections deal with the server's localohost IP and with the "public" address (remember, we are using a private address to demonstrate this) of the firewall, from which all connections on the trusted network will show. You can add multiple `<white_list>` entries as needed.

```
<syscheck>
  <!-- Frequency that syscheck is executed -- default every 22 hours -->
  <frequency>86400</frequency>
...
</syscheck>
```

The `<syscheck>` section takes a look at a list of directories to include and exclude when looking for compromised files. Think of this as yet another tool for watching and protecting the file system against vulnerabilities. You should review the list of directories and see if there are others that you want to add in to the `<syscheck>` section.

The `<rootcheck>` section just beneath the `<syscheck>` section is yet another protection layer. The locations that both `<syscheck>` and `<rootcheck>` watch are editable, but you probably will not need to make any changes to them.  

Changing the `<frequency>` for the `<rootcheck>` run to once every 24 hours (86400 seconds) from the default of 22 hours is an optional change shown above.

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

The `<localfile>` section deals with the locations of the logs we want to watch. There are entries already in place for _syslog_ and _secure_ logs that you just need to verify the path to, but everything else can be left as is.

We do need to add in the Apache log locations however, and we want to add these in as wild_cards, because we could have a bunch of logs for a lot of different web customers. That format is shown above.

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

Finally, towards the end of the file we need to add the active response section. This section contains two parts, a `<command>` section, and the `<active-response>` section.

The "firewall-drop" script already exists within the ossec path.  It tells _ossec\_hids_ that if a level of 7 is reached, add a firewall rule to block the IP address for 20 minutes. Obviously, you can change the timeout value. Just remember that the configuration file times are all in seconds.

Once you have made all of the configuration changes you need, simply enable and start the service. If everything starts correctly, you should be ready to move on:

`systemctl enable ossec-hids`

And then:

`systemctl start ossec-hids`

There are a lot of options for the _ossec-hids_ configuration file. You can find out about these options by visiting the [official documentation site](https://www.ossec.net/docs/).

## Conclusion

_ossec-hids_ is just one element of an Apache hardened web server. It can be used with other tools to gain better security for your web site.

While the installation and configuration are relatively straight forward, you will find that this is **not** an 'install it and forget it' application. You will need to tune it to your environment to gain the most security with the least amount of false-positive responses.
