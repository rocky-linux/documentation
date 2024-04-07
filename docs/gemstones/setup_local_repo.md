---
title: Setup Local Rocky Repositories
author: codedude
contributors: Steven Spencer
update: 09-Dec-2021
---

# Introduction

Sometimes you need to have Rocky repositories local for building virtual machines, lab environments, etc.  It can also help save bandwidth if that is a concern.  This article will walk you through using `rsync` to copy Rocky repositories to a local web server.  Building a web server is out of the scope of this short article.

## Requirements

* A web server

## Code

```bash
#!/bin/bash
repos_base_dir="/web/path"

# Start sync if base repo directory exist
if [[ -d "$repos_base_dir" ]] ; then
  # Start Sync
  rsync  -avSHP --progress --delete --exclude-from=/opt/scripts/excludes.txt rsync://ord.mirror.rackspace.com/rocky  "$repos_base_dir" --delete-excluded
  # Download Rocky 8 repository key
  if [[ -e /web/path/RPM-GPG-KEY-rockyofficial ]]; then
     exit
  else
      wget -P $repos_base_dir https://dl.rockylinux.org/pub/rocky/RPM-GPG-KEY-rockyofficial
  fi
fi
```

## Breakdown

This simple shell script uses `rsync` to pull repository files from the nearest mirror.  It also utilizes the "exclude" option which is defined in a text file in the form of keywords that should not be included.  Excludes are good if you have limited disk space or just do not want everything for whatever reason.  We can use  `*` as a wildcard character.  Be careful using  `*/ng` as it will exclude anything that matches those characters.  An example is below:

```bash
*/source*
*/debug*
*/images*
*/Devel*
8/*
8.4-RC1/*
8.4-RC1
```

## End

A simple script that can help save bandwidth or make building out a lab environment a little easier.
