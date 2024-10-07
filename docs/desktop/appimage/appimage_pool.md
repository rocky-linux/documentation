---
title: Install AppImages with AppImagePool
author: Joseph Brinkman
contributors: Steven Spencer
---

## Introduction

[AppImagePool](https://github.com/prateekmedia/appimagepool) provides a hub to install and manage AppImages. It is visually similar to the Software application.

## Assumptions

For this guide you need the following:

* Rocky Linux with a desktop environment installed
* `sudo` privileges
* Flatpak installed on the system

## Install AppImagePool

Install the Flatpak package for AppImagePool:

```bash
flatpak install flathub io.github.prateekmedia.appimagepool
```

## Explore AppImage launcher

When the installation of AppImagePool completes, launch it and explore the available AppImages.

![Launching AppImagePool](images/appimagepool/appimagepool_launch.jpg)

Eighteen available categories exist at the time of this writing:

1. Utility
2. Network
3. Graphics
4. System
5. Science
6. Others
7. Development
8. Game
9. Education
10. Office
11. Multimedia
12. Audio
13. Emulator
14. Finance
15. Qt
16. Video
17. GTK
18. Sequencer

In addition, an "Explore" category exists for browsing all of the available categories of AppImages together.

## Download an AppImage

Find an AppImage you want to use:

![select_AppImage](images/appimagepool/appimagepool_select.jpg)

Click on its thumbnail image and download it. After a few moments of waiting, the AppImage will be on your system and ready to use!

![downloaded AppImage](images/appimagepool/appimagepool_download.jpg)

## Remove AppImage

To remove an image, click on ++"Installed"++ in the top menu bar, and click on the trash bin icon to the right of the AppImage you want to remove:

![Remove AppImage](images/appimagepool/appimagepool_remove.jpg)

## Conclusion

The [AppImagePool](https://github.com/prateekmedia/appimagepool) provides an easy to use hub to browse, download, and remove AppImages. It is similar looking to the Software hub and just as simple to use.
