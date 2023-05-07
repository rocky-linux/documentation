---
title: Trabajar con filtros
author: Antoine Le Morvan
contributors: Steven Spencer
---

# Ansible - Trabajar con filtros

En este capítulo aprenderá a transformar datos mediante filtros de Jinja.

****

**Objetivos** : En este capítulo aprenderá a:

:heavy_check_mark: Transformar estructuras de datos como diccionarios o listas;
:heavy_check_mark: Transformar variables;

:checkered_flag: **ansible**, **jinja**, **filtros**

**Conocimiento**: :star: :star: :star:
**Complejidad**: :star: :star: :star: :star:

**Tiempo de lectura**: 20 minutos

****

Ya hemos tenido la oportunidad, durante los capítulos anteriores, de utilizar los filtros de Jinja.

Estos filtros, escritos en python, nos permiten manipular y transformar nuestras variables de ansible.

!!! Note

    Puede encontrar más información [aquí](https://docs.ansible.com/ansible/latest/user_guide/playbooks_filters.html).

A lo largo de este capítulo, utilizaremos el siguiente playbook para probar los diferentes filtros presentados:

```
- name: Manipulating the data
  hosts: localhost
  gather_facts: false
  vars:
    zero: 0
    zero_string: "0"
    non_zero: 4
    true_booleen: True
    true_non_booleen: "True"
    false_boolean: False
    false_non_boolean: "False"
    whatever: "It's false!"
    user_name: antoine
    my_dictionary:
      key1: value1
      key2: value2
    my_simple_list:
      - value_list_1
      - value_list_2
      - value_list_3
    my_simple_list_2:
      - value_list_3
      - value_list_4
      - value_list_5
    my_list:
      - element: element1
        value: value1
      - element: element2
        value: value2

  tasks:
    - name: Print an integer
      debug:
        var: zero
```

!!! Note

    La siguiente es una lista no exhaustiva de los filtros que probablemente se encontrará o necesitará mientras trabaje con Ansible.
    Afortunadamente, hay muchos otros. ¡Incluso podría escribir el suyo propio!

El playbook se ejecutará de la siguiente manera:

```
ansible-playbook play-filter.yml
```

## Convertir datos

Los datos se pueden convertir de un tipo a otro.

Para conocer el tipo de un dato (el tipo en lenguaje python), hay que utilizar el filtro `type_debug`.

Ejemplo:

```
- name: Display the type of a variable
  debug:
    var: true_boolean|type_debug
```

esto produce:

```
TASK [Display the type of a variable] ******************************************************************
ok: [localhost] => {
    "true_boolean|type_debug": "bool"
}
```

Es posible transformar un entero en una cadena:

```
- name: Transforming a variable type
  debug:
    var: zero|string
```

```
TASK [Transforming a variable type] ***************************************************************
ok: [localhost] => {
    "zero|string": "0"
}
```

Convertir una cadena en un entero:

```
- name: Transforming a variable type
  debug:
    var: zero_string|int
```

o una variable en un booleano:

```
- name: Display an integer as a boolean
  debug:
    var: non_zero | bool

- name: Display a string as a boolean
  debug:
    var: true_non_boolean | bool

- name: Display a string as a boolean
  debug:
    var: false_non_boolean | bool

- name: Display a string as a boolean
  debug:
    var: whatever | bool

```

Una cadena de caracteres se puede transformar a mayúsculas o minúsculas:

```
- name: Lowercase a string of characters
  debug:
    var: whatever | lower

- name: Upercase a string of characters
  debug:
    var: whatever | upper
```

esto produce:

```
TASK [Lowercase a string of characters] *****************************************************
ok: [localhost] => {
    "whatever | lower": "it's false!"
}

TASK [Upercase a string of characters] *****************************************************
ok: [localhost] => {
    "whatever | upper": "IT'S FALSE!"
}
```

El filtro `reemplazar` le permite sustituir unos caracteres por otros.

En este ejemplo, eliminamos espacios o incluso sustituimos una palabra:

```
- name: Replace a character in a string
  debug:
    var: whatever | replace(" ", "")

- name: Replace a word in a string
  debug:
    var: whatever | replace("false", "true")
```

esto produce:

```
TASK [Replace a character in a string] *****************************************************
ok: [localhost] => {
    "whatever | replace(\" \", \"\")": "It'sfalse!"
}

TASK [Replace a word in a string] *****************************************************
ok: [localhost] => {
    "whatever | replace(\"false\", \"true\")": "It's true !"
}
```

El filtro `split` le permite dividir una cadena en una lista basada en un carácter:

```
- name: Cutting a string of characters
  debug:
    var: whatever | split(" ", "")
```


```
TASK [Cutting a string of characters] *****************************************************
ok: [localhost] => {
    "whatever | split(\" \")": [
        "It's",
        "false!"
    ]
}
```

## Unir los elementos de una lista

Es frecuente tener que unir los diferentes elementos de una lista en una única cadena. A continuación, podemos especificar un carácter o una cadena para insertar entre cada elemento.

```
- name: Joining elements of a list
  debug:
    var: my_simple_list|join(",")

- name: Joining elements of a list
  debug:
    var: my_simple_list|join(" | ")
```

esto produce:

```
TASK [Joining elements of a list] *****************************************************************
ok: [localhost] => {
    "my_simple_list|join(\",\")": "value_list_1,value_list_2,value_list_3"
}

TASK [Joining elements of a list] *****************************************************************
ok: [localhost] => {
    "my_simple_list|join(\" | \")": "value_list_1 | value_list_2 | value_list_3"
}

```

## Transformar diccionarios en listas (y viceversa)

Los filtros `dict2items` y `itemstodict`, son filtros más complejos de implementar y se utilizan frecuentemente, especialmente en bucles.

Observe que es posible especificar el nombre de la clave y del valor a utilizar en la transformación.

```
- name: Display a dictionary
  debug:
    var: my_dictionary

- name: Transforming a dictionary into a list
  debug:
    var: my_dictionary | dict2items

- name: Transforming a dictionary into a list
  debug:
    var: my_dictionary | dict2items(key_name='key', value_name='value')

- name: Transforming a list into a dictionary
  debug:
    var: my_list | items2dict(key_name='element', value_name='value')
```

```
TASK [Display a dictionary] *************************************************************************
ok: [localhost] => {
    "my_dictionary": {
        "key1": "value1",
        "key2": "value2"
    }
}

TASK [Transforming a dictionary into a list] *************************************************************
ok: [localhost] => {
    "my_dictionary | dict2items": [
        {
            "key": "key1",
            "value": "value1"
        },
        {
            "key": "key2",
            "value": "value2"
        }
    ]
}

TASK [Transforming a dictionary into a list] *************************************************************
ok: [localhost] => {
    "my_dictionary | dict2items (key_name = 'key', value_name = 'value')": [
        {
            "key": "key1",
            "value": "value1"
        },
        {
            "key": "key2",
            "value": "value2"
        }
    ]
}

TASK [Transforming a list into a dictionary] ************************************************************
ok: [localhost] => {
    "my_list | items2dict(key_name='element', value_name='value')": {
        "element1": "value1",
        "element2": "value2"
    }
}
```

## Trabajar con listas

Es posible fusionar o filtrar datos de una o varias listas:

```
- name: Merger of two lists
  debug:
    var: my_simple_list | union(my_simple_list_2)
```

```
ok: [localhost] => {
    "my_simple_list | union(my_simple_list_2)": [
        "value_list_1",
        "value_list_2",
        "value_list_3",
        "value_list_4",
        "value_list_5"
    ]
}
```

Para mantener únicamente la intersección de las 2 listas (los valores presentes en las 2 listas):

```
- name: Merger of two lists
  debug:
    var: my_simple_list | intersect(my_simple_list_2)
```

```
TASK [Merger of two lists] *******************************************************************************
ok: [localhost] => {
    "my_simple_list | intersect(my_simple_list_2)": [
        "value_list_3"
    ]
}
```

O, por el contrario, mantener sólo la diferencia (los valores que no existen en la segunda lista):

```
- name: Merger of two lists
  debug:
    var: my_simple_list | difference(my_simple_list_2)
```

```
TASK [Merger of two lists] *******************************************************************************
ok: [localhost] => {
    "my_simple_list | difference(my_simple_list_2)": [
        "value_list_1",
        "value_list_2",
    ]
}
```

Si su lista contiene valores que no son únicos, también es posible filtrarlos mediante el filtro `unique`.

```
- name: Unique value in a list
  debug:
    var: my_simple_list | unique
```

## Transformación json/yaml

Es posible que tenga que importar datos en formato json (desde una API, por ejemplo) o exportar datos en formato yaml o json.

```
- name: Display a variable in yaml
  debug:
    var: my_list | to_nice_yaml(indent=4)

- name: Display a variable in json
  debug:
    var: my_list | to_nice_json(indent=4)
```

```
TASK [Display a variable in yaml] ********************************************************************
ok: [localhost] => {
    "my_list | to_nice_yaml(indent=4)": "-   element: element1\n    value: value1\n-   element: element2\n    value: value2\n"
}

TASK [Display a variable in json] ********************************************************************
ok: [localhost] => {
    "my_list | to_nice_json(indent=4)": "[\n    {\n        \"element\": \"element1\",\n        \"value\": \"value1\"\n    },\n    {\n        \"element\": \"element2\",\n        \"value\": \"value2\"\n    }\n]"
}
```

## Valores por defecto, variables opcionales, variables protegidas

Se encontrará rápidamente con errores en la ejecución de sus playbooks si no proporciona valores por defecto para sus variables, o si no las proteges.

Si no existe el valor de una variable, se puede ser sustituir por otro valor mediante el filtro `default`:

```
- name: Default value
  debug:
    var: variablethatdoesnotexists | default(whatever)
```

```
TASK [Default value] ********************************************************************************
ok: [localhost] => {
    "variablethatdoesnotexists | default(whatever)": "It's false!"
}
```

Observe la presencia del apóstrofe `'` que debería estar protegido, por ejemplo, si utiliza el modulo `shell`:

```
- name: Default value
  debug:
    var: variablethatdoesnotexists | default(whatever| quote)
```

```
TASK [Default value] ********************************************************************************
ok: [localhost] => {
    "variablethatdoesnotexists | default(whatever|quote)": "'It'\"'\"'s false!'"
}
```

Finalmente, si no existe una variable opcional en un módulo se puede ignorar utilizando con la palabra clave `omit` en el filtro `default`, lo que le ahorrará un error en tiempo de ejecución.

```
- name: Add a new user
  ansible.builtin.user:
    name: "{{ user_name }}"
    comment: "{{ user_comment | default(omit) }}"
```

## Asociar un valor en función de otro (`ternary`)

A veces es necesario utilizar una condición para asignar un valor a una variable, en cuyo caso es común pasar por un paso `set_fact`.

Esto se puede evitar utilizando el filtro `ternary`:

```
- name: Default value
  debug:
    var: (user_name == 'antoine') | ternary('admin', 'normal_user')
```

```
TASK [Default value] ********************************************************************************
ok: [localhost] => {
    "(user_name == 'antoine') | ternary('admin', 'normal_user')": "admin"
}
```

## Otros filtros

  * `{{ 10000 | random }}`: Como su nombre indica, da un valor aleatorio.
  * `{{ my_simple_list | first }}`: Extrae el primer elemento de la lista.
  * `{{ my_simple_list | length }}`: Da la longitud (de una lista o una cadena).
  * `{{ ip_list | ansible.netcommon.ipv4 }}`: Sólo muestra las IPs v4. Sin insistir en esto, si lo necesita, hay muchos filtros dedicados a la red.
  * `{{ user_password | password_hash('sha512') }}`: Genera una contraseña con hash en sha512.
