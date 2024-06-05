---
title: Flatpak
author: Steven Spencer
contributors: Ganna Zhyrnova
---

## Introduction

Depuis le site Web du projet :

> Flatpak est un framework permettant de distribuer des applications de bureau sur diverses distributions Linux. Il a été créé par des développeurs qui ont une longue expérience sur Linux-Desktop et est exécuté comme un projet open source indépendant.

Flatpak est installé par défaut lors de l'installation de Rocky Linux avec des sélections de logiciels incluant GNOME (« Serveur avec interface graphique » ou « Poste de travail »). Une installation manuelle est également possible. (voir procédure incluse) C'est un excellent moyen de remplir votre environnement de bureau avec les outils que vous souhaitez utiliser.

## Installation Manuelle

!!! note

```
Vous pouvez ignorer cette étape si vous exécutez déjà l'environnement de bureau GNOME complet décrit dans l'introduction.
```

Installer Flatpak comme suit :

```bash
sudo dnf install flatpak
```

Ajouter le dépôt Flatpak :

```bash
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
```

Redémarrez le système :

```bash
sudo shutdown -r now
```

## Les commandes de Flatpak

Pour afficher une liste de toutes les commandes Flatpak disponibles :

```bash
flatpak --help
```

Cela devrait afficher le résultat suivant :

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

Mémoriser la liste des commandes n'est pas nécessaire, mais savoir comment y accéder et utiliser l'option `--help` est une bonne idée.

!!! warning "Avertissement"

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

`Flathub` est une ressource Web permettant d'obtenir ou de soumettre des packages de bureau.

Pour parcourir `Flathub`, veuillez visiter https://flathub.org/. Une énorme liste de packages de bureau sélectionnés existe ici, joliment divisés en catégories.

## Intégration de Flathub avec Flatpak

À titre d'exemple, le processus d'installation d'OBS Studio est le suivant :

1. Ouvrez la section "Audio & Vidéo" sur Flathub

2. Sélectionnez « OBS Studio » dans la liste

3. Cliquez sur la flèche vers le bas à côté du bouton « Install »

   ![flathub\_install\_1](images/01_flatpak.png)

   ![flathub\_install\_2](images/02_flatpak.png)

4. Assurez-vous d'avoir rempli toutes les conditions préalables à l'installation de Rocky Linux (numéro 1 dans la deuxième image, qui est déjà complété ci-dessus), puis copiez la commande (numéro 2 dans la deuxième image) et collez-la dans un terminal

   ```bash
   flatpak install flathub com.obsproject.Studio
   Looking for matches…
   Required runtime for com.obsproject.Studio/x86_64/stable (runtime/org.kde.Platform/x86_64/6.6) found in remote flathub
   Do you want to install it? [Y/n]: Y
   ```

5. Lorsque vous répondez « Y » et appuyez sur ++enter++, vous verrez ce qui suit :

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

6. Répondre « Y » et appuyer sur ++enter++ modifiera les autorisations du système comme indiqué et installera l'application.

7. Si tout se passe bien, vous devriez obtenir le message suivant :

   ```text
   Installation complete.
   ```

8. Depuis le menu « Activités », vous pouvez désormais rechercher et exécuter OBS Studio.

## Liste des Paquets

Pour voir les installations Flatpak dont vous disposez sur votre système, ouvrez un terminal et utilisez cette commande :

```bash
flatpak list
```

qui vous montrera un résultat tel que celui-ci :

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

## Mise à Jour des Paquets

Pour mettre à jour un package vers la dernière version, utilisez « l'ID d'application » de la sortie « flatpak list » :

```bash
flatpak update com.obsproject.Studio
```

## Suppression de paquets

Pour désinstaller un package, utilisez l'« ID d'application » de la sortie « flatpak list » :

```bash
flatpak uninstall com.obsproject.Studio
```

## Conclusion

Vous pouvez utiliser Flathub et Flatpak pour remplir facilement votre bureau GNOME avec des applications, des jeux aux outils de productivité.
