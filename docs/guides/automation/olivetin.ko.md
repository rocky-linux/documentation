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

같은 CLI 명령을 반복해서 입력하는 것에 지쳐 보셨나요? 집에 있는 다른 사람들도 당신의 개입 없이 Plex 서버를 재시작할 수 있기를 원하셨나요? 웹 패널에서 이름을 입력하고 버튼을 누르기만 하면 맞춤형 Docker/LXD 컨테이너가 마법처럼 생성되는 것을 원하셨나요?

그렇다면 OliveTin을 살펴보는 것이 좋을 수 있습니다. OliveTin은 구성 파일에서 웹 페이지를 생성하고, 그 웹 페이지에 버튼이 있는 앱입니다. 버튼을 누르면 OliveTin이 미리 설정한 bash 명령을 실행합니다.

이론적으로 충분한 프로그래밍 경험이 있다면 처음부터 직접 이와 같은 것을 만들 수도 있습니다. 하지만 이것은 *훨씬* 더 쉽습니다. 아래의 이미지는 ([OliveTin 저장소](https://github.com/OliveTin/OliveTin))에서 가져온 것으로, 설정한 경우 이와 같이 보일 것입니다:

![OliveTin 데스크톱 스크린샷; 레이블과 각 명령에 대한 작업이 있는 격자 형태의 여러 사각형이 표시됩니다.](olivetin/screenshotDesktop.png)

!!! 경고 "공용 서버에서 이 앱을 실행하지 마십시오"

    이 앱은 설계 및 제작자 자신의 승인에 따라 로컬 네트워크, *어쩌면* 개발자 설정에서 사용하도록 되어 있습니다. 그러나 현재 사용자 인증 시스템이 없으며 (개발자가 수정하기 전까지) <em x-id="3">기본적으로 root로 실행됩니다.</em>
    
    그래서 네트워크 보안과 방화벽이 설정된 네트워크에서 마음껏 사용하세요. 공개적으로 사용되는 환경에는 *사용하지 마세요*. 현재로서는 그렇습니다.

## 전제 조건 및 가정

이 가이드를 따르려면 다음이 필요합니다.

* Rocky Linux가 설치된 컴퓨터.
* 명령줄에 대한 최소한의 편안함 또는 경험.
* Root 액세스 또는 `sudo` 사용 능력.
* YAML의 기본을 배우려는 의지. 어렵지 않으며, 아래에서 익힐 수 있습니다.

## OliveTin 설치

OliveTin에는 미리 빌드된 RPM이 포함되어 있습니다. 아키텍처에 맞는 최신 릴리스를 여기에서 다운로드하여 설치하면 됩니다. 그래픽 데스크톱을 가진 작업용 컴퓨터에서 이 가이드를 따르고 있다면 파일을 다운로드한 후에 선호하는 파일 관리자에서 더블 클릭하여 설치하면 됩니다.

서버에 이 앱을 설치하는 경우, 작업용 컴퓨터에서 다운로드한 후 SSH/SCP/SFTP를 통해 업로드하거나, 어떤 사람들이 하지 말라고 말하는 방법으로 `wget`을 사용하여 다운로드할 수 있습니다.

예:

```bash
wget https://github.com/OliveTin/OliveTin/releases/download/2022-04-07/OliveTin_2022-04-07_linux_amd64.rpm
```

그런 다음 다음과 같이 앱을 설치하세요 (다시 말하지만 예시입니다):

```bash
sudo rpm -i OliveTin_2022-04-07_linux_amd64.rpm
```

OliveTin은 일반적인 `systemd` 서비스로 실행할 수 있지만, 아직 활성화하지 마세요. 먼저 설정 파일을 설정해야 합니다.

!!! 참고 사항

    테스트 후에 Rocky Linux LXD 컨테이너에서도 동일한 설치 지침이 잘 작동하는 것으로 판단되었습니다. Docker를 좋아하는 경우, 미리 빌드된 이미지를 사용할 수 있습니다.

## OliveTin 작업 구성

OliveTin은 bash가 할 수 있는 모든 작업과 더 많은 작업을 수행할 수 있습니다. CLI 옵션으로 앱 실행, bash 스크립트 실행, 서비스 재시작 등이 가능합니다. 시작하려면 다음과 같이 루트 또는 sudo 권한으로 설정 파일을 텍스트 편집기로 엽니다:

```bash
sudo nano /etc/OliveTin/config.yaml
```

가장 기본적인 작업 유형은 버튼입니다. 버튼을 클릭하면 명령이 호스트 컴퓨터에서 실행됩니다. 다음과 같이 YAML 파일에 정의할 수 있습니다:

```yaml
actions:
  - title: Restart Nginx
    shell: systemctl restart nginx
```

각 작업에 사용자 정의 아이콘을 추가할 수도 있습니다. 이는 유니코드 이모지로 가능합니다:

```yaml
actions:
  - title: Restart Nginx
    icon: "&#1F504"
    shell: systemctl restart nginx
```

모든 사용자 지정 옵션에 대해 자세히 설명하지는 않겠지만, 입력 텍스트와 드롭다운 메뉴를 사용하여 실행할 명령에 변수와 옵션을 추가할 수도 있습니다. 이렇게 하면 명령을 실행하기 전에 OliveTin이 입력을 요청할 것입니다.

이를 통해 프로그램을 실행하거나 SSH를 사용하여 원격 기기를 제어하거나 웹훅을 트리거하는 등의 작업을 수행할 수 있습니다. 더 많은 아이디어를 위해 [공식 문서](https://docs.olivetin.app/actions.html)를 참조하세요.

여기에 제 개인적인 예시가 있습니다. 웹 서버가 미리 설치된 LXD 컨테이너를 생성하는 개인 스크립트가 있습니다. OliveTin을 사용하여 다음과 같은 GUI를 빠르게 만들었습니다:

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

원하는 대로 설정 파일을 작성한 후에는 다음 명령으로 OliveTin을 활성화하고 시작하면 됩니다:

```bash
sudo systemctl enable --now OliveTin
```

구성 파일을 편집할 때마다 일반적인 방법으로 서비스를 재시작해야 합니다:

```bash
sudo systemctl restart OliveTin
```

## 결론

OliveTin은 bash 명령부터 상당히 복잡한 스크립트 작업까지 모두 실행하는 좋은 도구입니다. 기본적으로 모든 작업은 root로 실행되며, 특정 명령에서 사용자를 변경하기 위해 셸 명령에서 su/sudo를 사용할 수 있습니다.

따라서 환경 설정에 주의해야 하며, 가정용 서버 및 가전 제품을 제어하기 위해 (예: 가족에게) 액세스 권한을 부여할 계획인 경우 특히 조심해야 합니다.

또한, 페이지를 보안해야 할 준비가 되지 않았다면 공개 서버에 이를 배치하지 마세요.

그 외에는 즐겁게 사용하세요. 이것은 멋진 작은 도구입니다.
