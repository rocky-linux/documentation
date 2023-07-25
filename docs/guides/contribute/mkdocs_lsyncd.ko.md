---
title: 로컬 문서 - LXD
author: Steven Spencer
contributors: Ezequiel Bruni
tested_with: 8.5, 8.6
tags:
  - contribute
  - local envirmonent lxd
---

# 소개

`mkdocs` 사본을 실행하여 Rocky Linux 문서가 실제 시스템에 통합될 때 어떻게 표시되는지 정확히 확인할 수 있는 여러 가지 방법이 있습니다. 이 특정 문서는 로컬 워크스테이션에서 LXD 컨테이너를 사용하여 `mkdocs`의 Python 코드를 다른 프로젝트와 분리하는 방법에 대해 다룹니다.

워크스테이션의 코드에 문제를 일으키지 않도록 프로젝트를 분리하는 것이 권장됩니다.

이것은 [Docker 버전](rockydocs_web_dev.md)에 대한 파트너 문서이기도 합니다.

## 전제 조건 및 가정

당신이 알아야 할/알고/있어야 할 몇 가지 사항:

* 커맨드 라인에 대한 익숙하고 편안함
* 편집, SSH, 동기화 도구 사용에 익숙하거나 따라하고 배울 준비가 되어 있음
* LXD에 대해 참조합니다 - [서버에서 LXD를 구축하고 사용하는 방법](../../books/lxd_server/00-toc.md)에 대한 긴 문서가 있지만, 여기서는 Linux 워크스테이션에 기본 설치만 사용합니다. 이 문서는 이미 다른 목적으로 LXD를 사용하고 있다고 가정하며, LXD의 빌드 및 초기화를 다루지 않습니다.
* 파일 미러링에 `lsyncd`를 사용할 예정이며 [여기에서](../backup/mirroring_lsyncd.md) 관련 문서를 찾을 수 있습니다.
* [이 문서](../security/ssh_public_private_keys.md)를 사용하여 로컬 워크스테이션의 사용자 및 "root" 에 대한 공개 키를 생성해야 합니다.
* 이하의 예제에서는 브리지 인터페이스가 10.56.233.1에 실행되며, 컨테이너는 10.56.233.189에 실행되는 것으로 가정합니다.
* 이 문서에서 "youruser"는 사용자 ID를 나타내므로 해당 사용자에 맞게 바꿉니다.
* 이 문서는 이미 워크스테이션에서 documentation 저장소의 복제본을 사용하여 문서 개발을 진행하고 있다고 가정합니다.

## mkdocs 컨테이너

### 컨테이너 만들기

첫 번째 단계는 LXD 컨테이너를 만드는 것입니다. 여기에 다른 기본 설정을 사용할 필요가 없으므로 브리지 인터페이스를 사용하여 컨테이너를 빌드합니다.

워크스테이션에 `mkdocs`를 위한 Rocky 컨테이너를 추가하므로 "mkdocs"라고 부르겠습니다:

```
lxc launch images:rockylinux/8 mkdocs
```

컨테이너는 프록시로 설정되어야 합니다. 기본적으로 `mkdocs serve`가 시작되면 127.0.0.1:8000에서 실행됩니다. 컨테이너 없이 로컬 워크스테이션에 있을 때는 괜찮습니다. 로컬 워크스테이션에서 **컨테이너**로 이동할 때는 프록시 포트를 설정해야 합니다. 이것은 다음과 같이 수행됩니다:

```
lxc config device add mkdocs mkdocsport proxy listen=tcp:0.0.0.0:8000 connect=tcp:127.0.0.1:8000
```

위의 줄에서 "mkdocs"는 컨테이너 이름이고, "mkdocsport"는 프록시 포트에 임의의 이름을 지정하는 것입니다. 유형은 "proxy"이고, 그 다음에는 포트 8000의 모든 tcp 인터페이스에서 듣고 해당 컨테이너의 localhost에서 포트 8000으로 연결합니다.

!!! 참고 사항

    네트워크의 다른 컴퓨터에서 lxd 인스턴스를 실행하는 경우, 방화벽에서 포트 8000이 열려 있는지 확인해야 합니다.

### 패키지 설치

먼저 다음을 사용하여 컨테이너에 들어갑니다.

