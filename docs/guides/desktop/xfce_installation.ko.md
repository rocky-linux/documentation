- - -
title: XFCE 데스트탑 author: Gerard Arthus, Steven Spencer contributors: Steven Spencer, Antoine Le Morvan, K.Prasad tested with: 8.5, 8.6, 9.0 tags:
  - xfce
  - 데스크톱
- - -

# XFCE 데스크탑 환경

XFCE 데스크탑 환경은 Common Desktop Environment (CDE)의 파생 프로젝트로 만들어졌습니다. XFCE는 모듈성과 재사용성이라는 전통적인 Unix 철학을 추구하고 있습니다. XFCE는 Rocky Linux를 포함하여 거의 모든 리눅스 버전에 설치할 수 있습니다.

또한 이는 awesome 또는 i3와 같은 대체 창 관리자와 가장 쉽게 결합할 수 있는 데스크탑 환경 중 하나입니다. 하지만 이 절차는 더 일반적인 XFCE 설치를 통해 Rocky Linux를 사용하도록 설계되었습니다.

## 필요 사항

* 워크스테이션 또는 노트북
* 기본 GNOME 데스크톱 대신 XFCE를 사용하려는 의지

=== "9"

    ## 9: 소개
    
    Rocky Linux 9의 개발 팀은 XFCE 및 기타 인기있는 데스크탑 환경을 설치하는 것을 쉽게 만들기 위해 라이브 이미지를 포함시켰습니다. 라이브 이미지는 OS를 설치하지 않고도 부팅할 수 있는 부팅 가능한 이미지입니다. 로드된 후, 이를 기기의 디스크 드라이브에 설치하여 사용할 수 있습니다.
    
    ## 9: XFCE 라이브 이미지 가져오기, 확인 및 쓰기
    
    설치 전에 첫 번째 단계는 라이브 이미지를 다운로드하고 DVD 또는 USB 썸드라이브에 작성하는 것입니다. 이미지는 다른 리눅스 설치 미디어와 마찬가지로 부팅 가능하게 됩니다. Rocky Linux 9 [라이브 이미지](https://dl.rockylinux.org/pub/rocky/9.1/live/x86_64/) 다운로드 섹션에서 최신 XFCE 이미지를 찾을 수 있습니다. 
    이 특정 링크는 프로세서 아키텍처로 x86_64를 가정합니다. 
    
    이 문서 작성 시점에서 이 라이브 이미지에는 x86_64 또는 aarch64 아키텍처를 사용할 수 있습니다. 라이브 이미지와 체크섬 파일을 모두 다운로드하세요. 
    
    이제 다음을 사용하여 CHECKSUM 파일로 이미지를 확인하세요(주의: 이는 예시입니다! 이미지 이름과 CHECKSUM 파일이 일치하는지 확인하세요):

    ```
    sha256sum -c CHECKSUM --ignore-missing Rocky-9-XFCE-x86_64-latest.iso.CHECKSUM
    ```


    모든 것이 정상적으로 진행되면 다음과 같은 메시지가 나타납니다:

    ```
    Rocky-9-XFCE-x86_64-latest.iso: OK
    ```


    파일의 체크섬이 OK이면 이제 미디어에 ISO 이미지를 작성할 준비가 되었습니다. 이 프로세스는 사용하는 OS, 미디어 및 도구에 따라 다르므로, 여기서 이미지를 미디어에 작성하는 방법을 알고 있다고 가정합니다. 여기서는 이미지를 미디어에 쓰는 방법을 알고 있다고 가정합니다.
    
    ## 9: 부팅하기
    
    이는 기계, BIOS, OS 등에 따라 다르므로 자신의 미디어(디비디 또는 USB) 가 첫 번째 부팅 장치로 설정되도록 확인해야 합니다. 성공적으로 설정된 경우 다음과 같은 화면이 표시됩니다:
    
    ![xfce_boot](images/xfce_boot.png)
    
    그렇다면 성공입니다! 미디어를 테스트하려면 해당 옵션을 먼저 선택하거나 **S**를 입력하여 **Start Rocky Linux XFCE 9.0**을 시작할 수 있습니다.
    
    라이브 이미지이므로 첫 번째 화면으로 부팅하는 데 시간이 좀 걸릴 수 있습니다. 걱정하지 마시고 기다리세요! 라이브 이미지가 부팅되면 다음 화면을 볼 수 있습니다:
    
    
    
    ![xfce_install](images/xfce_install.png)
    
    ## 9: XFCE 설치
    
    이제 XFCE 환경을 사용하여 어떻게 보이는지 확인할 수 있습니다. 사용을 영구적으로 원한다고 결정하면 "Install to Hard Drive" 옵션을 두 번 클릭하세요.
    
    이는 이미 Rocky Linux를 설치한 사용자들에게는 꽤 익숙한 설치 프로세스를 시작할 것입니다. 첫 번째 화면은 기본 언어를 선택하는 화면입니다:
    
    ![xfce_language](images/xfce_language.png)
    
    다음 화면에는 확인하거나 변경해야 할 사항들이 나열됩니다. 옵션은 참고용으로 번호가 매겨져 있습니다:
    
    
    
    ![xfce_install2](images/xfce_install_2.png)

    1. **키보드** - 사용하는 키보드 레이아웃과 일치하는지 확인하세요.
    2. **시간 & 날짜** - 시간대와 일치하는지 확인하세요.
    3. **설치 대상** - 이미 있는 것을 그대로 받아들이더라도 클릭해야 합니다.
    4. **네트워크 & 호스트 이름** - 원하는 내용을 확인하세요. 네트워크가 활성화된 상태라면 필요에 따라 나중에 변경할 수 있습니다.
    5. **루트 암호** - 루트 비밀번호를 설정하세요. 자주 사용하지 않을 경우에도 안전한 곳(비밀번호 관리자)에 저장하세요.
    6. **사용자 생성** - 적어도 하나의 사용자를 생성하세요. 사용자에게 관리 권한을 부여하려면 사용자를 생성할 때 이 옵션을 설정하세요.
    7. **설치 시작** - 모든 설정이 완료되었거나 확인되었을 때 이 옵션을 클릭하세요.

    7단계를 완료하면 설치 과정이 아래 스크린샷과 같이 패키지를 설치하게 됩니다:

    ![xfce_install3](images/xfce_install_3.png)

    하드 드라이브에 설치가 완료되면 다음 화면이 나타납니다:

    ![xfce_install_final](images/xfce_install_final.png)

    계속해서 **Finish Installation**를 클릭합니다.

    이렇게 하면 라이브 이미지 화면으로 돌아갑니다. 컴퓨터를 재부팅하고 XFCE 설치에 사용한 부팅 미디어를 제거하세요.

    그런 다음 위에서 생성한 사용자의 로그인 화면이 나타납니다. 비밀번호를 입력하세요. 이렇게 하면 XFCE 데스크톱으로 이동합니다:

    ![xfce_desktop](images/xfce_desktop.png)

=== "8"

    ## 8: Rocky Linux Minimal 설치
    
    !!! note "참고사항"
    
        참고: 이 섹션에서는 root 사용자이거나 권한을 상승시키기 위해 sudo를 사용할 수 있어야 합니다.
    
    Rocky Linux를 설치할 때 다음 패키지 세트를 사용했습니다.

    * Minimal
    * Standard


    ## 8: 시스템 업데이트 실행

    먼저 서버 업데이트 명령을 실행하여 시스템이 리포지토리 캐시를 다시 빌드하도록 하여 사용 가능한 패키지를 인식하게 합니다.

    ```
    dnf update
    ```


    ## 8: 리포지토리 활성화

    Rocky 8.x 버전에서 실행하려면 EPEL 리포지토리의 비공식 XFCE 리포지토리가 필요합니다.

    이 리포지토리를 활성화하려면 다음을 입력하세요:

    ```
    dnf install epel-release
    ```

    그리고 'Y'를 입력하여 설치를 진행하세요.

    Powertools와 lightdm 리포지토리도 필요합니다. 이제 다음을 입력하여 이들을 활성화하세요:

    ```
    dnf config-manager --set-enabled powertools
    dnf copr enable stenstorp/lightdm
    ```

    !!! !!!

        `copr` 빌드 시스템은 `lightdm`을 설치하는 데 작동하는 것으로 알려져 있지만 Rocky Linux 커뮤니티에서 유지되지 않는 리포지토리입니다. 본인 책임 하에 사용하세요!

    다시 한 번 리포지토리에 대한 경고 메시지가 표시됩니다. 'Y'로 응답하세요.


    ## 8: 그룹에서 사용 가능한 환경 및 도구 확인

    이제 리포지토리가 활성화되었으므로 다음 명령으로 모든 것을 확인하세요.

    먼저 다음 명령으로 리포지토리 목록을 확인하세요:

    ```
    dnf repolist
    ```

    활성화된 모든 리포지토리가 나열된 것을 확인할 수 있습니다:

    ```bash
    appstream                                                        Rocky Linux 8 - AppStream
    baseos                                                           Rocky Linux 8 - BaseOS
    copr:copr.fedorainfracloud.org:stenstorp:lightdm                 Copr repo for lightdm owned by stenstorp
    epel                                                             Extra Packages for Enterprise Linux 8 - x86_64
    epel-modular                                                     Extra Packages for Enterprise Linux Modular 8 - x86_64
    extras                                                           Rocky Linux 8 - Extras
    powertools                                                       Rocky Linux 8 - PowerTools
    ```

    다음 명령으로 XFCE를 확인하세요:

    ```
    dnf grouplist
    ```

    목록 하단에 "Xfce"가 표시되어야 합니다.

    활성화된 모든 리포지토리가 시스템에 읽혀지도록 다시 한 번 `dnf update`를 실행하세요.


    ## 8: 패키지 설치

    XFCE를 설치하려면 다음을 실행하세요:

    ```
    dnf groupinstall "xfce"
    ```

    또한 lightdm을 설치하세요:

    ```
    dnf install lightdm
    ```


    ## 8: 최종 단계

    *dnf groupinstall "xfce"*을 실행하면 추가되고 활성화되는 `gdm`을 비활성화해야 합니다:

    ```
    systemctl disable gdm
    ```

    이제 *lightdm*을 활성화할 수 있습니다.

    ```
    systemctl enable lightdm
    ```

    부팅 후에는 그래픽 사용자 인터페이스만 사용하도록 시스템에 지정합니다. 이를 위해 기본 대상 시스템을 GUI 인터페이스로 설정하세요:

    ```
    systemctl set-default graphical.target
    ```

    그런 다음 재부팅하세요.

    ```
    reboot
    ```

    이제 XFCE GUI에서 로그인 프롬프트가 나타날 것입니다. 로그인하면 모든 XFCE 환경을 사용할 수 있습니다.

## 결론

XFCE는 가벼운 환경으로 간단한 인터페이스를 제공합니다. Rocky Linux의 기본 GNOME 데스크톱 대안입니다. Rocky Linux 9를 실행하는 경우 개발자들은 설치 과정을 빠르게 진행할 수 있는 편리한 라이브 이미지를 만들었습니다.
