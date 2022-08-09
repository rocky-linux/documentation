---
title: Habilitar el cortafuegos `iptables`
author: Steven Spencer
contributors: Ezequiel Bruni
tested with: 8.5, 8.6, 9.0
tags:
  - seguridad
  - iptables
  - obsoleto
---

# Habilitar el cortafuegos `iptables`

## Requisitos previos

* Un deseo ardiente e insaciable de desactivar _firewalld_, el cortafuegos configurado por defecto en el sistema y activar _iptables_.

!!! warning "Este proceso es desaprobado"

    A partir de la versión 9.0 de Rocky Linux, `iptables` y todas las utilidades asociadas a él están obsoletas. Esto significa que las futuras versiones del sistema operativo eliminarán `iptables`. Por esta razón, es muy recomendable que no utilice este proceso. Si está familiarizado con iptables,le recomendamos utilizar la guía [`iptables` a `firewalld`](firewalld.md). Si es nuevo en la terminología y conceptos de los cortafuegos, entonces le recomendamos leer la guía [`firewalld` Para principiantes](firewalld-beginners.md).

## Introducción

_firewalld_ es ahora el cortafuegos por defecto en Rocky Linux. _firewalld_ **no era** más que una aplicación dinámica de _iptables_ que cargaba los cambios, sin vaciar las reglas desde archivos en formato xml en CentOS 7/RHEL 7.  Con CentOS 8/RHEL 8/Rocky 8, _firewalld_ es una capa alrededor de _nftables_. Sin embargo, todavía es posible instalar y utilizar _iptables_ si ese es su deseo. Para instalar y ejecutar directamente _iptables_ sin _firewalld_ puede hacerlo siguiendo esta guía. Lo que esta guía **no** le dirá es cómo escribir reglas para _iptables_. Se asume que si quiere deshacerse de _firewalld_, debe saber cómo escribir reglas para _iptables_.

## Deshabilitar firewalld

Realmente no es posible ejecutar las antiguas utilidades de _iptables_ al mismo tiempo que _firewalld_. Sencillamente, no son compatibles. La mejor manera de evitarlo es deshabilitar _firewalld_ completamente (no es necesario desinistarla a menos que realmente lo desee), y reinstalar las utilidades _iptables_. Es posible deshabilitar _firewalld_ utilizando los siguientes comandos:

Detener _firewalld_:

`systemctl stop firewalld`

Deshabilitar _firewalld_ para que no se ejecute al arrancar el sistema:

`systemctl disable firewalld`

Enmascarar el servicio para que no pueda ser encontrado:

`systemctl mask firewalld`

## Instalar y habilitar los servicios iptables

A continuación necesitamos instalar los antiguos servicios y utilidades de _iptables_. Esto se hace mediante el siguiente comando:

`dnf install iptables-services iptables-utils`

Esto instalará todo lo necesario para ejecutar un conjunto de reglas de _iptables_.

Ahora necesitamos habilitar el servicio _iptables_ para asegurarnos de que se ejecute correctamente al arrancar el sistema:

`systemctl enable iptables`

## Conclusión

Si lo prefiere puede volver a utilizar _iptables_ en vez de utilizar _firewalld_. Puede volver a utilizar _firewalld_, el cortafuegos por defecto del sistema. Simplemente debe revertir los cambios realizados previamente.
