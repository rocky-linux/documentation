---
title: Installing Nerd Fonts
author: Franco Colussi
contributors: Steven Spencer, Ganna Zhyrnova, Christine Belzie
tested: 8.6, 9.0
tags:
    - nvchad
    - coding
    - fonts
---

# :material-format-font: Nerd Fonts - Fonts for Developers

## :material-format-font: What is Nerd Fonts?

![Nerd Fonts](images/nerd_fonts_site_small.png){ align=right } Nerd Fonts are a collection of modified fonts aimed at developers. In particular, "iconic fonts" such as [Font Awesome](https://fontawesome.com/), [Devicons](https://devicon.dev/), and [Octicons](https://primer.style/foundations/icons) are used to add extra glyphs.

Nerd Fonts also takes the most popular programming fonts such as MonoLisa or SourceCode Pro and modifies them by adding a group of glyphs (icons). A font patcher is available if the font you'd like to use has not already been edited.  There's also a preview feature where you can see how the font should look in the editor. For more information, check out the project's main [site](https://www.nerdfonts.com/).

## :material-monitor-arrow-down-variant: Download

Fonts are available for download at:

```text
https://www.nerdfonts.com/font-downloads
```

### :material-monitor-arrow-down-variant: Installation procedure

The installation of Nerd Fonts in Rocky Linux is done entirely from the command line thanks to the implementation of the procedure provided by the project repository [ryanoasis/nerd-fonts](https://github.com/ryanoasis/nerd-fonts), the procedure uses *git* to retrieve the required fonts and *fc-cache* for their configuration.

!!! Note

    This method can be used on all *linux* distributions that use [fontconfig](https://www.freedesktop.org/wiki/Software/fontconfig/) for system font management.

To begin, retrieve the necessary files from the project repository:

```bash
git clone --filter=blob:none --sparse git@github.com:ryanoasis/nerd-fonts
```

This command downloads only the necessary files omitting the fonts contained in *patched-fonts* so as not to weigh down the local repository with fonts that later will not be used, thus allowing for selective installation.  
This guide will use the [IBM Plex Mono](https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/IBMPlexMono) font, which offers a clean and slightly typographic display, features that make it particularly suitable for writing Markdown documentation.  
For an overview, with preview, of available fonts you can visit the [dedicated site](https://www.programmingfonts.org/#plex-mono).

Go to the newly created folder and then download the font set with the commands:

```bash
cd ~/nerd-fonts/
git sparse-checkout add patched-fonts/IBMPlexMono
```

The command will download the fonts to the *patched-fonts* folder and once finished you can install them with the ==install.sh== script provided, type:

```bash
./install.sh IBMPlexMono
```

!!! Note "Reserved Name"

    The font during installation is renamed to *BlexMono* to comply with the SIL Open Font License (OFL) and in particular the [reserved name mechanism](http://scripts.sil.org/cms/scripts/page.php?item_id=OFL_web_fonts_and_RFNs#14cbfd4a).

The *install.sh* script copies the fonts to the user folder `~/.local/share/fonts/` and invokes the *fc-cache* program to register them on the system. Once finished the fonts will be available for the terminal emulator, in particular we will find the following fonts installed:

```text title="~/.local/share/fonts/"
NerdFonts/
├── BlexMonoNerdFont-BoldItalic.ttf
├── BlexMonoNerdFont-Bold.ttf
├── BlexMonoNerdFont-ExtraLightItalic.ttf
├── BlexMonoNerdFont-ExtraLight.ttf
├── BlexMonoNerdFont-Italic.ttf
├── BlexMonoNerdFont-LightItalic.ttf
├── BlexMonoNerdFont-Light.ttf
├── BlexMonoNerdFont-MediumItalic.ttf
├── BlexMonoNerdFont-Medium.ttf
├── BlexMonoNerdFont-Regular.ttf
├── BlexMonoNerdFont-SemiBoldItalic.ttf
├── BlexMonoNerdFont-SemiBold.ttf
├── BlexMonoNerdFont-TextItalic.ttf
├── BlexMonoNerdFont-Text.ttf
├── BlexMonoNerdFont-ThinItalic.ttf
├── BlexMonoNerdFont-Thin.ttf
```

## :material-file-cog-outline: Configuration

At this point the Nerd Font of your choice should be available for selection. To actually select it you must refer to the desktop you are using.

![Font Manager](images/font_nerd_view.png)

If you are using the default Rocky Linux desktop (Gnome), to change the font in the terminal emulator you will just need to open `gnome-terminal`, go to "Preferences", and set the Nerd Font for your profile.
