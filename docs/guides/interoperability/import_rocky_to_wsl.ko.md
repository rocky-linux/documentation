---
title: Rocky Linux를 WSL 또는 WSL2로 가져오기
author: Lukas Magauer
tested_with: 8.6, 9.0
tags:
  - wsl
  - wsl2
  - 윈도우
  - 상호 운용성
---

# Rocky Linux를 WSL로 가져오기

## 필요 사항

Windows Subsystem for Linux 기능이 활성화되어 있어야 합니다. 이를 위해서 다음 중 하나의 방법을 사용할 수 있습니다.

- 매우 최근에 [Microsoft Store](https://apps.microsoft.com/store/detail/windows-subsystem-for-linux/9P9TQF7MRM4R)에서 사용 가능한 새로운 WSL 버전이 나왔으며, 더 많은 기능이 있으므로 가능하다면 이를 사용하세요.
- 관리 터미널(PowerShell 또는 명령 프롬프트)을 열고 <br>다음을 실행 `wsl --install` ([ref.](https://docs.microsoft.com/en-us/windows/wsl/install))
- Windows 설정에서 `Windows Subsystem for Linux` 선택적 기능을 활성화합니다.

이 기능은 현재 모든 지원되는 Windows 10 및 11 버전에서 사용할 수 있어야 합니다.

## 단계

1. 컨테이너 루트 파일시스템을 가져옵니다. 이는 여러 가지 방법으로 가능합니다.

    - **권장:** CDN에서 이미지 다운로드:
        - 8: [Base x86_64](https://dl.rockylinux.org/pub/rocky/8/images/x86_64/Rocky-8-Container-Base.latest.x86_64.tar.xz), [Minimal x86_64](https://dl.rockylinux.org/pub/rocky/8/images/x86_64/Rocky-8-Container-Minimal.latest.x86_64.tar.xz), [UBI x86_64](https://dl.rockylinux.org/pub/rocky/8/images/x86_64/Rocky-8-Container-UBI.latest.x86_64.tar.xz),<br>[Base aarch64](https://dl.rockylinux.org/pub/rocky/8/images/aarch64/Rocky-8-Container-Base.latest.aarch64.tar.xz), [Minimal aarch64](https://dl.rockylinux.org/pub/rocky/8/images/aarch64/Rocky-8-Container-Minimal.latest.aarch64.tar.xz), [UBI aarch64](https://dl.rockylinux.org/pub/rocky/8/images/aarch64/Rocky-8-Container-UBI.latest.aarch64.tar.xz)
        - 9: [Base x86_64](https://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-Container-Base.latest.x86_64.tar.xz), [Minimal x86_64](https://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-Container-Minimal.latest.x86_64.tar.xz), [UBI x86_64](https://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-Container-UBI.latest.x86_64.tar.xz),<br>[Base aarch64](https://dl.rockylinux.org/pub/rocky/9/images/aarch64/Rocky-9-Container-Base.latest.aarch64.tar.xz), [Minimal aarch64](https://dl.rockylinux.org/pub/rocky/9/images/aarch64/Rocky-9-Container-Minimal.latest.aarch64.tar.xz), [UBI aarch64](https://dl.rockylinux.org/pub/rocky/9/images/aarch64/Rocky-9-Container-UBI.latest.aarch64.tar.xz)
    - Docker Hub 또는 Quay.io에서 이미지 추출 ([ref.](https://docs.microsoft.com/en-us/windows/wsl/use-custom-distro#export-the-tar-from-a-container))

        ```sh
        <podman/docker> export rockylinux:9 > rocky-9-image.tar
        ```

2. (선택 사항) 최신 WSL 버전이 아닌 경우 .tar 파일을 .tar.xz 파일에서 추출해야 합니다.
3. WSL이 파일을 저장할 디렉터리를 만듭니다(대부분 사용자 프로필의 어딘가에 있음).
4. 마지막으로 이미지를 WSL로 가져옵니다([ref.](https://docs.microsoft.com/en-us/windows/wsl/use-custom-distro#import-the-tar-file-into-wsl)):

    - WSL：

        ```sh
        wsl --import <machine-name> <path-to-vm-dir> <path-to/rocky-9-image.tar.xz>
        ```

    - WSL 2：

        ```sh
        wsl --import <machine-name> <path-to-vm-dir> <path-to/rocky-9-image.tar.xz> --version 2
        ```

!!! tip "WSL vs. WSL 2"

    일반적으로 WSL 2가 WSL보다 더 빠릅니다. 그러나 사용 사례에 따라 다를 수 있습니다.

!!! 팁 "Windows Terminal"

    Windows 터미널이 설치되어 있다면, 새로운 WSL 배포 이름이 드롭다운 메뉴에 옵션으로 나타나므로 편리하게 사용할 수 있습니다. 그런 다음 색상, 글꼴 등으로 사용자 정의할 수 있습니다.

!!! 팁 "systemd"

    마이크로소프트가 WSL에 systemd를 도입하기로 결정했습니다. 이 기능은 Microsoft Store의 새 WSL 버전에서 사용 가능합니다. `/etc/wsl.conf` 파일의 boot ini 섹션에 `systemd=true`를 추가하기만 하면 됩니다! ([참고](https://devblogs.microsoft.com/commandline/systemd-support-is-now-available-in-wsl/#set-the-systemd-flag-set-in-your-wsl-distro-settings))

!!! tip "Microsoft Store"

    현재 Microsoft Store에 이미지가 없습니다. Microsoft Store에 가져오는 데 도움을 주려면 Mattermost SIG/Containers 채널에서 대화에 참여하세요! 예전에 이미 [논의된 작업](https://github.com/rocky-linux/WSL-DistroLauncher)이 있으며, 다시 시작할 수 있습니다.
