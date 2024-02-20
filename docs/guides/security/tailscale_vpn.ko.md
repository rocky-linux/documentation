---
title: Tailscale VPN
author: Neel Chauhan
contributors: null
tested_with: 9.3
tags:
  - security
---

# Tailscale VPN

## 소개

[Tailscale](https://tailscale.com/)은 Wireguard를 기반으로 한 영구적으로 구성되지 않고, end-to-end로 암호화된, peer-to-peer VPN입니다. Tailscale은 모든 주요 데스크톱 및 모바일 운영 체제를 지원합니다.

다른 VPN 솔루션과 비교할 때, Tailscale은 개방된 TCP/IP 포트를 필요로하지 않으며, 네트워크 주소 변환(NAT) 또는 방화벽 뒤에서 작동할 수 있습니다.

## 전제 조건 및 가정

이 프로시저를 사용하기 위해 다음이 최소 요구 사항입니다:

- 루트 사용자로 명령을 실행하거나 권한을 상승시키기 위해 `sudo`를 사용할 수 있는 능력
- Tailscale 계정

## Tailscale 설치

Tailscale을 설치하려면 먼저 `dnf` 저장소를 추가해야 합니다 (참고: 만약 Rocky Linux 8.x를 사용 중이라면, 8로 대체하세요):

```bash
dnf config-manager --add-repo https://pkgs.tailscale.com/stable/rhel/9/tailscale.repo
```

그런 다음 Tailscale을 설치합니다:

```bash
dnf install tailscale
```

## Tailscale 구성

패키지가 설치되었으면 Tailscale을 활성화하고 구성해야 합니다. Tailscale 데몬을 활성화하려면:

```bash
systemctl enable --now tailscaled
```

그런 다음 Tailscale 인증을 수행합니다:

```bash
tailscale up
```

인증용 URL을 받게 됩니다. 브라우저에서 해당 Url을 방문하고 Tailscale에 로그인합니다.

![Tailscale login screen](../images/tailscale_1.png)

그런 다음 서버에 액세스 권한을 부여합니다. 액세스를 부여하려면 **연결**을 클릭하세요.

![Tailscale grant access dialog](../images/tailscale_2.png)

액세스를 부여한 후에는 성공 대화상자가 표시됩니다.

![Tailscale login successful dialog](../images/tailscale_3.png)

서버가 Tailscale로 인증되면 Tailscale IPv4 주소를 받게 됩니다.

```bash
tailscale ip -4
```

또한 RFC 4193 (고유 로컬 주소) Tailscale IPv6 주소를 받게 됩니다.

```bash
tailscale ip -6
```

## 결론

전통적으로 VPN 서비스는 VPN 게이트웨이가 중앙 집중식으로 운영되는 클라이언트-서버 모델에서 운영되었습니다. 이는 수동 구성, 방화벽 구성 및 사용자 계정 부여를 필요로 했습니다. Tailscale은 네트워크 수준의 액세스 제어와 결합된 P2P 모델로 이 문제를 해결합니다.
