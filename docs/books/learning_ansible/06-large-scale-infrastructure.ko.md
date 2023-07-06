---
title: 대규모 인프라
---

# Ansible - 대규모 인프라

이 문서에서는 구성 관리 시스템을 확장하는 방법을 배웁니다.

****

**목적**: 이 문서에서는 다음을 수행하는 방법에 대해 알아볼 것 입니다:

:heavy_check_mark: 대규모 인프라를 위한 코드 구성;   
:heavy_check_mark: 구성 관리의 전체 또는 일부를 노드 그룹에 적용합니다.

:checkered_flag: **ansible**, **구성 관리**, **확장**

**지식**: :star: :star: :star:       
**복잡성**: :star: :star: :star: :star:

**소요 시간**: 30분

****

이전 장에서 역할(role) 형태로 코드를 구성하는 방법과 업데이트 관리(패치 관리) 또는 코드 배포에 역할(role)을 사용하는 방법에 대해 알아보았습니다.

하지만 구성 관리는 어떻게 관리해야 할까요? 앤서블을 사용하여 수십, 수백 또는 수천 개의 가상 머신의 구성을 어떻게 관리할 수 있을까요?

클라우드의 등장으로 전통적인 방법이 약간 변경되었습니다. 가상 머신은 배포 시에 구성됩니다. 그 구성이 더 이상 일치하지 않으면 가상 머신은 파괴되고 새로운 것으로 대체됩니다.

이 장에서 제시하는 구성 관리 시스템의 구조는 IT를 소비하는 두 가지 방식에 대응합니다. "일회성" 사용 또는 서버 풀의 정기적인 "재구성"입니다.

그러나 주의해야 할 점은 앤서블을 사용하여 서버 풀의 일관성을 보장하려면 작업 습관을 변경해야 한다는 것입니다. 앤서블을 실행할 때 서비스 관리자의 구성을 수동으로 수정하는 것은 더 이상 가능하지 않습니다.

!!! 참고 사항

    아래에서 설정할 내용은 앤서블의 가장 선호하는 영역은 아닙니다. Puppet이나 Salt와 같은 기술이 훨씬 더 적합합니다. 앤서블은 자동화의 스위스 아미 나이프(Swiss army knife)이자 에이전트리스(Agentless)인 점이 성능상의 차이를 설명합니다.

