---
title: OpenSCAP로 DISA STIG 규정 준수 확인 - 파트 2
author: Scott Shinn
contributors: Steven Spencer
tested_with: 8.6
tags:
  - DISA
  - STIG
  - 보안
  - 기업
---

# 소개

이전 글에서는 [OpenSCAP](https://www.openscap.org)를 사용하여 DISA STIG가 적용된 새로운 Rocky Linux 8 시스템을 설정했습니다. 이제 동일한 도구를 사용하여 시스템을 테스트하고, 도구 oscap과 그 UI 버전인 SCAP Workbench를 사용하여 어떤 종류의 보고서를 생성할 수 있는지 알아보겠습니다.

Rocky Linux 8(및 9!)에는 다양한 표준을 기준으로 규정 준수를 테스트하고 복구하기 위한 [SCAP](https://csrc.nist.gov/projects/security-content-automation-protocol) 컨텐츠 모음이 포함되어 있습니다. 파트 1에서 STIG가 적용된 시스템을 구축했다면 이미 이를 확인했을 것입니다. 아나콘다 설치 프로그램은 이 콘텐츠를 활용하여 rocky 8 구성을 수정하여 다양한 제어 조치를 구현하고, 패키지를 설치/제거하며, 운영 체제 수준의 마운트 포인트 작업 방식을 변경합니다.

이러한 사항은 시간이 지나면서 변경될 수 있으므로 주의를 기울여야 합니다. 또한 이러한 보고서를 사용하여 특정 제어 조치가 올바르게 구현되었음을 증명하기도 합니다. 어떤 방식으로든 Rocky에 내장되어 있습니다. 몇 가지 기본 사항부터 시작하겠습니다.

## 보안 프로필 리스트

사용 가능한 보안 프로필을 나열하려면 `openscap-scanner` 패키지에서 제공하는 `oscap info` 명령을 사용해야 합니다. 파트 1 이후로 계속 따라왔다면 시스템에 이미 설치되어 있을 것입니다.  사용 가능한 보안 프로필을 얻으려면 다음을 실행하세요:

```
oscap info /usr/share/xml/scap/ssg/content/ssg-rl8-ds.xml
```

!!! 참고 사항

    Rocky linux 8 콘텐츠는 파일 이름에 "rl8" 태그를 사용합니다. Rocky 9에서는 "rl9"가 사용됩니다.

모두 잘 진행되면 다음과 같은 화면이 표시됩니다.

![보안 프로필](images/disa_stig_pt2_img1.jpg)

DISA는 Rocky Linux SCAP 정의에서 지원하는 다양한 보안 프로필 중 하나일 뿐입니다. 또한 다음과 같은 프로필도 있습니다:

* [ANSSI](https://www.ssi.gouv.fr/en/)
* [CIS](https://cisecurity.org)
* [호주 사이버 보안 센터](https://cyber.gov.au)
* [NIST-800-171](https://csrc.nist.gov/publications/detail/sp/800-171/rev-2/final)
* [HIPAA](https://www.hhs.gov/hipaa/for-professionals/security/laws-regulations/index.html)
* [PCI-DSS](https://www.pcisecuritystandards.org/)

## DISA STIG 준수 감사

여기에서 선택할 수 있는 두 가지 유형이 있습니다.

* stig - GUI 없이
* stig_gui - GUI 포함

DISA STIG를 감사하고 HTML 보고서를 생성하려면 다음을 실행하세요:

```
sudo oscap xccdf eval --report unit-test-disa-scan.html --profile stig /usr/share/xml/scap/ssg/content/ssg-rl8-ds.xml
```

이렇게 하면 다음과 비슷한 보고서가 생성됩니다:

![스캔 결과](images/disa_stig_pt2_img2.jpg)

그리고 HTML 보고서를 출력합니다:

![HTML 보고서](images/disa_stig_pt2_img3.jpg)

## 업데이트 적용 Bash 스크립트 생성

다음으로, 스캔을 생성한 후 스캔 결과를 사용하여 DISA stig 프로필을 기반으로 시스템을 복구하는 bash 스크립트를 생성합니다. 실제로 실행하기 전에 변경 사항을 검토하는 것을 권장합니다.

1) 시스템에서 스캔을 생성합니다.
    ```
    sudo oscap xccdf eval --results disa-stig-scan.xml --profile stig /usr/share/xml/scap/ssg/content/ssg-rl8-ds.xml
    ```
2) 이 스캔 출력을 사용하여 스크립트를 생성합니다.
    ```
    sudo oscap xccdf generate fix --output draft-disa-remediate.sh --profile stig disa-stig-scan.xml
    ```

생성된 스크립트에는 시스템에 적용될 변경 사항이 모두 포함됩니다.

!!! 주의

    실행하기 전에 이것을 검토하세요! 시스템에 중대한 변경 사항을 가할 수 있습니다.

![스크립트 내용](images/disa_stig_pt2_img4.jpg)

## 복구 Ansible 플레이북 생성

Ansible playbook 형식으로도 복구 조치를 생성할 수 있습니다. 위의 섹션을 반복하지만 이번에는 ansible 출력으로 진행해 보겠습니다:

1) 시스템에서 스캔을 생성합니다.
    ```
    sudo oscap xccdf eval --results disa-stig-scan.xml --profile stig /usr/share/xml/scap/ssg/content/ssg-rl8-ds.xml
    ```
2) 이 스캔 출력을 사용하여 스크립트를 생성합니다.
    ```
    sudo oscap xccdf generate fix --fix-type ansible --output draft-disa-remediate.yml --profile stig disa-stig-scan.xml
    ```

!!! 주의

    다시 말하지만 실행하기 전에 이것을 검토하십시오! 여기서 어떤 패턴이 느껴지나요? 이러한 모든 절차에 대한 이 검증 단계는 매우 중요합니다!

![Ansible Playbook](images/disa_stig_pt2_img5.jpg)

## 저자 소개

Scott Shinn은 Atomomicorp의 CTO이자 Rocky Linux Security 팀의 일원입니다. 그는 1995년부터 백악관, 국방부 및 정보 커뮤니티에서 연방 정보 시스템에 참여했습니다. 그 중 일부는 STIG를 생성하고 사용해야 하는 요구사항이었는데, 이에 대해 매우 유감스럽게 생각합니다.

