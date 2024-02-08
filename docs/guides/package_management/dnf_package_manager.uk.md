---
title: Менеджер пакетів DNF
author: Emre Camalan
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 8.9, 9.3
tags:
  - Dnf
  - Yum
  - Rpm
  - Менеджер пакетів
---

# Менеджер пакетів DNF

DNF, або Dandified Yum, — це менеджер пакетів у деяких дистрибутивах Linux. Це версія нового покоління менеджера пакетів Yum (Yellowdog Updater, Modified), який широко використовується в системах на основі Red Hat. DNF було представлено як заміну Yum, щоб усунути деякі обмеження та покращити продуктивність.

DNF зазвичай використовується в Rocky Linux, Fedora, RHEL (Red Hat Enterprise Linux) 8 і новіших версіях та інших дистрибутивах Linux, які прийняли його як менеджер пакетів. Його мета — надати користувачам і адміністраторам більш сучасний і ефективний досвід керування пакетами.

## Передумови

- Для всіх версій Rocky Linux можливість використовувати `sudo` для підвищення привілеїв.

## Встановлення пакетів

Ви можете використовувати менеджер пакетів DNF в операційній системі Rocky Linux так само, як і інші менеджери пакунків, щоб установлювати, видаляти та оновлювати потрібні пакети.

```bash
sudo dnf install package_name1 package_name2 package_name3 
```

Щоб встановити perl:

```bash
sudo dnf install perl
Last metadata expiration check: 0:57:51 ago on Mon 05 Feb 2024 08:31:09 PM UTC.
Dependencies resolved.
==============================================================================================================================
 Package                                  Architecture       Version                              Repository             Size
==============================================================================================================================
Installing:
 perl                                     x86_64             4:5.32.1-480.el9                     appstream              13 k
Installing dependencies:
 annobin                                  x86_64             12.12-1.el9                          appstream             977 k
 binutils                                 x86_64             2.35.2-42.el9                        baseos                4.5 M
 binutils-gold                            x86_64             2.35.2-42.el9                        baseos                734 k
 cpp                                      x86_64             11.4.1-2.1.el9                       appstream              11 M
 dwz                                      x86_64             0.14-3.el9                           appstream             127 k
 efi-srpm-macros                          noarch             6-2.el9_0                            appstream              22 k
 elfutils-debuginfod-client               x86_64             0.189-3.el9                          baseos                 36 k
 file                                     x86_64             5.39-14.el9                          baseos                 48 k
 fonts-srpm-macros                        noarch             1:2.0.5-7.el9.1                      appstream              27 k
 gcc                                      x86_64             11.4.1-2.1.el9                       appstream              32 M
 gcc-c++                                  x86_64             11.4.1-2.1.el9                       appstream              13 M
 gcc-plugin-annobin                       x86_64             11.4.1-2.1.el9                       appstream              48 k
 ghc-srpm-macros                          noarch             1.5.0-6.el9                          appstream             7.8 k
 glibc-devel                              x86_64             2.34-83.el9.7                        appstream              50 k
 glibc-headers                            x86_64             2.34-83.el9.7                        appstream             450 k
 go-srpm-macros                           noarch             3.2.0-2.el9                          appstream              26 k
 kernel-headers                           x86_64             5.14.0-362.18.1.el9_3                appstream             6.3 M
 kernel-srpm-macros                       noarch             1.0-13.el9                           appstream              15 k
 libdatrie                                x86_64             0.2.13-4.el9                         appstream              32 k
 libmpc                                   x86_64             1.2.1-4.el9                          appstream              61 k
 libpkgconf                               x86_64             1.7.3-10.el9                         baseos                 35 k

... (some packages not shown)

Installing weak dependencies:
 perl-CPAN-DistnameInfo                   noarch             0.12-23.el9                          appstream              14 k
 perl-Encode-Locale                       noarch             1.05-21.el9                          appstream              19 k
 perl-Term-Size-Any                       noarch             0.002-35.el9                         appstream              13 k
 perl-TermReadKey                         x86_64             2.38-11.el9                          appstream              36 k
 perl-Unicode-LineBreak                   x86_64             2019.001-11.el9                      appstream             120 k

Transaction Summary
==============================================================================================================================
Install  206 Packages

Total download size: 111 M
Installed size: 343 M
Is this ok [y/N]:
```

