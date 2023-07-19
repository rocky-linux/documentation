---
title: Podman의 Nextcloud
author: Ananda Kammampati
contributors: Ezequiel Bruni, Steven Spencer
tested_with: 8.5
tags:
  - podman
  - podman
  - nextcloud
---

# Rocky Linux에서 Podman 컨테이너로 Nextcloud 실행

## 소개

이 문서는 Rocky Linux에서 Podman 컨테이너로 [Nextcloud](https://nextcloud.com) 인스턴스를 빌드하고 실행하는 데 필요한 모든 단계를 설명합니다. 또한 이 전체 가이드는 Raspberry Pi에서 테스트되었으므로 모든 Rocky 지원 프로세서 아키텍처와 호환되어야 합니다.

절차는 자동화를 위한 자체 셸 스크립트가 있는 여러 단계로 나뉩니다.

1. `podman` 및 `buildah` 패키지를 설치하여 각각 컨테이너를 관리하고 빌드합니다.
2. 필요한 모든 컨테이너에 대해 용도가 변경될 기본 이미지 만들기
3. MariaDB 데이터베이스 구축 및 실행에 필요한 셸 스크립트로 `db-tools` 컨테이너 이미지 생성
4. Podman 컨테이너로 MariaDB 생성 및 실행
5. MariaDB Podman 컨테이너를 백엔드로 사용하여 Nextcloud를 Podman 컨테이너로 생성 및 실행

가이드에 있는 대부분의 명령을 수동으로 실행할 수 있지만 몇 가지 bash 스크립트를 설정하면 특히 다른 설정, 변수 또는 컨테이너 이름으로 이러한 단계를 반복하려는 경우 작업이 훨씬 쉬워집니다.

!!! "초보자를 위한 참고 사항:"을 참고하십시오.

    Podman은 컨테이너, 특히 OCI(Open Containers Initiative) 컨테이너를 관리하기 위한 도구입니다. 대부분의 동일한 명령이 두 도구 모두에서 작동하지 않는다는 점에서 거의 Docker와 호환되도록 설계되었습니다. "Docker"가 아무 의미가 없는 경우 또는 단지 호기심이 있는 경우라도 [Podman의 자체 웹 사이트](https://podman.io)에서 Podman과 작동 방식에 대해 자세히 알아볼 수 있습니다.
    
    `buildah`는 "DockerFiles"를 기반으로 Podman 컨테이너 이미지를 빌드하는 도구입니다.
    
    이 가이드는 사람들이 Podman 컨테이너를 일반적으로, 특히 Rocky Linux에서 실행하는 데 익숙해지도록 돕기 위한 연습으로 설계되었습니다.

## 전제 조건 및 가정

다음은 이 가이드를 작동시키기 위해 필요하거나 알아야 할 모든 것입니다.

* 명령줄, bash 스크립트 및 Linux 구성 파일 편집에 익숙합니다.
* 원격 시스템에서 작업하는 경우 SSH 액세스.
* 선택한 명령줄 기반 텍스트 편집기. 이 가이드에서는 `vi`를 사용할 것입니다.
* 인터넷에 연결된 Rocky Linux 머신(역시 Raspberry Pi가 잘 작동함).
* 이러한 명령 중 다수는 루트로 실행해야 하므로 시스템에 루트 또는 sudo 가능 사용자가 필요합니다.
* 웹 서버와 MariaDB에 익숙하면 확실히 도움이 될 것입니다.
* 컨테이너 및 Docker에 대한 지식은 *확실한* 장점이 되지만 반드시 필요한 것은 아닙니다.

## 01단계: `podman` 및 `buildah` 설치

먼저 시스템이 최신 상태인지 확인하십시오.

```bash
dnf update
```

그런 다음 사용할 모든 추가 패키지에 대한 `epel-release` 저장소를 설치해야 합니다.

```bash
dnf -y install epel-release 
```

완료되면 다시 업데이트하거나(때때로 도움이 됨) 계속해서 필요한 패키지를 설치할 수 있습니다.

```bash
dnf -y install podman buildah
```

설치가 완료되면 `podman --version` 및 `buildah --version`을 실행하여 모든 것이 올바르게 작동하는지 확인합니다.

컨테이너 이미지를 다운로드하기 위해 Red Hat의 레지스트리에 액세스하려면 다음을 실행해야 합니다.

```bash
vi /etc/containers/registries.conf
```

아래에 보이는 것과 같은 섹션을 찾으십시오. 주석 처리된 경우 주석을 제거하십시오.

```
[registries.insecure]
registries = ['registry.access.redhat.com', 'registry.redhat.io', 'docker.io'] 
insecure = true
```

## 02단계: `base` 컨테이너 이미지 생성

이 가이드에서는 루트 사용자로 작업하지만 모든 홈 디렉터리에서 이 작업을 수행할 수 있습니다. 아직 없는 경우 루트 디렉터리로 변경합니다.

```bash
cd /root
```

이제 다양한 컨테이너 빌드에 필요한 모든 디렉터리를 만듭니다.

```bash
mkdir base db-tools mariadb nextcloud
```

이제 작업 디렉터리를 기본 이미지의 폴더로 변경합니다.

```bash
cd /root/base
```

그리고 DockerFile이라는 파일을 만듭니다. 예, Podman도 사용합니다.

```bash
vi Dockerfile
```

다음 텍스트를 복사하여 새 DockerFile에 붙여넣습니다.

```
FROM rockylinux/rockylinux:latest
ENV container docker
RUN yum -y install epel-release ; yum -y update
RUN dnf module enable -y php:7.4
RUN dnf install -y php
RUN yum install -y bzip2 unzip lsof wget traceroute nmap tcpdump bridge-utils ; yum -y update
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;
VOLUME [ "/sys/fs/cgroup" ]
CMD ["/usr/sbin/init"]
```

이전 파일을 저장하고 닫고 새 bash 스크립트 파일을 만듭니다.

```bash
vi build.sh
```

그런 다음 이 콘텐츠를 붙여넣습니다.

```
#!/bin/bash
clear
buildah rmi `buildah images -q base` ;
buildah bud --no-cache -t base . ;
buildah images -a
```

이제 다음을 사용하여 빌드 스크립트를 실행 가능하게 만드십시오.

```bash
chmod +x build.sh
```

그리고 실행하세요:

```bash
./build.sh
```

완료될 때까지 기다렸다가 다음 단계로 넘어갑니다.

## 03단계: `db-tools` 컨테이너 이미지 생성

이 가이드의 목적을 위해 데이터베이스 설정을 최대한 단순하게 유지하고 있습니다. 다음 사항을 기록하고 필요에 따라 수정해야 합니다:

* 데이터베이스 이름: ncdb
* 데이터베이스 사용자: nc-user
* 데이터베이스 패스: nc-pass
* 서버 IP 주소(아래 예시 IP 사용)

먼저 db-tools 이미지를 빌드할 폴더로 변경합니다.

```bash
First, change to the folder where you'll be building the db-tools image:
```

이제 Podman 컨테이너 이미지 내에서 사용할 일부 bash 스크립트를 설정합니다. 먼저 자동으로 데이터베이스를 구축할 스크립트를 만듭니다.

```bash
vi db-create.sh
```

이제 원하는 텍스트 편집기를 사용하여 다음 코드를 복사하여 해당 파일에 붙여넣습니다.

```
#!/bin/bash
mysql -h 10.1.1.160 -u root -p rockylinux << eof
create database ncdb;
grant all on ncdb.* to 'nc-user'@'10.1.1.160' identified by 'nc-pass';
flush privileges;
eof
```

저장하고 닫은 다음 필요에 따라 데이터베이스를 삭제하기 위한 스크립트를 사용하여 단계를 반복합니다.

```bash
vi db-drop.sh
```

이 코드를 복사하여 새 파일에 붙여넣습니다.

```
#!/bin/bash
mysql -h 10.1.1.160 -u root -p rockylinux << eof
drop database ncdb;
flush privileges;
eof
```

마지막으로 `db-tools` 이미지에 대한 DockerFile을 설정하겠습니다.

```bash
vi Dockerfile
```

복사 및 붙여 넣기:

```
FROM localhost/base
RUN yum -y install mysql
WORKDIR /root
COPY db-drop.sh db-drop.sh
COPY db-create.sh db-create.sh
```

마지막으로 bash 스크립트를 만들어 명령에 따라 이미지를 빌드합니다.

```bash
vi build.sh
```

원하는 코드:

```
#!/bin/bash
clear
buildah rmi `buildah images -q db-tools` ;
buildah bud --no-cache -t db-tools . ;
buildah images -a
```

저장하고 닫은 다음 파일을 실행 가능하게 만듭니다.

```bash
chmod +x build.sh
```

그리고 실행하세요:

```bash
./build.sh
```

## 04단계: MariaDB 컨테이너 이미지 생성

프로세스의 요령을 이해하고 있습니까? 실제 데이터베이스 컨테이너를 구축할 시간입니다. 작업 디렉토리를 `/root/mariadb`로 변경합니다.

```bash
cd /root/mariadb
```

원할 때마다 컨테이너를 (재)빌드하는 스크립트를 만듭니다.

```bash
vi db-init.sh
```

필요한 코드는 다음과 같습니다.

!!! warning "주의"

    이 가이드의 목적에 따라 다음 스크립트는 모든 Podman 볼륨을 삭제합니다. 자체 볼륨으로 실행 중인 다른 애플리케이션이 있는 경우 "podman volume rm --all" 행을 수정/주석 처리하십시오.

```
#!/bin/bash
clear
echo " "
echo "Deleting existing volumes if any...."
podman volume rm --all ;
echo " "
echo "Starting mariadb container....."
podman run --name mariadb --label mariadb -d --net host -e MYSQL_ROOT_PASSWORD=rockylinux -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v mariadb-data:/var/lib/mysql/data:Z mariadb ;

echo " "
echo "Initializing mariadb (takes 2 minutes)....."
sleep 120 ;

echo " "
echo "Creating ncdb Database for nextcloud ....."
podman run --rm --net host db-tools /root/db-create.sh ;

echo " "
echo "Listing podman volumes...."
podman volume ls
```

다음은 원할 때마다 데이터베이스를 재설정하는 스크립트를 만드는 곳입니다.

```bash
vi db-reset.sh
```

코드는 다음과 같습니다.

```
#!/bin/bash
clear
echo " "
echo "Deleting ncdb Database for nextcloud ....."
podman run --rm --net host db-tools /root/db-drop.sh ;

echo " "
echo "Creating ncdb Database for nextcloud ....."
podman run --rm --net host db-tools /root/db-create.sh ;
```

마지막으로 전체 mariadb 컨테이너를 하나로 묶을 빌드 스크립트는 다음과 같습니다.

```bash
vi build.sh
```

해당 코드:

```
#!/bin/bash
clear
buildah rmi `buildah images -q mariadb` ;
buildah bud --no-cache -t mariadb . ;
buildah images -a
```

이제 DockferFile(`vi Dockerfile`)을 만들고 다음 한 줄에 붙여넣기만 하면 됩니다.

```
FROM arm64v8/mariadb
```

이제 빌드 스크립트를 실행 가능하게 만들고 실행합니다.

```bash
chmod +x *.sh

./build.sh
```

## 05단계: Nextcloud 컨테이너 구축 및 실행

우리는 마지막 단계에 있으며 프로세스는 거의 반복됩니다. Nextcloud 이미지 디렉터리로 변경합니다.

```bash
cd /root/nextcloud
```

이번에는 다양하게 DockerFile을 먼저 설정합니다.

```bash
vi Dockerfile
```

!!! 참고사항

    다음 비트는 ARM 아키텍처(Raspberry Pi용)를 가정하므로 다른 아키텍처를 사용하는 경우 이를 변경해야 합니다.

그리고 다음 비트를 붙여넣습니다.

```
FROM arm64v8/nextcloud
```

Npw는 빌드 스크립트를 만듭니다.

```bash
vi build.sh
```

그리고 다음 코드를 붙여넣습니다.

```
#!/bin/bash
clear
buildah rmi `buildah images -q nextcloud` ;
buildah bud --no-cache -t nextcloud . ;
buildah images -a
```

이제 모든 파일을 잃을 염려 없이 컨테이너와 데이터베이스를 재구축할 수 있도록 호스트 서버(Podman 컨테이너가 *아닌*)에 여러 로컬 폴더를 설정할 것입니다.

```bash
mkdir -p /usr/local/nc/nextcloud /usr/local/nc/apps /usr/local/nc/config /usr/local/nc/data
```

마지막으로 우리를 위해 실제로 Nextcloud 컨테이너를 빌드할 스크립트를 만들 것입니다.

```bash
vi run.sh
```

여기에 필요한 모든 코드가 있습니다. `MYSQL_HOST`의 IP 주소를 MariaDB 인스턴스를 실행 중인 도커 컨테이너로 변경해야 합니다.

```
#!/bin/bash
clear
echo " "
echo "Starting nextloud container....."
podman run --name nextcloud --net host --privileged -d -p 80:80 \
-e MYSQL_HOST=10.1.1.160 \
-e MYSQL_DATABASE=ncdb \
-e MYSQL_USER=nc-user \
-e MYSQL_PASSWORD=nc-pass \
-e NEXTCLOUD_ADMIN_USER=admin \
-e NEXTCLOUD_ADMIN_PASSWORD=rockylinux \
-e NEXTCLOUD_DATA_DIR=/var/www/html/data \
-e NEXTCLOUD_TRUSTED_DOMAINS=10.1.1.160 \
-v /sys/fs/cgroup:/sys/fs/cgroup:ro \
-v /usr/local/nc/nextcloud:/var/www/html \
-v /usr/local/nc/apps:/var/www/html/custom_apps \
-v /usr/local/nc/config:/var/www/html/config \
-v /usr/local/nc/data:/var/www/html/data \
nextcloud ;
```

저장하고 닫고 모든 스크립트를 실행 가능하게 만든 다음 먼저 이미지 작성 스크립트를 실행하십시오.

```bash
chmod +x *.sh

./build.sh
```

모든 이미지가 올바르게 빌드되었는지 확인하려면 `podman images`를 실행하세요. 다음과 같은 목록이 표시됩니다.

```
REPOSITORY                      TAG    IMAGE ID     CREATED      SIZE
localhost/db-tools              latest 8f7ccb04ecab 6 days ago   557 MB
localhost/base                  latest 03ae68ad2271 6 days ago   465 MB
docker.io/arm64v8/mariadb       latest 89a126188478 11 days ago  405 MB
docker.io/arm64v8/nextcloud     latest 579a44c1dc98 3 weeks ago  945 MB
```

모든 것이 올바르게 보이면 최종 스크립트를 실행하여 Nextcloud를 시작하고 진행합니다.

```bash
./run.sh
```

`podman ps -a`를 실행하면 다음과 같이 실행 중인 컨테이너 목록이 표시됩니다.

```
CONTAINER ID IMAGE                              COMMAND              CREATED        STATUS            PORTS    NAMES
9518756a259a docker.io/arm64v8/mariadb:latest   mariadbd             3 minutes  ago Up 3 minutes ago           mariadb
32534e5a5890 docker.io/arm64v8/nextcloud:latest apache2-foregroun... 12 seconds ago Up 12 seconds ago          nextcloud
```

여기에서 브라우저가 서버 IP 주소를 가리킬 수 있어야 합니다. 따라하고 있고 우리의 예와 동일한 IP를 가지고 있는 경우 여기(예: http://your-server-ip)에서 이를 대체하고 Nextcloud가 실행되고 있는지 확인할 수 있습니다.

## 결론

특히 Nextcloud 인스턴스가 공개용인 경우에는 프로덕션 서버에서 이 가이드를 다소 수정해야 합니다. 그럼에도 불구하고 Podman의 작동 방식과 스크립트 및 여러 기본 이미지를 사용하여 Podman을 설정하여 더 쉽게 다시 빌드할 수 있는 방법에 대한 기본적인 아이디어를 얻을 수 있습니다.