```
lxc exec mkdocs bash
```

!!! 경고 "8.x에 대한 requirements.txt의 변경 사항"

    현재 `requirements.txt`에는 Rocky Linux 8.5 또는 8.6에서 기본적으로 설치된 Python보다 더 높은 버전의 Python이 필요합니다. 다른 종속성을 모두 설치할 수 있도록 하려면 다음 작업을 수행하세요.

    ```
    sudo dnf module enable python38
    sudo dnf install python38
    ```


    그런 다음 아래에 있는 패키지에서 `python3-pip` 설치를 건너뛸 수 있습니다.

필요한 작업을 수행하려면 몇 가지 패키지가 필요합니다.

```
dnf install git openssh-server python3-pip rsync
```

설치가 완료되면 `sshd`를 활성화하고 시작해야 합니다.

```
systemctl enable --now sshd
```
### 컨테이너 사용자

우리는 root 사용자의 비밀번호를 설정하고, 그 다음으로 우리 자신의 사용자(로컬 워크스테이션에서 사용하는 사용자)를 추가하고 sudoers 목록에 추가해야 합니다. 현재 우리는 "root" 사용자입니다. 따라서 비밀번호를 변경하려면 다음과 같이 입력합니다.

```
passwd
```

그리고 보안 및 기억하기 쉬운 비밀번호를 설정합니다.

다음으로 사용자를 추가하고 비밀번호를 설정합니다:

```
adduser youruser
passwd youruser
```

그리고 사용자를 sudoers 그룹에 추가합니다.

```
usermod -aG wheel youruser
```

이 시점에서 워크스테이션에서 "root" 사용자 또는 사용자로 컨테이너에 SSH로 접속하고 비밀번호를 입력할 수 있어야 합니다. 그러므로 계속하기 전에 그 작업이 제대로 작동하는지 확인하십시오.

## 루트 및 사용자를 위한 SSH

이 절차에서는 루트 사용자(최소한)이 비밀번호를 입력하지 않고도 컨테이너에 SSH로 접속할 수 있어야 합니다. 이것은 우리가 구현할 `lsyncd` 프로세스 때문입니다. 여기서는 로컬 워크스테이션에서 루트 사용자로 sudo할 수 있다고 가정합니다.

```
sudo -s
```

또한 루트 사용자가 `./ssh` 디렉토리에 `id_rsa.pub` 키를 가지고 있다고 가정합니다. 그렇지 않은 경우 [다음 절차](../security/ssh_public_private_keys.md)를 사용하여 생성하십시오.

```
ls -al .ssh/
drwx------  2 root root 4096 Feb 25 08:06 .
drwx------ 14 root root 4096 Feb 25 08:10 ..
-rw-------  1 root root 2610 Feb 14  2021 id_rsa
-rw-r--r--  1 root root  572 Feb 14  2021 id_rsa.pub
-rw-r--r--  1 root root  222 Feb 25 08:06 known_hosts
```

위와 같이 `id_rsa.pub` 키가 존재하는 한 암호를 입력하지 않고 컨테이너에서 SSH 액세스를 얻으려면 다음을 실행하기만 하면 됩니다.

```
ssh-copy-id root@10.56.233.189
```

우리 사용자의 경우, .ssh/ 디렉토리 전체를 컨테이너로 복사해야 합니다. 이유는 GitHub에 대한 SSH를 통한 액세스가 같아야 하기 때문입니다.

모든 것을 컨테이너로 복사하려면 다음과 같이 하면 됩니다. 이때 sudo로 **하지 않고** 사용자로 하십시오.

```
scp -r .ssh/ youruser@10.56.233.189:/home/youruser/
```

다음으로 사용자로 컨테이너에 SSH로 접속합니다.

```
ssh -l 사용자 10.56.233.189
```

무엇을 해야 하는지 이해하기 위해 동일하게 만들어야 합니다. 하지만 이렇게 하려면 `ssh-agent`를 사용할 수 있는지 확인해야 합니다.

```
eval "$(ssh-agent)"
ssh-add
```

## 저장소 복제하기

두 개의 저장소를 복제해야 하지만 <code>git</code> 원격을 추가할 필요는 없습니다. 여기서 documentation 저장소는 현재 문서(워크스테이션에서 미러링된 것)와 docs를 표시하는 데만 사용될 것입니다.

