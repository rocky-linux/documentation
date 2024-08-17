---
title: Audio Sharing
author: Christine Belzie
contributors: 
---

## Introduction

The Audio Sharing app is a great tool for sending your computer's sound to other devices on your network.  You can use this app to play music in different rooms of your house, share sound during online presentations or Twitch streams, or listen to audio with friends and family at the same time.  Whether you're new to audio sharing or have some experience, this app makes it simple to stream your computer's sound to other devices.

## Assumptions

This guide assumes you have the following:

- Rocky Linux
- Flatpak
- FlatHub

## Installation Process

Go to Flatub.com, type "Audio Sharing" in the search bar, and click on **Install**.
<!--- add screenshot here --->

Then, use the following command to install the app
`flatpak run de.haeckerfelix.AudioSharing`

## How to Use

To use the app, scan the displayed QR code from the device which you want to use for receiving the audio.
<!--- add screenshot here --->
 
 !!! note

 In order for the shared audio to play on the other device, make sure your it has a program that does RTSP(Real-Time Streaming Protocol) streams.  Check out the [FAQs section on the Audio Sharing repository](https://gitlab.gnome.org/World/AudioSharing/#faq) to learn more.  

## Conclusion

Eager to learn more about or have more ideas for this app? [Submit an issue in Audio Sharing's repository at GitLab](https://gitlab.gnome.org/World/AudioSharing/-/issues).
