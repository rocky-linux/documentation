---
title: Ansible 기초
author: Antoine Le Morvan
contributors: Steven Spencer, tianci li
update: 15-Dec-2021
---

# Ansible 기초

이 문서에서는 Ansible을 사용하는 방법에 대해 알아봅니다.

****

**목적**: 이 문서에서는 다음을 수행하는 방법에 대해 알아볼 것 입니다:

:heavy_check_mark: Ansible 구현하기;       
:heavy_check_mark: 서버에 구성 변경 사항을 적용하기;   
:heavy_check_mark: 첫 번째 Ansible 플레이북을 만들기.

:checkered_flag: **ansible**, **모듈**, **플레이북**

**지식**: :star: :star: :star:     
**복잡성**: :star: :star:

**소요 시간**: 30분

****

Ansible은 관리 작업을 중앙 집중화하고 자동화하는 도구입니다. 다음과 같은 특징이 있습니다:

* **에이전트 미사용**(클라이언트에 특정 배포가 필요하지 않음),
* **멱동성**(실행할 때마다 동일한 효과).

Linux 클라이언트를 원격으로 구성하기 위해 **SSH** 프로토콜을 사용하거나 Windows 클라이언트와 작업하기 위해 **WinRM** 프로토콜을 사용합니다. 이러한 프로토콜 중 어느 것도 사용할 수 없는 경우에는 항상 API를 사용하여 서버, 워크스테이션, 도커 서비스, 네트워크 장비 등 (사실 거의 모든 것)의 구성에 Ansible을 사용할 수 있습니다.

!!! 주의

    SSH 또는 WinRM 흐름을 Ansible 서버에서 모든 클라이언트로 열어 놓는 것은 아키텍처의 중요한 요소이므로 주의 깊게 모니터링해야 합니다.

Ansible은 푸시 기반이므로 각 실행 사이에 대상 서버의 상태를 유지하지 않습니다. 반대로 실행될 때마다 새로운 상태 검사를 수행합니다. 이를 스테이트리스(stateless)라고 합니다.

Ansible은 다음과 같은 작업에 도움을 줄 수 있습니다:

* 프로비저닝(새 VM 배포),
* 애플리케이션 배포,
* 구성 관리,
* 자동화,
* 오케스트레이션 (1개 이상의 대상을 사용할 때).

!!! 참고 사항

    Ansible은 원래 Cobbler와 같은 다른 도구의 설립자인 Michael DeHaan이 작성했습니다.
    
    ![Michael DeHaan](images/Michael_DeHaan01.jpg)
    
    가장 초기 버전은 2012년 3월 9일에 출시된 0.0.1 버전입니다.
    
    2015년 10월 17일, AnsibleWorks(Ansible 뒤에 있는 회사)는 Red Hat에 1억 5천만 달러에 인수되었습니다.

![앤서블의 특징](images/ansible-001.png)

일상적인 Ansible 사용을 위해 그래픽 인터페이스를 제공하기 위해 Ansible Tower (RedHat)와 같은 도구를 설치할 수 있습니다. 이는 유료인 경우도 있으며 오픈소스 대안으로 Awx 또는 Jenkins와 Rundeck와 같은 다른 프로젝트도 사용할 수 있습니다.

!!! abstract "개요"

    이 교육을 따르려면 최소 2개의 Rocky8 서버가 필요합니다:

    * 첫 번째는 **관리 기기**이고, Ansible은 그 위에 설치될 것입니다.
    * 두 번째는 구성 및 관리할 서버입니다(Rocky Linux 이외의 다른 Linux도 사용 가능).

    아래 예에서 관리 스테이션의 IP 주소는 172.16.1.10이고, 관리 대상 스테이션의 IP 주소는 172.16.1.11입니다. IP 주소 지정 계획에 따라 예시를 조정하십시오.

## Ansible 단어

