---
title: Ansible Galaxy
---

# Ansible Galaxy: 컬렉션 및 역할

이 문서에서는 Ansible 역할 및 컬렉션을 사용, 설치 및 관리하는 방법을 배웁니다.

****

**목적**: 이 문서에서는 다음을 수행하는 방법에 대해 알아볼 것 입니다:

:heavy_check_mark: 컬렉션을 설치하고 관리하는 방법       
:heavy_check_mark: 역할 설치 및 관리하는 방법

:checkered_flag: **ansible**, **ansible-galaxy**, **역할**, **컬렉션**

**지식**: :star: :star:      
**복잡성**: :star: :star: :star:

**소요 시간**: 40분

****

[Ansible Galaxy](https://galaxy.ansible.com)는 Ansible 커뮤니티의 Ansible 역할 및 컬렉션을 제공합니다.

제공된 요소는 플레이북에서 참조할 수 있으며 즉시 사용할 수 있습니다.

## `ansible-galaxy` 명령

`ansible-galaxy` 명령은 [galaxy.ansible.com](http://galaxy.ansible.com)을 사용하여 역할 및 컬렉션을 관리합니다.

* 역할을 관리하려면:

```
ansible-galaxy role [import|init|install|login|remove|...]
```

| 하위 명령어    | 기능                                    |
| --------- | ------------------------------------- |
| `install` | 역할을 설치합니다.                            |
| `remove`  | 하나 이상의 역할을 제거합니다.                     |
| `list`    | 설치된 역할의 이름과 버전을 표시합니다.                |
| `info`    | 역할에 대한 정보를 표시합니다.                     |
| `init`    | 새로운 역할의 뼈대를 생성합니다.                    |
| `import`  | Galaxy 웹 사이트에서 역할을 가져옵니다. 로그인이 필요합니다. |

* 컬렉션을 관리하려면:

```
ansible-galaxy collection [import|init|install|login|remove|...]
```

| 하위 명령어    | 관찰                      |
| --------- | ----------------------- |
| `init`    | 새 컬렉션의 뼈대를 생성합니다.       |
| `install` | 컬렉션을 설치합니다.             |
| `list`    | 설치된 컬렉션의 이름과 버전을 표시합니다. |

## Ansible 역할

Ansible 역할은 플레이북의 재사용성을 촉진하는 단위입니다.

!!! 참고 사항

    자세한 내용은 [여기](https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_roles.html)에서 확인할 수 있습니다.

### 유용한 역할 설치

역할을 사용하는 장점을 강조하기 위해 `alemorvan/patchmanagement` 역할을 사용해 보겠습니다. 이 역할은 몇 줄의 코드로 업데이트 프로세스 중에 수행할 수 있는 많은 작업(예: 업데이트 전 또는 업데이트 후)을 수행할 수 있도록 해줍니다.

[여기](https://github.com/alemorvan/patchmanagement)에서 역할의 github 저장소에서 코드를 확인할 수 있습니다.

* 역할을 설치합니다. 이 작업에는 한 줄의 명령어만 필요합니다.

```
ansible-galaxy role install alemorvan.patchmanagement
```

* 역할을 포함하는 플레이북을 작성합니다.

```
- name: Start a Patch Management
  hosts: ansible_clients
  vars:
    pm_before_update_tasks_file: custom_tasks/pm_before_update_tasks_file.yml
    pm_after_update_tasks_file: custom_tasks/pm_after_update_tasks_file.yml

  tasks:
    - name: "Include patchmanagement"
      include_role:
        name: "alemorvan.patchmanagement"
```

이 역할을 사용하여 인벤토리 전체 또는 대상 노드에 대해 자체 작업을 추가할 수 있습니다.

업데이트 프로세스 전후에 실행할 작업을 생성해 보겠습니다.

* `custom_tasks` 폴더를 생성합니다.

```
mkdir custom_tasks
```

* `custom_tasks/pm_before_update_tasks_file.yml`파일을 생성합니다 (파일의 이름과 내용을 변경해도 좋습니다).

```
---
- name: sample task before the update process
  debug:
    msg: "This is a sample tasks, feel free to add your own test task"
```

* `custom_tasks/pm_after_update_tasks_file.yml`파일을 생성합니다 (파일의 이름과 내용을 변경해도 좋습니다).

```
---
- name: sample task after the update process
  debug:
    msg: "This is a sample tasks, feel free to add your own test task"
```

그리고 첫 번째 패치 관리를 시작합니다.

```
ansible-playbook patchmanagement.yml

PLAY [Start a Patch Management] *************************************************************************

TASK [Gathering Facts] **********************************************************************************
ok: [192.168.1.11]

TASK [Include patchmanagement] **************************************************************************

TASK [alemorvan.patchmanagement : MAIN | Linux Patch Management Job] ************************************
ok: [192.168.1.11] => {
    "msg": "Start 192 patch management"
}

...

TASK [alemorvan.patchmanagement : sample task before the update process] ********************************
ok: [192.168.1.11] => {
    "msg": "This is a sample tasks, feel free to add your own test task"
}

...

TASK [alemorvan.patchmanagement : MAIN | We can now patch] **********************************************
included: /home/ansible/.ansible/roles/alemorvan.patchmanagement/tasks/patch.yml for 192.168.1.11

TASK [alemorvan.patchmanagement : PATCH | Tasks depends on distribution] ********************************
ok: [192.168.1.11] => {
    "ansible_distribution": "Rocky"
}

TASK [alemorvan.patchmanagement : PATCH | Include tasks for CentOS & RedHat tasks] **********************
included: /home/ansible/.ansible/roles/alemorvan.patchmanagement/tasks/linux_tasks/redhat_centos.yml for 192.168.1.11

TASK [alemorvan.patchmanagement : RHEL CENTOS | yum clean all] ******************************************
changed: [192.168.1.11]

TASK [alemorvan.patchmanagement : RHEL CENTOS | Ensure yum-utils is installed] **************************
ok: [192.168.1.11]

TASK [alemorvan.patchmanagement : RHEL CENTOS | Remove old kernels] *************************************
skipping: [192.168.1.11]

TASK [alemorvan.patchmanagement : RHEL CENTOS | Update rpm package with yum] ****************************
ok: [192.168.1.11]

TASK [alemorvan.patchmanagement : PATCH | Inlude tasks for Debian & Ubuntu tasks] ***********************
skipping: [192.168.1.11]

TASK [alemorvan.patchmanagement : MAIN | We can now reboot] *********************************************
included: /home/ansible/.ansible/roles/alemorvan.patchmanagement/tasks/reboot.yml for 192.168.1.11

TASK [alemorvan.patchmanagement : REBOOT | Reboot triggered] ********************************************
ok: [192.168.1.11]

TASK [alemorvan.patchmanagement : REBOOT | Ensure we are not in rescue mode] ****************************
ok: [192.168.1.11]

...

TASK [alemorvan.patchmanagement : FACTS | Insert fact file] *********************************************
ok: [192.168.1.11]

TASK [alemorvan.patchmanagement : FACTS | Save date of last PM] *****************************************
ok: [192.168.1.11]

...

TASK [alemorvan.patchmanagement : sample task after the update process] *********************************
ok: [192.168.1.11] => {
    "msg": "This is a sample tasks, feel free to add your own test task"
}

PLAY RECAP **********************************************************************************************
192.168.1.11               : ok=31   changed=1    unreachable=0    failed=0    skipped=4    rescued=0    ignored=0  
```

이렇게 복잡한 프로세스인데 꽤 간단하죠?

이것은 커뮤니티에서 제공하는 역할을 사용하여 수행할 수 있는 예시 중 하나에 불과합니다. 유용할 수 있는 역할을 찾기 위해 [galaxy.ansible.com](https://galaxy.ansible.com/)을 확인해 보세요!

또한 필요에 따라 자체 역할을 만들어 인터넷에 공개할 수도 있습니다. 이는 다음 문서에서 간략하게 다룰 내용입니다.

### 역할 개발 소개

사용자 정의 역할 개발의 시작점으로 사용될 수 있는 역할 스켈레톤은 `ansible-galaxy` 명령으로 생성할 수 있습니다.

```
$ ansible-galaxy role init rocky8
- Role rocky8 was created successfully
```

이 명령은 `rocky8` 역할을 포함하는 다음 트리 구조를 생성합니다.

```
tree rocky8/
rocky8/
├── defaults
│   └── main.yml
├── files
├── handlers
│   └── main.yml
├── meta
│   └── main.yml
├── README.md
├── tasks
│   └── main.yml
├── templates
├── tests
│   ├── inventory
│   └── test.yml
└── vars
    └── main.yml

8 directories, 8 files
```

역할을 사용하면 파일을 포함할 필요가 없습니다. 플레이북에 파일 경로 또는 `include` 지시문을 지정할 필요가 없습니다. 작업을 지정하기만 하면 Ansible이 포함 사항을 처리합니다.

역할의 구조는 이해하기 매우 쉽습니다.

변수를 재정의하지 않으려면 변수를 `vars/main.yml `에 저장하거나, 역할 외부에서 변수 내용을 재정의할 가능성을 남겨두려면 `default/main.yml `에 저장합니다.

코드에 필요한 핸들러, 파일 및 템플릿은 각각 `handlers/main.yml`, `files` 및 `templates`에 저장됩니다.

이제 역할의 작업에 대한 코드를 `tasks/main.yml`에 정의하기만 하면 됩니다.

이 모든 것이 잘 작동하면 플레이북에서 이 역할을 사용할 수 있습니다. 변수를 사용하여 작업의 기술적 측면에 대해 걱정할 필요 없이 역할을 사용하고 작동을 사용자 정의할 수 있습니다.

### 실습 작업: 첫 번째 간단한 역할 생성하기

기본 사용자를 생성하고 소프트웨어 패키지를 설치하는 "gowhere" 역할로 이를 구현해 보겠습니다. 이 역할은 모든 서버에 체계적으로 적용될 수 있습니다.

#### 변수

모든 서버에서 `rockstar` 사용자를 생성합니다. 이 사용자가 재정의되는 것을 원하지 않으므로 `vars/main.yml`에서 정의해 보겠습니다.

```
---
rocky8_default_group:
  name: rockstar
  gid: 1100
rocky8_default_user:
  name: rockstar
  uid: 1100
  group: rockstar
```

이제 `tasks/main.yml` 내에서 이러한 변수를 포함하지 않고 사용할 수 있습니다.

```
---
- name: Create default group
  group:
    name: "{{ rocky8_default_group.name }}"
    gid: "{{ rocky8_default_group.gid }}"

- name: Create default user
  user:
    name: "{{ rocky8_default_user.name }}"
    uid: "{{ rocky8_default_user.uid }}"
    group: "{{ rocky8_default_user.group }}"
```

새 역할을 테스트하기 위해 역할과 동일한 디렉터리에 `test-role.yml` 플레이북을 생성해 보겠습니다.

```
---
- name: Test my role
  hosts: localhost

  roles:

    - role: rocky8
      become: true
      become_user: root
```

그리고 실행합니다:

```
ansible-playbook test-role.yml

PLAY [Test my role] ************************************************************************************

TASK [Gathering Facts] *********************************************************************************
ok: [localhost]

TASK [rocky8 : Create default group] *******************************************************************
changed: [localhost]

TASK [rocky8 : Create default user] ********************************************************************
changed: [localhost]

PLAY RECAP *********************************************************************************************
localhost                  : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

축하합니다! 이제 몇 줄로 구성된 플레이북으로 멋진 것들을 만들 수 있습니다.

기본 변수를 사용하는 방법을 살펴보겠습니다.

서버에 기본적으로 설치할 패키지 목록과 제거할 빈 패키지 목록을 만듭니다. `defaults/main.yml` 파일을 편집하고 다음 두 목록을 추가합니다.

```
rocky8_default_packages:
  - tree
  - vim
rocky8_remove_packages: []
```

`tasks/main.yml`에서 사용하세요.

```
- name: Install default packages (can be overridden)
  package:
    name: "{{ rocky8_default_packages }}"
    state: present

- name: "Uninstall default packages (can be overridden) {{ rocky8_remove_packages }}"
  package:
    name: "{{ rocky8_remove_packages }}"
    state: absent
```

이전에 만든 플레이북을 사용하여 역할을 테스트합니다.

```
ansible-playbook test-role.yml

PLAY [Test my role] ************************************************************************************

TASK [Gathering Facts] *********************************************************************************
ok: [localhost]

TASK [rocky8 : Create default group] *******************************************************************
ok: [localhost]

TASK [rocky8 : Create default user] ********************************************************************
ok: [localhost]

TASK [rocky8 : Install default packages (can be overridden)] ********************************************
ok: [localhost]

TASK [rocky8 : Uninstall default packages (can be overridden) []] ***************************************
ok: [localhost]

PLAY RECAP *********************************************************************************************
localhost                  : ok=5    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

이제 플레이북에서 `rocky8_remove_packages`를 재정의하고 예를 들어 `cockpit`을 제거할 수 있습니다.

```
---
- name: Test my role
  hosts: localhost
  vars:
    rocky8_remove_packages:
      - cockpit

  roles:

    - role: rocky8
      become: true
      become_user: root
```

```
ansible-playbook test-role.yml

PLAY [Test my role] ************************************************************************************

TASK [Gathering Facts] *********************************************************************************
ok: [localhost]

TASK [rocky8 : Create default group] *******************************************************************
ok: [localhost]

TASK [rocky8 : Create default user] ********************************************************************
ok: [localhost]

TASK [rocky8 : Install default packages (can be overridden)] ********************************************
ok: [localhost]

TASK [rocky8 : Uninstall default packages (can be overridden) ['cockpit']] ******************************
changed: [localhost]

PLAY RECAP *********************************************************************************************
localhost                  : ok=5    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

분명히, 당신이 당신의 역할을 얼마나 향상시킬 수 있는지에는 제한이 없습니다. 서버 중 하나에 대해 제거할 패키지 목록에 있는 패키지가 필요하다고 가정해 보십시오. 그런 다음 예를 들어 무시할 수 있는 새 목록을 만든 다음 jinja `difference()` 필터를 사용하여 설치할 특정 패키지 목록에 있는 패키지를 제거할 패키지 목록에서 제거할 수 있습니다.

```
- name: "Uninstall default packages (can be overridden) {{ rocky8_remove_packages }}"
  package:
    name: "{{ rocky8_remove_packages | difference(rocky8_specifics_packages) }}"
    state: absent
```

## Ansible 컬렉션

컬렉션은 플레이북, 역할, 모듈 및 플러그인을 포함할 수 있는 Ansible 콘텐츠의 배포 형식입니다.

!!! 참고 사항

    자세한 내용은 [여기](https://docs.ansible.com/ansible/latest/user_guide/collections_using.html)에서 확인할 수 있습니다.

컬렉션을 설치하거나 업그레이드하려면:

```
ansible-galaxy collection install namespace.collection [--upgrade]
```

그런 다음 모듈 이름이나 역할 이름 앞에 해당 네임스페이스와 이름을 사용하여 새로 설치된 컬렉션을 사용할 수 있습니다.

```
- import_role:
    name: namespace.collection.rolename

- namespace.collection.modulename:
    option1: value
```

[여기](https://docs.ansible.com/ansible/latest/collections/index.html)에서 컬렉션 색인을 찾을 수 있습니다.

`community.general` 컬렉션을 설치해 보겠습니다.

```
ansible-galaxy collection install community.general
Starting galaxy collection install process
Process install dependency map
Starting collection install process
Downloading https://galaxy.ansible.com/download/community-general-3.3.2.tar.gz to /home/ansible/.ansible/tmp/ansible-local-51384hsuhf3t5/tmpr_c9qrt1/community-general-3.3.2-f4q9u4dg
Installing 'community.general:3.3.2' to '/home/ansible/.ansible/collections/ansible_collections/community/general'
community.general:3.3.2 was installed successfully
```

이제 새로 사용할 수 있는 `yum_versionlock` 모듈을 사용할 수 있습니다.

```
- name: Start a Patch Management
  hosts: ansible_clients
  become: true
  become_user: root
  tasks:

    - name: Ensure yum-versionlock is installed
      package:
        name: python3-dnf-plugin-versionlock
        state: present

    - name: Prevent kernel from being updated
      community.general.yum_versionlock:
        state: present
        name: kernel
      register: locks

    - name: Display locks
      debug:
        var: locks.meta.packages                            
```

```
ansible-playbook versionlock.yml

PLAY [Start a Patch Management] *************************************************************************

TASK [Gathering Facts] **********************************************************************************
ok: [192.168.1.11]

TASK [Ensure yum-versionlock is installed] **************************************************************
changed: [192.168.1.11]

TASK [Prevent kernel from being updated] ****************************************************************
changed: [192.168.1.11]

TASK [Display locks] ************************************************************************************
ok: [192.168.1.11] => {
    "locks.meta.packages": [
        "kernel"
    ]
}

PLAY RECAP **********************************************************************************************
192.168.1.11               : ok=4    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

```

### 나만의 컬렉션 만들기

역할과 마찬가지로 `ansible-galaxy` 명령을 사용하여 자신만의 컬렉션을 만들 수 있습니다.

```
ansible-galaxy collection init rocky8.rockstarcollection
- Collection rocky8.rockstarcollection was created successfully
```

```
tree rocky8/rockstarcollection/
rocky8/rockstarcollection/
├── docs
├── galaxy.yml
├── plugins
│   └── README.md
├── README.md
└── roles
```

그런 다음 이 새 컬렉션 내에 고유한 플러그인 또는 역할을 저장할 수 있습니다.
