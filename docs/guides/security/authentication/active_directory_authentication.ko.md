---
author: Hayden Young
contributors: Steven Spencer, Sambhav Saggi, Antoine Le Morvan, Krista Burdine
---

# 액티브 디렉토리 인증

## 필요사항

- Active Directory에 대한 이해
- LDAP에 대한 이해

## 소개

Microsoft의 Active Directory (AD)는 대부분의 기업에서 Windows 시스템과 외부 LDAP 연결 서비스의 사실상의 인증 시스템입니다. 사용자 및 그룹, 접근 제어, 권한, 자동 마운트 등을 구성할 수 있습니다.

이제 Linux를 AD 클러스터에 연결하더라도 언급된 모든 기능을 지원할 수는 없지만 사용자, 그룹 및 접근 제어를 처리할 수 있습니다. 또한 Linux 쪽에서 구성을 조정하고 AD 쪽에서 일부 고급 옵션을 사용하여 SSH 키를 AD를 통해 배포하는 것도 가능합니다.

그러나 이 가이드는 Active Directory 인증을 구성하는 것만 다루며 Windows 쪽에서 추가 구성은 포함되지 않습니다.

## SSSD를 사용하여 AD 검색 및 가입

!!! Note "참고 사항"

    이 가이드 전체에서 도메인 이름으로 `ad.company.local`이라는 Active Directory 도메인을 나타내는 데 사용됩니다. 이 가이드를 따를 때 실제 AD 도메인이 사용하는 실제 도메인 이름으로 대체하십시오.

Linux 시스템을 AD에 가입하기 위해 첫 번째 단계는 AD 클러스터를 검색하여 양쪽 모두에서 네트워크 구성이 올바른지 확인하는 것입니다.

### 준비

- Linux 호스트의 도메인 컨트롤러에서 Linux 호스트로 다음 포트가 열려 있는지 확인하세요.

  | Service  | Port(s)           | Notes                                    |
  | -------- | ----------------- | ---------------------------------------- |
  | DNS      | 53 (TCP+UDP)      |                                          |
  | Kerberos | 88, 464 (TCP+UDP) | 비밀번호 설정 & 업데이트를 위해 `kadmin`에서 사용         |
  | LDAP     | 389 (TCP+UDP)     |                                          |
  | LDAP-GC  | 3268 (TCP)        | LDAP 글로벌 카탈로그 - AD에서 사용자 ID를 소싱할 수 있습니다. |

- Rocky Linux 호스트에서 AD 도메인 컨트롤러를 DNS 서버로 구성했는지 확인합니다.

  **NetworkManager 사용 시:**
  ```sh
  # 여기서 기본 NetworkManager 연결은 'System eth0'이고 AD입니다. # 서버는 IP 주소 10.0.0.2에서 액세스할 수 있습니다.
  [root@host ~]$ nmcli con mod 'System eth0' ipv4.dns 10.0.0.2
  ```

- 양쪽(AD 호스트 및 Linux 시스템)의 시간이 동기화되었는지 확인합니다(chronyd 참조).

  **Rocky Linux에서 시간을 확인하려면:**
  ```sh
  [user@host ~]$ date
  Wed 22 Sep 17:11:35 BST 2021
  ```

- Linux 측에서 AD 연결에 필요한 패키지를 설치합니다.

  ```sh
  [user@host ~]$ sudo dnf install realmd oddjob oddjob-mkhomedir sssd adcli krb5-workstation
  ```


### 탐색

이제 Linux 호스트에서 AD 서버를 성공적으로 검색할 수 있어야 합니다.

```sh
[user@host ~]$ realm discover ad.company.local
ad.company.local
  type: kerberos
  realm-name: AD.COMPANY.LOCAL
  domain-name: ad.company.local
  configured: no
  server-software: active-directory
  client-software: sssd
  required-package: oddjob
  required-package: oddjob-mkhomedir
  required-package: sssd
  required-package: adcli
  required-package: samba-common
```

이는 Active Directory DNS 서비스에 저장된 관련 SRV 레코드를 사용하여 검색됩니다.

### 가입

Linux 호스트에서 Active Directory 설치를 성공적으로 검색한 후 `realmd`를 사용하여 도메인에 가입할 수 있으며, 이는 `adcli` 및 기타 도구를 사용하여 `sssd`의 구성을 조정할 것입니다.

