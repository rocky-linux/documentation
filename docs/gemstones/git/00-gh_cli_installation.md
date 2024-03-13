---
title: Installing and Setting Up GitHub CLI on Rocky Linux
author: Wale Soyinka
Contributor: Ganna Zhyrnova
tags:
  - GitHub CLI
  - gh
  - git
  - github
---

## Introduction 

This gemstone covers the installation and basic setup of the GitHub CLI tool (gh) on the Rocky Linux system. This tool enables users to interact with GitHub repositories directly from the command line.

## Problem Description

Users need a convenient way to interact with GitHub without leaving the command line environment.

## Prerequisites 

- A system running Rocky Linux
- Access to a terminal
- Basic familiarity with command-line operations
- An existing Github account

## Procedure

1. **Install GitHub CLI repo using curl**:
   Use the curl command to download the official repository file for `gh`. The downloaded file will be saved under the /etc/yum.repos.d/ directory. After downloading, use the dnf command to install `gh` from the repository. Type:

   ```bash
   curl -fsSL https://cli.github.com/packages/rpm/gh-cli.repo | sudo tee /etc/yum.repos.d/github-cli.repo
   sudo dnf -y install gh
   ```
2. **Verify Installation**:
   Ensure that `gh` is correctly installed. Type:

   ```bash
   gh --version
   ```
3. **Authenticate with GitHub**:
   Log in to your GitHub account. Type:
   
   ```bash
   gh auth login
   ```
   Follow the prompts to authenticate.

## Conclusion

You should now have the GitHub CLI installed and set up on your Rocky Linux 9.3 system, allowing you to interact with GitHub repositories directly from your terminal.

## Additional Information (Optional)

- The GitHub CLI provides various commands, such as `gh repo clone`, `gh pr create`, `gh issue list`, and so on.
- For more detailed usage, refer to the [official GitHub CLI documentation](https://cli.github.com/manual/).
