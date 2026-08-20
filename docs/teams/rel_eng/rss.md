---
title: Rocky Linux RSS feeds
author: Release Engineering
contributors: Steven Spencer
---

This page covers the RSS (Really Simple Syndication) feeds provided by the Rocky Linux project.

## About RSS feeds

Rocky Linux provides RSS feeds as an alternative way for users to observe updates that come to the many repositories for supported versions of Rocky Linux.

RSS feeds will appear in the public mirror: [RSS Feeds](https://dl.rockylinux.org/pub/feeds)

Release Engineering (SIG/Core) generates these feeds [Toolkit](https://git.resf.org/sig_core/toolkit/src/branch/devel/mangle/generators/rss.py).

## Notes on refresh times

The feeds update every 30 minutes. If there are new packages added to any of the repositories, they will appear right away on next refresh.

## Notes on packages

The feeds will show the most recent packages up to 30 days. If a package is older than 30 days, it will drop from the feed.

## Notes on modules

Some module packages might not appear in the feed. This is especially true for Rocky Linux 8. The RSS feed script at this time is not capable of taking into account all modules. Notable exceptions to this are the default module streams.