* **관리 시스템**: Ansible이 설치된 머신입니다. Ansible은 **에이전트가 없이** 동작하므로 관리 대상 서버에는 소프트웨어가 배포되지 않습니다.
* **인벤토리**: 관리 대상 서버에 대한 정보를 포함하는 파일입니다.
* **작업**: 작업은 실행할 절차를 정의하는 블록입니다(예: 사용자 또는 그룹 생성, 소프트웨어 패키지 설치 등).
* **모듈**: 모듈은 태스크를 추상화하는 것입니다. Ansible에서는 여러 모듈이 제공됩니다.
* **플레이북**: 목표 서버와 수행할 작업을 정의하는 간단한 yaml 형식의 파일입니다.
* **롤**: 롤은 플레이북과 코드의 공유와 재사용을 용이하게 하기 위해 필요한 다른 모든 파일 (템플릿, 스크립트 등) 을 구성하는 것입니다.
* **컬렉션**: 컬렉션에는 플레이북, 롤, 모듈 및 플러그인의 논리적인 집합을 포함합니다.
* **팩트**: 시스템에 대한 정보(컴퓨터 이름, 시스템 버전, 네트워크 인터페이스 및 구성 등)를 포함하는 전역 변수입니다.
* **핸들러**: 변경 사항 발생 시 서비스를 중지하거나 재시작하는 데 사용됩니다.

## 관리 서버에 설치

Ansible은 _EPEL_ 리포지토리에서 사용할 수 있지만 지금은 꽤 오래된 버전인 2.9.21로 제공됩니다. 이를 따라하면 수행하면 이 작업이 어떻게 수행되는지 볼 수 있지만 최신 버전을 설치할 예정이므로 실제 설치 단계를 건너뛸 것 입니다. _EPEL_은 두 버전 모두에 필요하므로 지금 바로 설치할 수 있습니다.

* EPEL 설치:

```
$ sudo dnf install epel-release
```
_EPEL_에서 Ansible을 설치하는 경우 다음을 수행할 수 있습니다.

```
$ sudo dnf install ansible
$ ansible --version
2.9.21
```
최신 버전의 Ansible을 사용하려면 `python3-pip`에서 설치합니다.

!!! 참고 사항

    이전에 _EPEL_에서 Ansible을 설치한 경우 Ansible을 제거합니다.

```
$ sudo dnf install python38 python38-pip python38-wheel python3-argcomplete rust cargo curl
```

!!! 참고 사항

    `python3-argcomplete`는 _EPEL_에서 제공합니다. 아직 설치하지 않았다면 epel-release를 설치하십시오.
    이 패키지는 Ansible 명령어를 자동 완성하는 데 도움이 됩니다.

Ansible을 실제로 설치하기 전에, Rocky Linux에 새로 설치한 Python 버전을 사용하도록 설정해야 합니다. 그 이유는 이 설정 없이 계속 설치하면 기본 python3 (이 글을 쓰는 시점에서 3.6 버전) 이 새로 설치한 3.8 버전 대신 사용될 것입니다. 원하는 버전을 다음 명령어로 설정합니다:

```
sudo alternatives --set python /usr/bin/python3.8
sudo alternatives --set python3 /usr/bin/python3.8
```

이제 Ansible을 설치할 수 있습니다.

```
$ sudo pip3 install ansible
$ sudo activate-global-python-argcomplete
```

Ansible 버전 확인합니다:

```
$ ansible --version
ansible [core 2.11.2]
  config file = None
  configured module search path = ['/home/ansible/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/local/lib/python3.8/site-packages/ansible
  ansible collection location = /home/ansible/.ansible/collections:/usr/share/ansible/collections
  executable location = /usr/local/bin/ansible
  python version = 3.8.6 (default, Jun 29 2021, 21:14:45) [GCC 8.4.1 20200928 (Red Hat 8.4.1-1)]
  jinja version = 3.0.1
  libyaml = True
```

## 구성 파일

서버 구성 파일은`/etc/ansible`에 위치합니다.

두 개의 주요 구성 파일이 있습니다:

* 주요 구성 파일 `ansible.cfg`에는 명령어, 모듈, 플러그인 및 SSH 구성이 포함됩니다.
* 클라이언트 머신 관리 인벤토리 파일인 `hosts`에는 클라이언트 및 클라이언트 그룹이 선언됩니다.

`pip`로 Ansible을 설치했기 때문에 해당 파일이 존재하지 않습니다. 우리는 이를 수동으로 생성해야 합니다.

