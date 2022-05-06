---
title: Patching servers with dnf-automatic
author: Antoine Le Morvan
contributors: Steven Spencer
update: 05-may-2022
tags:
  - security
  - dnf
  - updates
---

# Patching servers with `dnf-automatic`

Managing the installation of security updates is an important matter for the system administrator.

The process of providing software updates is a well-trodden path that ultimately causes few problems.

For these reasons, it is reasonable to automate the download and application of updates daily and automatically on the Rocky servers.

The security of your information system will be strengthened.

The `dnf-automatic` software is an additional tool that will allow you to achieve this.

## Installation

You can install `dnf-automatic` from the rocky repositories:

```
sudo dnf install dnf-automatic
```

## configuration

By default, the update process will start at 6am, with a random extra time delta to avoid all your machines updating at the same time.

To change this behavior, you must override the timer configuration associated with the application service.

```
sudo systemctl edit dnf-automatic.timer

[Unit]
Description=dnf-automatic timer
# See comment in dnf-makecache.service
ConditionPathExists=!/run/ostree-booted
Wants=network-online.target

[Timer]
OnCalendar=*-*-* 6:00
RandomizedDelaySec=10m
Persistent=true

[Install]
WantedBy=timers.target
```

The previous configuration allows to reduce the start-up delay between 6:00 and 6:10 am. A server that would be shut down at this time would be automatically patched after its restart.

And then activate the timer associated to the service (not the service itself):

```
$ sudo systemctl enable --now dnf-automatic.timer
```

## What about CentOS 7 servers ?

The process under centos 7 is almost similar but uses a different software: `yum-cron`.

```
$ sudo yum install yum-cron
```

The configuration of the service is done this time in the file `/etc/yum/yum-cron.conf`.

Set configuration as needed:

```
[commands]
#  What kind of update to use:
# default                            = yum upgrade
# security                           = yum --security upgrade
# security-severity:Critical         = yum --sec-severity=Critical upgrade
# minimal                            = yum --bugfix update-minimal
# minimal-security                   = yum --security update-minimal
# minimal-security-severity:Critical =  --sec-severity=Critical update-minimal
update_cmd = default

# Whether a message should be emitted when updates are available,
# were downloaded, or applied.
update_messages = yes

# Whether updates should be downloaded when they are available.
download_updates = yes

# Whether updates should be applied when they are available.  Note
# that download_updates must also be yes for the update to be applied.
apply_updates = yes

# Maximum amout of time to randomly sleep, in minutes.  The program
# will sleep for a random amount of time between 0 and random_sleep
# minutes before running.  This is useful for e.g. staggering the
# times that multiple systems will access update servers.  If
# random_sleep is 0 or negative, the program will run immediately.
# 6*60 = 360
random_sleep = 30
```

The comments in the configuration file speak for themselves.

You can now enable the service and start it:

```
$ sudo systemctl enable --now yum-cron
```

## Conclusion

The automatic update of packages is easily activated and considerably increases the security of your information system.
