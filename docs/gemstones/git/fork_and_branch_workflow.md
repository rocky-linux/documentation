---
title: Fork and Branch Git workflow
author: Wale Soyinka
contributors: Ganna Zhyrnova
tags:
  - GitHub
  - git
  - gh
  - git fetch
  - git add
  - git pull
  - git checkout
  - gh repo
---

## Fork and Branch Workflow

In this workflow type, contributors fork the main repository to their own GitHub account, create feature branches for their work, and then submit contributions via pull requests from these branches.

This Gemstone walks through how to set up a local repository to contribute to a GitHub project. It starts with the initial project forking, setting up a local and remote repository, committing changes, and creating a pull request (PR) to submit your contributions.

## Prerequisites 

- A GitHub account.
- `git` and `GitHub CLI (gh)` installed on your system.
- A personal fork of the project on GitHub.

## Procedure 

1. If it doesn't already exist, create a fork of the project using the gh utility. Type:
   ```
   gh repo fork rocky-linux/documentation --clone=true --remote=true
   ```
   The options used in this *gh repo fork* command are:
   - `--clone=true`: Clones the forked repository to your local machine.
   - `--remote=true`: Adds the original repository as a remote, allowing you to sync future updates.
2. Navigate to the local repository directory. Type:
   ```
   cd documentation
   ```
3. Verify that all the relevant remote repos have been properly configured in your local repo, type:
   ```
   git remote -vv
   ```
4. Fetch the latest changes from the upstream remote:
   ```
   git fetch upstream
   ```
5. Create and checkout a new feature branch named your-feature-branch:
   ```
   git checkout -b your-feature-branch
   ```
6. Make changes, add new files, and commit your changes to your local repo:
   ```
   git add .
   git commit -m "Your commit message"
   ```
7. Sync with the main branch of the remote repo named `upstream`:
   ```
   git pull upstream main
   ```
8. Push changes to your Fork**:
   ```
   git push origin your-feature-branch
   ```
9. Finally, create a Pull Request (PR) using the `gh` CLI application:
   ```
   gh pr create --base main --head your-feature-branch --title "Your PR Title" --body "Description of your changes"
   ```
   The options used in this *gh pr create* command are:
   
   `--base` main: Specifies the base branch in the upstream repository where the changes will be merged.
   `--head` your-feature-branch: Indicates the head branch from your fork that contains the changes.
   `--title` "Your PR Title": Sets the title for the pull request.
   `--body` "Description of your changes": Provides a detailed description of the changes in the pull request.


## Conclusion

The Fork and Branch workflow is another common collaboration technique.
The high-level steps involved are:

1. Fork the Repository: Create a personal copy of the project's repository on your GitHub account.
2. Clone the Fork: Clone your fork to your local machine for development work.
3. Set Upstream Remote: To stay updated with its changes, add the original project repository as an 'upstream' remote.
4. Create a Feature Branch: Create a new branch from the updated main branch for each new feature or fix. Branch names should describe the feature or fix it.
5. Commit Changes: Make your changes and commit them with clear and concise commit messages.
6. Sync with Upstream: Regularly sync your fork and feature branch with the upstream main branch to incorporate new changes and reduce merge conflicts.
7. Create a Pull Request (PR): Push your feature branch to your fork on GitHub and open a PR against the main project. Your PR should clearly describe the changes and link to any relevant issues.
8. Respond to Feedback: Collaborate on review feedback until the PR is merged or closed.

Benefits:

- Isolates development work to specific branches, keeping the main branch clean.
- It makes it easier to review and integrate changes.
- Reduces the risk of conflicts with the main project’s evolving codebase.
