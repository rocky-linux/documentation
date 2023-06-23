---
title: Bash - Comprueba tu conocimiento
author: Antoine Le Morvan
contributors: Steven Spencer, Pedro garcia
tested_with: 8.5
tags:
  - educación
  - bash scripting
  - bash
---

# Bash - Comprueba tu conocimiento

:heavy_check_mark: Cada ejecución debe devolver un código de devolución al final de su ejecución:

- [ ] Verdadero
- [ ] Falso

:heavy_check_mark: Un código de retorno de 0 indica un error de ejecución:

- [ ] Verdadero
- [ ] Falso

:heavy_check_mark: El código de retorno se almacena en la variable `$@`:

- [ ] Verdadero
- [ ] Falso

:heavy_check_mark: El comando `test` le permite:

- [ ] Probar el tipo de un archivo
- [ ] Probar una variable
- [ ] Comparar números
- [ ] Compara el contenido de 2 archivos

:heavy_check_mark: El comando `expr`:

- [ ] Concatena 2 cadenas de caracteres
- [ ] Realiza operaciones matemáticas
- [ ] Muestra texto en la pantalla

:heavy_check_mark: ¿Te parece correcta la sintaxis de la estructura condicional que se muestra a continuación? Explique por qué.

```
if command
    command if $?=0
else
    command if $?!=0
fi
```

- [ ] Verdadero
- [ ] Falso

:heavy_check_mark: ¿Qué significa la siguiente sintaxis: `${variable:=value}`

- [ ] Muestra un valor de reemplazo si la variable está vacía
- [ ] Muestra un valor de reemplazo si la variable no está vacía
- [ ] Asigna un nuevo valor a la variable si está vacía

:heavy_check_mark: ¿Le parece correcta la sintaxis de la estructura alternativa condicional que se muestra a continuación? Explique por qué.

```
case $variable in
  value1)
    commands if $variable = value1
  value2)
    commands if $variable = value2
  *)
    commands for all values of $variable != of value1 and value2
    ;;
esac
```

- [ ] Verdadero
- [ ] Falso

:heavy_check_mark: ¿Cuál de las siguientes opciones no es una estructura de un bucle?

- [ ] while
- [ ] until
- [] loop
- [ ] for
