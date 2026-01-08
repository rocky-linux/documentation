---
author: Wale Soyinka
contributors: Steven Spencer, tianci li, Ganna Zhyrnova
tested on: 8.8
tags:
  - 실습
  - 소프트웨어 관리
---

# 실습 7: 소프트웨어 관리 및 설치

## 목표

이 실습을 완료한 후에는 다음을 수행할 수 있습니다:

- 정보를 위해 패키지를 쿼리
- 이진 패키지에서 소프트웨어 설치
- 일부 기본 의존성 문제 해결
- 소스에서 소프트웨어를 컴파일 및 설치

이 실습을 완료하는 데 예상 소요 시간: 90분

## 이진 파일과 소스 파일

시스템에 설치된 애플리케이션은 몇 가지 요소에 따라 달라집니다. 주요 요소는 운영 체제 설치 중 선택된 소프트웨어 패키지 그룹에 따라 달라집니다. 다른 요소는 시스템 사용 이후에 수행된 작업에 따라 달라집니다.

시스템 관리자로서 일상적인 작업 중 하나는 소프트웨어 관리입니다. 이것은 종종 다음을 포함합니다:

- 새 소프트웨어 설치
- 소프트웨어 제거
- 이미 설치된 소프트웨어 업데이트

리눅스 기반 시스템에서 소프트웨어를 설치하는 방법은 여러 가지입니다. 소스 또는 사전 컴파일된 이진 파일에서 설치할 수 있습니다. 후자의 방법이 가장 쉽지만 가장 적게 사용자 정의할 수 있는 방법입니다. 사전 컴파일된 이진 파일에서 설치할 때 대부분의 작업이 이미 수행되어 있습니다. 그러나 특정 소프트웨어의 이름과 위치를 알아야 합니다.

거의 모든 소프트웨어는 원래 C 또는 "C++" 프로그래밍 언어 소스 파일로 제공됩니다. 소스 프로그램은 일반적으로 소스 파일의 아카이브로 배포됩니다. 보통 tar’ed 또는 gzip’ed 또는 bzip2’ed 파일로 제공됩니다. 이것은 그들이 압축되거나 단일 번들로 제공된다는 것을 의미합니다.

대부분의 개발자들은 GNU 표준에 맞게 소스 코드를 만들어 공유가 더 쉽게 되었습니다. 이는 패키지가 모든 UNIX 또는 UNIX와 유사한 시스템(예: 리눅스)에서 컴파일될 것임을 의미합니다.

RPM은 Rocky Linux, Fedora, Red Hat Enterprise Linux(RHEL), openSuSE, Mandrake 등과 같은 Red Hat 기반 배포판에서 애플리케이션(패키지)을 관리하기 위한 기본 도구입니다.

리눅스 배포판에서 소프트웨어를 관리하는 데 사용되는 애플리케이션을 패키지 관리자라고 합니다. 예를 들면:

- 레드햇 패키지 매니저 (`rpm`). 패키지는 “.rpm” 확장자를 가집니다.
- 데비안 패키지 관리 시스템 (`dpkg`).  패키지는 “.deb” 확장자를 가집니다.

다음은 RPM 명령어에 대한 몇 가지 인기 있는 명령줄 옵션과 구문입니다:

### `rpm`

사용법: rpm [옵션...]

**패키지 쿼리**

```bash
쿼리 옵션 (-q 또는 --query와 함께):
  -c, --configfiles                  모든 구성 파일 나열
  -d, --docfiles                     모든 문서 파일 나열
  -L, --licensefiles                 모든 라이선스 파일 나열
  -A, --artifactfiles                모든 아티팩트 파일 나열
      --dump                         기본 파일 정보를 덤프
  -l, --list                         패키지의 파일 나열
      --queryformat=QUERYFORMAT      다음 쿼리 형식 사용
  -s, --state                        나열된 파일의 상태를 표시
```

**패키지 검증**

```bash
검증 옵션 (-V 또는 --verify와 함께):
      --nofiledigest                 파일의 다이제스트를 검증하지 않음
      --nofiles                      패키지의 파일을 검증하지 않음
      --nodeps                       패키지 의존성을 검증하지 않음
      --noscript                     검증 스크립트를 실행하지 않음
```

**패키지 설치, 업그레이드, 제거**

```bash
설치/업그레이드/삭제 옵션:
      --allfiles                     설치될 수 있는 모든 파일 설치, 그렇지 않으면 생략될 구성도 포함
  -e, --erase=<package>+             패키지 제거(제거)
      --excludedocs                  문서를 설치하지 않음
      --excludepath=<path>           <path>로 시작하는 파일 건너뛰기
      --force                        --replacepkgs --replacefiles의 단축
  -F, --freshen=<packagefile>+       이미 설치된 경우 패키지를 업그레이드
  -h, --hash                         패키지를 설치할 때 해시 마크를 인쇄 (v와 함께 사용할 때 좋음)
      --noverify                     --ignorepayload --ignoresignature의 단축
  -i, --install                      패키지 설치
      --nodeps                       패키지 의존성을 검증하지 않음
      --noscripts                    패키지 스크립트를 실행하지 않음
      --percent                      패키지를 설치할 때 백분율을 인쇄
      --prefix=<dir>                 패키지가 이동 가능한 경우 <dir>로 패키지를 이동
      --relocate=<old>=<new>         <old> 경로의 파일을 <new>로 이동
      --replacefiles                 패키지 간의 파일 충돌을 무시
      --replacepkgs                  패키지가 이미 존재하는 경우 다시 설치
      --test                         설치하지 않고, 작동할 지 알려줌
  -U, --upgrade=<packagefile>+       패키지 업그레이드
      --reinstall=<packagefile>+     패키지 재설치
```

