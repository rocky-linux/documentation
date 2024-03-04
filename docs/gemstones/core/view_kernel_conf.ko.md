---
title: 현재 커널 구성 보기
author: David Hensley
contributors: Steven Spencer
tested_with: 8.5
tags:
  - 커널
  - config
  - modules
  - kmod
---

# 현재 커널 구성 보기

리눅스 커널은 두 개의 특수 파일 시스템을 통해 실행 중인 커널 정보를 저장합니다: ([요약](https://www.landoflinux.com/linux_procfs_sysfs.html))

  - `/proc`를 마운트하는 예전의 [procfs](https://man7.org/linux/man-pages/man5/procfs.5.html) ( `mount -l -t proc`를 통해 확인)
  - `/sys`를 마운트하는 최신 [sysfs](https://man7.org/linux/man-pages/man5/sysfs.5.html) (`mount -l -t sysfs`를 통해 확인)

!!! 주의

    여기에 언급된 파일을 조사할 때 조심하세요. 이들을 변경하면 실제 실행 중인 커널의 동작이 변경될 수 있습니다!


이 두 인터페이스를 통해 현재 실행 중인 커널의 매개변수를 볼 수 있고 변경할 수도 있습니다.

이러한 파일 중 일부를 [`ls -l`](https://man7.org/linux/man-pages/man1/ls.1.html)로 확인하면 길이가 "0"으로 표시되지만 [`cat`](https://man7.org/linux/man-pages/man1/cat.1.html)으로 확인하면 실제 데이터가 포함되어 있음을 알 수 있습니다. 대부분의 파일은 ASCII이며 편집할 수 있지만 일부는 이진 형식입니다. 어느 경우에도 [`file`](https://man7.org/linux/man-pages/man1/file.1.html)이나 [`stat`](https://man7.org/linux/man-pages/man2/lstat.2.html)과 같은 명령은 일반적으로 길이에 대해 "빈 파일"이나 "0"을 반환하지만 다른 정보를 표시합니다.

이러한 기능과 상호 작용하기 위해 선호되는 표준 프로그램은 [`lsmod`](https://man7.org/linux/man-pages/man8/lsmod.8.html), [`modinfo`](https://man7.org/linux/man-pages/man8/modinfo.8.html), 및 [`sysctl`](https://man7.org/linux/man-pages/man8/sysctl.8.html) 등 입니다.

```bash
sysctl -a | grep -i <keyword>
```

```bash
lsmod | grep -i <keyword>
```

```bash
modinfo <module>
```

현재 실행 중인 "커널 릴리스" 버전이 무엇인지 확인하십시오.

`uname -r` 및 `$(uname -r)`를 사용하여 명령에서 반환 값을 대체합니다.

RHEL 및 파생 배포판(Fedora, CentOS Stream, Scientific Linux, RockyLinux, Almalinux 등) RHEL 및 파생 배포판 (Fedora, CentOS Stream, Scientific Linux, RockyLinux, AlmaLinux 등)은 Grub2에서 사용하는 `/boot` 디렉토리에 설치된 커널의 구성을 ASCII 파일로 저장합니다.

```bash
/boot/config-<kernel-release>
```

특정 값의 현재 실행 중인 커널 구성을 확인하려면 다음을 실행하세요.

```bash
cat /boot/config-$(uname -r) | grep -i <keyword>
```

결과는 다음과 같이 표시됩니다.

  - 커널 모듈로 컴파일된 경우 "=m"
  - 커널에 정적으로 컴파일된 경우 "=y"
  - 설정이 주석 처리된 경우 "is not set"
  - 숫자 값
  - 인용 부호로 둘러싸인 문자열 값

일부 배포판 (Gentoo 및 Arch 등)은 기본적으로 `/proc/config.gz`를 제공하기 위해 `configs` 커널 모듈을 사용합니다.

```bash
zcat /proc/config.gz | grep -i <keyword>
zgrep <keyword> /proc/config.gz
```

모든 배포에서 실행 중인 커널이 `CONFIG_IKCONFIG` 및 `CONFIG_IKCONFIG_PROC` 두 가지를 모두 설정한 경우

```bash
ls -lh /sys/module/configs
```

존재하고 실행 가능하며(dir의 경우 검색 가능), 존재하지 않는 경우 이 명령을 사용하여 `/proc/config.gz`를 생성할 수 있습니다:

```bash
modprobe configs
```

!!! 참고 "활성화된 저장소"

    이 문서는 다음과 같은 기본 리포지토리 이외의 리포지토리에서 제공되는 커널 패키지에 대해서는 다루지 않습니다. appstream-debug, appstream-source, baseos-debug, baseos-source, or devel


`kernel-devel` 패키지는 설치된 각 표준 커널 패키지를 ASCII 파일로 컴파일하는 데 사용되는 구성 파일을 다음 위치에 설치합니다.

```bash
/usr/src/kernels/<kernel-release>/.config
```

이 파일은 `kernel-core` 패키지에 의해 제공되는 심볼릭 링크 경로를 통해 일반적으로 액세스됩니다.

```bash
/lib/modules/<kernel-release>/build/ -> /usr/src/kernels/<kernel-release>/
```

`kernel-debug-devel` 패키지가 설치된 경우 다음 디렉토리도 있습니다.

```bash
 /usr/src/kernels/<kernel-release>+debug/
```

설치된 커널에 대해 사용된 구성 값에 대해 자세히 알아보려면 다음 파일을 확인할 수 있습니다.

```bash
/lib/modules/<kernel-release>/config
/lib/modules/<kernel-release>/build/.config
/usr/src/kernels/<kernel-release>/.config
/usr/src/kernels/<kernel-release>+debug/.config
```

현재 실행 중인 커널에 대해 구성된 모듈은 내장(즉, 커널 자체에 정적으로) 또는 로드 가능한 모듈로 컴파일되었는지 여부에 관계없이 모듈 이름으로 명명된 하위 디렉토리에 나열됩니다.

```bash
/sys/module/
```

설치된 각 커널 릴리스에 대해 컴파일된 값과 해당 버전의 [GCC](https://man7.org/linux/man-pages/man1/gcc.1.html) 정보를 확인하려면 다음 파일을 확인할 수 있습니다.

```bash
cat /lib/modules/$(uname -r)/config | grep -i <keyword>
```

```bash
cat /lib/modules/$(uname -r)/build/.config | grep -i <keyword>
```

```bash
cat /usr/src/kernels/$(uname -r)/.config | grep -i <keyword>
```

```bash
cat /usr/src/kernels/$(uname -r)+debug/.config | grep -i <keyword>
```

```bash
ls -lh /sys/module/ | grep -i <keyword>
```

커널 모듈 종속성은 다음 파일에서 확인할 수 있습니다.

```bash
/lib/modules/<kernel-release>/modules.dep
```

그러나 [`lsmod`](https://man7.org/linux/man-pages/man8/lsmod.8.html)에서 "Used-by" 필드의 출력을 읽거나 구문 분석하는 것이 더 쉽습니다.

## 참고

[depmod](https://man7.org/linux/man-pages/man8/depmod.8.html), [ls](https://man7.org/linux/man-pages/man1/ls.1.html), [lsmod](https://man7.org/linux/man-pages/man8/lsmod.8.html), [modinfo](https://man7.org/linux/man-pages/man8/modinfo.8.html), [modprobe](https://man7.org/linux/man-pages/man8/modprobe.8.html), [modules.dep](https://man7.org/linux/man-pages/man5/modules.dep.5.html), [namespaces](https://man7.org/linux/man-pages/man7/namespaces.7.html), [procfs](https://man7.org/linux/man-pages/man5/procfs.5.html), [sysctl](https://man7.org/linux/man-pages/man8/sysctl.8.html), [sysfs](https://man7.org/linux/man-pages/man5/sysfs.5.html), [uname](https://man7.org/linux/man-pages/man8/uname26.8.html)
