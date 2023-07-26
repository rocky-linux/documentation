---
title: VirtualBox의 Rocky
author: Steven Spencer
contributors: Trevor Cooper, Ezequiel Bruni
tested on: 8.4, 8.5
tags:
  - virtualbox
  - virtualization
---

# VirtualBox의 Rocky

## 소개

VirtualBox®는 기업 및 가정용으로 강력한 가상화 제품입니다. 가끔씩 누군가가 Rocky Linux를 VirtualBox®에서 실행하는 데 문제가 있다고 게시합니다. Rocky Linux는 릴리스 후보부터 여러 차례 테스트되었으며 정상적으로 작동합니다. 사람들이 보고하는 문제들은 주로 비디오와 관련된 것입니다.

이 문서는 VirtualBox®에서 Rocky Linux를 설치하고 실행하는 단계별 지침을 제공하기 위한 시도입니다. 이 문서를 작성한 컴퓨터는 Linux를 사용하고 있지만, 지원되는 운영 체제 중 하나를 사용할 수 있습니다.

## 필요 사항

* VirtualBox® 인스턴스를 빌드하고 실행할 수 있는 충분한 메모리와 하드 디스크 공간이 있는 기계 (Windows, Mac, Linux, Solaris).
* 기계에 VirtualBox®가 설치되어 있어야 합니다. 설치 방법은 [여기](https://www.virtualbox.org/wiki/Downloads)에서 확인할 수 있습니다.
* Rocky Linux [DVD ISO](https://rockylinux.org/download)의 사본이 필요합니다. (x86_64 또는 ARM64).
* OS가 64비트인지 확인하고 BIOS에서 하드웨어 가상화가 활성화되어 있는지 확인하세요.

!!! !!!

    64비트 OS를 설치하려면 하드웨어 가상화가 100% 필요합니다. 구성 화면에 32비트 옵션만 표시되는 경우, 계속하기 전에 이를 수정해야 합니다.

## VirtualBox 준비하기&reg; 구성

일단 VirtualBox&reg;가 설치되었다면 다음 단계는 VirtualBox®를 실행하는 것입니다. 이미지가 설치되지 않은 상태에서는 다음과 같은 화면이 표시됩니다:

 ![VirtualBox 새로 설치](../images/vbox-01.png)

 먼저 VirtualBox&reg;에 우리의 OS를 알려주어야 합니다:

 * "New"(톱니 아이콘)를 클릭합니다.
 * 이름을 입력합니다. 예: "Rocky Linux 8.5".
 * 기본적으로 기계 폴더는 자동으로 채워집니다.
 * 유형을 "Linux"로 변경하십시오.
 * 그리고 "Red Hat(64-bit)"을 선택합니다.
 * "Next"을 클릭합니다.

 ![이름 및 운영 체제](../images/vbox-02.png)

다음으로, 이 기계에 메모리를 할당해야 합니다. 기본적으로 VirtualBox®는 이를 자동으로 1024MB로 채우게 됩니다. 이는 Rocky Linux를 포함한 모든 최신 OS에 적합하지 않습니다. 메모리가 충분하다면 2GB에서 4GB (2048MB 또는 4096MB) 또는 더 많이 할당하십시오. 기억하세요, VirtualBox®는 가상 머신이 실행되는 동안에만 이 메모리를 사용합니다.

이 항목에 대한 스크린샷은 없으며, 사용 가능한 메모리에 따라 값을 변경하십시오. 최선의 판단을 행하세요.

이제 하드 디스크 크기를 설정해야 합니다. 기본적으로 VirtualBox®는 "Create a virtual hard disk now" 라디오 버튼을 자동으로 채우게 됩니다.

![하드디스크](../images/vbox-03.png)

* "Create"을 클릭하십시오

가상 하드 디스크 유형을 만드는 대화 상자가 표시됩니다. 여러 가지 하드 디스크 유형이 나열되어 있습니다. 가상 하드 디스크 유형 선택에 대한 [자세한 정보](https://docs.oracle.com/en/virtualization/virtualbox/6.0/user/vdidetails.html)는 Oracle VirtualBox 문서를 참조하십시오. 이 문서의 목적을 위해 기본값(VDI)을 유지하십시오:

![하드 디스크 파일 유형](../images/vbox-04.png)

* "Next"을 클릭하세요

다음 화면에서는 물리적 하드 디스크의 저장소를 다룹니다. 두 가지 옵션이 있습니다. "고정 크기"는 생성 시간이 더 오래 걸리지만 사용 시간이 더 빠르며, 공간에 대해 덜 유연합니다(공간이 더 필요한 경우, 생성한 크기로 고정됩니다).

기본 옵션인 "Dynamically Allocated"(동적 할당)은 생성 속도가 빠르고 사용 속도가 느리지만 디스크 공간을 변경해야 하는 경우 확장할 수 있는 옵션을 제공합니다. 이 문서의 목적을 위해 "Dynamically allocated"이라는 기본값을 수락합니다.

![물리적 하드 디스크에 저장](../images/vbox-05.png)

* "Next"을 클릭하세요

VirtualBox&reg;는 이제 가상 하드 디스크 파일을 저장할 위치를 지정하는 옵션과 기본 8GB 가상 하드 디스크 공간을 확장하는 옵션을 제공합니다. 이 옵션은 좋습니다. 왜냐하면 8GB의 하드 디스크 공간은 GUI 설치 옵션을 설치하는 데 충분하지 않습니다. 가상 머신을 사용하기에 따라 20GB (또는 더 많은 용량)으로 설정하세요. 그리고 사용 가능한 디스크 공간에 따라 조절하십시오:

![파일 위치 및 크기](../images/vbox-06.png)

* "Create"을 클릭하세요

기본 구성이 완료되었습니다. 다음과 같이 보이는 화면이어야 합니다:

![기본 구성 완료](../images/vbox-07.png)

## ISO 이미지 첨부

다음 단계는 이전에 다운로드한 ISO 이미지를 가상 CD-ROM 장치로 첨부하는 것입니다. "Settings" (톱니 바퀴 모양 아이콘)를 클릭하면 다음과 같은 화면이 표시됩니다:

![설정](../images/vbox-08.png)

* 왼쪽 메뉴에서 "Storage" 항목을 클릭합니다.
* 가운데 섹션의 "Storage Devices"에서 "Empty"라고 표시된 CD 아이콘을 클릭합니다.
* 오른쪽에 있는 "Attributes"에서 CD 아이콘을 클릭합니다.
* "Choose/Create a Virtual Optical Disk"를 선택합니다.
* "Add" 버튼 (플러스 기호 아이콘)를 클릭하고 Rocky Linux ISO 이미지가 저장된 위치로 이동합니다.
* ISO를 선택하고 "Open"을 클릭합니다.

이제 이렇게 ISO가 사용 가능한 장치로 추가되어야 합니다:

![ISO 이미지가 추가됨](../images/vbox-09.png)

* ISO 이미지를 강조 표시한 다음 "Choose"를 클릭합니다.

Rocky Linux ISO 이미지가 이제 가운데 섹션의 "Controller: IDE" 아래에서 선택된 것을 볼 수 있습니다:

![ISO 이미지 선택](../images/vbox-10.png)

* "OK"을 클릭하세요

### 그래픽 설치용 비디오 메모리

VirtualBox®는 비디오에 사용할 메모리를 16MB로 설정합니다. 이는 GUI 없는 최소한의 서버를 실행할 경우에는 괜찮지만, 그래픽을 추가하면 부족합니다. 이 설정을 유지하는 사용자들은 종종 부팅 화면이 멈추고 완료되지 않는 등의 오류를 볼 수 있습니다.

GUI가 있는 Rocky Linux를 실행할 예정인 경우, 그래픽을 원활하게 실행하기에 충분한 메모리를 할당해야 합니다. 기계의 메모리가 약간 부족한 경우, 이 값을 16MB씩 늘려가며 원활하게 실행될 때까지 조정하십시오. 또한 호스트 기계의 비디오 해상도도 고려해야 합니다.

Rocky Linux 가상 머신의 용도와 요구 사항과 호환되는 비디오 메모리를 할당하도록 신중하게 선택하십시오. [Oracle 공식 문서](https://docs.oracle.com/en/virtualization/virtualbox/6.0/user/settings-display.html)에서 디스플레이 설정에 대한 자세한 정보를 찾을 수 있습니다.

메모리가 충분하다면 이 값을 최대 128MB로 설정할 수 있습니다. 가상 머신을 시작하기 전에 이를 수정하려면 "Settings" (톱니 바퀴 모양 아이콘)를 클릭하여 이전에 ISO 이미지를 첨부할 때와 같은 설정 화면을 얻을 수 있습니다(위 참조).

이번에는:

* 왼쪽의 "Display"를 클릭합니다.
* 오른쪽의 "Screen" 탭에서 기본적으로 16MB로 설정된 "Video Memory" 옵션을 볼 수 있습니다.
* 원하는 값으로 이를 변경할 수 있습니다. 이 화면으로 언제든지 돌아와 값을 조정할 수 있습니다. 이 예시에서는 지금 128MB를 선택합니다.

!!! tip "팁"

    비디오 메모리를 최대 256MB로 설정하는 방법이 있습니다. 더 많은 메모리가 필요한 경우 [Oracle 공식 문서](https://docs.oracle.com/en/virtualization/virtualbox/6.0/user/vboxmanage-modifyvm.html)를 확인하세요.

이제 화면이 다음과 같아야 합니다:

![설정 비디오](../images/vbox-12.png)

* "OK"를 클릭하세요.

## 설치 시작

이제 설치를 시작할 준비가 모두 되었습니다. VirtualBox® 머신에서 Rocky Linux를 설치하는 것은 독립 실행형 하드웨어와 비교하여 별 다른 차이점이 없습니다. 설치 단계는 동일합니다.

설치를 위해 모든 준비가 완료되었으므로, "Start" (녹색 오른쪽 화살표 아이콘)를 클릭하여 Rocky를 설치하십시오. 언어 선택 화면을 넘어가면 다음 화면은 "Installation Summary" 화면입니다. 관련 있는 항목을 설정해야 하지만 다음과 같은 것들은 반드시 설정해야 합니다:

* 시간 및 날짜
* 소프트웨어 선택 (기본 "Server with GUI" 외에 다른 옵션을 원하는 경우)
* 설치 대상
* 네트워크 및 호스트 이름
* 사용자 설정

위 설정 중 확실하지 않은게 있다면 [Rocky 설치](../installation.md) 문서를 참조하세요.

설치를 완료하면 Rocky Linux를 실행하는 VirtualBox&reg;인스턴스를 얻을 수 있습니다.

설치 후 재부팅하면 사용권 계약 동의 화면이 표시되며, "Finish Configuration"를 클릭하면 그래픽 (GUI 옵션을 선택한 경우) 또는 명령 줄 로그인이 제공됩니다. 저자는 데모 목적으로 기본 "Server with GUI" 옵션을 선택했습니다:

![실행 중인 Rocky VirtualBox 머신](../images/vbox-11.png)

## 기타 정보

본 문서는 VirtualBox&reg;의 모든 기능에 대한 전문가가 되는 것을 목적으로 하지 않습니다. 특정 작업을 수행하는 방법에 대한 정보는 [공식 문서](https://docs.oracle.com/en/virtualization/virtualbox/6.0/user/)를 확인하세요.

!!! 팁 "고급 팁"

    VBoxManage를 사용하여 명령 줄에서 VirtualBox&reg;의 다양한 옵션을 활용할 수 있습니다. 본 문서는 VBoxManage의 사용에 대해 다루지 않지만, 이에 대해 자세히 조사하고 싶다면 Oracle의 공식 문서에서 [자세한 내용](https://docs.oracle.com/en/virtualization/virtualbox/6.0/user/vboxmanage-intro.html)을 확인하세요.

## 결론

VirtualBox&reg;를 사용하여 Rocky Linux 머신을 생성, 설치 및 실행하는 것은 매우 쉽습니다. 위의 단계를 따르면 Rocky Linux가 설치되어 작동하는 상태가 됩니다. 만약 당신이 VirtualBox&reg;를 사용하고 특정한 구성을 공유하고 싶다면, 저자는 이 문서에 새로운 섹션을 제출하도록 초대합니다.
