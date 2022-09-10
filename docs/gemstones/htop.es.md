---
title: htop-Gestión de procesos
author: tianci li
contributors: Steven Spencer, Pedro Garcia
date: 16-10-2021
---

# Instalar `htop`
A todo administrador de sistemas le gusta usar algunos de los comandos más utilizados. Hoy recomiendo `htop` como alternativa al comando `top`. Para utilizar el comando `htop` con normalidad, es necesario instalarlo primero.

``` bash
# Installation epel source (also called repository)
dnf -y install epel-release
# Generate cache
dnf makecache
# Install htop
dnf -y install htop
```

# Utilizar `htop`
Sólo tiene que escribir `htop` en el terminal, y se mostrará la siguiente interfaz interactiva:

```
0[ |||                      3%]     Tasks: 24, 14thr; 1 running
1[ |                        1%]     Load average: 0.00 0.00 0.05
Mem[ |||||||           197M/8G]     Uptime: 00:31:39
Swap[                  0K/500M]
PID   USER   PRI   NI   VIRT   RES   SHR   S   CPU%   MEM%   TIME+   Commad(merged)
...
```

<kbd>F1</kbd>Help   <kbd>F2</kbd>Setup  <kbd>F3</kbd>Search <kbd>F4</kbd>Filter <kbd>F5</kbd>Tree   <kbd>F6</kbd>SortBy <kbd>F7</kbd>Nice   <kbd>F8</kbd>Nice+  <kbd>F9</kbd>Kill   <kbd>F10</kbd>Quit

## Descripción de la parte superior

* El 0 y el 1 superiores indican el número de sus núcleos de CPU, y el porcentaje indica la tasa de ocupación de un solo núcleo (por supuesto, también se puede mostrar la tasa de ocupación total de la CPU)
    * Los diferentes colores de la barra de progreso indican el porcentaje de los diferentes tipos de procesos:

        | Color   | Descripción                                                           |
        | ------- | --------------------------------------------------------------------- |
        | Azúl    | El porcentaje de la CPU utilizado por los procesos de baja prioridad. |
        | Verde   | El porcentaje de proceso de CPU propiedad de usuarios comunes.        |
        | Rojo    | El porcentaje de CPU utilizada por los procesos del sistema.          |
        | Naranja | El porcentaje de la CPU utilizado por el tiempo IRQ.                  |
        | Magenta | El porcentaje de la CPU utilizado por el tiempo de IRQ soft.          |
        | Gris    | El porcentaje de la CPU ocupado por el tiempo de espera IO.           |
        | Cían    | El porcentaje de la CPU utilizado por el tiempo Steal.                |

* Tasks: 24, 14thr; 1 running, process information. En mi ejemplo, significa que la máquina tiene 24 tareas, que se dividen en 14 hilos, de los cuales sólo 1 proceso está en estado de ejecución.
* Información sobre la memoria y la swap. Del mismo modo, utiliza diferentes colores para distinguir:

 | Color   | Descripción                                                |
 | ------- | ---------------------------------------------------------- |
 | Azúl    | El porcentaje de memoria consumido por el bufer.           |
 | Verde   | El porcentaje de memoria consumido por el área de memoria. |
 | Naranja | El porcentaje de memoria consumido por el área de caché.   |

* Load average - Los tres valores representan respectivamente la carga media del sistema en el último 1 minuto, los últimos 5 minutos y los últimos 15 minutos.
* Uptime - Indicate el tiempo de funcionamiento desde el arranque del sistema.

## Descripción de la información de los procesos

* **PID - El número de identificación del proceso.**

* USER - El propietario del proceso.
* PRI - Muestra la prioridad del proceso tal y como la ve el kernel de Linux.
* NI - Muestra la prioridad del proceso de restablecimiento por parte del usuario normal o del superusuario root.
* VIRI - La memoria virtual consumida por un proceso.

* **RES - La memoria física consumida por un proceso.**

* SHR - La memoria compartida consumida por un proceso.
* S - El estado actual del proceso, ¡hay un estado especial al que prestar atención! La Z (proceso zombi). Cuando hay un gran número de procesos zombis en la máquina, esto afectará al rendimiento de la misma.

* **CPU% - El porcentaje de CPU consumido por cada proceso.**

* MEM% - El porcentaje de memoria consumido por cada proceso.
* TIME+ - Muestra el tiempo de ejecución desde que se inició el proceso.
* Command - El comando correspondiente al proceso.

## Descripción de teclas de acceso directo
En la interfaz interactiva, presione el botón <kbd>F1</kbd> para ver la descripción de la tecla de acceso directo correspondiente.

* Las teclas de dirección arriba, abajo, izquierda y derecha pueden desplazarle por la interfaz interactiva, y tecla <kbd>espacio</kbd> puede marcar el proceso correspondiente, que está marcado en amarillo.
* El botón <kbd>N</kbd>, el botón <kbd>P</kbd>, el botón <kbd>M</kbd> y el botón <kbd>T</kbd> son respectivamente PID, CPU%, MEM%, TIME+ se utiliza para ordenar los procesos. Por supuesto, también puede utilizar el ratón y hacer clic para ordenar de forma ascendente o descendente un determinado campo.

## Otras teclas de acceso directo comúnmente utilizadas
Para gestionar el proceso, utilice el botón <kbd>F9</kbd> para enviar diferentes señales al proceso. Se puede ver la lista de señales ejecutando el comando `kill -l`. Algunos de los más utilizados son:

| Señal | Descripción                                                                                                                                                                               |
| ----- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1     | Deja que el proceso se apague inmediatamente, y lo reinicia después de volver a leer el archivo de configuración.                                                                         |
| 9     | Se utiliza para terminar inmediatamente la ejecución del programa, tambien se utiliza para terminar forzosamente el proceso, similar al final forzado de la barra de tareas de Windows.   |
| 15    | La señal predeterminada para el comando kill. A veces si se ha producido un problema en el proceso y el proceso no se puede finalizar normalmente con esta señal, utilizaremos la señal 9 |

## Fin
El comando `htop` es mucho más sencillo de utilizar que el comando `top` que viene instalado por defecto en el sistema, es más intuitivo y mejora mucho el uso diario. Por eso, lo primero que suele hacer el autor después de instalar el sistema operativo es instalarlo.
