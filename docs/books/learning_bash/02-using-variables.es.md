---
title: Bash - Uso de variables
author: Antoine Le Morvan
contributors: Steven Spencer, Pedro garcia
tested with: 8.5
tags:
  - educación
  - bash scripting
  - bash
---

# Bash - Uso de variables

En este capítulo aprenderá a usar variables en tus scripts bash.

****

**Objetivos**: En este capítulo aprenderá como:

:heavy_check_mark: Almacenar información para su posterior uso;  
:heavy_check_mark: Eliminar y bloquear variables;  
:heavy_check_mark: Utilizar variables de entorno;  
:heavy_check_mark: Comandos de sustitución;

:checkered_flag: **linux**, **script**, **bash**, **variable**

**Conocimiento**: :star: :star:  
**Complejidad**: :star:

**Tiempo de lectura**: 10 minutos

****

## Almacenar información para su posterior uso

Como en cualquier lenguaje de programación, los scripts de shell utilizan variables. Se utilizan para almacenar información en memoria para ser reutilizada según sea necesario durante el script.

Una variable se crea cuando recibe su contenido. Y sigue siendo válida hasta el final de la ejecución del script o a petición explícita del autor del script. Dado que el script se ejecuta secuencialmente de principio a fin, es imposible llamar a una variable antes de que se cree.

Se puede cambiar el contenido de una variable durante el script, ya que la variable continúa existiendo hasta que el script termina. Si su contenido se elimina, la variable permanece activa pero no contiene nada.

La noción de un tipo de variable en un script de shell es posible, pero es muy raramente usada. El contenido de una variable es siempre un carácter o una cadena.

```
#!/usr/bin/env bash

#
# Author : Rocky Documentation Team
# Date: March 2022
# Version 1.0.0: Save in /root the files passwd, shadow, group, and gshadow
#

# Global variables
FILE1=/etc/passwd
FILE2=/etc/shadow
FILE3=/etc/group
FILE4=/etc/gshadow

# Destination folder
DESTINATION=/root

# Clear the screen
clear

# Launch the backup
echo "Starting the backup of $FILE1, $FILE2, $FILE3, $FILE4 to $DESTINATION:"

cp $FILE1 $FILE2 $FILE3 $FILE4 $DESTINATION

echo "Backup ended!"
```

Este script hace uso de variables. El nombre de una variable debe comenzar con una letra, pudiendo contener cualquier secuencia de letras o números. Excepto para el guión bajo "_", los caracteres especiales no se pueden utilizar.

Por convención, las variables creadas por un usuario tienen el nombre en minúsculas. Este nombre debe elegirse con cuidado para no ser demasiado evasivo o demasiado complicado. Sin embargo, una variable puede ser nombrada con letras mayúsculas, como en este caso, si es una variable global que no debe ser modificada por el programa.

El carácter `=` asigna contenido a una variable:

```
variable=value
rep_name="/home"
```

No hay espacio antes o después del signo `=`.

Una vez creada la variable, puede utilizarse anteponiéndole un dólar $.

```
file=file_name
touch $file
```

Se recomienda encarecidamente proteger las variables con comillas, como en el siguiente ejemplo:

```
file=file name
touch $file
touch "$file"
```

Como el contenido de la variable contiene un espacio, el primer `touch` creará 2 archivos mientras que el segundo `touch` creará un archivo cuyo nombre contendrá un espacio.

Para aislar el nombre de la variable del resto del texto, debe utilizar comillas o llaves:

```
file=file_name
touch "$file"1
touch ${file}1
```

**Se recomienda el uso sistemático de llaves.**

El uso de apóstrofes inhibe la interpretación de caracteres especiales.

```
message="Hello"
echo "This is the content of the variable message: $message"
Here is the content of the variable message: Hello
echo 'Here is the content of the variable message: $message'
Here is the content of the variable message: $message
```

## Eliminar y bloquear variables

El comando `unset` permite eliminar una variable.

Ejemplo:

```
name="NAME"
firstname="Firstname"
echo "$name $firstname"
NAME Firstname
unset firstname
echo "$name $firstname"
NAME
```

El comando `readonly` o `typeset -r` bloquea una variable.

