---
title: SSH 퍼블릭과 프라이빗 키
author: Steven Spencer
contributors: Ezequiel Bruni
tested_with: 8.5
tags:
  - security
  - ssh
  - keygen
---

# SSH 퍼블릭과 프라이빗 키

## 필요 사항

* 명령줄에서 작동하는 어느 정도의 편안함
* *openssh*가 설치된 Rocky Linux 서버 및/또는 워크스테이션
    * 좋습니다. 기술적으로 이 프로세스는 openssh가 설치된 모든 Linux 시스템에서 작동해야 합니다.
* 선택 사항: Linux 파일 및 디렉터리 권한에 익숙함

## 소개

SSH는 보통 명령 줄을 통해 한 컴퓨터에서 다른 컴퓨터에 접근하는 데 사용되는 프로토콜입니다. SSH를 사용하여 원격 컴퓨터 및 서버에서 명령을 실행하고 파일을 전송하며 일반적으로 모든 작업을 한 곳에서 관리할 수 있습니다.

여러 위치에 있는 여러 Rocky Linux 서버로 작업하거나 이러한 서버에 액세스하는 데 시간을 절약하려는 경우 SSH 공개 및 개인 키 쌍을 사용하는 것이 좋습니다. 키 쌍은 기본적으로 원격 시스템에 로그인하고 명령을 실행하는 것을 더 쉽게 만듭니다.

이 문서는 키를 생성하고 키로 쉽게 접근할 수 있도록 서버를 설정하는 과정을 안내합니다.

## 키 생성 프로세스

다음 명령은 모두 Rocky Linux 워크스테이션의 명령 줄에서 실행됩니다.

```
ssh-keygen -t rsa
```

그러면 다음이 표시됩니다.

```
Generating public/private rsa key pair.
Enter file in which to save the key (/root/.ssh/id_rsa):
```

기본 위치를 수락하려면 Enter 키를 누릅니다. 그런 다음 시스템은 다음과 같이 보여줍니다:

`Enter passphrase (empty for no passphrase):`

따라서 여기서는 Enter 키를 누릅니다. 마지막으로, 암호를 다시 입력하라는 메시지가 나타납니다:

`Enter same passphrase again:`

마지막으로 Enter를 누르십시오.

이제 .ssh 디렉토리에 RSA 유형의 공개 및 개인 키 쌍이 있어야 합니다:

```
ls -a .ssh/
.  ..  ..
```

이제 공개 키(id_rsa.pub)를 액세스할 모든 머신으로 보내야 합니다... 하지만 그 전에 키를 보낼 서버에 SSH로 액세스할 수 있는지 확인해야 합니다. 우리의 예시에서는 세 개의 서버만 사용합니다.

DNS 이름 또는 IP 주소를 통해 액세스할 수 있지만, 예시에서는 DNS 이름을 사용할 것입니다. 우리의 예시 서버는 web, mail, portal입니다. 각 서버에 대해 SSH로 접속하여(수동으로 SSH로 접속하려는 것을 좋아하는 사람들이 SSH를 동사로 사용합니다) 각 머신마다 터미널 창을 열어둡니다:

`ssh -l root web.ourourdomain.com`

세 머신 모두에서 문제없이 로그인할 수 있다면, 다음 단계는 각 서버로 공개 키를 보내는 것입니다:

`scp .ssh/id_rsa.pub root@web.ourourdomain.com:/root/`

우리의 세 머신 각각에 대해 이 단계를 반복합니다.

열려 있는 각 터미널 창에서 다음 명령을 입력하면 이제 *id_rsa.pub*를 볼 수 있습니다.

`ls -a | grep id_rsa.pub`

그렇다면 이제 각 서버의 *.ssh* 디렉토리에 *authorized_keys* 파일을 만들거나 추가할 준비가 된 것입니다. 각 서버에서 다음 명령을 입력합니다.

`ls -a .ssh`

!!! 경고 "중요!"

    아래의 모든 내용을 주의 깊게 읽으십시오. 무언가를 손상시킬지 확실하지 않은 경우 계속하기 전에 각 시스템에 authorized_keys(있는 경우)의 백업 복사본을 만드십시오.

*authorized_keys* 파일이 나열되지 않으면 _/root_ 디렉토리에 있는 동안 다음 명령을 입력하여 생성합니다.

`cat id_rsa.pub > .ssh/authorized_keys`

_authorized_keys_가 이미 존재하는 경우, 새 공개 키를 이미 있는 키에 추가하기만 하면 됩니다:

`cat id_rsa.pub >> .ssh/authorized_keys`

_authorized_keys_에 키를 추가하거나 _authorized_keys_ 파일을 생성한 후, Rocky Linux 워크스테이션에서 서버로 SSH로 시도해보세요. 비밀번호를 입력하라는 메시지가 나타나지 않아야 합니다.

비밀번호를 입력하지 않고 SSH할 수 있는지 확인한 후, 각 머신의 _/root_ 디렉토리에서 id_rsa.pub 파일을 삭제하세요.

`rm id_rsa.pub`

## SSH 디렉터리 및 authorized_keys 보안

대상 서버 각각에서 다음 권한이 적용되었는지 확인하세요.

```
chmod 700 .ssh/
chmod 600 .ssh/authorized_keys
```
