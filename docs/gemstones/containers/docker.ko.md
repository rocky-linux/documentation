---
title: 도커 - 엔진 설치
author: wale soyinka
contributors:
date: 2021-08-04
tags:
  - docker
---

# 소개

Docker Engine은 Rocky Linux 서버에서 기본 Docker 스타일의 컨테이너 작업을 실행하는 데 사용될 수 있습니다. 이는 전체 Docker Desktop 환경을 실행하는 것보다 선호되는 경우도 있습니다.

## docker 리포지토리 추가

`dnf` 유틸리티를 사용하여 도커 저장소를 Rocky Linux 서버에 추가합니다. 다음을 입력하세요.

```
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
```

## 필요한 패키지 설치

다음을 실행하여 최신 버전의 Docker Engine, containerd 및 Docker Compose를 설치합니다.

```
sudo dnf -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin
```

## systemd docker 서비스(dockerd) 시작 및 활성화

`systemctl` 유틸리티를 사용하여 dockerd 데몬을 다음 시스템 재부팅 때 자동으로 시작하도록 구성하고 현재 세션에서 동시에 시작합니다. 다음을 입력하세요.

```
sudo systemctl --now enable docker
```


### 참고 사항

```
docker-ce               : 이 패키지는 도커 컨테이너를 빌드하고 실행하는 데 사용되는 기본 기술을 제공합니다 (dockerd). docker-ce-cli           : 명령 줄 인터페이스 (CLI) 클라이언트 도커 도구 (docker)를 제공합니다. containerd.io           : 컨테이너 런타임 (runc)을 제공합니다. docker-compose-plugin   : 'docker compose' 하위 명령을 제공하는 플러그인입니다. 

```