Ejemplo:

```
name="NAME"
readonly name
name="OTHER NAME"
bash: name: read-only variable
unset name
bash: name: read-only variable
```

!!! Note

    La instrucción `set -u` al principio del script detendrá la ejecución del script si se utilizan variables no declaradas.

## Utilizar variables de entorno

Las variables de **entorno** y las variables del **sistema** son variables utilizadas por el sistema para su operación. Por convención se nombran con letras mayúsculas.

Como todas las variables, se pueden mostrar cuando se ejecuta un script. Aunque se desaconseja encarecidamente, también pueden modificarse.

El comando `env` muestra todas las variables de entorno utilizadas.

El comando `set` muestra todas las variables del sistema utilizadas.

Entre las docenas de variables de entorno, varias son de interés para ser utilizadas en un script de shell:

| Variables                      | Descripción                                                              |
| ------------------------------ | ------------------------------------------------------------------------ |
| `HOSTNAME`                     | El nombre de la máquina.                                                 |
| `USER`, `USERNAME` y `LOGNAME` | El nombre del usuario conectado a la sesión.                             |
| `PATH`                         | La ruta para encontrar los comandos.                                     |
| `PWD`                          | El directorio actual, actualizado cada vez que se ejecuta el comando cd. |
| `HOME`                         | El directorio de inicio.                                                 |
| `$$`                           | El id de proceso de ejecución del script.                                |
| `$?`                           | Código de salida del último comando ejecutado.                           |

El comando `export` le permite exportar una variable.

Una variable sólo es válida en el entorno del proceso del script de shell. Para que un **hijo** del script conozca las variables y su contenido, estas deben ser exportadas.

La modificación de una variable exportada en un proceso hijo no se puede trazar hasta el proceso padre.

!!! note

    Sin ninguna opción, el comando `export` muestra el nombre y los valores de las variables exportadas en el entorno.

## Comandos de sustitución

Es posible almacenar el resultado de un comando en una variable.

!!! Note

    Esta operación sólo es válida para comandos que devuelven un mensaje al final de su ejecución.

La sintaxis para subejecutar un comando es la siguiente:

```
variable=`command`
variable=$(command) # Preferred syntax
```

Ejemplo:

```
$ day=`date +%d`
$ homedir=$(pwd)
```

Con todo lo que acabamos de ver, nuestro script de copia de seguridad podría verse así:

```
#!/usr/bin/env bash

#
# Author : Rocky Documentation Team
# Date: March 2022
# Version 1.0.0: Save in /root the files passwd, shadow, group, and gshadow
# Version 1.0.1: Adding what we learned about variables
#

# Global variables
FILE1=/etc/passwd
FILE2=/etc/shadow
FILE3=/etc/group
FILE4=/etc/gshadow

# Destination folder
DESTINATION=/root

## Readonly variables
readonly FILE1 FILE2 FILE3 FILE4 DESTINATION

# A folder name with the day's number
dir="backup-$(date +%j)"

# Clear the screen
clear

# Launch the backup
echo "****************************************************************"
echo "     Backup Script - Backup on ${HOSTNAME}                      "
echo "****************************************************************"
echo "The backup will be made in the folder ${dir}."
echo "Creating the directory..."
mkdir -p ${DESTINATION}/${dir}

echo "Starting the backup of ${FILE1}, ${FILE2}, ${FILE3}, ${FILE4} to ${DESTINATION}/${dir}:"

cp ${FILE1} ${FILE2} ${FILE3} ${FILE4} ${DESTINATION}/${dir}

echo "Backup ended!"

# The backup is noted in the system event log:
logger "Backup of system files by ${USER} on ${HOSTNAME} in the folder ${DESTINATION}/${dir}."
```

Al ejecutar nuestro script de copia de seguridad:

```
$ sudo ./backup.sh
```

obtendremos:

```
****************************************************************
     Backup Script - Backup on desktop                      
****************************************************************
The backup will be made in the folder backup-088.
Creating the directory...
Starting the backup of /etc/passwd, /etc/shadow, /etc/group, /etc/gshadow to /root/backup-088:
Backup ended!
```
