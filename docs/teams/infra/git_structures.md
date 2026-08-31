---
title: Git structures
author: Infrastructure
contributors: Steven Spencer
---

!!! info

    While this document is filed under the Infrastructure team, there is a great deal of crossover between Infrastructure and Release Engineering regarding Git services. If you ever need to ask a question regarding anything in this document, refer your question to the [RelEng & Infra](https://chat.rockylinux.org/rocky-linux/channels/releng--infra) Mattermost channel.

This document covers how the Rocky Enterprise Software Foundation (RESF) handles the use of Git in the ecosystem for the RESF and its projects such as Rocky Linux. It contains information about how various teams and the community interact and work with Git, project expectations and requirements.

!!! note

    Usage of Git services hosted by the RESF are subject to the [Rocky Git Contributor Agreement](contribute/git_agreement.md).

## General information

Git is a core component of the Rocky Linux build ecosystem, RESF projects, and one of the modes of the development process for the distribution and available software.

**Forgejo** The RESF uses this for its projects, its code, mirrored repositories, and other components.

**GitLab** The software currently in use to store RPM spec files, patches, configurations for debranding, modification to packages, and some scripts and utilities. Generally source code does not live here with the exception of src-git scenarios.

**GitHub** In use for the RESF and Rocky Linux project organizations, which might contain branding, scripts, tools, utilities, and other useful code, such as Ansible. There might also be forks of upstream projects (such as mock) to handle upstreaming changes to the Fedora Project (such as the EPEL).

## Expectations

You can find the information about how to use our Git services, the team's expectations for your conduct, and other important information, in the [Git services agreement](contribute/git_agreement.md). This is a duplicate of the information you need to agree to in Account services.

## RPM system

This section goes over the RPM system, such as importing, patching, and how it ultimately gets built into a binary RPM. This happens on [git.rockylinux.org](https://git.rockylinux.org).

### Current RPM structure

The design of the current RPM structure is to allow the orchestrator tool to import sources, and then patch them if required. It also allows the support of AppStream modules, and makes them manageable with their required YAML files.

There are four primary groups:

* **original**: contains RPM spec data that are from Rocky, such as release and logos
* **staging**: contains RPM spec data for the staging channel, such as testing the tools in that they operate and function correctly, and to test the build process.
* **release**: contains RPM spec data for the release channel, which would be the actual release that users will consume.

```text
.
├── original
│   ├── modules
│   ├── patch
│   └── rpms
├── release
│   ├── modules
│   ├── patch
│   └── rpms
└── staging
    ├── modules
    ├── patch
    └── rpms
```

Each group has three subgroups:

* **modules** group: In use to store repos that hold YAML files. The YAML files define the module that will exist in the AppStream repository.

* **patch** group: In use to hold the configuration for **distrobuild**, to pick up and patch or perform other tasks as it pertains to the RPM.

* **rpms** group: In use as the final output or import of the RPM spec file and patches (after patching, if applicable) and is then used or picked up to build the SRPM and send to koji for build.

* **src** group: Though not required, can be where a package's source exists to help create patches, if needed.

Note that Special Interest Groups (SIGs) or projects that plan on using the build system should be following this methodology.

### RPM patching structure

For the patch configuration, you must follow the layout strictly to ensure the modification of a SPEC file or its sources. An example is:

```text
.
└── ROCKY
    ├── CFG
    │   └── browser.cfg
    └── _supporting
        ├── Bug-1238661---fix-mozillaSignalTrampoline-to-work-.patch
        ├── Bug-1526653---fix_user_vfp_armv7.patch
        └── firefox-rocky-default-prefs.js
```

At the top level, the **ROCKY** folder will hold two additional folders, **CFG** and **_supporting**.

The **CFG** directory will contain files that end in `.cfg` that tell the orchestrator what to do to the imports coming in the form of an action.

```text
Action {
    file: "OriginalFile"
    with_file: "ROCKY/_supporting/RockyReplaceFile"
}
```

This goes into further detail at our [Debrand HowTo](https://wiki.rockylinux.org/team/release_engineering/debranding/) page.

### Branch strategy

Typically when making a **patch** repository, the `main` branch is where everything should be. However, there are cases where this is not sufficient, especially in the case of major release version differences. Here is a general example of how the branches will work:

* `main` is the universal branch that is always used during a patch
* `r8` is the Rocky 8 branch, specific to patching the corresponding RPM specs or patches for 8
* `r9` would be for Rocky 9
* `r9-beta` would be for Rocky 9 beta

In practice when the patch process occurs, the parsing of the `main` branch is first and is applied, and then, if there is a corresponding `rX` branch, the application of that would be next. There are cases, too, where `main` can be empty and you will just have an `rX` branch. This is acceptable and will still work.

Note that with this strategy, merging branches is never recommended in most circumstances. Try to keep them separated where possible. The only time you should merge or force-push branches, is when going from `rXlh` to `rX-beta` or `rX-beta` to `rX`.

### Submitting a potential patch

There are a few ways to submit a patch to fix build issues in the main distribution:

#### Patch repository does not exist

* If there is a package failing, or you are looking to submit a patch, for example to allow something to compile correctly on another architecture (such as `armv7` or `armhfp`).
* You found a piece of the base that was not debranded properly. In this case, you should open a bug report at our [Bug Tracker](https://bugs.rockylinux.org) with relevant information and logs.
* You can open a project under your namespace and it can eventually be transferred into `staging` after review.

#### Patch repository exists

If there is a package failing because of a failing current patch, or a there is a requirement of a new patch, perhaps debranding must occur, you generally:

1. Fork the repo into your namespace
2. Make the relevant changes
3. Apply for a merge or pull request

You should open an appropriate bug tracking ticket, if not opened already or automatically, to ensure there is documentation for this change.

## SIGs and projects

Special Interest Groups (SIGs) and projects might exist within the Rocky Linux git service. They might have RPM specs, scripts, or even their own software. These can have a somewhat different structure than the RPM structures, while following the basic methods.

### General overview

SIGs are smaller groups within the Rocky community that focus on a small set of issues or exist solely for the awareness or focus on topics.

It is typical that a SIG might end up having repositories with packages that can add-on to a Rocky Linux system. In that case, they will typically have a section in Rocky Linux GitLab under the SIG group. It is important to note that not all SIGs operate this way.

A SIG will always have an organization in RESF Git Services.

### Structure (Packaging)

Using the RPM structure as a guide, the general idea is the same. A `patch` group may not be needed, but could be useful. An example of how a SIG could set up their group might be:

```text
.
└── SIG
    └── messaging
        ├── modules
        ├── rpms
        │   └── somemq
        └── somemq
```

In this example, source code for the software `somemq` would be under the `messaging` subgroup under `SIG`. And then an RPM spec for that software, for that SIG, would sit under `rpms` as expected. However, you can further organize this further if you require.

```text
.
└── SIG
    └── messaging
        ├── modules
        ├── rpms
        │   └── somemq
        └── sources
            └── somemq
```

This is not a strict requirement, but could be good for the purposes of organization.

### Access to a SIG group

SIG group access is typically obtained by contacting a sponsor, found in [Account Services](https://accounts.rockylinux.org/), and requesting access to be a part of the SIG. Once added to the group and the `gitusers` group, you can do work within the SIG.
.

## Other Groups

Other groups generally will not exist in the Rocky GitLab instance. Rather, they will (and should) exist in the RESF Forgejo instance instead. These groups could contain repos for:

* A team's source code
* A team's set of tools or scripts
* Other miscellaneous metadata

Examples of groups are:

* Infrastructure -> This group contains repositories related for rocky infrastructure
* releng -> Release Engineering repositories and code
* sig_core -> Core Special Interest Group specifically for code and items related to Rocky Linux development and infrastructure

### Resources

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