Встановлення групи пакетів, як для **Xfce desktop** або **Kde desktop** тощо, відбувається подібно до:

```bash
sudo dnf groupinstall xfce
```

Що створить такі результати:

```bash
sudo dnf group install xfce
Last metadata expiration check: 1:04:31 ago on Mon 05 Feb 2024 08:31:09 PM UTC.
Dependencies resolved.
========================================================================================================================================================================================================================================================
 Package                                                                      Architecture                                  Version                                                                    Repository                                        Size
========================================================================================================================================================================================================================================================
Installing group/module packages:

Thunar                                                                       x86_64                                        4.18.6-2.el9                                                               epel                                      1.8 M
 gdm                                                                          x86_64                                        1:40.1-21.el9                                                              appstream                                836 k
 network-manager-applet                                                       x86_64                                        1.26.0-2.el9                                                               appstream                                197 k
 openssh-askpass                                                              x86_64                                        8.7p1-34.el9                                                               appstream                                21 k
 thunar-archive-plugin                                                        x86_64                                        0.5.0-2.el9                                                                epel                                     93 k
 thunar-volman                                                                x86_64                                        4.18.0-2.el9                                                               epel                                     210 k
 tumbler                                                                      x86_64                                        4.18.1-1.el9                                                               epel                                     237 k
 xfce-polkit                                                                  x86_64                                        0.3-8.el9                                                                  epel                                     24 k
 xfce4-appfinder                                                              x86_64                                        4.18.0-2.el9                                                               epel                                     285 k
 xfce4-panel                                                                  x86_64                                        4.18.4-1.el9                                                               epel                                     1.2 M
 xfce4-power-manager                                                          x86_64                                        4.18.2-1.el9                                                               epel                                     733 k
 xfce4-pulseaudio-plugin                                                      x86_64                                        0.4.7-1.el9                                                                epel                                     131 k
 xfce4-screensaver                                                            x86_64                                        4.18.2-1.el9                                                               epel                                     305 k
 xfce4-session                                                                x86_64                                        4.18.3-1.el9                                                               epel                                     541 k
 xfce4-settings                                                               x86_64                                        4.18.2-2.el9                                                               epel                                     1.2 M
 
 ... (some packages not shown)

Installing Groups:
 Xfce                                                                                                                                                                                                                                                        

Transaction Summary
========================================================================================================================================================================================================================================================
Install  402 Packages

Total download size: 317 M
Installed size: 1.1 G
Is this ok [y/N]:
```

Як бачите, є кілька способів інсталювати групу стільниці KDE:

```bash
sudo dnf group install "KDE Plasma Workspaces"
sudo dnf group install kde-desktop-environment
sudo dnf install @kde-desktop-environment
```

## Оновлення пакетів

### Оновлення

Якщо ви вирішите оновити свої пакети, використовуйте цей код на терміналі:

```bash
  sudo dnf update
```

Що може показати щось на зразок цього:

