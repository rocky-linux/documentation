---
title: Entorno de escritorio MATE
author: lillollo
contributors: Steven Spencer, Pedro Garcia
tested with: 8.5, 8.6
tags:
  - mate
  - escritorio
---

# Entorno de escritorio MATE

El entorno de escritorio MATE fue creado como una bifurcación para continuar GNOME2 después de las críticas negativas que recibió GNOME3 tras su presentación. MATE tiene un conjunto leal de seguidores, que lo instalan inmediatamente en su sistema operativo favorito. MATE se puede instalar en muchos de los diferentes sabores de Linux, incluyendo Rocky Linux.

Este procedimiento está diseñado para que usted pueda trabajar con Rocky Linux utilizando MATE.

## Requisitos previos

* Un ordenador con una pantalla y el resto de periféricos necesarios, preferiblemente con Rocky Linux ya instalado.

## Instalar Rocky Linux Minimal

Al instalar Rocky Linux, utilizamos los siguientes conjuntos de paquetes:

* Minimal
* Standard

## Habilitar los repositorios

Necesita los repositorio Powertools y EPEL. Continue y activelos mediante el comando:

`sudo dnf config-manager --set-enabled powertools`

`sudo dnf install epel-release`

Y responda 'Y' para instalar EPEL.

Continue y ejecute el comando `dnf update` para asegurarse de que todos los repositorios habilitados se pueden leer en el sistema.

## Instalar paquetes

Lo siguiente que necesitamos son muchos paquetes. Puede instalarlos copiando y pegando el siguiente texto en la línea de comandos de su máquina:

`sudo dnf install NetworkManager-adsl NetworkManager-bluetooth NetworkManager-libreswan-gnome NetworkManager-openvpn-gnome NetworkManager-ovs NetworkManager-ppp NetworkManager-team NetworkManager-wifi NetworkManager-wwan abrt-desktop abrt-java-connector adwaita-gtk2-theme alsa-plugins-pulseaudio atril atril-caja atril-thumbnailer caja caja-actions caja-image-converter caja-open-terminal caja-sendto caja-wallpaper caja-xattr-tags dconf-editor engrampa eom firewall-config gnome-disk-utility gnome-epub-thumbnailer gstreamer1-plugins-ugly-free gtk2-engines gucharmap gvfs-afc gvfs-afp gvfs-archive gvfs-fuse gvfs-gphoto2 gvfs-mtp gvfs-smb initial-setup-gui libmatekbd libmatemixer libmateweather libsecret lm_sensors marco mate-applets mate-backgrounds mate-calc mate-control-center mate-desktop mate-dictionary mate-disk-usage-analyzer mate-icon-theme mate-media mate-menus mate-menus-preferences-category-menu mate-notification-daemon mate-panel mate-polkit mate-power-manager mate-screensaver mate-screenshot mate-search-tool mate-session-manager mate-settings-daemon mate-system-log mate-system-monitor mate-terminal mate-themes mate-user-admin mate-user-guide mozo network-manager-applet nm-connection-editor p7zip p7zip-plugins pluma seahorse seahorse-caja xdg-user-dirs-gtk`

Esto instalará los paquetes necesarios además de todas las dependencias requeridas.

Vamos a instalar lightdm-settings y lightdm también:

`sudo dnf install lightdm-settings lightdm`

## Últimos pasos

Ahora que tenemos todo lo que necesitamos instalado, lo siguiente que necesitamos hacer es establecer la instalación mínima para poder ejecutar la interfaz de usuario gráfica (GUI). Podemos hacer esto tecleando el siguiente comando:

`sudo systemctl set-default graphical.target`

Ahora cruce los dedos cruzados y reinicie:

`sudo reboot`

A continuación, haga clic en la pantalla sobre su nombre de usuario, pero antes de introducir su contraseña e iniciar la sesión, haga clic sobre el icono con forma de engranaje situado a la izquierda de la opción "Iniciar sesión". Seleccione "MATE" entre las opciones de escritorio disponibles y luego introduzca su contraseña e inicie sesión. Los siguientes inicios de sesión recordarán la elección realizada.

## Conclusión

Algunas personas no están satisfechas con las nuevas implementaciones de GNOME o simplemente prefieren el antiguo aspecto de GNOME 2. Para esas personas, instalar MATE en Rocky Linux les proporcionará una agradable y estable alternativa.
