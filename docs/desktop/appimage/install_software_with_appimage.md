---
title: Install Software with AppImage
author: Joseph Brinkman
contributors:
---

## Introduction

AppImages are a convenient way to install software on Linux without using package managers or the command line. They are single-file executables that contain all the program's dependencies, making them easy to run on various Linux distributions. Installing software with an AppImage may serve as a simpler and more straightforward process than managing repositories or building from source for end-users that are already familiar with Windows and Mac operating systems. 


Installing programs on your Rocky Linux desktop with AppImage is a three step process: 

1. Download the desired program's AppImage.
2. Make the program executable.
3. Run the program to install it. 


This guide uses Krita as the example program we will download and install using AppImage. Krita is a free and open-source graphic design software. We won't dive into the details of Krita, but you can [read more about it on their website](https://krita.org/). 

## Assumptions

For this guide, you need the following:

* Rocky Linux with a desktop environment installed.
* `sudo` privileges.

## Downloading a Program's AppImage

The first step of installing software using an AppImage is downloading the program's AppImage. To download the Krita AppImage, go to the [Download](https://krita.org/en/download/) page, and click the `Download` button.

![Click download appimage button](images/download_krita_appimage.webp)

## Installing a Program using its AppImage

After downloading the AppImage, you will need to navigate to the `Downloads` folder to make the file executable before running it.

In the top left corner of your Rocky Linux desktop, click Activities:

![Rocky linux deskop with default wall paper. The mouse is hovered over the activities button.](images/activites_appimage.webp)

Once the activities panel launches, type 'files' into the search field. Click the Files app:

![Activites pane on a Rocky linux system. 'Files' is typed into the search field. The Files app is hovered over.](images/searchbar_files_appimage.webp)

Files will launch in the home directory. Click the Downloads folder:

![The Files app is open and the mouse is hovered over the Downloads folder.](images/files_downloads_appimage.webp)

Now that you have navigated to the directory that the AppImage is in, it's time to make the program executable. Right-click the AppImage file and select properties:

![The AppImage file is selected. The mouse is hovered over properties.](images/file_properties_appimage.webp)

Select permissions from the file properties menu:

![Permissions is selected in the file properties menu](images/permissions_appimage.webp)

Select the checkbox labeled 'Execute' before closing the properties menu:

![The checkbox labeled 'Execute' has been selected](images/file_properties_allow_executing_file_as_program_appimage.webp)

If you'd rather use the command line, open terminal and run the following command to make the AppImage executable:

```bash
sudo chmod a+x ~/Downloads/krita*.appimage
```

## Running a Program using its AppImage

You have reached the final step - running your AppImage! 

!!! Note

    Running an AppImage doesn't install the program into your system's files like traditional software packages do. What this means is that everytime you want to use the program you will need to double-click the AppImage. It is important to store the AppImage in a safe and memorable place for this reason. 

Double-click the AppImage:

![The AppImage is selected indicating it was double-clicked and ran](images/run_app_image.webp)

You can alternatively run the following shell command instead of double-clicking the AppImage:

 ```bash
    ./krita*.appimage
```

Shortly after running the AppImage, Krita will launch!

![The Krita app launcher](images/krita_launching.webp)

## Conclusion

This guide taught you how to use a program using its AppImage. AppImage's are convienent for end-users because they don't need to know how to manage repositories, build from source, or use the command line to use their favorite programs that have an available AppImage. 