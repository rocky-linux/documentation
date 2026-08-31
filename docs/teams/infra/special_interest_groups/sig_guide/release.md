---
title: Releasing Packages
---

## Release

### rocky-release packages

It is expected with Special Interest Groups that are delivering packages to have associated release packages that provide:

* Repo file(s) for dnf
* GPG key associated with the signing of your packages

!!! info "Key/Package Restrictions"
    The Special Interest Group cannot submit a key nor can they have access to the private key. A SIG cannot submit their own release package.

During the initial request process, a GPG key is assigned to you in the build system to be used to sign your packages. A release package must be requested to be built and submitted to the extras repository. In the event that a release package was not requested nor fulfilled during the initial request, a new request can be opened at [SIG/Core Issues](https://git.resf.org/sig_core/meta).

When submitting the request, click on the "[New Issue](https://git.resf.org/sig_core/meta/issues/new/choose)" button and then click "[Get Started](https://git.resf.org/sig_core/meta/issues/new?template=.gitea%2fISSUE_TEMPLATE%2fsig_release_request.md)" for "Requests for SIG Release Package" and fill out the template as shown, which includes:

  * An introduction of yourself and the request for the release package
  * Number of repositories and names
  * Note if there are plans for multiple versions of software
  * Note if there are modularity repositories
  * Which major versions you are targeting (Rocky Linux 8, 9, and so on)
  * Other details if needed

### Releasing Packages for your SIG

TBD. As of now, releasing requires feedback to Release Engineering (SIG/Core) to push out to mirrors.

### Directory Format for Repositories (Informational)

This is informational more than anything, but it is important for a SIG to know where their exported repositories will live.

Repositories will be formatted as such:

`/pub/sig/MAJOR/NAME/ARCH/PKG_OR_REPO`

This basically means that the sig directory will live along side the main distribution directories, potentially at the root a mirror. At `/pub/rocky` you'll see each supported major version. At `/pub/sig` you'll also see major versions, with a different structure. Let's break it down.

* `NAME` can be the name of the SIG or the abbreviation code (eg, cloud, kernel, mcs)
* `MAJOR` is the major version that's being targeted (8, 9, so on)
* `ARCH` is for the architecture
* `PKG_OR_REPO` could be for the specific set of packages of just any repository. (For example, you could have a "common" directory alongside the others)

Let's say for the sake of the example we need some repositories for mcs and we build for x86_64 and aarch64. It could look like this. This assumes the messaging and communication SIG has not only an ejabberd repository, but also a "common" repository that is perhaps shared with ejabberd and potentially another set of packages in the future.

```
.
├── rocky
│   ├── 8
│   └── 9
└── sig
    ├── 8
    │   └── mcs
    │       ├── aarch64
    │       │   ├── ejabberd
    │       │   │   ├── Packages
    │       │   │   └── repodata
    │       │   └── mcs-common
    │       │       ├── Packages
    │       │       └── repodata
    │       └── x86_64
    │           ├── ejabberd
    │           │   ├── Packages
    │           │   └── repodata
    │           └── mcs-common
    │               ├── Packages
    │               └── repodata
    └── 9
        └── mcs
            ├── aarch64
            │   ├── ejabberd
            │   │   ├── Packages
            │   │   └── repodata
            │   └── mcs-common
            │       ├── Packages
            │       └── repodata
            └── x86_64
                ├── ejabberd
                │   ├── Packages
                │   └── repodata
                └── mcs-common
                    ├── Packages
                    └── repodata
```

### Mirror List Queries (Informational)

Queries to a mirror list for SIG repositories will be like the standard calls, but repo names will have a format of `sig-NAME-MAJOR`. `NAME` can be a simple SIG name or abbreviate or a combination, for example, `sig-mcs-common` or `sig-cloud`.

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
