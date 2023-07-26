---
title: Apache 보안 강화 웹서버
author: Steven Spencer
contributors: Ezequiel Bruni
tested_with: 8.8, 9.2
tags:
  - apache
  - web
  - security
---

# Apache 보안 강화 웹서버

## 전제 조건 및 가정

* Rocky Linux에서 실행 중인 Apache 웹 서버
* 명령줄에서 명령을 실행하고 로그를 읽고 일반적인 시스템 관리 작업을 수행하는 데 편안함
* 명령줄 에디터에 익숙함 (예제는 일반적으로 `vim` 편집기를 호출하는`vi`를 사용하지만 선호하는 편집기로 대체할 수 있음)
* `firewalld`나 하드웨어 방화벽 대신 iptables 방화벽 사용을 가정함
* 신뢰된 장치가 있는 게이트웨이 하드웨어 방화벽 사용을 가정함
* 웹 서버에 직접 할당된 공인 IP 주소를 전제함. 우리는 모든 예제를 사설 IP 주소로 대체하고 있습니다.

## 소개

고객을 위해 많은 웹 사이트를 호스팅하거나 비즈니스를 위한 중요한 하나의 웹 사이트를 호스팅하는 경우, 웹 서버를 강화하면 약간의 추가 작업이 발생하지만 관리자의 안심감을 얻을 수 있습니다.

고객이 업로드한 여러 웹사이트 중 하나는 취약점이 있는 콘텐츠 관리 시스템(CMS - Content Management System)을 업로드할 가능성이 높습니다. 대부분의 고객은 사용의 편의성에 초점을 맞추며 보안을 고려하지 않습니다. 그리고 고객의 CMS를 업데이트하는 것은 그들의 우선 순위 목록에서 완전히 빠지게 됩니다.


대규모 IT 스태프를 보유한 회사에서는 고객의 CMS 취약점을 고지하는 것이 가능할 수 있지만, 소규모 IT 팀에게는 현실적이지 않을 수 있습니다. 가장 좋은 방어 수단은 강화된 웹 서버입니다.

웹 서버 강화에는 여러 가지 방법이 있으며, 여기에 나열된 도구 중 일부 또는 모두를 사용할 수 있으며, 기타 정의되지 않은 도구도 사용할 수 있습니다.

몇 가지 도구를 선택하여 사용하거나 다른 도구를 선택할 수 있습니다. 이 문서에서는 각 도구에 대해 별도의 문서로 분리합니다. 예외는 패킷 기반 방화벽(`firewalld`) 인데, 이를 본 문서에서 설명합니다.

