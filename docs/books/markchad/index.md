---
title: Overview
author: Franco Colussi
contributors: Steven Spencer
tested_with: 9.4
tags:
  - neovim
  - nvchad
  - editor
  - markdown
---

## :simple-streamrunners: Objective

Create a configuration of NvChad dedicated to writing documentation with Markdown code by implementing the following features.

* Automatically set Neovim options for Markdown files
* Highlighting Markdown tags in the buffer
* Integrate plugins dedicated to Markdown code development

## :material-book-open-page-variant-outline: Introduction

[Nvchad](https://nvchad.com/) is a custom configuration of **Neovim** that provides *out of the box* an IDE for *Lua* code development, its modularity however allows useful features for any type of language to be implemented in the configuration.
This project intends to create a version of the NvChad configuration with the best solutions for the Markdown language provided by Neovim plugins and settings.

![Markchad Editor](./images/markchad_editor.png)

## :material-feature-search-outline: Features

* **Configuration:** all configurations of the additional plugins have been written with great care to make them independent of each other, this allows them to be disabled when needed by means of the *Plugin Spec* `enabled = false/true` of *lazy.nvim* present in all configuration files. Keyboard keys to invoke the various features have been included in the configuration files and converted where possible to the *lazy style* format
* **UI - Interface:** some changes were made to the layout strategy of `Telescope` in order to have a more modern and functional interface, themes (*dropdown* and *ivy*) were also used for the `pickers` provided by default and for those inserted by additional plugins.
No changes have been made to the themes provided by *NvChad*, this is to allow you to use it according to your own aesthetic tastes. Not all themes offer a *rich* display for highlights, and the default `onedark` theme was used for graphic development.
* **Editor:** the section of plugins that provide functionality to the editor have been supplemented with a *git* repository and other small utilities to improve workflow.
* **Markdown:** several features have been included for writing Markdown documentation including a preview of the document in the browser, highlighting in the buffer of markdown tags, conversion by keyboard keys of attributes to text, and more.

## :fontawesome-regular-handshake: Acknowledgements

A big thank you goes to [Siduck](https://github.com/siduck), the main developer, and to all those who contributed to the creation of *NvChad*, without them this project could not exist.
A big thank you also goes to all the developers of the plugins used in this setup for sharing their knowledge.
