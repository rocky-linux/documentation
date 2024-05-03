---
title: Tracking vs Non-Tracking Branch in Git
author: Wale Soyinka
contributors:
tags:
  - git
  - git branch
  - Tracking Branch
  - Non-Tracking Branch
---

## Introduction

This Gemstone delves into tracking and non-tracking branches in Git. It also includes steps to verify and convert between the branch types.

## Tracking Branch

A tracking branch is a branch that is linked to a remote branch.

1. Create a new branch named my-local-branch. Make the new local branch track the main branch of the remote repository named origin. Type:

    ```bash
    git checkout -b my-local-branch origin/main
    ```

2. Use the `git branch -vv` command to verify that the branch is a tracking branch. Type:

    ```bash
    git branch -vv
    ```

    Look for branches with `[origin/main]` indicating they are tracking `origin/main`.

## Non-Tracking Branch

A non-tracking branch is a branch that operates independently from remote branches.

1. Create a new non-tracking local branch named my-feature-branch. Type:

    ```bash
    git checkout -b my-feature-branch
    ```

2. Non-tracking branches won’t show a remote branch next to them in the git branch -vv output. Check if my-feature-branch is a non-tracking branch.

## Converting Non-Tracking to Tracking

1. Optionally, first make sure the latest changes from the main branch are merged into the target branch. Type:

     ```bash
     git checkout my-feature-branch
     git merge main
     ```

2. Set up tracking to a remote branch:

     ```bash
     git branch --set-upstream-to=origin/main my-feature-branch
     ```

     Output: `Branch 'my-feature-branch' set up to track remote branch 'main' from 'origin'.`

3. Verify the change. Type:

     ```bash
     git branch -vv
     ```

     Now, `my-feature-branch` should show `[origin/main]` indicating it's tracking.

## Conclusion

Understanding the nuances between tracking and non-tracking branches is vital in Git. This Gemstone clarifies these concepts and also demonstrates how to identify and convert between these branch types for optimal git workflow management.
