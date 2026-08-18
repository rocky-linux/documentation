---
title: PackageKit Missing Items
author: Release Engineering
contributors: Steven Spencer
---

The following may explain why you cannot find certain packages in Rocky Linux.

## Missing package

The package you are searching for is not available in Rocky Linux. There are a few reasons why this could be:

* We cannot include software encumbered by software patents.
* We cannot include software that is not in the Base OS (you should use the EPEL and Special Interest Group repositories instead).
* In the case of a SIG, we cannot package proprietary software.
* A maintainer has not packaged it yet for inclusion in a SIG.

## Missing codecs

The codecs you are searching for is not available in Rocky Linux. A codec is a program for encoding and decoding a data stream in a specific format (think MP3/MOV/WMV). Upstream, and thus Rocky Linux, generally do not have such codecs.

The question we generally receive is "Why can't you provide it in a SIG or an extras?" It is because of the following reasons:

* Many codecs are proprietary or patent encumbered.
* Some codecs might not be patent encumbered, but might be under an unacceptable license.

We encourage users to either:

* Use formats such as OGG, Dirac, and FLAC.
* Consider finding a third party repository that provides such codecs, such as rpmfusion.

    * Note that we cannot support you if you choose to use repositories that are not community approved.

## Missing Drivers

Since Rocky Linux attempts to be compatible with Red Hat Enterprise Linux, there are limits to the hardware that their kernel configuration supports. We encourage you to use [ELRepo](https://elrepo.org) where you can find kmod's + newer kernels or SIG/Kernel where there might be similar support.

## Missing Fonts

The font that you are looking for is not available in Rocky Linux. This is because we only include fonts that are available in our upstreams, CentOS Stream and Red Hat Enterprise Linux.
