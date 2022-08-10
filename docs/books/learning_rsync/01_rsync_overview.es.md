---
title: Breve descripción de rsync
author: tianci li
contributors: Steven Spencer
update: 2022-Mar-08
---

# Resumen de las copias de seguridad

¿Qué es una copia de seguridad?

La copia de seguridad se refiere a la duplicación de los datos en un sistema de archivos o en una base de datos. En caso de error o de desastre, los datos efectivos del sistema pueden restablecerse a tiempo y permitir el funcionamiento normal del sistema.

¿Cuáles son los métodos de copia de seguridad?

* Copia de seguridad completa: Se refiere a una copia única de todos los archivos, carpetas o datos contenidos en el disco duro o en la base de datos. (Pros: El mejor, puede recuperar los datos de forma más rápida. Desventajas: Ocupa un espacio mayor en el disco duro).
* Copia de seguridad incremental: Se refiere a la copia de seguridad de los datos actualizada después de la última copia de seguridad completa o incremental realizada. El proceso es así, como una copia de seguridad completa el primer día; una copia de seguridad de los datos recientemente añadidos el segundo día, en lugar de una copia de seguridad completa; el tercer día, una copia de seguridad de los datos recién añadidos sobre la base del segundo día, relativo al día siguiente, y así sucesivamente.
* Copia de seguridad diferencial: Se refiere a la copia de seguridad de los archivos modificados después de la copia completa de seguridad. Por ejemplo, una copia de seguridad completa el primer día; una copia de seguridad de los nuevos datos el segundo día; una copia de seguridad de los nuevos datos del segundo al tercer día del tercer día; y una copia de seguridad de todos los nuevos datos del segundo día al cuarto día, y así sucesivamente.
* Copia de seguridad selectiva: Se refiere a respaldar una parte concreta del sistema.
* Copia de seguridad en frío: Se refiere a la copia de seguridad que se realiza cuando el sistema está apagado o estado de mantenimiento. Los datos respaldados son exactamente los mismos que los del sistema durante ese estado o período de tiempo.
* Copia de seguridad caliente: Se refiere a la copia de seguridad que se realiza cuando el sistema está en operación normal. Como los datos en el sistema se actualizan en cualquier momento, los datos almacenados en la copia de seguridad tienen un cierto retraso en relación a los datos reales del sistema.
* Copia de seguridad remota: Se refiere a la copia de seguridad de los datos que se encuentra en otra ubicación geográfica para evitar la pérdida de datos y la interrupción de los servicios causada por incendios, desastres naturales, robo, etc.

## Resumen de rsync

En un servidor, respaldé la primera partición en la segunda partición, algo que se conoce comúnmente como "copia de seguridad local". Las herramientas específicas de copia de seguridad son `tar` , `dd` , `volcado` , `cp`, etc. Aunque los datos están respaldados en este servidor, si el hardware no puede arrancar correctamente, los datos no se podrán recuperar. Para solucionar este problema con la copia de seguridad local, hemos introducido otro tipo de copia de seguridad: la "copia de seguridad remota".

Algunos dirán: ¿Porqué no puedo utilizar el comando `tar` o `cp` en el primer servidor y enviarlo al segundo servidor a través de `scp` o `sftp`?

En un entorno de producción, la cantidad de datos que se maneja es relativamente grande. En primer lugar, tanto `tar` como `cp` consumen mucho tiempo y ocupan el rendimiento del sistema. La transmisión de datos a través de `scp` o `sftp` también consume un gran ancho de banda de red, lo que no está permitido en el entorno real de producción. En segundo lugar, estos comandos o herramientas deben ser introducidos manualmente por el administrador y deben integrarse con crontab para la ejecución de la tarea programada. Sin embargo, el tiempo establecido por crontab no es fácil de entender, y no es apropiado que los datos sean respaldados si el tiempo es demasiado corto o demasiado largo.

Por lo tanto, tiene que haber una copia de seguridad de los datos en el entorno de producción que necesite cumplir los siguientes requisitos:

1. Las copias de seguridad se transmiten por la red.
2. Sincronización de los archivos de datos en tiempo real.
3. Una carga menor sobre los recursos del sistema y una mayor eficiencia.

`rsync` parece satisfacer todas las necesidades listadas. Utiliza el acuerdo de licencia GNU de código abierto. Es una herramienta de copia de seguridad incremental rápida. La última versión es 3.2.3 (2020-08-06). Puede visitar el [sitio web oficial de rsync](https://rsync.samba.org/) para obtener más información.

En términos de soporte de plataforma, la mayoría de los sistemas tipo Unix están soportados, ya sea GNU/Linux o BSD. Además, existen herramientas relacionadas con `rsync` que se ejecutan bajo la plataforma Windows, como por ejemplo cwRsync.

La herramienta `rsync` original fue mantenida por el programador australiano <font color=red>Andrew Tridgell</font> (se muestra en la Figura 1, situada más abajo), y ahora es mantenido por <font color=red>Wayne Davison</font> (se muestra en la Figura 2, situada más abajo). Puede dirigirse al [ proyecto alojado en github ](https://github.com/WayneD/rsync) para obtener toda la información que necesite.

![ Andrew Tridgell ](images/Andrew_Tridgell.jpg) ![ Wayne Davison ](images/Wayne_Davison.jpg)

!!! nota "nota"

    **rsync en sí es sólo una herramienta incremental de copia de seguridad y no tiene la función de sincronización de datos en tiempo real (necesita ser complementada por otros programas). Además, la sincronización se realiza de forma unidireccional. Si quiere realizar la sincronización de forma bidireccional necesita interactuar con otras herramientas.**

### Principios y características básicas

¿Cómo consigue `rsync` una copia de seguridad eficiente mediante la sincronización de datos unidireccional?

El núcleo de `rsync` es su algoritmo de **suma de verificación**. Si está interesado en conocer como funciona, puede dirigirse a [Cómo funciona Rsync](https://rsync.samba.org/how-rsync-works.html) y [El algoritmo Rsync](https://rsync.samba.org/tech_report/) para obtener más información. Esta sección está fuera de la competencias del autor de este documento y no se cubrirá con demasiado detalle.

Las características de `rsync` son:

* El directorio se puede actualizar por completo recursivamente;
* Puede retener selectivamente los atributos de sincronización de los archivos, como enlaces, su el propietario, el grupoal que pertenece, los permisos correspondientes, la fecha/hora de modificación, etc. y puede retener algunos de los atributos;
* Soporte para dos protocolos para la transmisión de archivos, uno es el protocolo ssh, el otro es el protocolo rsync.
