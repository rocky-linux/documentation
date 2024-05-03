---
title: mtr - Diagnósticos de red
author: tianci li
contributors: Steven Spencer, Pedro Garcia
date: 20-10-2021
---

# Introducción a `mtr`

`mtr` es una herramienta de diagnóstico de red que puede ayudarle en la detección de problemas de red. Se utiliza para reemplazar los comandos `ping` y `traceroute`. En términos de rendimiento, el comando `mtr` es más rápido.

## Utilizar `mtr`

```bash
# Install mtr
shell > dnf -y install mtr
```

Las opciones más comunes del comando `mtr` se muestran a continuación. En circunstancias normales, no se requieren má opciones adicionales, seguidas del nombre de host o la dirección IP directamente:

| Opciones | Descripción                                    |
| -------- | ---------------------------------------------- |
| -4       | # Utilizar solo IPv4                          |
| -6       | Utilizar solo IPv6                             |
| -c COUNT | # Número de pings a enviar                    |
| -n       | # No resolver el nombre del host              |
| -z       | # Mostrar como número                         |
| -b       | # Mostrar la dirección ip y el nombre de host |
| -w       | # Salida a una amplia variedad de informes    |

La información mostrada por el terminal es la siguiente:

```bash
shell > mtr -c 10 bing.com
 My traceroutr [v0.92]
li(192.168.100.4) 2021-10-20T08:02:05+0800
Keys:Help Display mode Restart Statistics Order of fields quit
HOST: li Loss% Snt Last Avg Best Wrst StDev
 1. _gateway 0.0% 10 2.0 5.6 2.0 12.9 3.6
 2. _gateway 0.0% 10 2.0 5.6 2.0 12.9 3.6
 2. 120.80.175.109 0.0% 10 15.8 15.0 10.0 20.1 3.1
 4. 112.89.0.57 20.0% 10 18.9 15.2 11.5 18.9 2.9
 5.219.158.8.114 0.0% 10 10.8 14.4 10.6 20.5 3.5
 6. 219.158.24.134 0.0% 10 13.1 14.5 11.9 18.9 2.2
 7. 219.158.10.30 0.0% 10 14.9 21.2 12.0 29.8 6.9
 8. 219.158.33.114 0.0% 10 17.7 17.1 13.0 20.0 2.0
 9. ??? 100.0 10 0.0 0.0 0.0 0.0 0.0
10. ??? 100.0 10 0.0 0.0 0.0 0.0 0.0
11. ??? 100.0 10 0.0 0.0 0.0 0.0 0.0
12. ??? 100.0 10 0.0 0.0 0.0 0.0 0.0
13. a-0001.a-msedge.net 0.0% 10 18.4 15.7 9.5 19.3 3.1
...
```

* Loss% - Tasa de pérdida de paquetes
* Snt - Número de paquetes enviados
* Last - Retraso del último paquete
* Avg - Retraso medio
* Best - Latencia más baja
* Wrst - Mayor retraso
* StDev - Variación (estabilidad)

## Teclas de acceso directo para la interacción
<kbd>p</kbd> - Pausa; <kbd>d</kbd> - Cambia el modo de visualización; <kbd>n</kbd> - Activar/desactivar DNS; <kbd>r</kbd> - Restablecer todos los contadores; <kbd>j</kbd> - Alternar la información de la pantalla de retraso; <kbd>y</kbd> - Cambiar información de IP; <kbd>q</kbd> - Salir de la interacción.
