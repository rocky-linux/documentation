---
title: Business & Office Apps
author: Ezequiel Bruni
contributors: Steven Spencer
---

## Introduction

Whether you have a shiny new Linux-based work notebook, or you are trying to set up a home office environment, you might be wondering where all of your usual office and business apps are.

Well, many of them are on Flathub. In this guide, you will learn how to install the most common of these apps, and the guide provides you with a list of viable alternatives. If you want to know how to install Office, Zoom, and more, read on.

## Assumptions

This guide assumes the following:

* Rocky Linux with a graphical desktop environment
* The authority to install software on your system
* Flatpak and Flathub installed and working

## How to install common business software on Rocky linux

It is pretty easy. For most of them, you just install Flatpak and Flathub, go to the Software center, look for what you want, and install it. That will take care of quite a few of the most common options. For others, you will need to use the browser versions of the apps.

![A screenshot of Zoom in the software center](images/businessapps-01.png)

To get you started, here is a list of some of the most common business apps -- the ones that have desktop clients at least -- and the best ways to get them.

!!! Note

    If you just want to know about the state of Microsoft Office on Linux, scroll on down and past the next section. It is a slightly complex topic.

    Additionally, this list simply will not include apps like Jira, which do not have official desktop apps.

### Asana Desktop

Desktop app: Not available on Linux

Recommended: Use the web version.

### Discord (yes, some people use it for business)

Desktop app: Official and third-party apps available with Flathub in the Software center

Recommended: Use the official client if you need push-to-talk. Use the browser version -- or any of the half a dozen third-party clients in the Software center.

### Dropbox

Desktop app: Official app available with Flathub in the Software center.

Recommended: Use the official app in GNOME and most other desktop environments. If you are running KDE, use the built-in Dropbox integration

### Evernote

Desktop app: No longer available for Linux.

Recommended: Use the web version.

### Freshbooks

Desktop app: Not available on Linux.

Recommended: Use the web version.

### Google Drive

Desktop app: Third party clients.

Recommended: Use the Online Accounts feature in GNOME Shell or KDE to log into your Google account directly. On GNOME, this will give you integrated access to your files, email, calendar, to-do lists, and more.

On KDE... well, you can browse and manage your Drive files from the file manager. It is not as fully integrated as GNOME, but still useful.

### Hubspot

Desktop app: Not available on Linux.

Recommended: Use the web version.

### Microsoft Exchange

Desktop app: Third party clients only.

Recommended: In GNOME, you can use the Online Accounts feature to integrate your apps with Exchange much like you can with a Google account.

On any other Desktop environment, use Thunderbird with one of *several* Exchange-enabling addons. Thunderbird is available in the default Rocky Linux repository, but you can get a newer version with Flathub.

### Notion

Desktop app: Not available on Linux.

Recommended: Use the web version.

### Outlook

Desktop app: Third party apps only.

Recommended: Use the email client of your choice. Both Evolution and Thunderbird are fantastic options. Or just use the web version.

### Quickbooks

Desktop app: Not available on Linux.

Recommended: Use the web version.

### Slack

Desktop app: Available with Flathub in the Software center.

Recommended: Use the app or the web version as you prefer.

### Teams

Desktop app: Available with Flathub in the Software center.

Recommended: Use it on the desktop or in your browser as you see fit. Just note that either way, if you need to enable screen sharing, you should log into an X11 session when you boot up your PC. Screen sharing is not yet supported on Wayland.

### Zoom

Desktop app: Available with Flathub in the Software center.

Recommended: If you are going to use the desktop app on Rocky Linux, use the X11 session when you log in to your PC, rather than Wayland, if you need to share your screen. Screen sharing does work in Wayland nowadays, but only on newer versions of the software.

Rocky Linux, being a stable enterprise operating system at heart, will take some time to catch up.

However, depending on your browser, you might have better luck screen sharing on Wayland by skipping the desktop app altogether, and just using the web version.

## Open source alternatives to common business apps

