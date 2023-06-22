---
title: Rocky Linux로 마이그레이션
author: Ezequiel Bruni
contributors: tianci li, Steven Spencer
update: 11-23-2021
---

# CentOS Stream, CentOS, Alma Linux, RHEL, 또는 Oracle Linux에서 Rocky Linux로 이전하는 방법

## 전제 조건 및 가정 사항

* 하드웨어 서버 또는 VPS에서 CentOS Stream, CentOS, Alma Linux, RHEL, 또는 Oracle Linux가 잘 실행 중이어야 합니다. 각각의 현재 지원되는 버전은 8.7 또는 9.1입니다.
* 명령 줄에 대한 작동 지식이 있어야 합니다.
* 원격 머신에 대한 SSH 작동 지식이 있어야 합니다.
* 약간의 위험 감수 정신이 있어야 합니다.
* 모든 명령은 root 권한으로 실행되어야 합니다. root로 로그인하거나 "sudo"를 많이 입력할 준비를 해야 합니다.

## 소개

이 가이드에서는 위에서 나열한 모든 운영 체제를 완전히 작동하는 Rocky Linux 설치로 변환하는 방법을 알아보겠습니다. 이는 Rocky Linux를 설치하는 가장 번거로운 방법 중 하나일 수 있지만, 다양한 상황에서 유용하게 사용할 수 있습니다.

예를 들어, 일부 서버 제공업체는 당분간 Rocky Linux를 기본적으로 지원하지 않을 수 있습니다. 또는 모든 것을 재설치하지 않고 프로덕션 서버를 Rocky Linux로 변환하려는 경우가 있을 수 있습니다.

이런 경우에 사용할 수 있는 도구가 있습니다 [migrate2rocky](https://github.com/rocky-linux/rocky-tools/tree/main/migrate2rocky).

이 스크립트는 실행될 때 모든 리포지토리를 Rocky Linux의 리포지토리로 교체합니다. 필요에 따라 패키지가 설치되고 업그레이드/다운그레이드되며, 운영 체제의 브랜딩도 변경됩니다.

걱정하지 마세요. 시스템 관리에 처음이시더라도 가능한 한 사용자 친화적으로 유지하도록 하겠습니다. 음, 명령 줄에서 가능한 한 사용자 친화적으로요.

### 주의사항 및 경고

1. migrate2rocky의 README 페이지(위의 링크)를 확인해야 합니다. 이 스크립트와 Katello의 리포지토리 간에 충돌이 발생하는 것이 알려져 있습니다. 시간이 지나면 더 많은 충돌과 호환성 문제를 발견하고(결국 패치할 것으로 예상됩니다) 알아야 하므로 특히 프로덕션 서버의 경우 해당 내용을 알고 있어야 합니다.
2. 이 스크립트는 완전히 새로 설치된 시스템에서 가장 원활하게 작동할 것입니다. _프로덕션 서버를 변환하려는 경우, 그 어떤 것이건 **데이터 백업과 시스템 스냅샷을 만들거나 먼저 스테이징 환경에서 수행하세요.**_

알겠습니까? 준비되셨나요? 그러면 시작해봅시다.

## 서버 준비

먼저, 리포지토리에서 실제 스크립트 파일을 가져와야 합니다. 이 작업은 여러 가지 방법으로 수행할 수 있습니다.

### 수동 방법

GitHub에서 압축된 파일을 다운로드하고 필요한 파일(*migrate2rocky.sh*)을 추출합니다. GitHub 리포지토리의 메인 페이지 오른쪽에 zip 파일을 찾을 수 있습니다:

!["Download Zip" 버튼](images/migrate2rocky-github-zip.png)

그런 다음, 다음 명령을 로컬 머신에서 실행하여 실행 가능한 파일을 서버에 업로드합니다:

```
scp PATH/TO/FILE/migrate2rocky.sh root@yourdomain.com:/home/
```

파일 경로와 서버 도메인 또는 IP 주소를 필요에 따라 조정하세요.

### Git 방법

서버에서 다음 명령을 사용하여 git을 설치합니다:

```
dnf install git
```

그런 다음 rocky-tools 리포지토리를 복제합니다:

```
git clone https://github.com/rocky-linux/rocky-tools.git
```

참고: 이 방법은 rocky-tools 리포지토리의 모든 스크립트와 파일을 다운로드합니다.

### 쉬운 방법

이 스크립트를 얻는 가장 쉬운 방법입니다. 서버에 적합한 HTTP 클라이언트(curl, wget, lynx 등)가 설치되어 있다고 가정합니다.

`curl` 유틸리티가 설치되어 있다고 가정하고, 다음 명령을 실행하여 스크립트를 다운로드합니다:

```
curl https://raw.githubusercontent.com/rocky-linux/rocky-tools/main/migrate2rocky/migrate2rocky.sh -o migrate2rocky.sh
```

이 명령은 파일을 직접 서버로 다운로드하며, 원하는 파일만 다운로드합니다. 그러나 보안 문제 때문에 이것이 항상 최상의 방법은 아니라는 점을 기억하세요.

## 스크립트 실행 및 설치

`cd` 명령을 사용하여 스크립트가 있는 디렉토리로 이동한 후, 파일이 실행 가능한지 확인하고 스크립트 파일의 소유자에게 x 권한을 부여합니다.

```
chmod u+x migrate2rocky.sh
```

그리고 이제 스크립트를 실행합니다:

```
./migrate2rocky.sh -r
```

위의 "-r" 옵션은 스크립트에게 모든 것을 설치하라고 지시합니다.

모든 것을 올바르게 수행했다면, 터미널 창은 다음과 같이 보일 것입니다:

![스크립트 실행](images/migrate2rocky-convert-01.png)

이제 스크립트가 모든 것을 변환하는 데 시간이 걸릴 것입니다. 실제 기기/서버 및 인터넷 연결에 따라 다를 수 있습니다.

마지막에 **Complete!** 메시지가 나타나면 모든 것이 정상이며 서버를 재시작할 수 있습니다.

![OS 마이그레이션 성공 메세지](images/migrate2rocky-convert-02.png)

잠시 기다린 후 다시 로그인하면 새로운 Rocky Linux 서버가 플레이할 수 있습니다. 매우 진지한 작업을 수행한다는 의미입니다. `hostnamectl` 명령을 실행하여 OS가 올바르게 마이그레이션되었는지 확인하고 사용할 수 있습니다.

![hostnamectl 명령의 결과](images/migrate2rocky-convert-03.png)
