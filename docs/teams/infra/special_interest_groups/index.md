---
title: Special Interest Groups
---

Special Interest Groups are a core component of the Rocky Linux community, in
which various members of these groups can extend the Enterprise Linux experience,
by way of packages, images, and/or other community engagement.

For the case of this wiki, Special Interest Groups are recommended not to have
direct wiki pages, but instead maintain their own wiki pages, maintained at
the [RESF Git Service](https://git.resf.org).

This page serves simply as an overview to Special Interest Groups. See the
[SIG Guide](sig_guide/index.md) for specific information such as proposing a SIG,
content management, and much more.

See the [Current SIGs](current.md) page for a list of current Special Interest
Groups that may or may not be active in the community.

## Special Interest Group Requirements

We expect SIGs to satisfy some basic requirements, such as:

* The group should be related to Rocky Linux, a use-case for Rocky Linux or Enterprise Linux, or related to Enterprise Linux as a whole
* There must be feedback and control into the Rocky Linux community
* All communication as to the work of the SIG should be public - Some matters may have to be private, and as such should be out of band
    * It is expected that each SIG will have a public channel as `SIG/name` in mattermost. Optionally an IRC channel can also be linked to the Mattermost channel, if requested.
* Code produced within the SIG must be compatible with a FOSS license presently used by Rocky Linux - If a new license is wanted, consult with Release Engineering/Core or the `~Legal` channel in mattermost.
* All documentation and information of the SIG should be on a wiki produced in the [RESF Git Service](https://git.resf.org).
* All documentation produced within the SIG must be a compatible documentation license
* Groups should be aware/watchful of the direction from the Release Engineering team/Core as it can affect how SIGs operate if they are producing compiled software.
* Groups should maintain minutes of past meetings and record decisions made within and without of those meetings for transparency

### Onboarding

Each SIG is expected to implement the guidelines set forth in the [SIG Onboarding Guide](onboarding.md) to welcome and facilitate contributions for new members.

When onboarding a new member, follow the guidelines in the [SIG Onboarding Guide - Leads](onboarding_leads.md).

Leads are welcome and encouraged to maintain a customized set of instructions on the SIG wiki--especially for instructions that are unique to the SIG.

## Special Interest Group Wiki

Each SIG should have a wiki that will have documentation for their particular group as well as information on how the group operates. Required information should be as follows:

* An "about" section on the index that explains what the group does/a group description
* Mission Statement
* How to Contribute / Onboarding Process
* Meeting Information (time, location, other information that they feel is important)
* Policies and Resources, if applicable

## SIG Membership and Participation

The following rules apply for SIG membership:

* Mailing lists of SIGs are open and can be joined freely
* SIG members are appointed/approved by SIG sponsors/leaders - The sponsors/leaders typically have write permissions to relevant wikis and git repos
* SIG sponsors/leaders may be asked to be a mailing list moderator
* SIG channels will be public under a name such as `SIG/name` with an optional IRC channel to be bridged.
* Optionally: define if work with CentOS Stream will be applicable for the SIG

Special Interest Groups (SIGs) in Rocky Linux are required to report quarterly, summarizing their accomplishments, challenges, and overall health. Below is a suggested outline and template for creating your quarterly report.

Completion of these reports helps the Community team have a large selection of content to promote and market so the SIG can grow in membership and usage.

### Suggested Outline:

* **Membership Update**: Include details on new members, departures, and any changes in sponsors or leaders.
* **Releases**: List releases from the current quarter (or previous quarter if there have been no new releases).
* **General Activity/Health Report**: Provide a summary of the overall activity and health of the SIG.
* **Issues**: Identify any issues the SIG is currently facing and any actions being taken to address them.

### Markdown Template

```markdown
# [SIG Name] Quarterly Report
_**Quarter:** [Specify the quarter and year]_

## 1. Membership Update
* **New Members**:
  - [Name], [Role]
  - [Name], [Role]
* **Departed Members**:
  - [Name], [Role]
* **Sponsor/Leader Changes**:
  - [Name], [New Role]

## 2. Releases
* **Released in Current Quarter**:
  - [Package/Version] - [Release Date]
    - Short description of the release.
  - [Package/Version] - [Release Date]
    - Short description of the release.
* **No new releases this quarter. Releases from previous quarter**:
  - [Product/Version] - [Release Date]
    - Short description of the release.

## 3. General Activity/Health Report
* **Project Updates**:
  - Brief summary of ongoing projects.
  - Goals achieved, milestones reached.
* **Meetings Held**: 
  - [Date] - Summary
  - [Date] - Summary
* **Collaboration**:
  - Summary of collaboration with other SIGs or external groups.

## 4. Issues
* **Current Issues**:
  - Description of issue 1 and steps taken to address it.
  - Description of issue 2 and steps taken to address it.
* **Upcoming Challenges**:
  - Description of any anticipated challenges in the next quarter.

### Additional Notes
* [Any additional notes or comments relevant to the report.]

## Conclusion
* Brief conclusion or call to action for SIG members.
```

## Joining a Special Interest Group

Joining an established Special Interest Group should be simple. Each SIG will
have its own process and outlines, but the general process can be seen [here](onboarding.md).
Please see sponsors or other members of the Special Interest Group you're interested in if
you can't find an answer to your question

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