## 연습문제 1

### 패키지 설치, 쿼리 및 제거

이 실습에서는 RPM 시스템을 사용하고 샘플 애플리케이션을 설치하는 방법을 배울 것입니다.

!!! tip

    Rocky Linux 패키지를 얻을 수 있는 옵션이 많습니다. 신뢰할 수 있는 [또는 신뢰할 수 없는] 저장소에서 직접 다운로드할 수 있습니다. 배포 ISO에서 얻을 수 있습니다. nfs, git, https, ftp, smb, cifs 등과 같은 프로토콜을 사용하여 중앙 공유 위치에서 얻을 수 있습니다. 궁금하다면 다음 공식 웹사이트를 보고 원하는 패키지에 대한 적절한 저장소를 탐색할 수 있습니다:
    
    https://download.rockylinux.org/pub/rocky/8.8/

#### 정보를 위해 패키지 쿼리하기

1. 현재 로컬 시스템에 설치된 모든 패키지의 목록을 보려면 다음과 같이 입력합니다:

    ```bash
    $ rpm -qa
    python3-gobject-base-*
    NetworkManager-*
    rocky-repos-*
    ...<출력 생략>...
    ```

   긴 목록이 표시됩니다.

2. 시스템에 설치된 패키지 중 하나인 NetworkManager에 대해 조금 더 자세히 알아보겠습니다. We will examine NetworkManager. `rpm` 명령에 --query (-q) 및 --info (-i) 옵션을 사용합니다. Type:

    ```bash
    $ rpm -qi NetworkManager
    이름        : NetworkManager
    에포크      : 1
    ...<출력 생략>...
    ```

   그것은 많은 정보(메타데이터)입니다!

3. 이전 명령의 Summary 필드에만 관심이 있다고 가정해 보겠습니다. rpm의 --queryformat 옵션을 사용하여 쿼리 옵션에서 되돌아오는 정보를 필터링할 수 있습니다.

   예를 들어, Summary 필드만 보려면 다음과 같이 입력합니다:

    ```bash
    rpm -q --queryformat '%{summary}\n' NetworkManager
    ```

   필드 이름은 대소문자를 구분하지 않습니다.

4. 설치된 NetworkManager 패키지의 버전 및 Summary 필드를 모두 보려면 다음과 같이 입력합니다:

    ```bash
    rpm -q --queryformat '%{version}  %{summary}\n' NetworkManager
    ```

5. 시스템에 설치된 bash 패키지에 대한 정보를 보려면 다음 명령을 입력합니다.

    ```bash
    rpm -qi bash
    ```

   !!! note

            이전 연습에서는 시스템에 이미 설치된 패키지를 쿼리하고 작업했습니다. 다음 연습에서는 아직 설치되지 않은 패키지로 작업을 시작할 것입니다. 다음 단계에서 사용할 패키지를 다운로드하기 위해 DNF 애플리케이션을 사용할 것입니다.

6. 먼저 시스템에 `wget` 애플리케이션이 이미 설치되어 있는지 확인합니다. Type:

    ```bash
    rpm -q wget
    package wget is not installed
    ```

   `wget`은 데모 시스템에 설치되어 있지 않은 것 같습니다.

7. Rocky Linux 8.x부터 `dnf download` 명령을 사용하면 `wget`의 최신 `rpm` 패키지를 가져올 수 있습니다. Type:

    ```bash
    dnf download wget
    ```

8. `ls` 명령을 사용하여 패키지가 현재 디렉토리에 다운로드되었는지 확인합니다. Type:

    ```bash
    ls -lh wg*
    ```

9. 다운로드된 wget-\*.rpm에 대한 정보를 쿼리하기 위해 `rpm` 명령을 사용합니다. Type:

    ```bash
    rpm -qip wget-*.rpm
    이름        : wget
    아키텍처    : x86_64
    설치 날짜   : (설치되지 않음)
    그룹       : Applications/Internet
    ...<생략>...
    ```

   !!! question

            이전 단계의 출력에서 `wget` 패키지는 정확히 무엇인가요? 힌트: 다운로드 패키지의 설명 필드를 보기 위해 `rpm` 쿼리 포맷 옵션을 사용할 수 있습니다.

10. `wget files-.rpm` 패키지에 관심이 있다면, 패키지에 포함된 모든 파일을 나열하기 위해 다음과 같이 입력할 수 있습니다:

    ```bash
    rpm -qlp wget-*.rpm | head
    /etc/wgetrc
    /usr/bin/wget
    ...<생략>...
    /usr/share/doc/wget/AUTHORS
    /usr/share/doc/wget/COPYING
    /usr/share/doc/wget/MAILING-LIST
    /usr/share/doc/wget/NEWS
    ```

11. `wget` 패키지에 포함된 `/usr/share/doc/wget/AUTHORS` 파일의 내용을 보겠습니다. `cat` 명령을 사용합니다. Type:

    ```bash
    cat /usr/share/doc/wget/AUTHORS
    cat: /usr/share/doc/wget/AUTHORS: 그런 파일이나 디렉토리가 없습니다
    ```

    `wget`은 아직 데모 시스템에 설치되지 않았습니다! 그래서, 패키지에 포함된 AUTHORS 파일을 볼 수 없습니다!

