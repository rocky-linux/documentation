---
title: Rocky Releases
tags:
  - releases
  - release notes
---

You have reached the releases section of the documentation. This page provides details on the releases. The release notes deal with changes and features in the major and minor releases. You can find other release-related information here as well.

## Current supported releases

Here are the current releases:

| Release         | Codename       | Release Date  | Active Support Ends  | End of Life          | Latest/Current Version   |
|-----------------|----------------|---------------|----------------------|----------------------|--------------------------|
| Rocky Linux 8   | Green Obsidian | 2021-05-01    | 2024-05-31           | 2029-05-31           | 8.10 (2024-05-31)        |
| Rocky Linux 9   | Blue Onyx      | 2022-07-14 | 2027-05-31         | 2032-05-31         | 9.8 (2026-05-28)  |
| Rocky Linux 10  | Red Quartz     | 2025-06-11 | 2030-05-31         | 2035-05-31         | 10.2 (2026-05-29) |

!!! warning "Only the latest minor release of each major version is supported"

    The release date, active support ends date, and the end of life date, refer to the major version. In order to remain in a supported state, you need to update your operating system to the latest minor release. No minor release is supported past the release of the next minor release. For instance, 8.9 is unsupported, whereas 8.10 is supported. You should always perform a `sudo dnf upgrade` when the next minor release is available. For more information, see the section on "Timeline and terminology".

## Rocky 10

Rocky 10 (Codename "Red Quartz") has general support until 31 May 2030 and security support through 31 May 2035. The supported architectures are x86-64-v3, riscv64, aarch64, ppc64le, and s390x.

| Release Number | General Availability Date | Kernel Version  |
|----------------|---------------------------|-----------------|
| 10.0           | 2025-06-11                | 6.12.0-55.14.1  |
| 10.1           | 2025-11-25                | 6.12.0-124.8.1  |
| 10.2           | 2026-05-29                | 6.12.0-211.16.1 |

## Rocky 9

Rocky 9 (Codename "Blue Onyx") has general support until 31 May 2027 and security support through 31 May 2032. The supported architectures are x86-64-v2, aarch64, ppc64le, and s390x.

| Release Number | General Availability Date | Kernel Version  |
|----------------|---------------------------|-----------------|
| 9.0            | 2022-07-14                | 5.14.0-70.13.1  |
| 9.1            | 2022-11-26                | 5.14.0-162.6.1  |
| 9.2            | 2023-05-16                | 5.14.0-284.11.1 |
| 9.3            | 2023-11-20                | 5.14.0-362.8.1  |
| 9.4            | 2024-05-09                | 5.14.0-427.13.1 |
| 9.5            | 2024-11-19                | 5.14.0-503.14.1 |
| 9.6            | 2025-06-04                | 5.14.0-570.18.1 |
| 9.7            | 2025-12-01                | 5.14.0-611.5.1  |
| 9.8            | 2026-05-28                | 5.14.0-687.10.1 |

## Rocky 8

Rocky 8 (Codename "Green Obsidian") has general support until 31 May 2024 and security support through 31 May 2029. The supported architectures are x86_64 and aarch64.

| Release Number | General Availability Date | Kernel Version  |
| -------------- | ------------------------- | --------------- |
| 8.3 | 2021-05-01 | 4.18.0-240 |
| 8.4            | 2021-06-21                | 4.18.0-305      |
| 8.5            | 2021-11-15                | 4.18.0-348      |
| 8.6            | 2022-05-16                | 4.18.0-372.9.1  |
| 8.7            | 2022-11-14                | 4.18.0-425.3.1  |
| 8.8            | 2023-05-19                | 4.18.0-477.10.1 |
| 8.9            | 2023-11-22                | 4.18.0-513.5.1  |
| 8.10           | 2024-05-31                | 4.18.0-553      |

## Timeline and terminology

### Terminology

Throughout this page, you will see terms such as "major version" or "minor version", among others. You will see these terms used throughout many discussions online forums, mail lists, or even our Mattermost.

| Term           | Definitions |
|----------------|-------------|
| Major Version  | A whole number in the leftmost position of the version, denotes a major version, such as "Rocky Linux 9". For example, in the version 9.1, the "9" is the major version. Major version releases come with significant changes to its preceding major version. |
| Minor Version  | The number in the rightmost position of a version denotes the minor version. For example in the version "Rocky Linux 9.3", the "3" is the minor version. These updates come with version upgrades, rebases, new software and features. |
| Release        | Release typically refers to a major version release, such as "Rocky Linux 9". It is typically assumed it is referring to the latest/current version of that release. |
| Minor Release  | Used as "Minor Version" in most cases. |
| Active Support | Active Support (also known as "Full Support") is the period of time where minor releases come out every six (6) months. These provide new software, rebases, or other new features. When Active Support ends, a release receives maintenance-only updates. |
| Security Support | Security Support (also known as "Maintenance Support"), it refers to the period after the end of "Active Support". |
| General Availability | General Availability (GA) is a critical stage in the software lifecycle, where a product has completed all testing, is fully functional, and is officially released to all target users. Normally, GA does not refer to any specific version. |
| Codename | A name used internally during the product development phase to identify different development versions or stages. |
| End of Life  | In Rocky Linux, End of Life (EOL) refers to the product no longer receiving any form of updates or support. In some commercial software, EOL refers to stopping the sale of the software and then entering the EOS (End of Support) phase. |

### Timeline

Rocky Linux attempts to follow CentOS Stream development and Red Hat Enterprise Linux releases as close as possible. With this model, Rocky Linux releases should follow these upstream platforms closely.

