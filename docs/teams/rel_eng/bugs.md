---
title: Reporting bugs and requests for enhancement (RFE)
author: Release Engineering 
contributors: Steven Spencer 
---

The Rocky Linux project has several ways of reporting issues or requesting enhancements, depending on what the issue is and who it pertains to. The aim of this resource is to guide you to the correct location.

## Rocky Linux (core distribution)

### Bugs

!!! note

    The Bug Tracker is **not** meant for general support questions. A maintainer will close a bug immediately if it is found to be a general question rather than a bug report.

Bugs are an inevitable part of any Linux distribution. Users who find problems need a way to report the bug.

You should report all bugs in our [Bug Tracker](https://bugs.rockylinux.org).

### Bug Tracker guidelines

These guidelines are what you should expect using the Bug Tracker system.

**Mantis Bug Tracker** is a core component of the Rocky Linux distribution. If you are a bug reporter, a contributor, or even a member of the Release Engineering team, the Bug Tracker facilitates engagement for everyone. It helps resolve issues in the software available within the distribution.

As a reporter, you should follow these guidelines and expectations when reporting issues or bugs on the Bug Tracker. Following these helps to keep the queues clean, consistent, and readable. This helps the responsible party address the issue in a proper manner.

Guidelines:

* The Rocky Linux team enforces moderation - As is the case with Rocky Linux Mattermost chat, it is important to mind your language and word choice. Speak to others as you would want them to speak to you.
* The Bug Tracker is not a place for support - The Bug Tracker is for issues, bugs, and problems with the packages and software in Rocky Linux. The team closes tickets opened that are asking for support on the operating system or software. You should use our subreddit, Libera IRC channel (#rockylinux), Mattermost, or our forums, for such support.
* There is no support for custom compiled software and libraries, including those that either replace or live side-by-side with system packages. The team closes most such reports.

Expectations:

* Ensure your report goes to the correct project - There is a list of projects that accept bug reports or issues. The drop down is on the top right corner of the Bug Tracker. Choose the one most appropriate to your issue.
* Ensure that you provide relevant information - When submitting a report that might be a bug or issue, ensure that you provide relevant logs and output that can help the responsible parties to address your issue. This includes:
    * Logs from `/var/log`
    * `journalctl` logs
    * Console output in your shell or session
    * An archive created by `sosreport`
    * Patch files or workarounds
* Do **NOT** attempt to submit arbitrary scripts. The team will reject these. This includes but is not limited to `sh`, `py`, `pl` files.
* Do not submit support questions - The Bug Tracker is not a support desk. The team will close tickets of this nature. Use our reddit, Libera IRC channel (#rockylinux), or our forum, for such issues.

!!! note

    The team may ask you to reproduce the issue on Red Hat Enterprise Linux (RHEL). If the issue is reproducible on RHEL, they will encourage you to open a bug report at [Red Hat Jira](https://issues.redhat.com). The assignee on your bug report can do this for you if you wish.

#### Ticket types

While reporting bugs and issues are common with bug trackers, the tracker also accepts other reports. Such as:

* Account Removal - If you are requesting removing or disabling your account, You can do this in the Account Services section of the Bug Tracker.
* GitLab Request - There might be patch, repos missing or something else that involves a group or even a Special Interest Group (SIG).
* Rocky Services - This could be the Bug Tracker itself, the wiki, or other pieces of infrastructure.

### RFE (Request for enhancement)

Requests for enhancements to packages[^1] are typically handled in the [Bug Tracker](https://bugs.rockylinux.org). In some cases, this might not apply. A Special Interest Group (SIG) might ask that you submit an RFE elsewhere. See the SIGs section later on this page.

## Rocky Linux Infrastructure and Services

Rocky Linux Infrastructure have responsibility over several areas including:

* [Mirror Manager](https://mirrors.rockylinux.org)
* [Account Services](https://accounts.rockylinux.org)
* [RESF Git Service](https://git.resf.org)
* [Rocky Linux Git Service](https://git.rockylinux.org)
* [Mail List](https://lists.resf.org)
* General Special Interest Group requests (such as resources)

Infrastructure and Services encourages the submission of issues and requests go to their [Infrastructure Meta](https://git.resf.org/infrastructure/meta/issues) tracker.

## Special interest groups (SIGs)

Each Special Interest Group might do things differently from the next. In a majority of cases, a SIG will receive a group at the [RESF Git Service](https://git.resf.org) and a "meta" repository. However, a SIG can choose not to use this and might note on their documentation where to go instead.

Examples of SIGs that use "meta" are:

* [SIG/AltArch](https://git.resf.org/sig_altarch/meta/issues)
* [SIG/HPC](https://git.resf.org/sig_hpc/meta/issues)
* [SIG/Kernel](https://git.resf.org/sig_kernel/meta/issues)

## Other Resources

If you have reproduced a bug or an issue in RHEL or even CentOS Stream, or you want to request something for a future Enterprise Linux versions, you should submit a report to the [Red Hat Jira](https://issues.redhat.com). Below are some quick links for submitting such requests.

* [Red Hat Enterprise Linux](https://issues.redhat.com/projects/RHEL/issues/RHEL-2997?filter=allopenissues) - For RHEL bugs found in both Rocky Linux and RHEL
* [CentOS Stream](https://issues.redhat.com/projects/CS/issues/CS-1759?filter=allopenissues) - Bugs or RFE's for CentOS Stream

Depending on the package or feature, it might be something that you can request in a SIG, plus, or extras repositories. You can also request a package inclusion to EPEL at the [Red Hat Bugzilla](https://bugzilla.redhat.com).

[^1]: Packages might be for a core Rocky Linux package or a Special Interest Group package. Note that if the RFE is for a Rocky Linux core package, the team will likely reject it and might encourage you to request it upstream to CentOS Stream. If the RFE is to a package that contains `rocky-` in the name *or* it is a package that we actively patch, the team might consider it. The team encourages RFE's to prepare for upcoming features from Stream to RHEL.
