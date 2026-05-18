---
title: Hardware compatibility
author: Chris Stackpole
contributors: Steven Spencer
translators:
---

## History

A common question people have is "Will Rocky install on my machine?" It is an important question and generally the answer is "yes." However, the question becomes more challenging when it is "Will Rocky work with this device or setup?" At the beginning of the project, Testing Team needed as many reports as possible to know that Rocky did indeed install on a wide range of hardware. This information was scraped together with `xsos` and put into the [Git repository here](https://github.com/rocky-linux/testing/tree/main/test-reports).

At the time it worked well however, it was hard to contribute to, and it was hard to search and filter. Those reports have not been updated in years.

However, the questions of "Does Rocky install on...?" Are still valid questions as new hardware is constantly being released. Thus, there is a desire to help build a database that users can search and contribute to.

## Hardware Probe project

The [Hardware Probe project](https://github.com/linuxhw/hw-probe) set out to answer this question. It is an established project with [a website](https://linux-hardware.org) that allows users to search for hardware and systems. Additionally, there are numerous ways to install [the probe](https://linux-hardware.org/?view=howto) and submit results easily and anonymously. The `hw-probe` tool analyzes and collects outputs from a number of utilities, such as `lspci`, `smartctl`, and `hwinfo`, to verify hardware and check if drivers are loaded and working optimally before submitting to the database.

Here is an example of a system that has multiple items useful for [Testing Team purposes](https://linux-hardware.org/?probe=edebdf0568).

## Why contribute

There are three reasons why Testing Team would like you to contribute your system to the Hardware Probe project database:

1. Whether you are running Rocky or some other distribution, helping the Hardware Probe project helps all Linux users know if their hardware is supported and works under Linux. It is good for the larger community.

1. It builds a database for the community who has the question "Does Rocky install on ...?". Contributing your `hw-probe` results to the database helps answer this question. The more variations and contributions, the more helpful the database is for others using EL based distributions like Rocky Linux.

1. Upstream from Rocky, drivers have been known to change or even drop entirely. It helps the Rocky Testing Team to know and more quickly address concerns about hardware where drivers should be working but for some reason are no longer functional in newer releases. If a piece of hardware previously worked and no longer does, we may not have access to that hardware, which can make it challenging to find release notes if the hardware was deprecated, or in filing upstream bug reports if it should be supported. The more history of the hardware Testing Team has available to reference, the easier and quicker it is to help address the issue.

## How to contribute

Fortunately for Rocky Linux, the `hw-probe` tool is available in EPEL except for Rocky Linux 10. This is not a complete comprehensive guide on how to utilize this tool. There are a number of useful features built-in which are not covered below. Only what is needed to install and upload to the database is covered.

### Rocky 8 and Rocky 9

Install EPEL if you have not done so already:

```text
dnf install -y epel-release
```

Install `hw-probe`:

```
sudo dnf install -y hw-probe
```

Do note, the EPEL package does not always get dependencies. On Rocky 8, also install `xorg-x11-utils` for edid-decode:

```
sudo dnf install -y xorg-x11-utils
```

Run the probe and upload the results:

```text
sudo -E hw-probe -all -upload
```

### Rocky 10

For Rocky 10, at the time of this writing `hw-probe`, is not in the main EPEL repository, but [there is work on building it](https://packages.fedoraproject.org/pkgs/hw-probe/hw-probe). In the mean time, the easiest way to get `hw-probe` with least amount of dependency packages to install, is to download and use [the AppImage](https://github.com/linuxhw/hw-probe/blob/master/README.md#appimage). Check the link for the latest version.

```text
curl -o hw-probe-1.6.5-189-x86_64.AppImage 'https://release-assets.githubusercontent.com/github-production-release-asset/47073191/b65e3afa-625f-4954-99e4-58da82ab7dd5?sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-05-18T17%3A29%3A57Z&rscd=attachment%3B+filename%3Dhw-probe-1.6.5-189-x86_64.AppImage&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-05-18T16%3A29%3A37Z&ske=2026-05-18T17%3A29%3A57Z&sks=b&skv=2018-11-09&sig=m%2FCSV5VjS%2FQv5vbq9EvY%2BXL9LbQhIo0sHmHmMQh7bgE%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc3OTEyMjYxMywibmJmIjoxNzc5MTIyMzEzLCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.z8HdXVijlSI_s1DqNgjlJaAvHRluuaWXMyImjk0PF18&response-content-disposition=attachment%3B%20filename%3Dhw-probe-1.6.5-189-x86_64.AppImage&response-content-type=application%2Foctet-stream'
```

You need to install the `libxcrypt-compat` package:

```text
sudo dnf install -y libxcrypt-compat
```

And finally make the AppImage executable:

```text
chmod +x ./hw-probe-1.6.5-189-x86_64.AppImage
```

Run the probe and upload the results:

```text
sudo -E ./hw-probe-1.6.5-189-x86_64.AppImage -all -upload
```

### Notify the Testing team

If running the probe on a official release (at the time of this writing: 8.10, 9.7, 10.1), submit the result to the Testing Team via chat.rockylinux.org (Mattermost Chat) in the testing channel. This is only recommended and not required. It simply lets Testing Team know what hardware has been submitted and the current state of it with Rocky. There is a lot of value for the larger community and for Testing Team historical purposes (knowing if hardware did or did not work on previous releases).

If running the probe on a Release Candidate and/or Beta, It is important to report the link regardless of status to [chat.rockylinux.org](https://chat.rockylinux.org) (Mattermost Chat), in the release channel. If that is not possible, direct message Rocky Linux on your social media of choice, or post in the forums at [forums.rockylinux.org](https://forums.rockylinux.org). Testing Team cannot guarantee your name will appear in the credits for submissions outside of the Mattermost channels at [chat.rockylinux.org](https://chat.rockylinux.org), but we will do our best to include ALL those who give submissions.

## Additional ways to contribute

It would be amazing to have `hw-probe` fully added into EPEL for 10, and for as many architectures as possible. Anyone with EPEL experience willing to assist there would be greatly appreciated. You can review the [upstream bug-report here](https://bugzilla.redhat.com/show_bug.cgi?id=2479630) or follow along with the [Testing Team's issue](https://github.com/rocky-linux/testing/issues/89). 

Additionally, anyone willing to contribue to the Hardware Probe project would be of great help. They are looking for people to assist with writing tests and managing the project.

Lastly, anyone willing to assist by coming up with a good method where Testing Team can review all of the Rocky submissions without overloading the upstream database would be greatly appreciated.
