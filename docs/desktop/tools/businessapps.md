---
title: Business & Office Apps
author: Ezequiel Bruni
contributors: Steven Spencer, Ganna Zhyrnova
---

## Introduction

Whether you have a shiny new Linux-based work notebook or are trying to set up a home office environment, you might wonder where your usual office and business apps are.

Many of them are on Flathub. This guide teaches you how to install the most common of these apps and provides a list of viable alternatives. Read on to learn how to install Office, Zoom, and more.

## Assumptions

This guide assumes the following:

* Rocky Linux with a graphical desktop environment
* The authority to install software on your system
* Flatpak and Flathub installed and working

## How to install common business software on Rocky Linux

For most of them, you install Flatpak and Flathub, go to the Software Center, look for what you want, and install it. That will take care of quite a few of the most common options. For others, you will need to use the browser versions of the apps.

![A screenshot of Zoom in the software center](images/businessapps-01.png)

To get you started, here is a list of some of the most common business apps with desktop clients and the best ways to get them.

!!! Note

    If you want to know about the state of Microsoft Office on Linux, scroll down and past the next section.

   Additionally, this list will not include apps like Jira, which do not have official desktop apps.

### Asana Desktop

Desktop app: Not available on Linux

Recommended: Use the web version.

### Discord

Desktop app: Official and third-party apps available with Flathub in the Software center

Recommended: Use the official client if you need push-to-talk. Use the browser version or any third-party clients in the Software center.

### Dropbox

Desktop app: The official app is available with Flathub in the software center.

Recommended: Use the official app in GNOME and most other desktop environments. If you are running KDE, use the built-in Dropbox integration.

### Evernote

Desktop app: No longer available for Linux.

Recommended: Use the web version.

### Freshbooks

Desktop app: Not available on Linux.

Recommended: Use the web version.

### Google Drive

Desktop app: Third-party clients.

Recommended: Log into your Google account using the Online Accounts feature in GNOME Shell or KDE. This will give you integrated access to your files, email, calendar, to-do lists, and more on GNOME.

You can browse and manage your Drive files from the file manager on KDE. It is not as fully integrated as GNOME, but still useful.

### Hubspot

Desktop app: Not available on Linux.

Recommended: Use the web version.

### Microsoft Exchange

Desktop app: Third-party clients only.

Recommended: In GNOME, you can use the Online Accounts feature to integrate your apps with Exchange, much like a Google account.

On any other Desktop environment, use Thunderbird with one of *several* Exchange-enabling addons. Thunderbird is available in the default Rocky Linux repository, but you can get a newer version with Flathub.

### Notion

Desktop app: Not available on Linux.

Recommended: Use the web version.

### Outlook

Desktop app: Third-party apps only.

Recommended: Use the email client of your choice. Evolution and Thunderbird are good options or use the web version.

### Quickbooks

Desktop app: Not available on Linux.

Recommended: Use the web version.

### Slack

Desktop app: This app is available with Flathub in the software center.

Recommended: Use the app or the web version as you prefer.

### Teams

Desktop app: This app is available with Flathub in the software center.

Recommended: Use it on the desktop or your browser as you see fit. If you need to enable screen sharing, log into an X11 session when you boot up your PC. Screen sharing is not yet supported on Wayland.

### Zoom

Desktop app: This app is available with Flathub in the software center.

Recommended: If you use the desktop app on Rocky Linux, log in to your PC using the X11 session rather than Wayland if you need to share your screen. Screen sharing works in Wayland nowadays, but only on newer software versions.

Being a stable enterprise operating system at heart, Rocky Linux will take some time to catch up.

However, depending on your browser, you might have better luck screen sharing on Wayland by skipping the desktop app altogether and just using the web version.

## Open source alternatives to standard business apps