```bash
sudo dnf update
Last metadata expiration check: 1:12:59 ago on Mon 05 Feb 2024 08:31:09 PM UTC.
Dependencies resolved.
========================================================================================================================================================================================================================================================
 Package                                                                 Architecture                                        Version                                                             Repository                                              Size
========================================================================================================================================================================================================================================================
Upgrading:
 NetworkManager                                                          x86_64                                              1:1.44.0-4.el9_3                                                    baseos                                     2.2 M
 NetworkManager-libnm                                                    x86_64                                              1:1.44.0-4.el9_3                                                    baseos                                     1.8 M
 gnutls                                                                  x86_64                                              3.7.6-23.el9_3.3                                                    baseos                                     1.0 M
 openssl                                                                 x86_64                                              1:3.0.7-25.el9_3                                                    baseos                                     1.2 M
 openssl-libs                                                            x86_64                                              1:3.0.7-25.el9_3                                                    baseos                                     2.1 M
 python3                                                                 x86_64                                              3.9.18-1.el9_3.1                                                    baseos                                     25 k
 python3-libs                                                            x86_64                                              3.9.18-1.el9_3.1                                                    baseos                                     7.3 M
 python3-rpm                                                             x86_64                                              4.16.1.3-27.el9_3                                                   baseos                                     64 k
 rocky-gpg-keys                                                          noarch                                              9.3-1.2.el9                                                         baseos                                     13 k
 rocky-release                                                           noarch                                              9.3-1.2.el9                                                         baseos                                     23 k
 rocky-repos                                                             noarch                                              9.3-1.2.el9                                                         baseos                                     13 k
 rpm                                                                     x86_64                                              4.16.1.3-27.el9_3                                                   baseos                                     485 k
 rpm-build-libs                                                          x86_64                                              4.16.1.3-27.el9_3                                                   baseos                                     87 k
 rpm-libs                                                                x86_64                                              4.16.1.3-27.el9_3                                                   baseos                                     307 k
 rpm-plugin-systemd-inhibit                                              x86_64                                              4.16.1.3-27.el9_3                                                   appstream                                  15 k
 rpm-sign-libs                                                           x86_64                                              4.16.1.3-27.el9_3                                                   baseos                                     19 k
 systemd                                                                 x86_64                                              252-18.el9.0.1.rocky                                                baseos                                     3.9 M
 systemd-libs                                                            x86_64                                              252-18.el9.0.1.rocky                                                baseos                                     651 k
 systemd-pam                                                             x86_64                                              252-18.el9.0.1.rocky                                                baseos                                     259 k
 systemd-rpm-macros                                                      noarch                                              252-18.el9.0.1.rocky                                                baseos                                     47 k
 systemd-udev                                                            x86_64                                              252-18.el9.0.1.rocky                                                baseos                                     1.8 M
 tzdata                                                                  noarch                                              2023d-1.el9                                                         baseos                                     433 k

Transaction Summary
========================================================================================================================================================================================================================================================
Upgrade  22 Packages

Total download size: 24 M
Is this ok [y/N]
```

Команда `dnf upgrade` дає ті самі результати, що й команда `dnf update`.

```bash
sudo dnf upgrade
```

### Оновлення одного пакету

```bash
  sudo dnf upgrade package_name
```

Наприклад, якщо ви хочете оновити `openssl`, використовуйте `dnf`:

```bash
dnf upgrade openssl
```

Що може показати:

```bash
dnf upgrade openssl
Last metadata expiration check: 1:21:40 ago on Mon 05 Feb 2024 08:31:09 PM UTC.
Dependencies resolved.
========================================================================================================================================================================================================================================================Package                                                        Architecture                                             Version                                                               Repository                                    Size
========================================================================================================================================================================================================================================================
Upgrading:
 openssl                                                        x86_64                                                   1:3.0.7-25.el9_3                                                      baseos                                       1.2 M
 openssl-libs                                                   x86_64                                                   1:3.0.7-25.el9_3                                                      baseos                                       2.1 M

Transaction Summary
========================================================================================================================================================================================================================================================
Upgrade  2 Packages

Total download size: 3.3 M
Is this ok [y/N]:
```

Якщо ви використовували команди `sudo dnf update` або `sudo dnf upgrade` раніше, уся ваша система оновлена, і не буде пакета для оновлення вручну.

## Видалення пакетів

Подібно до встановлення пакунків, ви можете використовувати `dnf` для видалення пакунків. Однак залежності є вирішальними в системі Linux, і якщо ви про них не знаєте, рекомендується не видаляти пакет. Наприклад, помилково встановлений пакет може мати 20 залежностей, і коли ви видаляєте цей пакет, система також видаляє ці 20 пакетів, якими користуються інші програми. Як наслідок, деякі раніше функціонуючі програми можуть стати непридатними. Крім того, якщо ви думаєте, що можете вирішити це, перевстановивши той самий патч, у вас є старіша версія та стара версія Jesus. Будьте обережні в цьому відношенні.

!!! Warning "Важливо"

```
DNF не може видалити пакет, не видаливши пакети, які від нього залежать.
```

Синтаксис видалення пакетів:

```bash
sudo dnf remove package_name1 package_name2
```

```bash
sudo dnf remove wget 
```

!!! warning "Важливо"

```
Будь обережний; DNF показує залежності пакетів! Якщо ви видалите Perl, ви видалите пакети, які залежать від Perl!
```

