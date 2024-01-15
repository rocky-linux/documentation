---
title: Arbeiten mit Filtern
author: Antoine Le Morvan
contributors: Steven Spencer, Ganna Zhyrnova
---

# Ansible - Arbeiten mit Filtern

In diesem Kapitel lernen Sie, wie Sie Daten mit jinja-Filtern umwandeln.

****

**Ziele**: In diesem Kapitel werden Sie Folgendes lernen:

:heavy_check_mark: Umwandlung von Datenstrukturen als Dictionary oder Listen;  
:heavy_check_mark: Umwandlung von Variablen.

:checkered_flag: **Ansible**, **jinja**, **Filters**

**Vorkenntnisse**: :star: :star: :star:       
**Komplexität**: :star: :star: :star: :star:

**Lesezeit**: 23 Minuten

****

Wir hatten bereits die Gelegenheit, in den vorhergehenden Kapiteln die jinja-Filter zu verwenden.

Mit diesen in Python geschriebenen Filtern können wir unsere Ansible-Variablen bearbeiten und transformieren.

!!! note "Anmerkung"

    Weitere Informationen finden Sie [hier](https://docs.ansible.com/ansible/latest/user_guide/playbooks_filters.html).

Während dieses Kapitels werden wir das folgende Playbook verwenden, um die verschiedenen vorgestellten Filter zu testen:

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

!!! note "Anmerkung"

    Das folgende ist eine exemplarische Liste von Filtern, die Sie am ehesten begegnen oder benötigen werden.
    Zum Glück gibt es viele andere. Sie könnten sogar Ihre eigene implementieren!

Das Playbook wird wie folgt abgespielt:

```
ansible-playbook play-filter.yml
```

## Daten-Konvertierung

Daten können von einem Typ in einen anderen umgewandelt werden.

Um den Typ der Daten (der Typ in der Python-Sprache) zu erfahren, müssen Sie den `type_debug` Filter verwenden.

Beispiel:

```
- name: Display the type of a variable
  debug:
    var: true_boolean|type_debug
```

dies ergibt:

```
TASK [Display the type of a variable] ******************************************************************
ok: [localhost] => {
    "true_boolean|type_debug": "bool"
}
```

Es ist möglich, einen Integer in einen String umzuwandeln:

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

Einen String in eine Ganzzahl umwandeln:

```
- name: Transforming a variable type
  debug:
    var: zero_string|int
```

oder eine Variable in Boolean:

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

Ein String kann in Groß- oder Kleinschreibung umgewandelt werden:

```
- name: Lowercase a string of characters
  debug:
    var: whatever | lower

- name: Upercase a string of characters
  debug:
    var: whatever | upper
```

dies ergibt:

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

Der `replace`-Filter erlaubt es Ihnen, Zeichen durch andere zu ersetzen.

Hier entfernen wir Leerzeichen oder ersetzen sogar ein Wort:

```
- name: Replace a character in a string
  debug:
    var: whatever | replace(" ", "")

- name: Replace a word in a string
  debug:
    var: whatever | replace("false", "true")
```

dies ergibt:

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

Der `split`-Filter teilt einen String in eine Liste basierend auf einem Zeichen auf:

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

## Die Elemente einer Liste zusammensetzen

Häufig müssen die verschiedenen Elemente einer Liste in einem einzigen String zusammengefasst werden. Wir können dann ein Zeichen oder einen String angeben, der zwischen den Elementen eingefügt werden soll.

```
- name: Joining elements of a list
  debug:
    var: my_simple_list|join(",")

- name: Joining elements of a list
  debug:
    var: my_simple_list|join(" | ")
```

dies ergibt:

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

## Umwandlung von Dictionaries in Listen (und umgekehrt)

Die Filter `dict2items` und `itemstodict`, etwas komplexer zu implementieren, werden häufig verwendet, besonders in Schleifen.

Beachten Sie, dass es möglich ist, den Namen des Schlüssels und des Wertes für die Transformation anzugeben.

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

## Mit Listen arbeiten

Es ist möglich, Daten aus einer oder mehreren Listen zusammenzuführen oder zu filtern:

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

Um nur den Durchschnitt der beiden Listen zu behalten (die Werte sind in beiden Listen vorhanden):

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

Oder im Gegenteil nur die Differenz (die Werte, die nicht in der zweiten Liste vorhanden sind):

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

Wenn Ihre Liste nicht eindeutige Werte enthält, ist es auch möglich, diese mit `unique` zu filtern.

```
- name: Unique value in a list
  debug:
    var: my_simple_list | unique
```

## Transformation json/yaml

Möglicherweise müssen Sie json-Daten importieren (zum Beispiel von einer API), oder Daten in yaml oder json exportieren.

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

## Default-Werte, optionale Variablen und Variablen schützen

Sie werden schnell mit Fehlern bei der Ausführung Ihrer Playbooks konfrontiert, wenn Sie keine Default-Werte für Ihre Variablen angeben oder wenn Sie sie nicht schützen.

Der Wert einer Variable kann durch eine andere ersetzt werden, wenn sie nicht mit dem Filter  `default` existiert:

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

Beachten Sie das Vorhandensein der Apostrophe `'` die geschützt werden sollte, zum Beispiel, wenn Sie das `shell` Modul verwenden:

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

Schließlich kann eine optionale Variable in einem Modul ignoriert werden, wenn sie nicht mit dem Schlüsselwort `omit` im Filter `default` vorhanden ist, was Ihnen einen Fehler bei der Laufzeit erspart.

```
- name: Add a new user
  ansible.builtin.user:
    name: "{{ user_name }}"
    comment: "{{ user_comment | default(omit) }}"
```

## Einen Wert mit einem anderen (`ternary`) verbinden

Manchmal müssen Sie eine Bedingung verwenden, um einer Variable einen Wert zuzuweisen, in diesem Fall ist es üblich, einen `set_fact` Schritt zu durchlaufen.

Dies kann durch Verwendung des `ternary` Filter vermieden werden:

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

## Einige andere Filter

  * `{{ 10000 | random }}`: Wie der Name andeutet, gibt einen zufälligen Wert an.
  * `{{ my_simple_list | first }}`: Extrahiert das erste Element der Liste.
  * `{{ my_simple_list | length }}`: gibt die Länge (einer Liste oder einer Zeichenkette) an.
  * `{{ ip_list | ansible.netcommon.ipv4 }}`: zeigt nur IPv4-Adressen an. Ohne auf das Thema einzugehen, gibt es bei Bedarf viele Filter, die dem Netzwerk gewidmet sind.
  * `{{ user_password | password_hash('sha512') }}`: generiert ein Passwort in sha512.
