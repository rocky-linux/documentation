---
title: 필터 작업
author: Antoine Le Morvan
contributors: Steven Spencer
---

# Ansible - 필터 작업

이 문서에서는 jinja 필터를 사용하여 데이터를 변환하는 방법을 배웁니다.

****

**목적**: 이 문서에서는 다음을 수행하는 방법에 대해 알아볼 것 입니다:

:heavy_check_mark: 데이터 구조를 사전 또는 목록으로 변환합니다.  
:heavy_check_mark: 변수를 변환합니다.

:checkered_flag: **ansible**, **jinja**, **필터**

**지식**: :star: :star: :star:       
**복잡성**: :star: :star: :star: :star:

**소요 시간**: 20분

****

우리는 이미 이전 문서에서 jinja 필터를 사용할 기회를 가졌습니다.

Python으로 작성된 이 필터를 사용하면 ansible 변수를 조작하고 변환할 수 있습니다.

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

    다음은 가장 자주 접하거나 필요로 하는 필터 목록입니다.
    다행히도 다른 많은 것들이 있습니다. 직접 작성할 수도 있습니다!

플레이북은 다음과 같이 재생됩니다.

```
ansible-playbook play-filter.yml
```

## 데이터 변환

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

정수를 문자열로 변환하는 것은 가능합니다:

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

`replace` 필터를 사용하면 문자를 다른 문자로 바꿀 수 있습니다.

여기에서는 공백을 제거하거나 단어를 대체합니다.

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

`split` 필터는 문자열을 문자에 따라 목록으로 분할합니다.

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

서로 다른 요소를 단일 문자열로 결합해야 하는 경우가 많습니다. 그런 다음 각 요소 사이에 삽입할 문자 또는 문자열을 지정할 수 있습니다.

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

변환에 사용할 키와 값의 이름을 지정할 수 있습니다.

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

하나 이상의 목록에서 데이터를 병합하거나 필터링할 수 있습니다.

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

2개 목록의 교차점만 유지하려면(2개 목록에 있는 값):

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

또는 반대로 차이만 유지합니다(두 번째 목록에 존재하지 않는 값).

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

목록에 고유하지 않은 값이 포함된 경우 `고유` 필터로 필터링할 수도 있습니다.

```
- name: Unique value in a list
  debug:
    var: my_simple_list | unique
```

## json/yaml 변환

예를 들어 API에서 json 데이터를 가져오거나 yaml 또는 json으로 데이터를 내보내야 할 수 있습니다.

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

변수에 대한 기본값을 제공하지 않거나 변수를 보호하지 않으면 플레이북 실행 시 오류에 빠르게 직면하게 됩니다.

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

마지막으로 모듈의 선택적 변수는 `default` 필터에 `omit` 키워드와 함께 존재하지 않는 경우 무시할 수 있습니다. 이렇게 하면 런타임 시 오류가 저장됩니다.

```
- name: Add a new user
  ansible.builtin.user:
    name: "{{ user_name }}"
    comment: "{{ user_comment | default(omit) }}"
```

## 다른 값에 따라 값 연결(`ternary`)

변수에 값을 할당하기 위해 조건을 사용해야 하는 경우가 있으며, 이 경우 `set_fact` 단계를 거치는 것이 일반적입니다.

이것은 `ternary` 필터를 사용하여 피할 수 있습니다.

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

  * `{{ 10000 | random }}`: 이름에서 알 수 있듯이 임의의 값을 제공합니다.
  * `{{ my_simple_list | first }}`: 목록의 첫 번째 요소를 추출합니다.
  * `{{ my_simple_list | length }}`: (목록 또는 문자열의) 길이를 제공합니다.
  * `{{ ip_list | ansible.netcommon.ipv4 }}`: v4 IP만 표시합니다. 이 뿐만 아니라, 필요한 경우 네트워크 전용 필터가 많이 있습니다.
  * `{{ user_password | password_hash('sha512') }}`: sha512에서 해시된 암호를 생성합니다.
