---
title: Lavorare Con I Filtri
author: Antoine Le Morvan
contributors: Steven Spencer, Franco Colussi
---

# Ansible - Lavorare con filtri

In questo capitolo imparerai come trasformare i dati con i filtri jinja.

****

**Obiettivi**: In questo capitolo imparerai come:

:heavy_check_mark: Trasformare le strutture dati come dizionari o liste;  
:heavy_check_mark: Trasformare variabili.

:checkered_flag: **ansible**, **jinja**, **filtri**

**Conoscenza**: :star: :star: :star:  
**Complessità**: :star: :star: :star: :star:

**Tempo di lettura**: 20 minuti

****

Abbiamo già avuto la possibilità, durante i capitoli precedenti, di utilizzare i filtri jinja.

Questi filtri, scritti in python, ci permettono di manipolare e trasformare le nostre variabili ansible.

!!! Note "Nota"

    Maggiori informazioni possono essere [trovate qui](https://docs.ansible.com/ansible/latest/user_guide/playbooks_filters.html).

In tutto questo capitolo, useremo il seguente playbook per testare i diversi filtri presentati:

```bash
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

!!! Note "Nota"

    Di seguito è riportato un elenco non esaustivo di filtri che si hanno più probabilità di incontrare o necessitare.
    Fortunatamente, ce ne sono molti altri. Potresti anche scrivere il tuo!

Il playbook sarà riprodotto come segue:

```bash
ansible-playbook play-filter.yml
```

## Conversione dei dati

I dati possono essere convertiti da un tipo all'altro.

Per conoscere il tipo di dati (il tipo nel linguaggio python), è necessario utilizzare il filtro `type_debug`.

Esempio:

```bash
- name: Display the type of a variable
  debug:
    var: true_boolean|type_debug
```

che ci fornisce:

```bash
TASK [Display the type of a variable] ******************************************************************
ok: [localhost] => {
    "true_boolean|type_debug": "bool"
}
```

È possibile trasformare un intero in una stringa:

```bash
- name: Transforming a variable type
  debug:
    var: zero|string
```

```bash
TASK [Transforming a variable type] ***************************************************************
ok: [localhost] => {
    "zero|string": "0"
}
```

Trasforma una stringa in un intero:

```bash
- name: Transforming a variable type
  debug:
    var: zero_string|int
```

oppure una variabile in un booleano:

```bash
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

Una stringa di caratteri può essere trasformata in maiuscolo o minuscolo:

```bash
- name: Lowercase a string of characters
  debug:
    var: whatever | lower

- name: Upercase a string of characters
  debug:
    var: whatever | upper
```

che ci fornisce:

```bash
TASK [Lowercase a string of characters] *****************************************************
ok: [localhost] => {
    "whatever | lower": "it's false!"
}

TASK [Upercase a string of characters] *****************************************************
ok: [localhost] => {
    "whatever | upper": "IT'S FALSE!"
}
```

Il filtro `replace` consente di sostituire i caratteri con altri.

Qui rimuoviamo gli spazi o addirittura sostituiamo una parola:

```bash
- name: Replace a character in a string
  debug:
    var: whatever | replace(" ", "")

- name: Replace a word in a string
  debug:
    var: whatever | replace("false", "true")
```

che ci fornisce:

```bash
TASK [Replace a character in a string] *****************************************************
ok: [localhost] => {
    "whatever | replace(\" \", \"\")": "It'sfalse!"
}

TASK [Replace a word in a string] *****************************************************
ok: [localhost] => {
    "whatever | replace(\"false\", \"true\")": "It's true !"
}
```

Il filtro `split` divide una stringa in una lista in base a un carattere:

```bash
- name: Cutting a string of characters
  debug:
    var: whatever | split(" ", "")
```

```bash
TASK [Cutting a string of characters] *****************************************************
ok: [localhost] => {
    "whatever | split(\" \")": [
        "It's",
        "false!"
    ]
}
```

## Unire gli elementi di una lista

È frequente dover unire i diversi elementi in una singola stringa. Possiamo quindi specificare un carattere o una stringa da inserire tra ogni elemento.

```bash
- name: Joining elements of a list
  debug:
    var: my_simple_list|join(",")

- name: Joining elements of a list
  debug:
    var: my_simple_list|join(" | ")
```

che ci fornisce:

```bash
TASK [Joining elements of a list] *****************************************************************
ok: [localhost] => {
    "my_simple_list|join(\",\")": "value_list_1,value_list_2,value_list_3"
}

TASK [Joining elements of a list] *****************************************************************
ok: [localhost] => {
    "my_simple_list|join(\" | \")": "value_list_1 | value_list_2 | value_list_3"
}

```

## Trasformare dizionari in liste (e viceversa)

I filtri `dict2items` and `itemstodict`, un po 'più complessi da implementare, sono frequentemente utilizzati, soprattutto nei cicli.

Si noti che è possibile specificare il nome della chiave e del valore da usare nella trasformazione.

```bash
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

```bash
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

## Lavorare con liste

È possibile unire o filtrare i dati da una o più liste:

```bash
- name: Merger of two lists
  debug:
    var: my_simple_list | union(my_simple_list_2)
```

```bash
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

Per mantenere solo l'intersezione dei 2 elenchi (i valori presenti nelle 2 liste):

```bash
- name: Merger of two lists
  debug:
    var: my_simple_list | intersect(my_simple_list_2)
```

```bash
TASK [Merger of two lists] *******************************************************************************
ok: [localhost] => {
    "my_simple_list | intersect(my_simple_list_2)": [
        "value_list_3"
    ]
}
```

O al contrario mantenere solo la differenza (i valori che non esistono nella seconda lista):

```bash
- name: Merger of two lists
  debug:
    var: my_simple_list | difference(my_simple_list_2)
```

```bash
TASK [Merger of two lists] *******************************************************************************
ok: [localhost] => {
    "my_simple_list | difference(my_simple_list_2)": [
        "value_list_1",
        "value_list_2",
    ]
}
```

Se la tua lista contiene valori non univoci, è anche possibile filtrarli con il filtro `unique`.

```bash
- name: Unique value in a list
  debug:
    var: my_simple_list | unique
```

## Trasformazione json/yaml

Potrebbe essere necessario importare i dati json (da un'API per esempio) o esportare i dati in yaml o json.

```bash
- name: Display a variable in yaml
  debug:
    var: my_list | to_nice_yaml(indent=4)

- name: Display a variable in json
  debug:
    var: my_list | to_nice_json(indent=4)
```

```bash
TASK [Display a variable in yaml] ********************************************************************
ok: [localhost] => {
    "my_list | to_nice_yaml(indent=4)": "-   element: element1\n    value: value1\n-   element: element2\n    value: value2\n"
}

TASK [Display a variable in json] ********************************************************************
ok: [localhost] => {
    "my_list | to_nice_json(indent=4)": "[\n    {\n        \"element\": \"element1\",\n        \"value\": \"value1\"\n    },\n    {\n        \"element\": \"element2\",\n        \"value\": \"value2\"\n    }\n]"
}
```

## Valori predefiniti, variabili opzionali, proteggere le variabili

Se non fornisci valori predefiniti per le tue variabili, ti troverai rapidamente di fronte a errori nell'esecuzione dei tuoi playbook, o se non li proteggi.

Il valore di una variabile può essere sostituito con un'altra se non esiste con il filtro `default`:

```bash
- name: Default value
  debug:
    var: variablethatdoesnotexists | default(whatever)
```

```bash
TASK [Default value] ********************************************************************************
ok: [localhost] => {
    "variablethatdoesnotexists | default(whatever)": "It's false!"
}
```

Nota la presenza dell'apostrofo `'` che dovrebbe essere protetto, per esempio, se usi il modulo `shell`:

```bash
- name: Default value
  debug:
    var: variablethatdoesnotexists | default(whatever| quote)
```

```bash
TASK [Default value] ********************************************************************************
ok: [localhost] => {
    "variablethatdoesnotexists | default(whatever|quote)": "'It'\"'\"'s false!'"
}
```

Infine una variabile facoltativa in un modulo può essere ignorata se non esiste con la parola chiave `omit` nel filtro `default`, che ti salverà da un errore al runtime.

```bash
- name: Add a new user
  ansible.builtin.user:
    name: "{{ user_name }}"
    comment: "{{ user_comment | default(omit) }}"
```

## Associa un valore in base ad un altro (`ternary`)

A volte è necessario utilizzare una condizione per assegnare un valore a una variabile, in questo caso è comune passare attraverso un passaggio `set_fact`.

Questo può essere evitato utilizzando il filtro `ternary`:

```bash
- name: Default value
  debug:
    var: (user_name == 'antoine') | ternary('admin', 'normal_user')
```

```bash
TASK [Default value] ********************************************************************************
ok: [localhost] => {
    "(user_name == 'antoine') | ternary('admin', 'normal_user')": "admin"
}
```

## Altri filtri

* `{{ 10000 | random }}`: come indica il suo nome, dà un valore casuale.
* `{{ my_simple_list | first }}`: estrae il primo elemento della lista.
* `{{ my_simple_list | length }}`: dà la lunghezza (di una lista o di una stringa).
* `{{ ip_list | ansible.netcommon.ipv4 }}`: visualizza solo gli IP v4. Senza soffermarsi su questo, se necessario, ci sono molti filtri dedicati alla rete.
* `{{ user_password | password_hash('sha512') }}`: genera una password hash in sha512.
