---
title: Flatpak
author: Steven Spencer
contributors: Ganna Zhyrnova
---

## 简介

来自项目官网:

> Flatpak是一个框架，用于跨平台支持各种Linux发行版分发桌面应用程序。 它是由在Linux桌面上有着悠久工作历史的开发人员创建的，并作为一个独立的开源项目运行。

Flatpak会在安装Rocky Linux系统时默认被安装，其中就包括GNOME(“带GUI的服务器”或“工作站”)。 也可以手动安装。 (请参考下面的手动安装过程) 这是一种当你想要使用工具自定义桌面环境的好方法。

## 手动安装

!!! note "注意"

```
如果你已经在运行完整的GNOME桌面环境，则可以跳过此步骤。
```

使用下面的命令安装 Flatpak:

```bash
sudo dnf install flatpak
```

添加 Flatpak 仓库

```bash
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
```

重启系统

```bash
sudo shutdown -r now
```

## Flatpak 命令

查看所有 Flatpak 可用命令:

```bash
flatpak --help
```

输出结果如下:

```text
Usage:
  flatpak [OPTION…] COMMAND

Builtin Commands:
 Manage installed applications and runtimes
  install                Install an application or runtime
  update                 Update an installed application or runtime
  uninstall              Uninstall an installed application or runtime
  mask                   Mask out updates and automatic installation
  pin                    Pin a runtime to prevent automatic removal
  list                   List installed apps and/or runtimes
  info                   Show info for installed app or runtime
  history                Show history
  config                 Configure flatpak
  repair                 Repair flatpak installation
  create-usb             Put applications or runtimes onto removable media

 Find applications and runtimes
  search                 Search for remote apps/runtimes

 Manage running applications
  run                    Run an application
  override               Override permissions for an application
  make-current           Specify default version to run
  enter                  Enter the namespace of a running application
  ps                     Enumerate running applications
  kill                   Stop a running application

 Manage file access
  documents              List exported files
  document-export        Grant an application access to a specific file
  document-unexport      Revoke access to a specific file
  document-info          Show information about a specific file

 Manage dynamic permissions
  permissions            List permissions
  permission-remove      Remove item from permission store
  permission-set         Set permissions
  permission-show        Show app permissions
  permission-reset       Reset app permissions

 Manage remote repositories
  remotes                List all configured remotes
  remote-add             Add a new remote repository (by URL)
  remote-modify          Modify properties of a configured remote
  remote-delete          Delete a configured remote
  remote-ls              List contents of a configured remote
  remote-info            Show information about a remote app or runtime

 Build applications
  build-init             Initialize a directory for building
  build                  Run a build command inside the build dir
  build-finish           Finish a build dir for export
  build-export           Export a build dir to a repository
  build-bundle           Create a bundle file from a ref in a local repository
  build-import-bundle    Import a bundle file
  build-sign             Sign an application or runtime
  build-update-repo      Update the summary file in a repository
  build-commit-from      Create new commit based on existing ref
  repo                   Show information about a repo

Help Options:
  -h, --help              Show help options

Application Options:
  --version               Print version information and exit
  --default-arch          Print default arch and exit
  --supported-arches      Print supported arches and exit
  --gl-drivers            Print active gl drivers and exit
  --installations         Print paths for system installations and exit
  --print-updated-env     Print the updated environment needed to run flatpaks
  --print-system-only     Only include the system installation with --print-updated-env
  -v, --verbose           Show debug information, -vv for more detail
  --ostree-verbose        Show OSTree debug information
```

没必要记住所有命令列表，知道如何进入列表并使用选项 `--help` 即可。

!!! warning "警告"

````
如果使用的是RockyLinux9.x版本，运行命令时可能遇到下面的问题：

```bash
flatpak search [packagename]
```
其中[packagename]是要查找的软件包，将返回：

```text
F: Failed to parse /var/lib/flatpak/appstream/flathub/x86_64/active/appstream.xml.gz file: Error on line 4065 char 29: <p> already set '
  Organic Maps is a free Android & iOS offline maps app for travelers,
  tourists, hikers, drivers, and cyclists.
  It uses crowd-sourced OpenStreetMap data and is developed with love by
  ' and tried to replace with ' ('
No matches found
```

对此没有解决方法。为了避免出现错误，请使用本文档中的Flathub资源获取并安装所需的软件包。
````

## Flathub

Flatchub是一个用于获取或提交桌面软件包的web资源网站。

要访问 Flathub, 查看 https://flathub.org/. 这里有非常多用心整理的桌面软件包，它们被很好地划分为不同的类别。

## Flathub 对接 Flatpak

比如, 安装 OBS Studio 的过程如下:

1. 在 Flathub 进入 "Audio & Video" 选项

2. 从列表中找到 "OBS Studio"

