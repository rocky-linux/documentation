---
title: 백업 솔루션 - rsnapshot
author: Steven Spencer
contributors: Ezequiel Bruni
tested_with: 8.5, 8.6, 9.0
tags:
  - backup
  - rsnapshot
---

# 백업 솔루션 - _rsnapshot_

## 필요 사항

  * 추가 리포지토리 및 스냅샷 설치 방법을 알고 있어야 합니다.
  * 외부 드라이브, 원격 파일 시스템 등 외부 파일 시스템을 마운트하는 방법에 대해 알아야 합니다.
  * 편집기(여기서는 `vi`를 사용하지만 좋아하는 편집기를 사용할 수 있습니다) 사용법을 알고 있어야 합니다.
  * 간단한 BASH 스크립팅에 대한 지식이 있어야 합니다.
  * 루트 사용자의 crontab을 변경하는 방법을 알고 있어야 합니다.
  * SSH 공개 및 개인 키에 대한 지식(다른 서버에서 원격 백업을 실행할 경우에만 해당)이 있어야 합니다.

## 소개

_rsnapshot_ 은 강력한 백업 유틸리티로, Linux 기반의 모든 머신에 설치할 수 있습니다. 하나의 기계를 로컬로 백업하거나, 예를 들어 서버와 같은 여러 기계를 한 대의 기계에서 백업할 수도 있습니다.

_rsnapshot_ 은 `rsync`를 사용하며, Perl로 작성되어 라이브러리 의존성이 전혀 없습니다. 설치에는 특별한 요구사항이 없습니다. Rocky Linux의 경우, EPEL 저장소를 사용하여 _rsnapshot_ 을 설치할 수 있습니다. Rocky Linux 9.0의 초기 릴리스 이후에는 EPEL에 _rsnapshot_ 패키지가 포함되지 않은 경우가 있었습니다. 이 지침에는 이러한 상황이 다시 발생할 경우를 대비하여 소스에서 설치하는 방법도 포함되어 있습니다.

이 문서는 Rocky Linux에서의 _rsnapshot_ 설치에 대해서만 다룹니다.

=== "EPEL Install"

    ## _rsnapshot_ 설치
    
    여기서 보여지는 모든 명령은 서버나 워크스테이션의 명령줄에서 호출되는 것입니다.
    
    ### EPEL 저장소 설치하기
    
    _rsnapshot_ 을 설치하기 위해 Fedora의 EPEL 소프트웨어 저장소가 필요합니다. 저장소를 설치하려면 다음 명령을 사용하세요.

    ```
    sudo dnf install epel-release
    ```


    이제 저장소가 활성화되었습니다.
    
    ### _rsnapshot_ 패키지 설치
    
    다음으로 _rsnapshot_ 및 몇 가지 기타 필요한 도구를 설치합니다. 이러한 도구는 이미 설치되어 있을 가능성이 높습니다.

    ``` 
    sudo dnf install rsnapshot openssh-server rsync
    ```


    누락된 종속성이 있으면 해당 내용이 표시되며, 그냥 계속 진행하면 됩니다. 예를 들어,

    ```
    dnf install rsnapshot
    Last metadata expiration check: 0:00:16 ago on Mon Feb 22 00:12:45 2021.
    Dependencies resolved.
    ========================================================================================================================================
    Package                           Architecture                 Version                              Repository                    Size
    ========================================================================================================================================
    Installing:
    rsnapshot                         noarch                       1.4.3-1.el8                          epel                         121 k
    Installing dependencies:
    perl-Lchown                       x86_64                       1.01-14.el8                          epel                          18 k
    rsync                             x86_64                       3.1.3-9.el8                          baseos                       404 k

    Transaction Summary
    ========================================================================================================================================
    Install  3 Packages

    Total download size: 543 k
    Installed size: 1.2 M
    Is this ok [y/N]: y
    ```

