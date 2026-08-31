---
title: Getting Started
---

Contributing to Rocky Linux should be easy and straight forward for any user
who wishes to participate or would like to contribute in any way. This could
be through a Special Interest Group, or it could just be to the core Rocky
Linux distribution.

## Purpose

This page goes over the basic steps to signing up for an account with our
Rocky Account Services and other basics with interacting with the Rocky
ecosystem.

## Start Guide

This section will go over the very basics of signing up for an account
and filling in basic information in Rocky Account Services.

### Creating an Account

Creating and managing your Rocky account starts at Rocky Account Services.

* Go to the [Rocky Account Services](https://accounts.rockylinux.org) page and click the register tab
* Fill in the necessary boxes presented, such as user name, first and last name, and email address, and click "register"
* You will receive an activation email. Activate your account.
* Login to your account on the [Rocky Account Services](https://accounts.rockylinux.org) page

### Profile Information

When you login, you will be on your profile. Click "Edit Profile" below your
email address to make changes to your profile.

It is highly recommended that you fill out the following information on the
"Profile" tab:

* Locale
* Timezone
* Chat nicknames (if applicable)
* Your github/gitlab username

By default, if your email address has an account on [libravatar](https://www.libravatar.org),
you will automatically have a profile picture assigned. If you do not, you can create one
by clicking the "Change Avatar" button in the profile tab.

It is highly recommended that you fill out the "SSH & GPG Keys" tab. Your ssh
keys should sync to both the [Rocky Linux GitLab](https://git.rockylinux.org) and
[RESF Git Service](https://git.resf.org).

It is highly recommended that you add an OTP to your account.

### Signing Agreements

While editing your profile, there is an "Agreements" tab with all of the current
agreements for Rocky. It is highly recommended that the following is reviewed
and signed:

* Rocky Open Source Contributor Agreement
* Rocky Git Contributor Agreement

See the [details](#details) section for more information.

### Requesting Access to Groups in Rocky Account Services

Groups in Rocky Account Services define roles, access, membership to a
group, or any combination of the three. These groups can be for a Special
Interest Group or a team in the Rocky Linux project or RESF ecosystem.

In general, the baseline steps to requesting access starts here:

* Create your account in RAS
* Fill out your profile
* Sign the appropriate agreements
* Find the group or groups you wish to join and find the sponsors

  * Check out the [Special Interest Group](../special_interest_groups/index.md) page
  * Check out the [IRC and Chat Page](irc.md) page

* Contact the sponsor directly or send a message to appropriate channel for the group

Each group will have different procedures for becoming part of the groups within
Rocky Account Services. Most groups will require agreement(s) to be signed,
others may be on a per-request basis. Each group should have "sponsors" that can
be contacted with information on joining the groups. They can be contacted in
the [Rocky Linux Mattermost](https://chat.rockylinux.org).

Some sponsors may have additional documents they'll send you from the main wiki
or their dedicated wiki that will detail the procedure they expect you to follow.

## Details

This section will go over a more detailed overview of various aspects of the
Rocky Account Services as well as pieces of infrastructure you may interact
with.

### Agreements

Agreements in Rocky Account Services are there to show that you understand
and agree to the terms in how you are expected to use any Rocky-related
service.

You will find that 100% of the time, you will be required to sign at least one
of the agreements, and that's the `Rocky Open Source Contributor Agreement`. If
you plan on utilizing git.rockylinux.org or git.resf.org (as most contributors
will), signing of the `Rocky Git Contributor Agreement` is a requirement.

Before a sponsor or a team leader will add you to a group, they will have the
ability to check your profile to verify that you have signed the appropriate
agreements before proceeding. In the event your profile is set to private, this
information may be requested from Core/RelEng. If you do not or cannot agree to
the terms, you will not be able to contribute to any Rocky project. Even so,
this does not stop you from contributing to github repositories at both the
Rocky Linux github organization repositories of the RESF github organization
repositories.

## Pull Requests

Should have:

* All commits GPG signed
* Head repo either branched from or rebased onto the development branch
* Any applicable Rocky Account Services agreements signed

<h4>Resources</h4>

=== "Account Services"

    **URL**: [https://accounts.rockylinux.org](https://accounts.rockylinux.org)

    **Purpose**: Account Services maintains the accounts for almost all components of the Rocky ecosystem

    **Technology**: Noggin used by Fedora Infrastructure

    **Contact**: `~Infrastructure` in Mattermost and `#rockylinux-infra` in Libera IRC

=== "Git (RESF Git Service)"

    **URL**: [https://git.resf.org](https://git.resf.org)

    **Purpose**: General projects, code, and so on for the Rocky Enterprise Software Foundation.

    **Technology**: [Forgejo](https://forgejo.org/)

    **Contact**: `~Infrastructure`, `~Development` in Mattermost and `#rockylinux-infra`, `#rockylinux-devel` in Libera IRC

=== "Git (Rocky Linux GitLab)"

    **URL**: [https://git.rockylinux.org](https://git.rockylinux.org)

    **Purpose**: Packages and light code for the Rocky Linux distribution

    **Technology**: [GitLab](https://gitlab.com)

    **Contact**: `~Infrastructure`, `~Development` in Mattermost and `#rockylinux-infra`, `#rockylinux-devel` in Libera IRC

=== "Mirrors"

    **URL**: [https://mirrors.rockylinux.org](https://mirrors.rockylinux.org)

    **Purpose**: Users can apply to be a mirror to host Rocky content (SIG or the base operating system)

    **Technology**: MirrorManager 2

    **Contact**: `~Infrastructure` in Mattermost and `#rockylinux-infra` in Libera IRC

=== "Mail Lists"

    **URL**: [https://lists.resf.org](https://lists.resf.org)

    **Purpose**: Users can subscribe and interact with various mail lists for the Rocky ecosystem

    **Technology**: Mailman 3 + Hyper Kitty

    **Contact**: `~Infrastructure` in Mattermost and `#rockylinux-infra` in Libera IRC