3. 单击“Install”安装按钮旁边的向下箭头

   ![flathub\_install\_1](images/01_flatpak.png)

   ![flathub\_install\_2](images/02_flatpak.png)

4. 确保已经安装了Rocky Linux需要的所有必备依赖(第二个图片中的数字1所指向的内容，上面已经完成)，然后复制命令(第二图片中的数字2所指向的内容) 并将其粘贴到终端中

   ```bash
   flatpak install flathub com.obsproject.Studio
   Looking for matches…
   Required runtime for com.obsproject.Studio/x86_64/stable (runtime/org.kde.Platform/x86_64/6.6) found in remote flathub
   Do you want to install it? [Y/n]: Y
   ```

5. 当你回答 "Y" 并点击 ++enter++ 键的时候, 你将看到类似下面的输出:

   ```bash
   com.obsproject.Studio permissions:
   ipc                             network         pulseaudio              wayland
   x11                             devices         file access [1]         dbus access [2]
   system dbus access [3]

   [1] host, xdg-config/kdeglobals:ro, xdg-run/pipewire-0
   [2] com.canonical.AppMenu.Registrar, org.a11y.Bus, org.freedesktop.Flatpak, org.freedesktop.Notifications,
       org.kde.KGlobalSettings, org.kde.StatusNotifierWatcher, org.kde.kconfig.notify
   [3] org.freedesktop.Avahi

       ID                                                    Branch         Op         Remote          Download
   1.     com.obsproject.Studio.Locale                          stable         i          flathub          < 47.0 kB (partial)
   2.     org.kde.KStyle.Adwaita                                6.6            i          flathub           < 8.0 MB
   3.     org.kde.Platform.Locale                               6.6            i          flathub         < 380.6 MB (partial)
   4.     org.kde.PlatformTheme.QGnomePlatform                  6.6            i          flathub           < 9.7 MB
   5.     org.kde.WaylandDecoration.QAdwaitaDecorations         6.6            i          flathub           < 1.2 MB
   6.     org.kde.Platform                                      6.6            i          flathub         < 325.0 MB
   7.     com.obsproject.Studio                                 stable         i          flathub         < 207.7 MB

   Proceed with these changes to the system installation? [Y/n]:
   ```

6. 回答 "Y" 并点击 ++enter++ 键将按提示修改系统权限并安装应用.

7. 如果安装顺利, 你将看到:

   ```text
   Installation complete.
   ```

8. 在 "Activities" 菜单, 可以搜索并运行 OBS Studio.

## 列出安装包

要想查看 Flatpak 在你系统上的安装包, 打开终端并执行如下命令:

```bash
flatpak list
```

输出结果类似下面这种:

```text
Name                                    Application ID                                  Version   Branch       Installation
OBS Project                             com.obsproject.Studio                           30.1.2    stable       system
FileZilla                               org.filezillaproject.Filezilla                  3.66.1    stable       system
Freedesktop Platform                    org.freedesktop.Platform                        22.08.24  22.08        system
Freedesktop Platform                    org.freedesktop.Platform                        23.08.16  23.08        system
Mesa                                    org.freedesktop.Platform.GL.default             24.0.4    22.08        system
Mesa (Extra)                            org.freedesktop.Platform.GL.default             24.0.4    22.08-extra  system
Mesa                                    org.freedesktop.Platform.GL.default             24.0.5    23.08        system
Mesa (Extra)                            org.freedesktop.Platform.GL.default             24.0.5    23.08-extra  system
Intel                                   org.freedesktop.Platform.VAAPI.Intel                      22.08        system
Intel                                   org.freedesktop.Platform.VAAPI.Intel                      23.08        system
openh264                                org.freedesktop.Platform.openh264               2.1.0     2.2.0        system
openh264                                org.freedesktop.Platform.openh264               2.4.1     2.4.1        system
The GIMP team                           org.gimp.GIMP                                   2.10.36   stable       system
GNOME Application Platform version 46   org.gnome.Platform                                        46           system
Adwaita theme                           org.kde.KStyle.Adwaita                                    6.6          system
KDE Application Platform                org.kde.Platform                                          6.6          system
QGnomePlatform                          org.kde.PlatformTheme.QGnomePlatform                      6.6          system
QAdwaitaDecorations                     org.kde.WaylandDecoration.QAdwaitaDecorations             6.6          system
```

## 更新软件包

要想将某个包更新到最新版本, 需要用到 `flatpak list` 命令中输出的 "Application ID" 那一列对应包的值:

```bash
flatpak update com.obsproject.Studio
```

## 删除软件包

要想将某个包卸载, 也需要用到 flatpak list 命令中输出的 "Application ID" 那一列对应包的值:

```bash
flatpak uninstall com.obsproject.Studio
```

## 总结

你可以使用Flathaub和Flatpak轻松地开发GNOME桌面相关的应用程序, 从游戏到生产力工具都可以。