```sh
[user@host ~]$ sudo realm join ad.company.local
```

이 과정에서 `KDC has no support for encryption type`는 오류가 발생하면, 이전 암호화 알고리즘을 허용하도록 전역 암호화 정책을 업데이트해 보십시오.

```sh
[user@host ~]$ sudo update-crypto-policies --set DEFAULT:AD-SUPPORT
```

이 과정이 성공하면 Active Directory 사용자의 `passwd` 정보를 가져올 수 있어야 합니다.

```sh
[user@host ~]$ sudo getent passwd administrator@ad.company.local
administrator@ad.company.local:*:1450400500:1450400513:Administrator:/home/administrator@ad.company.local:/bin/bash
```

!!! Note "참고 사항" 

    `getent`는 이름 서비스 스위치 라이브러리(NSS)에서 항목을 가져옵니다. 즉, <code>passwd 또는 dig와는 달리 getent hosts 또는 getent passwd 경우와 같이 /etc/hosts 또는 sssd에서 다른 데이터베이스를 쿼리합니다.
    </code>

`realm`은 사용할 수 있는 몇 가지 흥미로운 옵션이 있습니다:

| 옵션                                                         | 관찰               |
| ---------------------------------------------------------- | ---------------- |
| --computer-ou='OU=LINUX,OU=SERVERS,dc=ad,dc=company.local' | 서버 계정을 저장할 OU    |
| --os-name='rocky'                                          | AD에 저장된 OS 이름 지정 |
| --os-version='8'                                           | AD에 저장된 OS 버전 지정 |
| -U admin_username                                          | 관리자 계정 지정        |

### 인증 시도 중

이제 사용자들은 Linux 호스트에서 Active Directory로 인증할 수 있어야 합니다.

**Windows 10:**(자체 OpenSSH 사본 제공)

```
C:\Users\John.Doe> ssh -l john.doe@ad.company.local linux.host
Password for john.doe@ad.company.local:

Activate the web console with: systemctl enable --now cockpit.socket

Last login: Wed Sep 15 17:37:03 2021 from 10.0.10.241
[john.doe@ad.company.local@host ~]$
```

이 과정이 성공하면 Linux를 Active Directory를 인증 소스로 사용하도록 성공적으로 구성한 것입니다.

### 기본 도메인 설정

완전히 기본 설정으로는 사용자명에 도메인을 지정하여 AD 계정으로 로그인해야 합니다 (예: `john.doe@ad.company.local`). 이러한 동작이 원하지 않는 경우 인증 시간에 도메인 이름을 생략할 수 있도록 SSSD를 특정 도메인으로 기본 설정할 수 있습니다.

이것은 실제로 비교적 간단한 프로세스이며, SSSD 구성 파일에서 구성을 변경하는 것만 필요합니다.

```sh
[user@host ~]$ sudo vi /etc/sssd/sssd.conf
[sssd]
...
default_domain_suffix = ad.company.local
```

`default_domain_suffix`를 추가함으로써 다른 도메인이 지정되지 않으면 사용자가 `ad.company.local` 도메인의 사용자로 인증하려는 것으로 추론하도록 SSSD에 지시합니다. 이렇게 하면 `john.doe@ad.company.local` 대신 `john.doe`와 같은 방식으로 인증할 수 있습니다.

이 구성 변경을 적용하려면 `systemctl`을 사용하여 `sssd.service` unit를 다시 시작해야 합니다.

```sh
[user@host ~]$ sudo systemctl restart sssd
```

마찬가지로 홈 디렉터리가 도메인 이름으로 끝나는 것을 원치 않는 경우 이러한 옵션을 `/etc/sssd/sssd.conf` 구성 파일에 추가할 수 있습니다.

```
[domain/ad.company.local]
use_fully_qualified_names = False
override_homedir = /home/%u
```

`sssd` 서비스를 다시 시작하는 것을 잊지 마십시오.

### 특정 사용자로 제한

서버의 액세스를 제한하는 다양한 방법이 있지만 이름에서 알 수 있듯이 이것은 확실히 가장 간단한 방법입니다:

