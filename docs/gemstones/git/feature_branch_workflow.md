---
title: Feature Branch Workflow in Git
author: Wale Soyinka
contributors: 
tags:
  - git
  - Feature Branch Workflow
  - GitHub
  - gh
  - git fetch
  - git add
  - git pull
  - git checkout
---

## Feature Branch Workflow

This popular git workflow involves creating new branches for every new feature or fix directly in the main repository. 
It’s usually employed in projects where contributors have direct push access to the repository.

This Gemstone outlines the process of setting up a local repository to work on and contribute to the `rocky-linux/documentation` project using the Git Feature Branch Workflow. 

The user "rockstar" has forked this repository, and we will use `https://github.com/rockstar/documentation` as the origin.

## Prerequisites 

- A GitHub account and a fork of the project (e.g., `https://github.com/rockstar/documentation`).
- `git` and `GitHub CLI (gh)` installed.

## Procedure

1. If not already done, clone your fork:
   ```bash
   git clone https://github.com/rockstar/documentation.git
   cd documentation
   ```
2. Add the upstream remote:
   ```bash
   git remote add upstream https://github.com/rocky-linux/documentation.git
   ```
3. Fetch Upstream changes:
   ```bash
   git fetch upstream
   ```
4. Create a New Feature Branch:
   ```bash
   git checkout -b feature-branch-name
   ```
5. Make changes, add new files and commit them:
   
     ```bash
     git add .
     git commit -m "Implementing feature X"
     ```
6. Keep Your Branch Updated. Regularly merge changes from upstream to avoid conflicts:
     ```bash
     git pull upstream main --rebase
     ```
7. Push to your fork, type:
   ```bash
   git push origin feature-branch-name
   ```
8. Create a Pull Request:
   ```bash
   gh pr create --base main --head rockstar:feature-branch-name --title "New Feature X" --body "Long Description of the feature"
   ```

## Conclusion

The Feature Branch workflow is a common collaboration technique, allowing teams to work concurrently on various aspects of a project while maintaining a stable main codebase. 

The high-level steps involved are:
   
1. Clone the Main Repository: Directly clone the main project repository to your local machine.
2. Create a Feature Branch: For every new task, create a new branch off the main branch with a descriptive name.
3. Commit Changes: Work on the feature or fix in your branch and commit changes.
4. Keep Branch Updated: Regularly merge or rebase with the main branch to stay updated with its changes.
5. Open a Pull Request: Once your feature is ready, push the branch to the main repository and open a PR for review.
6. Code Review and Merge: After review and approval, the branch is merged into the main branch.

*Benefits*:

- Streamlines contributions for regular contributors with direct repository access.
- Ensures each feature is reviewed before being integrated into the main codebase.
- Helps maintain a clean and linear project history.