12. 시스템에 _이미_ 설치된 다른 패키지(curl)와 함께 제공되는 파일 목록을 보려면 다음과 같이 입력합니다: Type:

    ```bash
    $ rpm -ql curl
    /usr/bin/curl
    /usr/lib/.build-id
    /usr/lib/.build-id/fc
    ...<>...
    ```

    !!! note

            이전 명령에서 `curl` 패키지의 전체 이름을 참조할 필요가 없었던 것을 알 수 있습니다. 이는 `curl`이 이미 설치되어 있기 때문입니다.

#### 패키지 이름에 대한 확장 지식

- **전체 패키지 이름**: 신뢰할 수 있는 출처(예: 벤더 웹사이트, 개발자 저장소)에서 패키지를 다운로드할 때 다운로드된 파일의 이름은 전체 패키지 이름이 됩니다. 이 패키지를 `rpm` 명령으로 설치/업데이트할 때, 명령의 작업 대상은 패키지의 전체 이름(또는 일치하는 와일드카드 등가)이어야 합니다.

    ```bash
    rpm -ivh htop-3.2.1-1.el8.x86_64.rpm
    ```

    ```bash
    rpm -Uvh htop-3.2.1-1.*.rpm
    ```

    ```bash
    rpm -qip htop-3.*.rpm
    ```

    ```bash
    rpm -qlp wget-1.19.5-11.el8.x86_64.rpm
    ```

  패키지의 전체 이름은 이와 유사한 명명 규칙을 따릅니다 —— `[패키지_이름]-[버전]-[릴리스].[OS].[아키텍처].rpm` 또는 `[패키지_이름]-[버전]-[릴리스].[OS].[아키텍처].src.rpm`

- **패키지 이름**: RPM은 소프트웨어를 관리하기 위해 데이터베이스를 사용하기 때문에, 패키지 설치가 완료되면 데이터베이스에 해당 기록이 있습니다. 현재 `rpm` 명령의 작업 대상은 패키지 이름만 입력하면 됩니다. 예를 들면:

    ```bash
    rpm -qi bash
    ```

    ```bash
    rpm -q systemd
    ```

    ```bash
    rpm -ql chrony
    ```

## 연습문제 2

### 패키지 무결성

1. It is possible to download or end up with a corrupted or tainted file. 다운로드한 `wget` 패키지의 무결성을 검증할 수 있습니다. Type:

    ```bash
    rpm -K  wget-*.rpm
    wget-1.19.5-10.el8.x86_64.rpm: digests signatures OK
    ```

   출력 메시지인 "digests signatures OK"는 패키지가 정상임을 보여줍니다.

2. 우리는 고의로 다운로드한 패키지를 변경하여 악의적인 행동을 해보겠습니다. 이는 원본 패키지에 무언가를 추가하거나 제거함으로써 수행될 수 있습니다. 원래 패키저가 의도하지 않은 방식으로 패키지를 변경하는 모든 것은 패키지를 손상시킬 것입니다. `echo` 명령을 사용하여 패키지에 문자열 "haha"를 추가함으로써 파일을 변경할 것입니다. Type:

    ```bash
    echo haha >> wget-1.19.5-10.el8.x86_64.rpm 
    ```

3. 이제 rpm의 -K 옵션을 사용하여 다시 패키지의 무결성을 검증해 보십시오.

    ```bash
    $ rpm -K  wget-*.rpm
    wget-1.19.5-10.el8.x86_64.rpm: DIGESTS SIGNATURES NOT OK
    ```

   이제 메시지가 매우 다릅니다. "DIGESTS SIGNATURES NOT OK" 출력은 패키지를 사용하거나 설치하려고 시도하지 말라는 분명한 경고입니다. It should no longer be trusted.

4. `rm` 명령을 사용하여 손상된 `wget` 패키지 파일을 삭제하고 `dnf`를 사용하여 새로운 복사본을 다운로드합니다. Type:

    ```bash
    rm wget-*.rpm  && dnf download wget
    ```

   새로 다운로드한 패키지가 RPM의 무결성 검사를 통과하는지 한 번 더 확인합니다.

## 연습문제 3

### 패키지 설치

시스템에 소프트웨어를 설치하는 동안 "실패한 의존성" 문제에 부딪힐 수 있습니다. 이는 시스템에서 수동으로 애플리케이션을 관리하기 위해 저수준 RPM 유틸리티를 사용할 때 특히 흔합니다.

예를 들어, "abc.rpm" 패키지를 설치하려고 시도할 때 RPM 설치 프로그램은 일부 실패한 의존성에 대해 불평할 수 있습니다. 패키지 "abc.rpm"이 먼저 설치되어야 하는 다른 패키지 "xyz.rpm"이 필요하다고 알려줄 수 있습니다. 의존성 문제는 소프트웨어 애플리케이션이 거의 항상 다른 소프트웨어나 라이브러리에 의존하기 때문에 발생합니다. 필요한 프로그램이나 공유 라이브러리가 시스템에 이미 없는 경우, 타겟 애플리케이션을 설치하기 전에 그 전제 조건을 충족시켜야 합니다.

