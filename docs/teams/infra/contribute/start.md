---
title: Getting Started
author: Infrastructure
contributors: Steven Spencer
---

Contributing to Rocky Linux should be easy for any user who wishes to participate or to contribute in any way. This could be through a Special Interest Group (SIG), or it could just be to the core Rocky Linux distribution.

## Purpose

This page goes over the basic steps to signing up for an account with our Rocky Account Services. It also covers other basics regarding interacting with the Rocky ecosystem.

## Start guide

### Creating an account

Creating and managing your Rocky account starts at Rocky Account Services.

* Go to the [Rocky Account Services](https://accounts.rockylinux.org) page and click the register tab.
* Fill in the necessary boxes presented: First name, last name, email address, and then click "register."
* You will receive an activation email. Activate your account.
* Login to your account on the [Rocky Account Services](https://accounts.rockylinux.org) page.

### Profile information

When you login, you will be on your profile. Click "Edit Profile" following your email address to make changes to your profile.

You should fill out the following information:

* Locale
* Time zone
* Chat nicknames (if applicable)
* Your github or gitlab username

By default, if your email address has an account on [libravatar](https://www.libravatar.org), you will automatically have a profile picture assigned. If you do not, you can create one by clicking the "Change Avatar" button in the profile tab.

It is a strong recommendation that you fill out the "SSH & GPG Keys" tab. Your `ssh` keys should sync to both the [Rocky Linux GitLab](https://git.rockylinux.org) and [RESF Git Service](https://git.resf.org).

The infrastructure team suggests that you add an OTP (one time password) to your account.

### Signing agreements

While editing your profile, there is an "Agreements" tab with all of the current agreements for Rocky. You should review and sign:

* Rocky Open Source Contributor Agreement
* Rocky Git Contributor Agreement

See the [details](#details) section for more information.

### Requesting access to groups

Groups in Rocky Account Services define roles, access, membership to a group, or any combination of the three. These groups can be for a Special Interest Group or a team in the Rocky Linux project or RESF ecosystem.

In general, the baseline steps to requesting access starts here:

* Create your account
* Fill out your profile
* Sign the appropriate agreements
* Find the group or groups you want to join and find the sponsors
    * Check out the [IRC and Chat page](../irc.md).
* Contact the sponsor directly or send a message to appropriate channel for the group.

Each group will have different procedures for becoming part of the groups within Rocky Account Services. Most groups will require the signing of other agreement(s). Others might be on a per-request basis. Each group should have "sponsors" that you can contact with information about joining the groups. You can contact them in the [Rocky Linux Mattermost](https://chat.rockylinux.org).

Some sponsors might have additional documents to send you.

### Agreements

Agreements in Rocky Account Services are there to show that you understand and agree to the terms and expectations for using the services.

You must sign at least one agreement, and it is the `Rocky Open Source Contributor Agreement`. If you plan on using git.rockylinux.org or git.resf.org (as most contributors will), you must also sign the `Rocky Git Contributor Agreement.`

A sponsor or a team leader will have the ability to check your profile to verify that you have signed the appropriate agreements before adding you to a group. If your profile is private, Core or Release Engineering might request this information. If you do not, or cannot, agree to the terms, you will not be able to contribute to any Rocky project. Still, this does not stop you from contributing to GitHub repositories at both the Rocky Linux GitHub, and RESF GitHub, organizations.

## Pull requests

Should have:

* All commits GPG signed.
* Head repository either branched from or rebased onto the development branch.
* Any applicable Rocky Account Services agreements signed.

### Resources

You can find Infrastructure services [additional resources here](../resource_list.md).
