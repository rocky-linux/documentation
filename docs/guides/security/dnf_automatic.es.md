---
title: Parcheo con dnf-automatic
author: Antoine Le Morvan
contributors: Steven Spencer, Pedro Garcia
tested with: 8.5
tags:
  - seguridad
  - dnf
  - automatización
  - actualizaciones
---

# Parchear servidores con `dnf-automatic`

La gestión de la instalación de actualizaciones de seguridad es un tema importante para el administrador del sistema. El proceso de proporcionar actualizaciones de software es un camino bien transitado que, en última instancia, causa pocos problemas. Por ese motivo, es razonable automatizar la descarga y aplicación de actualizaciones diarias y automáticas en los servidores que ejecuten Rocky Linux.

La seguridad de su sistema de información se verá reforzada. `dnf-automatic` es una herramienta adicional que le permitirá lograrlo.

!!! hint "Si estás preocupado..."

    Hace años, aplicar actualizaciones automáticamente como esta habría sido una receta para el desastre. En muchas ocasiones, una actualización aplicada podría provocar problemas. Esto sigue ocurriendo en raras ocasiones, cuando una actualización de un paquete elimina una característica obsoleta que se utiliza en el servidor, pero en su mayor parte, esto es raro que suceda. Dicho esto, si aún se siente incómodo dejando que la herramienta `dnf-automatic` maneje sus actualizaciones, considere utilizarlo para descargar y/o notificar que hay actualizaciones disponibles. De esa manera su servidor no permanecerá sin actualizar durante mucho tiempo. Estas características son `dnf-automatic-notifyonly` y `dnf-automatic-download`
    
    Para más información sobre estas características, eche un vistazo a la [documentación oficial](https://dnf.readthedocs.io/en/latest/automatic.html).

## Instalación

Puede instalar `dnf-automatic` desde los repositorios de Rocky Linux:

```
sudo dnf install dnf-automatic
```

## Configuración

De forma predeterminada, el proceso de actualización comenzará a las 6am, con un delta de tiempo aleatorio extra para evitar que todas sus máquinas se actualicen al mismo tiempo. Para cambiar este comportamiento, debe sobreescribir la configuración del temporizador asociada con el servicio de la aplicación:

```
sudo systemctl edit dnf-automatic.timer

[Unit]
Description=dnf-automatic timer
# Ver comentario en dnf-makecache.service
ConditionPathExists=!/run/ostree-booted
Wants=network-online. Apuntar

[Timer]
OnCalendar=*-*-* 6:00
RandomizedDelaySec=10m
Persistent=true

[Install]
WantedBy=timers.target
```

Esta configuración reduce el retraso en el inicio entre las 6:00 y las 6:10 am. (Un servidor que se apague en este momento sería parcheado automáticamente después de su reinicio.)

Luego active el temporizador asociado al servicio (no el servicio en sí):

```
$ sudo systemctl enable --now dnf-automatic.timer
```

## ¿Qué pasa con los servidores CentOS 7?

!!! tip

    Sí, esta es la documentación de Rocky Linux, pero si usted es un administrador de sistemas o red, puede que disponga de algunas máquinas ejecutando CentOS 7. Lo entendemos, y por eso incluimos esta sección en la documentación.

El proceso bajo CentOS 7 es similar pero utiliza la herramienta: `yum-cron`.

```
$ sudo yum install yum-cron
```

Esta vez la configuración del servicio se realiza en el archivo `/etc/yum/yum-cron.conf`.

Establezca la configuración según sea necesario:

```
[commands]
#  What kind of update to use:
# default                            = yum upgrade
# security                           = yum --security upgrade
# security-severity:Critical         = yum --sec-severity=Critical upgrade
# minimal                            = yum --bugfix update-minimal
# minimal-security                   = yum --security update-minimal
# minimal-security-severity:Critical =  --sec-severity=Critical update-minimal
update_cmd = default

# Whether a message should be emitted when updates are available,
# were downloaded, or applied.
update_messages = yes

# Whether updates should be downloaded when they are available.
download_updates = yes

# Whether updates should be applied when they are available.  Note
# that download_updates must also be yes for the update to be applied.
apply_updates = yes

# Maximum amout of time to randomly sleep, in minutes.  The program
# will sleep for a random amount of time between 0 and random_sleep
# minutes before running.  This is useful for e.g. staggering the
# times that multiple systems will access update servers.  If
# random_sleep is 0 or negative, the program will run immediately.
# 6*60 = 360
random_sleep = 30
```

Los comentarios en el archivo de configuración hablan por sí mismos.

Ahora puede activar el servicio e iniciarlo:

```
$ sudo systemctl enable --now yum-cron
```

## Conclusión

La actualización automática de los paquetes se activa fácilmente y aumenta considerablemente la seguridad de su sistema de información.
