---
title: Patching with dnf-automatic
author: Antoine Le Morvan
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 8.5
tags:
  - security
  - dnf
  - automation
  - updates
---

# Patching servers with `dnf-automatic`

Managing the installation of security updates is an important matter for the system administrator. Providing software updates is a well-trodden path that ultimately causes few problems. For these reasons, it is reasonable to automate the download and application of updates daily and automatically on Rocky servers.

The security of your information system will be strengthened. `dnf-automatic` is an additional tool that will allow you to achieve this.

!!! tip "If you are worried..."

    Years ago, applying updates automatically like this would have been a recipe for disaster. There were many times when an update applied might cause issues. That still happens rarely, when an update of a package removes a deprecated feature that is being used on the server, but for the most part, this simply isn't an issue these days. If you still feel uncomfortable letting `dnf-automatic` handle the updates, consider using it to download and/or notify you that updates are available. That way your server doesn't remain unpatched for long. These features are `dnf-automatic-notifyonly` and `dnf-automatic-download`

    For more on these features, take a look at the [official documentation](https://dnf.readthedocs.io/en/latest/automatic.html).

## Installation

You can install `dnf-automatic` from the rocky repositories:

```
sudo dnf install dnf-automatic
```

## Configuration

By default, the update process will start at 6am, with a random extra time delta to avoid all your machines updating simultaneously. To change this behavior, you must override the timer configuration associated with the application service:

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

This configuration reduces the start-up delay between 6:00 and 6:10 am. (A server that would be shut down now would be automatically patched after its restart.)

Then activate the timer associated with the service (not the service itself):

```
$ sudo systemctl enable --now dnf-automatic.timer
```

## What about CentOS 7 servers?

!!! tip

    Yes, this is Rocky Linux documentation, but if you are a system or network administrator, you may have some CentOS 7 machines still in play. We get that, and that is why we are including this section.

The process under CentOS 7 is similar but uses: `yum-cron`.

```
$ sudo yum install yum-cron
```

This time, the configuration of the service is done in the file `/etc/yum/yum-cron.conf`.

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

# Maximum amount of time to randomly sleep, in minutes.  The program
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
