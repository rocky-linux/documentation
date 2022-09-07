---
title: Sed - Buscar y reemplazar
author: Steven Spencer
---

# `sed` - Buscar y reemplazar

`sed` es el acrónimo de un comando que significa "stream editor".

## Convenciones

* `path`: La ruta actual. Por ejemplo: `/var/www/html/`
* `filename`: El nombre de archivo real. Ejemplo: `index.php`

## Utilizar `sed`

`sed` es mi preferencia personal a la hora de realizar búsquedas y reemplazos de texto porque puede utilizar un delimitador de su elección, lo que hace que reemplazar cosas como por ejemplo, los enlaces web con "/" en ellos sea muy práctico. Los ejemplos para la edición in situ utilizando `sed` muestran comandos como este:

`sed -i 's/cadena_a_buscar/cadena_de_reemplazo/g' /ruta/nombre_de_archivo`

¿Pero qué pasa si busca cadenas que contengan "/" en ellas? Si la barra fuese la única opción disponible como delimitador, tendríamos que escapar cada barra antes de poder utilizarla en las búsquedas. Ahí es donde `sed` destaca sobre otras herramientas, porque permite cambiar el delimitador sobre la marcha (sin necesidad especificar que se está cambiando en ningún sitio). Como se ha dicho, si buscamos cadenas que contengan "/", podemos hacerlo fácilmente cambiando el delimitador por "|". A continuación hay un ejemplo de búsqueda de un enlace utilizando este método:

`sed -i 's|cadena_a_buscar/con_barra|cadena_de_reemplazo|g' /ruta/nombre_de_archivo`

Puede utilizar cualquier carácter de un byte para el delimitador, a excepción de la barra invertida, la línea nueva y la "s". Por ejemplo, esto también funciona:

`sed -i 'sacadena_a_buscar_con_barraacadena_de_reemplazoag' /ruta/nombre_de_archivo` donde "a" es el delimitador, y la búsqueda y sustitución sigue funcionando. Por seguridad, puede especificar una copia de seguridad mientras busca y reemplaza, lo cual es útil para asegurarse de que los cambios que está haciendo con `sed` son los que _realmente_ quiere. Esto le da una opción de recuperación desde el archivo de copia de seguridad:

`sed -i.bak s|cadena_a_buscar|cadena_de_reemplazo|g /ruta/nombre_de_archivo`

Lo que creará una versión sin editar de `nombre_del_archivo` llamada `nombre_del_archivo.bak`

Si lo desea también puede utilizar comillas dobles en lugar de comillas simples:

`sed -i "s|cadena_a_buscar/con_barra|cadena_de_reemplazo|g" /ruta/nombre_de_archivo`

## Explicación de las opciones

| Opción | Explicación                                                               |
| ------ | ------------------------------------------------------------------------- |
| i      | editar línea in situ.                                                     |
| i.ext  | crear una copia de seguridad con la extensión indicada.                   |
| s      | especifica la búsqueda.                                                   |
| g      | especifica que se reemplace globalmente, es decir, todas las ocurrencias. |

## Múltiples archivos

Desafortunadamente, `sed` no tiene una opción para ejecutar bucles como posee `perl`. Para realizar un bucle a través de varios archivos, necesitaría combinar su comando `sed` dentro de un script. En esta sección, se muestra un ejemplo.

En primer lugar, genere una lista de archivos que utilizará su script, la cual puede obtenerse desde la línea de comandos:

`find /var/www/html  -name "*.php" > phpfiles.txt`

A continuación, cree un script para utilizar el fichero `phpfiles.txt`:

```
#!/bin/bash

for file in `cat phpfiles.txt`
do
        sed -i.bak 's|search_for/with_slash|replace_string|g' $file
done
```
El script recorre todos los archivos indicados en el archivo `phpfiles.txt`, crea una copia de seguridad de cada archivo y ejecuta la búsqueda y reemplazo de la cadena de forma global.  Una vez que haya verificado que la búsqueda y el reemplazo se ha completado con éxito y que los cambios son los deseados, puede eliminar todos los archivos de copia de seguridad.

## Otras lecturas y ejemplos

* `sed` [página de man](https://linux.die.net/man/1/sed)
* `sed` [ejemplos adicionales](https://www.linuxtechi.com/20-sed-command-examples-linux-users/)
* `sed` & `awk` [ libro de O'Reilly](https://www.oreilly.com/library/view/sed-awk/1565922255/)

## Conclusión

`sed` es una potente herramienta que funciona muy bien para las funciones de búsqueda y reemplazo, particularmente cuando el delimitador utilizado debe ser flexible.
