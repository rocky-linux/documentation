---
title: QA:Testcase Packages No RHSM
author: Trevor Cooper
revision_date: 2026-04-17
rc:
  prod: Rocky Linux
  ver: 8
  level: Final
render_macros: true
---

!!! info "Associated release criterion"
    This test case is associated with the [Release_Criteria#repositories-must-match-upstream](../../guidelines/release_criteria/r9/9_release_criteria.md#repositories-must-match-upstream) release criterion. If you are doing release validation testing, a failure of this test case may be a breach of that release criterion.

## Description
This test will verify that packages that are availble from upstream do not have hard requirements on `subscription-manager` (RHSM).

## Setup
1. Obtain access to an environment with the `dnf` command.
2. Download the ISO to be tested to that machine.

## How to test
1. Mount the ISO to be tested locally.
2. Obtain a list of packages that have `Requires:` for `subscription-manager`
    - Example:<br>`package_list=($(dnf --refresh repoquery --repofrompath BaseOS,/media/BaseOS --repo BaseOS --repofrompath AppStream,/media/AppStream --repo AppStream --whatrequires subscription-manager 2>/dev/null| grep el8))`
3. Download the packages with explicity `Requires:` for `subscription-manager`
    - Example:<br>`dnf --repofrompath BaseOS,/media/BaseOS --repo BaseOS --repofrompath AppStream,/media/AppStream --repo AppStream download "${package_list[@]}"`
4. Obtain the `SOURCEPKG` definition for the above packages
    - Example:<br>`rpm -q --queryformat="%{NAME}|%{SOURCERPM}\n" subscription-manager*.rpm | column -s\| -t`
4. Unmount the ISO.

## Expected Results
1. No packages have an explicit requirement for `subscription-manager`.


<h3>Sample Output</h3>

=== "Success"

    ```
    $ sudo mount -o loop Rocky-8.5-aarch64-minimal.iso /media
    mount: /media: WARNING: device write-protected, mounted read-only.

    $ package_list=($(dnf --refresh repoquery --repofrompath BaseOS,/media/BaseOS --repo BaseOS --repofrompath AppStream,/media/AppStream --repo AppStream --whatrequires subscription-manager 2>/dev/null| grep el8))

    $ dnf --repofrompath BaseOS,/media/BaseOS --repo BaseOS --repofrompath AppStream,/media/AppStream --repo AppStream download "${package_list[@]}"
    Added BaseOS repo from /media/BaseOS
    Added AppStream repo from /media/AppStream
    Last metadata expiration check: 0:00:25 ago on Sun 24 Apr 2022 10:57:13 PM UTC.

    $ rpm -q --queryformat="%{NAME}|%{SOURCERPM}\n" subscription-manager*.rpm | column -s\| -t
    subscription-manager-cockpit        subscription-manager-1.28.21-3.el8.src.rpm
    subscription-manager-migration      subscription-manager-1.28.21-3.el8.src.rpm
    subscription-manager-plugin-ostree  subscription-manager-1.28.21-3.el8.src.rpm

    $ sudo umount /media
    ```

=== "Failure"

    TBD


{% include 'teams/testing/qa_testcase_bottom.md' %}