```bash
sudo dnf remove perl
Dependencies resolved.
========================================================================================================================================================================================================================================================
 Package                                                                  Architecture                                       Version                                                             Repository                                  Size
========================================================================================================================================================================================================================================================
Removing:
 perl                                                                     x86_64                                             4:5.32.1-480.el9                                                    @appstream                                   0  
Removing unused dependencies:
 annobin                                                                  x86_64                                             12.12-1.el9                                                         @appstream                                 1.0 M
 binutils                                                                 x86_64                                             2.35.2-42.el9                                                       @baseos                                    24 M
 binutils-gold                                                            x86_64                                             2.35.2-42.el9                                                       @baseos                                    2.0 M
 cpp                                                                      x86_64                                             11.4.1-2.1.el9                                                      @appstream                                 29 M
 dwz                                                                      x86_64                                             0.14-3.el9                                                          @appstream                                 275 k
 efi-srpm-macros                                                          noarch                                             6-2.el9_0                                                           @appstream                                 40 k
 elfutils-debuginfod-client                                               x86_64                                             0.189-3.el9                                                         @baseos                                    60 k
 file                                                                     x86_64                                             5.39-14.el9                                                         @baseos                                    100 k
 fonts-srpm-macros                                                        noarch                                             1:2.0.5-7.el9.1                                                     @appstream                                 55 k
 gcc                                                                      x86_64                                             11.4.1-2.1.el9                                                      @appstream                                 85 M
 gcc-c++                                                                  x86_64                                             11.4.1-2.1.el9                                                      @appstream                                 32 M
 gcc-plugin-annobin                                                       x86_64                                             11.4.1-2.1.el9                                                      @appstream                                 52 k
 ghc-srpm-macros                                                          noarch                                             1.5.0-6.el9                                                         @appstream                                 535  
 glibc-devel                                                              x86_64                                             2.34-83.el9.7                                                       @appstream                                 157 k
 glibc-headers                                                            x86_64                                             2.34-83.el9.7                                                       @appstream                                 2.1 M
 go-srpm-macros                                                           noarch                                             3.2.0-2.el9                                                         @appstream                                 60 k
 kernel-headers                                                           x86_64                                             5.14.0-362.18.1.el9_3                                               @appstream                                 5.8 M
 kernel-srpm-macros                                                       noarch                                             1.0-13.el9                                                          @appstream                                 17 k
 libdatrie                                                                x86_64                                             0.2.13-4.el9                                                        @appstream                                 58 k
 libmpc                                                                   x86_64                                             1.2.1-4.el9                                                         @appstream                                 135 k
 libpkgconf                                                               x86_64                                             1.7.3-10.el9                                                        @baseos                                    74 k
 libstdc++-devel                                                          x86_64                                             11.4.1-2.1.el9                                                      @appstream                                 13 M
 libthai                                                                  x86_64                                             0.1.28-8.el9                                                        @appstream                                 760 k
 libxcrypt-devel                                                          x86_64                                             4.4.18-3.el9                                                        @appstream                                 30 k

... (some package removal output not shown)

redhat-rpm-config                                                         noarch                                             201-1.el9                                                           @appstream                                 187 k
 rust-srpm-macros                                                         noarch                                             17-4.el9                                                            @appstream                                 2.4 k
 sombok                                                                   x86_64                                             2.4.0-16.el9                                                        @appstream                                 136 k
 systemtap-sdt-devel                                                      x86_64                                             4.9-3.el9                                                           @appstream                                 198 k

Transaction Summary
========================================================================================================================================================================================================================================================
Remove  206 Packages

Freed space: 343 M
Is this ok [y/N]:
```

Видалення групи має наступний синтаксис. Зауважте, що видалити групу KDE можна кількома способами:

```bash
sudo dnf group remove "KDE Plasma Workspaces"
sudo dnf group remove kde-desktop-environment
sudo dnf remove @kde-desktop-environment
```

## Список DNF

Ви можете перерахувати будь-який пакет, навіть якщо ви не знаєте повної назви пакета, виконавши цю команду:

