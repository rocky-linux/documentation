---
Title: Introduction
author: Steven Spencer
contributors:
tags:
  - local docs
  - docs as code 
  - linters
---

# Introduction

Using a local copy of Rocky Linux documentation is helpful for those who contribute often and need to see exactly how a document will look in the web interface after merging. The methods included here represent contributors preferences to date.

Using a local copy of the documentation is one step in the development process for those who subscribe to the philosophy of "docs as code," a workflow for documentation that is similar to code development.

## Markdown linting

In addition to environments for storing and building the documentation, a consideration for some writers might be a linter for markdown. Markdown linters are helpful in many aspects of writing documents, including checks for grammar, spelling, formatting, and more. Sometimes these are separate tools or plugins for your editor. One such tool is [markdownlint](https://github.com/DavidAnson/markdownlint), a Node.js tool. `markdownlint` is available as plugin for many popular editors including Visual Studio Code and NVChad. For this reason, included in the root of the documentation directory is a `.markdownlint.yml` file that will apply the rules available and enabled for the project. `markdownlint` is purely a formatting linter. It will check for errant spaces, in-line html elements, double blank lines, incorrect tabs, and more. For grammar, spelling, inclusive language usage, and more, install other tools.

!!! info "Disclaimer"

    None of the items in this category ("Local documentation") are required to write documents and submit them for approval. They exist for those who want to follow [docs as code](https://www.writethedocs.org/guide/docs-as-code/) philosophies, which include at minimum a local copy of the documentation.
