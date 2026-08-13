---
title: PackageKit Missing Items
---

You have been redirected here to answer why you cannot find certain packages in Rocky Linux.

## Missing Package
The package you are searching for is not available in Rocky Linux. There are a few reasons why this could be:

* We cannot include software that is encumbered by software patents
* We cannot include software that is not in the Base OS (you are encouraged to use EPEL and Special Interest Group repositories)
* In the case of a SIG, we cannot package proprietary software.
* Perhaps someone has not packaged it yet to be included in a SIG.

## Missing Codecs
The codecs you are searching for is not available in Rocky Linux. A codec is a program that allows the user to encode or decode a data stream in a specific format (think MP3/MOV/WMV). Upstream, and thus Rocky Linux, generally do not have such codecs.

The question we generally receive is "Why can't you provide it in a SIG or an extras?" It's because of the following reasons:

* Many codecs are proprietary or patent encumbered
* Some codecs may not be encumbered, but may be under a license that is *not* acceptable

We encourage users to either:

* Use formats such as OGG, Dirac, and FLAC
* Consider finding a third party repository that provides such codecs such as rpmfusion

    * Note that we cannot support you if you choose to use repositories that are not community approved.

## Missing Drivers
Since Rocky Linux attempts to be compatible with Red Hat Enterprise Linux, we are limited to the hardware that their kernel configuration supports. We encourage you to use [ELRepo](https://elrepo.org) where you can find kmod's + newer kernels or SIG/Kernel where there may be similar support.

## Missing Fonts
The font that you are looking for is not available in Rocky Linux. This is because we only include fonts that are available in our upstreams CentOS Stream and Red Hat Enterprise Linux.