```bash
sudo dnf list kernel*

Last metadata expiration check: 1:44:26 ago on Mon 05 Feb 2024 08:31:09 PM UTC.
Installed Packages
kernel-headers.x86_64                                                                                                           5.14.0-362.18.1.el9_3                                                                                   @appstream
kernel-srpm-macros.noarch                                                                                                       1.0-13.el9                                                                                              @appstream
Available Packages
kernel.x86_64                                                                                                                   5.14.0-362.18.1.el9_3                                                                                   baseos    
kernel-abi-stablelists.noarch                                                                                                   5.14.0-362.18.1.el9_3                                                                                   baseos    
kernel-core.x86_64                                                                                                              5.14.0-362.18.1.el9_3                                                                                   baseos    
kernel-cross-headers.x86_64                                                                                                     5.14.0-362.18.1.el9_3                                                                                   crb       
kernel-debug.x86_64                                                                                                             5.14.0-362.18.1.el9_3                                                                                   baseos    
kernel-debug-core.x86_64                                                                                                        5.14.0-362.18.1.el9_3                                                                                   baseos    
kernel-debug-devel.x86_64                                                                                                       5.14.0-362.18.1.el9_3                                                                                   appstream 
kernel-debug-devel-matched.x86_64                                                                                               5.14.0-362.18.1.el9_3                                                                                   appstream 
kernel-debug-modules.x86_64                                                                                                     5.14.0-362.18.1.el9_3                                                                                   baseos    
kernel-debug-modules-core.x86_64                                                                                                5.14.0-362.18.1.el9_3                                                                                   baseos    
kernel-debug-modules-extra.x86_64                                                                                               5.14.0-362.18.1.el9_3                                                                                   baseos    
kernel-debug-uki-virt.x86_64                                                                                                    5.14.0-362.18.1.el9_3                                                                                   baseos    
kernel-devel.x86_64                                                                                                             5.14.0-362.18.1.el9_3                                                                                   appstream 
kernel-devel-matched.x86_64                                                                                                     5.14.0-362.18.1.el9_3                                                                                   appstream 
kernel-doc.noarch                                                                                                               5.14.0-362.18.1.el9_3                                                                                   appstream 
kernel-modules.x86_64                                                                                                           5.14.0-362.18.1.el9_3                                                                                   baseos    
kernel-modules-core.x86_64                                                                                                      5.14.0-362.18.1.el9_3                                                                                   baseos    
kernel-modules-extra.x86_64                                                                                                     5.14.0-362.18.1.el9_3                                                                                   baseos    
kernel-rpm-macros.noarch                                                                                                        185-13.el9                                                                                              appstream 
kernel-tools.x86_64                                                                                                             5.14.0-362.18.1.el9_3                                                                                   baseos    
kernel-tools-libs.x86_64                                                                                                        5.14.0-362.18.1.el9_3                                                                                   baseos    
kernel-tools-libs-devel.x86_64                                                                                                  5.14.0-362.18.1.el9_3                                                                                   crb       
kernel-uki-virt.x86_64                                                                                                          5.14.0-362.18.1.el9_3                                                                                   baseos    
kernelshark.x86_64                                                                                                              1:1.2-10.el9                                                                                            appstream
```

Виведіть інформацію про встановлені та доступні інструменти ядра, модулі та відповідну інформацію за допомогою цієї команди:

```bash
sudo dnf list kernel-tools\* kernel-modules\*

Last metadata expiration check: 1:48:22 ago on Mon 05 Feb 2024 08:31:09 PM UTC.
Available Packages
kernel-modules.x86_64                                                                                                           5.14.0-362.18.1.el9_3                                                                                   baseos
kernel-modules-core.x86_64                                                                                                      5.14.0-362.18.1.el9_3                                                                                   baseos
kernel-modules-extra.x86_64                                                                                                     5.14.0-362.18.1.el9_3                                                                                   baseos
kernel-tools.x86_64                                                                                                             5.14.0-362.18.1.el9_3                                                                                   baseos
kernel-tools-libs.x86_64                                                                                                        5.14.0-362.18.1.el9_3                                                                                   baseos
kernel-tools-libs-devel.x86_64                                                                                                  5.14.0-362.18.1.el9_3                                                                                   crb
```

Перелічіть усі встановлені та доступні пакети з:

```bash
dnf list all
```

