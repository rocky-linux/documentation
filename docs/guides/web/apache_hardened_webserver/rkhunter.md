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

# Rootkit hunter

## Prerequisites

* Proficiency with a command-line editor (using _vi_ in this example)
* A heavy comfort level with issuing commands from the command-line, viewing logs, and other general systems administrator duties
* An understanding of what can trigger a response to changed files on the file system (such as package updates) is helpful
* Running all commands as root or as a regular user with `sudo`

This document was originally written in conjunction with the apache hardened web server routines, but works equally well on a server running any software.

## Introduction

`rkhunter` (Root Kit Hunter) is a Unix-based tool that scans for rootkits, back doors, and possible local exploits. It is a good part of a hardened server, and will notify the administrator quickly when something suspicious happens on the server's file system, providing it is properly configured.

`rkhunter` is just one possible part of a hardened Apache web server setup. Use it alone or with other tools to maximize security. If you want to use this along with other tools for hardening, refer back to the [Apache Hardened Web Server guide](index.md).

This document also uses all of the assumptions and conventions outlined in that original document. It is a good idea to review it before continuing.

## General steps

1. install `rkhunter`
2. configure `rkhunter`
3. configure email and ensure it will work correctly
4. run `rkhunter` manually to generate a list of warnings to test your email settings (`rkhunter --check`)
5. run `rkhunter --propupd` to generate a clean `rkhunter.dat` file that `rkhunter` will use from this point forward as a baseline for further checks.

## Installing `rkhunter`

`rkhunter` requires the EPEL (Extra Packages for Enterprise Linux) repository. Install that repository if you do not have it installed already:

```
dnf install epel-release
```

Install `rkhunter`:

```
dnf install rkhunter
```

## Configuring `rkhunter`

The only configuration options that you need to set are those dealing with mailing reports to the administrator. To change the configuration file, run:

```
vi /etc/rkhunter.conf`
```

Search for:

```
#MAIL-ON-WARNING=me@mydomain   root@mydomain
```

Remove the remark here and change the `me@mydomain.com` to reflect your email address.

Change the `root@mydomain` to `root@whatever_the_server_name_is`.

You will probably also want to remove the remark (and edit the line to fit your needs) from the `MAIL-CMD` line:


```
MAIL_CMD=mail -s "[rkhunter] Warnings found for ${HOST_NAME}"
```

You might also need to setup [Postfix Email for Reporting](../../email/postfix_reporting.md) to get the email section to work correctly.

## Running `rkhunter`

Run `rkhunter` manually by typing it at the command-line. A cron job takes care of running `rkhunter` for you automatically in `/etc/cron.daily`. If you want to automate the procedure on a different schedule, examine [Automating cron jobs guide](../../automation/cron_jobs_howto.md).

You will also need to move the script somewhere other than `/etc/cron.daily`, such as `/usr/local/sbin` and call it from your custom cron job. The easiest method is to leave the default `cron.daily` setup intact.

If you want to test `rkhunter` before you start, including all email functionality, run `rkhunter --check` from the command line. If problems exist with the email setup, hold off completing the remaining steps. When confirming email works, but before allowing `rkhunter` to run automatically, run the command manually again with the "--propupd" flag to create the `rkhunter.dat` file. This ensures recognition of your environment and configuration:

```
rkhunter --propupd
```

## Conclusion

`rkhunter` is one part of a hardened server strategy that can help in monitoring the file system and reporting any issues to the administrator. It is perhaps one of the easiest hardening tools to install, configure, and run.
