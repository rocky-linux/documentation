---
title: Entorno de escritorio MATE
author: lillollo
contributors: Steven Spencer
tested with: 8.5
tags:
  - mate
  - escritorio
---

# Entorno de escritorio MATE

El entorno de escritorio MATE fue creado como una bifurcación para continuar GNOME2 después de las críticas negativas que recibió GNOME3 tras su presentación. MATE tiene un conjunto leal de seguidores, que lo instalan inmediatamente en su sistema operativo favorito. MATE se puede instalar en muchos de los diferentes sabores de Linux, incluyendo Rocky Linux.

Este procedimiento está diseñado para que usted pueda trabajar con Rocky Linux utilizando MATE.

!!! Warning

    MATE no proviene de los repositorios de Rocky Linux. No está soportado oficialmente por Rocky Linux. Para la gran mayoría de los usuarios, este procedimiento funcionará tal y como se espera, si tiene problemas, por favor recuerde que los desarrolladores de Rocky Linux y el equipo de pruebas NO trabajarán en ningún error o problema.  Sile gusta MATE y lo quiere con todas tus fuerzas, entonces solucione los problemas encontrados y arregle lo que sea necesario. Si encuentra algo que cree que debería incluirse en este procedimiento para ayudar a otros usuarios, suba un cambio a este documento.

## Requisitos previos

* Un ordenador con una pantalla y el resto de periféricos necesarios, preferiblemente con Rocky Linux ya instalado.

## Instalar Rocky Linux Minimal

Al instalar Rocky Linux, utilizamos los siguientes conjuntos de paquetes:

* Minimal
* Standard

## Habilitar los repositorios

Necesitamos el repositorio no oficial para MATE. Puede encontrar más información sobre ese repositorio aquí: [Stenstorp/MATE](https://copr.fedorainfracloud.org/coprs/stenstorp/MATE/)

Active este repositorio tecleando el siguiente comando:

`dnf copr enable stenstorp/MATE`

!!! Warning

    El sistema de construcción `copr` crea un repositorio que funciona para instalar `mate` y `lightdm`, recuerde que estos repositorios no son mantenidos por la comunidad Rocky Linux. ¡Utilícelos bajo su cuenta y riesgo!

Se mostrará un mensaje de advertencia acerca del repositorio, pero puede continuar adelante y activarlo presionando la tecla `Y` para permitir su activación.

Tal y como se indica en el enlace anterior, también necesita los repositorios Powertools y EPEL. Continue y activelos mediante el comando:

`sudo dnf config-manager --set-enabled powertools`

`sudo dnf install epel-release`

Y responda 'Y' para instalar EPEL.

También necesitamos habilitar el repositorio de Stenstorp Lightdm, así que procedemos a habilitarlo. Puede encontrar más información sobre este repositorio haciendo clic en el siguiente enlace: [Stenstorp/Lighdm](https://copr.fedorainfracloud.org/coprs/stenstorp/lightdm/)

Para habilitar ese repositorio, escriba el siguiente comando:

`sudo dnf copr enable stenstorp/lightdm`

De nuevo, se le mostrará un mensaje de advertencia sobre el repositorio. Puede continuar y responder `Y` a la petición.

Continue y ejecute el comando `dnf update` para asegurarse de que todos los repositorios habilitados se pueden leer en el sistema.

## Instalar paquetes

Lo siguiente que necesitamos son muchos paquetes. Puede instalarlos copiando y pegando el siguiente texto en la línea de comandos de su máquina:

`sudo dnf install NetworkManager-adsl NetworkManager-bluetooth NetworkManager-libreswan-gnome NetworkManager-openvpn-gnome NetworkManager-ovs NetworkManager-ppp NetworkManager-team NetworkManager-wifi NetworkManager-wwan abrt-desktop abrt-java-connector adwaita-gtk2-theme alsa-plugins-pulseaudio atril atril-caja atril-thumbnailer caja caja-actions caja-image-converter caja-open-terminal caja-sendto caja-wallpaper caja-xattr-tags dconf-editor engrampa eom firewall-config gnome-disk-utility gnome-epub-thumbnailer gstreamer1-plugins-ugly-free gtk2-engines gucharmap gvfs-afc gvfs-afp gvfs-archive gvfs-fuse gvfs-gphoto2 gvfs-mtp gvfs-smb initial-setup-gui libmatekbd libmatemixer libmateweather libsecret lm_sensors marco mate-applets mate-backgrounds mate-calc mate-control-center mate-desktop mate-dictionary mate-disk-usage-analyzer mate-icon-theme mate-media mate-menus mate-menus-preferences-category-menu mate-notification-daemon mate-panel mate-polkit mate-power-manager mate-screensaver mate-screenshot mate-search-tool mate-session-manager mate-settings-daemon mate-system-log mate-system-monitor mate-terminal mate-themes mate-user-admin mate-user-guide mozo network-manager-applet nm-connection-editor p7zip p7zip-plugins pluma seahorse seahorse-caja xdg-user-dirs-gtk brisk-menu`

Esto instalará los paquetes necesarios además de todas las dependencias requeridas.

Seguimos adelante y procedemos a instalar también el paquete lightdm-gtk:

`sudo dnf install lightdm-gtk`

## Últimos pasos

Ahora que tenemos todo lo que necesitamos instalado, lo siguiente que necesitamos hacer es establecer la instalación mínima para poder ejecutar la interfaz de usuario gráfica (GUI). Podemos hacer esto tecleando el siguiente comando:

`sudo systemctl set-default graphical.target`

Ahora cruce los dedos cruzados y reinicie:

`sudo reboot`

A continuación, haga clic en la pantalla sobre su nombre de usuario, pero antes de introducir su contraseña e iniciar la sesión, haga clic sobre el icono con forma de engranaje situado a la izquierda de la opción "Iniciar sesión". Seleccione "MATE" entre las opciones de escritorio disponibles y luego introduzca su contraseña e inicie sesión. Los siguientes inicios de sesión recordarán la elección realizada.

## Conclusión

Algunas personas no están satisfechas con las nuevas implementaciones de GNOME o simplemente prefieren el aspecto antiguo de GNOME 2. Para esas personas, instalar MATE en Rocky Linux proporcionará una alternativa agradable y estable.

!!! attention

    Después de más pruebas, la selección de escritorio **NOT** permanece, aunque MATE permanezca seleccionado. Los intentos de inicio de sesión producen un retorno a la pantalla de inicio de sesión. Para iniciar sesión en MATE, debe seleccionar MATE de nuevo, aunque ya se mostrará como seleccionado. Por eso la advertencia está al principio de este procedimiento. Por favor, utilice esta guía bajo su propio riesgo. Si descubre una solución que pueda ayudar a otros usuarios a seguir utilizando MATE con Rocky Linux, por favor de a conocer dicha solución.
