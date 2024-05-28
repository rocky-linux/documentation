---
title: Робота з фільтрами
author: Antoine Le Morvan
contributors: Steven Spencer, Ganna Zhyrnova
---

# Ansible - Робота з фільтрами

У цьому розділі ви дізнаєтеся, як перетворювати дані за допомогою фільтрів jinja.

****

**Цілі**: В цьому розділі ви дізнаєтеся про:

:heavy_check_mark: Перетворення структур даних як словників або списків;  
:heavy_check_mark: Перетворення змінних.

:checkered_flag: **ansible**, **jinja**, **filters**

**Знання**: :star: :star: :star:  
**Складність**: :star: :star: :star: :star:

**Час читання**: 20 хвилин

****

У попередніх розділах ми вже мали можливість використовувати фільтри jinja.

Ці фільтри, написані на Python, дозволяють нам маніпулювати та трансформувати наші змінні ansible.

!!! Примітка

    Більше інформації можна [знайти тут](https://docs.ansible.com/ansible/latest/user_guide/playbooks_filters.html).

У цьому розділі ми будемо використовувати наступний playbook, щоб перевірити різні представлені фільтри:

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

!!! Примітка

    Нижче наведено неповний список фільтрів, з якими ви, швидше за все, зіткнетеся.
    На щастя, є багато інших. Ви навіть можете написати свій!

Playbook відбуватиметься таким чином:

```bash
ansible-playbook play-filter.yml
```

## Перетворення даних

Дані можна конвертувати з одного типу в інший.

Щоб дізнатися тип даних (тип на мові python), вам потрібно скористатися фільтром `type_debug`.

Приклад:

```bash
- name: Display the type of a variable
  debug:
    var: true_boolean|type_debug
```

що дає нам:

```bash
TASK [Display the type of a variable] ******************************************************************
ok: [localhost] => {
    "true_boolean|type_debug": "bool"
}
```

Ціле число можна перетворити на рядок:

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

Перетворення рядка в ціле число:

```bash
- name: Transforming a variable type
  debug:
    var: zero_string|int
```

або змінну в логічне значення:

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

Рядок символів можна перетворити на верхній або нижній регістр:

```bash
- name: Lowercase a string of characters
  debug:
    var: whatever | lower

- name: Upercase a string of characters
  debug:
    var: whatever | upper
```

що дає нам:

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

Фільтр `replace` дозволяє замінювати символи іншими.

Тут ми видаляємо пробіли або навіть замінюємо слово:

```bash
- name: Replace a character in a string
  debug:
    var: whatever | replace(" ", "")

- name: Replace a word in a string
  debug:
    var: whatever | replace("false", "true")
```

що дає нам:

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

Фільтр `split` розбиває рядок на список на основі символу:

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

## Об’єднання елементів списку

Часто доводиться об’єднувати різні елементи в один рядок. Потім ми можемо вказати символ або рядок для вставки між кожним елементом.

```bash
- name: Joining elements of a list
  debug:
    var: my_simple_list|join(",")

- name: Joining elements of a list
  debug:
    var: my_simple_list|join(" | ")
```

що дає нам:

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

## Перетворення словників у списки (і навпаки)

Фільтри `dict2items` і `itemstodict`, дещо складніші для реалізації, часто використовуються, особливо в циклах.

Зауважте, що можна вказати назву ключа та значення для використання в перетворенні.

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

## Робота зі списками

Можна об’єднати або відфільтрувати дані з одного чи кількох списків:

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

Щоб зберегти лише перетин 2 списків (значення, присутні у 2 списках):

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

Або навпаки залишити лише різницю (значення, яких немає у другому списку):

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

Якщо ваш список містить неунікальні значення, їх також можна відфільтрувати за допомогою фільтра `unique`.

```bash
- name: Unique value in a list
  debug:
    var: my_simple_list | unique
```

## Перетворення json/yaml

Можливо, вам доведеться імпортувати дані json (наприклад, з API) або експортувати дані в yaml або json.

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

## Значення за замовчуванням, додаткові змінні, захистити змінні

Ви швидко зіткнетеся з помилками під час виконання ваших ігор, якщо ви не надасте значення за замовчуванням для ваших змінних або якщо ви не захистите їх.

Значення змінної можна замінити на інше, якщо воно не існує за допомогою фільтра `default`:

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

Зверніть увагу на наявність апострофа `'`, який слід захистити, наприклад, якщо ви використовуєте модуль `shell`:

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

Нарешті, необов’язкову змінну в модулі можна проігнорувати, якщо вона не існує з ключовим словом `omit` у фільтрі `default`, що позбавить вас від помилки під час виконання.

```bash
- name: Add a new user
  ansible.builtin.user:
    name: "{{ user_name }}"
    comment: "{{ user_comment | default(omit) }}"
```

## Прив'язати значення відповідно до іншого (`ternary`)

Іноді вам потрібно використовувати умову, щоб призначити значення змінній, і в цьому випадку зазвичай потрібно виконати крок `set_fact`.

Цього можна уникнути за допомогою фільтра `ternary`:

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

## Деякі інші фільтри

* `{{ 10000 | random }}`: як вказує його назва, дає випадкове значення.
* `{{ my_simple_list | first }}`: витягує перший елемент списку.
* `{{ my_simple_list | length }}`: дає довжину (списку або рядка).
* `{{ ip_list | ansible.netcommon.ipv4 }}`: відображає лише v4 IP. Не зупиняючись на цьому, якщо вам потрібно, є багато фільтрів, присвячених мережі.
* `{{ user_password | password_hash('sha512') }}`: генерує хешований пароль у sha512.
