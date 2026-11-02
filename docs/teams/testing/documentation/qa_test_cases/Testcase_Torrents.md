---
title: QA:Testcase Torrents
author: Chris Stackpole
contributors: 
tested_with: 8.10, 9.8, 10.2
tags:
  - testing
  - qa
revision_date: 2026-10-20
rc:
  prod: Rocky Linux
  ver:
    - 8
    - 9
    - 10
  level: Final
render_macros: true
---

## Description

One of the last steps of release is generating torrents for users. Torrents should be checked for validity before released to the public.

* ⬇️ - Low priority. It would be good to have this tested, but if it isn't or if it fails then it is inconsequential. 
* ❗ - Important. It is best to have this tested, but if it isn't or if it fails then it won't block the release.

## Releases, Architectures, and ISO's

| Distro         | aarch64 | ppc64le | riscv64 | s390x | x86_64 |
| -------------- | ------- | ------- | ------- | ----- | ------ |
| Rocky Linux  9 | ❗       | ⬇️       | N/A     | ⬇️     | ❗      |
| Rocky Linux 10 | ❗       | ⬇️       | ⬇️       | ⬇️     | ❗      |

## Setup

1. Download the torrent files. Information will be released in the Mattermost Release Channel.

## How to test

1. Download the torrents and content.
2. Verify Checksums; `sha256sum -c *.CHECKSUM --ignore-missing`
3. Verify GPG key signature.

   ```
   # If you do not have the GPG keys already, please download the keys for each release from:-
   # https://rockylinux.org/resources/gpg-key-info
   #
   # Import those keys
   gpg --import RPM-GPG-KEY-Rocky-9
   gpg --import RPM-GPG-KEY-Rocky-10
   #
   # Alternatively, if you are on a Rocky system you can get the system key from:-
   sudo dnf install rocky-gpg-keys
   gpg --import /etc/pki/rpm-gpg/RPM-GPG-KEY-Rocky-*
   #
   # Test that the GPG key matches that website
   gpg --list-keys
   #
   # Now test
   gpg --verify-file CHECKSUM.asc
   #
   # Output you are looking for is one of the following with keys that match the website above:-
   gpg: Good signature from "Rocky Enterprise Software Foundation - Release key 2022 <releng@rockylinux.org>"
   gpg: Good signature from "Release Engineering (Rocky Linux 10) <releng@rockylinux.org>"
   #
   # The following WARNING can be ignored for this test:-
   gpg: WARNING: This key is not certified with a trusted signature!
   ```

## Expected Results

1. All files should download.
2. ISO's should match Checksums.
3. Checksums should be signed with GPG key.

{% include 'teams/testing/qa_testcase_bottom.md' %}
