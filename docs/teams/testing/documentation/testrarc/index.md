---
title: Testrarc
author: Chris Stackpole
contributors: 
tested_with:
tags:
  - testing
revision_date: 2026-11-0r98
rc:
  prod: Rocky Linux
render_macros: true
---

# Introduction

Testrarc (TEST tRAcking for Rocky Candidates) is a dedicated, web-based platform tailored specifically for managing and monitoring the testing process of Rocky releases. The goal is to allow anyone to easily contribute to the testing of any Rocky release and to publicly display the progress of each release.

Code repo:- [https://git.resf.org/testing/testrarc](https://git.resf.org/testing/testrarc)
Production page:- [https://testrarc.rockylinux.org/app/home](https://testrarc.rockylinux.org/app/home)


# Getting Started

Before a contributor can submit to a test, the first step is to ensure that they have a Rocky account on the [Rocky Account Services portal](https://accounts.rockylinux.org/) which manages accounts across the RESF/Rocky community.

After a contributor has an account, they will then be able to log into [https://testrarc.rockylinux.org/](https://testrarc.rockylinux.org/).

![Main page pre-sign-in example](images/main_page_pre_sign_in.png)

After signing in there should be no difference in the screen except for the Logout in the top right. From this page, the status of each active Testbook can be seen per architecture. Selecting a different "arch" will update the status for each Testbook. Note:- the information for Testbooks without the arch may display incorrect infomration (ex: Rocky 9 does not have riscv64 arch).

# Exploring Tests

## Test Categories
Clicking on one of the Testbooks will open to all of the tests. By default, they are expanded. The "Collapse All" option will show all category headings. Conversely, "Expand All" will show all headings plus the tests.

![Category Headings](category_headings.png)

## Community Test Filter

To contributors find tests quickly, there is a "community_testable" tag. Click on "Filters", then on "Tags", and select "community_testable". Finally, click "Close."

![Community Testable Filter](community_testable.png)

The tests inside this filter are intended to be completed by anyone without any special software or hardware tooling. Many of these tests require feedback from a wide variety of systems in different environments. Successes are just as important as failures! All relevant contributions are helpful.

# Submitting the first test result

In this example, the first category is "ISO Testing". It can be seen that 75% of this category has already been validated by an experienced Testing team member. However, it is very important to remember that a wide breadth of testing is helpful! Even if there are many submitted tests, your contribution is helpful!

The very first test is "Physical Media Testing". The "Importance" is described as "Low" which means it will not block the release but it is desired to have someone test. Clicking "Physical Media Testing" will open a page to the results of previously submitted tests. In this example, there are none. Clicking the "Test Procedure" will open in a new tab the documentation for how to perform the test. In this case, it is a simple document that allows the user to download the beta ISO and burn to a physical disc to be tested with a physical system. The "Description" tells a summary of the test. There are currently no submitted tests so the "Admin Pass", "Num Passes", and "Num Fails" are all empty. If the contributor is logged in, there should be a "Submit" button. If there is no "Submit" button, then please verify you are logged in.

![Physical Media Test](physical_media_test.png)

Let's assume for this example that the ISO was downloaded, burned to a disc, booted, and verified. Click "Submit." At the top is the heading, description, and a link to the test procedure.

* Select the architecture ("arch") that the test was run on. 
* Select "Pass", "Fail", or "Partial".
* Select the "Deploy Type" which for this case should be "Bare Metal", but other tests could be "KVM", "Container", "VM", or "CloudVM".
* The "AdminPass" should only be available for those who contribute frequently. It's our hope that _you_ will one day have this option!
* Fill out the "Comments". Markdown is supported. Please fill in relevant details on what environment you tested on, the results of the test, and anything else that may be relevant. This is particularly needed when testing other "Deploy Types" as it helps to know even greater details about the environment.
* An optional "Bug URL" is very useful if you discover a problem and are able to file the bug with the relevant group.

Finally, "Submit Result" will save the results. You should be returned to the main TestBook page. Click on the "Thank You" link at the top to see your name mentioned!

![Submit Result](submit_result.png)

# Next steps

After you've submitted a test, find another you are interested in helping. If you are not already on our [Mattermost Chat](https://chat.rockylinux.org) then join both the ~Testing channel and the relevant release channel.

Thank you for contributing!

{% include 'teams/testing/content_bottom.md' %}
