---
title: 로컬 문서 - 도커
author: Wale Soyinka
contributors: Steve Spencer
update: 27-Feb-2022
---

# 웹 개발 및/또는 콘텐츠 작성자를 위해 docs.rockylinux.org 웹 사이트의 로컬 사본 실행

이 문서는 로컬 컴퓨터에서 전체 docs.rockylinux.org 웹 사이트의 로컬 복사본을 재생성하고 실행하는 방법을 안내합니다. **이것은 진행 중인 작업입니다.**

문서 웹 사이트의 로컬 복사본을 실행하는 것은 다음과 같은 경우에 유용합니다:

* docs.rockylinux.org 웹 사이트의 웹 개발 측면에 관심이 있는 경우 기여하고자 할 수 있습니다.
* 문서 작성자이며, 기여하기 전에 문서가 어떻게 렌더링되고 보일지 보고 싶을 수 있습니다.
* 웹 개발자로서 docs.rockylinux.org 웹 사이트에 기여하거나 유지 관리에 도움을 줄 수 있습니다.


### 참고 사항:

* 이 가이드의 지침은 Rocky 문서 작성자/콘텐츠 기여자의 전제 조건이 **아닙니다**.
* 전체 환경은 Docker 컨테이너 내에서 실행되므로 로컬 컴퓨터에 Docker 엔진이 필요합니다.
* 컨테이너는 https://hub.docker.com/r/rockylinux/rockylinux에서 사용할 수 있는 공식 RockyLinux 도커 이미지 위에 구축됩니다.
* 컨테이너는 문서 콘텐츠(가이드, 책, 이미지 등)를 웹 엔진(mkdocs)에서 분리하여 보관합니다.
* 컨테이너는 포트 8000에서 리스닝하는 로컬 웹 서버를 시작하며, 포트 8000은 Docker 호스트로 포워딩됩니다.  그리고 포트 8000은 Docker 호스트로 전달됩니다.


## 콘텐츠 환경 생성하기

1. 현재 작업 디렉토리를 로컬 시스템에서 글을 작성할 폴더로 변경합니다. 이 가이드의 나머지 부분에서 이 디렉토리를 `$ROCKYDOCS`로 지칭합니다.  데모 시스템에서 `$ROCKYDOCS`는 `~/projects/rockydocs`를 가리킵니다.

$ROCKYDOCS가 이미 존재하지 않으면 만들고, 다음과 같이 입력합니다:

```
cd  $ROCKYDOCS
```

2. `git`이 설치되어 있는지 확인하십시오(`dnf -y install git`).  $ROCKYDOCS에서 git을 사용하여 공식 Rocky Documentation 콘텐츠 저장소를 클론합니다. 다음과 같이 입력합니다:

```
git clone https://github.com/rocky-linux/documentation.git
```

이제 `$ROCKYDOCS/documentation` 폴더가 생겼을 것입니다. 이 폴더는 git 저장소이며, git의 제어 하에 있습니다.


## Rocky Docs 웹 개발 환경 생성 및 시작

3.  로컬 컴퓨터에서 Docker가 실행 중인지 확인합니다(`systemctl`로 확인할 수 있음).

4. 터미널에서 다음과 같이 입력합니다:

```
docker pull wsoyinka/rockydocs:latest
```

5. 이미지가 성공적으로 다운로드되었는지 확인합니다. 다음과 같이 입력합니다:

```
docker image  ls
```

## RockyDocs 컨테이너 시작하기

1. rockydocs 이미지로부터 컨테이너를 시작합니다. 다음과 같이 입력합니다:

```
docker run -it --name rockydoc --rm \
     -p 8000:8000  \
     --mount type=bind,source="$(pwd)"/documentation,target=/documentation  \
     wsoyinka/rockydocs:latest

```


또는  `docker-compose`를 설치했다면,  `docker-compose`를 사용하여 `docker-compose.yml`이라는 파일을 생성하고 다음 내용을 추가합니다:

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

파일 이름을 `docker-compose.yml`로 저장하고 $ROCKYDOCS 작업 디렉토리에 파일을 저장합니다.  그리고 다음 명령으로 서비스/컨테이너를 시작합니다:

```
docker-compose  up
```


## 로컬 docs.rockylinux.org 웹사이트 보기

컨테이너가 실행되고 있으므로 웹 브라우저를 다음 URL로 이동하여 로컬 사이트의 복사본을 보여줄 수 있습니다:

http://localhost:8000