rockylinux.org 저장소는 `mkdocs serve`를 실행하는 데 사용되며 미러를 소스로 사용합니다. 이 모든 단계는 루트 사용자가 아닌 사용자로 수행해야 합니다. 사용자 ID로 저장소를 복제할 수 없는 경우 `git`에 대한 ID가 잘못 설정되어 있는 **문제가 있으며**, 앞에서 다시 키 환경을 만드는 데 대한 내용을 검토해야 합니다.

먼저 documentation을 복제합니다.

```
git clone git@github.com:rocky-linux/documentation.git
```

작업이 잘 작동한다면 docs.rockylinux.org를 복제합니다.

```
git clone git@github.com:rocky-linux/docs.rockylinux.org.git
```

모든 것이 계획대로 작동한다면 계속 진행할 수 있습니다.

## mkdocs 설정

mkdocs를 설정하는 것은 모두 `pip3`와 docs.rockylinux.org 디렉토리의 "requirements.txt" 파일을 사용하여 수행됩니다. 이 프로세스는 루트 사용자를 사용하여 시스템 디렉토리에 변경 사항을 작성하도록 요청하지만, 변경 사항을 작성하기 위해서는 대부분 root 권한으로 실행해야 합니다.

여기서는 `sudo`를 사용하여 작업합니다.

먼저 디렉토리로 이동합니다:

```
cd docs.rockylinux.org
```

그런 다음 다음과 같이 실행합니다:

```
sudo pip3 install -r requirements.txt
```

다음으로 추가 디렉토리로 `mkdocs`를 설정해야 합니다.  현재 `mkdocs`는 docs 디렉토리를 생성하고 그 아래에 documentation/docs 디렉토리를 링크해야 합니다. 이 모든 작업은 다음과 같이 수행합니다:

```
mkdir docs
cd docs
ln -s ../../documentation/docs
```
### mkdocs 테스트

이제 `mkdocs`를 설정했으므로 서버를 시작해 봅시다. 기억하세요, 이 프로세스는 이것이 프로덕션 환경처럼 보인다는 경고를 표시할 것입니다. 따라서 경고를 무시하세요. 다음과 같이 `mkdocs serve`를 시작합니다.

```
mkdocs serve -a 0.0.0.0:8000
```

콘솔에 다음과 같은 내용이 표시되어야 합니다.

```
INFO     -  Building documentation...
WARNING  -  Config value: 'dev_addr'. Warning: The use of the IP address '0.0.0.0' suggests a production environment or the use of a
            proxy to connect to the MkDocs server. However, the MkDocs' server is intended for local development purposes only. Please
            use a third party production-ready server instead.
INFO     -  Adding 'sv' to the 'plugins.search.lang' option
INFO     -  Adding 'it' to the 'plugins.search.lang' option
INFO     -  Adding 'es' to the 'plugins.search.lang' option
INFO     -  Adding 'ja' to the 'plugins.search.lang' option
INFO     -  Adding 'fr' to the 'plugins.search.lang' option
INFO     -  Adding 'pt' to the 'plugins.search.lang' option
WARNING  -  Language 'zh' is not supported by lunr.js, not setting it in the 'plugins.search.lang' option
INFO     -  Adding 'de' to the 'plugins.search.lang' option
INFO     -  Building en documentation
INFO     -  Building de documentation
INFO     -  Building fr documentation
INFO     -  Building es documentation
INFO     -  Building it documentation
INFO     -  Building ja documentation
INFO     -  Building zh documentation
INFO     -  Building sv documentation
INFO     -  Building pt documentation
INFO     -  [14:12:56] Reloading browsers
```

그리고 이제 진실의 순간입니다! 위의 모든 작업을 올바르게 수행했다면 웹 브라우저를 열고 포트:8000에서 컨테이너의 IP로 이동하여 설명서 사이트를 볼 수 있어야 합니다.

이 예에서는 브라우저 주소에 다음을 입력합니다(**참고사항:** URL 손상을 방지하기 위해 여기서 IP는 "your-server-ip"로 변경되었습니다. IP를 대체하기만 하면 됩니다.):

```
http://your-server-ip:8000
```
## lsyncd

