---
title: Perl - Buscar y reemplazar
author: Steven Spencer, Pedro Garcia
tags:
  - perl
  - search
---

# `Perl` Buscar y reemplazar

A veces es necesario buscar y reemplazar rápidamente cadenas de texto en un archivo o en un grupo de archivos. Hay muchas maneras de hacerlo, pero este método utiliza `perl`

Para buscar y sustituir una cadena concreta en varios archivos de un directorio, el comando a ejecutar sería:

```
perl -pi -w -e 's/search_for/replace_with/g;' ~/Dir_to_search/*.html
```

Para buscar y reemplazar en un solo archivo que pueda contener varias instancias de la cadena, puede especificar el archivo:

```
perl -pi -w -e 's/search_for/replace_with/g;' /var/www/htdocs/bigfile.html
```

Este comando utiliza la sintaxis de vi para buscar y reemplazar cualquier ocurrencia de una cadena y reemplazarla por otra en uno o varios archivos de un tipo determinado. Útil para realizar cambios en los enlaces html/php insertados en ese tipo de archivos, y muchas otras cosas.

## Explicación de las opciones

| Opción | Explicación                                                              |
| ------ | ------------------------------------------------------------------------ |
| -p     | coloca un bucle alrededor de su script                                   |
| -i     | editar línea in situ                                                     |
| -w     | imprime mensajes de advertencia en caso de que algo vaya mal             |
| -e     | permite introducir una sola línea de código en la línea de comandos      |
| -s     | especifica la búsqueda                                                   |
| -g     | especifica que se reemplace globalmente, es decir, todas las ocurrencias |

## Conclusión

Una forma sencilla de reemplazar una cadena en uno o varios archivos utilizando `perl`.
