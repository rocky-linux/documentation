---
title: 필터 작업
author: Antoine Le Morvan
contributors: Steven Spencer
---

# Ansible - 필터 작업

이 문서에서는 jinja 필터를 사용하여 데이터를 변환하는 방법을 배웁니다.

****

**목적**: 이 문서에서는 다음을 수행하는 방법에 대해 알아볼 것 입니다:

:heavy_check_mark: 딕셔너리나 리스트와 같은 데이터 구조를 변환하는 방법 :heavy_check_mark: 변수를 변환하는 방법

:checkered_flag: **ansible**, **jinja**, **필터**

**지식**: :star: :star: :star:       
**복잡성**: :star: :star: :star: :star:

**소요 시간**: 20분

****

우리는 이미 이전 문서에서 jinja 필터를 사용하는 기회를 가졌습니다.

이러한 필터는 파이썬으로 작성되어 우리의 Ansible 변수를 조작하고 변환하는 데 사용됩니다.

!!! 참고 사항

    자세한 내용은 [여기](https://docs.ansible.com/ansible/latest/user_guide/playbooks_filters.html)에서 확인할 수 있습니다.

이 문서에서는 다음 플레이북을 사용하여 제시된 다양한 필터를 테스트합니다:

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

!!! 참고 사항

    다음은 가장 자주 만나게 되거나 필요한 필터의 비완전한 목록입니다.
    다행히도 다른 필터도 많이 있습니다. 심지어 직접 만들 수도 있습니다!

플레이북은 다음과 같이 실행됩니다.

```
ansible-playbook play-filter.yml
```

## 데이터 변환하기

데이터는 한 유형에서 다른 유형으로 변환될 수 있습니다.

데이터의 유형(Python 언어의 유형)을 알려면 `type_debug` 필터를 사용해야 합니다.

예시:

```
- name: Display the type of a variable
  debug:
    var: true_boolean|type_debug
```

이는 우리에게 다음을 제공합니다.

```
TASK [Display the type of a variable] ******************************************************************
ok: [localhost] => {
    "true_boolean|type_debug": "bool"
}
```

정수를 문자열로 변환할 수 있습니다.

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

문자열을 정수로 변환:

```
- name: Transforming a variable type
  debug:
    var: zero_string|int
```

또는 boolean의 변수:

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

문자열은 대문자 또는 소문자로 변환할 수 있습니다.

```
- name: Lowercase a string of characters
  debug:
    var: whatever | lower

- name: Upercase a string of characters
  debug:
    var: whatever | upper
```

이는 우리에게 다음을 제공합니다.

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

`replace` 필터를 사용하면 문자를 다른 문자로 대체할 수 있습니다.

여기에서는 공백을 제거하거나 단어를 대체하는 예제입니다:

```
- name: Replace a character in a string
  debug:
    var: whatever | replace(" ", "")

- name: Replace a word in a string
  debug:
    var: whatever | replace("false", "true")
```

이는 우리에게 다음을 제공합니다.

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

`split` 필터는 문자를 기준으로 문자열을 리스트로 분리합니다:

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

## 리스트의 구성 요소 결합

리스트의 요소를 결합하는 방법에 대해 설명합니다. 각 요소 사이에 삽입할 문자 또는 문자열을 지정할 수 있습니다.

```
- name: Joining elements of a list
  debug:
    var: my_simple_list|join(",")

- name: Joining elements of a list
  debug:
    var: my_simple_list|join(" | ")
```

이는 우리에게 다음을 제공합니다.

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

## 딕셔너리를 리스트로 변환(또는 그 반대로)

필터 `dict2items` 및 `itemstodict`는 구현하기가 조금 더 복잡합니다.

변환 과정에서 사용할 키와 값을 지정할 수 있습니다.

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

## 리스트 작업

하나 이상의 리스트에서 데이터를 병합하거나 필터링할 수 있습니다.

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

두 리스트의 교집합만 유지하려면 (두 리스트에 모두 있는 값):

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

또는 반대로 차이점만 유지하려면 (두 번째 리스트에 존재하지 않는 값):

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

리스트에 중복되는 값이 포함되어 있는 경우, `unique` 필터를 사용하여 중복 값을 필터링할 수도 있습니다.

```
- name: Unique value in a list
  debug:
    var: my_simple_list | unique
```

## json/yaml 변환

API에서 JSON 데이터를 가져오거나 데이터를 YAML 또는 JSON으로 내보내야 할 수도 있습니다.

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

## 기본값, 선택적 변수, 변수 보호

플레이북 실행 중에 변수에 기본값을 제공하지 않거나 보호하지 않으면 빠른 시간 내에 오류에 직면하게 됩니다.

변수 값은 `default` 필터와 함께 존재하지 않는 경우 다른 값으로 대체될 수 있습니다.

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

예를 들어 `shell` 모듈을 사용하는 경우 보호되어야 하는 아포스트로피 `'`가 있음에 유의하십시오.

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

마지막으로 모듈의 선택적 변수는 `default` 필터에 `omit` 키워드를 사용하여 해당 변수가 존재하지 않는 경우 무시될 수 있으며, 이는 런타임 오류를 방지해줍니다.

```
- name: Add a new user
  ansible.builtin.user:
    name: "{{ user_name }}"
    comment: "{{ user_comment | default(omit) }}"
```

## 다른 값에 따라 값 연결(`ternary`)

가끔 조건에 따라 변수에 값을 할당해야 할 때가 있는데, 이 경우 `set_fact` 단계를 거치는 것이 일반적입니다.

`ternary` 필터를 사용하여 이를 피할 수 있습니다.

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

## 기타 필터

  * `{{ 10000 | random }}`: 이름에서 알 수 있듯이 임의의 값을 반환합니다.
  * `{{ my_simple_list | first }}`: 리스트의 첫 번째 요소를 추출합니다.
  * `{{ my_simple_list | length }}`: 길이를 반환합니다 (리스트 또는 문자열).
  * `{{ ip_list | ansible.netcommon.ipv4 }}`: v4 IP만 표시합니다. 자세히 설명하지 않겠지만, 필요하다면 네트워크에 관련된 많은 필터가 있습니다.
  * `{{ user_password | password_hash('sha512') }}`: sha512로 해시된 암호를 생성합니다.
