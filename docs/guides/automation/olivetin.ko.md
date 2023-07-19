---
title: OliveTin
author: Ezequiel Bruni
contributors: Steven Spencer
tested_with: 8.5, 8.6
tags:
  - 자동화
  - web
  - bash
---

# 설치 방법 & Rocky Linux에서 OliveTin 사용

## 소개

동일한 CLI 명령을 반복해서 입력하는 데 지친 적이 있습니까? 집에 있는 모든 사람이 개입 없이 Plex 서버를 다시 시작할 수 있기를 원한 적이 있습니까? 웹 패널에 이름을 입력하고 버튼을 누르면 맞춤형 Docker/LXD 컨테이너가 마술처럼 나타나는 것을 보고 싶습니까?

그런 다음 OliveTin을 확인하고 싶을 수도 있습니다. OliveTin은 말 그대로 구성 파일에서 웹 페이지를 생성할 수 있는 앱이며 해당 웹 페이지에는 버튼이 있습니다. 버튼을 누르면 OliveTin이 사용자가 직접 설정한 미리 설정된 bash 명령을 실행합니다.

물론, 기술적으로는 충분한 프로그래밍 경험이 있으면 처음부터 직접 이와 같은 것을 만들 수 있습니다... 하지만 이것이 *훨씬* 더 쉽습니다. 설정하면 다음과 같이 보입니다([OliveTin 저장소](https://github.com/OliveTin/OliveTin)의 이미지 제공).

![데스크탑의 OliveTin 스크린샷 실행할 수 있는 각 명령에 대한 레이블과 작업이 있는 그리드에 여러 사각형이 있습니다.](olivetin/screenshotDesktop.png)

!!! 경고 "공용 서버에서 이 앱을 실행하지 마십시오"

    이 앱은 설계 및 제작자 자신의 승인에 따라 로컬 네트워크, *어쩌면* 개발자 설정에서 사용하도록 되어 있습니다. 그러나 현재 사용자 인증 시스템이 없으며 (개발자가 이를 수정할 때까지) *기본적으로 루트로 실행됩니다*.
    
    보안 및 방화벽 네트워크에서 원하는 모든 것을 사용하십시오. 대중이 사용할 수 있는 어떤 것에도 *붙이지 마십시오*. 현재로는요.

## 전제 조건 및 가정

이 가이드를 따르려면 다음이 필요합니다.

* Rocky Linux를 실행하는 컴퓨터.
* 명령줄에 대한 최소한의 편안함 또는 경험.
* Root 액세스 또는 `sudo` 사용 능력.
* YAML의 기초를 배웁니다. 어렵지 않습니다. 아래에서 요령을 얻을 수 있습니다.

## OliveTin 설치

OliveTin에는 사전 구축된 RPM이 포함되어 있습니다. 귀하의 아키텍처에 대한 최신 릴리스를 여기에서 다운로드하고 설치하십시오. 그래픽 데스크탑이 있는 워크스테이션에서 이 가이드를 따르는 경우 파일을 다운로드하고 선택한 파일 관리자에서 두 번 클릭하십시오.

이 앱을 서버에 설치하는 경우 업무용 컴퓨터에 다운로드하여 SSH/SCP/SFTP를 통해 업로드하거나 일부 사람들이 하지 말라고 하는 작업을 수행하고 `wget`으로 다운로드할 수 있습니다.

예:

```bash
wget https://github.com/OliveTin/OliveTin/releases/download/2022-04-07/OliveTin_2022-04-07_linux_amd64.rpm
```

그런 다음 (예를 들어 다시) 다음을 사용하여 앱을 설치합니다.

```bash
sudo rpm -i OliveTin_2022-04-07_linux_amd64.rpm
```

OliveTin은 일반 `systemd` 서비스로 실행할 수 있지만 아직 활성화하지는 마십시오. 먼저 구성 파일을 설정해야 합니다.

!!! 참고 사항

    몇 가지 테스트를 거친 후 동일한 설치 지침이 Rocky Linux LXD 컨테이너에서 제대로 작동한다는 것을 확인했습니다. Docker를 좋아하는 사람이라면 누구나 미리 빌드된 이미지를 사용할 수 있습니다.

## OliveTin 작업 구성

OliveTin은 bash가 할 수 있는 모든 것을 할 수 있습니다. 이를 사용하여 CLI 옵션으로 앱을 실행하고, bash 스크립트를 실행하고, 서비스를 다시 시작하는 등의 작업을 수행할 수 있습니다. 시작하려면 root/sudo를 사용하여 선택한 텍스트 편집기로 구성 파일을 엽니다.

```bash
sudo nano /etc/OliveTin/config.yaml
```

가장 기본적인 종류의 작업은 버튼입니다. 클릭하면 명령이 호스트 컴퓨터에서 실행됩니다. 다음과 같이 YAML 파일에서 정의할 수 있습니다.

```yaml
actions:
  - title: Restart Nginx
    shell: systemctl restart nginx
```

Unicode 이모티콘과 같이 모든 작업에 사용자 지정 아이콘을 추가할 수도 있습니다.

```yaml
actions:
  - title: Restart Nginx
    icon: "&#1F504"
    shell: systemctl restart nginx
```

사용자 지정 옵션에 대해 자세히 설명하지는 않겠지만 텍스트 입력과 드롭다운 메뉴를 사용하여 실행하려는 명령에 변수와 옵션을 추가할 수도 있습니다. 그렇게 하면 명령이 실행되기 전에 OliveTin이 입력하라는 메시지를 표시합니다.

이렇게 하면 모든 프로그램을 실행하고, SSH로 원격 시스템을 제어하고, 웹후크를 트리거하는 등의 작업을 수행할 수 있습니다. 자세한 내용은 [공식 문서](https://docs.olivetin.app/actions.html)를 확인하세요.

그러나 여기에 내 자신의 예가 있습니다. 웹 서버가 미리 설치된 LXD 컨테이너를 생성하는 데 사용하는 개인 스크립트가 있습니다. OliveTin을 사용하여 다음과 같이 해당 스크립트에 대한 GUI를 빠르게 만들 수 있었습니다.

```yaml
actions:
- title: Build Container
  shell: sh /home/ezequiel/server-scripts/rocky-host/buildcontainer -c {{ containerName }} -d {{ domainName }} {{ softwarePackage }}
  timeout: 60
  arguments:
    - name: containerName
      title: Container Name
      type: ascii_identifier

    - name: domainName
      title: Domain
      type: ascii_identifier

    - name: softwarePackage
      title: Default Software
      choices:
        - title: None
          value:

        - title: Nginx
          value: -s nginx

        - title: Nginx & PHP
          value: -s nginx-php

        - title: mariadb
          value: -s mariadb
```

프런트엔드는 다음과 같습니다(예, OliveTin에는 어두운 모드가 있으며 *실제로* 해당 아이콘을 변경해야 합니다).

![세 개의 텍스트 입력과 드롭다운 메뉴가 있는 양식](olivetin/containeraction.png)

## OliveTin 활성화

구성 파일을 원하는 방식으로 구축했으면 다음을 사용하여 OliveTin을 활성화하고 시작하십시오.

```bash
sudo systemctl enable --now OliveTin
```

구성 파일을 편집할 때마다 일반적인 방법으로 서비스를 다시 시작해야 합니다.

```bash
sudo systemctl restart OliveTin
```

## 결론

OliveTin은 bash 명령에서 스크립트를 사용하는 상당히 복잡한 작업에 이르기까지 모든 것을 실행할 수 있는 매우 좋은 방법입니다. 셸 명령에서 su/sudo를 사용하여 해당 특정 명령에 대한 사용자를 변경하지 않는 한 모든 것이 기본적으로 루트로 실행된다는 점을 기억하십시오.

따라서 이 모든 것을 설정하는 방법에 주의해야 합니다. 특히 가족에게 액세스 권한을 부여하고 홈 서버 및 가전 제품 등을 제어하려는 경우 더욱 그렇습니다.

다시 말하지만 페이지를 직접 보호할 준비가 되지 않은 경우 공개 서버에 이것을 두지 마십시오.

그렇지 않으면 재미있게 즐기십시오. 깔끔한 작은 도구입니다.
