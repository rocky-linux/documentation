---
title: Document versioning using two remotes 
author: Steven Spencer
contributors: Ganna Zhyrnova
tags:
  - contributing
  - documentation
  - versioning
---

## Introduction

In the early Fall of 2025, the documentation team moved from a single version of documentation covering all versions to each version having its own documentation branch. This makes it easier to differentiate between instructions across versions. It *does*, however, complicate the process of writing or fixing documentation, particularly if it is for an older version (Rocky Linux 8 or 9). This document outlines a strategy for handling the process using a double-remote approach.

!!! info "Rocky Linux Versions"

    As of this date, October 2025, the versions are as follows:

    | Branch | Version |
    |--------|---------|
    | main   | Rocky Linux 10 |
    | rocky-9 | Rocky Linux 9 |
    | rocky-8 | Rocky Linux 8 |

## Prerequisites

* A personal GitHub account with [SSH keys already in use](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account)
* An existing fork of the Rocky Linux documentation
* A little knowledge about the use of `git` at the command line or a willingness to learn
* Have the `git` utility installed

## Cloning the repository

Cloning the Rocky Linux repository moves a copy of the Rocky Linux documentation into your workstation in a `/documentation` directory. You might have read at some point, or in other GitHub projects, that you should always clone from your personal fork of the project. In this case, for your clone to be version-aware, this is not the case. You want to clone from the Rocky Linux project. This document will explain why that is the case as it goes along. In addition, you will need to rename your git remotes so that they make logical sense (Rocky Linux "upstream" and your GitHub "origin").

1. Clone the Rocky Linux documentation:

    ```bash
    git clone git@github.com:rocky-linux/documentation.git
    ```

1. Change into the `/documentation` directory:

    ```bash
    cd documentation
    ```

1. Check the remote name:

    ```bash
    git remote -v
    ```

    This will show:

    ```bash
    origin git@github.com:rocky-linux/documentation.git (fetch)
    origin git@github.com:rocky-linux/documentation.git (push)
    ```

    You want this resource to be "upstream" rather than "origin".

1. Change the remote name

    ```bash
    git remote rename origin upstream
    ```

    Running the `git remote -v` again will now show:

    ```bash
    upstream git@github.com:rocky-linux/documentation.git (fetch)
    upstream git@github.com:rocky-linux/documentation.git (push)

    ```

## Adding your fork as a remote

With the Rocky Linux remote added and properly named, you need to set your personal GitHub fork as the origin remote.

1. For this step, you will need to know your GitHub user name, which you should already know. Replace the "[username]" field with the correct name. Add your remote:

    ```bash
    git remote add origin git@github.com:[username]/documentation.git
    ```

1. Check your git remotes:

    ```bash
    git remote -v
    ```

    This will show:

    ```bash
    origin git@github.com:[username]/documentation.git (fetch)
    origin git@github.com:[username]/documentation.git (push)
    upstream git@github.com:rocky-linux/documentation.git (fetch)
    upstream git@github.com:rocky-linux/documentation.git (push)
    ```

## Checking for updates and adding the version branches to your fork

1. With the remotes added, start by pulling any updates from upstream and pushing them to origin. If you have just created your fork and your remotes, then there will be no updates to push, but it is a good idea to start with this:

    ```bash
    git pull upstream main && git push origin main
    ```

1. Make your local clone aware of the branches that exist on the `upstream` with:

    ```bash
    git fetch upstream
    ```

1. Check out one of the two older version branches:

    ```bash
    git checkout rocky-8
    ```

    !!! warning "This does not work if your clone was from your fork."

        This is why the cloning process is done from Rocky Linux instead of from your fork. Your fork will not be aware of the older branches. To get the message that follows, you *must* clone your local documentation repository from Rocky Linux. 

    If you have set up your remotes correctly, you should now see:

    ```bash
    branch 'rocky-8' set up to track 'upstream/rocky-8'.
    Switched to a new branch 'rocky-8'
    ```

    This effectively creates a local branch `rocky-8`. Your next step is to pull any changes from 'rocky-8' and push them to your origin. There should not be any changes locally, but the branch does not exist on your fork, so this process will create it:

    ```bash
    git pull upstream rocky-8 && git push origin rocky-8
    ```

    You will probably get a message that you can create a pull request from the push. You can ignore this. What has happened is that your fork now has a `rocky-8` branch.

1. Check out the remaining older branch. (`rocky-9`) and repeat the steps you just ran with that branch.

Once completed, you will now have `main`, `rocky-8`, and `rocky-9` branches on your local fork and clone, and will be able to write documentation on any of those branches.

## Writing a document or updating an existing document on an older version

If you are familiar with writing a pull request (PR) against the `main` branch of the documentation, this process still works as it always has. Just remember that `main` is for the newest version (10 at the time of this writing). To make a small change to one of the older versions, you first need to create a branch for editing locally based on that branch. To do that, use the `-b` option with your `git checkout` command. This command creates a branch called `8_rkhunter_changes` and bases it on the `rocky-8` branch:

```bash
git checkout -b 8_rkhunter_changes rocky-8
```

You can now edit the file you want to change, and it will use the version of that document from the `rocky-8` branch.

Once completed editing, save, stage, and commit your changes as usual, and then push your changes to your `origin` remote:

```bash
git push origin 8_rkhunter_changes
```

When you create the PR, though, GitHub will automatically treat it as a change to the `main` branch, even though you specifically used the `rocky-8` branch when modifying the document. Take care not to create the PR too quickly when you see this wrong comparison screen:

![Wrong comparison](../images/incorrect_comparison_branchb_blur.png)

What you need to do here is change the comparison branch to the correct (`rocky-8` in this case) branch:

![Right comparison](../images/correct_comparison_branch_blur.png)

After correcting the comparison branch, continue creating the PR and wait for it to be merged.

## Updating your older version branches after a merge

Just as with the `main` branch, it is a good idea to keep your older version branches up to date with any changes. The following set of commands will update *all* of your versions so that they match the upstream:

```bash
git checkout rocky-8
git pull upstream rocky-8 && git push origin rocky-8
git checkout rocky-9
git pull upstream rocky-9 && git push origin rocky-9
git checkout main
git pull upstream main && git push origin main
```

After completing these commands, all your local branches and your fork will be up to date.

## Conclusion

This document walks you through a double-remote strategy for dealing with new documents or corrections since the creation of document versions.
