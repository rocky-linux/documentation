---
title: General chat and IRC
author: Infrastructure team
contributors: Steven Spencer
---

!!! note

    IRC (libera.chat) and Matrix are no longer bridged. Joining by way of the Matrix channels generates a request to join us in other ways. The recommendation is that you join us by way of [Mattermost](https://chat.rockylinux.org) or [IRC](https://libera.chat).

Mattermost is the primary communication tool for the Rocky Linux project. IRC (Internet Relay Chat) is a common communication tool used in the open source community. Bridging occurs between several Mattermost channels and Libera IRC to ensure the community can communicate effectively. Rocky Linux Infrastructure and other teams manage and maintain both the Mattermost channels and the various Libera IRC channels such as `#rockylinux` and `#rockylinux-social`. You can find a list of our channels in the `Bridge Information` section on this page.

More information about Libera can be found [here](https://libera.chat).

## Bridge Information

Here are the current bridge mappings. Note that this is not an all inclusive list.

!!! note

    Since the bridging of Matrix and IRC is gone, the team removed the Matrix section. There are no plans to bridge Matrix. If you want to request or provide any kind of knowledge or help in maintaining a bridge, [file a ticket](https://git.resf.org/infrastructure/meta/issues).

| IRC                         | Mattermost                                                                         |
|-----------------------------|------------------------------------------------------------------------------------|
| #rockylinux                 | [~general](https://chat.rockylinux.org/rocky-linux/channels/town-square)           |
| #rockylinux-devel           | [~development](https://chat.rockylinux.org/rocky-linux/channels/development)       |
| #rockylinux-docs            | [~documentation](https://chat.rockylinux.org/rocky-linux/channels/documentation)   |
| #rockylinux-infra           | [~infrastructure](https://chat.rockylinux.org/rocky-linux/channels/infrastructure) |
| #rockylinux-legal           | [~legal](https://chat.rockylinux.org/rocky-linux/channels/legal)                   |
| #rockylinux-security        | [~security](https://chat.rockylinux.org/rocky-linux/channels/security)             |
| #rockylinux-sig-altarch     | [~altarch](https://chat.rockylinux.org/rocky-linux/channels/altarch)               |
| #rockylinux-sig-kernel      | [~sig-kernel](https://chat.rockylinux.org/rocky-linux/channels/sig-kernel)         |
| #rockylinux-social          | [~off-topic](https://chat.rockylinux.org/rocky-linux/channels/off-topic)           |
| #rockylinux-testing         | [~testing](https://chat.rockylinux.org/rocky-linux/channels/testing)               |
| #rockylinux-www             | [~web](https://chat.rockylinux.org/rocky-linux/channels/web)                       |

## General

It is likely that there will be many machines running Rocky Linux. This means a large amount of people will occasionally look for help in the main Rocky Linux Mattermost `~General` channel, or Rocky Linux main IRC channel `#rockylinux`. Typically these questions are on what the distribution ships. It is important to maintain focus on a Rocky Linux specific matter as the channel typically does not have the ability nor bandwidth to support non-Rocky Linux topics.

General rules are:

* **Unless a question or thread is about an application or program supplied in Rocky Linux, it is likely off topic** (see the exceptions section)
* **Discussing the usage of non-Rocky Linux packages or problems (that the Rocky Linux project has no control over) are off-topic** (see the exceptions section)
* **Polling for general usage, preferences, or other opinions, is off-topic**
* **It is off-topic to request support, or discuss the usage of other distributions.**

### Exceptions

There are cases where it might do more harm than good to deny providing help to a user who is using something that others might consider unsupported. The determination of this is on a case by case basis, and it is impossible to list all exceptions. Here are some exceptions:

* **The question is in releation to software in EPEL**

    * If a problem is reproducible or its an issue out of our control, you should go to `#epel` or [EPEL's Matrix Channel](https://matrix.to/#/#epel:fedoraproject.org).

* **The question is in relation to drivers from elrepo or rpmfusion**

    * It is common for users to use hardware that is either not supported in a current Rocky Linux release, or needs a better driver (such as nouveau -> nvidia). The team considers providing general assistance for getting such drivers semi-topical. Most users will support one another in this scenario. elrepo volunteers will be in the channel as well to assist users. Other issues should go to `#elrepo` or where topical, such as their [Bug Tracker](https://elrepo.org/bugs).

* **If the question is in relation to CentOS Stream as it pertains to Rocky Linux**

    * There might be cases where a discussion of CentOS Stream occurs. This happens when trying to determine behavior changes, or what it might take to make a behavior change upstream that would then affect Rocky Linux. The team considers these as semi-topical. Note that you can find the support for CentOS Stream in `#centos-stream` on Libera IRC and channels within Matrix if they exist.

### What is not supported

* **Kernel Rebuilds**
* **Other Derivatives or Forks**

    * This includes, but is not limited to RHEL, OEL, Alma, Springdale, SL
* **Broken "V" servers**
* **Old minor or point releases of Rocky Linux (See our [version policy](../../releases/index.md))**
* **Upgrades or upgraded Rocky Linux systems (upgrading Rocky Linux 8 to 9, or 9 to 10, see our [version policy](../../releases/index.md))**
* **Upgrades of the default python version (such as python 3.6 to 3.9 or python 3.9 to 3.11)**
* **Upgrades of the default `glibc` version provided**
* **Politics or Profanity**
* **Distro X is better or worse than Rocky Linux**
* **Personal drama from other channels, namespaces, or other users**

    * IRC: The quieting or banning of repeat offenders from the `#rockylinux*` namespace
    * Mattermost: The banning of repeat offenders from the Rocky Linux mattermost instance

## Etiquette

### How to ask questions

When coming into the IRC or Mattermost channels, it is important to be able to field your question in a manner in which the other users will be able to understand the question and provide assistance. Here are some general ideas:

* **Do not ask to ask** - Just ask your question
* **Do not paste large quantities of text into the channel**

    * This can be disruptive to users on both sides of the IRC and Mattermost bridge
    * If at all possible, use a paste bin such as [rpaste](https://rpa.st)
* **Limit edits** - Refrain from unnecessary edits in Mattermost.

    * Edits do not propagate to IRC at this time.
    * Consider sending a new separate message instead with only the added content. Users on our bridges can then help more effectively.
* **Be patient** - You might not get an instant answer. We are all volunteers, so it might take minutes or hours to receive an answer to your question.
* **Read the Topic** - The topic might contain useful information you want to know about.

### Expectations

As `#rockylinux` is the general Rocky Linux support and discussion channel on Libera, it is not a primary support area for learning Linux or general chatting and off-topic matters. Off-topic matter should go to `#rockylinux-social` or `~off-topic`. Here is a list of things you should know:

* **The channels have many supporters of Rocky, end users, and volunteers, with many skill sets and who are knowledgeable. These people use the distribution on a professional or personal level**
* **Polite and on-topic people get answers to their queries**

    * Insulting, rude, or off topic users are generally ignored or warned for their behavior
    * Consider the human, be civil - Treat people how you want them to treat you
    * Those who are consistently disruptive (or "trolls") will face removal from the channel by a quiet, or ban
* **The channel can be busy with several threads running in parallel**
* **We support what we ship**
* **It is common for others to ask for system or package information. Do this with:**

    * `rpaste -s`
    * `uname -a`
    * `rpm -V packageName`
    * **If you refuse to provide such information, volunteers might stop trying to assist you.**

It is normal for a channel to not be all business all the time. Passing snarkiness or even random off topic matter can occur. However, it can be a problem if it takes over the channel, where a user is unable to get their question in or the discussion turns into animosity, insults, or rude behavior.

A recommendation would be to join the channel and observe for a while to get an idea of how the channel operates; try to avoid dropping in, asking a question, and disappearing.

!!! note

    Logging occurs on the channels and are routinely checked. What you see in Mattermost is also seen in IRC and vice versa. It is also very likely channel operators are not the only ones who monitor the channel. This means that your conversations are public.

    Persistent abusers and those who consistently act out in bad faith will receive a silence, a quiet, or a ban, if they have been repeatedly warned. If you find that you have been banned in IRC and do not know why, you may want to ask in `#rockylinux-ops` and an available channel operator will try to assist you.

Please also see our [Code of Conduct](https://rockylinux.org/coc/).

## IRC for beginners

You will need an IRC client. There are many out there. Here are examples:

* ChatZilla (firefox add on)
* Pidgin
* Kiwi (web client)
* weechat (text client)
* irssi (text client)

Once you have your IRC client setup and configured, you will need to go to [irc://irc.libera.chat/](irc://irc.libera.chat). To set your nickname, type `/nick nickname` in the box and press enter.

Note that our channels require users to register on Libera to participate. Libera chat provides [instructions for you to do so here](https://libera.chat/guides/registration). If you need help, you can type `/join #libera` and request help.

Once you register and `NickServ` identifies you, you can type `/join #rockylinux` or another related channel.

New session logins will require you to identify. `/msg nickserv identify password` will help to ensure you do not get locked out of the `#rockylinux*` channels.

### IRC cloaks for libera.chat network

Cloaks let you show your association with the Rocky Linux project, and hide your hostname's visibility from others. You can receive cloaks from a project, or from the network upon request.

If you want to receive a cloak, contact Infrastructure on IRC or Mattermost.

## Context

### Kernel Rebuilds

Kernel rebuilds are neither recommended nor supported for Rocky Linux. Before building a custom kernel or even considering it, ask yourself the following questions:

* Is the functionality you need available by installing a kernel module from [elrepo](https://elrepo.org)?
* Is the functionality you need available as a separate module from the kernel itself?
* Are you willing to maintain your own security posture?
* **Are you sure?** The design of Rocky Linux and most other EL derivatives is to function as a complete environment. Replacing critical components can affect how the system acts.
* **Are you ABSOLUTELY sure?** 99.9% of the users no longer need to build their own kernel. You might only need a kernel module or driver. In this case, you can use [elrepo](https://elrepo.org) or build your own kernel module (kmod/dkms).
* **Are you sure you do not just want a newer kernel version?** Again, you can find newer kernels at [elrepo](https://elrepo.org) and soon [SIG/Kernel](https://sig-kernel.rocky.page/).

!!! warning

    As a final warning, if you break the kernel, you are on your own for your system. Rocky Linux volunteers or developers are unable to assist you with these issues.

### Upgraded systems

System upgrades are generally unsupported. There are quite a few methods out there of users performing upgrades:

* Updating the system release packages (such as, centos-release to rocky-release, or updating rocky-release to another) and running a `yum distro-sync` or `yum update`

    * Example 1: replacing centos-\* packages with rocky-\* packages and running `yum update` or `yum distro-sync`
    * Example 2: updating rocky-\* packages from 8 to 9, and then running `dnf update` or `dnf distro-sync`
* Using scripts or tools that a user might not review that promise smooth upgrades from X to Y
* Following guides that promise smooth upgrades from X to Y

Regardless of the method, a system that has been "upgraded" is generally considered unsupported. The team always recommends that you build a new system and restore from backups. Users might try to help or assist with your system, but it can be difficult to do so.

!!! note

    The tool ELevate exists to help users transition from one major release of an Enterprise Linux to another. The Rocky Linux team has not formally tested it. The team cannot officially provide assistance or feedback to the tool or support an upgraded system. There might be users in the channel who have done so and can assist, but at this time it is still unsupported.

### Outdated or end of life releases

Outdated or end of life (EOL) releases are not supported. If you do not update, you are leaving your system in a vulnerable state, prone to bugs and effectively lowering its security posture. Community members, volunteers, and channel regulars might ask you to run:

* `cat /etc/os-release`
* `cat /etc/rocky-release`
* `dnf repolist`
* `dnf update`

Only the latest available `X.Y` of a given version is supported at a given time. Check out the [Rocky Linux](../../releases/index.md) version section for more information, for the latest available releases, and our version policies.

If a vendor requires a specific software version, locking your ability to update, you should speak with your software vendor and ask when they plan on supporting or certifying a supported release for their software.

### Broken V servers

Our distribution uses a variant of `dnf`. All Rocky Linux releases ship with `dnf` and a certain set of matching configuration files (such as `.repo` files). This allows your system to work with the mirror system provided by the Rocky Linux project. Some downstream forks break these configurations and make their system incompatible with what we provide.

Regulars (developers and volunteers) will typically decline to help in this type of scenario. Below are examples of "broken V servers" where `dnf` is either missing, mis-configured, or otherwise broken.

#### Virtual private server (VPS)

So you have a VPS and you discover that `dnf` is not working as it should. This means you are not using Rocky Linux. If you are using an installation "based on" Rocky Linux but `dnf` is missing, you do not have a real Rocky Linux installation. Common examples of providers who do this:

* OpenVZ
* cPanel
* Plesk
* webmin
* Direct Admin
* BlueQuartz
* Asterisk
* Trixbox
* Elastix

These tend to only install parts of Rocky Linux on their virtual servers. Some remove `dnf` from the system entirely or alter the settings in a way that is not conducive to a working Rocky Linux system. Typical changes are such that they exclude locally modified packages from our base repositories. You can verify this by running `grep -ir exclude /etc/{yum,dnf}*`. This will show what they are excluding. Some will also manage the box outside of the package manager.

Why these providers do this is unclear. Regardless of their reasons, this approach affects these systems negatively as `dnf` has mechanisms to protect specific packages from change.

Before you try anything, ask your provider **why** they remove `dnf`. Ask how you are to keep your system up to date and secure without it.

Generally speaking, these are not true Rocky Linux systems. A true Rocky Linux installation has a Rocky kernel and the `rocky-release` packages. It also has `dnf`, without modifications to the contents in `/etc/yum.repos.d`. The exception is modifications used for a local mirror or staged repositories. A true Rocky Linux installation satisfies all dependencies, with the exception of configuration files, is up-to-date, and maintained.

With a true Rocky Linux system:

* You can update it at any time
* You can provide a list of usual groups that is reproducible across systems
* SELinux is enforcing by default
* Has a working firewall by default

Volunteers might ask you to run one of these commands to give you more help:

* `dnf install rpaste -y ; rpaste --sysinfo`
* `cat /etc/os-release ; uname -a ; rpm -V dnf rocky-release rocky-repos ; ls /etc/yum.repos.d/ ; dnf repolist all`

The former produces a `sysinfo` output. You can install `rpaste` from the extras repository. The second produces multi-line output that you can then use at <https://rpa.st>. They might also ask you to run `uname -a`. This is typically enough.

When it is clear it is not a Rocky Linux system, the regulars of the channel will not continue to offer further help. They do not want to suggest actions that can potentially break your system further. Most regulars do not know all the ways hosting providers might have altered the functions that a Rocky Linux system provides by default.

If your provider misrepresented your system as Rocky Linux, you should tell the provider:

* To stop misrepresenting what they offer as Rocky Linux
* To deliver to you what they promised or receive a refund

You might want to know if it is possible to get `dnf` back.

The answer is "Yes" it is possible. However, it might come at a cost of breaking your system. Thus, the team does not give such advice here.