The low-level RPM utility often knows about the inter-dependencies between applications. 저수준 RPM 유틸리티는 종종 애플리케이션 간의 상호 의존성을 알고 있지만, 문제를 해결하기 위해 필요한 애플리케이션 또는 라이브러리를 어떻게 또는 어디에서 얻을 수 있는지는 보통 알지 못합니다. 다시 말해, RPM은 _무엇_과 _어떻게_를 알고 있지만, _어디서_ 질문에 답할 수 있는 내장 능력이 없습니다. 이는 `dnf`, `yum`과 같은 도구가 빛나는 곳입니다.

#### 패키지 설치하기

이 연습에서는 `wget` 패키지(wget-\*.rpm)를 설치해 볼 것입니다.

1. `wget` 애플리케이션을 설치해 보십시오. RPM의 -ivh 명령줄 옵션을 사용합니다. Type:

    ```bash
    rpm -ivh wget-*.rpm
    error: Failed dependencies:
        libmetalink.so.3()(64bit) is needed by wget-*
    ```

   바로 의존성 문제가 발생했습니다! 샘플 출력은 `wget`이 "libmetalink.so.3"이라는 라이브러리 파일이 필요하다는 것을 보여줍니다.

   !!! note

            위의 테스트 출력에 따르면, wget-_.rpm 패키지는 libmetalink-_.rpm 패키지가 설치되어 있어야 합니다. 즉, libmetalink는 wget-_.rpm을 설치하기 위한 전제 조건입니다. 절대적으로 무엇을 하는지 알고 있다면 “nodeps” 옵션을 사용하여 wget-_.rpm 패키지를 강제로 설치할 수 있지만, 이는 일반적으로 나쁜 관행입니다.

2. RPM은 우리에게 무엇이 누락되었는지에 대한 힌트를 친절하게 제공했습니다. `rpm`은 무엇과 어떻게는 알지만 반드시 어디서인지는 모릅니다. 누락된 라이브러리를 제공하는 패키지 이름을 결정하기 위해 `dnf` 유틸리티를 사용해 보겠습니다. Type:

    ```bash
    $ dnf whatprovides libmetalink.so.3
    ...<생략>...
    libmetalink-* : C로 작성된 Metalink 라이브러리
    저장소      : baseos
    일치하는 항목:
    제공      : libmetalink.so.3
    ```

3. 출력에서 누락된 라이브러리를 제공하는 `libmetalink` 패키지를 다운로드해야 합니다. 구체적으로, 우리는 64비트 버전의 라이브러리를 원합니다. 데모 64비트(x86_64) 아키텍처에 대한 패키지를 찾고 다운로드하는 데 도움을 줄 별도의 유틸리티(`dnf`)를 호출해 보겠습니다. Type:

    ```bash
    dnf download --arch x86_64  libmetalink
    ```

4. 이제 작업 디렉토리에 최소 2개의 rpm 패키지가 있어야 합니다. `ls` 명령을 사용하여 이를 확인합니다.

5. 누락된 `libmetalink` 의존성을 설치합니다. Type:

    ```bash
    sudo rpm -ivh libmetalink-*.rpm
    ```

6. 의존성이 설치되었으므로, `wget` 패키지를 설치하는 원래 목표로 돌아갈 수 있습니다. Type:

    ```bash
    sudo rpm  -ivh wget-*.rpm
    ```

   !!! note

            RPM은 트랜잭션을 지원합니다. 이전 연습에서 우리는 원래 설치하고자 하는 패키지와 그것이 의존하는 모든 패키지 및 라이브러리를 포함한 단일 rpm 트랜잭션을 수행할 수 있었습니다. 아래와 같은 단일 명령이면 충분했을 것입니다:
           
                `bash              rpm -Uvh  wget-*.rpm  libmetalink-*.rpm              `

7. 이제 진실의 순간입니다. 옵션 없이 `wget` 프로그램을 실행하여 설치되었는지 확인해 보십시오. Type:

    ```bash
    wget
    ```

8. Let us see `wget` in action. `wget`을 사용하여 커맨드 라인에서 인터넷에서 파일을 다운로드해 보십시오. Type:

    ```bash
    wget  https://kernel.org
    ```

   이렇게 하면 kernel.org 웹사이트의 기본 index.html이 다운로드됩니다!

9. `rpm`을 사용하여 `wget` 애플리케이션과 함께 제공되는 모든 파일의 목록을 봅니다.

10. `rpm`을 사용하여 `wget`과 함께 포장된 모든 문서를 봅니다.

11. `rpm`을 사용하여 `wget` 패키지와 함께 설치된 모든 바이너리의 목록을 봅니다.

12. `wget`을 설치하기 위해 `libmetalink` 패키지를 설치했습니다. 커맨드 라인에서 `libmetalink`를 실행하거나 실행해 보십시오. Type:

    ```bash
    libmetalink
    -bash: libmetalink: command not found
    ```

    !!! 주의

        ```
        왜 `libmetalink`를 실행하거나 실행할 수 없는 걸까요?
        ```

#### `rpm`을 통해 공개 키 가져오기

!!! tip

    Rocky Linux 프로젝트에서 사용하는 패키지에 서명하는 데 사용되는 GPG 키는 프로젝트 웹사이트, ftp 사이트, 배포 미디어, 로컬 소스 등 다양한 출처에서 얻을 수 있습니다. RL 시스템의 키링에 적절한 키가 누락된 경우, `sudo  rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-rockyofficial`를 실행하여 로컬 RL 시스템에서 Rocky Linux의 공개 키를 가져올 수 있습니다.

