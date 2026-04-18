---
title: QA:Testcase Packages No Insights
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
This test will verify that `insights-client` package is not declared be installed as part of a package group.

## Setup
1. Obtain access to an environment with the `dnf` command.
2. Download the ISO to be tested to that machine.

## How to test
1. Mount the ISO to be tested locally.
2. Determine the path to the `comps` file(s) on the ISO.
3. Verify that `insights-client` is not declared to be installed automatically.
    - Example 1:<br>`find /media -name "*comps*.xml" -exec grep -H "insights-client" '{}' \;`
    - Example 2:<br>`dnf --refresh --repofrompath BaseOS,/media/BaseOS --repo BaseOS --repofrompath AppStream,/media/AppStream --repo AppStream groupinfo base | grep -E ":|insights"`
4. Unmount the ISO.

## Expected Results
1. `insights-client` is not declared to be installed by default.

<h3>Sample Output</h3>

=== "Success"


    !!! info "UPDATE SAMPLE"
        NOTE: This example needs to be refreshed when the 8.6 ISO has been produced. As seen in the Failure section below the `Rocky-8.5-x86_64-dvd1.iso` includes the `insights-client` as part of the `base` group. The package should be included on the DVD ISO but should **not** be installed automatically.

    ```
    $ sudo mount -o loop Rocky-8.5-aarch64-minimal.iso /media
    mount: /media: WARNING: device write-protected, mounted read-only.

    $ dnf --refresh --repofrompath BaseOS,/media/BaseOS --repo BaseOS --repofrompath Minimal,/media/Minimal --repo Minimal search insights-client
    Added BaseOS repo from /media/BaseOS
    Added Minimal repo from /media/Minimal
    BaseOS                                                                    3.8 MB/s | 3.9 kB     00:00
    Minimal                                                                   3.7 MB/s | 3.8 kB     00:00
    No matches found.

    $ find /media -name "*comps*.xml" -exec grep -H "insights-client" '{}' \;

    $ dnf --refresh --repofrompath BaseOS,/media/BaseOS --repo BaseOS --repofrompath Minimal,/media/Minimal --repo Minimal groupinfo base | grep -E ":|insights"
    BaseOS                                          3.8 MB/s | 3.9 kB     00:00
    Minimal                                         3.7 MB/s | 3.8 kB     00:00
    Group: Base
     Description: The standard installation of Rocky Linux.
     Mandatory Packages:
     Default Packages:
     Optional Packages:

    $ sudo umount /media
    ```

=== "Failure"

    ```
    $ sudo mount -o loop Rocky-8.5-x86_64-dvd1.iso /media
    mount: /media: WARNING: device write-protected, mounted read-only.

    $ dnf --refresh --repofrompath BaseOS,/media/BaseOS --repo BaseOS --repofrompath AppStream,/media/AppStream --repo AppStream search insights-client
    Added BaseOS repo from /media/BaseOS
    Added AppStream repo from /media/AppStream
    BaseOS                                                                    3.8 MB/s | 3.9 kB     00:00
    AppStream                                                                 4.2 MB/s | 4.3 kB     00:00
    ================================= Name Exactly Matched: insights-client ==================================
    insights-client.noarch : Uploads Insights information to Red Hat on a periodic basis

    $ find /media -name "*comps*.xml" -exec grep -H "insights-client" '{}' \;
    /media/AppStream/repodata/a6742e1300e1c786af91656b152d3b98bb7aff598e650509381417970e1f1b7e-comps-AppStream.x86_64.xml:      <packagereq type="default">insights-client</packagereq>
    /media/AppStream/repodata/a6742e1300e1c786af91656b152d3b98bb7aff598e650509381417970e1f1b7e-comps-AppStream.x86_64.xml:      <packagereq type="default">insights-client</packagereq>

    $ dnf --refresh --repofrompath BaseOS,/media/BaseOS --repo BaseOS --repofrompath AppStream,/media/AppStream --repo AppStream groupinfo base | grep -E ":|insights"
    BaseOS                                          3.8 MB/s | 3.9 kB     00:00
    AppStream                                       4.2 MB/s | 4.3 kB     00:00
    Group: Base
     Description: The standard installation of Rocky Linux.
     Mandatory Packages:
     Default Packages:
       insights-client
     Optional Packages:

    $ sudo umount /media
    ```

{% include 'teams/testing/qa_testcase_bottom.md' %}
