---
title: Rootkit Hunter
author: Steven Spencer
contributors: Ezequiel Bruni, Pedro Garcia
tested with: 8.7, 9.1
tags:
  - servidor
  - seguridad
  - rkhunter
---

# Rootkit Hunter

## Requisitos previos

* Dominio de un editor de línea de comandos (en este ejemplo utilizamos _vi_)
* Un alto nivel de comodidad en la ejecución de comandos desde el terminal, la visualización de registros y otras tareas de caracter genérico dentro de la administración de sistemas
* Es útil comprender qué puede desencadenar una respuesta a los archivos modificados en el sistema de archivos (como las actualizaciones de paquetes)
* Todos los comandos se ejecutan como el usuario root o sudo

Este documento fue escrito originalmente junto con las rutinas de securización del servidor web Apache, pero funciona igual de bien en un servidor que ejecuta cualquier otro software.

## Introduction

_rkhunter_ (Root Kit Hunter) es una herramienta basada en Unix que explora rootkits, puertas traseras y posibles exploits locales. Es una pieza importante de un servidor web securizado, y está diseñado para notificar rápidamente al administrador del sistema cuando algo sospechoso ocurre en el sistema de archivos del servidor.

_rkhunter_ es solo un posible componente de una configuración securizada del servidor web Apache y puede utilizarse en conjunto con otras herramientas. Si quiere utilizarlo junto con otras herramientas de securización, consulte la [guía de securización del servidor web Apache](index.md).

Este documento también utiliza todos los supuestos y convenciones descritos en ese documento original, por lo que es una buena idea revisarlo antes de continuar.

## Pasos generales

1. Instalar rkhunter
2. Configurar rkhunter.
3. Configurar el servidor de correo electrónico y asegurarse de que está configurado para funcionar correctamente.
4. Ejecute `rkhunter` manualmente para generar una lista de advertencias para probar sus ajustes de correo electrónico (`rkhunter --check`).
5. Ejecute `rkhunter --propupd` para generar un archivo `rkhunter.dat`limpio que `rkhunter` utilizará desde este punto hacia adelante como línea base para más comprobaciones.

## Instalar rkhunter

_rkhunter_ requiere el repositorio EPEL (Extra Packages for Enterprise Linux). Así que instale ese repositorio si no lo tiene instalado ya:

```
dnf install epel-release
```

Luego instale _rkhunter_:

```
dnf install rkhunter
```

## Configurar rkhunter

Las únicas opciones de configuración que se deben establecer son las que están relacionadas con el envio de los informes por correo al administrador del sistema. Para modificar el archivo de configuración, ejecute:

```
vi /rkhunter.conf`
```

Y luego busque:

```
#MAIL-ON-WARNING=me@mydomain root@mydomain
```

Elimine el comentario y cambie `me@mydomain.com` para reflejar su dirección de correo electrónico.

Luego cambie el `root@mydomain` a `root@nombre_de_servidor`.

Probablemente también querrá eliminar la observación (y editar la línea para adaptarla a sus necesidades) de la línea `MAIL-CMD`, que se encuentra unas líneas más abajo y que tiene este aspecto:

```
MAIL_CMD=mail -s "[rkhunter] Warnings found for ${HOST_NAME}"
```

Puede que también necesite configurar [Postfix](../../email/postfix_reporting.md) para que la sección de correo electrónico funcione correctamente.

## Ejecutar rkhunter

_rkhunter_ puede ejecutarse tecleándolo en la línea de comandos. Hay una tarea de cron instalada en `/etc/cron.daily` pero si desea automatizar el procedimiento en un horario diferente, mire la guía [Automatización de trabajos de Cron](../../automation/cron_jobs_howto.md).

También tendrá que mover el script a otra ubicación que no sea `/etc/cron.daily`, por ejemplo `/usr/local/sbin` y luego llámelo desde su ejecución de Cron. El método más fácil, por supuesto, es dejar intacto el `cron.daily` por defecto.

Si quiere probar `rkhunter` antes de empezar, incluyendo todas las funciones de correo electrónico, etc., ejecute `rkhunter --check` desde la línea de comandos. Si hay problemas con la configuración del correo electrónico, espere y complete el resto para que pueda ejecutar este comando de nuevo. Una vez que haya confirmado que el correo electrónico funciona, pero antes de permitir que `rkhunter` se ejecute automáticamente, vuelva a ejecutar el comando manualmente con el indicador "--propupd" para crear el archivo `rkhunter.dat` y asegurese de que su nuevo entorno se reconoce sin problemas:

```
rkhunter --propupd
```

## Conclusión

_rkhunter_ es parte de una estrategia de securización de servidores que puede ayudarle a monitorizar el sistema de archivos y reportar cualquier problema al administrador del sistema. Tal vez sea una de las herramientas de securización más fáciles de instalar, configurar y ejecutar.
