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

* 커맨드 라인에 대한 익숙하고 편안함
* 편집, SSH, 동기화 도구 사용에 익숙하거나 따라하고 배울 준비가 되어 있음
* LXD 참조 - 서버에서 LXD를 구축하고 사용하는 것에 대한 장문의 문서가 [여기](../../books/lxd_server/00-toc.md)에 있지만 Linux 워크스테이션에서는 기본 설치만 사용합니다
* 미러링 파일에 `lsyncd` 사용. 관련 내용은 [이 문서](../backup/mirroring_lsyncd.md)를 참조하세요.
* [이 문서](../security/ssh_public_private_keys.md)를 사용하여 로컬 워크스테이션의 사용자 및 "root" 에 대한 공개 키를 생성해야 합니다.
* 이하의 예제에서는 브리지 인터페이스가 10.56.233.1에 실행되며, 컨테이너는 10.56.233.189에 실행되는 것으로 가정합니다.
* 이 문서에서 "youruser"는 사용자 ID를 나타내므로 해당 사용자에 맞게 바꿉니다.
* 이 문서는 이미 워크스테이션에서 documentation 저장소의 복제본을 사용하여 문서 개발을 진행하고 있다고 가정합니다.

## mkdocs 컨테이너

### 컨테이너 만들기

첫 번째 단계는 LXD 컨테이너를 생성하는 것입니다. 여기서는 컨테이너의 기본값(브리지 인터페이스)을 사용하면 됩니다.

`mkdocs`용 Rocky 컨테이너를 워크스테이션에 추가합니다. "mkdocs"라고 이름을 지정합니다.

```
lxc launch images:rockylinux/8 mkdocs
```

컨테이너는 프록시여야 합니다. 기본적으로 `mkdocs serve`가 시작되면 127.0.0.1:8000에서 실행됩니다. 이는 컨테이너 없이 로컬 워크스테이션에서 수행할 때는 괜찮습니다. 그러나 로컬 워크스테이션의 LXD **컨테이너**에 있는 경우 컨테이너를 프록시 포트로 설정해야 합니다. 다음 명령으로 이 작업을 수행하세요.

```
lxc config device add mkdocs mkdocsport proxy listen=tcp:0.0.0.0:8000 connect=tcp:127.0.0.1:8000
```

위 줄에서 "mkdocs"는 우리의 컨테이너 이름이고, "mkdocsport"는 프록시 포트에 임의로 지정하는 이름입니다. 유형은 "proxy"이며, 포트 8000의 모든 TCP 인터페이스에서 수신하고 해당 컨테이너의 로컬호스트로 8000 포트에 연결합니다.

!!! Note "참고사항"

    네트워크의 다른 컴퓨터에서 lxd 인스턴스를 실행하는 경우, 방화벽에서 포트 8000이 열려 있는지 확인해야 합니다.

### 패키지 설치

처음에는 다음 명령을 사용하여 컨테이너에 들어가세요.

```
lxc exec mkdocs bash
```

!!! 주의 ""Rocky Linux 8.x를 위한 requirements.txt의 변경 사항"

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

설치가 완료되면 `sshd`를 활성화하고 시작합니다.


```
systemctl enable --now sshd
```
### 컨테이너 사용자

루트 사용자의 암호를 설정하고, 사용자(로컬 워크스테이션에서 사용하는 사용자)를 sudoers 목록에 추가해야 합니다. 현재 루트 사용자입니다. 암호를 변경하려면 다음 명령을 입력하세요.


```
passwd
```

안전하고 기억하기 쉬운 암호를 설정합니다.

다음으로 사용자를 추가하고 암호를 설정하세요.

```
adduser youruser
passwd youruser
```

사용자를 sudoers 그룹에 추가합니다.

```
usermod -aG wheel youruser
```

이제 워크스테이션에서 루트 사용자 또는 사용자로 컨테이너에 SSH로 로그인할 수 있어야 합니다. 계속하기 전에 이를 확인하세요.

## 루트 및 사용자를 위한 SSH

이 절차에서는 루트 사용자(최소한)이 패스워드 없이 컨테이너에 SSH로 접속할 수 있어야 합니다. 이는 `lsyncd` 프로세스 때문입니다. 가정은 로컬 워크스테이션에서 루트 사용자 권한으로 sudo를 사용할 수 있다는 것입니다.

