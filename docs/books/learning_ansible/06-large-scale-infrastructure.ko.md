---
title: 대규모 인프라
---

# Ansible - 대규모 인프라

이 문서에서는 구성 관리 시스템을 확장하는 방법을 배웁니다.

****

**목적**: 이 문서에서는 다음을 수행하는 방법에 대해 알아볼 것 입니다:

:heavy_check_mark: 대규모 인프라를 위한 코드 구성;   
:heavy_check_mark: 구성 관리의 전체 또는 일부를 노드 그룹에 적용합니다.

:checkered_flag: **ansible**, **구성 관리**, **규모**

**지식**: :star: :star: :star:       
**복잡성**: :star: :star: :star: :star:

**소요 시간**: 30분

****

이전 문서에서 역할 형식으로 코드를 구성하는 방법과 업데이트 관리(패치 관리) 또는 코드 배포를 위해 일부 역할을 사용하는 방법을 살펴보았습니다.

구성 관리는 어떻습니까? Ansible을 사용하여 수십, 수백 또는 수천 개의 가상 머신 구성을 관리하는 방법은 무엇입니까?

클라우드의 등장으로 기존의 방식이 조금 바뀌었습니다. VM은 배포 시 구성됩니다. 해당 구성이 더 이상 규정을 준수하지 않으면 폐기되고 새 구성으로 교체됩니다.

이 문서에 제시된 구성 관리 시스템의 조직은 IT를 소비하는 두 가지 방법, 즉 집합의 "원샷" 사용 또는 정기적인 "재구성"에 대응합니다.

그러나 주의하십시오. Ansible을 사용하여 공원 규정 준수를 보장하려면 작업 습관을 바꿔야 합니다. 다음에 Ansible이 실행될 때 이러한 수정 사항을 덮어쓰지 않고 서비스 관리자의 구성을 수동으로 수정할 수 없습니다.

!!! 참고 사항

    우리가 아래에서 설정할 것은 Ansible이 선호하는 지형이 아닙니다. Puppet 또는 Salt와 같은 기술은 훨씬 더 잘할 것입니다. Ansible은 자동화의 스위스 군용 나이프이며 에이전트가 없으므로 성능의 차이를 설명합니다.

!!! 참고 사항

    자세한 내용은 [여기](https://docs.ansible.com/ansible/latest/user_guide/sample_setup.html)에서 확인할 수 있습니다.

## 변수 저장

가장 먼저 논의해야 할 것은 데이터와 Ansible 코드 간의 분리입니다.

코드가 커지고 복잡해짐에 따라 포함된 변수를 수정하는 것도 점점 더 복잡해집니다.

사이트 유지 관리를 위해 가장 중요한 것은 Ansible 코드에서 변수를 올바르게 분리하는 것입니다.

여기서는 아직 논의하지 않았지만 Ansible이 관리 노드 또는 해당 구성원 그룹의 인벤토리 이름에 따라 특정 폴더에서 찾은 변수를 자동으로 로드할 수 있음을 알아야 합니다.

Ansible 문서에서는 코드를 아래와 같이 구성할 것을 제안합니다.

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

대상 노드가 `group1`의 `hostname1`인 경우 `hostname1.yml` 및 `group1.yml` 파일에 포함된 변수 자동으로 로드됩니다. 모든 역할에 대한 모든 데이터를 같은 위치에 저장하는 좋은 방법입니다.

이러한 방식으로 서버의 인벤토리 파일이 서버의 ID 카드가 됩니다. 여기에는 서버의 기본 변수와 다른 모든 변수가 포함됩니다.

변수를 중앙 집중화하는 관점에서 역할에 변수 이름을 접두사로 붙여 구성하는 것이 필수적입니다. 예를 들어 역할의 이름을 사용합니다. 또한 사전보다는 플랫 변수 이름을 사용하는 것이 좋습니다.

예를 들어 `sshd_config` 파일의 `PermitRootLogin` 값을 변수로 만들려는 경우, 좋은 변수 이름이 될 수도 있는 `sshd.config.permitrootlogin` 대신에 `sshd_config_permitrootlogin`가 좋은 변수 이름이 될 수 있습니다.

## Ansible 태그 정보

Ansible 태그를 사용하면 코드에서 일부 작업을 실행하거나 건너뛸 수 있습니다.

!!! 참고 사항

    자세한 내용은 [여기](https://docs.ansible.com/ansible/latest/user_guide/playbooks_tags.html)에서 확인할 수 있습니다.

예를 들어 사용자 생성 작업을 수정해 보겠습니다.

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

이제 `ansible-playbook` 옵션 `--tags`를 사용하여 `users` 태그가 있는 작업만 재생할 수 있습니다.

```
ansible-playbook -i inventories/production/hosts --tags users site.yml
```

`--skip-tags` 옵션을 사용할 수도 있습니다.

## 디렉토리 레이아웃 정보

CMS(Content Management System - 콘텐츠 관리 시스템)의 적절한 기능에 필요한 파일 및 디렉토리 구성에 대한 제안에 대해 알아보겠습니다.

시작점은 `site.yml` 파일입니다. 이 파일은 필요한 경우 대상 노드에 필요한 역할만 포함하므로 CMS의 오케스트라 지휘자와 비슷합니다.

```
---
- name: "Config Management for {{ target }}"
  hosts: "{{ target }}"

  roles:

    - role: roles/functionality1

    - role: roles/functionality2
```

물론 이러한 역할은 `site.yml` 파일과 동일한 수준의 `roles` 디렉토리 아래에 생성되어야 합니다.

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

또한 기능을 비활성화할 가능성을 유지하고 싶습니다. 따라서 다음과 같은 조건과 기본값으로 역할을 포함합니다:

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

    컬렉션 내에서 역할을 자유롭게 개발할 수 있습니다.

## 테스트

플레이북을 시작하고 몇 가지 테스트를 실행해 보겠습니다.

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

인벤토리에서 대상 노드에 대한 `functionality2`를 활성화하고 플레이북을 다시 실행해 보겠습니다.

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

Ansible 설명서에 제공된 조언을 따르면 다음을 빠르게 얻을 수 있습니다.

* 많은 역할을 포함하는 경우에도 쉽게 유지 관리할 수 있는 소스 코드
* 부분적으로 또는 전체적으로 적용할 수 있는 비교적 빠르고 반복 가능한 규정 준수 시스템
* 사례 및 서버별로 조정할 수 있습니다.
* 정보 시스템의 세부 사항은 코드와 분리되어 쉽게 감사할 수 있으며 구성 관리의 인벤토리 파일에 중앙 집중화됩니다.
