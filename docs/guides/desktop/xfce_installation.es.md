- - -
title: Entorno de escritorio XFCE autor: Gerard Arthus colaboradores: Steven Spencer, Antoine Le Morvan, K.Prasad, Pedro Garcia etiquetas:
  - xfce
  - desktop
- - -

# Entorno de escritorio XFCE

El entorno de escritorio XFCE fue creado como una bifurcación de Common Desktop Environment (CDE). Xfce encarna la filosofía tradicional de Unix en relación a la modularidad y usabilidad. XFCE se puede instalar en casi cualquier versión de Linux, incluyendo Rocky Linux.

Este procedimiento está diseñado para que pueda trabajar con Rocky Linux utilizando XFCE.

## Requisitos previos

* Una estación de trabajo o un servidor, preferiblemente con Rocky Linux ya instalado.
* Debe utilizar el usuario root o escribir `sudo` delante de todos los comandos que introduzca en el terminal.

## Instalar Rocky Linux Minimal

Al instalar Rocky Linux, utilizamos los siguientes conjuntos de paquetes:

* Minimal
* Standard

## Actualización del sistema

Primero, ejecute el comando de actualización del servidor para permitir que el sistema reconstruya la caché de los repositorios, de forma que pueda reconocer los paquetes que hay disponibles. Para ello teclee el comando que se muestra a continuación:

`dnf update`

## Habilitar los repositorios

Necesitamos el repositorio no oficial para XFCE en el EPEL, para ejecutarlo en las versiones 8.x. de Rocky Linux.

Active este repositorio tecleando el siguiente comando:

`dnf install epel-release`

Y responda 'Y' para instalar EPEL.

También necesitará los repositorios Powertools y lightdm. Continue y activelos mediante el comando:

`sudo dnf config-manager --set-enabled powertools`

`sudo dnf copr enable stenstorp/lightdm`

!!! Warning

    El sistema de construcción `copr` crea un repositorio que funciona para instalar `lightdm`, recuerde que estos repositorios no son mantenidos por la comunidad Rocky Linux. ¡Utilícelos bajo su cuenta y riesgo!

De nuevo, se le mostrará un mensaje de advertencia sobre el repositorio. Puede continuar y responder `Y` a la petición.

## Compruebe los entornos y herramientas disponibles en el grupo

Ahora que los repositorios están habilitados, ejecute los siguientes comandos para comprobar todo.

Primero, compruebe el listado de sus repositorios, para ello ejecute el siguiente comando:

`dnf repolist`

Debería poder ver la siguiente información que muestra todos los repositorios habilitados en el sistema:

```
appstream                                                        Rocky Linux 8 - AppStream
baseos                                                           Rocky Linux 8 - BaseOS
copr:copr.fedorainfracloud.org:stenstorp:lightdm                 Copr repo for lightdm owned by stenstorp
epel                                                             Extra Packages for Enterprise Linux 8 - x86_64
epel-modular                                                     Extra Packages for Enterprise Linux Modular 8 - x86_64
extras                                                           Rocky Linux 8 - Extras
powertools                                                       Rocky Linux 8 - PowerTools
```

Ejecute el siguiente comando para comprobar XFCE:

`dnf grouplist`

Debería ver "Xfce" en la parte inferior de la lista.

Continue y ejecute el comando `dnf update` una vez más para asegurarse de que todos los repositorios habilitados se pueden leer en el sistema.

## Instalar paquetes

Para instalar XFCE, ejecute:

`dnf groupinstall "xfce"`

Instale también lightdm:

`dnf install lightdm`

## Últimos pasos

Necesitamos desactivar `gdm`, el cúal se añade y activa durante la ejecución de *dnf groupinstall "xfce"*:

`systemctl disable gdm`

Ahora podemos habilitar *lightdm*:

`systemctl enable lightdm`

Necesitamos indicarle al sistema después de arrancar que utilice solo la interfaz gráfica de usuario, así que para que se establezca como predeterminado a la interfaz GUI, ejecutamos el siguiente comando:

`systemctl set-default graphical.target`

Después, reiniciamos el sistema:

`reboot`

Debería terminar con un aviso de inicio de sesión en la GUI de XFCE, y cuando inicie sesión, tendrá todo el entorno de XFCE.

## Conclusión

XFCE es un entorno ligero con una interfaz sencilla para aquellos a los que no les gustan los entornos con muchos adornos y que estén demasiado sobrecargados. Este tutorial se actualizará con muy pronto con imágenes, incluyendo capturas de pantalla para dar un ejemplo más visual del proceso de instalación.