```
sudo -s
```

가정하기로는 루트 사용자가 `./ssh` 디렉토리에 `id_rsa.pub` 키를 가지고 있다고 가정합니다. 그렇지 않다면 [이 절차](../security/ssh_public_private_keys.md)를 사용하여 키를 생성하세요.

```
ls -al .ssh/
drwx------  2 root root 4096 Feb 25 08:06 .
drwx------ 14 root root 4096 Feb 25 08:10 ..
-rw-------  1 root root 2610 Feb 14  2021 id_rsa
-rw-r--r--  1 root root  572 Feb 14  2021 id_rsa.pub
-rw-r--r--  1 root root  222 Feb 25 08:06 known_hosts
```

`id_rsa.pub` 키가 위와 같이 존재한다면, 패스워드 입력 없이 컨테이너에 SSH 액세스를 얻으려면 다음과 같이 실행합니다.

```
ssh-copy-id root@10.56.233.189
```

사용자의 경우 전체 `.ssh/` 디렉토리를 컨테이너에 복사해야 합니다. 이렇게 하는 이유는 GitHub에 대한 SSH로의 접근이 동일하도록 사용자의 모든 것을 동일하게 유지하려는 것입니다.

모든 내용을 컨테이너에 복사하려면 사용자가 직접 복사하기만 하면 됩니다(sudo가 아님):

```
scp -r .ssh/ youruser@10.56.233.189:/home/youruser/
```

다음으로 사용자로 컨테이너에 SSH로 접속합니다.

```
ssh -l youruser 10.56.233.189
```

이제 모든 것을 동일하게 만들어야 합니다. `ssh-add`를 사용합니다. 이를 위해 <code>ssh-agent</code>가 사용 가능한지 확인해야 합니다.

```
eval "$(ssh-agent)"
ssh-add
```

## 저장소 복제하기

두 개의 저장소를 클론해야 합니다. 그러나 <code>git</code> 원격(remote)를 추가할 필요는 없습니다. 여기의 문서 저장소는 현재의 문서를 표시합니다(로컬 워크스테이션에서 복제된 것) 및 docs입니다.

rockylinux.org 저장소는 `mkdocs serve`를 실행하고 그 소스로 미러를 사용합니다. 이 모든 단계는 비루트 사용자로 실행하세요. 이 단계에서 userid로 저장소를 클론할 수 없다면 `git`에 대한 당신의 신원과 관련하여 문제가 있습니다. 앞의 몇 단계를 검토하여 키 환경을 재생성해야 합니다.

먼저 문서를 클론합니다.

```
git clone git@github.com:rocky-linux/documentation.git
```

다음으로 docs.rockylinux.org를 클론합니다.

```
git clone git@github.com:rocky-linux/docs.rockylinux.org.git
```

오류가 발생하는 경우 위의 단계로 돌아가 올바른지 확인한 후 계속 진행하세요.

## mkdocs 설정

필요한 플러그인은 `pip3`와 docs.rockylinux.org 디렉토리에 있는 "requirements.txt" 파일로 모두 설치합니다. 이 프로세스는 루트 사용자로 시스템 디렉토리에 변경 사항을 쓰려고 할 것입니다.

따라서 `sudo`를 사용하여 실행해야 합니다.

디렉토리로 이동합니다.

```
cd docs.rockylinux.org
```

그런 다음 실행하세요:

```
sudo pip3 install -r requirements.txt
```

그 다음에는 `mkdocs`를 추가 디렉토리로 설정해야 합니다.  `mkdocs` docs 디렉토리를 생성하고 그 하위에 documentation/docs 디렉토리를 연결해야 합니다. 다음 명령으로 수행하세요.

```
mkdir docs
cd docs
ln -s ../../documentation/docs
```
### mkdocs 테스트

이제 `mkdocs`를 설정했으므로 서버를 시작해 보세요. 이 프로세스는 production으로 보입니다만 그렇지 않습니다. 그러므로 경고를 무시하세요. 다음과 같이 `mkdocs serve`를 시작합니다.

```
mkdocs serve -a 0.0.0.0:8000
```

콘솔에 다음과 유사한 내용이 표시됩니다.

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

