---
title: General Chat and IRC
---

This page goes over General Chat and IRC general information and etiquette.

!!! note
    IRC (libera.chat) and Matrix are no longer bridged. You will find that if you join the Matrix channels, you will be asked to join us in other ways. It is recommended that you join us via [Mattermost](https://chat.rockylinux.org) or via [IRC](https://libera.chat).

Mattermost is the primary communication tool for the Rocky Linux project. IRC is a common communication tool used in the open source community. This means that several channels of Mattermost and Libera IRC channels are bridged together to ensure the community can communicate effectively and not be splintered. Rocky Linux Infrastructure and other teams manage and maintain both the mattermost channels and the various Libera IRC channels such as `#rockylinux` and `#rockylinux-social`. A list of our channels can be found in `Bridge Information` section on this page.

More information about Libera can be found [here](https://libera.chat).

## Contact Information

| **IRC**                     | **Mattermost**                              |
|-----------------------------|---------------------------------------------|
| `Sokel/label/Sombra`        | `@label`                                    |
| `neil`                      | `@neil`                                     |
| `tg`                        | `@tgo`                                      |
| `pj`                        | `@pj`                                       |
| `lexi`                      |                                             |
|                             | `@grammaresque`                             |

## Bridge Information

Current mappings are below. Note that this is not an all inclusive list.

!!! note
    As matrix and IRC are no longer briged, the Matrix section has been removed. There are no plans to bridge Matrix. If you wish to request or provide any kind of knowledge or help in maintaining a bridge, please [file a ticket](https://git.resf.org/infrastructure/meta/issues).

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

It is likely that there will be a lot of boxes running Rocky Linux and thus there will be fair amount of people who will occasionally look for help in the main Rocky Linux Mattermost `~General` channel or Rocky Linux main IRC channel `#rockylinux`, typically on what the distribution ships. It is important to maintain focus on a Rocky Linux specific matter as the channel typically does not have the ability nor bandwidth to support non-Rocky Linux topics.

Here is a general rule of thumb:

* **Unless a question or thread is about an application or program supplied in Rocky Linux, it is likely off topic** (see the exceptions section)
* **Discussing the usage of non-Rocky Linux packages or problems (which the Rocky Linux project has no control over) are off-topic** (see [exceptions](#exceptions))
* **Polling for general usage/preferences or other opinion matter is considered off-topic**
* **Requesting support or discussing the usage of other distributions is considered off-topic** (more info [here](#what-is-not-supported))

### Exceptions

There are cases where it may do more harm than good to deny or to not provide assistance to a user who is using something that others may consider unsupported as a whole. While this is on a case by case basis and we are unable to list all exceptions, these are some of the more obvious exceptions:

* **If the question is related to software in EPEL**

    * If a problem is reproducible or its an issue out of our control, it is recommended to go `#epel` or [EPEL's Matrix Channel](https://matrix.to/#/#epel:fedoraproject.org).

* **If the question is related to drivers from elrepo or rpmfusion**

    * It is common for users to be using hardware that is either not supported in a current Rocky Linux release or needs a better driver (e.g., nouveau -> nvidia). Providing general assistance for getting such drivers should be considered semi-topical. Most users will support one another in this scenario. elrepo volunteers will be in the channel as well to assist users. Other issues should go to `#elrepo` or where topical, such as their [Bug Tracker](https://elrepo.org/bugs).

* **If the question is related to CentOS Stream as it pertains to Rocky Linux**

    * There may be cases where discussion of CentOS Stream may occur. This typically happens when trying to determine behavior changes or what it may take to make a behavior change upstream that would then affect Rocky Linux. These should be treated as semi-topical. Note that CentOS Stream specific support may be found in `#centos-stream` on Libera IRC and channels within Matrix if they exist.

### What is not supported?

* **[Kernel Rebuilds](#kernel-rebuilds)**
* **Other Derivatives/Forks**

    * This includes, but is not limited to RHEL, OEL, Alma, Springdale, SL

* **[Broken "V" Servers](#broken-v-servers)**
* **Old minor/point releases of Rocky Linux (See our [version policy](rocky/version.md))**
* **Upgrades or upgraded Rocky Linux systems (e.g., upgrading Rocky Linux 8 to 9, see our [version policy](rocky/version.md))**
* **Upgrades of the default python version (e.g. python 3.6 to 3.9 or python 3.9 to 3.11)**
* **Upgrades of the default glibc version provided**
* **Politics or Profanity**
* **Distro X is better/worse than Rocky Linux**
* **Personal drama from other channels, namespaces, or other users**

    * IRC: Repeat offenders will be quieted or banned from the `#rockylinux*` namespace
    * Mattermost: Repeat offenders will be banned from the Rocky Linux mattermost instance

## Etiquette

This section goes over general etiquette expected of all users of Mattermost or IRC.

### How to ask questions

When coming into the IRC or Mattermost channels, it's important to be able to field your question in a manner in which the other users will be able to understand the question and provide assistance. Here's some general ideas:

* **Don't ask to ask** - Just ask your question
* **Don't paste large quantities of text into the channel**

    * This can be disruptive to users on both sides of the IRC/MM bridge
    * If at all possible, use a paste bin such as [rpaste](https://rpa.st)

* **Limit edits** - Refrain from unnecessary edits in Mattermost.

    * Edits are not propogated to IRC at this time.
    * Consider sending a new separate message instead with only the added content, as to allow users on our bridges to help more easily if possible.

* **Be patient** - You may not get an instant answer. We are all volunteers, so it may take minutes or hours to receive an answer to your question.
* **Read the Topic** - The topic may contain useful information you may want to know about.

### Expectations

As `#rockylinux` is the general Rocky Linux support and discussion channel on Libera, it is not a primary support area for learning Linux or general chatting and off topic matter. Off-topic matter should go to `#rockylinux-social` or `~off-topic`. With that being said, below is a list of things you should probably be aware of:

* **The channels are filled with supporters of Rocky, end users, volunteers with wide ranges of skillsets and knowledge who use the distribution on a professional or personal level**
* **Polite and on-topic people get answers to their queries**

    * Insulting, rude, or off topic users are generally ignored or warned for their behavior
    * Consider the human, be civil - Treat people how you would want to be treated
    * Those who are consistently disruptive (or "trolls") will be removed from the channel by a quiet or ban

* **The channel can be busy with several threads running in parallel**
* **We support what we ship**
* **Do not be surprised if you are asked to provide some information about your system**

    * `rpaste -s`
    * `uname -a`
    * `rpm -V packageName`
    * **If you refuse to provide such information, volunteers may stop trying to assist you.**

It is normal for a channel to not be all business all the time. Passing snarkiness or even random off topic matter can occur. However, it can be a problem if it takes over the channel, where a user is unable to get their question in or the discussion turns into animosity, insults, or rude behavior (see the above points).

A recommendation would be to join the channel and observe for a while to get an idea of how the channel operates; try to avoid dropping in, asking a question, and disappearing.

!!! note
    The channels are logged and routinely checked. What is seen in Mattermost is also seen in IRC and vice versa. It is also very likely we (channel operators) are not the only ones who monitor the channel. This means that your conversations are considered public.

    Persistent abusers and those who consistently act out in bad faith will receive a silence/quiet or a ban, if they have been repeatedly warned. If you find that you have been banned in IRC and do not know why, you may want to ask in `#rockylinux-ops` and an available channel operator will try to assist you.

Please also see our [Code of Conduct](https://rockylinux.org/coc/).

## IRC For Beginners

It is possible that you may have not used IRC before. Hopefully this guide will get you started.

You will need an IRC client. There are many out there. Here are examples:

* ChatZilla (firefox add on)
* Pidgin
* Kiwi (web client)
* weechat (text client)
* irssi (text client)

Once you have your IRC client setup/configured, you'll need to go to [irc://irc.libera.chat/](irc://irc.libera.chat). To set your nickname, type `/nick nickname` in the box and press enter.

Note that our channels require users to be registered on Libera in order to participate. Libera chat provides instructions for you to do so [here](https://libera.chat/guides/registration). If you require assistance, you can type `/join #libera` and request help.

Once you have registered and you are identified with `NickServ`, you can type `/join #rockylinux` or another related channel.

Note that subsequent logins will require you to identify. `/msg nickserv identify password` will help you to ensure you don't get locked out of the `#rockylinux*` channels.

### IRC Cloaks for libera.chat network

Cloaks allow you to show your association with the Rocky Linux project and protect your hostname from being seen from others. Cloaks can be received from a project or just by the network upon request.

If you would like to receive a cloak, contact neil or Louis on IRC or Mattermost.

## Context

This section provides context to some things mentioned throughout this document that would've likely crowded the section entirely. These sections may end up on different pages in the future, but they are here for now.

### Kernel Rebuilds

Kernel rebuilds are not recommended nor supported for Rocky Linux. Before building a custom kernel or even considering it, ask yourself the following questions:

* Is the functionality you need available by installing a kernel module from [elrepo](https://elrepo.org)?
* Is the functionality you need available as a separate module from the kernel itself?
* Are you willing to maintain your own security posture?
* **Are you sure**? Rocky Linux and most other EL derivatives were designed to function as a complete environment. Replacing critical components can affect how the system acts.
* **Are you ABSOLUTELY sure**? 99.9% of the users no longer need to build their own kernel. You may simple need a kernel module/driver, in which case, you can use [elrepo](https://elrepo.org) or build your own kernel module (kmod/dkms)
* **Are you sure you don't just want a newer kernel version**? Newer kernels can be found at [elrepo](https://elrepo.org) and soon [SIG/Kernel](https://sig-kernel.rocky.page/).

!!! warning
    As a final warning, if you break the kernel, you are on the hook for your system. Rocky Linux volunteers or developers are unable to assist you with these issues.

### Upgraded Systems

System Upgrades are generally unsupported. There are quite a few methods out there of users performing upgrades:

* Updating the system release packages (e.g., centos-release to rocky-release, or updating rocky-release to another) and running a `yum distro-sync` or `yum update`

  * Example 1: replacing centos-\* packages with rocky-\* packages and running `yum update` or `yum distro-sync`
  * Example 2: updating rocky-\* packages from 8 to 9, and then running `dnf update` or `dnf distro-sync`

* Using scripts or tools that a user may not review that promise smooth upgrades from X to Y
* Following guides that promise smooth upgrades from X to Y

Regardless of the method, a system that has been "upgraded" is generally considered unsupported, and you will be recommended to build a new system and restore from backups. Users may try to help or assist with your system, but it may be difficult to do so.

!!! note
    While the tool ELevate exists to help users transition from one major release of an Enterprise Linux to another, we have not formally tested it and we cannot officially provide assistance or feedback to the tool or an upgraded system. There may be users in the channel who have done so and can assist, but at this time it's still unsupported.

### Outdated or End of Life Releases

Outdated or End of Life releases are not generally supported. When you do not update, you are leaving your system in a vulnerable state, prone to bugs and effectively lower security posture. Do not be surprised if community members, volunteers, and channel regulars ask you to run:

* `cat /etc/os-release`
* `cat /etc/rocky-release`
* `dnf repolist`
* `dnf update`

Only the latest available `X.Y` of a given version is supported at a given time. Check out the [Rocky Linux](../rocky/) section for more information for the latest available releases and our version policies.

If you are stuck on a release due to vendor software locking or certifying only on a certain release, it is recommended that you speak with your software vendor and request information on when they plan on supporting/certifying a supported release for their software.

### Broken V Servers

Our distribution, like others, use a variant of `dnf`. All Rocky Linux releases are shipped with `dnf` and a certain set of matching configuration files (like `.repo` files). This allows your system to work with the mirror system provided by the Rocky Linux project. Some downstream forks break these configurations and make their system incompatible with what we provide off the shelf.

Regulars (developers/volunteers) will typically decline to help in this type of scenario. Below are examples of "broken V servers" where `dnf` is either missing, misconfigured, or outright crippled.

#### VPS

So you have a VPS and you've discovered `dnf` is not working as it should. This means you are not using Rocky Linux. If you are using an installation "based on" Rocky Linux but `dnf` is missing, you don't have a real Rocky Linux installation. Common examples of providers who do this:

* OpenVZ
* cPanel
* Plesk
* webmin
* Direct Admin
* BlueQuartz
* Asterisk
* Trixbox
* Elastix

The above tend to only install parts of Rocky Linux on their virtual servers and some are known for removing `dnf` from the system entirely or altering the settings in a way that is unconducive to a working Rocky Linux system. Typical changes are that they exclude locally modified packages from our base repositories. You can verify this by running `grep -ir exclude /etc/{yum,dnf}*` which will show what they are excluding. Some will also manage the box outside of the package manager.

Why these providers do this is unclear. Regardless of their reasons, this approach is seen negatively as `dnf` has mechanisms to protect specific packages from change.

Before you try anything, please **STOP** and ask your provider **why** they removed `dnf` and how are you supposed to keep your system up to date/secure without it.

#### Wait, you're saying I was lied to?

In essence, yes. A true Rocky Linux installation has a Rocky kernel and the `rocky-release` packages, as well as `dnf`, without modifications to the contents in `/etc/yum.repos.d` (other than possibly a local mirror or staged repositories). All dependencies will be satisified and with the exception of configuration files, they will be kept up to date and maintained.

A true Rocky Linux system can:

* Be updated at any time
* Provide a list of usual groups that is reproducible across systems
* Has SELinux enforcing by default
* Has a working firewall by default

You will be asked to run some commands by volunteers. Such as:

* `dnf install rpaste -y ; rpaste --sysinfo`
* `cat /etc/os-release ; uname -a ; rpm -V dnf rocky-release rocky-repos ; ls /etc/yum.repos.d/ ; dnf repolist all`

The former produces a sysinfo output (the package is installed from extras). The second produces multi-line output that you can provide at https://rpa.st. Alternatively, you will be asked just to run `uname -a` which is typically sufficient enough.

When it's clear it's not a Rocky Linux system, the regulars of the channel will not continue to offer further assistance. They do not wish to suggest a course of action that can potentially break your system further. Most regulars cannot and don't know all the ways hosting providers may have altered the functions which a Rocky Linux system provides by default.

If you were lied to, we ask that you request your provider to mend their ways. You could ask your provider:

* Stop misrepresenting what they offer as Rocky Linux
* Deliver to you what they promised or receive a refund

#### Is it possible to get dnf back?

Yes it is possible. However, it may come at a cost of breaking your system. Thus, we cannot provide such advice here.