Це дасть вам надзвичайно довгий список файлів. Скільки файлів у Rocky Linux?

Використовуйте цю команду, щоб дізнатися:

```bash
dnf list all | wc -l
28297
```

Перелічує всі пакети, встановлені у вашій системі Rocky Linux:

```bash
sudo dnf list installed
```

Ви також можете фільтрувати за певним пакетом:

```bash
sudo dnf list installed "sudo*"
Installed Packages
sudo.x86_64                                                                                                               1.9.5p2-9.el9                                                                                                 baseos
```

Перелічіть усі доступні пакунки у всіх увімкнених репозиторіях за допомогою:

```bash
sudo dnf list available "perl"
Last metadata expiration check: 1:59:53 ago on Mon 05 Feb 2024 08:31:09 PM UTC.
Available Packages
perl.x86_64                                                                                                             4:5.32.1-480.el9                                                                                                appstream
```

Список усіх груп пакетів:

```bash
sudo dnf group list
Last metadata expiration check: 2:01:20 ago on Mon 05 Feb 2024 08:31:09 PM UTC.
Available Environment Groups:
   Server with GUI
   Server
   Minimal Install
   Workstation
   KDE Plasma Workspaces
   Custom Operating System
   Virtualization Host
Available Groups:
   Fedora Packager
   VideoLAN Client
   Xfce
   Legacy UNIX Compatibility
   Console Internet Tools
   Container Management
   Development Tools
   .NET Development
   Graphical Administration Tools
   Headless Management
   Network Servers
   RPM Development Tools
   Scientific Support
   Security Tools
   Smart Card Support
   System Tool
```

Перелічіть інформацію про сховище пакетів, які він надає для кожного активного сховища.

```bash
sudo dnf repolist 

repo id                                                                                                repo name
appstream                                                                                              Rocky Linux 9 - AppStream
baseos                                                                                                 Rocky Linux 9 - BaseOS
crb                                                                                                    Rocky Linux 9 - CRB
epel                                                                                                   Extra Packages for Enterprise Linux 9 - x86_64
epel-cisco-openh264                                                                                    Extra Packages for Enterprise Linux 9 openh264 (From Cisco) - x86_64
extras                                                                                                 Rocky Linux 9 - Extras
```

## Історія списку DNF

Ви можете переглянути історію списку DNF за допомогою цієї команди:

```bash
sudo dnf history list
ID     | Command line                                                            | Date and time    | Action(s)      | Altered
------------------------------------------------------------------------------------------------------------------------------
    23 | remove perl                                                             | 2024-02-05 22:30 | Removed        |  206   
    22 | install perl                                                            | 2024-02-05 22:05 | Install        |  206   
    21 | install sqlite                                                          | 2024-01-27 15:49 | I, U           |    2   
    20 | install tar gzip                                                        | 2024-01-27 14:27 | Install        |    1   
    19 | install htop                                                            | 2024-01-27 14:24 | Install        |    3   
    18 | install yarnpkg                                                         | 2024-01-27 14:21 | Install        |    1   
    17 | install nodejs mariadb-server npm                                       | 2024-01-27 14:14 | Install        |   81   
    16 | upgrade                                                                 | 2023-12-20 16:02 | Upgrade        |    2   
    15 | install wget                                                            | 2023-12-20 15:38 | Install        |    1   
    14 | remove iptables*                                                        | 2023-12-19 15:22 | Removed        |   10   
    13 | install iptables-utils                                                  | 2023-12-19 15:09 | Install        |    1   
    12 | install iptables-services                                               | 2023-12-19 15:08 | Install        |    1   
    11 | install iptables                                                        | 2023-12-19 15:02 | Install        |    8  <
    10 | remove firewalld                                                        | 2023-12-19 15:02 | Removed        |   20 >E
     9 | install firewalld                                                       | 2023-12-19 14:18 | Install        |   20 EE
     8 | install postfix s-nail                                                  | 2023-12-14 15:28 | Install        |    3   
     7 | upgrade                                                                 | 2023-11-30 14:30 | I, U           |  128 EE
     6 | install epel-release                                                    | 2023-11-30 14:30 | Install        |    8 EE
     5 | install which                                                           | 2023-01-24 14:31 | Install        |    1   
     4 | install zip                                                             | 2023-01-20 13:28 | Install        |    2   
     3 | -y --allowerasing install NetworkManager                                | 2023-01-19 02:47 | Install        |    7 EE
     2 | -y --allowerasing install cronie cronie-noanacron curl dhclient glibc-l | 2023-01-19 02:42 | Install        |   42 EE
     1 | --installroot=/rootfs -y --releasever=9 --skip-broken install basesyste | 2023-01-19 02:41 | Install        |  147 EE

```

