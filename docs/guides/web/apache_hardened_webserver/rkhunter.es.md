---
title: Rootkit Hunter
author: Steven Spencer
contributors: Ezequiel Bruni
tested with: 8.5
tags:
  - servidor
  - seguridad
  - rkhunter
---

# Rootkit Hunter

## Requisitos previos

* Un servidor web con Rocky Linux que ejecute Apache
* Dominio de un editor de línea de comandos (en este ejemplo utilizamos _vi_)
* Un alto nivel de comodidad en la ejecución de comandos desde el terminal, la visualización de registros y otras tareas de caracter genérico dentro de la administración de sistemas
* Es útil comprender qué puede desencadenar una respuesta a los archivos modificados en el sistema de archivos (como las actualizaciones de paquetes)
* Todos los comandos se ejecutan como el usuario root o sudo

## Introduction

_rkhunter_ (Root Kit Hunter) es una herramienta basada en Unix que explora rootkits, puertas traseras y posibles exploits locales. Es unapieza importante de un servidor web securizado, y está diseñado para notificar rápidamente al administrador del sistema cuando algo sospechoso ocurre en el sistema de archivos del servidor.

_rkhunter_ es solo un posible componente de una configuración securizada del servidor web Apache y puede utilizarse en conjunto con otras herramientas. Si quiere utilizarlo junto con otras herramientas para securizarlo, consultr la [guía del servidor web Apache securizado](index.md).

Este documento también utiliza todos los supuestos y convenciones descritos en ese documento original, por lo que es una buena idea revisarla antes de continuar.

## Instalar rkhunter

_rkhunter_ requiere el repositorio EPEL (Extra Packages for Enterprise Linux). Así que instale ese repositorio si no lo tiene instalado ya:

`dnf install epel-release`

Luego instale _rkhunter_:

`dnf install rkhunter`

## Configurar rkhunter

Las únicas opciones de configuración que se deben establecer son las que están relacionadas con el envio de los informes por correo al administrador del sistema. Para modificar el archivo de configuración, ejecute:

`vi /etc/rkhunter.conf`

Y luego busque:

`#MAIL-ON-WARNING=me@mydomain root@mydomain`

Elimine el comentario y cambie el la dirección de correo me@mydomain.com para reflejar su dirección de correo electrónico.

Luego cambie el root@mydomain a root@nombre_de_servidor.

Puede que también necesite configurar [Postfix](../../email/postfix_reporting.md) para que la sección de correo electrónico funcione correctamente.

## Ejecutar rkhunter

_rkhunter_ puede ejecutarse escribiéndola en la línea de comandos. Hay una tarea de cron instalada en `/etc/cron.daily` pero si desea automatizar el procedimiento en un horario diferente, mire la guía [Automatización de trabajos de Cron](../../automation/cron_jobs_howto.md).

También tendrá que mover el script a otra ubicación que no sea `/etc/cron.daily`, por ejemplo `/usr/local/sbin` y luego llámelo desde su ejecución de Cron. El método más fácil, por supuesto, es dejar intacto el cron.daily por defecto.

Antes de permitir que _rkhunter_ se ejecute automáticamente, ejecute el comando manualmente con los parametros "--propupd" para crear el archivo rkhunter.dat, y asegurarse de que su entorno se reconozca sin problema:

`rkhunter --propupd`

Para ejecutar _rkhunter_ manualmente:

`rkhunter --check`

Esto se repetirá en la pantalla a medida que se realicen las comprobaciones, pidiéndole que `[Pulse <ENTER> para continuar]` después de cada sección.

## Conclusión

_rkhunter_ es una parte de una estrategia de securización de servidores que puede ayudarle a monitorizar el sistema de archivos y reportar cualquier problema al administrador del sistema. Tal vez sea una de las herramientas de securización más fáciles de instalar, configurar y ejecutar.