해당 옵션을 `/etc/sssd/sssd.conf` 구성 파일에 추가하고 서비스를 다시 시작하세요.

```
access_provider = simple
simple_allow_groups = group1, group2
simple_allow_users = user1, user2
```

이제 sssd를 사용하여 group1 및 group2, 또는 user1 및 user2의 사용자만 서버에 연결할 수 있습니다!

## `adcli`를 사용하여 AD와 상호작용

`adcli`는 Active Directory 도메인에서 작업을 수행하는 CLI 도구입니다.

- 아직 설치되지 않았다면 필요한 패키지를 설치하세요:

```sh
[user@host ~]$ sudo dnf install adcli
```

- Active Directory 도메인에 가입한 적이 있는지 테스트하세요:

```sh
[user@host ~]$ sudo adcli testjoin
Successfully validated join to domain ad.company.local
```

- 도메인에 대한 고급 정보 얻기:

```sh
[user@host ~]$ adcli info ad.company.local
[domain]
domain-name = ad.company.local
domain-short = AD
domain-forest = ad.company.local
domain-controller = dc1.ad.company.local
domain-controller-site = site1
domain-controller-flags = gc ldap ds kdc timeserv closest writable full-secret ads-web
domain-controller-usable = yes
domain-controllers = dc1.ad.company.local dc2.ad.company.local
[computer]
computer-site = site1
```

- 자문 도구보다 더 많은 기능을 제공하므로 adcli를 사용하여 도메인을 상호작용할 수 있습니다. 사용자 또는 그룹 관리, 암호 변경 등을 수행할 수 있습니다.

예: 'adcli'를 사용하여 컴퓨터 정보 가져오기:

!!! 참고 사항

    이번에는 `-U` 옵션을 사용하여 관리자 사용자명을 제공합니다.

```sh
[user@host ~]$ adcli show-computer pctest -U admin_username
Password for admin_username@AD: 
sAMAccountName:
 pctest$
userPrincipalName:
 - not set -
msDS-KeyVersionNumber:
 9
msDS-supportedEncryptionTypes:
 24
dNSHostName:
 pctest.ad.company.local
servicePrincipalName:
 RestrictedKrbHost/pctest.ad.company.local
 RestrictedKrbHost/pctest
 host/pctest.ad.company.local
 host/pctest
operatingSystem:
 Rocky
operatingSystemVersion:
 8
operatingSystemServicePack:
 - not set -
pwdLastSet:
 133189248188488832
userAccountControl:
 69632
description:
 - not set -
```

예: `adcli`를 사용하여 사용자 비밀번호 변경하기:

```sh
[user@host ~]$ adcli passwd-user user_test -U admin_username
Password for admin_username@AD: 
Password for user_test: 
[user@host ~]$ 
```

## 문제 해결

때때로 네트워크 서비스가 SSSD보다 늦게 시작되어 인증에 문제가 발생할 수 있습니다.

SSSD를 다시 시작하기 전까지는 AD 사용자가 연결할 수 없습니다.

이 경우에는 systemd의 서비스 파일을 재정의하여 이 문제를 해결해야 합니다.

다음 내용을 `/etc/systemd/system/sssd.service`에 복사합니다.

```
[Unit]
Description=System Security Services Daemon
# SSSD must be running before we permit user sessions
Before=systemd-user-sessions.service nss-user-lookup.target
Wants=nss-user-lookup.target
After=network-online.target


[Service]
Environment=DEBUG_LOGGER=--logger=files
EnvironmentFile=-/etc/sysconfig/sssd
ExecStart=/usr/sbin/sssd -i ${DEBUG_LOGGER}
Type=notify
NotifyAccess=main
PIDFile=/var/run/sssd.pid

[Install]
WantedBy=multi-user.target
```

다음 재부팅에서 서비스는 요구 사항 이후에 시작되며 모든 것이 정상적으로 진행될 것입니다.

## Active Directory에서 나가기

가끔 AD를 떠나야 할 필요가 있습니다.

다이 경우 `realm`으로 진행하고 더 이상 필요하지 않은 패키지를 제거할 수 있습니다:

```sh
[user@host ~]$ sudo realm leave ad.company.local
[user@host ~]$ sudo dnf remove realmd oddjob oddjob-mkhomedir sssd adcli krb5-workstation
```