#### Major version release

For a new Rocky Linux release, the following should be true:

* New major version is released with support of ten (10) years, starting at `.0`.
* ‌Rocky Linux will have five (5) years of "Active Support" and five (5) years of "Security Support" over its ten-year lifecycle.

    * Each major version will come with two minor version releases a year: Every six (6) months
    * Minor version releases will come with new features, software rebases, and sometimes brand new software
    * Final minor version will be `.10`

#### Minor version release

For a new Rocky Linux minor version release, the following should be true:

* Rocky releases a new minor version with new features and software.
* Rocky moves the previous minor version to the [vault](https://dl.rockylinux.org/vault/rocky/) and it is no longer supported.

However, when the minor version is `.10`, this means:

* Rocky Linux (and other Enterprise Linux distributions) go into security maintenance for the next five (5) years.
* This version of Rocky Linux will likely not receive new features, but new packages might appear occasionally.

### Release schedule

Rocky releases new major version in the month of May, and bases this on Red Hat's life cycle policy. Every May and November, Rocky releases a new minor version for all supported releases, except those that have reached a minor version of ".10". The Rocky Linux team will do their best to follow this release schedule.

The following is a general guideline to the Rocky Linux "Full Support" lifecycle, based on Red Hat documentation.

| Version | Month    |
|---------|----------|
| .0      | May      |
| .1      | November |
| .2      | May      |
| .3      | November |
| .4      | May      |
| .5      | November |
| .6      | May      |
| .7      | November |
| .8      | May      |
| .9      | November |
| .10*    | May      |

Upon each new minor release, (`X.Y+1`), the previous version becomes unsupported and the team moves this version to the [vault](https://dl.rockylinux.org/vault/).

!!! warning "X.10, where X represents the major version"

    `X.10` is the final minor release and marks the end of "active support". When it is released, that version of Rocky Linux is now in maintenance mode for the next five (5) years until End of Life, receiving only maintenance related updates. CentOS Stream X will also cease development upstream, marking that upstream's end of life.

#### General update timeline

* Updates - On the premise that the software package packaging work is normal, there are no new dependencies added upstream, and the development team makes every effort, the update should be completed within 24-48 hours after the upstream release.
* Minor releases - After the upstream releases a minor version, the team expects to take one week or more to complete the final release work. This expectation is based on the following premise: the development team will make every effort to complete the packaging process of the software package and pass the OpenQA and general testing of the testing team. As an open-source community, we cannot guarantee the GA date for minor versions.
* Major releases - After the upstream is **ready**, our team will start packaging and testing the software package, and ultimately complete the construction and release of the image. As an open-source community, we cannot guarantee the GA date for major versions.

## Policy

### Version policy

Rocky Linux attempts to follow closely with the updates of our upstreams CentOS Stream and Red Hat Enterprise Linux. This means that the Release Engineering team attempts releases as closely as possible after our upstreams.

Previous versions of packages will coexist in the repositories to allow a user to downgrade in case of a regression or other use cases (such as security only updates).

!!! note

    When a new minor release arrives, all previous updates/versions are *not* carried over and will be found in the [vault](https://dl.rockylinux.org/vault/).

Rocky Linux may release Beta versions that are very close to the upstream source code in some cases, mainly because:

* Identify issues or bugs during the build process.
* Linking the discovered issues to upstream.
* Provided convenience for members of the testing team or other members of the community to download and test.

When the status of the minor version changes to GA, it is not recommended or advisable for ordinary or experienced users to update from the Beta version to the minor version.

The following updates are not supported:

* Update the stable version of GA phase to Beta version.
* Update the Beta version to the stable version at the GA stage.

### Lifecycle policy

A release or version of Rocky Linux becomes unsupported if:

* A new Rocky Linux minor version supersedes an old minor version *or*
* The Rocky Linux release or major version is End of Life

See below for examples of unsupported releases.

#### Example: An unsupported version

When a new Rocky Linux minor release arrives in May or November, the following contentis true:

* The previous version is no longer supported by Release Engineering and the community.
* The previous version is no longer updated and moves to the [vault](http://dl.rockylinux.org/vault/rocky/).
* The previous version **does not** receive bug fix nor security updates.
* **to maintain the supported status of your system** you need to run `sudo dnf upgrade`.

#### Example: Reaching end-of-life stage

When a Rocky Linux release has reached its End of Life date typically after ten (10) years, the following contentis true:

* The major version/release is no longer supported in full by Release Engineering and the community.
* The team moves the final version of that release to the [vault](http://dl.rockylinux.org/vault/rocky/).
* This release will no longer receive any form of updates or maintenance.
* Due to increased security risks, it is recommended that individuals or businesses install a supported version of Rocky Linux and migrate your data.

If you cannot install a new system and migrate and you still need support for your system or systems, you might be able to find a support provider.

!!! warning

    Support providers will maintain their own packages and policies outside of the Rocky Linux ecosystem, and thus their policies *do not* apply here. The release is still considered EOL and unsupported by the Rocky Linux project. You should work with your support provider for any assistance.

### Major version upgrade policy

Major version upgrade refers to the operation of upgrading the current major version to another major version.

The Rocky Linux team does **not recommend** performing major version upgrades. 

The tasks performed by Rocky Linux users are quite different. If you use some tools for the major version migration, you may lose important data. The recommended approach is:

* Back up your important data in the old operating system, then install a new operating system, and import the data according to the relevant methods.

If you have any questions, comments or suggestions regarding the upgrade operation of the main version, please join our [Mattermost](https://chat.rockylinux.org/rocky-linux/channels/documentation) for discussion.
