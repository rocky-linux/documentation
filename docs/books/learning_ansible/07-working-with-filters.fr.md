---
title: Travailler avec les Filtres
author: Antoine Le Morvan
contributors: Steven Spencer
---

# Ansible - Utilisation de filtres

Dans ce chapitre vous allez apprendre comment transformer les données grâce aux filtres jinja.

****

**Objectifs** : Dans ce chapitre, vous apprendrez à :

:heavy_check_mark: Transformer les structures de données en dictionnaires ou en listes ;   
:heavy_check_mark: Transformer des variables ;

:checkered_flag: **ansible**, **jinja**, **filtres**

**Compétences** : :star: :star: :star:       
**Difficulté** : :star: :star: :star: :star:

**Temps de lecture : **23 minutes

****

Nous avons déjà eu la possibilité, dans les chapitres précédents, d'utiliser les filtres Jinja.

Ces filtres, écrits en Python, nous permettent de manipuler et de transformer nos variables Ansible.

!!! note "Remarque"

    Plus d'informations sont disponible [ici] (https://docs.ansible.com/ansible/latest/user_guide/playbooks_filters.html).

Tout au long de ce chapitre, nous utiliserons le playbook suivant pour tester les différents filtres présentés :

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

!!! note "Note"

    La liste ci-dessous est une liste non exhaustive de filtres que vous serez souvent amené à voir ou à utiliser.
    Heureusement, il en existe plein d'autres. Vous pouvez aussi en créer vous-même !

Le playbook sera exécuté comme suit :

```
ansible-playbook play-filter.yml
```

## Convertir des données

Les données peuvent être converties d'un type à un autre.

Pour connaitre le type de données (le type d'après le langage Python), vous devez utiliser le filtre `type_debug`.

Exemple :

```
- name: Display the type of a variable
  debug:
    var: true_boolean|type_debug
```

ce qui nous donne :

```
TASK [Display the type of a variable] ******************************************************************
ok: [localhost] => {
    "true_boolean|type_debug": "bool"
}
```

Il est possible de transformer un nombre  entier en chaine de caractère :

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

Transformer une chaine de caractères en nombre entier :

```
- name: Transforming a variable type
  debug:
    var: zero_string|int
```

ou une variable en booleen :

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

Une chaine de caractères peut être changée en majuscules ou minuscules :

```
- name: Lowercase a string of characters
  debug:
    var: whatever | lower

- name: Upercase a string of characters
  debug:
    var: whatever | upper
```

ce qui nous donne :

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

Le filtre `replace` vous permet de remplacer des caractères par d'autres.

Ici, nous supprimons des espaces ou même remplacons un mot :

```
- name: Replace a character in a string
  debug:
    var: whatever | replace(" ", "")

- name: Replace a word in a string
  debug:
    var: whatever | replace("false", "true")
```

ce qui nous donne :

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

Le filtre `split` une chaîne en une liste basée sur un caractère :

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

## Joindre les éléments d'une liste

Il est fréquent de devoir joindre les différents éléments dans une seule chaîne. Nous pouvons alors spécifier un caractère ou une chaîne à insérer entre chaque élément.

```
- name: Joining elements of a list
  debug:
    var: my_simple_list|join(",")

- name: Joining elements of a list
  debug:
    var: my_simple_list|join(" | ")
```

ce qui nous donne :

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

## Transformer des dictionnaires en listes (et vice versa)

Les filtres `dict2items` et `itemstodict`, un peu plus complexe à implémenter, sont fréquemment utilisés, en particulier dans les boucles.

Notez qu'il est possible de spécifier le nom de la clé et de la valeur à utiliser dans la transformation.

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

## Travailler avec des listes

Il est possible de fusioner ou de filtrer des données à partir d'une ou plusieurs listes :

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

Pour garder uniquement l'intersection des deux listes (c'est-à-dire les éléments appartenant à la fois aux deux listes) :

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

Ou bien au contraire garder uniquement la différence (c'est-à-dire les éléments d'une liste n'appartenant pas à la deuxième) :

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

Si votre liste contient des valeurs multiples, vous pouvez aussi utiliser le filtre `unique` :

```
- name: Unique value in a list
  debug:
    var: my_simple_list | unique
```

## Transformation json/yaml

Vous pouvez avoir à importer des données json (à partir d'une API par exemple) ou bien exporter des données au format yaml ou json.

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

## Valeurs par défaut, variables en option, variables protégées

Vous serez rapidement confronté à des erreurs dans l'exécution de vos playbooks si vous ne fournissez pas de valeurs par défaut pour vos variables ou si vous ne les protégez pas.

La valeur d'une variable peut être remplacée par une autre si elle n'existe pas avec le filtre `default`:

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

Notez la présence de l'apostrophe `'` qui doit être protégée, par exemple, si vous utilisez le module `shell`:

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

Enfin une variable optionnelle dans un module peut être ignorée si elle n'existe pas avec le mot clé `omit` dans le filtre `default`, ce qui vous permettra d'éviter une erreur à l'exécution.

```
- name: Add a new user
  ansible.builtin.user:
    name: "{{ user_name }}"
    comment: "{{ user_comment | default(omit) }}"
```

## Associer une valeur en fonction d'une autre (`ternary`)

Parfois, vous devez utiliser une condition pour assigner une valeur à une variable, auquel cas il est courant de passer par une étape `set_fact`.

Ceci peut être évité en utilisant le filtre `ternary` :

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

## D'autres filtres

  * `{{ 10000 | random }}` : comme son nom l'indique, produit une valeur aléatoire.
  * `{{ my_simple_list | first }}` : extrait le premier élément de la liste.
  * `{{ my_simple_list | length }}` : donne la longueur (d'une liste ou d'une chaîne).
  * `{{ ip_list | ansible.netcommon.ipv4 }}` : n'affiche que les adresses IPv4. Without dwelling on this, if you need, there are many filters dedicated to the network.
  * `{{ user_password | password_hash('sha512') }}` : génère un mot de passe haché en sha512.