If you can choose your software for work and productivity, you might consider changing your routine and trying an open-source alternative. Most of the apps listed above can be replaced with a self-hosted or cloud-hosted instance of [Nextcloud](https://nextcloud.com), and some third-party apps you can install on that platform.

It can handle file sync, project management, CRM, calendar, note management, basic bookkeeping, email, and, with some work and setup, text and video chat.

For a more advanced and enterprise-ready alternative to Nextcloud, [Wikisuite](https://wikisuite.org/Software) can do everything listed above and help you build your company website. It is a lot like Odoo that way.

However, note that these platforms are primarily web-centric. The Nextcloud Desktop client is only for file syncing, and Wikisuite does not have one.

You can replace Slack handily with [Mattermost](https://mattermost.com), an open-source chat and team management platform. If you need the video and audio features provided by Discord, Teams, or Zoom, though, you can add [Jitsi Meet](https://meet.jit.si) to the mix. It is a bit like a self-hostable Google Meet.

Both Mattermost and Jitsi have Linux desktop clients on Flathub as well.

The same goes for [Joplin](https://joplinapp.org) and [QOwnNotes](https://www.qownnotes.org/), and [Notesnook](https://notesnook.com), which are fantastic alternatives to Evernote.

LAre you looking for an alternative to Notion in the Software center? [AppFlowy](https://appflowy.io) or [SiYuan](https://b3log.org/siyuan/en/) might be what you need.

!!! Note

    While every alternative app listed above is open source, not all are "Free Libre and Open Source (FLOSS)." This means some charge money for extra features or premium versions of their services.

## Microsoft Office on Rocky Linux

Newcomers to the Linux world might wonder what is so difficult about making that work. It is not difficult if you are okay with using the web version of Office365.

However, it will be more challenging if you need the whole desktop experience, with all the bells and whistles the Windows apps provide. While occasionally someone writes a tutorial about how to make the latest version of the Office apps work on Linux with WINE, these solutions often break sooner rather than later. There is no stable way to get the desktop apps running on Linux.

There are Linux-friendly office suites compatible with Microsoft Office, but the real problem is Excel.

Up to this point, the desktop version of Excel has been virtually unparalleled in terms of features, ways to manipulate data, and so on. Admittedly, it is a beast of a program that others find hard to replicate.

The workflow is different even when the alternatives have all the features a particular user might need. You cannot drop your most complicated formulae and spreadsheets into one of the alternatives, not even the web version of Excel, and expect it to work.

But, if Excel is not a huge part of your workflow, by all means check out the alternatives. They are *all* available in the Software center with Flathub.

### Microsoft Office alternatives for Rocky Linux

#### LibreOffice

[LibreOffice](https://www.libreoffice.org) is the de-facto standard in FLOSS office and productivity software. It covers most of your office needs: documents, spreadsheets, presentations, vector drawing software (built with printing in mind), and databases.

It generally has decent but not perfect compatibility with Microsoft Office, but it is *very* good at handling open formats. If you want to completely divorce yourself from the Microsoft ecosystem, LibreOffice is probably your best option.

There is also a web-hosted version called Collabora Office, which has limitations unless you pay for the premium versions.

#### OnlyOffice

[OnlyOffice](https://www.onlyoffice.com) is a slightly less comprehensive but still fantastic suite of apps for creating documents, presentations, spreadsheets, and PDF forms. Notably, it also includes a PDF editor.

If you need Microsoft Office compatibility, particularly for documents and presentations, then OnlyOffice is probably your best choice. OnlyOffice is better at handling Word documents than the online version of Office365.

#### WPS Office

[WPS Office](https://www.wps.com), formerly Kingsoft Office, has been around the Linux ecosystem for quite some time. It also supports docs, spreadsheets, presentations, and a PDF editor.

WPS Office has slightly better Microsoft Office compatibility than LibreOffice, but it is not as compatible as OnlyOffice. It also has fewer features and is less customizable. This is an excerpt from their blog:

![WPS Office has a more modern and user-friendly interface than Onlyoffice. It is also easier to learn and use, especially for beginners. WPS Office also has a wider range of templates and themes available, making it easier to create professional-looking documents. Onlyoffice is more powerful and customizable than WPS Office. It has a wider range of features, including document management and project management tools. Onlyoffice is also more compatible with Microsoft Office formats than WPS Office.](images/businessapps-02.png)

Their primary focus is creating a more straightforward and accessible user experience, which might be exactly what you want.

#### Calligra

The [Calligra](https://calligra.org) office suite is a FLOSS project by the developers of KDE. It provides a user-friendly set of basic office apps for creating documents, spreadsheets, presentations, databases, flowcharts, vector drawings, ebooks, and more.

However, the Calligra apps are not easy to install on Rocky Linux. If you have another machine running Fedora, the author encourages you to try it.

## Conclusion

With some notable exceptions, using all of your office software on Rocky Linux is finding the apps on Flathub or just using the web version. Either way, Rocky Linux will likely be a stable and convenient platform for most typical office tasks.

If the lack of desktop Excel support is a deal-breaker for you, the author recommends using a full-on database server. Database servers can do some amazing things.
