---
title: MATE 데스크톱
author: lillolollo, Steven Spencer
contributors: Steven Spencer, OSSLAB
tested_with: 8.5, 8.6, 9.0
tags:
  - mate
  - desktop
---

# MATE 데스크톱 환경

MATE 데스크톱 환경은 GNOME3가 도입될 때 상대적으로 부정적인 평가를 받은 뒤 GNOME2를 포크하고 계속해서 발전시키기 위해 만들어졌습니다. MATE에는 일반적으로 선택한 OS에 즉시 설치하는 충실한 추종자들이 있습니다. MATE는 일반적으로 OS에 즉시 설치하는 것이 좋다고 생각하는 충성스러운 팬들을 가지고 있으며, Rocky Linux를 포함한 많은 리눅스 배포판에 설치할 수 있습니다.

이 절차는 Rocky Linux에서 MATE를 실행하기 위해 구성되어 있습니다.

## 필요 사항

* 화면과 모든 것이 있는 컴퓨터(노트북 또는 워크스테이션).
* 기본 GNOME 대신 MATE 데스크톱을 실행하고자 하는 의지.

=== "9"

    ## 9: 소개
    
    Rocky Linux 9 개발팀은 MATE와 기타 인기 있는 데스크톱 환경을 쉽게 설치할 수 있도록 라이브 이미지를 포함시켰습니다. 라이브 이미지는 설치 없이 OS를 로드하는 부팅 가능한 이미지입니다. 로드되면 기계의 디스크 드라이브에 설치하고 사용할 수 있습니다. 라이브 이미지 사용 설명서 외에도 OS가 이미 설치된 후에 MATE를 설치하고자하는 사용자를 위한 설치 지침이 포함되어 있습니다.
    
    ## 9: 라이브 이미지에서 MATE
    
    ### 9: MATE 라이브 이미지 가져오기, 확인 및 쓰기
    
    설치 전에 첫 번째 단계는 라이브 이미지를 다운로드하고 DVD 또는 USB 썸 드라이브에 쓰는 것입니다. 앞서 언급한대로 라이브 이미지는 Linux를 위한 기타 모든 설치 미디어와 마찬가지로 부팅 가능합니다. Rocky Linux 9 [라이브 이미지](https://dl.rockylinux.org/pub/rocky/9.1/live/x86_64/) 다운로드 섹션에서 최신 MATE 이미지를 찾을 수 있습니다. 이 특정 링크는 아키텍처로 x86_64를 가정하고 있으며, 현재 작성 시점에서 이 특정 라이브 이미지는 해당 아키텍처로만 제공됩니다. 라이브 이미지와 체크섬 파일 모두를 다운로드하세요. 
    
    이제 다음을 사용하여 CHECKSUM 파일로 이미지를 확인하십시오. (참고로 예시입니다! 이미지 이름과 CHECKSUM 파일이 일치하는지 확인하세요.)

    ```
    sha256sum -c CHECKSUM --ignore-missing Rocky-9.1-MATE-x86_64-20221124.0.iso.CHECKSUM
    ```


    모두 성공하면 다음과 같은 메시지를 받아야 합니다:

    ```
    Rocky-9.1-MATE-x86_64-20221124.0.iso: OK
    ```


    파일의 체크섬이 OK라면 이제 ISO 이미지를 미디어에 쓸 준비가 되었습니다. 이 절차는 사용 중인 OS, 미디어 및 도구에 따라 다르므로 여기에서는 이미지를 미디어에 쓰는 방법을 알고 있다고 가정합니다. 여기서는 이미지를 미디어에 쓰는 방법을 알고 있다고 가정합니다.
    
    기계가 미디어(DVD 또는 USB)로 시작하도록 설정해야 합니다. 성공한 경우 다음 화면이 표시됩니다:
    
    
    
    ![mate_boot](images/mate_boot.png)
    
    성공한 경우, 축하합니다! 미디어를 테스트하려면 먼저 해당 옵션을 선택하거나 **S**를 입력하여 **Start Rocky Linux Mate 9.0**을 시작하세요.
    
    라이브 이미지이므로 처음 화면으로 부팅하는 데 시간이 다소 걸릴 수 있습니다. 걱정하지 마시고 기다리세요! 라이브 이미지가 부팅되면 다음과 같은 화면이 표시됩니다:
    
    
    
    ![mate-live](images/mate_live.png)
    
    ### 9: MATE 설치
    
    이 시점에서 MATE 환경을 사용하고 마음에 드는지 확인할 수 있습니다. MATE를 영구적으로 사용하려고 한다면, **Hard Drive에 설치**를 두 번 클릭하세요.
    
    이는 이미 Rocky Linux를 설치한 적이 있는 사용자에게는 익숙한 설치 프로세스를 시작합니다. 다음 화면에서 **변경할 수 있는 항목**들을 강조했습니다.
    
    ![mate_install](images/mate_install.png)

    1. **키보드** - 사용하는 키보드 레이아웃과 일치하는지 확인하세요.
    2. **시간 & 날짜** - 시간대와 일치하는지 확인하세요.
    3. **설치 대상** - 이미 있는 것을 그대로 받아들이더라도 클릭해야 합니다.
    4. **네트워크 & 호스트 이름** - 원하는 내용을 확인하세요. 네트워크가 활성화된 상태라면 필요에 따라 나중에 변경할 수 있습니다.
    5. **루트 암호** - 루트 비밀번호를 설정하세요. 자주 사용하지 않을 경우에도 안전한 곳(비밀번호 관리자)에 저장하세요.
    6. **사용자 생성** - 적어도 하나의 사용자를 생성하세요. 사용자에게 관리 권한을 부여하려면 사용자를 생성할 때 이 옵션을 설정하세요.
    7. **설치 시작** - 모든 설정이 완료되었거나 확인되었을 때 이 옵션을 클릭하세요.

    7단계를 수행하면 설치 프로세스가 아래 스크린샷과 같이 패키지를 설치하기 시작합니다:

    ![mate_install_2](images/mate_install_2.png)

    하드 드라이브에 설치가 완료되면 다음 화면이 표시됩니다.

    ![mate_install_final](images/mate_install_final.png)

    계속해서 **Finish Installation**를 클릭합니다.

    이제 OS가 재부팅되고, 부팅 미디어를 제거해야 합니다. OS가 처음으로 시작될 때 라이센스 동의 화면이 표시됩니다:

    ![eula](images/eula.png)

    **I accept the license agreement** 확인란을 클릭한 다음 **Done**을 클릭하세요. 이로써 설치와 관련된 최종 화면에 도달합니다. 이 화면에서 **Finish Configuration**을 클릭하세요.

    ![mate_finish](images/mate_finish.png)

    그다음으로 사용자를 생성한 로그인 화면이 표시됩니다. 비밀번호를 입력하고 MATE 데스크톱에 접속할 수 있습니다:

    ![mate_desktop](images/mate_desktop.png)


    ## 9: OS 설치 후 MATE

    MATE는 OS가 설치된 후에도 설치할 수 있습니다. 몇 가지 단계를 거쳐 진행해야 하지만 어려운 과정은 아닙니다. 다음 지침에 따라 진행하세요.


    ### 9: 리포지토리 활성화

    CRB 리포지토리와 EPEL 리포지토리가 필요합니다. 이제 다음 명령어를 사용하여 이들을 활성화하세요:

    ```
    sudo dnf config-manager --set-enabled crb
    sudo dnf install epel-release
    ```

    그런 다음 모든 활성화된 리포지토리를 시스템에 읽어들이기 위해 `dnf upgrade`를 실행하세요.


    ### 9: 패키지 설치

    이제 필요한 많은 패키지가 필요합니다. 다음 내용을 기계의 명령줄에 복사하여 설치할 수 있습니다:

    ```
    sudo dnf install NetworkManager-adsl NetworkManager-bluetooth NetworkManager-libreswan-gnome NetworkManager-openvpn-gnome NetworkManager-ovs NetworkManager-ppp NetworkManager-team NetworkManager-wifi NetworkManager-wwan adwaita-gtk2-theme alsa-plugins-pulseaudio atril atril-caja atril-thumbnailer caja caja-actions caja-image-converter caja-open-terminal caja-sendto caja-wallpaper caja-xattr-tags dconf-editor engrampa eom firewall-config gnome-disk-utility gnome-epub-thumbnailer gstreamer1-plugins-ugly-free gtk2-engines gucharmap gvfs-fuse gvfs-gphoto2 gvfs-mtp gvfs-smb initial-setup-gui libmatekbd libmatemixer libmateweather libsecret lm_sensors marco mate-applets mate-backgrounds mate-calc mate-control-center mate-desktop mate-dictionary mate-disk-usage-analyzer mate-icon-theme mate-media mate-menus mate-menus-preferences-category-menu mate-notification-daemon mate-panel mate-polkit mate-power-manager mate-screensaver mate-screenshot mate-search-tool mate-session-manager mate-settings-daemon mate-system-log mate-system-monitor mate-terminal mate-themes mate-user-admin mate-user-guide mozo network-manager-applet nm-connection-editor p7zip p7zip-plugins pluma seahorse seahorse-caja xdg-user-dirs-gtk
    ```

    이렇게 하면 필요한 패키지와 해당 종속성들이 모두 설치됩니다.

    계속해서 lightdm-settings 및 lightdm도 설치해 보겠습니다.

    ```
    sudo dnf install lightdm-settings lightdm
    ```


    ### 9: 최종 단계

    이제 시스템에 Gnome 또는 다른 데스크톱이 이미 설치된 경우 이 시점에서 재부팅할 준비가 되었습니다. 데스크톱이 설치되지 않은 경우 다음 명령어를 사용하여 그래픽 타겟을 설정해야 합니다:

    ```
    sudo systemctl set-default graphical.target
    ```

    그런 다음 재부팅합니다.

    ```
    sudo reboot
    ```

    시스템이 재부팅되면 사용자 이름을 클릭하지만 비밀번호를 입력하기 전에 화면 오른쪽 아래에 있는 톱니바퀴 아이콘을 클릭하여 데스크톱 목록에서 MATE를 선택하세요. 그런 다음 로그인하면 완전히 작동하는 MATE 데스크톱이 표시됩니다. 미래 로그인에서는 이전 선택이 기억될 것입니다.

=== "8"

    ## 8: Rocky Linux Minimal 설치
    
    Rocky Linux를 설치할 때 다음 패키지 세트를 사용했습니다:

    * Minimal
    * Standard


    ## 8: 리포지토리 활성화

    Powertools 리포지토리와 EPEL 리포지토리가 필요합니다. 이제 다음 명령어를 사용하여 이들을 활성화하세요:

    ```
    sudo dnf config-manager --set-enabled powertools
    sudo dnf install epel-release
    ```

    그리고 EPEL 리포지토리를 설치하기 위해 'Y'를 입력하세요.

    `dnf update` 명령어를 실행하여 활성화된 모든 리포지토리를 시스템에 적용하세요.


    ## 9: 패키지 설치

    이제 필요한 많은 패키지가 필요합니다. 다음 내용을 단순히 기계의 명령줄에 복사하여 설치할 수 있습니다:

    ```
    sudo dnf install NetworkManager-adsl NetworkManager-bluetooth NetworkManager-libreswan-gnome NetworkManager-openvpn-gnome NetworkManager-ovs NetworkManager-ppp NetworkManager-team NetworkManager-wifi NetworkManager-wwan abrt-desktop abrt-java-connector adwaita-gtk2-theme alsa-plugins-pulseaudio atril atril-caja atril-thumbnailer caja caja-actions caja-image-converter caja-open-terminal caja-sendto caja-wallpaper caja-xattr-tags dconf-editor engrampa eom firewall-config gnome-disk-utility gnome-epub-thumbnailer gstreamer1-plugins-ugly-free gtk2-engines gucharmap gvfs-afc gvfs-afp gvfs-archive gvfs-fuse gvfs-gphoto2 gvfs-mtp gvfs-smb initial-setup-gui libmatekbd libmatemixer libmateweather libsecret lm_sensors marco mate-applets mate-backgrounds mate-calc mate-control-center mate-desktop mate-dictionary mate-disk-usage-analyzer mate-icon-theme mate-media mate-menus mate-menus-preferences-category-menu mate-notification-daemon mate-panel mate-polkit mate-power-manager mate-screensaver mate-screenshot mate-search-tool mate-session-manager mate-settings-daemon mate-system-log mate-system-monitor mate-terminal mate-themes mate-user-admin mate-user-guide mozo network-manager-applet nm-connection-editor p7zip p7zip-plugins pluma seahorse seahorse-caja xdg-user-dirs-gtk
    ```

    이렇게 하면 필요한 패키지와 해당 종속성들이 모두 설치됩니다.

    계속해서 lightdm-settings 및 lightdm도 설치해 보겠습니다.

    ```
    sudo dnf install lightdm-settings lightdm
    ```


    ## 8: 최종 단계

    이제 필요한 모든 것들이 설치되었으므로, 최소 설치를 그래픽 사용자 인터페이스(GUI)로 부팅하도록 설정해야 합니다. 다음 명령어를 입력하여 이 작업을 수행할 수 있습니다:

    ```
    sudo systemctl set-default graphical.target
    ```

    그리고 이제 재부팅해주세요:

    ```
    sudo reboot
    ```

    그다음으로 화면에서 사용자 이름을 클릭하고, 비밀번호를 입력하여 로그인하기 전에 "로그인" 옵션 왼쪽에 있는 기어 아이콘을 클릭하세요. 사용 가능한 데스크톱 선택에서 "MATE"를 선택한 다음 비밀번호를 입력하고 로그인할 수 있습니다. 미래 로그인에서는 이전 선택이 기억될 것입니다.

## 결론

새로운 GNOME 구현에 만족하지 못하는 사람들이나 오래된 MATE GNOME 2 모양과 느낌을 선호하는 사람들을 위해 Rocky Linux에 MATE를 설치하는 것이 좋은 안정적인 대안을 제공합니다. 그러한 사람들에게는 Rocky Linux에 MATE를 설치하는 것이 멋지고 안정적인 대안이 될 것입니다. Rocky Linux 9.0에서는 사용 가능한 라이브 이미지로 전체 프로세스를 매우 쉽게 만들어냈습니다.