이제 이 순간이 참이 되었습니다! 모든 것을 올바르게 수행했다면 웹 브라우저를 열고 컨테이너의 IP와 포트 :8000으로 이동하여 문서 사이트를 확인할 수 있어야 합니다.

위 예제에서는 웹 브라우저 주소에 다음을 입력합니다. (**참고** 깨진 URL을 피하기 위해 여기서 IP는 "your-server-ip"로 변경되었습니다. 실제로는 해당 IP로 바꾸시면 됩니다.)

```
http://your-server-ip:8000
```
## `lsyncd`

웹 브라우저에서 문서를 보았다면 거의 완료되었습니다. 마지막 단계는 컨테이너의 문서를 로컬 워크스테이션의 문서와 동기화하는 것입니다.

이를 위해 이전에 언급한대로 `lsyncd`를 사용합니다.

`lsyncd`의 설치 방법은 사용하는 리눅스 버전에 따라 다릅니다. [이 문서](../backup/mirroring_lsyncd.md)에는 Rocky Linux에 설치하는 방법과 소스에서 설치하는 방법이 나와 있습니다. 다른 리눅스 종류를 사용하고 있다면(예: Ubuntu), 일반적으로 해당 플랫폼용 패키지가 있지만 세부적인 사항이 있을 수 있습니다.

예를 들어 Ubuntu의 경우 구성 파일의 이름이 다를 수 있습니다. 그냥 명심하세요. 다른 Rocky Linux 워크스테이션 타입을 사용하고 소스에서 설치하고 싶지 않다면, 해당 플랫폼용 패키지가 있을 가능성이 높습니다.

이제 Rocky Linux 워크스테이션을 사용하고 있고 포함된 문서에 있는 RPM 설치 방법을 사용한다고 가정합니다.

### 구성

!!! 참고 사항

    루트 사용자가 데몬을 실행해야 하므로 설정 파일과 로그를 만들려면 루트 권한이 필요합니다. 이를 위해 우리는 "sudo -s"를 가정합니다.

`lsyncd`가 로그를 작성할 수 있도록 몇 가지 로그 파일을 생성해야 합니다:

```
touch /var/log/lsyncd-status.log
touch /var/log/lsyncd.log
```

또한 아무 것도 제외하지 않더라도 제외 파일을 생성해야 합니다:

```
vi /etc/lsyncd.conf
```

마지막으로 설정 파일을 생성해야 합니다. 이 예제에서는 `vi`를 사용하지만 편한 에디터를 사용하셔도 괜찮습니다.

```
vi /etc/lsyncd.conf
```

그런 다음 해당 파일에 다음 내용을 넣고 저장하세요. "youruser"를 실제 사용자 이름으로, IP 주소를 사용하는 컨테이너 IP로 바꿔주세요:

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

`lsyncd`를 설치할 때 `lsyncd`를 활성화했다고 가정하면, 이 시점에서 `lsyncd`를 시작하거나 재시작하기만 하면 됩니다.

```
systemctl restart lsyncd
```

모든 것이 올바르게 시작된 경우, 특히 `lsyncd.log`를 확인하여 다음과 유사한 내용이 표시되어야 합니다:

```
Fri Feb 25 08:10:16 2022 Normal: --- Startup, daemonizing ---
Fri Feb 25 08:10:16 2022 Normal: recursive startup rsync: /home/youruser/documentation/ -> root@10.56.233.189:/home/youruser/documentation/
Fri Feb 25 08:10:41 2022 Normal: Startup of "/home/youruser/documentation/" finished: 0
Fri Feb 25 08:15:14 2022 Normal: Calling rsync with filter-list of new/modified files/dirs
```

## 결론

이제 작업하는 워크스테이션의 문서를 변경할 때마다 (`git pull` 또는 이 문서와 같이 문서를 만드는 브랜치를 생성하는 경우 등), 해당 변경 내용이 컨테이너의 문서에 반영되고 `mkdocs serve`를 사용하여 웹 브라우저에서 내용을 확인할 수 있습니다.

권장 사항은 모든 Python 코드가 다른 Python 코드와 별개로 실행되어야 한다는 것입니다. LXD 컨테이너를 사용하면 이 작업을 더 쉽게 할 수 있습니다. 이 방법을 사용해 보고 여러분에게 잘 작동하는지 확인해보세요.
