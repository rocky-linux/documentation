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

`mkdocs` 사본을 실행하여 Rocky Linux 문서가 실제 시스템에 병합될 때 어떻게 표시되는지 정확히 확인할 수 있는 여러 가지 방법이 있습니다. 이 특정 문서는 작업 중인 다른 프로젝트에서 `mkdocs`의 파이썬 코드를 분리하기 위해 로컬 워크스테이션에서 LXD 컨테이너를 사용하는 방법을 다룹니다.

워크스테이션 코드에 문제가 발생하지 않도록 프로젝트를 별도로 유지하는 것이 좋습니다.

이것은 [Docker 버전 ](rockydocs_web_dev.md)의 파트너 문서이기도 합니다.

## 전제 조건 및 가정

당신이 알아야 할/알고/있어야 할 몇 가지 사항:

* 커맨드 라인에 대한 친숙함과 편안함
* 편집, SSH 및 동기화를 위한 도구를 사용하는 것이 편하거나 기꺼이 따라하며 배울 의향이 있습니다.
* 우리는 LXD를 참조할 것입니다. 여기에서는 [서버에서 LXD를 구축하고 사용하는 방법](../../books/lxd_server/00-toc.md)에 대한 긴 문서가 있지만 Linux 워크스테이션에서 기본 설치만 사용할 것입니다. 이 문서는 이미 다른 용도로 LXD를 사용하고 있다고 가정하며 LXD의 빌드 및 초기화에 대해서는 다루지 않습니다.
* 파일 미러링에 `lsyncd`를 사용할 예정이며 [여기에서 관련 문서](../backup/mirroring_lsyncd.md)를 찾을 수 있습니다.
* [이 문서](../security/ssh_public_private_keys.md)를 사용하여 로컬 워크스테이션의 사용자 및 "루트" 사용자에 대해 생성된 공개 키가 필요합니다.
* 브리지 인터페이스는 10.56.233.1에서 실행 중이고 컨테이너는 아래 예에서 10.56.233.189에서 실행 중입니다.
* 이 문서의 "youruser"는 귀하의 사용자 ID를 나타내므로 귀하의 것으로 대체하십시오.
* 워크스테이션에 있는 문서 저장소의 복제본을 사용하여 문서 개발을 이미 수행하고 있다고 가정합니다.

## mkdocs 컨테이너

### 컨테이너 만들기

첫 번째 단계는 LXD 컨테이너를 만드는 것입니다. 여기서 기본값 이외의 다른 것을 사용할 필요가 없으므로 브리지 인터페이스를 사용하여 컨테이너를 빌드할 수 있습니다.

`mkdocs`용 워크스테이션에 Rocky 컨테이너를 추가할 것이므로 "mkdocs"라고 합니다.

```
lxc launch images:rockylinux/8 mkdocs
```

컨테이너는 프록시로 설정해야 합니다. 기본적으로 `mkdocs serve`가 시작되면 127.0.0.1:8000에서 실행됩니다. 컨테이너 없이 로컬 워크스테이션에 있을 때는 괜찮습니다. 그러나 로컬 워크스테이션의 LXD **컨테이너**에 있는 경우 프록시 포트로 컨테이너를 설정해야 합니다. 이것은 다음과 같이 수행됩니다:

```
lxc config device add mkdocs mkdocsport proxy listen=tcp:0.0.0.0:8000 connect=tcp:127.0.0.1:8000
```

위 줄에서 "mkdocs"는 컨테이너 이름이고 "mkdocsport"는 프록시 포트에 지정하는 임의의 이름이며 유형은 "proxy"입니다. 그런 다음 포트 8000의 모든 tcp 인터페이스에서 수신 대기하고, 포트 8000의 해당 컨테이너에 대한 localhost에 연결합니다.

!!! 참고 사항

    네트워크의 다른 시스템에서 lxd 인스턴스를 실행 중인 경우 방화벽에서 포트 8000이 열려 있는지 확인하십시오.

### 패키지 설치

먼저 다음을 사용하여 컨테이너에 들어갑니다.

```
lxc exec mkdocs bash
```

!!! 경고 "8.x에 대한 requirements.txt의 변경 사항"

    현재 `requirements.txt`에는 Rocky Linux 8.5 또는 8.6에 기본적으로 설치된 것보다 최신 버전의 Python이 필요합니다. 다른 모든 종속성을 설치하려면 다음을 수행하십시오.

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

