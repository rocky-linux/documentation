---
title: Rocky Linux 8의 DISA STIG - 파트 1
author: Scott Shinn
contributors: Steven Spencer
tested_with: 8.6
tags:
  - DISA
  - STIG
  - 보안
  - 기업
---

# HOWTO: STIG Rocky Linux 8 Fast - 파트 1

## 용어 참조

* DISA - 국방 정보 시스템 기관
* RHEL8 - Red Hat Enterprise Linux 8
* STIG - 보안 기술 구현 가이드
* SCAP - 보안 콘텐츠 자동화 프로토콜
* DoD - 국방부

## 소개

이 문서에서는 Rocky Linux 8의 새 설치에 [RHEL8용 DISA STIG](https://www.stigviewer.com/stig/red_hat_enterprise_linux_8/)를 적용하는 방법을 다룰 것입니다. 여러 부분으로 구성된 시리즈로서 STIG 준수를 테스트하는 방법, STIG 설정을 적용하는 방법, 이 환경에서 다른 STIG 콘텐츠를 적용하는 방법도 다룰 예정입니다.

Rocky Linux는 RHEL 8의 버그 수정 버전으로, 따라서 DISA RHEL8 STIG에 대한 게시된 콘텐츠는 두 운영 체제 모두에 대해 동일합니다.  더 좋은 소식은 STIG 설정을 적용하는 것이 Rocky Linux 8의 anaconda 설치 프로그램에 내장되어 있다는 것입니다.  내부적으로는 모두 [OpenSCAP](https://www.open-scap.org/)라는 도구로 구동되며, 이 도구를 사용하면 DISA STIG와의 규정 준수를 구성할 수 있을뿐만 아니라 설치 후 시스템의 규정 준수를 테스트할 수도 있습니다.

저는 가상 환경에서 가상 머신에서 이 작업을 수행할 것이지만, 여기에 나와 있는 모든 내용은 실제 시스템에서도 동일하게 적용됩니다.

### 1단계: 가상 머신 생성

* 2G 메모리
* 30G 디스크
* 1 코어

![가상 머신](images/disa_stig_pt1_img1.jpg)

### 2단계: Rocky Linux 8 DVD ISO 다운로드

[Rocky Linux DVD 다운로드](https://download.rockylinux.org/pub/rocky/8/isos/x86_64/Rocky-8.6-x86_64-dvd1.iso).  **참고:** 최소 ISO에는 Rocky Linux 8의 STIG 적용에 필요한 콘텐츠가 포함되어 있지 않으므로 DVD나 네트워크 설치를 사용해야 합니다.

![Rocky Linux 다운로드](images/disa_stig_pt1_img2.jpg)

### 3단계: 설치 프로그램 부팅

![설치 프로그램 부팅](images/disa_stig_pt1_img3.jpg)

### 4단계: 파티션 설정 먼저 선택

이것은 설치에서 가장 복잡한 단계이자 STIG 준수를 위한 요구 사항입니다. 운영 체제의 파일 시스템을 파티션으로 나눠야 하는데, 아마도 새로운 문제가 발생할 수도 있습니다. 다시 말해, 저장소 요구 사항을 정확히 알아야 합니다.

!!! 팁 "전문가 팁"

    Linux에서는 파일 시스템의 크기를 조정할 수 있습니다. 이에 대해서는 다른 글에서 다룰 것입니다. 말하자면 이것이 맨땅에 STIG를 적용하는 데 큰 문제 중 하나이며, 종종 해결하기 위해 완전히 다시 설치해야 하는 경우가 많아서 여기에서 필요한 크기보다 크게 사양을 잡아야 한다는 것입니다.

![파티셔닝](images/disa_stig_pt1_img4.jpg)

* "Custom"을 선택한 다음 "Done"를 선택합니다.

![파티션 사용자 정의 설정](images/disa_stig_pt1_img5.jpg)

* 파티션 추가를 시작합니다.

![파티션 추가](images/disa_stig_pt1_img6.jpg)

30G 디스크에 대한 DISA STIG 파티션 구성 방식입니다. 사용 사례는 간단한 웹 서버로 다음과 같습니다:

* / (10G)
* /boot (500m)
* /var (10G)
* /var/log (4G)
* /var/log/audit (1G)
* /home (1G)
* /tmp (1G)
* /var/tmp (1G)
* Swap (2G)

!!! 팁 "전문가 팁"

     /를 마지막으로 구성하고 매우 큰 숫자를 부여하면 모든 여유 디스크 공간이 /에 할당되어 수학 계산을 수행하지 않아도 됩니다.

![슬래시 파티션](images/disa_stig_pt1_img7.jpg)

!!! 팁 "전문가 팁"

    이전 Pro-Tip에서 다시 설명: 파일 시스템을 OVER SPEC 설정하십시오. 나중에 다시 확장해야 할 수 있습니다.

* "Done" 및 "Accept Changes"을 클릭하십시오.

![파티셔닝 확인](images/disa_stig_pt1_img8.jpg)

![변경 사항 적용](images/disa_stig_pt1_img9.jpg)

### 5단계: 환경에 맞게 소프트웨어 구성: GUI 없이 서버 설치하기

이는 **6단계**에서 중요하므로 UI 또는 워크스테이션 구성을 사용하는 경우 보안 프로필이 다를 수 있습니다.

![소프트웨어 선택](images/disa_stig_pt1_img10.jpg)

### 6단계: 보안 프로필 선택

SCAP 프레임워크를 활용하여 선택한 정책을 기반으로 시스템에서 여러 보안 설정을 구성합니다. **5단계**에서 선택한 패키지를 수정하여 필요한 구성 요소를 추가하거나 제거합니다.  **5단계**에서 GUI 설치를 _선택_ 하고 이 단계에서 GUI가 없는 STIG를 사용하는 경우 GUI가 제거될 것입니다. 그에 따라 조정하십시오!

![보안 프로필](images/disa_stig_pt1_img11.jpg)

Red Hat Enterprise Linux 8용 DISA STIG를 선택하세요.

![DISA STIG](images/disa_stig_pt1_img12.jpg)

"Select Profile"을 클릭하고 시스템에 적용할 변경 사항을 확인합니다. 이는 마운트 포인트에 대한 옵션을 설정하고, 응용 프로그램을 추가 또는 제거하며, 기타 구성 변경 사항을 수행할 것입니다.

![프로필_A 선택](images/disa_stig_pt1_img13.jpg)

![프로필_B 선택](images/disa_stig_pt1_img14.jpg)

### 7단계: "Done"를 클릭하고 최종 설정을 계속합니다.

![프로필 완료](images/disa_stig_pt1_img15.jpg)

### 8단계: 사용자 계정 생성 및 해당 사용자를 관리자로 설정

나중의 튜토리얼에서는 이것을 FreeIPA 엔터프라이즈 구성에 연결하는 방법에 대해 알아볼 수 있습니다 현재는 독립 실행형으로 처리합니다. 루트 비밀번호를 설정하지 않고 기본 사용자에게 `sudo` 액세스 권한을 부여합니다.

![사용자 설정](images/disa_stig_pt1_img16.jpg)

### 9단계: "Done"를 클릭한 다음 "Begin Installation"을 클릭합니다.

![설치 시작](images/disa_stig_pt1_img17.jpg)

### 10단계: 설치가 완료되면 "Reboot System"을 클릭합니다.

![재부팅](images/disa_stig_pt1_img18.jpg)

### 11단계: STIG'd Rocky Linux 8 시스템에 로그인합니다!

![DoD 경고](images/disa_stig_pt1_img19.jpg)

모든 것이 잘 진행되었다면, 여기에 기본 DoD 경고 배너가 표시됩니다.

![최종 화면](images/disa_stig_pt1_img20.jpg)

## 저자 소개

Scott Shinn은 Atomomicorp의 CTO이자 Rocky Linux Security 팀의 일원입니다. 그는 1995년부터 백악관, 국방부 및 정보 커뮤니티에서 연방 정보 시스템에 참여했습니다. 그 중 일부는 STIG를 생성하고 사용해야 하는 요구사항이었는데, 이에 대해 매우 유감스럽게 생각합니다.