!!! question

    패키지를 설치할 때 `rpm -Uvh`와 `rpm -ivh`의 차이점은 무엇인가요? `rpm`의 매뉴얼 페이지를 참조하세요.

## 연습문제 4

### 패키지 제거

Red Hat의 패키지 관리자(RPM)를 사용하면 설치만큼 쉽게 패키지를 제거할 수 있습니다.

이 연습에서는 시스템에서 몇 가지 패키지를 제거하기 위해 `rpm`을 사용해 볼 것입니다.

#### 패키지 제거하기

1. 시스템에서 `libmetalink` 패키지를 제거합니다. Type:

    ```bash
    sudo rpm -e libmetalink
    ```

   !!! question

            왜 패키지를 제거할 수 없었나요?

2. RPM을 사용하여 패키지를 제거하는 깨끗하고 적절한 방법은 해당 의존성과 함께 패키지를 제거하는 것입니다. `libmetalink` 패키지를 제거하려면 그것에 의존하는 `wget` 패키지도 함께 제거해야 합니다. Type:

    ```bash
    sudo rpm -e libmetalink wget
    ```

   !!! note

            libmetalink에 의존하는 패키지를 끊고 _강제로_ 시스템에서 패키지를 제거하려면 rpm의 `--nodeps` 옵션을 다음과 같이 사용할 수 있습니다: `$ sudo rpm  -e  --nodeps  libmetalink`.
           
            **i.** “nodeps” 옵션은 No dependencies를 의미합니다. 즉, 모든 의존성을 무시합니다.
            **ii.** 위의 방법은 시스템에서 패키지를 강제로 제거하는 방법을 보여줍니다. 때때로 이것이 필요하지만, 일반적으로 _좋은 관행이 아닙니다_.
            **iii.** 다른 설치된 패키지 “abc”가 의존하는 패키지 “xyz”를 강제로 제거하면 사실상 패키지 “abc”를 사용할 수 없게 하거나 어느 정도 손상시킵니다.

## 연습문제 8

### DNF - 패키지 관리자

DNF는 RPM 기반 리눅스 배포판을 위한 패키지 관리자입니다. 인기 있는 YUM 유틸리티의 후속작입니다. DNF는 YUM과 호환성을 유지합니다. 두 유틸리티 모두 유사한 명령줄 옵션과 구문을 공유합니다.

DNF는 Rocky Linux와 같은 RPM 기반 소프트웨어를 관리하기 위한 많은 도구 중 하나입니다. `rpm`과 비교했을 때, 이러한 고급 도구들은 패키지를 설치, 제거 및 쿼리하는 것을 단순화하는 데 도움을 줍니다. 이러한 도구들이 RPM 시스템에 의해 제공되는 기본 프레임워크를 사용한다는 점을 주목하는 것이 중요합니다. 이것이 RPM 사용 방법을 이해하는 것이 도움이 되는 이유입니다.

DNF(그리고 그와 유사한 다른 도구들)는 RPM 주위에 일종의 래퍼로 작동하며 RPM이 제공하지 않는 추가 기능을 제공합니다. DNF는 패키지와 라이브러리 의존성을 처리하는 방법을 알고 있으며 구성된 저장소를 사용하여 대부분의 문제를 자동으로 해결하는 방법을 알고 있습니다.

`dnf` 유틸리티와 함께 사용되는 일반적인 옵션은 다음과 같습니다:

```bash
    사용법: dnf [옵션] 명령어

    주요 명령어 목록:

    alias                     명령어 별칭을 나열하거나 생성
    autoremove                원래 의존성으로 설치된 모든 불필요한 패키지 제거
    check                     패키지 데이터베이스에서 문제를 확인
    check-update              사용 가능한 패키지 업그레이드 확인
    clean                     캐시된 데이터 제거
    deplist                   [사용 중단, repoquery --deplist 사용] 패키지의 의존성 및 해당 의존성을 제공하는 패키지 나열
    distro-sync               설치된 패키지를 가장 최신 버전으로 동기화
    downgrade                 패키지 다운그레이드
    group                     그룹 정보를 표시하거나 사용
    help                      유용한 사용법 메시지 표시
    history                   거래 내역을 표시하거나 사용
    info                      패키지나 패키지 그룹에 대한 상세 정보 표시
    install                   시스템에 패키지나 패키지 그룹 설치
    list                      패키지나 패키지 그룹 나열
    makecache                 메타데이터 캐시 생성
    mark                      사용자에 의해 설치된 것으로 패키지를 표시하거나 해제
    module                    모듈과 상호 작용
    provides                  주어진 값을 제공하는 패키지 찾기
    reinstall                 패키지 재설치
    remove                    시스템에서 패키지나 패키지 그룹 제거
    repolist                  구성된 소프트웨어 저장소 표시
    repoquery                 키워드와 일치하는 패키지 검색
    repository-packages       주어진 저장소의 모든 패키지에 대해 명령어 실행
    search                    주어진 문자열에 대한 패키지 상세 정보 검색
    shell                     대화형 DNF 셸 실행
    swap                      하나의 사양을 제거 및 설치하기 위해 대화형 DNF 모드를 실행합니다
    updateinfo                패키지에 대한 주의사항 표시
    upgrade                   시스템에서 패키지 또는 패키지 업그레이드
    upgrade-minimal           업그레이드하지만 시스템에 영향을 미치는 문제를 수정하는 'newest' 패키지만 일치합니다

```

