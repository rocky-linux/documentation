---
title: Using git pull and git fetch
author: Wale Soyinka
contributors: 
tags:
  - Git
  - git pull
  - git fetch
---

## Introduction 

This Gemstone explains the differences between `git pull` and `git fetch` commands. It also outlines when to appropriately use each command.

## Git Fetch vs Git Pull 

### Git Fetch

git fetch downloads changes from a remote repository, but doesn't integrate them into your local branch.

It is especially useful for seeing what others have committed without merging those changes into your local branch.

1. List the currently checked out branch
     ```
     git branch
     ```
2. Fetch changes from the main branch of a remote repo named origin. Type:
     ```
     git fetch origin main
     ```
3. Compare the changes beween the HEAD of your local repo and remote origin/main repo. 
     ```
     git log HEAD..origin/main
     ```

### Git Pull

Git Pull downloads changes and merges them into your current branch.
Useful for quickly updating your local branch with changes from the remote repository.

1. Pull and Merge Changes**:
     ```
     git pull origin main
     ```
2. Review merged changes**:
     ```
     git log
     ```

## Additional Notes

- **Use `git fetch`**:
-- When you need to review changes before merging.
-- To avoid unwanted changes or conflicts in your local branch.

- **Use `git pull`**:
-- When you want to update your local branch with the latest commits.
-- For quick, straightforward updates without needing to review changes first.

## Conclusion

Understanding the distinctions between `git fetch` and `git pull` is vital for effective Git workflow management. It is important to choose the right command based on your requirements when working or colloborating via version control systems like github, git, gitlab, gitea and so on.