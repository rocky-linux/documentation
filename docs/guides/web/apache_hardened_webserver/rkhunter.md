---
title: Rootkit Hunter
author: Steven Spencer
contributors: Ezequiel Bruni
tested with: 8.7, 9.1
tags:
  - server
  - security
  - rkhunter
---

# Rootkit Hunter

## Prerequisites

* Proficiency with a command-line editor (we are using _vi_ in this example)
* A heavy comfort level with issuing commands from the command-line, viewing logs, and other general systems administrator duties
* An understanding of what can trigger a response to changed files on the file system (such as package updates) is helpful
* All commands are run as the root user or sudo

This document was originally written in conjunction with the apache hardened webserver routines, but works equally well on a server running any software.

## Introduction

_rkhunter_ (Root Kit Hunter) is a Unix-based tool that scans for rootkits, backdoors, and possible local exploits. It is a good part of a hardened server, and is designed to notify the administrator quickly when something suspicious happens on the server's file system.

_rkhunter_ is just one possible component of a hardened Apache web server setup and can be used with or without other tools. If you'd like to use this along with other tools for hardening, refer back to the [Apache Hardened Web Server guide](index.md).

This document also uses all of the assumptions and conventions outlined in that original document, so it is a good idea to review it before continuing.

## General steps

1. install rkhunter
2. configure rkhunter
3. configure email and make sure it is set up to work correctly
4. run `rkhunter` manually to generate a list of warnings to test your email settings (`rkhunter --check`)
5. run `rkhunter --propupd` to generate a clean `rkhunter.dat` file that `rkhunter` will use from this point forward as a baseline for further checks.

## Installing rkhunter

_rkhunter_ requires the EPEL (Extra Packages for Enterprise Linux) repository. So install that repository if you don't have it installed already:

```
dnf install epel-release
```

Then install _rkhunter_:

```
dnf install rkhunter
```

## Configuring rkhunter

The only configuration options that need to be set are those dealing with mailing reports to the administrator. To modify the configuration file, run:

```
vi /etc/rkhunter.conf`
```

And then search for:

```
#MAIL-ON-WARNING=me@mydomain   root@mydomain
```

Remove the remark here and change the `me@mydomain.com` to reflect your email address.

Then change the `root@mydomain` to `root@whatever_the_server_name_is`.

You will probably also want to remove the remark (and edit the line to fit your needs) of the `MAIL-CMD` line, found a few lines below that looks like this:

```
MAIL_CMD=mail -s "[rkhunter] Warnings found for ${HOST_NAME}"
```

You may also need to setup [Postfix Email for Reporting](../../email/postfix_reporting.md) in order to get the email section to work correctly.

## Running rkhunter

_rkhunter_ can be run by typing it at the command-line. There is a cron job installed for you in `/etc/cron.daily`, but if you want to automate the procedure on a different schedule, look at the [Automating cron jobs guide](../../automation/cron_jobs_howto.md).

You'll also need to move the script somewhere other than `/etc/cron.daily`, such as `/usr/local/sbin` and then call it from your custom cron job. The easiest method, of course, is to leave the default `cron.daily` setup intact.

If you want to test `rkhunter` before you start, including all email functionality, etc., run `rkhunter --check` from the command line. If there are problems with email setup, hold off completing the rest so that you can run this command again. Once email has been confirmed to work but before you allow `rkhunter` to run automatically, run the command manually again with the "--propupd" flag to create the `rkhunter.dat` file, and to make sure that your new environment is recognized without issue:

```
rkhunter --propupd
```

## Conclusion

_rkhunter_ is one part of a hardened server strategy that can help in monitoring the file system and reporting any issues to the administrator. It is perhaps one of the easiest hardening tools to install, configure, and run.