!!! 참고 사항

    자세한 내용은 [여기](https://docs.ansible.com/ansible/latest/user_guide/sample_setup.html)에서 확인할 수 있습니다.

## 변수 저장

첫 번째로 논의해야 할 사항은 데이터와 앤서블 코드 사이의 분리입니다.

코드가 점점 커지고 복잡해지면 포함된 변수를 수정하는 것이더욱 어려워집니다.

사이트의 유지 보수를 보장하기 위해 가장 중요한 것은 변수와 앤서블 코드를 올바르게 분리하는 것입니다.

우리는 아직 이에 대해 논의하지 않았지만, 앤서블은 관리되는 노드의 인벤토리 이름이나 멤버 그룹에 따라 특정 폴더에서 발견하는 변수를 자동으로 로드할 수 있다는 것을 알아야 합니다.

앤서블 문서는 코드를 다음과 같이 구성하는 것을 제안합니다.

```
inventories/
   production/
      hosts               # inventory file for production servers
      group_vars/
         group1.yml       # here we assign variables to particular groups
         group2.yml
      host_vars/
         hostname1.yml    # here we assign variables to particular systems
         hostname2.yml
```

대상 노드가 `group1`의 `hostname1`인 경우 `hostname1.yml` 및 `group1.yml` 파일에 포함된 변수가 자동으로 로드됩니다. 이렇게 하면 모든 역할에 대한 모든 데이터를 동일한 위치에 저장할 수 있는 좋은 방법입니다.

이러한 방식으로 서버의 인벤토리 파일이 서버의 ID 카드가 됩니다. 이 방식으로 서버의 인벤토리 파일은 해당 서버의 기본 변수와 다른 변수를 모두 포함하게 됩니다.

변수의 중앙 집중화 관점에서는 역할 내에서 변수의 네이밍을 조직화하는 것이 매우 중요합니다. 예를 들어, 역할의 이름을 접두사로 사용하여 변수의 네이밍을 조직화하는 것이 좋습니다. 또한 딕셔너리보다는 평면 변수 이름을 사용하는 것이 권장됩니다.

예를 들어 `sshd_config` 파일의 `PermitRootLogin` 값을 변수로 만들려는 경우, 좋은 변수 이름이 될 수도 있는 `sshd.config.permitrootlogin` 대신에 `sshd_config_permitrootlogin`가 좋은 변수 이름이 될 수 있습니다.

## Ansible 태그 정보

Ansible 태그를 사용하면 코드에서 일부 작업을 실행하거나 건너뛸 수 있습니다.

!!! 참고 사항

    자세한 내용은 [여기](https://docs.ansible.com/ansible/latest/user_guide/playbooks_tags.html)에서 확인할 수 있습니다.

예를 들어, 사용자 생성 작업을 수정해보겠습니다.

```
- name: add users
  user:
    name: "{{ item }}"
    state: present
    groups: "users"
  loop:
     - antoine
     - patrick
     - steven
     - xavier
  tags: users
```

이제 `ansible-playbook` 옵션 `--tags`를 사용하여 `users` 태그가 지정된 작업만 실행할 수 있습니다.

```
ansible-playbook -i inventories/production/hosts --tags users site.yml
```

`--skip-tags` 옵션을 사용할 수도 있습니다.

## 디렉토리 레이아웃 정보

이제 CMS (Content Management System - 콘텐츠 관리 시스템)의 올바른 작동을 위해 필요한 파일과 디렉토리 구성을 제안해보겠습니다.

시작점은 `site.yml` 파일입니다. 이 파일은 CMS의 오케스트라 지휘자와 같은 역할을 합니다. 필요한 역할(role)만 대상 노드에 포함시킵니다.

```
---
- name: "Config Management for {{ target }}"
  hosts: "{{ target }}"

  roles:

    - role: roles/functionality1

    - role: roles/functionality2
```

물론 이러한 역할은 `roles` 디렉토리에 `site.yml` 파일과 동일한 수준에서 생성되어야 합니다.

`inventories/production/group_vars/all.yml`에 있는 파일에 저장할 수 있더라도 `vars/global_vars.yml` 내에서 전역 변수를 관리하고 싶습니다.

```
---
- name: "Config Management for {{ target }}"
  hosts: "{{ target }}"
  vars_files:
    - vars/global_vars.yml
  roles:

    - role: roles/functionality1

    - role: roles/functionality2
```

또한 기능을 비활성화하는 가능성을 유지하는 것을 좋아합니다. 따라서 다음과 같이 조건과 기본값을 가진 조건부로 역할을 포함시킵니다.

```
---
- name: "Config Management for {{ target }}"
  hosts: "{{ target }}"
  vars_files:
    - vars/global_vars.yml
  roles:

    - role: roles/functionality1
      when:
        - enable_functionality1|default(true)

    - role: roles/functionality2
      when:
        - enable_functionality2|default(false)
```

다음 태그를 사용하는 것을 잊지 마세요.


```
- name: "Config Management for {{ target }}"
  hosts: "{{ target }}"
  vars_files:
    - vars/global_vars.yml
  roles:

    - role: roles/functionality1
      when:
        - enable_functionality1|default(true)
      tags:
        - functionality1

    - role: roles/functionality2
      when:
        - enable_functionality2|default(false)
      tags:
        - functionality2
```

다음과 같은 결과를 얻어야 합니다.

```
$ tree cms
cms
├── inventories
│   └── production
│       ├── group_vars
│       │   └── plateform.yml
│       ├── hosts
│       └── host_vars
│           ├── client1.yml
│           └── client2.yml
├── roles
│   ├── functionality1
│   │   ├── defaults
│   │   │   └── main.yml
│   │   └── tasks
│   │       └── main.yml
│   └── functionality2
│       ├── defaults
│       │   └── main.yml
│       └── tasks
│           └── main.yml
├── site.yml
└── vars
    └── global_vars.yml
```

!!! 참고 사항

    역할을 컬렉션 내에서 개발할 수도 있습니다.

## 테스트

플레이북을 실행하고 몇 가지 테스트를 진행해보겠습니다.

```
$ ansible-playbook -i inventories/production/hosts -e "target=client1" site.yml

PLAY [Config Management for client1] ****************************************************************************

TASK [Gathering Facts] ******************************************************************************************
ok: [client1]

TASK [roles/functionality1 : Task in functionality 1] *********************************************************
ok: [client1] => {
    "msg": "You are in functionality 1"
}

TASK [roles/functionality2 : Task in functionality 2] *********************************************************
skipping: [client1]

PLAY RECAP ******************************************************************************************************
client1                    : ok=2    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0   
```

보시다시피 기본적으로 `functionality1` 역할의 작업만 수행됩니다.

인벤토리에서 대상 노드에 대한 `functionality2`를 활성화하고 플레이북을 다시 실행해보겠습니다.

```
$ vim inventories/production/host_vars/client1.yml
---
enable_functionality2: true
```


```
$ ansible-playbook -i inventories/production/hosts -e "target=client1" site.yml

PLAY [Config Management for client1] ****************************************************************************

TASK [Gathering Facts] ******************************************************************************************
ok: [client1]

TASK [roles/functionality1 : Task in functionality 1] *********************************************************
ok: [client1] => {
    "msg": "You are in functionality 1"
}

TASK [roles/functionality2 : Task in functionality 2] *********************************************************
ok: [client1] => {
    "msg": "You are in functionality 2"
}

PLAY RECAP ******************************************************************************************************
client1                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

`functionality2`만 적용해 보십시오.

```
$ ansible-playbook -i inventories/production/hosts -e "target=client1" --tags functionality2 site.yml

PLAY [Config Management for client1] ****************************************************************************

TASK [Gathering Facts] ******************************************************************************************
ok: [client1]

TASK [roles/functionality2 : Task in functionality 2] *********************************************************
ok: [client1] => {
    "msg": "You are in functionality 2"
}

PLAY RECAP ******************************************************************************************************
client1                    : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

전체 인벤토리에서 실행해 보겠습니다.

```
$ ansible-playbook -i inventories/production/hosts -e "target=plateform" site.yml

PLAY [Config Management for plateform] **************************************************************************

TASK [Gathering Facts] ******************************************************************************************
ok: [client1]
ok: [client2]

TASK [roles/functionality1 : Task in functionality 1] *********************************************************
ok: [client1] => {
    "msg": "You are in functionality 1"
}
ok: [client2] => {
    "msg": "You are in functionality 1"
}

TASK [roles/functionality2 : Task in functionality 2] *********************************************************
ok: [client1] => {
    "msg": "You are in functionality 2"
}
skipping: [client2]

PLAY RECAP ******************************************************************************************************
client1                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
client2                    : ok=2    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0   
```

보시다시피 `functionality2`는 `client1`에서만 재생됩니다.

## 장점

Ansible 문서에서 제시한 지침을 따르면 다음과 같은 이점을 얻을 수 있습니다:

* 많은 수의 역할이 포함된 소스 코드를 쉽게 유지할 수 있습니다.
* 상당히 빠르고 반복 가능한 규정 준수 시스템을 부분적으로 또는 전체적으로 적용할 수 있습니다.
* 사례 및 서버별로 조정할 수 있습니다.
* 정보 시스템의 세부 사항은 코드와 분리되어 쉽게 감사할 수 있으며 구성 관리의 인벤토리 파일에 중앙 집중화됩니다.
