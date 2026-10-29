---
title: QA:Sparrow Wordpress LAMP
author: Chris Stackpole
contributors: 
tags:
  - testing
  - sparrow
revision_date: 2026-10-09
rc:
  prod: Rocky Linux
  level: Final
render_macros: true
---

## Description

Documentation link:- [WordPress on LAMP](https://docs.rockylinux.org/guides/cms/wordpress-on-lamp)

Project link:- [https://git.resf.org/testing/Sparky_WP_LAMP](https://git.resf.org/testing/Sparky_WP_LAMP)

Note:- This test frequently breaks due to updates of Wordpress. Investigating failures and reporting updates is a HUGE help to the project.

🔴 - Tested and known to fail.
✅ - Tested and known to work.
⚠️  - Untested.

## Releases and Architectures

| Distro         | aarch64 | ppc64le | riscv64 | s390x | x86_64 |
| -------------- | ------- | ------- | ------- | ----- | ------ |
| Rocky Linux  8 | 🔴      | ⚠️       | N/A     | ⚠️     | 🔴     |
| Rocky Linux  9 | ✅       | ⚠️       | N/A     | ⚠️     | ✅      |
| Rocky Linux 10 | ✅       | ⚠️       | ⚠️       | ⚠️     | ✅      |

## Setup

1. See [Getting Started Guide](https://docs.rockylinux.org/guides/automation/sparky_getting_started/)

## How to test

1. See Sparky guide.

## Expected Results

``` Bash
# HTTP check for WP localhost
stdout match (r) <HTTP/1.1 302 Found> True
stdout match (r) <Date: \s*> True
stdout match (r) <^^ \s* "Server:" \s+ "Apache/" \d+ "."> True
stdout match (r) <"X-Powered-By: PHP/"\s*> True
stdout match (r) <Expires: \s*> True
stdout match (r) <Cache-Control: no-cache, must-revalidate, max-age=0, no-store, private> True
stdout match (r) <X-Redirect-By: WordPress> True
stdout match (r) <Location: http://127.0.0.1/wp-admin/install.php> True
stdout match (r) <Content-Length: 0> True
stdout match (r) <Content-Type: text/html; charset=UTF-8> True
stdout match (r) <^^  $$> True
stdout match (r) <HTTP/1.1 200 OK> True
stdout match (r) <Date: \s*> True
stdout match (r) <^^ \s* "Server:" \s+ "Apache/" \d+ "."> True
stdout match (r) <"X-Powered-By: PHP/"\s*> True
stdout match (r) <Expires: \s*> True
stdout match (r) <Cache-Control: no-cache, must-revalidate, max-age=0, no-store, private> True
stdout match (r) <Transfer-Encoding: chunked> True
stdout match (r) <Content-Type: text/html; charset=utf-8> True
stdout match (r) <^^  $$> True
stdout match (r) <<!DOCTYPE html>> True
stdout match (r) <<html lang="en-US">> True
stdout match (r) <<head>> True
stdout match (r) <<meta name="viewport" content="width=device-width, initial-scale=1.0" />> True
stdout match (r) <<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />> True
stdout match (r) <<meta name="robots" content="noindex,nofollow" />> True
stdout match (r) <<title>WordPress &rsaquo; Installation</title>> True
```

   {% include 'teams/testing/qa_testcase_bottom.md' %}
