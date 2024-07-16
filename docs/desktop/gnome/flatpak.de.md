---
title: Flatpak
author: Steven Spencer
contributors: Ganna Zhyrnova
---

## Einleitung

Zitat aus der Webseite des Projekts:

> Flatpak ist ein Framework zur Verteilung von Desktop-Anwendungen auf verschiedene Linux-Distributionen. Es wurde von Entwicklern erstellt, die über langjährige Erfahrung in der Arbeit am Linux-Desktop verfügen, und wird als unabhängiges Open-Source-Projekt betrieben.

Flatpak wird standardmäßig installiert, wenn Rocky Linux mit einer Software-Auswahl installiert wird, die GNOME enthält („Server mit GUI“ oder „Workstation“). Eine manuelle Installation ist auch möglich (siehe beigefügtes Verfahren). Es ist eine hervorragende Möglichkeit, Ihre Desktop-Umgebung mit den Tools zu füllen, die Sie verwenden möchten.

## Manuelle Installation

!!! note "Anmerkung"

```
Sie können diesen Schritt überspringen, wenn Sie bereits die vollständige GNOME-Desktop-Umgebung ausführen, die in der Einführung beschrieben wurde.
```

Flatpak wie folgt installieren:

```bash
sudo dnf install flatpak
```

Fügen Sie das Flatpak-Repository hinzu:

```bash
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
```

System neu starten:

```bash
sudo shutdown -r now
```

## Flatpak-Kommandos

So zeigen Sie eine Liste aller verfügbaren Flatpak-Befehle an:

```bash
flatpak --help
```

Dies ergibt Folgendes:

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

Es ist nicht notwendig, sich die Liste der Befehle zu merken, es ist aber eine gute Idee, zu wissen, wie man zu der Liste gelangt und die Option `--help` zu verwenden ist.

!!! warning "Warnhinweis"

````
If you are on a version of Rocky Linux 9.x, you will experience this bug. When running the command:

```bash
flatpak search [packagename]
```

Where [packagename] is the package you are looking for, you will get:

```text
F: Failed to parse /var/lib/flatpak/appstream/flathub/x86_64/active/appstream.xml.gz file: Error on line 4065 char 29: <p> already set '
  Organic Maps is a free Android & iOS offline maps app for travelers,
  tourists, hikers, drivers, and cyclists.
  It uses crowd-sourced OpenStreetMap data and is developed with love by
  ' and tried to replace with ' ('
No matches found
```

There is no workaround for this. To avoid the error, use the Flathub resource in this document to obtain and install the desired package.
````

## Flathub

Flathub ist eine Webressource zum Abrufen oder Senden von Desktop-Paketen.

Besuchen Sie https://flathub.org/, um Flathub zu durchsuchen. Hier gibt es eine riesige Liste kuratierter Desktop-Pakete, die übersichtlich in Kategorien unterteilt sind.

## Verwendung von Flathub zusammen mit Flatpak

Der Installationsprozess für OBS Studio sieht beispielsweise wie folgt aus:

1. Abschnitt "Audio & Video" in `Flathub` öffnen

2. "OBS Studio" aus der Liste auswählen

3. Klicken Sie auf den Abwärtspfeil neben der Schaltfläche „Installieren“

   ![flathub\_install\_1](images/01_flatpak.png)

   ![flathub\_install\_2](images/02_flatpak.png)

4. Stellen Sie sicher, dass Sie alle Installationsvoraussetzungen für Rocky Linux erfüllt haben (Nummer 1 im zweiten Bild, das oben bereits abgeschlossen ist), kopieren Sie dann den Befehl (Nummer 2 im zweiten Bild) und fügen Sie ihn in ein Terminal ein

   ```bash
   flatpak install flathub com.obsproject.Studio
   Looking for matches…
   Required runtime for com.obsproject.Studio/x86_64/stable (runtime/org.kde.Platform/x86_64/6.6) found in remote flathub
   Do you want to install it? [Y/n]: Y
   ```

5. Wenn Sie mit „Y“ antworten und ++enter++ drücken, wird Folgendes angezeigt:

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

6. Wenn Sie mit „Y“ antworten und ++enter++ drücken, werden die Systemberechtigungen wie angegeben geändert und die Anwendung installiert.

7. Wenn alles gut geht, sollten Sie folgende Meldung erhalten:

   ```text
   Installation complete.
   ```

8. Im Menü „Aktivities“ können Sie nun nach OBS Studio suchen und es ausführen.

## Liste der Pakete

Um die auf Ihrem System vorhandenen Flatpak-Installationen anzuzeigen, öffnen Sie ein Terminal und verwenden Sie diesen Befehl:

```bash
flatpak list
```

daraufhin wird eine Ausgabe wie diese angezeigt:

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

## Update von Paketen

Um ein Paket auf die neueste Version zu aktualisieren, verwenden Sie die „Anwendungs-ID“ aus der Ausgabe von `flatpak-list`:

```bash
flatpak update com.obsproject.Studio
```

## Pakete Entfernen

Um ein Paket zu deinstallieren, verwenden Sie die „Anwendungs-ID“ aus der Ausgabe von `flatpak-list`:

```bash
flatpak uninstall com.obsproject.Studio
```

## Conclusion

Sie können Flathub und Flatpak verwenden, um Ihren GNOME-Desktop ganz einfach mit Anwendungen zu füllen, von Spielen bis hin zu Produktivitätstools.