#### `dnf`를 사용하여 패키지 설치하기

이미 `wget` 유틸리티를 연습으로 제거했다고 가정하고, 다음 단계에서 DNF를 사용하여 패키지를 설치합니다. 이전에 `rpm`을 통해 `wget`을 설치할 때 필요했던 2-3단계 과정이 이제 DNF를 사용하면 한 단계 과정으로 간소화됩니다. `dnf`는 모든 의존성을 조용히 해결합니다.

1. 먼저, 시스템에서 `wget`과 `libmetalink`가 제거되었는지 확인합시다. Type:

    ```bash
    sudo rpm -e wget libmetalink
    ```

   제거한 후, CLI에서 `wget`을 실행해 보면 _wget: command not found_ 같은 메시지가 나타납니다.

2. 이제 `dnf`를 사용하여 `wget`을 설치합니다. Type:

    ```bash
    sudo dnf -y install wget
    의존성 해결됨.
    ...<줄임>...
    설치됨:
    libmetalink-*      wget-*
    완료!
    ```

   !!! tip

            앞서 사용한 "-y" 옵션은 `dnf`가 수행하려는 동작을 확인하는 "[y/N]" 프롬프트를 억제합니다. 이는 `dnf`의 모든 확인 동작(또는 대화형 응답)이 "예"(y)가 됨을 의미합니다.

3. DNF는 시스템에 새로운 기능 세트를 추가하는 것을 쉽게 만드는 "환경 그룹" 옵션을 제공합니다. 기능을 추가하려면 일반적으로 몇 개의 패키지를 개별적으로 설치해야 하지만, `dnf`를 사용하면 원하는 기능의 이름이나 설명만 알면 됩니다. 사용 가능한 그룹 목록을 표시하려면 `dnf`를 사용합니다. Type:

    ```bash
    dnf group list
    ```

4. 우리는 "Development Tools" 그룹/기능에 관심이 있습니다. 해당 그룹에 대한 자세한 정보를 얻어봅시다. Type:

    ```bash
    dnf group info "Development Tools"
    ```

5. 나중에, "Development Tools" 그룹의 일부 프로그램이 필요할 것입니다. `dnf`를 사용하여 "Development Tools" 그룹을 설치합니다:

    ```bash
    sudo dnf -y group install "Development Tools"
    ```

#### `dnf`를 사용하여 패키지 제거하기

1. `dnf`를 사용하여 `wget` 패키지를 제거하려면 다음과 같이 입력합니다:

    ```bash
    sudo dnf -y remove wget
    ```

2. 패키지가 시스템에서 실제로 제거되었는지 확인하기 위해 `dnf`를 사용합니다. Type:

    ```bash
    sudo dnf -y remove wget
    ```

3. `wget`을 사용/실행해 봅니다. Type:

    ```bash
    wget
    ```

#### 패키지 업데이트를 위해 `dnf` 사용하기

DNF는 저장소에 있는 개별 패키지의 최신 버전을 확인하고 설치할 수 있습니다. 또한, 특정 버전의 패키지를 설치하는 데 사용될 수도 있습니다.

1. 시스템에서 사용 가능한 `wget` 프로그램의 버전을 보려면 `dnf`와 list 옵션을 사용합니다. Type:

    ```bash
    dnf list wget
    ```

2. 패키지에 대해 사용 가능한 업데이트된 버전이 있는지만 보고 싶다면, `dnf`와 check-update 옵션을 사용합니다. 예를 들어, `wget` 패키지의 경우 다음과 같이 입력합니다:

    ```bash
    dnf check-update wget
    ```

3. 이제, 시스템에서 사용 가능한 kernel 패키지의 모든 버전을 나열합니다. Type:

    ```bash
    sudo dnf list kernel
    ```

4. 다음으로, 설치된 kernel 패키지에 대해 사용 가능한 업데이트된 패키지가 있는지 확인합니다. Type:

    ```bash
    dnf check-update kernel
    ```

5. 패키지 업데이트는 버그 수정, 새로운 기능 또는 보안 패치 때문일 수 있습니다. kernel 패키지에 대해 보안 관련 업데이트가 있는지 보려면 다음과 같이 입력합니다:

    ```bash
    dnf  --security check-update kernel
    ```

#### 시스템 업데이트를 위해 `dnf` 사용하기

DNF는 시스템에 설치된 모든 패키지를 배포판에서 사용 가능한 가장 최신 버전으로 업데이트하는 데 사용될 수 있습니다. 주기적으로 업데이트를 확인하고 설치하는 것은 시스템 관리의 중요한 측면입니다.

1. 시스템에 설치된 패키지에 대해 사용 가능한 업데이트가 있는지 확인하려면 다음과 같이 입력합니다:

    ```bash
    dnf check-update
    ```

2. 시스템에 설치된 모든 패키지에 대해 보안 관련 업데이트가 있는지 확인하려면 다음과 같이 입력합니다:

    ```bash
    dnf --security check-update
    ```

3. 시스템에 설치된 모든 패키지를 배포판에서 사용 가능한 가장 최신 버전으로 업데이트하려면 다음과 같이 실행합니다:

    ```bash
    dnf -y check-update
    ```

