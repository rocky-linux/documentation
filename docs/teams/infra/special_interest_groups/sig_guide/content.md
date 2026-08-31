---
title: Managing Content
---

This section goes over how to manage content in git and the community build system.

## Importing to the RESF Git Service

All Special Interest Groups get an organization created in the RESF Git Service. Each organization will have a `meta` repository that can track issues or requests for the SIG as a whole. This is not a requirement and each SIG can dictate how issues or requests are handled.

All Special Interest Groups also get a `wiki` repository in which they can manage their documentation and content for their `sig-X.rocky.page` website.

There is no strict requirement on what repositories should and should not exist. It is up to the discretion of the SIG.

## Importing to the Rocky Linux GitLab

Special Interest Groups that build and release packages will have a subgroup under `SIG`. This subgroup will have additional subgroups, `src`, `rpms`, `modules`.

!!! info "Additional Subgroups"
    While this is the default layout, additional subgroups can be made at the root of the SIG group. It is expected that some SIG's may not have plans to build packages as they could have an entirely separate focus.

!!! info "Examples and Inspiration"
    If you are ever confused on designing your imports and packages, you may look into other sig's or even Rocky Linux itself in the `staging` group.

### src

This area is typically for the rpm sources (spec file, metadata file, and so on), with support for dist-git/src-git coming soon. While this area is optional, it is highly likely you will be using it for managing rpm sources, and uploading the tarball sources to the lookaside.

For the case of rpm sources, which is the most standard usage, imports start here. When an import occurs, these would appear in `rpms` as long as the peridot catalog configuration is made aware. **Note** that all rules from the `rpms` section below apply.

!!! info "rpm rules"
    To repeat: All rules from the `rpms` section below apply. Please ensure that you read carefully.

#### RPM Format Rules

The expectation is that you will be designing repositories to be imported here in majority of cases. As this is likely, this is the expected format:

The expected format is:

* `SOURCES/...` -- light text files, scripts, patches, etc can come here (e.g., ones not in a tar ball)
* `SPECS/name.spec` -- Your spec file comes here - note it should only be one spec file
* `.name.metadata` -- Required, lists your source archives or otherwise that will be in lookaside. Empty if there are no sources to pull from lookaside.

The metadata file format is expected to be:

```
SHA256SUM_STRING SOURCES/some_name
```

The left column is generally a hashed sum of the archive. This *is* the name of the file in lookaside. The right side is where the archive will be the location and name of where it will be copied to. For example, the `ipa` package source name is a sum in lookaside, and during processing, it will be renamed and copied to `SOURCES/freeipa-4.9.6.tar.gz`:

```
b7b91082908db35e4acbcd0221b8df4044913dc1 SOURCES/freeipa-4.9.6.tar.gz
```

Ensure that you are also using the correct branch names. See the `Branch Names` section later in this guide for further details.

### rpms

This area is specifically used for rpm sources (spec file, patches, light text files, and so on). This is where "imports" will occur and no manual intervention or manual commits are necessary. Any manual changes made will never be picked up by the build system.

### modules

This area is specifically used for modularity. If you plan on maintaining multiple versions of a package and want to use modularity, this is the place to do it. The branch names *should always match* with rpms. For example, say your module is `idm` and you have a stream named `DL1`. The branch could be `rX-stream-DL1`.

The name of the module does not necessarily have to match the actual package or package names. For example, the idm module. There is no package named `idm`, but each package as part of the module has the correct branch names as referenced in the source yaml for the module.

The format expected:

