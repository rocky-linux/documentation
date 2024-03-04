---
title: Editing or Changing the Title of an Existing Pull Request via CLI
author: Wale Soyinka
contributors:
tags:
  - GitHub
  - Pull Request
  - Documentation
  - CLI
---

## Introduction 

This Gemstone explains how to edit or change the title of an existing pull request (PR) in a GitHub repository, using both the GitHub web interface and CLI.

## Problem Description

Sometimes, there may be a need to modify the title of a PR after its creation to better reflect the current changes or discussions.

## Prerequisites 

- An existing GitHub pull request.
- Access to GitHub web interface or CLI with necessary permissions.

## Procedure

### Using the GitHub CLI

1. **Check Out the Corresponding Branch**:
   - Ensure you are on the branch associated with the PR.
     ```bash
     git checkout branch-name
     ```

2. **Edit the PR Using the CLI**:
   - Use the following command to edit the PR:
     ```bash
     gh pr edit PR_NUMBER --title "New PR Title"
     ```
   - Replace `PR_NUMBER` with the number of your pull request and `"New PR Title"` with the desired title.

## Additional Information (Optional)

- Editing a PR title will not affect its discussion thread or code changes.
- It's considered good practice to inform collaborators if significant changes are made to a PR title.

## Conclusion

By following these steps, you can easily change the title of an existing pull request in a GitHub repository, through the GitHub CLI tool (gh).
