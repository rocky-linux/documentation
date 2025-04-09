---
title: Fetch and Distribute RPM Repository with Pulp
author: David Gomez
contributors: Steven Spencer 
tested with: 9.2
tags:
- Fetch
- Distribute
- RPM
- Repository
- Pulp
---

## Introduction

Developers who use Rocky Linux will often run into situations where they will require different remote rpm repositories to support their operations. Pulp is an open source project that can help developers meet this need by helping to facilitate fetching and distributing different RPM repositories. This guide shows a simple example of using Pulp to fetch BaseOS and AppStream from Rocky Linux vault.

## Requirements

* A Rocky Linux system
* Able to run containers

## Setup - Single Container

There are many setups possible for Pulp but for ease of illustration this guide will use the single container deployment scenario. Pick a directory for Pulp and create the following directories and files.

```bash
mkdir -p settings/certs pulp_storage pgsql containers
echo "CONTENT_ORIGIN='http://$(hostname):8080'" >> settings/settings.py
```

If you have SELinux enabled, run the following to deploy Pulp. If SELinux is not enabled, then you can remove the `:Z` suffix from the `--volume` lines:

```bash
$ podman run --detach \
             --publish 8080:80 \
             --name pulp \
             --volume "$(pwd)/settings":/etc/pulp:Z \
             --volume "$(pwd)/pulp_storage":/var/lib/pulp:Z \
             --volume "$(pwd)/pgsql":/var/lib/pgsql:Z \
             --volume "$(pwd)/containers":/var/lib/containers:Z \
             --device /dev/fuse \
             pulp/pulp
```

If you browse to `http://localhost:8080/pulp/content/` you should now see "Index of /pulp/content/" that for now is empty, but that you will populate with your repositories by the end of this guide.

## Create Pulp Remotes

Think of Pulp remotes as remote source repositories. In this case, the remote source repositories are BaseOS and AppStream from Rocky Linux 9.2 vault. You will use these remotes to sync to your repositories that you will create with Pulp. Please check the [Pulp official documentation](https://pulpproject.org/) for more on remote policies.

```bash
pulp rpm remote create --name "rocky_92_appstream_vault" --url "https://dl.rockylinux.org/vault/rocky/9.2/AppStream/x86_64/os/" --policy on_demand
pulp rpm remote create --name "rocky_92_baseos_vault" --url "https://dl.rockylinux.org/vault/rocky/9.2/BaseOS/x86_64/os/" --policy on_demand
```

## Pulp Repository Copies

These will be one-to-one repository copies of BaseOS and AppStream from Rocky Linux 9.2 vault. If you know the remote that you want to use to sync from for your repositories, then you can add those remotes at the time of repository creation. Otherwise, if you do not know what remotes to use, or if those remotes can change, then you can leave the remotes out. For this guide, the declaration of the remotes occurs at the time of repository creation.

```bash
pulp rpm repository create --name "R92_AppStream_Vault" --remote "rocky_92_appstream_vault"
pulp rpm repository create --name "R92_BaseOS_Vault" --remote "rocky_92_baseos_vault"
```

## Pulp Sync Copies

!!! note

    It is important to add "--skip-type treeinfo", otherwise instead of just BaseOS or AppStream, you end up with a weird mix of both. This probably due to an issue with repositories that are not dependency closed. If the remote was not specified before, you can add it, otherwise, if you added it at time of creation, it is not necessary to mention the remote in the sync as it is implied.

```bash
pulp rpm repository sync --name "R92_AppStream_Vault" --skip-type treeinfo
pulp rpm repository sync --name "R92_BaseOS_Vault" --skip-type treeinfo
```

## Pulp Publish Publications

Once the syncing of your repositories from the remotes is complete, you will want to create the publications from those repositories to serve up to the distributions. So far you have been able to get by just using names of remotes and repositories, however, Pulp relies on `hrefs` as well, and you can use them interchangeably. After creating the publication, make sure to take note of the `pulp_href` value of each as they will be necessary for the next step.

```bash
pulp rpm publication create --repository "R92_AppStream_Vault"
pulp rpm publication create --repository "R92_BaseOS_Vault"
```

## Pulp Create Distributions

With the `pulp_href` from the previous publication step, you can now serve up that content to a distribution. This content will then show under `http://localhost:8080/pulp/content/` and no longer be empty. You can double-check the `pulp_href` of the publications by using `pulp rpm publication list` and look for `pulp_href`. As an example, a `pulp_href` for BaseOS is below, but your `pulp_href` could be different so swap accordingly.

```bash
pulp rpm distribution create --name "Copy of BaseOS 92 RL Vault" --base-path "R92_BaseOS_Vault" --publication "/pulp/api/v3/publications/rpm/rpm/0195fdaa-a194-7e9d-a6a9-e6fd4eaa7a20/"
pulp rpm distribution create --name "Copy of AppStream 92 RL Vault" --base-path "R92_AppStream_Vault" --publication "<pulp_href>"
```

If you check `http://localhost:8080/pulp/content/` you should see your two repositories that are copies of the Rocky Linux 9.2 AppStream and BaseOS vault repositories.

## Conclusion

Pulp can be a very versatile tool used to fetch multiple repositories and distribute them as needed. This is a basic example, however, you can use Pulp in a variety of deployment scenarios and do more complex and advanced repository organization. Please check the [official documentation](https://pulpproject.org/) for more information.