Одним із найвигідніших аспектів історії DNF є можливість повертати (скасовувати) і повторювати (повторювати) транзакції.

```bash
dnf history undo id
```

```bash
dnf history redo id
```

```bash
sudo dnf history redo 20

Last metadata expiration check: 2:23:20 ago on Mon 05 Feb 2024 08:31:09 PM UTC.
Dependencies resolved.
Nothing to do.
Complete!
Warning, the following problems occurred while running a transaction:
  Package "tar.x86_64" is already installed for action "Install".
```

Команда `sudo dnf history redo 20` була використана для повторення команди з ID:20 зі списку історії DNF, і вона спробувала перевстановити `tar`. Природно, операція, яка відображається як «уже встановлено», оскільки вона була встановлена раніше.

### Пошук пакетів

Шукайте будь-який пакет, виконавши цю команду:

```bash
sudo dnf search wget 

Last metadata expiration check: 2:27:09 ago on Mon 05 Feb 2024 08:31:09 PM UTC.
================================================= Name Exactly Matched: wget =================================================
wget.x86_64 : A utility for retrieving files using the HTTP or FTP protocols
================================================ Name & Summary Matched: wget ================================================
perl-HTTP-Tinyish-Wget.noarch : HTTP::Tinyish wget backend
```

Шукайте більше ніж один пакет за один пошук, виконавши цю команду:

```bash
sudo dnf search all yum vim 
```

Команда поверне довгий список пакунків, які включають "yum" і "vim" як назву пакета або як описи для інших пакунків.

### Інформація про пакет DNF

Щоб відобразити інформацію про пакети, використовуйте цю команду:

```bash
sudo dnf info perl

Last metadata expiration check: 2:33:15 ago on Mon 05 Feb 2024 08:31:09 PM UTC.
Available Packages
Name         : perl
Epoch        : 4
Version      : 5.32.1
Release      : 480.el9
Architecture : x86_64
Size         : 13 k
Source       : perl-5.32.1-480.el9.src.rpm
Repository   : appstream
Summary      : Practical Extraction and Report Language
URL          : https://www.perl.org/
License      : GPL+ or Artistic
Description  : Perl is a high-level programming language with roots in C, sed, awk and shell
             : scripting. Perl is good at handling processes and files, and is especially
             : good at handling text. Perl's hallmarks are practicality and efficiency.
             : While it is used to do a lot of different things, Perl's most common
             : applications are system administration utilities and web programming.
             : 
             : This is a metapackage with all the Perl bits and core modules that can be
             : found in the upstream tarball from perl.org.
             : 
             : If you need only a specific feature, you can install a specific package
             : instead. E.g. to handle Perl scripts with /usr/bin/perl interpreter,
             : install perl-interpreter package. See perl-interpreter description for more
             : details on the Perl decomposition into packages.

```

Щоб відобразити інформацію про всі доступні пакунки, встановлені та доступні зі сховища, скористайтеся цією командою:

```bash
sudo dnf repoquery perl --info
```

Хоча це не завжди так, у наведеному вище випадку результати цієї команди ідентичні результатам команди `sudo dnf info perl`.

## Конфігурація сховища DNF

Файл конфігурації для DNF і пов’язаних із ним утиліт можна знайти за адресою `/etc/dnf/dnf.conf`.
У цьому файлі є обов’язковий розділ [main], який дозволяє конфігурувати параметри DNF із глобальними ефектами. Крім того, він може включати один або кілька розділів [репозиторій], надаючи можливість установлювати параметри для репозиторію.

Будь-які значення, указані в розділах [repository] файлу `/etc/dnf/dnf.conf`, передуватимуть значенням, встановленим у розділі [main].