웹 브라우저에서 문서를 확인했다면 거의 끝났습니다. 마지막 단계는 컨테이너 내에 있는 문서를 로컬 워크스테이션의 문서와 동기화하는 것입니다.

우리는 위에서 설명한 대로 `lsyncd`를 사용하여 작업합니다.

사용 중인 Linux 버전에 따라 `lsyncd`를 다르게 설치할 수 있습니다. 이 [이 문서](../backup/mirroring_lsyncd.md)에서는 Rocky Linux에 설치하는 방법과 소스에서 설치하는 방법을 다룹니다. 다른 Linux 형식(예: Ubuntu)을 사용하는 경우 일반적으로 해당 플랫폼용 패키지가 있지만, 뉘앙스가 있을 수 있습니다.

예를 들어, Ubuntu는 설정 파일의 이름을 다르게 지정합니다. 소스에서 설치하지 않고 다른 Linux 워크스테이션 형식( Rocky Linux 이외의 것)을 사용하는 경우에도 해당 플랫폼용 패키지가 있을 수 있으니 참고하세요.

이제 우리는 Rocky Linux 워크스테이션을 사용하고 RPM 설치 방법을 사용하고 있다고 가정합니다.

### 구성

!!! note "참고사항"

    루트 사용자가 데몬을 실행해야 하므로 설정 파일과 로그를 만들려면 루트 권한이 필요합니다. 이를 위해 우리는 "sudo -s"를 가정합니다.

`lsyncd`가 기록할 로그 파일이 있어야 합니다.

```
touch /var/log/lsyncd-status.log
touch /var/log/lsyncd.log
```

또한 무시할 파일이 있는 경우를 위해 exclude 파일을 만들어야 합니다(현재 경우에는 아무 것도 제외하지 않습니다).

```
vi /etc/lsyncd.conf
```

마지막으로 구성 파일을 만들어야 합니다. 이 예제에서는 `vi`를 사용하지만 편안한 편집기를 사용하시면 됩니다.

```
vi /etc/lsyncd.conf
```

그런 다음 이 내용을 해당 파일에 복사하고 저장하세요. 사용자 이름과 자신의 컨테이너 IP로 바꿔주세요.

```
settings {
   logfile = "/var/log/lsyncd.log",
   statusFile = "/var/log/lsyncd-status.log",
   statusInterval = 20,
   maxProcesses = 1
   }

sync {
   default.rsyncssh,
   source="/home/youruser/documentation",
   host="root@10.56.233.189",
   excludeFrom="/etc/lsyncd.exclude",
   targetdir="/home/youruser/documentation",
   rsync = {
     archive = true,
     compress = false,
     whole_file = false
   },
   ssh = {
     port = 22
   }
}
```

`lsyncd`를 설치할 때 활성화했다고 가정하므로 이 시점에서 프로세스를 시작하거나 다시 시작해야 합니다.

```
systemctl restart lsyncd
```

모든 것이 잘 작동하는지 확인하려면 로그-특히 `lsyncd.log`를 확인하십시오. 모든 것이 올바르게 시작된 경우 다음과 같이 표시됩니다.

```
Fri Feb 25 08:10:16 2022 Normal: --- Startup, daemonizing ---
Fri Feb 25 08:10:16 2022 Normal: recursive startup rsync: /home/youruser/documentation/ -> root@10.56.233.189:/home/youruser/documentation/
Fri Feb 25 08:10:41 2022 Normal: Startup of "/home/youruser/documentation/" finished: 0
Fri Feb 25 08:15:14 2022 Normal: Calling rsync with filter-list of new/modified files/dirs
```

## 결론

이제 로컬 워크스테이션 문서를 작업할 때마다(`git pull`이나 이 문서와 같이 문서를 작성하기 위해 브랜치를 만드는 경우) 변경 사항이 컨테이너의 문서에 표시되고, `mkdocs server`를 통해 웹 브라우저에서 내용을 확인할 수 있습니다.

모든 Python 코드는 다른 Python 코드와 분리해서 실행하는 것이 권장되는 관례입니다. LXD 컨테이너를 사용하면 이 작업을 훨씬 쉽게 수행할 수 있습니다. 이 방법이 당신에게 효과가 있는지 한번 시도해 보세요.
