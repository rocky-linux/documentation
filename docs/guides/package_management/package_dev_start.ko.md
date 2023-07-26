---
title: 패키징 및 개발자 가이드
---

# 패키징 및 개발자 스타터 가이드


Rocky Devtools는 Rocky Linux 커뮤니티 구성원들이 만든 일련의 자체 스크립트와 유틸리티로, Rocky Linux 운영 체제와 함께 배포되는 소프트웨어 패키지의 소싱, 생성, 브랜딩, 패치, 빌드를 도와주는 도구입니다. Rocky Devtools는 `rockyget`, `rockybuild`, `rockypatch` 및 `rockyprep`로 구성됩니다.

Rocky Devtools는 낮은 수준에서는 다양한 패키지 관리 작업에 사용되는 몇 가지 커스텀 및 전통적인 프로그램들을 실행하기 위한 래퍼(wrapper)입니다. Rocky Devtools는  [`srpmproc`](https://github.com/rocky-linux/srpmproc), `go`, `git` 및 `rpmbuild`에 크게 의존합니다.

Rocky Devtools를 설치하고 사용하려면 기존의 현대적인 RPM 기반 Linux 시스템이 필요합니다.

이제 devtools의 일반적인 설치 및 사용 시나리오를 살펴보겠습니다.

## 종속성
devtools를 사용하기 전에 시스템에 여러 패키지가 필요합니다. 이 명령은 Rocky Linux에서 테스트되었지만 CentOS 8 / RHEL 8에서도 작동해야 합니다.
```
dnf install git make golang
```

## 1. Rocky Devtools 다운로드

다음 URL에서 devtools 압축된 소스를 다운로드합니다:

https://github.com/rocky-linux/devtools/archive/refs/heads/main.zip

여기서는 `curl` 명령을 사용합니다:

```
curl -OJL https://github.com/rocky-linux/devtools/archive/refs/heads/main.zip
```

이제 `devtools-main.zip`이라는 압축된 아카이브가 있어야 합니다.


## 2. Rocky Devtools 설치

방금 다운로드한 devtools 압축 파일을 찾아서 압축을 해제합니다.

여기서는 `unzip` 명령줄 유틸리티를 사용합니다:

```
unzip devtools-main.zip
```

새로 생성된 devtool 소스 디렉토리로 작업 디렉토리를 변경합니다.

```
cd devtools-main
```

`make`를 실행하여 devtools를 구성하고 컴파일합니다:

```
make
```

devtools 설치하기:

```
sudo make install
```

## 3. Rocky Devtools(rockyget)를 사용하여 소스 RPM(SRPM) 검색 및 다운로드

설치 후, 주요 SRPM을 찾아서 다운로드하는 데 사용되는 주요 도구는 `rockyget` 유틸리티입니다.

`rockyget`을 사용하여 인기 있는 `sed` 패키지용 SRPM을 다운로드해 보겠습니다.

```
rockyget sed
```
rockyget을 처음 실행하면, Rocky 빌드 서버의 저장소 구조와 대략적으로 유사한 디렉토리 구조를 자동으로 생성합니다. 예를 들어, `~/rocky/rpms` 폴더가 자동으로 생성될 것입니다.

현재 sed 예제의 경우, 다음과 같은 샘플 폴더 구조에 해당 소스가 저장될 것입니다:

```
~rocky/rpms/sed/
└── r8
    ├── SOURCES
    │   ├── sed-4.2.2-binary_copy_args.patch
    │   ├── sed-4.5.tar.xz
    │   ├── sedfaq.txt
    │   ├── sed-fuse.patch
    │   └── sed-selinux.patch
    └── SPECS
        └── sed.spec
```

### TIP :
원본 소스를 가져왔으면 (`~rocky/rpms/sed/SPECS/specs.spec`) 해당 패키지에서 브랜딩 기회를 찾아볼 수 있습니다. 브랜딩은 upstream 아트워크/로고 등을 대체하는 작업을 포함할 수 있습니다.

### TIP
다른 Rocky 패키지를 빌드하고 실험하려면, Rocky 자동 빌드 환경에서 현재 실패한 패키지 목록을 찾아보는 것이 좋습니다. 이 [링크](https://kojidev.rockylinux.org/koji/builds?state=3&order=-build_id)를 통해 확인할 수 있습니다: https://kojidev.rockylinux.org/koji/builds?state=3&order=-build_id


## 4. Rocky Devtools(rockybuild)를 사용하여 Rocky OS용 새 패키지를 빌드합니다.

`rockybuild`는 명령 줄 인자로 지정한 애플리케이션을 chroot 환경에서 빌드하기 위해 `rpmbuild` 및 `mock` 유틸리티를 호출합니다. `rockyget` 명령을 통해 자동으로 다운로드된 애플리케이션 소스와 RPM SPEC 파일에 의존합니다.

sed 유틸리티를 빌드하려면 `rockybuild`를 사용하십시오:

```
rockybuild sed
```

빌드 프로세스/단계를 완료하는 데 걸리는 시간은 빌드하려는 애플리케이션의 크기와 복잡성에 따라 다를 수 있습니다.

`rockybuild` 실행이 끝나면, 다음과 유사한 출력이 나타납니다. 이는 빌드가 성공적으로 완료되었음을 나타냅니다.

```
..........
+ exit 0
Finish: rpmbuild sed-4.5-2.el8.src.rpm
Finish: build phase for sed-4.5-2.el8.src.rpm
INFO: Done(~/rocky/rpms/sed/r8/SRPMS/sed-4.5-2.el8.src.rpm) Config(baseos) 4 minutes 34 seconds
INFO: Results and/or logs in: /home/centos/rocky/builds/sed/r8
........
```


모든 것이 잘 진행되었다면, `~/rocky/builds/sed/r8` 디렉토리 아래에 Rocky 지원 SRPM 파일이 생성될 것입니다.

`~/rocky/rpms/sed/r8/SRPMS/sed-4.5-2.el8.src.rpm`



## 5. 실패한 패키지 빌드 디버깅

이전 rockybuild 프로세스는 실패한 애플리케이션 빌드를 디버깅하는 데 사용할 수 있는 몇 가지 로그 파일을 생성합니다. 빌드 프로세스의 결과 및/또는 로그는 `~/rocky/builds/<PACKAGE NAME>/r8` 디렉토리 아래에 저장됩니다. 예를 들어 `~/rocky/builds/sed/r8`입니다.


```
~/rocky/builds/sed/r8
├── build.log
├── hw_info.log
├── installed_pkgs.log
├── root.log
├── sed-4.5-2.el8_3.src.rpm
├── sed-4.5-2.el8_3.x86_64.rpm
├── sed-debuginfo-4.5-2.el8_3.x86_64.rpm
├── sed-debugsource-4.5-2.el8_3.x86_64.rpm
└── state.log
```

에러 원인을 추적하기 위해 주로 build.log와 root.log 파일을 검토해야 합니다.     build.log 파일에는 모든 빌드 에러에 대한 정보가 포함되어 있고, root.log 파일에는 chroot 환경 설정 및 종료 프로세스에 대한 정보가 포함되어 있습니다. 모든 것이 동일한 상태에서 대부분의 빌드 디버깅/문제 해결 과정은 build.log 파일의 내용을 통해 수행될 수 있습니다.
