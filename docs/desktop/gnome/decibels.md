---
title: Decibels
author: Christine Belzie
contributors: Steven Spencer, Ganna Zhyrnova 
---

## Introduction

Decibels is an application that plays audio files. Its user-friendly interface makes uploading and playing your favorite song(s), recordings of lectures, project ideas, and other audio files, easy.

## Assumptions

This guide assumes you have the following:

- Rocky Linux
- Flatpak
- FlatHub

## Installation Process

Go to [Flathub.org](https://flathub.org), type "Decibels" in the search bar, and click on **Install**.

![Screenshot of the Decibels app page on FlatHub, showing the install button being highlighted by a red rectangle](images/01_decibels.png)

![manual install script and run script](images/decibels-install.png)

2. Copy the manual install script and run it in a terminal:

    ```bash
    flatpak install flathub org.gnome.Decibels
    ```

3. Finally, copy the run command and run that in your terminal:

    ```bash
    flatpak run org.gnome.Decibels
    ```


## How to use

To use Decibels, do the following steps:

1. Click on **Open**

    ![Screenshot of Decibels' landing page with a red rectangle surrounding the blue open button](images/02_decibels.png)

2. Pick your desired file and click on the **Open** that appears in the upper right corner of the screen

    ![Screenshot of Decibels file selection interface with numbered arrows indicating audio file and Open button](images/03_decibels.png)


!!! note

    Tired of clicking with your mouse? Here are some ways you can use your keyboard to play and interact with your audio files

    - ++ctrl++ + ++shift++ + ++o++ = Open File
    - ++space++ = Play or Pause
    - ++left++ = Move audio back 10 seconds
    - ++right++ = Move audio forward 10 seconds

## Conclusion

Are you eager to learn more about this app, or do you have more ideas for it? [Submit an issue in Decibel's repository at GitLab](https://gitlab.gnome.org/GNOME/Incubator/decibels/-/issues).
