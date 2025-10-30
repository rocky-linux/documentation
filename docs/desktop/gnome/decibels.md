---
title: Decibels Audio Player
author: Wale Soyinka
contributors: Ganna Zhyrnova
tags:
  - gnome
  - desktop
  - audio
  - flatpak
---

## Introduction

**Decibels** is a modern and elegant audio player for the GNOME desktop. It is built on a philosophy of simplicity, designed to do one thing exceptionally well: play audio files.

Unlike full-featured music library applications like Rhythmbox, Decibels does not manage a music collection. Instead, it focuses on providing a clean, straightforward experience for playing individual sound files. Its signature feature is a beautiful waveform display that enables easy, precise navigation through the audio track.

This makes it the perfect tool for quickly listening to a downloaded podcast, a voice memo, or a new song without the overhead of importing files into a library.

## Installation

The recommended way to install Decibels on Rocky Linux is as a Flatpak from the Flathub repository. This method ensures you have the latest version of the application, sandboxed from the rest of your system.

### 1. Enable Flathub

First, please make sure Flatpak is installed and the Flathub remote is configured on your system.

```bash
# Install the Flatpak package
sudo dnf install flatpak

# Add the Flathub remote repository
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
```

!!! note
    You may need to log out and log back in for Flatpak applications to appear in the GNOME Activities Overview.

### 2. Install Decibels

Once Flathub is enabled, you can install Decibels with a single command:

```bash
flatpak install flathub org.gnome.Decibels
```

## Basic Usage

After installation, you can launch Decibels from the GNOME Activities Overview by searching for "Decibels".

To play a file:

1.  Launch the application. A clean, simple window will greet you.
2.  Click the prominent **"Open a File..."** button in the center of the window.
3.  Use the file chooser to navigate to and select an audio file on your system (e.g., an `.mp3`, `.flac`, `.ogg`, or `.wav` file).
4.  The file will open, and its waveform will be displayed. Playback will begin automatically.

## Key Features

While simple, Decibels has several valuable features:

*   **Waveform Navigation:** Instead of a simple progress bar, Decibels shows the audio's waveform. You can click anywhere on the waveform to seek to that part of the track instantly.
*   **Playback Speed Control:** A control in the bottom-right corner allows you to adjust the playback speed, which is perfect for speeding up podcasts or slowing down audio for transcription.
*   **Quick Skip Buttons:** Dedicated buttons allow you to jump backward or forward by 10-second intervals, making it easy to re-listen to a missed phrase.

Decibels is an excellent choice for anyone who needs a simple, elegant, and modern application for playing individual audio files on the GNOME desktop.
