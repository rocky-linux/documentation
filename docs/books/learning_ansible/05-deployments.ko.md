---
title: Ansistrano로 배포
---

# Ansistrano를 사용한 Ansible 배포

이 장에서는 Ansible 역할 [Ansistrano](https://ansistrano.com)로 애플리케이션을 배포하는 방법을 배웁니다.

****

**목적**: 이 문서에서는 다음을 수행하는 방법에 대해 알아볼 것 입니다:

:heavy_check_mark: Ansistrano 구현;       
:heavy_check_mark: Ansistrano 구성;       
:heavy_check_mark: 배포된 버전 간에 공유 폴더 및 파일 사용;       
:heavy_check_mark: git에서 사이트의 다른 버전 배포하기;        
:heavy_check_mark: 배포 단계 사이에 반응합니다.

:checkered_flag: **ansible**, **ansistrano**, **역할**, **배포**

**지식**: :star: :star:      
**복잡성**: :star: :star: :star:

**소요 시간**: 40분

****

Ansistrano는 PHP, Python 등의 애플리케이션을 쉽게 배포할 수 있는 Ansible 역할입니다. Ansistrano는 PHP, Python 등의 애플리케이션을 쉽게 배포할 수 있는 Ansible 역할입니다.

## 소개

Ansistrano를 실행하려면 다음이 필요합니다.

* 배포 머신에서 Ansible,
* 클라이언트 시스템의 `rsync` 또는 `git`.

`rsync`, `git`, `scp`, `http`, `S3`에서 소스 코드를 다운로드할 수 있습니다. , ...

!!! 참고 사항

    배포 예시에서는 `git` 프로토콜을 사용합니다.

Ansistrano는 다음 5단계에 따라 애플리케이션을 배포합니다.

* **설정**: 릴리스를 호스팅할 디렉토리 구조를 만듭니다.
* **업데이트 코드**: 새 릴리스를 대상에 다운로드합니다.
* **Symlink Shared** 및 **Symlink**: 새 릴리스를 배포한 후 `현재` 심볼릭 링크 이 새 릴리스를 가리키도록 수정되었습니다.
* **정리**: 일부 정리를 수행합니다(이전 버전 제거).

![배포 단계](images/ansistrano-001.png)

Ansistrano를 사용한 배포의 골격은 다음과 같습니다.

```
/var/www/site/
├── current -> ./releases/20210718100000Z
├── releases
│   └── 20210718100000Z
│       ├── css -> ../../shared/css/
│       ├── img -> ../../shared/img/
│       └── REVISION
├── repo
└── shared
    ├── css/
    └── img/
```

[Github 저장소](https://github.com/ansistrano/deploy)에서 모든 Ansistrano 문서를 찾을 수 있습니다.

## Labs

2개의 서버에서 계속 작업합니다.

매니지먼트(management) 서버

* Ansible이 이미 설치되어 있습니다. `ansistrano.deploy` 역할을 설치해야 합니다.

매니지드(managed) 서버

* Apache를 설치하고 클라이언트 사이트를 배포해야 합니다.

### 웹 서버 배포

효율성을 높이기 위해 `geerlingguy.apache` 역할을 사용하여 서버를 구성합니다.

```
$ ansible-galaxy role install geerlingguy.apache
Starting galaxy role install process
- downloading role 'apache', owned by geerlingguy
- downloading role from https://github.com/geerlingguy/ansible-role-apache/archive/3.1.4.tar.gz
- extracting geerlingguy.apache to /home/ansible/.ansible/roles/geerlingguy.apache
- geerlingguy.apache (3.1.4) was installed successfully
```

일부 방화벽 규칙을 열어야 할 수도 있으므로 모듈 `firewalld`와 함께 작동하도록 `ansible.posix` 컬렉션도 설치합니다.

```
$ ansible-galaxy collection install ansible.posix
Starting galaxy collection install process
Process install dependency map
Starting collection install process
Downloading https://galaxy.ansible.com/download/ansible-posix-1.2.0.tar.gz to /home/ansible/.ansible/tmp/ansible-local-519039bp65pwn/tmpsvuj1fw5/ansible-posix-1.2.0-bhjbfdpw
Installing 'ansible.posix:1.2.0' to '/home/ansible/.ansible/collections/ansible_collections/ansible/posix'
ansible.posix:1.2.0 was installed successfully
```

역할과 컬렉션이 설치되면 다음과 같은 플레이북의 첫 번째 부분을 만들 수 있습니다.

* Apache설치,
* `vhost`에 대한 대상 폴더를 생성,
* 기본 `vhost` 생성,
* 방화벽을 열기,
* Apache를 시작 혹은 다시 시작.

기술적 고려 사항:

* 사이트를 `/var/www/site/` 폴더에 배포합니다.
* 나중에 살펴보겠지만 `ansistrano`는 현재 릴리스 폴더에 대한 `current` 심볼릭 링크를 생성합니다.
* 배포할 소스 코드에는 가상 호스트가 가리켜야 하는 `html` 폴더가 포함되어 있습니다. `DirectoryIndex`는 `index.htm`입니다.
* 배포는 `git`에 의해 수행되며 패키지가 설치됩니다.

!!! 참고 사항

    따라서 vhost의 대상은 `/var/www/site/current/html`입니다.

서버 구성을 위한 플레이북: `playbook-config-server.yml`

```
---
- hosts: ansible_clients
  become: yes
  become_user: root
  vars:
    dest: "/var/www/site/"
    apache_global_vhost_settings: |
      DirectoryIndex index.php index.htm
    apache_vhosts:
      - servername: "website"
        documentroot: "{{ dest }}current/html"

  tasks:

    - name: create directory for website
      file:
        path: /var/www/site/
        state: directory
        mode: 0755

    - name: install git
      package:
        name: git
        state: latest

    - name: permit traffic in default zone for http service
      ansible.posix.firewalld:
        service: http
        permanent: yes
        state: enabled
        immediate: yes

  roles:
    - { role: geerlingguy.apache }
```

플레이북을 서버에 적용할 수 있습니다.

```
$ ansible-playbook playbook-config-server.yml
```

다음 작업의 실행에 유의하십시오.

```
TASK [geerlingguy.apache : Ensure Apache is installed on RHEL.] ****************
TASK [geerlingguy.apache : Configure Apache.] **********************************
TASK [geerlingguy.apache : Add apache vhosts configuration.] *******************
TASK [geerlingguy.apache : Ensure Apache has selected state and enabled on boot.] ***
TASK [permit traffic in default zone for http service] *************************
RUNNING HANDLER [geerlingguy.apache : restart apache] **************************
```

`geerlingguy.apache` 역할은 Apache의 설치 및 구성을 처리하여 작업을 훨씬 쉽게 해줍니다.

`curl`을 사용하여 모든 것이 작동하는지 확인할 수 있습니다.

```
$ curl -I http://192.168.1.11
HTTP/1.1 404 Not Found
Date: Mon, 05 Jul 2021 23:30:02 GMT
Server: Apache/2.4.37 (rocky) OpenSSL/1.1.1g
Content-Type: text/html; charset=iso-8859-1
```

!!! 참고 사항

    아직 코드를 배포하지 않았으므로 `curl`이 `404` HTTP 코드를 반환하는 것이 정상입니다. 그러나 우리는 이미 `httpd` 서비스가 작동하고 있고 방화벽이 열려 있음을 확인할 수 있습니다.

### 소프트웨어 배포

이제 서버가 구성되었으므로 애플리케이션을 배포할 수 있습니다.

이를 위해 애플리케이션 배포 전용 두 번째 플레이북에서 `ansistrano.deploy` 역할을 사용합니다(가독성 향상을 위해여).

```
$ ansible-galaxy role install ansistrano.deploy
Starting galaxy role install process
- downloading role 'deploy', owned by ansistrano
- downloading role from https://github.com/ansistrano/deploy/archive/3.10.0.tar.gz
- extracting ansistrano.deploy to /home/ansible/.ansible/roles/ansistrano.deploy
- ansistrano.deploy (3.10.0) was installed successfully

```

소프트웨어 소스는 [github 저장소](https://github.com/alemorvan/demo-ansible.git)에서 찾을 수 있습니다.

배포를 관리하기 위해 플레이북 `playbook-deploy.yml`을 생성합니다.

```
---
- hosts: ansible_clients
  become: yes
  become_user: root
  vars:
    dest: "/var/www/site/"
    ansistrano_deploy_via: "git"
    ansistrano_git_repo: https://github.com/alemorvan/demo-ansible.git
    ansistrano_deploy_to: "{{ dest }}"

  roles:
     - { role: ansistrano.deploy }
```

```
$ ansible-playbook playbook-deploy.yml

PLAY [ansible_clients] *********************************************************

TASK [ansistrano.deploy : ANSISTRANO | Ensure deployment base path exists] *****
TASK [ansistrano.deploy : ANSISTRANO | Ensure releases folder exists]
TASK [ansistrano.deploy : ANSISTRANO | Ensure shared elements folder exists]
TASK [ansistrano.deploy : ANSISTRANO | Ensure shared paths exists]
TASK [ansistrano.deploy : ANSISTRANO | Ensure basedir shared files exists]
TASK [ansistrano.deploy : ANSISTRANO | Get release version] ********************
TASK [ansistrano.deploy : ANSISTRANO | Get release path]
TASK [ansistrano.deploy : ANSISTRANO | GIT | Register ansistrano_git_result variable]
TASK [ansistrano.deploy : ANSISTRANO | GIT | Set git_real_repo_tree]
TASK [ansistrano.deploy : ANSISTRANO | GIT | Create release folder]
TASK [ansistrano.deploy : ANSISTRANO | GIT | Sync repo subtree[""] to release path]
TASK [ansistrano.deploy : ANSISTRANO | Copy git released version into REVISION file]
TASK [ansistrano.deploy : ANSISTRANO | Ensure shared paths targets are absent]
TASK [ansistrano.deploy : ANSISTRANO | Create softlinks for shared paths and files]
TASK [ansistrano.deploy : ANSISTRANO | Ensure .rsync-filter is absent]
TASK [ansistrano.deploy : ANSISTRANO | Setup .rsync-filter with shared-folders]
TASK [ansistrano.deploy : ANSISTRANO | Get current folder]
TASK [ansistrano.deploy : ANSISTRANO | Remove current folder if it's a directory]
TASK [ansistrano.deploy : ANSISTRANO | Change softlink to new release]
TASK [ansistrano.deploy : ANSISTRANO | Clean up releases]

PLAY RECAP ********************************************************************************************************************************************************************************************************
192.168.1.11               : ok=25   changed=8    unreachable=0    failed=0    skipped=14   rescued=0    ignored=0   

```

단 11줄의 코드로 많은 작업을 수행할 수 있습니다!

```
$ curl http://192.168.1.11
<html>
<head>
<title>Demo Ansible</title>
</head>
<body>
<h1>Version Master</h1>
</body>
<html>
```

### 서버에서 확인 중

이제 ssh로 클라이언트 시스템에 연결할 수 있습니다.

* `/var/www/site/` 디렉토리에 `tree`를 만듭니다.

```
$ tree /var/www/site/
/var/www/site
├── current -> ./releases/20210722155312Z
├── releases
│   └── 20210722155312Z
│       ├── REVISION
│       └── html
│           └── index.htm
├── repo
│   └── html
│       └── index.htm
└── shared
```

참고 사항:

* `./releases/20210722155312Z` 릴리스에 대한 `current` 심볼릭 링크
* `shared` 디렉토리의 존재
* `./repo/`에 있는 git repos의 존재

* Ansible 서버에서 배포를 **3**번 다시 시작한 다음 클라이언트를 확인합니다.

```
$ tree /var/www/site/
var/www/site
├── current -> ./releases/20210722160048Z
├── releases
│   ├── 20210722155312Z
│   │   ├── REVISION
│   │   └── html
│   │       └── index.htm
│   ├── 20210722160032Z
│   │   ├── REVISION
│   │   └── html
│   │       └── index.htm
│   ├── 20210722160040Z
│   │   ├── REVISION
│   │   └── html
│   │       └── index.htm
│   └── 20210722160048Z
│       ├── REVISION
│       └── html
│           └── index.htm
├── repo
│   └── html
│       └── index.htm
└── shared
```

참고 사항:

* `ansistrano`는 마지막 릴리스 4개를 유지했습니다.
* 최신 릴리스에 연결된 `current` 링크

### 릴리스 수 제한

`ansistrano_keep_releases` 변수는 보관할 릴리스 수를 지정하는 데 사용됩니다.

* `ansistrano_keep_releases` 변수를 사용하여 프로젝트의 3개 릴리스만 유지합니다. 확인하세요.

```
---
- hosts: ansible_clients
  become: yes
  become_user: root
  vars:
    dest: "/var/www/site/"
    ansistrano_deploy_via: "git"
    ansistrano_git_repo: https://github.com/alemorvan/demo-ansible.git
    ansistrano_deploy_to: "{{ dest }}"
    ansistrano_keep_releases: 3

  roles:
     - { role: ansistrano.deploy }
```

```
---
$ ansible-playbook -i hosts playbook-deploy.yml
```

클라이언트 컴퓨터에서:

```
$ tree /var/www/site/
/var/www/site
├── current -> ./releases/20210722160318Z
├── releases
│   ├── 20210722160040Z
│   │   ├── REVISION
│   │   └── html
│   │       └── index.htm
│   ├── 20210722160048Z
│   │   ├── REVISION
│   │   └── html
│   │       └── index.htm
│   └── 20210722160318Z
│       ├── REVISION
│       └── html
│           └── index.htm
├── repo
│   └── html
│       └── index.htm
└── shared
```

### shared_paths 및 shared_files 사용


```
---
- hosts: ansible_clients
  become: yes
  become_user: root
  vars:
    dest: "/var/www/site/"
    ansistrano_deploy_via: "git"
    ansistrano_git_repo: https://github.com/alemorvan/demo-ansible.git
    ansistrano_deploy_to: "{{ dest }}"
    ansistrano_keep_releases: 3
    ansistrano_shared_paths:
      - "img"
      - "css"
    ansistrano_shared_files:
      - "logs"

  roles:
     - { role: ansistrano.deploy }
```

클라이언트 시스템에서 `share` 디렉토리에 `logs` 파일을 만듭니다.

```
sudo touch /var/www/site/shared/logs
```

그런 다음 플레이북을 실행합니다.

```
TASK [ansistrano.deploy : ANSISTRANO | Ensure shared paths targets are absent] *******************************************************
ok: [192.168.10.11] => (item=img)
ok: [192.168.10.11] => (item=css)
ok: [192.168.10.11] => (item=logs/log)

TASK [ansistrano.deploy : ANSISTRANO | Create softlinks for shared paths and files] **************************************************
changed: [192.168.10.11] => (item=img)
changed: [192.168.10.11] => (item=css)
changed: [192.168.10.11] => (item=logs)
```

클라이언트 컴퓨터에서:

```
$  tree -F /var/www/site/
/var/www/site/
├── current -> ./releases/20210722160631Z/
├── releases/
│   ├── 20210722160048Z/
│   │   ├── REVISION
│   │   └── html/
│   │       └── index.htm
│   ├── 20210722160318Z/
│   │   ├── REVISION
│   │   └── html/
│   │       └── index.htm
│   └── 20210722160631Z/
│       ├── REVISION
│       ├── css -> ../../shared/css/
│       ├── html/
│       │   └── index.htm
│       ├── img -> ../../shared/img/
│       └── logs -> ../../shared/logs
├── repo/
│   └── html/
│       └── index.htm
└── shared/
    ├── css/
    ├── img/
    └── logs
```

마지막 릴리스에는 `css`, `img` 및 `logs`의 3개 링크가 포함되어 있습니다.

* `/var/www/site/releases/css`에서 `../../shared/css/` 디렉토리로.
* `/var/www/site/releases/img`에서 `../../shared/img/` 디렉토리로.
* `/var/www/site/releases/logs`에서 `../../shared/logs` 파일로.

따라서 이 두 폴더에 포함된 파일과 `logs` 파일은 항상 다음 경로를 통해 액세스할 수 있습니다.

* `/var/www/site/current/css/`,
* `/var/www/site/current/img/`,
* `/var/www/site/current/logs`,

그러나 무엇보다도 한 릴리스에서 다음 릴리스로 유지됩니다.

### 배포를 위해 리포지토리의 하위 디렉터리 사용

이 경우 리포지토리에는 사이트 파일이 포함된 `html` 폴더가 포함되어 있습니다.

* 이 추가 수준의 디렉토리를 피하려면 사용할 하위 디렉토리의 경로를 지정하여 `ansistrano_git_repo_tree` 변수를 사용하십시오.

이 변경 사항을 고려하여 Apache 구성을 수정하는 것을 잊지 마십시오!

서버 구성 `playbook-config-server.yml`에 대한 플레이북 변경

```
---
- hosts: ansible_clients
  become: yes
  become_user: root
  vars:
    dest: "/var/www/site/"
    apache_global_vhost_settings: |
      DirectoryIndex index.php index.htm
    apache_vhosts:
      - servername: "website"
        documentroot: "{{ dest }}current/" # <1>

  tasks:

    - name: create directory for website
      file:
        path: /var/www/site/
        state: directory
        mode: 0755

    - name: install git
      package:
        name: git
        state: latest

  roles:
    - { role: geerlingguy.apache }
```

<1> 이 줄을 수정하십시오.

배포 `playbook-deploy.yml`에 대한 플레이북 변경

```
---
- hosts: ansible_clients
  become: yes
  become_user: root
  vars:
    dest: "/var/www/site/"
    ansistrano_deploy_via: "git"
    ansistrano_git_repo: https://github.com/alemorvan/demo-ansible.git
    ansistrano_deploy_to: "{{ dest }}"
    ansistrano_keep_releases: 3
    ansistrano_shared_paths:
      - "img"
      - "css"
    ansistrano_shared_files:
      - "log"
    ansistrano_git_repo_tree: 'html' # <1>

  roles:
     - { role: ansistrano.deploy }
```

<1> 이 줄을 수정하십시오.

* 두 플레이북을 모두 실행하는 것을 잊지 마십시오.

* 클라이언트 컴퓨터에서 확인:

```
$  tree -F /var/www/site/
/var/www/site/
├── current -> ./releases/20210722161542Z/
├── releases/
│   ├── 20210722160318Z/
│   │   ├── REVISION
│   │   └── html/
│   │       └── index.htm
│   ├── 20210722160631Z/
│   │   ├── REVISION
│   │   ├── css -> ../../shared/css/
│   │   ├── html/
│   │   │   └── index.htm
│   │   ├── img -> ../../shared/img/
│   │   └── logs -> ../../shared/logs
│   └── 20210722161542Z/
│       ├── REVISION
│       ├── css -> ../../shared/css/
│       ├── img -> ../../shared/img/
│       ├── index.htm
│       └── logs -> ../../shared/logs
├── repo/
│   └── html/
│       └── index.htm
└── shared/
    ├── css/
    ├── img/
    └── logs
```

<1> `html`이 없다는 점에 유의하십시오.

### git 브랜치 또는 태그 관리

`ansistrano git_branch` 변수는 배포할 `branch` 또는 `tag`를 지정하는 데 사용됩니다.

* `releases/v1.1.0`브랜치를 배포합니다.

```
---
- hosts: ansible_clients
  become: yes
  become_user: root
  vars:
    dest: "/var/www/site/"
    ansistrano_deploy_via: "git"
    ansistrano_git_repo: https://github.com/alemorvan/demo-ansible.git
    ansistrano_deploy_to: "{{ dest }}"
    ansistrano_keep_releases: 3
    ansistrano_shared_paths:
      - "img"
      - "css"
    ansistrano_shared_files:
      - "log"
    ansistrano_git_repo_tree: 'html'
    ansistrano_git_branch: 'releases/v1.1.0'

  roles:
     - { role: ansistrano.deploy }
```

!!! 참고 사항

    배포하는 동안 브라우저를 새로 고치고 변경 사항을 '실시간'으로 확인할 수 있습니다.

```
$ curl http://192.168.1.11
<html>
<head>
<title>Demo Ansible</title>
</head>
<body>
<h1>Version 1.0.1</h1>
</body>
<html>
```

* `v2.0.0` 태그를 배포합니다.

```
---
- hosts: ansible_clients
  become: yes
  become_user: root
  vars:
    dest: "/var/www/site/"
    ansistrano_deploy_via: "git"
    ansistrano_git_repo: https://github.com/alemorvan/demo-ansible.git
    ansistrano_deploy_to: "{{ dest }}"
    ansistrano_keep_releases: 3
    ansistrano_shared_paths:
      - "img"
      - "css"
    ansistrano_shared_files:
      - "log"
    ansistrano_git_repo_tree: 'html'
    ansistrano_git_branch: 'v2.0.0'

  roles:
     - { role: ansistrano.deploy }
```

```
$ curl http://192.168.1.11
<html>
<head>
<title>Demo Ansible</title>
</head>
<body>
<h1>Version 2.0.0</h1>
</body>
<html>
```

### 배포 단계 간 작업

Ansistrano를 사용한 배포는 다음 단계를 따릅니다.

* `설정`
* `코드 업데이트`
* `심볼릭 링크 공유`
* `심볼릭 링크`
* `정리`

이러한 각 단계 전후에 개입할 수 있습니다.

![배포 단계](images/ansistrano-001.png)

플레이북은 이 목적을 위해 제공되는 변수를 통해 포함될 수 있습니다:

* `ansistrano_before_<task>_tasks_file`
* 또는 `ansistrano_after_<task>_tasks_file`

* 쉬운 예: 배포 시작 시 이메일(또는 Slack 알림과 같은 원하는 항목)을 보냅니다.


```
---
- hosts: ansible_clients
  become: yes
  become_user: root
  vars:
    dest: "/var/www/site/"
    ansistrano_deploy_via: "git"
    ansistrano_git_repo: https://github.com/alemorvan/demo-ansible.git
    ansistrano_deploy_to: "{{ dest }}"
    ansistrano_keep_releases: 3
    ansistrano_shared_paths:
      - "img"
      - "css"
    ansistrano_shared_files:
      - "logs"
    ansistrano_git_repo_tree: 'html'
    ansistrano_git_branch: 'v2.0.0'
    ansistrano_before_setup_tasks_file: "{{ playbook_dir }}/deploy/before-setup-tasks.yml"

  roles:
     - { role: ansistrano.deploy }
```

`deploy/before-setup-tasks.yml` 파일을 생성합니다.

```
---
- name: Send a mail
  mail:
    subject: Starting deployment on {{ ansible_hostname }}.
  delegate_to: localhost
```

```
TASK [ansistrano.deploy : include] *************************************************************************************
included: /home/ansible/deploy/before-setup-tasks.yml for 192.168.10.11

TASK [ansistrano.deploy : Send a mail] *************************************************************************************
ok: [192.168.10.11 -> localhost]
```

```
[root] # mailx
Heirloom Mail version 12.5 7/5/10.  Type ? for help.
"/var/spool/mail/root": 1 message 1 new
>N  1 root@localhost.local  Tue Aug 21 14:41  28/946   "Starting deployment on localhost."
```

* 예를 들어 캐시를 플러시하기 위해 배포가 끝날 때 일부 서비스를 다시 시작해야 할 수 있습니다. 배포가 끝나면 Apache를 다시 시작하겠습니다.

```
---
- hosts: ansible_clients
  become: yes
  become_user: root
  vars:
    dest: "/var/www/site/"
    ansistrano_deploy_via: "git"
    ansistrano_git_repo: https://github.com/alemorvan/demo-ansible.git
    ansistrano_deploy_to: "{{ dest }}"
    ansistrano_keep_releases: 3
    ansistrano_shared_paths:
      - "img"
      - "css"
    ansistrano_shared_files:
      - "logs"
    ansistrano_git_repo_tree: 'html'
    ansistrano_git_branch: 'v2.0.0'
    ansistrano_before_setup_tasks_file: "{{ playbook_dir }}/deploy/before-setup-tasks.yml"
    ansistrano_after_symlink_tasks_file: "{{ playbook_dir }}/deploy/after-symlink-tasks.yml"

  roles:
     - { role: ansistrano.deploy }
```

`deploy/after-symlink-tasks.yml` 파일을 생성합니다.

```
---
- name: restart apache
  systemd:
    name: httpd
    state: restarted
```

```
TASK [ansistrano.deploy : include] *************************************************************************************
included: /home/ansible/deploy/after-symlink-tasks.yml for 192.168.10.11

TASK [ansistrano.deploy : restart apache] **************************************************************************************
changed: [192.168.10.11]
```

이 장에서 보았듯이 Ansible은 시스템 관리자의 수명을 크게 향상시킬 수 있습니다. Ansistrano와 같은 매우 지능적인 역할은 빠르게 필수 불가결한 "필수 항목"입니다.

Ansistrano를 사용하면 우수한 배포 관행을 준수하고 시스템을 생산에 투입하는 데 필요한 시간을 단축하며 잠재적인 인적 오류의 위험을 방지할 수 있습니다. 기계는 빠르고 잘 작동하며 거의 실수하지 않습니다!