```bash
cat /etc/dnf/dnf.conf

[main]
gpgcheck=1
installonly_limit=3
clean_requirements_on_remove=True
best=True
skip_if_unavailable=False
```

### Менеджер конфігурацій DNF

Щоб отримати вичерпний список параметрів конфігурації, їхні відповідні значення та інформацію про сховища, скористайтеся командою `dnf config-manager` з опцією `--dump`.

```bash
dnf config-manager --dump

sudo dnf config-manager --dump
============================================================ main ============================================================
[main]
allow_vendor_change = 1
assumeno = 0
assumeyes = 0
autocheck_running_kernel = 1
bandwidth = 0
best = 1
bugtracker_url = https://bugs.rockylinux.org/
cachedir = /var/cache/dnf
cacheonly = 0
check_config_file_age = 1
clean_requirements_on_remove = 1
color = auto
color_list_available_downgrade = magenta
color_list_available_install = bold,cyan
color_list_available_reinstall = bold,underline,green
color_list_available_upgrade = bold,blue
color_list_installed_extra = bold,red
color_list_installed_newer = bold,yellow
color_list_installed_older = yellow
color_list_installed_reinstall = cyan
color_search_match = bold,magenta
color_update_installed = red
color_update_local = green
color_update_remote = bold,green
config_file_path = /etc/dnf/dnf.conf
countme = 0
debug_solver = 0
debuglevel = 2
defaultyes = 0
deltarpm = 1
deltarpm_percentage = 75
disable_excludes = 
diskspacecheck = 1
enabled = 1
enablegroups = 1
errorlevel = 3
exclude = 
exclude_from_weak = 
exclude_from_weak_autodetect = 1
excludepkgs = 
exit_on_lock = 0
fastestmirror = 0
gpgcheck = 1
gpgkey_dns_verification = 0
group_package_types = mandatory, default, conditional
history_list_view = commands
history_record = 1
history_record_packages = dnf, rpm
ignorearch = 0
includepkgs = 
install_weak_deps = 1
installonly_limit = 3
installonlypkgs = kernel, kernel-PAE, installonlypkg(kernel), installonlypkg(kernel-module), installonlypkg(vm), multiversion(kernel)
installroot = /
ip_resolve = whatever
keepcache = 0
localpkg_gpgcheck = 0
log_compress = 0
log_rotate = 4
log_size = 1048576
logdir = /var/log
logfilelevel = 9
max_downloads_per_mirror = 3
max_parallel_downloads = 3
metadata_expire = 172800
metadata_timer_sync = 10800
minrate = 1000
module_obsoletes = 0
module_stream_switch = 0
multilib_policy = best
obsoletes = 1
password = 
persistdir = /var/lib/dnf
pluginconfpath = /etc/dnf/plugins
pluginpath = /usr/lib/python3.9/site-packages/dnf-plugins
plugins = 1
protect_running_kernel = 1
protected_packages = dnf, setup, systemd, systemd-udev, dnf, yum, sudo, setup, systemd, systemd-udev, dnf, yum, sudo
proxy = 
proxy_auth_method = any
proxy_sslcacert = 
proxy_sslclientcert = 
proxy_sslclientkey = 
proxy_sslverify = 1
recent = 7
repo_gpgcheck = 0
reposdir = /etc/yum.repos.d, /etc/yum/repos.d, /etc/distro.repos.d
reset_nice = 1
retries = 10
rpmverbosity = info
showdupesfromrepos = 0
skip_broken = 0
skip_if_unavailable = 0
sslcacert = 
sslclientcert = 
sslclientkey = 
sslverify = 1
sslverifystatus = 0
strict = 1
system_cachedir = /var/cache/dnf
throttle = 0
timeout = 30
transformdb = 1
tsflags = 
upgrade_group_objects_upgrade = 1
user_agent = libdnf (Rocky Linux 9.3; generic; Linux.x86_64)
username = 
varsdir = /etc/yum/vars, /etc/dnf/vars
zchunk = 1

```

## Висновок

Rocky Linux використовує DNF, наступне покоління заміни YUM. На цій сторінці показані приклади базового використання DNF. Для отримання додаткової інформації зверніться до [офіційної документації для DNF](https://dnf.readthedocs.io/en/latest/index.html)
