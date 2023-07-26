---
title: '''iptables'' 방화벽 활성화'
author: Steven Spencer
contributors: Ezequiel Bruni
tested_with: 8.5, 8.6, 9.0
tags:
  - security
  - iptables
  - deprecated
---

# iptables 방화벽 활성화

## 전제조건

* 기본 _firewalld_ 애플리케이션을 비활성화하고 _iptables_를 활성화하려는 불타고 꺼지지 않는 의지.

!!! "이 프로세스는 더 이상 사용되지 않습니다" 경고

    Rocky Linux 9.0부터 `iptables` 및 관련 유틸리티 전체가 폐기되었습니다. 이는 향후 OS 버전에서 `iptables`가 제거될 예정이라는 의미입니다. 이러한 이유로 이 프로세스를 사용하지 않는 것이 권장됩니다. `iptables`에 익숙하시면 [`iptables` Guide To `firewalld`](firewalld.md)를 사용하는 것을 권장합니다. 방화벽 개념이 처음이라면 [초보자를 위한 `firewalld`](firewalld-beginners.md)를 권장합니다.

## 소개

현재 Rocky Linux에서는 _firewalld_가 기본 방화벽으로 사용됩니다. _firewalld_는 CentOS 7/RHEL 7에서 규칙을 플러시하지 않고 변경 사항을 로드하는 XML 파일을 사용하여 _iptables_의 동적인 응용 프로그램에 불과했습니다.  CentOS 8/RHEL 8/Rocky 8에서는 _firewalld_가 nftables을 감싼 것입니다. 그럼에도 불구하고, 직접 _iptables_를 설치하고 사용하는 것이 선호하는 경우에는 여전히 가능합니다. _firewalld_ 없이 직접 _iptables_를 설치하고 실행하려면 이 가이드를 따를 수 있습니다. 이 가이드에서 **알려주지 않을 것**은 _iptables_ 규칙을 작성하는 방법입니다. _firewalld_를 제거하고 싶다면 이미 _iptables_ 규칙을 작성하는 방법을 알고 있어야 한다고 가정합니다.

## firewalld 비활성화

기존의 _iptables_ 유틸리티를 _firewalld_와 함께 실행할 수는 없습니다. 그들은 단순히 호환되지 않습니다. 이 문제를 해결하는 가장 좋은 방법은 _firewalld_를 완전히 비활성화하고 (삭제하고 싶지 않다면 삭제할 필요가 없습니다), _iptables_ 유틸리티를 다시 설치하는 것입니다. _firewalld_를 비활성화하려면 다음과 같이 명령을 실행합니다:

_firewalld_ 중지:

`systemctl stop firewalld`

부팅 시 _firewalld_를 시작하지 않도록 비활성화:

`systemctl disable firewalld`

서비스가 찾을 수 없도록 마스크 처리:

`systemctl mask firewalld`

## iptables 서비스 설치 및 활성화

다음으로, 예전 _iptables_ 서비스 및 유틸리티를 설치해야 합니다. 다음 명령으로 수행할 수 있습니다:

`dnf install iptables-services iptables-utils`

이렇게 하면 직접 _iptables_ 규칙 집합을 실행하는 데 필요한 모든 것이 설치됩니다.

이제 _iptables_ 서비스를 부팅 시 시작하도록 활성화해야 합니다:

`systemctl enable iptables`

## 결론

_firewalld_ 대신 선호하는 경우 직접 _iptables_를 사용할 수 있습니다. 이러한 변경 사항을 간단히 반대로하면 기본 _firewalld_를 사용할 수 있습니다.
