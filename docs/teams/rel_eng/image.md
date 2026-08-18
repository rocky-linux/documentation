---
title: Rocky Linux ISOs and Images
author: Release Engineering
contributors: Steven Spencer
---

For a given Rocky Linux release, Release Engineering provides the generation of ISOs and images to the community. This process provides different methods of installing Rocky Linux, whether that is a full DVD iso, a boot iso, live desktop, or even cloud, images.

It is important to note that the images and what they provide may differ between major releases. This can include packages, installable or installed groups, and more.

## About ISO Images

| Version                                                       | boot | minimal | dvd | Architectures                            |
|---------------------------------------------------------------|------|---------|-----|------------------------------------------|
| [Rocky Linux 8](http://dl.rockylinux.org/pub/rocky/8/isos/)   | Yes  | Yes     | Yes | x86_64, aarch64                          |
| [Rocky Linux 9](http://dl.rockylinux.org/pub/rocky/9/isos/)   | Yes  | Yes     | Yes | x86_64, aarch64, ppc64le, s390x          |
| [Rocky Linux 10](http://dl.rockylinux.org/pub/rocky/10/isos/) | Yes  | Yes     | Yes | x86_64, aarch64, ppc64le, s390x, riscv64 |

Every Rocky Linux release gets a set of ISOs. These ISOs are made by the tooling used to make and finalize the distribution. For a given Rocky Linux release, they will live in an `isos` directory at the root of a Rocky Linux release.

There are three formats for the ISO's. See the notes below.

### Notes about multiple ISO images

There are multiple templated formats for each ISO you may see.

| Format                   | Type     | Context                   |
|--------------------------|----------|---------------------------|
| Rocky-X.Y-ARCH-TYPE      | ISO File | Day of release ISO        |
| Rocky-X.Y-DATE-ARCH-TYPE | ISO File | Rebuilt ISO               |
| Rocky-ARCH-TYPE          | Symlink  | Symlink to the latest ISO |

* X is the major version
* Y is the minor version
* ARCH is the architecture
* DATE will be the date the ISO was built (if applicable)
* TYPE will be the type of ISO (boot, dvd, minimal)

The first format is the most common and is the day-of-release ISO.

The second format is in the case of rebuilt ISOs, typically in the case of addressing a bug or providing updated images (in the case of a newer kernel, a new secure boot shim, and so on).

The third format is a symlink to the "latest" ISO, which is deprecated and will not appear in versions after Rocky Linux 9.

### Notes about what each ISO does

Each provided ISO has a specific purpose.

* The `boot` image, also known as the "net install" media, is used to perform Rocky Linux installations over the internet.
* The `minimal` image is typically used to install a minimal Rocky Linux environment without downloading the entire DVD image or using the `boot` ISO to do so.

    * The equivalent dnf group or environment would be `Minimal Install`
    * The equivalent dnf group or environment for a kickstart would be `@^minimal-environment` - This can also be used with dnf install as `@minimal-environment`
* The `dvd` image, or also known as the "everything" or "BaseOS" media, contains everything needed to do a custom installation of Rocky Linux without needing an internet connection.

### Notes about writing the ISO

There are many ways to write ISOs to a USB. Listed here are the recommended and not recommended methods.

#### Recommended

* Fedora Media Writer

    * [Windows](https://getfedora.org/fmw/FedoraMediaWriter-win32-latest.exe)
    * [MacOS](https://getfedora.org/fmw/FedoraMediaWriter-osx-latest.dmg)
    * On Fedora: `dnf install mediawriter`
* [dd for windows](http://www.chrysocome.net/dd)
* [Rawrite32](https://www.netbsd.org/~martin/rawrite32/)

#### Not recommended (avoid)

Release Engineering lists the following tools as **do not use**. They might break isohybrid images or cause other inconsistencies:

* rufus
* unetbootin
* multibootusb
* universal usb installer

!!! warning

    Rufus can **only** work for Rocky Linux images if you use "dd mode". Do **not** use ISO mode as it will result in a broken installer. Release Engineering recommends that you use a writer from the recommended section on this page.

## About Cloud Images

Every Rocky Linux release gets a set of cloud images that cloud infrastructure can use as they see fit. They live in an `images` directory at the root of a Rocky Linux release.

| Version                                                         | Generic Cloud                   | EC2                   |
|-----------------------------------------------------------------|---------------------------------|-----------------------|
| [Rocky Linux 8](https://dl.rockylinux.org/pub/rocky/8/images/)  | Yes (x86_64, aarch64)           | Yes (x86_64, aarch64) |
| [Rocky Linux 9](https://dl.rockylinux.org/pub/rocky/9/images/)  | Yes (x86_64, aarch64, others\*) | Yes (x86_64, aarch64) |
| [Rocky Linux 10](https://dl.rockylinux.org/pub/rocky/10/images/)| Yes (x86_64, aarch64, others\*) | Yes (x86_64, aarch64) |

There are two formats for the images:

| Format                                    | Type       | Context                             |
|-------------------------------------------|------------|-------------------------------------|
| Rocky-X-CLOUD{-TYPE}-X.Y-DATE-ARCH.FORMAT | Image File | Any given cloud image               |
| Rocky-X-CLOUD{-TYPE}.latest.ARCH.FORMAT   | Symlink    | Symlink to the latest image         |
| Rocky-X-CLOUD.latest.ARCH.FORMAT          | Symlink    | Symlink to the latest primary image |

* X is the major version
* Y is the minor version
* ARCH is the architecture
* DATE will be the date of when the image was produced (YYYYMMDD.X, X starts at 0)
* CLOUD will the type of cloud image (e.g., GenericCloud)
* TYPE will be the type of image such as Base or LVM, if applicable
* FORMAT will be `raw` or `qcow2`

The first format will always exist. Cloud images will appear in this format in majority of cases and there might be more than one at any given time. Updates can occur for newer kernels or to address issues in previous versions. This means the date will change frequently.

The second format is a symlink to the latest cloud image of that variant and type, if applicable.

The third format is a symlink to the latest available image. Users, mirrors, and service providers can script this download location if they want to always pull the latest available. This is typically the "Base" variant.

## About Live Images

Every Rocky Linux release provides a set of live images that a user can download, boot, use, and optionally install to their systems. The live images are desktop oriented images that are primarily for desktop use cases and try to closely match similarly to what Fedora provides for their releases.

| Version                                                        | GNOME / Workstation | KDE     | XFCE | Architectures   |
|----------------------------------------------------------------|---------------------|---------|------|-----------------|
| [Rocky Linux 8](https://dl.rockylinux.org/pub/rocky/8/live/)   | Yes                 | No\*    | Yes  | x86_64          |
| [Rocky Linux 9](https://dl.rockylinux.org/pub/rocky/9/live/)   | Yes                 | Yes     | Yes  | x86_64, aarch64 |
| [Rocky Linux 10](https://dl.rockylinux.org/pub/rocky/10/live/) | Yes                 | Yes     | No   | x86_64, aarch64 |

\* This image is not available either due to image/package issues or issues with the desktop environment in that version of Rocky Linux.

### Notes about missing architectures

There might be other live images for different architectures in the future. You can check availability by going to the Rocky Linux version link to see if another architecture exists.

### Notes about Kickstarts

You can find the kickstarts that help generate these live images at [https://git.resf.org/sig_core/kickstarts](https://git.resf.org/sig_core/kickstarts) and the mirror at [https://github.com/rocky-linux/kickstarts](https://github.com/rocky-linux/kickstarts).

## About Pi Images (maintained by SIG/AltArch)

The raspberry pi images are exactly what is labeled on the tin: images for the means of installing to an sd card to run Rocky Linux on a raspberry pi. SIG/AltArch community members support these images.

You can find these images in the [SIG](http://dl.rockylinux.org/pub/sig/) directories.

You can find the git repository that contains the kickstart and other related data for the creation of these images at [https://git.resf.org/sig_altarch/RockyRpi](https://git.resf.org/sig_altarch/RockyRpi).

For general quickstart information, checkout the readme for the images.

| Version                                                                                        | README (direct)                                                                 |
|----------------------------------------------------------------------------------------------- |---------------------------------------------------------------------------------|
| [Rocky Linux 8 for Raspberry Pi](https://dl.rockylinux.org/pub/sig/8/altarch/aarch64/images/)  | [README](https://dl.rockylinux.org/pub/sig/8/altarch/aarch64/images/README.txt) |
| [Rocky Linux 9 for Raspberry Pi](https://dl.rockylinux.org/pub/sig/9/altarch/aarch64/images/)  | [README](https://dl.rockylinux.org/pub/sig/9/altarch/aarch64/images/README.txt) |
| [Rocky Linux 10 for Raspberry Pi](https://dl.rockylinux.org/pub/sig/10/altarch/aarch64/images/)| [README](https://dl.rockylinux.org/pub/sig/10/altarch/aarch64/images/README.txt)|