`ansible.cfg`의 예는 [여기](https://github.com/ansible/ansible/blob/devel/examples/ansible.cfg)에 나와 있습니다. `hosts`의 예는 [이 파일](https://github.com/ansible/ansible/blob/devel/examples/hosts)에 있습니다.

```
$ sudo mkdir /etc/ansible
$ sudo curl -o /etc/ansible/ansible.cfg https://raw.githubusercontent.com/ansible/ansible/devel/examples/ansible.cfg
$ sudo curl -o /etc/ansible/hosts https://raw.githubusercontent.com/ansible/ansible/devel/examples/hosts
```

`ansible-config` 명령을 사용하여 새 구성 파일을 생성할 수도 있습니다.

```
usage: ansible-config [-h] [--version] [-v] {list,dump,view,init} ...

ansible 구성을 봅니다.

positional arguments:
  {list,dump,view,init}
    list                Print all config options
    dump                Dump configuration
    view                View configuration file
    init                Create initial configuration
```

예시:

```
ansible-config init --disabled > /etc/ansible/ansible.cfg
```

`--disabled` 옵션을 사용하면 `;`로 시작하여 주석 처리할 수 있습니다.

### 인벤토리 파일 `/etc/ansible/hosts`

Ansible은 구성할 모든 장비와 함께 작동해야 하므로, 조직과 완벽히 일치하는 잘 구조화된 인벤토리 파일(하나 또는 여러 개)을 제공하는 것이 매우 중요합니다.

이 파일을 구성하는 방법에 대해 신중히 생각해야 할 때가 있습니다.

기본 인벤토리 파일인 `/etc/ansible/hosts`로 이동하세요. 몇 가지 예시가 제공되며 주석 처리되어 있습니다:

```
# 이것은 기본 ansible 'hosts' 파일입니다.
#
# /etc/ansible/hosts에 위치해야 합니다.
#
# - 주석은 '#' 문자로 시작합니다.
# - 빈 줄은 무시됩니다.
# - 호스트 그룹은 [헤더] 요소로 구분됩니다.
# - 호스트 이름 또는 IP 주소를 입력할 수 있습니다.
# - 호스트 이름/ip는 여러 그룹의 구성원이 될 수 있습니다.

# Ex 1: 그룹에 속하지 않은 호스트, 그룹 헤더 앞에 지정하세요:

## green.example.com
## blue.example.com
## 192.168.100.1
## 192.168.100.10

# Ex 2: 'webservers' 그룹에 속하는 호스트 모음:
## [webservers]
## alpha.example.org
## beta.example.org
## 192.168.1.100
## 192.168.1.110

# 패턴에 따라 여러 호스트가 있는 경우 다음과 같이 지정할 수 있습니다:
# 그들은 다음과 같습니다:

## www[001:006].example.com

# Ex 3: 'dbservers' 그룹에 속하는 데이터베이스 서버 모음:

## [dbservers]
##
## db01.intranet.mydomain.net
## db02.intranet.mydomain.net
## 10.25.1.56
## 10.25.1.57

# 다음은 호스트 범위의 또 다른 예입니다. 
# 이번에는 선행 0이 없습니다.

## db-[99:101]-node.example.com
```

예시에서 볼 수 있듯이, 제공된 파일은 시스템 관리자에게 잘 알려진 INI 형식을 사용합니다. 다른 파일 형식(예: yaml)을 선택할 수도 있지만, 첫 번째 테스트에는 INI 형식이 우리의 예제에 적합합니다.

물론 실제 환경에서는 인벤토리를 자동으로 생성할 수도 있으며, 특히 VMware VSphere나 AWS, Openstack 등의 클라우드 환경과 같은 가상화 환경이 있는 경우에 유용합니다.

* `/etc/ansible/hosts`에서 호스트 그룹 생성:

그룹은 대괄호로 선언됩니다. 그룹에 속하는 요소가 이어집니다. 예를 들어 이 파일에 다음 블록을 삽입하여 `rocky8` 그룹을 만들 수 있습니다.

```
[rocky8]
172.16.1.10
172.16.1.11
```

그룹은 다른 그룹 내에서 사용할 수 있습니다. 이 경우 상위 그룹이 다음과 같이 `:chidren` 속성이 있는 하위 그룹으로 구성되도록 지정해야 합니다.

```
[linux:children]
rocky8
debian9

[ansible:children]
ansible_management
ansible_clients

[ansible_management]
172.16.1.10

[ansible_clients]
172.16.1.10
```

인벤토리에 대해 더 자세히 알고 싶다면 [이 링크를](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html)를 확인해보시기 바랍니다.

이제 관리 서버가 설치되고 인벤토리가 준비되었으므로 첫 번째 `ansible` 명령을 실행할 차례입니다.

## `ansible` 커맨드 라인 사용

`ansible` 명령은 하나 이상의 대상 호스트에서 작업을 실행합니다.

```
ansible <host-pattern> [-m module_name] [-a args] [options]
```

예시:

!!! warning "주의"

    아직 테스트 서버 2대에 인증을 구성하지 않았으므로, 다음 예시가 모두 작동하지는 않습니다. 이 예시들은 이해를 돕기 위해 제공되며, 이 문서의 뒷부분에서 완전히 작동합니다.

* rocky8 그룹에 속한 호스트를 목록 표시:

```
ansible rocky8 --list-hosts
```

* `ping` 모듈을 사용하여 호스트 그룹에 ping 전송:

```
ansible rocky8 -m ping
```

* `setup` 모듈을 사용하여 호스트 그룹의 팩트 표시:

```
ansible rocky8 -m setup
```

* `command` 모듈을 인자와 함께 사용하여 호스트 그룹에서 명령 실행:

```
ansible rocky8 -m command -a 'uptime'
```

* 관리자 권한으로 명령 실행:

```
ansible ansible_clients --become -m command -a 'reboot'
```

* 사용자 정의 인벤토리 파일을 사용하여 명령 실행:

```
ansible rocky8 -i ./local-inventory -m command -a 'date'
```

!!! note "참고 사항"

    이 예시에서처럼, 관리 대상 장치의 선언을 여러 파일로 분리하는 것이 긴 인벤토리 파일을 유지하는 것보다 간단할 때가 있습니다. 예를 들어, 클라우드 프로젝트별로 분리하고 Ansible에 해당 파일 경로를 제공하는 것이 좋습니다.

| 옵션                       | 정보                                                |
| ------------------------ | ------------------------------------------------- |
| `-a 'arguments'`         | 모듈에 전달할 인수입니다.                                    |
| `-b -K`                  | 암호를 요청하고 더 높은 권한으로 명령을 실행합니다.                     |
| `--user=username`        | 이 사용자를 사용하여 현재 사용자 대신 대상 호스트에 연결합니다.              |
| `--become-user=username` | 이 사용자로 작업을 실행합니다(기본값: `root`).                    |
| `-C`                     | 시뮬레이션입니다. 대상을 변경하지 않고 대상을 테스트하여 변경해야 할 사항을 확인합니다. |
| `-m module`              | 지정된 모듈을 실행합니다.                                    |

### 클라이언트 준비

관리 서버와 클라이언트 모두에게 `ansible`이 수행하는 작업에 전용으로 사용할 ansible 사용자를 생성합니다. 이 사용자는 sudo 권한을 사용해야 하므로 `wheel` 그룹에 추가해야 합니다.

이 사용자는 다음과 같이 사용됩니다.

* 관리 스테이션 측: `ansible` 명령을 실행하고 관리되는 클라이언트로 ssh를 실행하기 위해.
* 관리되는 스테이션에서(여기에서는 관리 스테이션이 동시에 클라이언트로 작동하므로 자체 관리되는 서버입니다): 관리 스테이션에서 시작된 명령을 실행하기 위해 sudo 권한이 필요합니다.

두 컴퓨터에서 ansible 전용 `ansible` 사용자를 생성하세요:

```
$ sudo useradd ansible
$ sudo usermod -aG wheel ansible
```

이 사용자에게 암호를 설정하세요:

```
$ sudo passwd ansible
```

Sudoers 구성을 수정하여 `wheel` 그룹의 구성원이 암호 없이 sudo를 실행할 수 있도록 변경하세요:

```
$ sudo visudo
```

여기서 우리의 목표는 기본 설정 부분의 주석 처리를 제거하고 NOPASSWD 옵션을 주석 처리를 제거하여 다음과 같이 변경하는 것입니다:

```
## 그룹 휠의 사람들이 모든 명령을 실행할 수 있습니다.
# %wheel  ALL=(ALL)       ALL

## 암호가 없을 경우 같은 상황
%wheel        ALL=(ALL)       NOPASSWD: ALL
```

!!! warning "주의"

    Ansible 명령을 입력할 때 다음과 같은 오류 메시지를 받으면 클라이언트 중 하나에서 이 단계를 빠뜨린 것입니다:
    `"msg": "Missing sudo password`

이제부터 관리에서 작업을 시작할 때 이 새로운 사용자로 작업을 시작하세요:

```
$ sudo su - ansible
```

### ping 모듈로 테스트

기본적으로 Ansible은 비밀번호로 로그인할 수 없습니다.

`/etc/ansible/ansible.cfg` 구성 파일의 `[defaults]/<code> 섹션에서 다음 행의 주석을 제거하고 True로 설정합니다:</p>

<pre><code>ask_pass      = True
`</pre>

rocky8 그룹의 각 서버에서 `ping`을 실행합니다.

```
# ansible rocky8 -m ping
SSH password:
172.16.1.10 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
172.16.1.11 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

!!! 참고 사항

    원격 서버의 Ansible 암호를 요청받게 되는데, 이는 보안상의 문제입니다...

!!! tip "팁"

    `"msg": "to use the 'ssh' connection type with passwords, you must install the sshpass program"` 라는 오류가 발생한 경우 관리 스테이션에 `sshpass`를 설치하세요:

    ```
    $ sudo dnf install sshpass
    ```

!!! abstract "개요"

    이제 이 문서에서 이전에 작동하지 않았던 명령을 테스트할 수 있습니다.

## 키 인증

암호 인증은 훨씬 더 안전한 프라이빗/퍼블릭 키 인증으로 대체됩니다.

### SSH 키 생성

`ansible` 사용자가 관리 스테이션에서 `ssh-keygen` 명령으로 이중 키를 생성합니다.

```
[ansible]$ ssh-keygen
Generating public/private rsa key pair.
Enter file in which to save the key (/home/ansible/.ssh/id_rsa):
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /home/ansible/.ssh/id_rsa.
Your public key has been saved in /home/ansible/.ssh/id_rsa.pub.
The key fingerprint is:
SHA256:Oa1d2hYzzdO0e/K10XPad25TA1nrSVRPIuS4fnmKr9g ansible@localhost.localdomain
The key's randomart image is:
+---[RSA 3072]----+
|           .o . +|
|           o . =.|
|          . . + +|
|         o . = =.|
|        S o = B.o|
|         = + = =+|
|        . + = o+B|
|         o + o *@|
|        . Eoo .+B|
+----[SHA256]-----+

```

퍼블릭 키는 서버에 복사할 수 있습니다.

```
# ssh-copy-id ansible@172.16.1.10
# ssh-copy-id ansible@172.16.1.11
```

다음 줄을 주석 처리하여 비밀번호 인증을 방지하도록 `/etc/ansible/ansible.cfg` 설정 파일의 `[defaults]` 섹션을 다시 주석 처리하세요:

```
#ask_pass      = True
```

### 프라이빗키 인증 테스트

다음 테스트에서는 원격 명령 실행을 허용하는 `shell` 모듈을 사용합니다:

```
# ansible rocky8 -m shell -a "uptime"
172.16.1.10 | SUCCESS | rc=0 >>
 12:36:18 up 57 min,  1 user,  load average: 0.00, 0.00, 0.00

172.16.1.11 | SUCCESS | rc=0 >>
 12:37:07 up 57 min,  1 user,  load average: 0.00, 0.00, 0.00
```

암호가 필요하지 않으며 프라이빗/퍼블릭 키 인증이 작동합니다!

!!! 참고 사항

    운영 환경에서는 이제 보안을 강화하기 위해 이전에 설정한 `ansible` 암호를 제거해야 합니다(이제 인증 암호가 필요하지 않음).

## Ansible 사용

Ansible은 셸에서 또는 플레이북을 통해 사용할 수 있습니다.

### 모듈

카테고리별로 분류된 모듈 목록은 [여기](https://docs.ansible.com/ansible/latest/collections/index_module.html)에서 찾을 수 있습니다. Ansible은 750개 이상의 모듈을 제공합니다!

모듈은 모듈 컬렉션으로 그룹화되며 그 목록은 [여기](https://docs.ansible.com/ansible/latest/collections/index.html)에서 찾을 수 있습니다.

컬렉션은 플레이북, 역할, 모듈 및 플러그인을 포함할 수 있는 Ansible 콘텐츠의 배포 형식입니다.

모듈은 `ansible` 명령의 `-m` 옵션으로 호출됩니다.

```
ansible <host-pattern> [-m module_name] [-a args] [options]
```

거의 모든 필요에 맞는 모듈이 있습니다! 따라서 쉘 모듈을 사용하는 대신 필요에 맞는 모듈을 찾는 것이 좋습니다.

각 필요 범주에는 자체 모듈이 있습니다. 다음은 일부 목록입니다.

| 유형        | 예시                                                   |
| --------- | ---------------------------------------------------- |
| 시스템 관리    | `user`(사용자 관리), `group`(그룹 관리) 등                     |
| 소프트웨어 관리  | `dnf`,`yum`, `apt`, `pip`, `npm`                     |
| 파일 관리     | `copy`, `fetch`, `lineinfile`, `template`, `archive` |
| 데이터베이스 관리 | `mysql`, `postgresql`, `redis`                       |
| 클라우드 관리   | `amazon S3`, `cloudstack`, `openstack`               |
| 클러스터 관리   | `consul`, `zookeeper`                                |
| 명령 전송     | `shell`, `script`, `expect`                          |
| 다운로드      | `get_url`                                            |
| 소스 관리     | `git`, `gitlab`                                      |

#### 소프트웨어 설치 예시

`dnf` 모듈을 사용하면 대상 클라이언트에 소프트웨어를 설치할 수 있습니다.

```
# ansible rocky8 --become -m dnf -a name="httpd"
172.16.1.10 | SUCCESS => {
    "changed": true,
    "msg": "",
    "rc": 0,
    "results": [
      ...
      \n\nComplete!\n"
    ]
}
172.16.1.11 | SUCCESS => {
    "changed": true,
    "msg": "",
    "rc": 0,
    "results": [
      ...
    \n\nComplete!\n"
    ]
}
```

설치된 소프트웨어는 서비스이므로 이제 `systemd` 모듈로 시작해야 합니다.

```
# ansible rocky8 --become  -m systemd -a "name=httpd state=started"
172.16.1.10 | SUCCESS => {
    "changed": true,
    "name": "httpd",
    "state": "started"
}
172.16.1.11 | SUCCESS => {
    "changed": true,
    "name": "httpd",
    "state": "started"
}
```

!!! tip "팁"

    마지막 2개의 명령을 두 번 실행해 보세요. 처음에는 Ansible이 명령에 설정한 상태에 도달하기 위해 조치를 취할 것입니다. 두 번째로는 상태가 이미 도달되었다는 것을 감지하여 아무 작업도 수행하지 않을 것입니다!

### 연습 문제

Ansible에 대해 더 알아보고 Ansible 문서를 검색하는 데 익숙해지기 위해 진행하기 전에 다음 연습을 수행해 보세요:

* 파리, 도쿄, 뉴욕 그룹 만들기
* `supervisor`사용자 생성
* 사용자의 uid를 10000으로 변경
* 사용자가 Paris 그룹에 속하도록 변경
* Tree 소프트웨어 설치
* crond 서비스 중지
* `644` 권한으로 빈 파일 만들기
* 클라이언트 배포 업데이트
* 클라이언트 다시 시작

!!! warning "주의"

    쉘 모듈을 사용하지 마십시오. 해당 모듈에 대한 설명서를 참조하십시오!

#### `setup` 모듈: 팩트 소개

시스템 팩트는 `setup` 모듈을 통해 Ansible에서 검색한 변수입니다.

간단한 명령을 통해 얼마나 많은 정보를 쉽게 검색할 수 있는지 파악하기 위해 클라이언트의 다양한 사실을 살펴보세요.

플레이북에서 팩트를 사용하는 방법과 자체 팩트를 만드는 방법은 나중에 살펴보겠습니다.

```
# ansible ansible_clients -m setup | less
192.168.1.11 | SUCCESS => {
    "ansible_facts": {
        "ansible_all_ipv4_addresses": [
            "192.168.1.11"
        ],
        "ansible_all_ipv6_addresses": [
            "2001:861:3dc3:fcf0:a00:27ff:fef7:28be",
            "fe80::a00:27ff:fef7:28be"
        ],
        "ansible_apparmor": {
            "status": "disabled"
        },
        "ansible_architecture": "x86_64",
        "ansible_bios_date": "12/01/2006",
        "ansible_bios_vendor": "innotek GmbH",
        "ansible_bios_version": "VirtualBox",
        "ansible_board_asset_tag": "NA",
        "ansible_board_name": "VirtualBox",
        "ansible_board_serial": "NA",
        "ansible_board_vendor": "Oracle Corporation",
        ...
```

이제 우리는 Ansible을 사용하여 명령 줄에서 원격 서버를 구성하는 방법을 보았으므로, 플레이북의 개념을 소개할 수 있게 되었습니다. 플레이북은 Ansible을 사용하는 또 다른 방법으로, 코드를 재사용하기 쉽게 만들어주는 것이지만 크게 복잡하지는 않습니다.

## 플레이북

Ansible의 플레이북은 원격 시스템에 적용할 정책을 설명하여 구성을 강제화합니다. 플레이북은 `yaml` 형식으로 그룹화된 일련의 작업(task)을 포함하는 이해하기 쉬운 텍스트 형식으로 작성됩니다.

!!! 참고 사항

    [여기](https://docs.ansible.com/ansible/latest/reference_appendices/YAMLSyntax.html)에서 yaml에 대해 자세히 알아보세요.

```
ansible-playbook <file.yml> ... [options]
```

옵션은 `ansible` 명령과 동일합니다.

다음과 같은 오류 코드를 반환합니다:

| 코드    | 오류                   |
| ----- | -------------------- |
| `0`   | 정상 또는 일치하는 호스트 없음    |
| `1`   | 오류                   |
| `2`   | 하나 이상의 호스트에서 오류 발생   |
| `3`   | 하나 이상의 호스트에 연결할 수 없음 |
| `4`   | 오류 분석                |
| `5`   | 잘못되었거나 불완전한 옵션       |
| `99`  | 사용자에 의해 실행 중지됨       |
| `250` | 예상치 못한 오류            |

!!! 참고 사항

    목표로하는 대상과 일치하는 호스트가 없을 때 `ansible`은 "정상"을 반환하므로, 이 점에 유의해야 합니다!

### Apache 및 MySQL 플레이북의 예

다음 플레이북을 사용하면 대상 서버에 Apache 및 MariaDB를 설치할 수 있습니다.

다음 내용을 갖는 `test.yml` 파일을 생성하세요:

```
---
- hosts: rocky8 <1>
  become: true <2>
  become_user: root

  tasks:

    - name: ensure apache is at the latest version
      dnf: name=httpd,php,php-mysqli state=latest

    - name: ensure httpd is started
      systemd: name=httpd state=started

    - name: ensure mariadb is at the latest version
      dnf: name=mariadb-server state=latest

    - name: ensure mariadb is started
      systemd: name=mariadb state=started
...
```

* <1> 대상 그룹 또는 대상 서버는 인벤토리에 존재해야 합니다.
* <2> 연결되면 사용자는 기본적으로 `sudo`를 통해 `root`가 됩니다.

플레이북 실행은 `ansible-playbook` 명령으로 수행됩니다.

```
$ ansible-playbook test.yml

PLAY [rocky8] ****************************************************************

TASK [setup] ******************************************************************
ok: [172.16.1.10]
ok: [172.16.1.11]

TASK [ensure apache is at the latest version] *********************************
ok: [172.16.1.10]
ok: [172.16.1.11]

TASK [ensure httpd is started] ************************************************
changed: [172.16.1.10]
changed: [172.16.1.11]

TASK [ensure mariadb is at the latest version] **********************************
changed: [172.16.1.10]
changed: [172.16.1.11]

TASK [ensure mariadb is started] ***********************************************
changed: [172.16.1.10]
changed: [172.16.1.11]

PLAY RECAP *********************************************************************
172.16.1.10             : ok=5    changed=3    unreachable=0    failed=0
172.16.1.11             : ok=5    changed=3    unreachable=0    failed=0
```

가독성을 높이기 위해 플레이북을 완전한 yaml 형식으로 작성하는 것이 권장됩니다. 이전 예제에서 인수는 모듈과 동일한 줄에 주어지고, 인자의 값은 이름과 `=`로 분리된 형식으로 주어졌습니다. 동일한 플레이북을 완전한 yaml 형식으로 살펴보세요:

```
---
- hosts: rocky8
  become: true
  become_user: root

  tasks:

    - name: ensure apache is at the latest version
      dnf:
        name: httpd,php,php-mysqli
        state: latest

    - name: ensure httpd is started
      systemd:
        name: httpd
        state: started

    - name: ensure mariadb is at the latest version
      dnf:
        name: mariadb-server
        state: latest

    - name: ensure mariadb is started
      systemd:
        name: mariadb
        state: started
...
```

!!! tip "Tip"

    `dnf`는 목록을 인수로 제공할 수 있는 모듈 중 하나입니다.

컬렉션에 대한 참고 사항: Ansible은 이제 컬렉션 형식의 모듈을 제공합니다. 일부 모듈은 `ansible.builtin` 컬렉션 내에서 기본적으로 제공되며, 다른 모듈은 수동으로 설치해야 합니다. 예를 들면 다음과 같습니다:

```
ansible-galaxy collection install [collectionname]
```
여기서 [collectionname]은 컬렉션의 이름입니다(여기서 대괄호는 이것을 실제 컬렉션 이름으로 대체해야 할 필요성을 강조하는 데 사용되며 명령의 일부가 아닙니다).

이전 예제는 다음과 같이 작성해야 합니다.

```
---
- hosts: rocky8
  become: true
  become_user: root

  tasks:

    - name: ensure apache is at the latest version
      ansible.builtin.dnf:
        name: httpd,php,php-mysqli
        state: latest

    - name: ensure httpd is started
      ansible.builtin.systemd:
        name: httpd
        state: started

    - name: ensure mariadb is at the latest version
      ansible.builtin.dnf:
        name: mariadb-server
        state: latest

    - name: ensure mariadb is started
      ansible.builtin.systemd:
        name: mariadb
        state: started
...
```

플레이북은 하나의 대상으로 제한되지 않습니다.

```
---
- hosts: webservers
  become: true
  become_user: root

  tasks:

    - name: ensure apache is at the latest version
      ansible.builtin.dnf:
        name: httpd,php,php-mysqli
        state: latest

    - name: ensure httpd is started
      ansible.builtin.systemd:
        name: httpd
        state: started

- hosts: databases
  become: true
  become_user: root

    - name: ensure mariadb is at the latest version
      ansible.builtin.dnf:
        name: mariadb-server
        state: latest

    - name: ensure mariadb is started
      ansible.builtin.systemd:
        name: mariadb
        state: started
...
```

플레이북의 구문을 확인할 수 있습니다.

```
$ ansible-playbook --syntax-check play.yml
```

yaml에 "linter"를 사용할 수도 있습니다.

```
$ dnf install -y yamllint
```

그런 다음 플레이북의 yaml 구문을 확인합니다.

```
$ yamllint test.yml
test.yml
  8:1       error    syntax error: could not find expected ':' (syntax)
```

## 연습 결과

* 파리, 도쿄, 뉴욕 그룹 만들기
* `supervisor`사용자 생성
* 사용자의 uid를 10000으로 변경
* 사용자가 Paris 그룹에 속하도록 변경
* Tree 소프트웨어 설치
* crond 서비스 중지
* `0644` 권한이 있는 빈 파일 만들기
* 클라이언트 배포 업데이트
* 클라이언트 다시 시작

```
ansible ansible_clients --become -m group -a "name=Paris"
ansible ansible_clients --become -m group -a "name=Tokio"
ansible ansible_clients --become -m group -a "name=NewYork"
ansible ansible_clients --become -m user -a "name=Supervisor"
ansible ansible_clients --become -m user -a "name=Supervisor uid=10000"
ansible ansible_clients --become -m user -a "name=Supervisor uid=10000 groups=Paris"
ansible ansible_clients --become -m dnf -a "name=tree"
ansible ansible_clients --become -m systemd -a "name=crond state=stopped"
ansible ansible_clients --become -m copy -a "content='' dest=/tmp/test force=no mode=0644"
ansible ansible_clients --become -m dnf -a "name=* state=latest"
ansible ansible_clients --become -m reboot
```
