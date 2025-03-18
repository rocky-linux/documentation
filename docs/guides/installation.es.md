---
Title: Instalación de Rocky Linux 9
author: Wale Soyinka
contributors: Steven Spencer, Ganna Zhyrnova
---

# Instalación de Rocky Linux 9

Esta es una guía detallada para instalar la versión de 64 bits de la distribución de Rocky Linux en un sistema independiente. Vamos a realizar una instalación de clase servidor. Realizaremos los pasos de instalación y personalización en las siguientes secciones.

## Prerequisitos de instalación de SO

Descargue la ISO a utilizar para esta instalación de Rocky Linux.
Puede descargar la última imagen ISO para la versión de Rocky Linux de esta instalación aquí:

<https://www.rockylinux.org/download/>

Para descargar la ISO directamente desde la línea de comandos en un sistema existente basado en Linux, utilice el comando `wget`:

```bash
wget https://download.rockylinux.org/pub/rocky/9/isos/x86_64/Rocky-9.3-x86_64-minimal.iso
```
Las ISOs Rocky Linux siguen esta convención de nombres:

```text
Rocky-<MAJOR#>.<MINOR#>-<ARCH>-<VARIANT>.iso
```

Por ejemplo, `Rocky-9.3-x86_64-minimal.iso`

¡¡¡ Nota !!!

    La página Web del proyecto Rocky muestra un listado de diversos servidores de réplicas alrededor del mundo. Elegir el servidor de réplica que geográficamente esté más cerca a tu ubicación. La lista oficial de servidores de réplica pueden ser encontrados en (https://mirrors.rockylinux.org/mirrormanager/mirrors).

## Verificar el Programa de Instalación del Archivo ISO

Si ha descargado la imagen Rocky Linux ISO(s) sobre una distribución de Linux existente, puedes usar la utilidad `sha256sum` para verificar que los archivos(s) descargado(s) no están corruptos. Mostraremos un ejemplo de la verificación del archivo `Rocky-9.3-x86_64-minimal.iso` comprobando su suma de verificación.

1. Descargue el archivo que contiene las sumas de verificación oficiales para las ISO disponibles.

2. Mientras estamos en la carpeta que contiene la ISO del Rocky Linux descargada, descargue el archivo de la suma de verificación para la ISO, escriba:

    ```bash
    wget -O CHECKSUM https://download.rockylinux.org/pub/rocky/9.3/isos/x86_64/CHECKSUM
    ```

3. Use la utilidad `sha256sum` para verificar la integridad del archivo ISO frente a cualquier corrupción o la manipulación.

    ```bash
    sha256sum -c CHECKSUM --ignore-missing
    ```

    Esto comprueba la integridad del archivo ISO descargado previamente, siempre que esté en el mismo directorio. La salida debe mostrar:

    ```text
    Rocky-9.3-x86_64-minimal.iso: OK
    ```

## La Instalación

¡¡¡ Consejo !!!

    Antes de realizar una instalación de manera correcta, la Interfaz de firmware extensible unificada (UEFI) o el Sistema básico de entrada/salida (BIOS) del sistema deben estar preconfigurados para arrancar desde el medio correcto. 

Si el ordenador está configurado para arrancar desde los medios con el archivo ISO, podemos comenzar la instalación.

    Una vez que el ordenador ha arrancado, se ve la pantalla de salpicadura de bienvenida Rocky Linux 9.

    Rocky Linux installation splash screen

1. Insertar y arrancar desde el medio de instalación (disco óptico, unidad flash USB, u otro medio).

2. Una vez que el ordenador ha arrancado, se ve la pantalla inicial de bienvenida Rocky Linux 9. 

    ![Pantalla inicial de bienvenida de instalación](images/install_9_3_01.png)

3. Si no pulsa ninguna tecla, el programa de instalación inicia una cuenta atrás, después de la cual el proceso de instalación se ejecutará automáticamente con la opción resaltada predeterminada:

    `Test this media & install Rocky Linux 9.3`

    También puedes pulsar ++entrar++ en cualquier momento para iniciar el proceso inmediatamente.

4. Se realiza un paso de verificación rápido de medios.
Este paso de verificación de medios puede ahorrarle la molestía de iniciar la instalación, sólo para comprobar que a mitad de camino el programa de instalación tiene que detenerse debido a un mal medio de instalación.

5. Después de que la verificación de los medios se ejecuta hasta terminar y el medio se verifica con éxito para ser utilizado, el programa de instalación continúa automáticamente hasta la siguiente pantalla.

6. Seleccione el idioma que desea utilizar para realizar la instalación en esta pantalla. Para esta guía seleccionamos *Inglés (Estados Unidos)*. A continuación, haga clic en el botón ++"continuar"++.

## Resumen de instalación

La pantalla de `Resumen de instalación` es un área todo-en-uno donde tomas decisiones importantes sobre la instalación del sistema.

La pantalla se divide aproximadamente en las siguientes secciones:

- *LOCALIZACION*
- *SOFTWARE*
- *SISTEMA*
- *CONFIGURACIONES DE USUARIO*

A continuación profundizaremos en cada una de estas secciones y haremos cambios cuando sea necesario.

### Sección de Localización

Esta sección personaliza elementos relacionados con la ubicación geográfica del sistema. Esto incluye el teclado, Soporte de Idioma, Hora y Fecha.

#### Teclado

En esta guía de deomostración, aceptamos el valor predeterminado (*English US*) y no hacemos cambios.

Sin embargo, si necesita hacer algún cambio aquí, desde la pantalla *Resumen de la instalación*, haga clic en la opción ++"teclado"++ para especificar el diseño del teclado del sistema. Usando el botón de ++más++, puede agregar diseños adicionales de teclado si es necesario en la pantalla subsiguiente e incluso especificar su orden preferido.

Haz clic en ++"hecho"++ cuando hayas terminado con esta pantalla.

#### Soporte de Idioma

La opción de `Soporte de Idioma` en la pantalla *Resumen de instalación* le permite especificar soporte para idiomas adicionales.

Aceptaremos el valor predeterminado - **Inglés (Estados Unidos)** y no realizamos cambios, hacemos clic en ++"hecho"++.

#### Fecha y Hora

Haz clic en la opción ++"Fecha y Hora"++ en la pantalla principal del *Resumen de Instalación* para obtener otra pantalla que le permitirá seleccionar la zona horaria en la que se encuentra la máquina. Desplácese a través de la lista de regiones y ciudades y seleccione la zona más cercana a usted.

Dependiendo de su fuente de instalación, la opción "Fecha/Hora de Red" podría configurarse en *ON* u *OFF* por defecto. Aceptar la configuración predeterminada *ON*; esto permite que el sistema establezca automáticamente el tiempo correcto usando el Protocolo de Tiempo de red (NTP).

Haga clic en ++"hecho"++ después de hacer cualquier cambio.

### Sección de Software

En la sección de Software de la pantalla de *Resumen de Instalación*, puede seleccionar o cambiar la fuente de instalación, así como paquetes (aplicaciones) adicionales que se instalan.

#### Fuente de instalación

Debido a que la instalación utiliza una imagen ISO de Rocky Linux 9, notará que *Local Media* se especifica automáticamente en la sección Fuente de instalación de la pantalla principal de *Resumen de Instalación*. Puede aceptar los predeterminados preestablecidos.

¡¡¡ Consejo !!!

    El área de Fuente de instalación le permite especificar una instalación a través de red (por ejemplo, si usa el arranque ISO de Rocky Linux - Rocky-9.3-x86_64-boot.iso). Para una instalación a través de red, necesita primero asegurarse que existe un adaptador de red configurado correctamente en el sistema y que puede alcanzar Internet. Para realizar una instalación a través de red, haga clic en `Origen de Instalación` y seleccione la opción `A través de red`. Una vez seleccionada, seleccionar `https` como protocolo y escriba la siguiente URL en el campo de texto `download.rockylinux.org/pub/rocky/9/BaseOS/x86_64/os`. Haga clic en `Hecho`.

#### Selección de Software

Al Haga clic en la opción ++"Software Selection"++ en la pantalla principal de *Resumen de Instalación* se presenta la sección de instalación donde puede elegir los paquetes de software exactos instalados en el sistema. El área de selección de software se divide en:

- **Entorno Base**: Instalación mínima y sistema operativo personalizado
- **Software adicional para el entorno seleccionado**: Seleccionando un entorno base en el lado izquierdo, presenta en el lado derecho una variedad de software adicional relacionado a instalar. Tenga en cuenta que esto sólo se aplica si estaba instalando desde un DVD completo de Rocky Linux 9.2 o tiene repositorios adicionales configurados.

Seleccione la opción *Instalación Mínima* (funcionalidad básica).

Haz clic en ++"Hecho"++ en la parte superior de la pantalla.

### Sección del Sistema

La sección Sistema de la pantalla de *Resumen de instalación* se utiliza para personalizar y hacer cambios en las cuestiones relacionadas con el hardware subyacente del sistema de destino. Aquí es donde crea sus particiones o volúmenes de unidad de disco duro, especifica el sistema de archivos, especifica la configuración de red, habilita o deshabilita KDUMP o selecciona un Perfil de Seguridad.

#### Destino de la Instalación

Desde la pantalla de *Resumen de instalación*, haga clic en la opción ++"Installation Destination"++ . Esto le lleva al área de tareas correspondiente.

Verá una pantalla que muestra todas las unidades de disco candidatas que tiene disponible en el sistema de destino. Si usted tiene sólo una unidad de disco en el sistema, como en nuestro ejemplo, ve la unidad listada bajo *Discos Estándar Locales* con una marca de verificación a su lado. Al Haga clic en el icono de disco, cambiará activada o desactivada la marca de verificación de selección de disco. Mantenlo activado para seleccionar el disco.

Bajo la sección *Configuración de Almacenamiento*:

1. Seleccione la opción ++"Automático"++.

2. Haz clic en ++"Hecho"++ en la parte superior de la pantalla.

3. Una vez que el programa de instalación determina que tiene un disco utilizable, vuelve a la pantalla *Resumen de Instalación*.

### Red y nombre de Host

La siguiente tarea importante del procedimiento de instalación en el Área del Sistema se refiere a la configuración de la red, donde puede configurar o ajustar la configuración de la red para el sistema.

¡¡¡ Nota !!! 

    Tras Haga clic en la opción ++"Red y nombre de host"++, todo el hardware de interfaz de red detectado correctamente (como Ethernet, tarjetas de red inalámbricas, etc.) aparecerá en el panel izquierdo de la pantalla de configuración de red. Según la configuración de hardware, los dispositivos Ethernet en Linux tienen nombres similares a `eth0`, `eth1`, `ens3`, `ens4`, `em1`, `em2`, `p1p1`, `enp0s3`, etc.
    Puede configurar cada interfaz mediante DHCP o configurar manualmente la dirección IP.
    Si opta por la configuración manual, asegúrese de tener a mano toda la información necesaria, como la dirección IP, máscara de red, etc.

Al Haga clic en el botón ++"Network & Hostname"++ en la pantalla principal de *Resumen de Instalación* se abre la pantalla de configuración correspondiente. Aquí, puede configurar el nombre de host del sistema (hostname).

¡¡¡ Nota !!!

    Puede cambiar el nombre de host fácilmente después o una vez que el SO ha sido instalado.

La siguiente tarea de configuración importante está relacionada con las interfaces de red del sistema.

1. Verifique que el panel izquierdo enumera una tarjeta Ethernet (o cualquier tarjeta de red.)
2. Haga clic en cualquiera de los dispositivos de red detectados en el panel izquierdo para seleccionarlo.
Las propiedades configurables del adaptador de red seleccionado aparecen en el panel derecho de la pantalla.

¡¡¡ Nota !!!

    En nuestro ejemplo, tenemos dos dispositivos Ethernet en estado conectados (`ens3` y `ens4`). El tipo, nombre, cantidad y estado de los dispositivos de red de su sistema pueden ser diferentes a los de nuestro ejemplo.

Verificar el interruptor del dispositivo que desea configurar está situado en posición `ON` (azul) en el panel derecho. 
Aceptaremos todos los valores por defecto de esta sección.

Haz clic en ++"hecho"++ para volver a la pantalla principal de *Resumen de Instalación*.

¡¡¡ Advertencia !!!

    Preste atención a la dirección IP del servidor en esta sección del instalador. Si no tiene acceso físico o fácil al sistema mediante la consola, esta información le será útil más adelante cuando necesite conectarse al servidor para continuar trabajando en él una vez finalizada la instalación del sistema operativo.

### Sección de Configuraciones de Usuario

Esta sección se puede utilizar para crear una contraseña para la cuenta `root` y también para la creación de nuevas cuentas administrativas o no administrativas.

#### Contraseña de Root

1. Haga clic en el campo *Contraseña Root* en "Configuraciones de usuario" para iniciar la pantalla de cambio de *Contraseña Root*.

    ¡¡¡ Advertencia !!!

        El superusuario root es la cuenta con más privilegios del sistema. Por lo tanto, si decide usarlo o habilitarlo, es fundamental protegerlo con una contraseña segura. 

2. En el cuadro de texto de *Contraseña Root*, establezca una contraseña fuerte para el usuario de raíz.

3. Introduzca de nuevo la misma contraseña en el cuadro de texto *Confirmar*.

4. Haga clic en ++"Hecho"++.

#### Creación de Usuario

Para crear un usuario:

1. Haga clic en el campo *Creación de Usuario* en la *Configuraciones de usuario* para iniciar la pantalla de *Crear Usuario*.
Este área de tarea le permite crear una cuenta de usuario privilegiado o no privilegiado (cuenta no administrativa).

    !!! Información

        Crear y utilizar una cuenta sin privilegios para las tareas diarias en un sistema es una buena práctica de administración del sistema.

    Crearemos un usuario regular que pueda invocar los poderes de superusuario (administrador) cuando sea necesario.

2. Completa los campos en la pantalla *Crear Usuario* con la siguiente información:

    - **Nombre completo**: `rockstar`
    - **Nombre de Usuario**: `rockstar`
    - **Hacer este usuario administrador**: Marcar para seleccionar si.
    - **Requiere una contraseña para usar esta cuenta**:  Marcar para seleccionar si.
    - **Contraseña**: `04302021`
    - **Confirmar contraseña**: `04302021`

3. Haga clic en ++"Hecho"++.

## Fase de instalación

Una vez que está de acuerdo con sus opciones para las diversas tareas de instalación, la siguiente fase del proceso de instalación comenzará la instalación propiamente dicha.

### Inicia la instalación

Una vez que está de acuerdo con sus opciones para las diversas tareas de instalación, haga clic en el botón ++"Inicio de entrada"++ en la pantalla principal de *Resumen de Instalación*.

La instalación comenzará, y el programa de instalación mostrará el progreso de la instalación. 
Una vez que comience la instalación, varias tareas comenzarán a funcionar en segundo plano, como particionar el disco, formatear las particiones o volúmenes LVM, comprobar y resolver dependencias de software, escribir el sistema operativo en el disco, y así sucesivamente.

¡¡¡ Nota !!!

    Si no desea continuar después de hacer clic en el botón "Iniciar instalación", puede salir de la instalación de forma segura sin perder datos. Para salir del instalador, simplemente reinicie el sistema haciendo clic en el botón "Salir", presionando Ctrl+Alt+Supr o presionando el botón de reinicio o de encendido.

### Completa la instalación

Después de que el programa de instalación haya completado su trabajo, verá una pantalla final de progreso de instalación con un mensaje completo.

Finalmente, complete todo el procedimiento haciendo clic en el botón ++"Reiniciar Sistema"++. El sistema se reinicia.

### Iniciar sesión

El sistema está ahora listo para su uso. Verás la consola Rocky Linux.

![Pantalla de Bienvenida de Rocky Linux](images/installation_9_F02.png)

Para iniciar sesión en el sistema:

1. Escriba 'rockstar' en el prompt de inicio de sesión y pulse de ++Intro++.

2. En el prompt de la contraseña, escriba `04302021` (contraseña de rockstar) y pulse ++intro++ (la contraseña no se muestra en pantalla, eso es normal).

3. Ejecute el comando `whoami` después de iniciar sesión.
Este comando muestra el nombre del usuario actualmente registrado.

![Pantalla de Inicio de Sesión](images/installation_9.0_F03.png)
