---
title: 1st time contribution to Rocky Linux Documentation via CLI
author: Wale Soyinka
contributors:
tags:
  - GitHub
  - Rocky Linux
  - Contribution
  - Pull Request
  - CLI
---

## Introduction 

This Gemstone details how to contribute to the Rocky Linux documentation project using only the command line interface (CLI). It covers forking the repository the 1st time and creating a pull request.
We'll use contributing a new Gemstone document in our example.

## Problem Description

Contributors may prefer or need to perform all actions via the CLI, from forking repositories to submitting pull requests for the first time.

## Prerequisites 

- A GitHub account
- `git` and `GitHub CLI (gh)` installed on your system
- A markdown file ready for contribution

## Solution Steps

1. **Fork the Repository Using GitHub CLI**:
   Fork the upstream repository to your account.
   ```bash
   gh repo fork https://github.com/rocky-linux/documentation --clone
   ```

2. **Navigate to the Repository Directory**:
   ```bash
   cd documentation
   ```

3. **Add the Upstream Repository**:
   ```bash
   git remote add upstream https://github.com/rocky-linux/documentation.git
   ```

4. **Create a New Branch**:
   Create a new branch for your contribution. Type:
   ```bash
   git checkout -b new-gemstone
   ```

5. **Add Your New Document**:
   Use your favorite text editor to create and edit your new contribution file. 
   For this example, we'll create a new file named `gemstome_new_pr.md` and save the file under the  `docs/gemstones/` directory. 

6. **Commit Your Changes**:
   Stage and commit your new file. Type:
   ```bash
   git add docs/gemstones/gemstome_new_pr.md
   git commit -m "Add new Gemstone document"
   ```

7. **Push to Your Fork**:
   Push the changes to your fork/copy of the Rocky Linux documentation repo. Type:
   ```bash
   git push origin new-gemstone
   ```

8. **Create a Pull Request**:
   Create a pull request to the upstream repository.
   ```
   gh pr create --base main --head wsoyinka:new-gemstone --title "New Gemstone: Creating PRs via CLI" --body "Guide on how to contribute to documentation using CLI"
   ```

## Additional Information (Optional)

- Use `gh pr list` and `gh pr status` to track the status of your pull requests.
- Review and follow the contribution guidelines of the Rocky Linux documentation project.

## Conclusion

Following these steps, you should be able to successfully create your very first PR and contribute to the Rocky Linux documentation repository entirely via the CLI!
