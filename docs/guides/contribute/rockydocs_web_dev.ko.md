---
title: 로컬 문서 - 도커
author: Wale Soyinka
contributors: Steve Spencer
update: 27-Feb-2022
---

# 웹 개발 및/또는 콘텐츠 작성자를 위해 docs.rockylinux.org 웹 사이트의 로컬 사본 실행

이 문서는 로컬 컴퓨터에서 전체 docs.rockylinux.org 웹 사이트의 로컬 복사본을 다시 만들고 실행하는 방법을 안내합니다. **작업이 진행 중입니다.**

설명서 웹 사이트의 로컬 복사본을 실행하면 다음 시나리오에서 유용할 수 있습니다.

* docs.rockylinux.org 웹사이트의 웹 개발 측면에 대해 배우고 기여하는 데 관심이 있습니다.
* 귀하는 작성자이며 문서를 제공하기 전에 문서 웹 사이트에서 문서가 어떻게 렌더링/표시되는지 확인하고 싶습니다.
* 귀하는 docs.rockylinux.org 웹사이트에 기여하거나 유지 관리를 돕고자 하는 웹 개발자입니다.


### 참고 사항:

* 이 가이드의 지침은 Rocky 문서 작성자/콘텐츠 기여자의 전제 조건이 **아닙니다**.
* 전체 환경은 Docker 컨테이너에서 실행되므로 로컬 머신에 Docker 엔진이 필요합니다.
* 컨테이너는 https://hub.docker.com/r/rockylinux/rockylinux에서 사용할 수 있는 공식 RockyLinux 도커 이미지 위에 구축됩니다.
* 컨테이너는 문서 콘텐츠(가이드, 책, 이미지 등)를 웹 엔진(mkdocs)과 별도로 보관합니다.
* 컨테이너는 포트 8000에서 수신 대기 중인 로컬 웹 서버를 시작합니다.  그리고 포트 8000은 Docker 호스트로 전달됩니다.


## 콘텐츠 환경 만들기

1. 로컬 시스템의 현재 작업 디렉토리를 작성하려는 폴더로 변경하십시오. 이 안내서의 나머지 부분에서는 이 디렉토리를 `$ROCKYDOCS`라고 합니다.  데모의 경우 `$ROCKYDOCS`는 데모 시스템의 `~/projects/rockydocs`를 가리킵니다.

아직 존재하지 않는 경우 $ROCKYDOCS를 만들고 다음을 입력합니다.

```
cd  $ROCKYDOCS
```

2. `git`이 설치되어 있는지 확인하십시오(`dnf -y install git`).  $ROCKYDOCS에 있는 동안 git을 사용하여 공식 Rocky Documentation 콘텐츠 저장소를 복제합니다. 유형:

```
git clone https://github.com/rocky-linux/documentation.git
```

이제 `$ROCKYDOCS/documentation` 폴더가 생깁니다. 이 폴더는 git 리포지토리이며 git이 제어합니다.


## Rocky Docs 웹 개발 환경 생성 및 시작

3.  로컬 컴퓨터에서 Docker가 실행 중인지 확인합니다(`systemctl`로 확인할 수 있음).

4. 터미널 유형에서:

```
docker pull wsoyinka/rockydocs:latest
```

5. 이미지가 성공적으로 다운로드되었는지 확인하십시오. 유형:

```
docker image  ls
```

## RockyDocs 컨테이너 시작하기

1. rockydocs 이미지에서 컨테이너를 시작합니다. 유형:

```
docker run -it --name rockydoc --rm \
     -p 8000:8000  \
     --mount type=bind,source="$(pwd)"/documentation,target=/documentation  \
     wsoyinka/rockydocs:latest

```


또는 원하는 경우 `docker-compose`가 설치되어 있는 경우 다음 내용으로 `docker-compose.yml`이라는 작성 파일을 만들 수 있습니다.

```
version: "3.9"
services:
  rockydocs:
    image: wsoyinka/rockydocs:latest
    volumes:
      - type: bind
        source: ./documentation
        target: /documentation
    container_name: rocky
    ports:
       - "8000:8000"

```

파일 이름을 `docker-compose.yml`로 $ROCKYDOCS 작업 디렉터리에 저장합니다.  그리고 다음을 실행하여 서비스/컨테이너를 시작합니다.

```
docker-compose  up
```


## 로컬 docs.rockylinux.org 웹사이트 보기

컨테이너가 실행 중이면 이제 웹 브라우저에서 다음 URL로 이동하여 사이트의 로컬 사본을 볼 수 있습니다.

http://localhost:8000
