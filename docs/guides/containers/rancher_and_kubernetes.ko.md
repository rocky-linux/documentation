---
title: Working with Rancher and Kubernetes
author: Antoine Le Morvan
contributors: Steven Spencer
update: 22-Feb-2024
tested_with: 9.3
tags:
  - rancher
  - kubernetes
  - podman
  - docker
---

# Working with Rancher and Kubernetes

**Kubernetes** (**K8s**)는 컨테이너화된 애플리케이션의 배포 및 관리를 위한 오픈 소스 컨테이너 오케스트레이션 시스템입니다.

이미 시장에서 자리잡은 바 있어 K8s를 새롭게 소개할 필요는 없습니다.

클라우드 제공업체들은 관리형 Kubernetes 플랫폼을 쉽게 배포할 수 있게 해주지만, 온프레미스 클러스터를 설정하고 관리하는 것은 어떨까요?

여러 클러스터를 온프레미스 또는 멀티 클라우드에서 관리하는 것은 얼마나 쉬울까요?

마지막 두 질문에 대한 답은 '아니오'입니다. 온프레미스 클러스터를 설정하는 것은 어렵고, 멀티 클라우드 클러스터를 관리하는 것은 실제로 골치 아픈 일입니다.

여기서 이 가이드의 주제인 **Rancher**가 등장합니다! Rancher 또한 오픈 소스 시스템으로, 여러 멀티 클라우드 또는 온프레미스 클러스터의 설치 및 오케스트레이션을 가능하게 하며, 애플리케이션 카탈로그와 자원 시각화를 위한 실용적인 웹 인터페이스와 같은 흥미로운 기능을 제공합니다.

Rancher는 클라우드 제공업체가 관리하는 Kubernetes 클러스터를 배포하거나 기존 Kubernetes 클러스터를 가져오거나, K3s(간단히 말해 K8s의 가벼운 버전) 또는 K8s 클러스터를 배포할 수 있게 해줍니다.

이 가이드는 Rancher를 발견하고 설치하며 시작하는 방법을 도와주고, Rocky Linux 서버에 배포된 온프레미스 Kubernetes 클러스터를 생성하는 방법을 안내합니다.

## Rancher 배포

서버에 Docker가 설치되어 있다면, Rancher를 설치하는 것은 매우 쉽습니다.

Docker 설치 방법은 [여기에서](https://docs.rockylinux.org/gemstones/docker/) 찾을 수 있습니다.

Rocky 9에서 실행하려면 Rancher에 modules/
/run//run/ 이 필요합니다.

시스템 시작 시 필요한 모듈을 로드하도록 하는 것이 한 가지 방법은 `/etc/modules-load.d/rancher.conf` 파일을 생성하는 것 입니다.

```text
ip_tables
ip_conntrack
iptable_filter
ipt_state
```

그리고 변경 사항을 적용하기 위한 가장 쉬운 방법은 서버를 재부팅하는 것입니다: `sudo reboot`.

재부팅 후, `lsmod | grep <module_name>` 명령어를 사용하여 모듈이 제대로 로드되었는지 확인할 수 있습니다.

이제 Rancher 컨테이너를 받을 준비가 된 시스템이 있습니다:

```bash
docker pull rancher/rancher:latest
docker run -d --name=rancher --privileged --restart=unless-stopped -p 80:80 -p 443:443 rancher/rancher:latest
```

!!! 노트

```
궁금하다면 새 컨테이너의 로그를 확인해 보세요. 단일 노드를 가진 K3s 클러스터가 방금 생성되었다는 것을 알 수 있습니다! 이것이 Rancher가 스탠드얼론 버전에서 작동하는 방식입니다.

![k3s local cluster](img/rancher_k3s_local_cluster.png)
```

Rancher가 443 포트에서 수신하므로 방화벽을 열어 외부에서 접근할 수 있도록 합니다:

```bash
firewall-cmd --permanent --zone=public --add-service=https
firewall-cmd --zone=public --add-service=https
```

새로 배포된 Rancher 웹 인터페이스로 이동하면 컨테이너 로그에서 관리자 비밀번호를 어떻게 검색하는지 알려주는 메시지가 표시됩니다.

이 작업을 수행하려면 다음 명령을 실행하세요:

```bash
docker logs rancher  2>&1 | grep "Bootstrap Password:"
```

이제 Rancher의 웹UI에 연결할 준비가 되었습니다.

![rancher](img/rancher_login.png)

!!! 노트

```
이 솔루션은 결코 생산 준비가 된 것이 아닙니다. 시스템이 고가용성을 보장받아야 하지만, 시작하기에는 좋습니다. 최적의 HA를 위해 기존 K8s 클러스터에 Rancher를 배포하는 것을 고려하세요.
```

## Rocky Linux 9 서버에서의 Kubernetes

Rancher는 Kubernetes의 도커 기반 버전인 RKE(Rancher Kubernetes Engine)을 제공합니다.

필요한 것은 여러 대의 Rocky Linux 서버와 그 위에 설치된 [Docker 엔진](https://docs.rockylinux.org/gemstones/docker/)뿐입니다.

Kubernetes의 요구 사항 중 하나가 마스터 노드의 수가 홀수(예: 1 또는 3)여야 한다는 것을 잊지 마세요. 우리의 테스트를 위해, 3개의 마스터 노드와 오직 워커 역할만 있는 2개의 추가 노드로 시작합니다.

서버에 Docker가 설치되면 각 서버에서 `firewalld`를 중지하고 `nftables`를 실행하세요:

```bash
systemctl stop firewalld
systemctl disable firewalld
systemctl start nftables
systemctl enable nftables
```

우리는 이제 클러스터 생성을 위해 준비가 되었습니다.

### 클러스터 생성

클러스터 관리 영역에서 새 클러스터를 생성하세요:

![create cluster](img/rancher_cluster_create.png)

호스팅된 Kubernetes 제공자에서 클러스터를 생성하거나, 새 노드를 프로비저닝하고, RKE2/K3s를 사용하여 클러스터를 생성하거나, 우리 경우처럼 기존 노드를 사용하고 RKE2/K3s를 사용하여 클러스터를 생성할 자유가 있습니다.

마지막 옵션을 선택하세요.

클러스터 이름과 설명을 입력하세요.

클러스터 생성을 시작하기 전에 다양한 옵션을 탐색하는 데 시간을 할애하세요.

![cluster creation](img/rancher_create_custom_cluster.png)

클러스터가 생성되면 등록 탭으로 가서 우리 서버를 추가하세요:

![registring hosts](img/rancher_hosts_registration.png)

추가하려는 노드의 다양한 역할을 선택하고 필요한 명령 줄을 복사하세요. 클러스터가 자체 서명된 인증서를 사용하는 경우 적절한 상자를 체크하세요.

구성에 추가하려는 노드로 이동하여 앞서 복사한 명령을 붙여넣으세요.

몇 분 후, 서버가 클러스터에 추가되고, 첫 번째 서버이며 모든 역할을 가지고 있다면 클러스터가 웹 인터페이스에서 사용 가능하게 됩니다.

5대의 서버를 모두 추가하면 이와 유사한 결과를 얻게 됩니다:

![clusters hosts](img/rancher_cluster_ready.png)

## 결론

축하합니다! Rancher의 기능 덕분에 몇 분/시간 만에 첫 Kubernetes 클러스터를 설치했습니다.

Kubernetes가 처음이라면 이미 자랑스러워할 수 있습니다: 올바른 길에 있습니다. 이제 Kubernetes의 탐색을 계속할 수 있는 모든 것을 갖추었습니다.