* 포트 기반의 우수한 패킷 필터 방화벽(iptables, firewalld 또는 하드웨어 방화벽 - 예제에서는 `firewalld` 사용) [`firewalld` procedure](#iptablesstart)
* 호스트 기반 침입 탐지 시스템(Host-based Intrusion Detection System - HIDS), 이 경우 _ossec-hids_ [Apache Hardened Web Server - ossec-hids](ossec-hids.md)
* 웹 기반 애플리케이션 방화벽(WAF), `mod_security` 규칙 [Apache Hardened Web Server - mod_security](modsecurity.md)
* Rootkit Hunter(`rkhunter`): Linux 맬웨어를 검사하는 검사 도구 [Apache Hardened Web Server - rkhunter](rkhunter.md)
* 데이터베이스 보안(여기서는 `mariadb-server`를 사용하고 있습니다) [MariaDB Database Server](../../database/database_mariadb-server.md)
* 보안 FTP 또는 SFTP 서버(여기서는 _vsftpd_ 사용) [Secure FTP Server - vsftpd](../../file_sharing/secure_ftp_server_vsftpd.md) 그러나 [여기에](../../file_sharing/sftp.md) _sftp_ 및 SSH 잠금 절차도 있습니다(../../file_sharing/sftp.md).

이 절차는 [Apache 웹 서버 다중 사이트 설정](../apache-sites-enabled.md)을 대체하지 않으며, 해당 보안 요소를 추가합니다. 이를 먼저 읽지 않았다면 진행하기 전에 시간을 내어 검토하십시오.

## 기타 고려 사항

여기에 설명된 도구 중 일부는 무료 및 유료 옵션이 있습니다. 필요 사항이나 지원 요구 사항에 따라 유료 버전을 고려하는 것이 좋습니다. 가능한 모든 옵션을 탐색하고 모든 옵션을 고려한 후 결정하는 것이 가장 좋은 방법입니다.

이러한 옵션 중 많은 옵션에 대해 하드웨어 장비를 구입하는 것도 가능합니다. 자체 시스템을 설치 및 유지 관리하는 번거로움을 피하고자 하는 경우 여기에 나열된 옵션 이외의 옵션이 있습니다.

이 문서는 `firewalld` 방화벽을 사용합니다. `firewalld` 가이드를 사용할 수 있습니다. 이 문서에서는 `iptables` 지식을 가진 사용자가 해당 내용을 `firewalld`로 전환하는 방법을 설명하는 문서를 [여기](../../security/firewalld.md)에서 찾을 수 있으며, 초보자를 위한 더 자세한 내용은 [여기](../../security/firewalld-beginners.md)에서 확인하실 수 있습니다.  시작하기 전에 이러한 절차 중 하나를 검토해 보시는 것이 좋습니다.

이러한 모든 도구를 시스템에 맞게 조정해야 합니다. 이를 위해서는 로그와 보고된 웹 환경을 고객이 주의 깊게 모니터링해야 합니다. 또한 지속적인 튜닝이 필요합니다.

이 예시는 공개 IP 주소를 시뮬레이션하기 위해 개인 IP 주소를 사용하지만, 하드웨어 방화벽에서 1:1 NAT를 사용하고 웹 서버를 해당 하드웨어 방화벽에 연결하여 게이트웨이 라우터가 아닌 개인 IP 주소로 설정할 수 있습니다.

표시된 하드웨어 방화벽을 자세히 살펴보아야 하며, 이 문서의 범위를 벗어납니다.

## 규칙

* **IP 주소:** 여기서 공개 IP 주소를 개인 블록(192.168.1.0/24)으로 시뮬레이션하고, LAN IP 주소 블록으로 10.0.0.0/24를 사용합니다. 이러한 IP 블록은 개인용이므로 인터넷을 통해 라우팅할 수 없지만, 일부 회사나 조직에 할당된 실제 IP 주소를 사용하지 않으면 공용 IP 블록을 시뮬레이션할 수 없습니다. 그러나 우리 목적에 따라 192.168.1.0/24 블록은 "공개" IP 블록이고 10.0.0.0/24는 "개인" IP 블록입니다.

* **하드웨어 방화벽:** 이것은 신뢰된 네트워크에서 서버 룸 장치에 대한 액세스를 제어하는 방화벽입니다. 이는 패킷 기반 방화벽과 동일하지 않지만, 다른 기계에서 실행되는 `firewalld`의 다른 인스턴스일 수 있습니다. 이 장치는 신뢰된 장치에 대해 ICMP(핑) 및 SSH(보안 셸)를 허용합니다. 이 장치의 정의는 이 문서의 범위를 벗어납니다. 저자는 [PfSense](https://www.pfsense.org/) 와 [OPNSense](https://opnsense.org/)를 사용하고 이 장치에 성공적으로 설치했습니다. 이 장치에는 두 개의 IP 주소가 할당됩니다. 하나는 인터넷 라우터의 시뮬레이션된 공개 IP(192.168.1.2)에 연결되고 다른 하나는 로컬 네트워크(10.0.0.1)에 연결됩니다.
* **인터넷 라우터 IP:**  이를 192.168.1.1/24로 시뮬레이션하고 있습니다.
* **웹 서버 IP:** 이는 웹 서버에 할당된 "공용" IP 주소입니다. 다시 말해서, 우리는 이를 개인 IP 주소인 192.168.1.10/24로 시뮬레이션하고 있습니다.

![Hardened web server](images/hardened_webserver_figure1.jpeg)

그림은 일반적인 레이아웃을 보여줍니다. `firewalld` 패킷 기반 방화벽은 웹 서버에서 실행됩니다.

## 패키지 설치

각 개별 패키지 섹션에는 필요한 설치 파일과 구성 절차가 나열되어 있습니다.

## <a name="iptablesstart"></a>`firewalld` 구성

```
firewall-cmd --zone=trusted --add-source=192.168.1.2 --permanent
firewall-cmd --zone=trusted --add-service=ssh --permanent
firewall-cmd --zone=public --remove-service=ssh --permanent
firewall-cmd --zone=public --add-service=dns --permanent
firewall-cmd --zone=public --add-service=http --add-service=https --permanent
firewall-cmd --zone=public --add-service=ftp --permanent
firewall-cmd --zone=public --add-port=20/tcp --permanent
firewall-cmd --zone=public --add-port=7000-7500/tcp --permanent
firewall-cmd --reload
```
다음은 수행되는 작업입니다:

* 신뢰된 존을 하드웨어 방화벽의 IP 주소로 설정합니다.
* 신뢰된 네트워크, 즉 하드웨어 방화벽 뒤의 장치들로부터 SSH(포트 22)를 허용합니다(단 하나의 IP 주소).
* 공용 존에서 DNS를 허용합니다(이를 더 제한할 수 있으며, 서버 IP 주소 또는 로컬 DNS 서버를 지정할 수 있습니다).
* 어디서든지 웹 트래픽을 포트 80과 443으로 허용합니다.
* 표준 FTP(포트 20-21)와 FTP의 양방향 통신을 위해 필요한 패시브 포트(7000-7500)를 허용합니다. 이 포트들은 FTP 서버 구성에 따라 임의로 다른 포트로 변경할 수 있습니다.

    !!! note "참고사항"
  
        현재는 SFTP를 사용하는 것이 가장 좋은 방법입니다. SFTP를 안전하게 사용하는 방법에 대해서는 이 [문서](../../file_sharing/sftp.md).에서 확인할 수 있습니다.

* 마지막으로 방화벽을 다시 로드합니다.

## 결론

웹 서버를 강화하여 더욱 안전하게 만드는 다양한 방법이 있습니다. 각각은 독립적으로 작동하며, 설치와 선택은 사용자에게 달려 있습니다.

각각은 특정 요구 사항을 충족하기 위해 일부 구성 및 튜닝이 필요합니다. 웹 서비스는 비도덕적인 사용자들에 의해 지속적으로 공격 받기 때문에, 이러한 방법들 중 적어도 일부를 적용하는 것이 관리자가 안심할 수 있도록 도와줄 것입니다.
