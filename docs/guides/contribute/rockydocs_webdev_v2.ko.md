---
title: 로컬 문서 - Podman
author: Wale Soyinka
contributors:
update: 13-Feb-2023
---

# 웹 개발을 위해 로컬에서 docs.rockylinux.org 웹 사이트 실행 | Podman


이 문서는 로컬 컴퓨터에서 전체 docs.rockylinux.org 웹 사이트의 로컬 복사본을 다시 만들고 실행하는 방법에 대한 단계를 안내합니다. 문서 웹 사이트의 로컬 복사본을 실행하는 것은 다음과 같은 경우에 유용합니다:

* docs.rockylinux.org 웹 사이트의 웹 개발 측면에 관심이 있는 경우 기여하고자 할 수 있습니다.
* 문서 작성자이며, 기여하기 전에 문서가 어떻게 렌더링되고 보일지 보고 싶을 수 있습니다.


## 콘텐츠 환경 생성하기

1. 전제조건이 충족되었는지 확인하십시오. 그렇지 않은 경우 "[사전 요구 사항 설정](#setup-the-prerequisites)" 섹션으로 건너뛴 다음 여기로 돌아오십시오.

2. 현재 작업 디렉토리를 로컬 시스템에서 글을 작성할 폴더로 변경합니다. 이 가이드의 나머지 부분에서 이 디렉토리를 `$ROCKYDOCS`로 지칭합니다.  데모의 경우 `$ROCKYDOCS`는 데모 시스템의 `$HOME/projects/rockydocs`를 가리킵니다.

아직 존재하지 않는 경우 $ROCKYDOCS를 생성하고 작업 디렉토리를 $ROCKYDOCS 유형으로 변경합니다.

```
mkdir -p $HOME/projects/rockydocs
export ROCKYDOCS=${HOME}/projects/rockydocs
cd  $ROCKYDOCS
```

3. `git`이 설치되어 있는지 확인하십시오(`dnf -y install git`).  $ROCKYDOCS에서 git을 사용하여 공식 Rocky Documentation 콘텐츠 저장소를 클론합니다. 다음과 같이 입력합니다:

```
git clone https://github.com/rocky-linux/documentation.git
```

이제 `$ROCKYDOCS/documentation` 폴더가 생겼을 것입니다. 이 폴더는 git 저장소이며, git의 제어 하에 있습니다.

4. 또한 git을 사용하여 공식 docs.rockylinux.org 저장소를 복제하십시오. 다음과 같이 입력합니다:

```
git clone https://github.com/rocky-linux/docs.rockylinux.org.git
```

이제 `$ROCKYDOCS/docs.rockylinux.org` 폴더가 생깁니다. 이 폴더는 웹 개발 기여를 실험할 수 있는 곳입니다.


## Rocky Docs 웹 개발 환경 생성 및 시작

5.  로컬 시스템에서 podman이 실행 중인지 확인하십시오(`systemctl`로 확인할 수 있음). 다음을 실행하여 테스트:

```
systemctl  enable --now podman.socket
```

6. 다음 내용으로 새 `docker-compose.yml` 파일을 만듭니다.

```
version: '2'
services:
  mkdocs:
    privileged: true
    image: rockylinux:9.1
    ports:
      - 8001:8001
    environment:
      PIP_NO_CACHE_DIR: "off"
      PIP_DISABLE_PIP_VERSION_CHECK: "on"
    volumes:
       - type: bind
         source: ./documentation
         target: /app/docs
       - type: bind
         source: ./docs.rockylinux.org
         target: /app/docs.rockylinux.org
    working_dir: /app
    command: bash -c "dnf install -y python3 pip git && \
       ln -sfn  /app/docs   docs.rockylinux.org/docs && \
       cd docs.rockylinux.org && \
       git config  --global user.name webmaster && \
       git config  --global user.email webmaster@rockylinux.org && \
       curl -SL https://raw.githubusercontent.com/rocky-linux/documentation-test/main/docs/labs/mike-plugin-changes.patch -o mike-plugin-changes.patch && \
       git apply --reverse --check mike-plugin-changes.patch && \
       /usr/bin/pip3 install --no-cache-dir -r requirements.txt && \
       /usr/local/bin/mike deploy -F mkdocs.yml 9.1 91alias && \
       /usr/local/bin/mike set-default 9.1 && \
       echo  All done && \
       /usr/local/bin/mike serve  -F mkdocs.yml -a  0.0.0.0:8001"

```

파일 이름을 `docker-compose.yml`로 저장하고 $ROCKYDOCS 작업 디렉토리에 파일을 저장합니다.

다음을 실행하여 docker-compose.yml 파일의 복사본을 빠르게 다운로드할 수도 있습니다.

```
curl -SL https://raw.githubusercontent.com/rocky-linux/documentation-test/main/docs/labs/docker-compose-rockydocs.yml -o docker-compose.yml
```


7. 마지막으로 docker-compose를 사용하여 서비스를 불러옵니다. 다음과 같이 입력합니다:

```
docker-compose  up
```


## 로컬 docs.rockylinux.org 웹사이트 보기

8. Rocky Linux 시스템에서 실행 중인 방화벽이 있는 경우를 대비하여 포트 8001이 열려 있는지 확인하십시오. 다음과 같이 입력합니다:

```
firewall-cmd  --add-port=8001/tcp  --permanent
firewall-cmd  --reload
```

컨테이너가 실행되고 있으므로 웹 브라우저를 다음 URL로 이동하여 로컬 사이트의 복사본을 보여줄 수 있습니다:

http://localhost:8001

또는

http://<SERVER_IP>:8001




## 전제 조건 설정

다음을 실행하여 podman 및 기타 도구를 설치하고 설정합니다.

```
sudo dnf -y install podman podman-docker git

sudo systemctl enable --now  podman.socket

```

docker-compose를 설치하고 실행 가능하게 만드십시오. 다음과 같이 입력합니다:

```
curl -SL https://github.com/docker/compose/releases/download/v2.16.0/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose

chmod 755 /usr/local/bin/docker-compose
```


도커 소켓에 대한 권한을 수정합니다. 다음과 같이 입력합니다:

```
sudo chmod 666 /var/run/docker.sock
```


### 참고 사항

* 이 가이드의 지침은 Rocky 문서 작성자/콘텐츠 기여자의 전제 조건이 **아닙니다**.
* 전체 환경은 Podman 컨테이너에서 실행되므로 로컬 컴퓨터에 Podman을 올바르게 설정해야 합니다.
* 컨테이너는 https://hub.docker.com/r/rockylinux/rockylinux에서 사용할 수 있는 공식 Rocky Linux 9.1 도커 이미지 위에 구축됩니다.
* 컨테이너는 문서 콘텐츠를 웹 엔진(mkdocs)과 별도로 유지합니다.
* 컨테이너는 포트 8001에서 수신 대기 중인 로컬 웹 서버를 시작합니다. 
