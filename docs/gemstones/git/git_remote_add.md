---
title: Adding a remote repository using git CLI
author: Wale Soyinka
contributors: Ganna Zhyrnova
tags:
  - GitHub
  - git
  - git remote
  - git fetch
---

## Introduction

This Gemstone illustrates how to add a specific remote repository to an existing local clone of a FOSS project using the Git command-line interface.
We'll use the repository of the Rocky Linux documentation project as our example FOSS project - <https://github.com/rocky-linux/documentation.git>

## Prerequisites

- A GitHub account.
- `git` installed on your system.
- A local clone of a FOSS project repository.

## Procedure

1. Open a terminal and change your working directory to the folder containing your local clone of the project.
  For example if you cloned the github repo to  ~/path/to/your/rl-documentation-clone, type

     ```bash
     cd ~/path/to/your/rl-documentation-clone
     ```

2. Before making any changes, list the remotes you have configured. Type:

   ```bash
   git remote -vv
   ```

   If this is a freshly cloned repo, you will likely see a lone remote named `origin` in your output.

3. Add the Rocky Linux Documentation Repository (`https://github.com/rocky-linux/documentation.git`) as a new remote to your local repository. Here, we'll assign upstream as the name for this particular remote. Type:

     ```bash
     git remote add upstream https://github.com/rocky-linux/documentation.git
     ```

4. To further emphasize that the names assigned to remote repositories are arbitrary, create another remote named rocky-docs that points to the same repo by running:

   ```bash
   git remote add rocky-docs https://github.com/rocky-linux/documentation.git
   ```

5. Confirm that the new remote repository has been added successfully:

     ```bash
     git remote -v
     ```

     You should see `upstream` listed along with its URL.

6. Optionally, before you start making any changes to your local repo, you can fetch data from the Newly Added Remote.
  Fetch branches and commits from the newly added remote by running:

     ```bash
     git fetch upstream
     ```

## Additional Notes

- *Origin*: This is the default name Git gives to the remote repository from which you cloned. It's like a nickname for the repository URL. When you clone a repository, this remote repository is automatically set as "origin" in your local Git configuration. The name is arbitrary but conventional.

- *Upstream*: This often refers to the original repository when you've forked a project.
   In open-source projects, if you fork a repository to make changes, the forked repository is your "origin", and the original repository is typically referred to as "upstream". The name is arbitrary but conventional.

   This subtle distinction between the uses/assignment of origin and remote is crucial for contributing to the original project through pull requests.

## Conclusion

The git CLI utility makes it easy to use a descriptive name and add a specific remote repository to a local clone of a FOSS project. This allows you to sync with and contribute to various repositories effectively.
