---
title: Create a New Document in GitHub
author: Ezequiel Bruni
contributors: Grammaresque, Ganna Zhyrnova
tags:
  - contributing
  - documentation
---

# How To Create a New Document in GitHub

*When you are ready to submit your original written documentation for approval, follow these easy steps:*

## With the GitHub GUI

You can complete almost all tasks from the web GUI on GitHub. Here's an example of adding a file you've created on your local machine to the Rocky Linux documentation GitHub repository.

1. Login to your GitHub account.
2. Navigate to the Rocky Linux Documentation repository at <https://github.com/rocky-linux/documentation>.
3. You should be on the "Main" branch, so check the drop-down label down in the middle section to be sure you are. Your document might not ultimately end up in the "Main" branch, but admins will move it around to where it logically fits later.
4. On the right-hand side of the page, click the ++"Fork"++ button, which will create your copy of the documentation.
5. In the middle of the page on the forked copy, just to the left of the Green "Code" drop-down, is an ++"Add file"++ button. Click this and choose the "Upload files" option.
6. This will allow you to drag and drop files here or browse to them on your computer. Go ahead and use the method that you prefer.
7. Once the file is uploaded, the next thing you need to do is create a Pull Request. This request lets the upstream administrators know you have a new file (or files) that you want them to merge with the master branch.
8. Click on `Pull Request` in the upper-left corner of the screen.
9. Write a brief message in the "Write" section letting the administrators know what you've done. (New document, revision, suggested change, etc.) then submit your change.

## From the Git Command-Line

If you prefer to run Git locally on your machine, you can clone the [Rocky Linux Documentation](https://github.com/rocky-linux/documentation) repository, make changes, and then commit changes afterward. To make things simple, execute steps 1-3 using the **With the GitHub GUI** approach above, then:

1. Git clone the repository:

    ```text
    git clone https://github.com/your_fork_name/documentation.git
    ```

2. Now, on your machine, add files to the directory.
   Example:

    ```bash
    mv /home/myname/help.md /home/myname/documentation/
    ```

3. Next, run Git add for that file name.
   Example:

    ```text
    git add help.md
    ```

4. Now, run git commit for the changes you have made.
   Example:

    ```text
    git commit -m "Added the help.md file"
    ```

5. Next, push your changes to your forked repository:

    ```text
    git push https://github.com/your_fork_name/documentation main
    ```

6. Next, repeat steps 6 and 7 above: Create a Pull Request. This request lets the upstream administrators know that you have a new file (or files) that you would like them to merge with the master branch. Click on `Pull Request` in the upper-left corner of the screen.

Watch for comments within the PR for requested revisions and clarifications.
