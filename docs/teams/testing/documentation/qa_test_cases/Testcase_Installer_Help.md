---
title: QA:Testcase Installer Help
author: Al Bowles
revision_date: 2026-04-17
rc:
  prod: Rocky Linux
  ver:
  - 8
  - 9
  level: Final
render_macros: true
---

!!! info "Associated release criterion"
    This test case is associated with the [Release_Criteria#Installer Help](../../guidelines/release_criteria/r9/9_release_criteria.md#installer-help) release criterion. If you are doing release validation testing, a failure of this test case may be a breach of that release criterion.

## Description
Any element in the installer which contains a “help” text must display the appropriate help documentation when selected.

## Setup
{% include 'teams/testing/qa_setup_boot_to_media.md' %}

## How to test
1. From the Anaconda Hub, click the Help button in the upper right hand corner.
1. Verify that you see the "Customizing your Installation" help page.
1. Verify that the "Configuring language and location settings" link displays a topically appropriate page.
1. Close the Help browser to return to the Anaconda Hub.
1. Verify that the Localization help page displays for the Keyboard, Language Support, and Time & Date spokes:
    1. Select the spoke, then click the Help button.
    1. Verify that you see the "Configuring localization options" page containing a functioning link to the "Configuring keyboard, language, and time and date settings" page.
    1. Close the Help browser (and click Done if necessary) to return to the Anaconda Hub.
1. Verify that the Help button in the Installation Source spoke displays the "Configuring installation source" page.
1. Verify that the Help button in the Software Selection spoke displays the "Configuring software selection" page.
1. Verify that the Help button in the Installation Destination spoke displays the "Configuring storage devices" page.
1. Verify that the Help button in the Network & Host Name spoke displays the "Configuring network and host name options" page.
1. Verify that the Help button in the Root Password spoke displays the "Configuring a root password" page.
1. Verify that the Help button in the User Creation spoke displays the "Creating a user account" page.

## Expected Results
1. All links should work and display relevant content.

## Testing in openQA
The following openQA test suites satisfy this release criteria:

- `anaconda_help`

{% include 'teams/testing/qa_testcase_bottom.md' %}