* `SOURCES/modulemd.src.txt` -- This is the initial module yaml data that will be transformed name.yaml. See [this](https://git.rockylinux.org/staging/modules/idm/-/blob/r8-stream-client/SOURCES/modulemd.src.txt) for an example.
* `.name.metadata` - Just like rpms, a metadata file is required, even though it will be empty.

As of this writing, the `name.yaml` file generated in the root may be done by the Rocky Automation account.

### Branch Names

Branch naming is **important**. **main is NOT an acceptable branch name under any cirumstances.**

You **must** use `rX` as the prefix, `X` being the major version number. All packages that are part of a SIG and will be in a peridot project together must have matching branch names.

To support multiple versions, there will need to be multiple projects and branches need to be named appropriately. Multiple versions of a package cannot coexist in a single peridot project.

#### Multiple Versions + Multiple Projects

There may be cases where:

* Multiple version of a package will exist in some form and/or
* Although the cases may be rare, sets of packages may not coexist with others and live in completely separate projects.

If this applies to your SIG, you can use branch names and the proper configuration in peridot to make this separation possible. The names of the branches are used to separate packages if need be. See the ideal template:

`rX-sig-SIGNAME-VERSION`

* `rX-sig` is considered the SIG prefix
* `SIGNAME` would be the name of the SIG (for example, `kernel`)
* `VERSION` is required. This can be numerical or simply another name/acronym.

Examples:

```
* Kernel SIG for kernel 5.15 (Rocky Linux 8): r8-sig-kernel-5.15
* Kernel SIG for kernel 5.15 (Rocky Linux 9): r9-sig-kernel-5.15
* Kernel SIG for kernel 6.1 on (Rocky Linux 8): r8-sig-kernel-6.1
* Kernel SIG for kernel 6.1 on (Rocky Linux 9): r9-sig-kernel-6.1
```

### Tagging

In the case of an rpm or a module, there should be tags associated, otherwise the build system *may not* pick up your builds. The general format for tags are as follows:

* RPM: `imports/rX[-SIGNAME-VERSION]/NEVR` (for example, `imports/r8/bash-4.4.20-2.el8` is acceptable)
  * Note: You cannot choose a tag/branch destined for one rocky release and build on another. Ensuring your tags and branches are in alignment will generally make things easier for you and other maintainers.

* Module: `imports/rX-stream-STREAM_NAME_OR_VERSION/MODULE_NAME-STREAM_NAME_OR_VERSION-X0Y00YYYYMMDDHHMMSS.ZZZZZZZZ`
  * Note: X is the major version, Y is the minor version. MODULE_NAME and STREAM_NAME_OR_VERSION are required. Ensure you fill out the timestamp as appropriate. You may fill in the final Z's with a portion of the commit hash that you are using for the tag.
  * Example: `imports/r8-stream-1.4/389-ds-1.4-8060020220204145416.ce3e8c9c`

## Peridot Project Configuration

### peridot-config repository

Each Special Interest Group will need a repository called `peridot-config` which will contain the content of the special interest group. This helps identify what repositories will exist and what exists in each repository. The default file is `catalog.cfg`. Below is just a simple example using SIG/Core.

```
# kind: resf.peridot.v1.CatalogSync
package {
  name: "some-core-tool"
  type: PACKAGE_TYPE_NORMAL_SRC
  repository {
    name: "core-common"
    include_filter: "core-tool-mgt.noarch"
    include_filter: "core-tool-keys.noarch"
  }
}

package {
  name: "some-infra-tool"
  type: PACKAGE_TYPE_NORMAL_SRC
  repository {
    name: "core-infra"
    include_filter: "infra-tool-mgt.x86_64"
    include_filter: "infra-tool-mgt.aarc64"
    include_filter: "infra-tool-mgt.s390x"
    include_filter: "infra-tool-mgt.ppc64le"
    include_filter: "infra-tool-keys.noarch"
  }
}
```

Below was a SIG/Cloud example.

```
# kind: resf.peridot.v1.CatalogSync
exclude_filter {
  repo_match: "^cloud-common$"
  arch {
    key: "*"
    glob_match: "kernel-debug-devel-matched"
  }
}
package {
  name: "kernel"
  type: 2
  repository {
    name: "cloud-common"
    # use an include filter, then exclude same NA to force an empty repo
    include_filter: "kernel-debug-devel-matched.aarch64"
  }
  repository {
    name: "cloud-kernel"
    include_filter: "kernel-debug-devel-matched.aarch64"
    include_filter: "kernel-debug-devel.aarch64"
. . .
  }
}
```

### Dist Tags

It is expected that your SIG will have a "shorthand" name assigned to you (either by core or yourself during the proposal). This name will be part of the `dist` macro that gets applied to your builds in Peridot, which serve as identifiers of where the package was built and who the package was built for. Because of this, it is a requirement that the group project's packages all have it set for the entire scope of the group. For example, if the SIG's name is "Messaging and Communication", the shorthand would be "mc", and an example package would be named:

`erlang-22.0.7-1.el9.mc.x86_64.rpm`

Some single word SIGs can be abbreviated too. Like `hyperscale` can become `hs`. There may be cases where this isn't possible and exceptions can be granted. `cloud` is an example of this.

**Note**: In majority of cases, this will be configured for the SIG and won't be user modifiable for consistency purposes.

More examples of dist tags are below:

| SIG        | Dist Tag    |
|------------|-------------|
| altarch    | elX.altarch |
| cloud      | elX.cloud   |
| core       | elX.core    |
| hyperscale | elX.hs      |

## Importing to S3

TBD. Please work with a member of Release Engineering (SIG/Core) for assistance for now. In a future peridot version, there should be more capabilities to enable users further.

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