=== "Source Install"

    <em x-id="4">rsnapshot</em> 을 소스에서 설치하는 것은 어렵지 않습니다. 그러나 단점도 있습니다. 새로운 버전이 출시되면 소스에서 새로 설치해야 하기 때문에 EPEL 설치 방법과 달리 <code>dnf 업그레이드로 간단하게 최신 상태를 유지할 수 없습니다. 
    
    ### 개발 도구 설치 및 소스 다운로드
    
    먼저 '개발 도구' 그룹을 설치해야 합니다.
    </code>

    ```
    dnf groupinstall 'Development Tools'
    ```


    그리고 다음과 같은 몇 가지 패키지가 더 필요합니다.

    ```
    dnf install wget unzip rsync openssh-server
    ```


    다음으로 GitHub 저장소에서 소스 파일을 다운로드해야 합니다. 다양한 방법으로 할 수 있지만, 이 경우 가장 쉬운 방법은 저장소에서 ZIP 파일을 다운로드하는 것입니다.

    1. https://github.com/rsnapshot/rsnapshot으로 이동합니다.
    2. 오른쪽의 초록색 "Code" 버튼을 클릭합니다. ![Code](images/code.png)
    3. "Download ZIP"을 우클릭하여 링크 주소를 복사합니다. ![Zip](images/zip.png)
    4. `wget` 또는 `curl`을 사용하여 복사된 링크를 다운로드합니다. 예시:
    ```
    wget https://github.com/rsnapshot/rsnapshot/archive/refs/heads/master.zip
    ```
    5. `master.zip` 파일을 압축 해제합니다.
    ```
    unzip master.zip
    ```


    ### 소스 구축

    이제 모든 파일을 가져왔으니 다음 단계는 빌드입니다. `master.zip` 파일을 압축 해제할 때 `rsnapshot-master` 디렉토리가 만들어집니다. 이 디렉토리로 이동하여 빌드 절차를 진행해야 합니다. 빌드는 모든 패키지 기본값을 사용하고 있으므로 다른 값을 원한다면 약간의 조사가 필요합니다. 또한 이 단계는 [GitHub 설치](https://github.com/rsnapshot/rsnapshot/blob/master/INSTALL.md) 페이지에서 직접 가져온 것입니다.

    ```
    cd rsnapshot-master
    ```

    configure 스크립트를 생성하기 위해 `authogen.sh` 스크립트를 실행합니다.

    ```
    ./autogen.sh
    ```

    !!! !!!

        다음과 같은 여러 줄이 표시될 수 있습니다.

        ```
        fatal: git 저장소(또는 상위 디렉토리)가 아님: .git
        ```

        이들은 치명적이지 않습니다.

    다음으로 구성 디렉토리 세트로 `configure`를 실행해야 합니다.

    ```
    ./configure --sysconfdir=/etc
    ```

    마지막으로 `make install`을 실행합니다.

    ```
    sudo make install
    ```

    이 과정 동안 `rsnapshot.conf` 파일이 `rsnapshot.conf.default`로 생성됩니다. 이것을 `rsnapshot.conf`에 복사한 다음 시스템에 필요한 내용에 맞게 편집해야 합니다.

    ```
    sudo cp /etc/rsnapshot.conf.default /etc/rsnapshot.conf
    ```

    이로써 구성 파일을 복사하는 작업을 끝냈습니다. 아래 "rsnapshot 구성" 섹션에서는 이 구성 파일에서 필요한 변경 사항에 대해 다룹니다.

## 백업용 드라이브 또는 파일 시스템 마운트

이 단계에서는 시스템을 백업하는 데 사용하는 외부 USB 드라이브와 같은 드라이브를 마운트하는 방법을 보여줍니다. 이 특정 단계는 첫 번째 예시에서와 같이 단일 컴퓨터 또는 서버를 백업하는 경우에만 필요합니다.

1. USB 드라이브를 연결합니다.
2. `dmesg | grep sd`를 입력하면 사용할 드라이브가 표시됩니다. 이 경우 _sda1_ 입니다.  
   예: `EXT4-fs(sda1): ext4 하위 시스템을 사용하여 ext2 파일 시스템 마운트`.
3. 불행하게도(혹은 다행히도, 당신의 의견에 따라 다를 수 있습니다), 대부분의 최신 리눅스 데스크톱 운영체제는 가능한 경우 드라이브를 자동으로 마운트합니다. 이는 다양한 요인에 따라 rsnapshot이 드라이브를 추적하지 못할 수 있다는 것을 의미합니다. 드라이브를 매번 동일한 위치에 "마운트"하고 파일을 사용할 수 있도록 하려면 다음과 같이 수행합니다.
4. 외부 드라이브를 언마운트하려면 `sudo umount /dev/sda1`을 입력합니다.
5. 다음으로 백업용 마운트 지점을 생성합니다: `sudo mkdir /mnt/backup`
6. 드라이브를 백업 폴더 위치에 마운트합니다: `sudo mount /dev/sda1 /mnt/backup`
7. ## 소스에서 _rsnapshot_ 설치하기
8. 마운트된 드라이브에서 백업이 계속될 수 있도록 백업을 위해 반드시 존재해야 하는 디렉토리를 생성합니다. 이 예시에서는 "storage"라는 폴더를 사용합니다: `sudo mkdir /mnt/backup/storage`

단일 컴퓨터의 경우, 드라이브를 연결할 때마다 또는 시스템이 재부팅될 때마다 `umount` 및 `mount` 단계를 반복하거나 이러한 명령을 스크립트로 자동화해야 합니다.

자동화를 권장합니다. 자동화는 시스템 관리자의 방법입니다.

## rsnapshot 구성

이 단계가 가장 중요합니다. 구성 파일을 변경할 때 실수할 수 있습니다. _rsnapshot_ 구성에는 요소들을 구분하기 위해 탭(tab)이 필요하며, 구성 파일의 맨 위에 경고 메시지가 있습니다.

공백 문자 하나만으로도 구성 전체 - 그리고 백업 -이 실패할 수 있습니다. 예를 들어 구성 파일의 상단 근처에는 `# SNAPSHOT ROOT DIRECTORY #` 섹션이 있습니다. 처음부터 이를 추가하는 경우, `snapshot_root`를 입력한 다음 탭(tab)을 누르고 `/whatever_the_path_to_the_snapshot_root_will_be/`를 입력합니다.

좋은 점은 _rsnapshot_ 에 기본으로 포함된 구성은 로컬 컴퓨터의 백업을 위해 작동하기 위해 작은 수정만 필요합니다. 하지만 편집을 시작하기 전에 구성 파일의 백업 복사본을 만드는 것이 항상 좋은 아이디어입니다:

`cp /etc/rsnapshot.conf /etc/rsnapshot.conf.bak`

## 기본 머신 또는 단일 서버 백업

이 경우 _rsnapshot_ 은 특정 컴퓨터를 백업하기 위해 로컬에서 실행됩니다. 이 예제에서는 구성 파일을 분석하고 필요한 변경 사항을 자세히 설명하겠습니다.

_/etc/rsnapshot.conf_ 파일을 열려면 `vi`(또는 선호하는 편집기로 편집)를 사용해야 합니다.

첫 번째로 바꿔야 할 것은 _snapshot_root_ 설정입니다. 기본값은 다음과 같습니다:

`snapshot_root   /.snapshots/`

이를 위에서 생성한 마운트 지점으로 변경해야 합니다. 추가로 "storage"를 붙여야 합니다.

`snapshot_root   /mnt/backup/storage/`

또한 드라이브가 마운트되지 않은 경우 백업이 실행되지 않도록 지시하고 싶습니다. 이렇게 하려면 다음과 같이 보이도록 `no_create_root` 옆에 있는 "#" 기호(설명, 파운드 기호, 숫자 기호, 해시 기호 등이라고도 함)를 제거합니다.

`no_create_root 1`

그런 다음 `# EXTERNAL PROGRAM DEPENDENCIES #` 섹션으로 이동하여 이 줄에서 주석(다시 "#" 기호)을 제거합니다.

`#cmd_cp         /usr/bin/cp`

이제 다음과 같이 표시됩니다.

`cmd_cp         /usr/bin/cp`

이 특정 구성에는 `cmd_ssh`가 필요하지 않지만 아래의 다른 옵션에는 필요하므로 활성화해도 문제가 되지 않습니다. 따라서 다음과 같은 줄을 찾으십시오.

`#cmd_ssh        /usr/bin/ssh`

그리고 "#" 기호를 제거하여 다음과 같이 표시합니다.

`cmd_ssh        /usr/bin/ssh`

다음으로 `# BACKUP LEVELS / INTERVALS #` 섹션으로 건너뛰어야 합니다.

_rsnapshot_의 이전 버전에서 `hourly, daily, monthly, yearly`에서 `alpha, beta, gamma, delta`로 변경되었습니다. 이것은 약간 혼란 스럽습니다. 사용하지 않을 간격에 설명을 추가하기만 하면 됩니다. 구성에서 델타는 이미 언급되어 있습니다.

이 예에서는 야간 백업 이외의 다른 증분 백업을 실행하지 않습니다. Alpha 와 Gamma에 주석 처리를 추가하면 됩니다. 변경이 완료되면 구성 파일은 다음과 같을 것입니다:

```
#retain  alpha   6
retain  beta    7
#retain  gamma   4
#retain delta   3
```

로그 파일 라인으로 이동합니다. 기본값은 다음과 같습니다:

`#logfile        /var/log/rsnapshot`

활성화되도록 주석을 제거하십시오.

`logfile        /var/log/rsnapshot`

마지막으로, `### BACKUP POINTS / SCRIPTS ####` 섹션으로 이동하여 `# LOCALHost` 섹션에 추가할 디렉토리를 추가합니다. 요소 사이에 스페이스를 사용하는 것이 아니라 Tab을 사용해야 합니다!

지금은 변경 사항을 작성하고(`vi`의 경우 `SHIFT :wq!`를 사용) 구성 파일을 종료합니다.

### 구성 확인

편집 중에 구성 파일에 공백이나 다른 눈에 띄는 오류를 추가하지 않았는지 확인하고자 합니다. 이를 위해 `configtest` 옵션을 사용하여 _rsnapshot_ 을 구성 파일에 대해 실행합니다:

`rsnapshot configtest`를 실행하면 오류가 없다면 `Syntax OK`가 표시됩니다.

특정 구성에 대해 `configtest`를 실행하는 습관을 기르는 것이 좋습니다. 그 이유는 **다중 시스템 또는 다중 서버 백업** 섹션으로 넘어갈 때 더욱 명백해질 것입니다.

특정 구성 파일에 대해 `configtest`를 실행하려면 -c 옵션을 사용하여 구성을 지정하십시오:

`rsnapshot -c /etc/rsnapshot.conf configtest`

## 첫 번째로 백업 실행하기

configtest가 모든 것이 정상인지 확인했으므로 이제 첫 번째 백업을 실행할 시간입니다. 원한다면 테스트 모드로 먼저 실행하여 백업 스크립트가 어떻게 작동하는지 확인할 수 있습니다.

다시 말하지만 이 경우에는 구성을 지정할 필요가 없지만, 습관적으로 지정하는 것이 좋습니다:

`rsnapshot -c /etc/rsnapshot.conf -t beta`

이렇게 하면 실제 백업이 실행될 때 무엇이 발생하는지 보여줍니다:

```
echo 1441 > /var/run/rsnapshot.pid
mkdir -m 0755 -p /mnt/backup/storage/beta.0/
/usr/bin/rsync -a --delete --numeric-ids --relative --delete-excluded \
    /home/ /mnt/backup/storage/beta.0/localhost/
mkdir -m 0755 -p /mnt/backup/storage/beta.0/
/usr/bin/rsync -a --delete --numeric-ids --relative --delete-excluded /etc/ \
    /mnt/backup/storage/beta.0/localhost/
mkdir -m 0755 -p /mnt/backup/storage/beta.0/
/usr/bin/rsync -a --delete --numeric-ids --relative --delete-excluded \
    /usr/local/ /mnt/backup/storage/beta.0/localhost/
touch /mnt/backup/storage/beta.0/
```

테스트가 기대한 대로 이루어지면 테스트하지 않고 처음 실행합니다:

`rsnapshot -c /etc/rsnapshot.conf beta`

백업이 완료되면 /mnt/backup으로 이동하여 생성된 디렉토리 구조를 검사합니다. `storage/beta.0/localhost` 디렉토리가 있으며, 백업할 디렉토리들이 그 아래에 있을 것입니다.

### 추가 설명

각 백업 실행마다 beta increment, 0-6 또는 7일치의 백업이 생성됩니다. 가장 최신의 백업은 항상 beta.0이고, 어제의 백업은 항상 beta.1일 것입니다.

각 백업의 크기는 동일한 양의 디스크 공간을 차지하는 것처럼 보일 수 있지만, 이는 _rsnapshot_ 의 하드 링크 사용으로 인한 것입니다. 어제의 백업에서 파일을 복원하려면 그냥 beta.1의 디렉토리 구조에서 해당 파일을 복사하면 됩니다.

각 백업은 이전 실행으로부터의 증분 백업만 포함하지만, 하드 링크 사용으로 인해 각 백업 디렉토리는 실제로 백업된 디렉토리 또는 해당 파일의 하드 링크를 포함하고 있습니다.

파일을 복원할 때는 디렉토리나 증분을 복원할 필요 없이 복원하려는 백업의 타임 스탬프만 선택하면 됩니다. 이는 많은 다른 백업 솔루션보다 훨씬 적은 디스크 공간을 사용하며 효율적으로 활용하는 시스템입니다.

## 백업이 자동으로 실행되도록 설정

테스트가 완료되고 문제 없이 작동할 것으로 확신할 경우, 다음 단계는 매일 자동으로 프로세스를 실행할 수 있도록 루트 사용자의 crontab을 설정하는 것입니다:

`sudo crontab -e`

이전에 실행한 적이 없다면, `Select an editor` 라인에서 vim.basic을 편집기로 선택하거나 원하는 편집기를 선택하세요.

다음과 같이 스냅샷 루트를 기본값으로 되돌릴 수 있습니다.

```
## 오후 11시에 백업 실행
00 23 *  *  *  /usr/bin/rsnapshot -c /etc/rsnapshot.conf beta`
```

## 다중 시스템 또는 다중 서버 백업

온프레미스 또는 인터넷을 통해 RAID 어레이 또는 대용량 스토리지가 있는 머신에서 여러 머신을 백업하는 것은 매우 잘 작동합니다.

인터넷 연결이 있는 다른 위치에서 이러한 백업을 실행하는 경우, 백업을 수행하는 데 충분한 대역폭이 각 위치에 필요합니다. _rsnapshot_ 을 사용하여 온프레미스 서버를 오프프레미스 백업 배열이나 백업 서버와 동기화하여 데이터 신뢰성을 향상시킬 수 있습니다.

## 가정

우리는 당신이 컴퓨터에서 온프레미스로 원격으로 _rsnapshot_을 실행하고 있다고 가정합니다. 이 정확한 구성은 위에 표시된 대로 원격 오프프레미스에서도 복제할 수 있습니다.

이 경우 모든 백업을 수행하는 시스템에 _rsnapshot_을 설치해야 합니다. 또한 다음과 같이 가정합니다.

* 백업할 서버들이 원격 머신이 SSH로 접근할 수 있도록 허용하는 방화벽 규칙이 있어야 합니다.
* 백업할 각 서버에는 최신 버전의 `rsync`가 설치되어 있어야 합니다. Rocky Linux 서버의 경우 `dnf install rsync`를 실행하여 시스템의 `rsync` 버전을 업데이트할 수 있습니다.
* 시스템에 루트 사용자로 연결했거나 `sudo -s`를 실행하여 루트 사용자로 전환했다고 가정합니다.

## SSH Public / Private Keys

백업을 실행할 서버에서 백업 중에 사용할 SSH 키 쌍을 생성해야 합니다. 이 예제에서는 RSA 키를 생성하게 됩니다.

이미 키 쌍이 생성된 경우에는 이 단계를 건너뛸 수 있습니다. `ls -al .ssh`를 실행하여 `id_rsa` 및 `id_rsa.pub` 키 쌍을 찾아볼 수 있습니다. 키가 없다면 다음 링크를 사용하여 머신과 접근하려는 서버에 키를 설정하세요:

[SSH Public Private 키 쌍](../security/ssh_public_private_keys.md)

## _rsnapshot_ 구성

구성 파일은 기본적으로  위의 **기본 시스템 또는 단일 서버 백업**으로 만든 파일과 거의 동일해야 하지만 일부 옵션을 변경해야 합니다.

다음과 같이 스냅샷 루트를 기본값으로 되돌릴 수 있습니다.

`snapshot_root   /.snapshots/`

이 줄을 주석 처리합니다:

`no_create_root 1`

`#no_create_root 1`

다른 차이점은 각 머신마다 자체 구성이 있어야 한다는 점입니다. 이를 익숙해지면 기존 구성 파일 중 하나를 다른 이름으로 복사하여 추가로 백업하려는 다른 머신에 맞게 변경하기만 하면 됩니다.

여기서 또 다른 차이점은 각 머신마다 고유한 구성이 있다는 것입니다. 이것에 익숙해지면 기존 구성 파일 중 하나를 새 이름으로 복사한 다음 백업하려는 추가 시스템에 맞게 수정하면 됩니다.

`cp /etc/rsnapshot.conf /etc/rsnapshot_web.conf`

구성 파일을 변경하고 로그 및 잠금 파일을 머신 이름으로 만듭니다:

`logfile /var/log/rsnapshot_web.log`

`lockfile        /var/run/rsnapshot_web.pid`

다음으로 rsnapshot_web.conf를 변경하여 백업할 디렉토리를 포함하도록 합니다. 여기에서 유일한 차이점은 대상입니다.

다음은 web.ourdomain.com 구성의 예입니다.

```
### BACKUP POINTS / SCRIPTS ###
backup  root@web.ourourdomain.com:/etc/     web.ourourdomain.com/
backup  root@web.ourourdomain.com:/var/www/     web.ourourdomain.com/
backup  root@web.ourdomain.com:/usr/local/     web.ourdomain.com/
backup  root@web.ourdomain.com:/home/     web.ourdomain.com/
backup  root@web.ourdomain.com:/root/     web.ourdomain.com/
```

### 구성 확인 및 초기 백업 실행

다음은 web.ourdomain.com 구성의 예입니다.

`rsnapshot -c /etc/rsnapshot_web.conf configtest`

`Syntax OK` 메시지를 찾고 있습니다. 모든 것이 정상이면 백업을 수동으로 실행할 수 있습니다:

`/usr/bin/rsnapshot -c /etc/rsnapshot_web.conf beta`

모든 것이 잘 작동한다고 가정하고 메일 서버(rsnapshot_mail.conf) 및 포털 서버(rsnapshot_portal.conf)의 구성 파일을 만들고 테스트한 다음 시행해보세요.

## 백업 자동화

여러 대의 머신 또는 서버 버전의 백업 자동화는 약간 다릅니다. 백업을 순서대로 호출하는 bash 스크립트를 생성하려고 합니다. 하나가 끝나면 다음이 시작됩니다. 이 스크립트는 다음과 유사합니다:

`vi /usr/local/sbin/backup_all`

컨텐츠와 함께 (With content)

```
#!/bin/bash/
# rsnapshot 백업을 연속적으로 실행하는 스크립트
/usr/bin/rsnapshot -c /etc/rsnapshot_web.conf beta
/usr/bin/rsnapshot -c /etc/rsnapshot_mail.conf beta
/usr/bin/rsnapshot -c /etc/rsnapshot_portal.conf beta
```

스크립트를 /usr/local/sbin에 저장하고 스크립트를 실행 가능하게 만듭니다:

`chmod +x /usr/local/sbin/backup_all`

루트의 crontab에 백업 스크립트를 실행하도록 crontab을 만듭니다:

`crontab -e`

그리고 다음 줄을 추가합니다.

```
## 오후 11시에 백업 실행
00 23 *  *  *  /usr/local/sbin/backup_all
```

## 백업 상태 보고

모든 것이 계획대로 백업되는지 확인하려면 백업 로그 파일을 이메일로 보낼 수 있습니다. _rsnapshot_ 을 사용하여 여러 대의 머신 백업을 실행하는 경우 각 로그 파일에 고유한 이름이 있으며 이를 사용하여 [postfix를 사용하여 서버 프로세스 보고](../email/postfix_reporting.md) 절차를 통해 이메일로 전송할 수 있습니다.

## 백업 복원

파일 몇 개 또는 전체 백업을 복원하는 것은 원하는 디렉토리의 날짜별 디렉토리에서 파일을 다시 복사하는 것입니다.

## 결론 및 기타 리소스

_rsnapshot_ 으로 설정을 올바르게 하려면 처음에는 조금 어려울 수 있지만, 머신 또는 서버의 백업에 소요되는 시간을 많이 절약할 수 있습니다.

_rsnapshot_ 은 강력하고 빠르며 디스크 공간 사용량이 경제적입니다. _rsnapshot_ 에 대한 자세한 내용은 [rsnapshot.org](https://rsnapshot.org/download.html)를 방문하여 확인할 수 있습니다.