If you have the option to choose your own software for work and productivity, you might consider changing up your routine and trying an open source alternative. In fact, most of the apps listed above can actually be replaced with a self-hosted or cloud-hosted instance of [Nextcloud(https://nextcloud.com)], along with some third-party apps that you can install on that platform.

Seriously, it can handle file sync, project management, CRM, your calendar, note management, basic bookkeeping, your email, and even text and video chat with some work and setup. It really is that versatile.

For a more advanced and enterprise-ready alternative to Nextcloud, [Wikisuite](https://wikisuite.org/Software) can do pretty much everything listed above, and help you build your company website besides. It is a lot like Odoo that way.

However, note that these platforms are mostly web-centric. The Nextcloud Desktop client is pretty much only for file syncing, and Wikisuite does not have one.

You can replace Slack handily with [Mattermost](https://mattermost.com), an open source chat and team management platform. If you need the video and audio features provided by Discord, Teams, or Zoom, though, you can add [Jitsi Meet](https://meet.jit.si) to the mix. It is a bit like a self-hostable Google Meet.

Both Mattermost and Jitsi have Linux desktop clients on Flathub as well.

The same goes for [Joplin](https://joplinapp.org) and [QOwnNotes](https://www.qownnotes.org/), and [Notesnook](https://notesnook.com), which are fantastic alternatives to Evernote.

Looking for an alternative to Notion in the Software center? [AppFlowy](https://appflowy.io) or [SiYuan](https://b3log.org/siyuan/en/) might be what you need.

!!! Note

    While every alternative app listed above is open source, they are not all "Free Libre and Open Source (FLOSS)". This means that some of them charge money for extra features, or premium versions of their services.

## Microsoft Office (does not work) on Rocky Linux

Ah Microsoft office. Newcomers to the Linux world might wonder what is so difficult about making that work. It is not difficult at all, if you are okay with using the web version of Office365. That works just fine.

But if you need the full desktop experience, with all the bells and whistles that the Windows apps provide, you will have a harder time. While every so often someone writes a tutorial about how to make the latest version of the Office apps work on Linux with WINE, these solutions often break sooner than later. There is just no stable way to get the desktop apps running on Linux for now.

Yes, there are Linux-friendly office suites with a degree of compatibility with Microsoft Office, but the real problem then is Excel.

The desktop version of Excel is, up to this point, pretty much unparalleled in terms of features, ways to manipulate data, and so on. It is, admittedly, a beast of a program that others find hard to replicate.

Even when the alternatives have all the features that a particular user might need, the workflow is different. You cannot drop your most complicated formulae and spreadsheets into one of the alternatives, not even the web version of Excel, and just expect it to work.

But, if Excel is not a huge part of your workflow, by all means check out the alternatives. They are *all* available in the Software center with Flathub.

### Microsoft Office alternatives for Rocky Linux

#### LibreOffice

[LibreOffice](https://www.libreoffice.org) is the de-facto standard in FLOSS office and productivity software. It covers most of your office needs: documents, spreadsheets, presentations, vector drawing software (built with printing in mind), and databases.

It has decent but not perfect compatibility with Microsoft Office in general, but it is *very* good at handling open formats. If you want to divorce yourself from the Microsoft ecosystem completely, LibreOffice is probably your best option.

There is also a web-hosted version called Collabora Office, but that one has limitations unless you pay for the premium versions.

#### OnlyOffice

[OnlyOffice](https://www.onlyoffice.com) is a slightly less-comprehensive but still fantastic suite of apps that covers the creation of documents, presentations, spreadsheets, and PDF forms. Notably, there is also a PDF editor.

If you need Microsoft Office compatibility, particularly for documents and presentations, then OnlyOffice is probably your best choice. This author can attest that OnlyOffice is, in my experience, actually better at handling Word documents than the online version of Office365.

#### WPS Office

[WPS Office](https://www.wps.com), formerly Kingsoft Office, has actually been around the Linux ecosystem for quite some time. It also features support for docs, spreadsheets, presentations, and a PDF editor.

WPS Office has slightly better Microsoft Office compatibility than LibreOffice, but it is not as compatible as OnlyOffice. It also has fewer features, and is less customizable. The author is not saying that, they are. This is an excerpt from their own blog:

![WPS Office has a more modern and user-friendly interface than Onlyoffice. It is also easier to learn and use, especially for beginners. WPS Office also has a wider range of templates and themes available, making it easier to create professional-looking documents. Onlyoffice is more powerful and customizable than WPS Office. It has a wider range of features, including document management and project management tools. Onlyoffice is also more compatible with Microsoft Office formats than WPS Office.](images/businessapps-02.png)

They themselves state that their primary focus is on creating a simpler and easier experience for users. And hey, that might be exactly what you want.

#### Honorable mention: Calligra

The [Calligra](https://calligra.org) office suite is a FLOSS project by the developers of KDE to create a user-friendly set of basic office apps that covers the creation of documents, spreadsheets, presentations, databases, flowcharts, vector drawing, ebooks, and more.

However, the Calligra apps are not too easy install on Rocky Linux. If you have another machine running Fedora, the author encourages you to give it a try.

## Conclusion

With some notable exceptions, using all of your standard office software on Rocky Linux is a matter of either finding the apps on Flathub, or just using the web version. Either way, you will likely find that Rocky makes a stable and convenient platform for most typical office tasks.

And if the lack of desktop Excel support is a deal-breaker for you, the author recommends using a full on database server. You can do some amazing things with database servers.