루트 사용자의 암호를 설정한 다음 자체 사용자(로컬 시스템에서 사용하는 사용자)를 추가하고 sudoers 목록에 추가해야 합니다. 지금은 "루트" 사용자여야 하므로 암호 유형을 변경하려면 다음과 같이 하십시오.

```
passwd
```

그리고 비밀번호를 안전하고 기억하기 쉬운 것으로 설정하십시오.

다음으로 사용자를 추가하고 비밀번호를 설정합니다.

```
adduser youruser
passwd youruser
```

그리고 사용자를 sudoers 그룹에 추가합니다.

```
usermod -aG wheel youruser
```

이 시점에서 루트 사용자 또는 워크스테이션의 사용자를 사용하고 암호를 입력하여 컨테이너에 SSH로 연결할 수 있어야 합니다. 계속하기 전에 그렇게 할 수 있는지 확인하십시오.

## 루트 및 사용자를 위한 SSH

이 절차에서 루트 사용자(최소한)는 비밀번호를 입력하지 않고 컨테이너에 SSH로 연결할 수 있어야 합니다. 이는 우리가 구현할 `lsyncd` 프로세스 때문입니다. 여기서는 로컬 워크스테이션의 루트 사용자에게 sudo를 수행할 수 있다고 가정합니다.

```
sudo -s
```

또한 루트 사용자가 `./ssh` 디렉토리에 `id_rsa.pub` 키를 가지고 있다고 가정합니다. 그렇지 않은 경우 [이 절차](../security/ssh_public_private_keys.md)를 사용하여 생성하십시오.

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

그러나 사용자의 경우 전체 .ssh/ 디렉토리를 컨테이너에 복사해야 합니다. 그 이유는 SSH를 통한 GitHub 액세스가 동일하도록 이 사용자에 대해 모든 것을 동일하게 유지할 것이기 때문입니다.

컨테이너에 모든 것을 복사하려면 sudo가 **아닌** 사용자로서 이 작업을 수행하기만 하면 됩니다.

```
scp -r .ssh/ youruser@10.56.233.189:/home/youruser/
```

다음으로 사용자로 컨테이너에 SSH로 연결합니다.

```
ssh -l 사용자 10.56.233.189
```

우리는 모든 것을 동일하게 만들어야 하며 이는 `ssh-add`로 수행됩니다. 하지만 이렇게 하려면 `ssh-agent`를 사용할 수 있는지 확인해야 합니다. 다음을 입력하세요:

```
eval "$(ssh-agent)"
ssh-add
```

## 저장소 복제하기

두 개의 리포지토리를 복제해야 하지만 `git` 원격을 추가할 필요는 없습니다. 여기의 문서 저장소는 현재 문서(워크스테이션에서 미러링됨) 및 문서를 표시하는 데만 사용됩니다.

rockylinux.org 저장소는 `mkdocs serve`를 실행하는 데 사용되며 미러를 소스로 사용합니다. 이러한 모든 단계는 루트가 아닌 사용자로 수행해야 합니다. 리포지토리를 사용자 ID로 복제할 수 없는 경우 `git`와 관련하여 ID에 **문제가 있는 것**이므로 키 환경을 재생성하기 위한 마지막 몇 단계(위)를 검토해야 합니다.

먼저 문서를 복제합니다.

```
git clone git@github.com:rocky-linux/documentation.git
```

작동한다고 가정하고 docs.rockylinux.org를 복제합니다.

```
git clone git@github.com:rocky-linux/docs.rockylinux.org.git
```

모든 것이 계획대로 작동했다면 계속 진행할 수 있습니다.

## mkdocs 설정

필요한 플러그인 설치는 docs.rockylinux.org 디렉토리의 `pip3` 및 "requirements.txt" 파일로 모두 완료됩니다. 이 프로세스는 이것을 위해 루트 사용자를 사용하는 것에 대해 당신과 논쟁을 벌일 것이지만, 변경 사항을 시스템 디렉토리에 쓰려면 거의 루트로 실행해야 합니다.

여기에서 `sudo`로 이 작업을 수행하고 있습니다.

다음 디렉토리로 변경하십시오.

```
cd docs.rockylinux.org
```

그런 다음, 아래 명령을 실행합니다.

```
sudo pip3 install -r requirements.txt
```

다음으로 추가 디렉토리로 `mkdocs`를 설정해야 합니다. 현재 `mkdocs`는 docs 디렉토리를 생성한 다음 그 아래에 링크된 documentation/docs 디렉토리를 필요로 합니다. 이것은 다음과 같이 수행됩니다:

```
mkdir docs
cd docs
ln -s ../../documentation/docs
```
### mkdocs 테스트

이제 `mkdocs` 설정이 완료되었으므로 서버를 시작해 보겠습니다. 기억하세요, 이 프로세스는 이것이 프로덕션인 것처럼 보인다고 주장할 것입니다. 그렇지 않으므로 경고를 무시하십시오. 다음을 사용하여 `mkdocs serve`를 시작합니다.

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

그리고 이제 진실의 순간입니다!  위의 모든 작업을 올바르게 수행했다면 웹 브라우저를 열고 포트:8000에서 컨테이너의 IP로 이동하여 설명서 사이트를 볼 수 있어야 합니다.

이 예에서는 브라우저 주소에 다음을 입력합니다(**참고사항:** URL 손상을 방지하기 위해 여기서 IP는 "your-server-ip"로 변경되었습니다. IP를 대체하기만 하면 됩니다.):

```
http://your-server-ip:8000
```
## lsyncd

웹 브라우저에서 설명서를 보셨다면 거의 다 온 것입니다. 마지막 단계는 컨테이너에 있는 문서를 로컬 워크스테이션에 있는 문서와 동기화 상태로 유지하는 것입니다.

여기서는 위에서 언급한 대로 `lsyncd`를 사용하여 이 작업을 수행하고 있습니다.

사용 중인 Linux 버전에 따라 `lsyncd`가 다르게 설치됩니다. [이 문서](../backup/mirroring lsyncd.md)는 Rocky Linux 및 소스에서 설치하는 방법을 다룹니다. 다른 Linux 유형(예: Ubuntu)을 사용하는 경우 일반적으로 자체 패키지가 있지만 미묘한 차이가 있습니다.

예를 들어 Ubuntu는 구성 파일의 이름을 다르게 지정합니다. Rocky Linux 이외의 다른 Linux 워크스테이션 유형을 사용 중이고 소스에서 설치하지 않으려는 경우 플랫폼에 사용할 수 있는 패키지가 있을 수 있습니다.

지금은 Rocky Linux 워크스테이션을 사용하고 포함된 문서의 RPM 설치 방법을 사용하고 있다고 가정합니다.

### 구성

!!! 참고사항
     루트 사용자는 데몬을 실행해야 하므로 구성 파일과 로그를 생성하려면 루트여야 합니다. 이를 위해 우리는 `sudo -s`를 가정합니다.

`lsyncd`가 쓸 수 있는 몇 가지 로그 파일이 있어야 합니다.

```
touch /var/log/lsyncd-status.log
touch /var/log/lsyncd.log
```

이 경우 아무것도 제외하지 않더라도 제외 파일도 생성해야 합니다.

```
touch /etc/lsyncd.exclude
```

마지막으로 구성 파일을 만들어야 합니다. 이 예에서는 편집기로 `vi`를 사용하고 있지만 다음 중 편한 편집기를 사용할 수 있습니다.

```
vi /etc/lsyncd.conf
```

그런 다음 이 콘텐츠를 해당 파일에 배치하고 저장합니다. "youruser"를 실제 사용자로 바꾸고 IP 주소를 자신의 컨테이너 IP로 바꾸십시오.

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

제대로 작동하는지 확인하려면 로그, 특히 `lsyncd.log`를 확인하세요. 모든 것이 올바르게 시작된 경우 다음과 같이 표시됩니다.

```
Fri Feb 25 08:10:16 2022 Normal: --- Startup, daemonizing ---
Fri Feb 25 08:10:16 2022 Normal: recursive startup rsync: /home/youruser/documentation/ -> root@10.56.233.189:/home/youruser/documentation/
Fri Feb 25 08:10:41 2022 Normal: Startup of "/home/youruser/documentation/" finished: 0
Fri Feb 25 08:15:14 2022 Normal: Calling rsync with filter-list of new/modified files/dirs
```

## 결론

지금 워크스테이션 문서를 작업할 때 `git pull` 또는 문서를 만들기 위해 생성한 브랜치(이와 같은 경우)에 관계없이 컨테이너의 문서에 변경 사항이 표시되는 것을 볼 수 있습니다. `mkdocs server`는 웹 브라우저에 콘텐츠를 표시합니다.

모든 Python 코드를 개발 중인 다른 Python 코드와 별도로 실행하는 것이 좋습니다. LXD 컨테이너를 사용하면 훨씬 쉽게 만들 수 있습니다. 이 방법을 시도해보고 효과가 있는지 확인하십시오.
