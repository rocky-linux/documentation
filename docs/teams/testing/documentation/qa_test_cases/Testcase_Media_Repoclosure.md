---
title: QA:Testcase Media Repoclosure
author: Trevor Cooper
revision_date: 2026-04-17
rc:
  prod: Rocky Linux
  ver: 8
  level: Final
render_macros: true
---

!!! info "Associated release criterion"
    This test case is associated with the [Release_Criteria#no-broken-packages](../../guidelines/release_criteria/r9/9_release_criteria.md#no-broken-packages) release criterion. If you are doing release validation testing, a failure of this test case may be a breach of that release criterion.

## Description
This testcase will verify that the offline repository included on release blocking images will not contain broken dependencies.

## Setup
1. Obtain access to an environment with the `dnf repoclosure` command.
2. Download the ISO to be tested to that machine.

## How to test
1. Mount the ISO to be tested locally.
    - Example:<br>`mount -o loop Rocky-8.5-x86_64-minimal.iso /media`
2. Determine the path to the `repodata` directory(ies) on the ISO.
    - Example:<br>`find /media -name repodata`
3. Run the `dnf repoclosure` command on the mounted ISO.
    - Example:<br>`dnf --verbose repoclosure --repofrompath BaseOS,/media/BaseOS --repo BaseOS --repofrompath Minimal,/media/Minimal --repo Minimal`
4. Unmount the ISO.
    - Example:<br>`umount /media`

## Expected Results
1. The `dnf repoclosure` command does not generate any errors.

<h3>Sample Output</h3>

=== "Success"

    ```
    $ sudo mount -o loop Rocky-8.5-x86_64-minimal.iso /media
    mount: /media: WARNING: device write-protected, mounted read-only.

    [vagrant@localhost ~]$ dnf --refresh repoclosure \
      --repofrompath BaseOS,/media/BaseOS --repo BaseOS \
      --repofrompath Minimal,/media/Minimal --repo Minimal
    Added BaseOS repo from /media/BaseOS
    Added Minimal repo from /media/Minimal
    BaseOS                                               102 MB/s | 2.6 MB     00:00
    Minimal                                               90 kB/s | 384  B     00:00

    $ sudo umount /media
    ```

=== "Failure"

    __NOTE: In this example the content of the `Rocky-8.5-x86_64-minimal.iso` was copied to `/tmp` then the BaseOS repository was modified to remove the `setup-2.12.2-6.el8.noarch.rpm` package and the repository metadata was regenerated.__

    ```
    [vagrant@localhost ~]$ dnf --refresh repoclosure \
      --repofrompath BaseOS,/tmp/media/BaseOS --repo BaseOS \
      --repofrompath Minimal,/tmp/media/Minimal --repo Minimal
    Added BaseOS repo from /tmp/media/BaseOS
    Added Minimal repo from /tmp/media/Minimal
    BaseOS                                               3.7 MB/s | 3.8 kB     00:00
    Minimal                                              3.7 MB/s | 3.8 kB     00:00
    package: basesystem-11-5.el8.noarch from BaseOS
      unresolved deps:
        setup
    package: dump-1:0.4-0.36.b46.el8.x86_64 from BaseOS
      unresolved deps:
        setup
    package: filesystem-3.8-6.el8.x86_64 from BaseOS
      unresolved deps:
        setup
    package: initscripts-10.00.15-1.el8.x86_64 from BaseOS
      unresolved deps:
        setup
    package: rpcbind-1.2.5-8.el8.x86_64 from BaseOS
      unresolved deps:
        setup
    package: shadow-utils-2:4.6-14.el8.x86_64 from BaseOS
      unresolved deps:
        setup
    Error: Repoclosure ended with unresolved dependencies.
    ```

{% include 'teams/testing/qa_testcase_bottom.md' %}