## 연습문제 6

### 소스에서 소프트웨어 빌드하기

모든 소프트웨어/애플리케이션/패키지는 일반적으로 사람이 읽을 수 있는 텍스트 파일에서 시작됩니다. 이러한 파일들을 총칭하여 소스 코드라고 합니다. 리눅스 배포판에 설치된 RPM 패키지는 소스 코드에서 출발합니다.

이 연습에서는 샘플 프로그램의 소스 파일을 다운로드, 컴파일, 설치할 것입니다. 편의를 위해, 소스 파일은 일반적으로 tar-ball(타르-점-지-지로 발음)이라고 하는 단일 압축 파일로 배포됩니다.

다음 연습은 오래된 Hello 프로젝트 소스 코드를 기반으로 합니다. `hello`는 C++로 작성된 간단한 명령줄 애플리케이션으로, 터미널에 "hello"를 출력하는 것 외에는 아무것도 하지 않습니다. [프로젝트에 대해 더 알아보기](http://www.gnu.org/software/hello/hello.html)

#### 소스 파일 다운로드하기

1. `curl`을 사용하여 `hello` 애플리케이션의 최신 소스 코드를 다운로드합니다. 파일을 다운로드 폴더에 저장합시다.

   https\://ftp.gnu.org/gnu/hello/hello-2.12.tar.gz

#### 타르 파일 풀기

1. hello 소스 코드를 다운로드한 로컬 머신의 디렉터리로 변경합니다.

2. `tar` 프로그램을 사용하여 타르볼을 풉니다. Type:

    ```bash
    tar -xvzf hello-2.12.tar.gz
    ```

   출력:

    ```bash
    hello-2.12/
    hello-2.12/NEWS
    hello-2.12/AUTHORS
    hello-2.12/hello.1
    hello-2.12/THANKS
    ...<줄임>...
    ```

3. `ls` 명령어를 사용하여 현재 작업 디렉터리의 내용을 봅니다.

   풀기 과정에서 hello-2.12라는 새 디렉터리가 생성되었어야 합니다.

4. 해당 디렉터리로 변경하고 그 내용을 나열합니다. Type:

    ```bash
    cd hello-2.12 ; ls
    ```

5. 소스 코드와 함께 제공될 수 있는 특별한 설치 지침을 검토하는 것은 항상 좋은 관행입니다. 이러한 파일은 일반적으로 INSTALL, README 등과 같은 이름을 가지고 있습니다.

   페이저를 사용하여 INSTALL 파일을 열고 읽습니다. Type:

    ```bash
    less INSTALL
    ```

   파일 검토를 마친 후 페이저를 종료합니다.

#### 패키지 구성하기

대부분의 애플리케이션은 사용자가 활성화하거나 비활성화할 수 있는 기능을 가지고 있습니다. 소스 코드에 접근할 수 있고 동일한 소스에서 설치하는 것의 이점 중 하나입니다. 사용자는 애플리케이션의 구성 가능한 기능을 제어할 수 있습니다. 이는 패키지 관리자가 사전 컴파일된 바이너리에서 설치하는 모든 것을 수용하는 것과 대조됩니다.

소프트웨어를 구성하는 데 사용되는 스크립트는 일반적으로 "configure"라고 적절하게 명명됩니다.

!!! 팁

    ````
    "Development Tools" 패키지 그룹이 설치되어 있는지 확인한 후 다음 연습을 완료하십시오.
    
    ```bash
    sudo dnf -y group install "Development Tools"
    ```
    ````

1. `ls` 명령어를 다시 사용하여 현재 작업 디렉터리에 _configure_라는 파일이 실제로 있는지 확인합니다.

2. `hello` 프로그램에서 활성화하거나 비활성화할 수 있는 모든 옵션을 보려면 다음과 같이 입력합니다:

    ```bash
    ./configure --help
    ```

   !!! question

            명령어의 출력에서 "--prefix" 옵션은 무엇을 합니까?

3. configure 스크립트가 제공하는 기본 옵션에 만족한다면 다음과 같이 입력합니다: Type:

    ```bash
    ./configure
    ```

   !!! note

            구성 단계가 원활하게 진행되었다면 컴파일 단계로 넘어갈 수 있습니다.
           
            구성 단계에서 일부 오류가 발생하면 출력의 마지막 부분을 주의 깊게 살펴 오류의 원인을 확인해야 합니다. 오류는 _가끔_ 자명하고 쉽게 해결할 수 있습니다. 예를 들어, 다음과 같은 오류가 나타날 수 있습니다:
           
            configure: error: $PATH에서 수용할 수 있는 C 컴파일러를 찾을 수 없음
           
            위의 오류는 시스템에 C 컴파일러(예: `gcc`)가 설치되어 있지 않거나 컴파일러가 PATH 변수에 없는 위치에 설치되어 있음을 의미합니다.

#### 패키지 컴파일하기

다음 단계에서 hello 애플리케이션을 빌드할 것입니다. 이는 DNF를 사용하여 이전에 설치한 Development Tools 그룹에 포함된 일부 프로그램이 유용하게 사용됩니다.

1. “configure” 스크립트를 실행한 후 make 명령어를 사용하여 패키지를 컴파일합니다. Type:

    ```bash
    make
    ```

   출력:

    ```bash
    gcc  -g -O2   -o hello src/hello.o  ./lib/libhello.a
    make[2]: '/home/rocky/hello-2.12' 디렉터리를 떠납니다
    ...<출력 줄임>...
    make[1]: '/home/rocky/hello-2.12' 디렉터리를 떠납니다
    ```

   모든 것이 잘 진행된다면 - 이 중요한 `make` 단계는 최종 `hello` 애플리케이션 바이너리를 생성하는 데 도움이 될 것입니다.

2. 현재 작업 디렉터리의 파일을 다시 나열합니다. `hello` 프로그램을 포함하여 몇몇 새로 생성된 파일들을 볼 수 있어야 합니다.

#### 애플리케이션 설치하기

다른 관리 작업들 사이에서, 최종 설치 단계에는 어플리케이션 바이너리와 라이브러리를 적절한 폴더로 복사하는 작업도 포함됩니다.

1. hello 애플리케이션을 설치하려면 make install 명령을 실행하세요. Type:

    ```bash
    sudo make install
    ```

   이 작업은 패키지를 이전에 “configure” 스크립트와 함께 사용했을 수 있는 기본 prefix (--prefix) 인수에 의해 지정된 위치에 설치합니다. 만약 --prefix가 설정되지 않았다면, 기본 prefix로 `/usr/local/`이 사용됩니다.

#### hello 프로그램 실행하기

1. 시스템에서 `hello` 프로그램이 어디에 있는지 보려면 `whereis` 명령을 사용하세요. Type:

    ```bash
    whereis hello
    ```

2. `hello` 애플리케이션을 실행하여 그 기능을 확인해보세요. Type:

    ```bash
    hello
    ```

3. 다른 기능이 무엇인지 보려면 `hello`를 `--help` 옵션과 함께 다시 실행하세요.

4. 이제 `sudo`를 사용하여 슈퍼유저로서 `hello`를 다시 실행하세요. Type:

    ```bash
    sudo hello
    ```

   출력:

    ```bash
    sudo: hello: command not found
    ```

   !!! 질문

        ```
         `sudo`를 사용하여 `hello`를 실행할 때 오류가 발생하는 원인을 조사하세요. 문제를 해결하고 `hello` 프로그램이 `sudo`와 함께 사용될 수 있도록 해주세요.
        ```

   !!! tip

            일반 사용자로서 프로그램을 테스트하는 것은 일반 사용자도 실제로 프로그램을 사용할 수 있도록 하는 것이 좋습니다. 이는 물론 바이너리의 권한이 잘못 설정되어 슈퍼유저만 프로그램을 사용할 수 있는 경우를 가정합니다.

5. That's it. 이 연습은 완료되었습니다!

## 연습문제 7

### 패키지 설치 후 파일 무결성 확인하기

관련 패키지를 설치한 후, 경우에 따라 다른 사람에 의한 악의적인 수정을 방지하기 위해 관련 파일이 수정되었는지 여부를 결정해야 할 수 있습니다.

#### 파일 검증

`rpm` 명령의 "-V" 옵션을 사용합니다.

시간 동기화 프로그램 `chrony`를 예로 들어 그 출력의 의미를 설명합니다.

1. `rpm` 패키지 검증이 어떻게 작동하는지 시연하기 위해, chrony의 설정 파일인 `/etc/chrony.conf`에 변경을 가합니다. (chrony가 설치되어 있다고 가정합니다). 파일의 끝에 해로움이 없는 주석 `##` 기호 2개를 추가하세요. Type:

    ```bash
    echo -e "##"  | sudo tee -a /etc/chrony.conf
    ```

2. 이제 `rpm` 명령을 `--verify` 옵션과 함께 실행하세요. Type:

    ```bash
    rpm -V chrony
    ```

   출력:

    ```bash
    S.5....T.  c  /etc/chrony.conf
    ```

   출력은 3개의 별도 컬럼으로 나뉩니다.

   - **첫 번째 컬럼 (S.5....T.)**

     샘플 출력인 `S.5....T.`는 RPM 패키지의 파일에 대한 유효성에 대한 유용한 정보를 나타내는 데 사용되는 9개의 필드를 나타냅니다. 주어진 검사/테스트를 통과한 필드나 특성은 "."로 표시됩니다.

     이 9가지 다른 필드 또는 검사는 여기에 설명되어 있습니다:

     - S: 파일의 크기가 수정되었는지 여부.
     - M: 파일의 유형 또는 파일 권한 (rwx)이 수정되었는지 여부.
     - 5: 파일 MD5 체크섬이 수정되었는지 여부.
     - D: 디바이스의 번호가 수정되었는지 여부.
     - L: 파일로의 경로가 수정되었는지 여부.
     - U: 파일의 소유자가 수정되었는지 여부.
     - G: 파일이 속한 그룹이 수정되었는지 여부.
     - T: 파일의 mTime (수정 시간)이 수정되었는지 여부.
     - P: 프로그램 기능이 수정되었는지 여부.

   - **두 번째 컬럼 (c)**

     - **c**: 설정 파일의 수정을 나타냅니다. It can also be the following values:
     - d: 문서 파일.
     - g: ghost file. 매우 드물게 볼 수 있습니다.
     - l: 라이센스 파일.
     - r: readme 파일.

   - **세 번째 컬럼 (/etc/chrony.conf)**

     - **/etc/chrony.conf**: 수정된 파일의 경로를 나타냅니다.
