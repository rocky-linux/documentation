---
title: 고급 Linux 명령
---

# Linux 사용자를 위한 고급 명령

기본 명령에 익숙해지면 고급 명령을 통해 보다 구체적인 상황에서 더 많은 사용자 정의 및 제어가 가능합니다.

****

**목표**: 이 문서에서는 미래의 Linux 관리자가 다음을 수행하는 방법을 배웁니다:

:heavy_check_mark: 이전 장에서 다루지 않은 몇 가지 유용한 명령입니다.   
:heavy_check_mark: 일부 고급 명령.

:checkered_flag: **사용자 명령어**, **Linux**

**지식**: :star:   
**복잡성**: :star: :star: :star:

**소요 시간**: 20분

****

## `uniq` 명령

`uniq` 명령은 특히 로그 파일 분석을 위해 `sort` 명령과 함께 사용되는 매우 강력한 명령어입니다. 중복 항목을 제거하여 항목을 정렬하고 표시할 수 있습니다.

`uniq` 명령의 작동 방식을 설명하기 위해 이름 목록이 포함된 `firstnames.txt` 파일을 사용하겠습니다.

```
antoine
xavier
steven
patrick
xavier
antoine
antoine
steven
```

!!! 참고 사항

    `uniq`는 연속된 줄만 비교하기 때문에 실행하기 전에 입력 파일을 정렬해야 합니다.

인수가 없으면 `uniq` 명령은 `firstnames.txt` 파일에서 서로 이어지는 동일한 줄을 표시하지 않습니다.

```
$ sort firstnames.txt | uniq
antoine
patrick
steven
xavier
```

한 번만 나타나는 행만 표시하려면 `-u` 옵션을 사용하십시오:

```
$ sort firstnames.txt | uniq -u
patrick
```

반대로 파일에 두 번 이상 나타나는 행만 표시하려면 `-d` 옵션을 사용하십시오:

```
$ sort firstnames.txt | uniq -d
antoine
steven
xavier
```

한 번만 나타나는 줄을 간단히 삭제하려면 `-D` 옵션을 사용하십시오:

```
$ sort firstnames.txt | uniq -D
antoine
antoine
antoine
steven
steven
xavier
xavier
```

마지막으로 각 줄의 발생 횟수를 계산하려면 `-c` 옵션을 사용합니다:

```
$ sort firstnames.txt | uniq -c
      3 antoine
      1 patrick
      2 steven
      2 xavier
```

```
$ sort firstnames.txt | uniq -cd
      3 antoine
      2 steven
      2 xavier
```

## `xargs` 명령

`xargs` 명령을 사용하면 표준 입력에서 명령줄을 구성하고 실행할 수 있습니다.

`xargs` 명령은 표준 입력에서 공백 또는 줄 바꿈으로 구분된 인수를 읽습니다, 그리고 표준 입력에서 읽은 인수가 뒤따르는 초기 인수를 사용하여 명령(기본적으로 `/bin/echo`)을 한 번 이상 실행합니다.

가장 간단한 첫 번째 예는 다음과 같습니다:

```
$ xargs
use
of
xargs
<CTRL+D>
use of xargs
```

`xargs` 명령은 표준 **stdin** 입력의 입력을 기다립니다. 3줄이 입력됩니다. 사용자 입력의 끝은 키 입력 시퀀스 <kbd>CTRL</kbd>+<kbd>D</kbd>에 의해 `xargs`로 지정됩니다. `xargs`는 기본 명령 `echo`를 실행한 다음 사용자 입력에 해당하는 세 개의 인수, 즉 다음을 실행합니다.

```
$ echo "use" "of" "xargs"
use of xargs
```

`xargs`에 의해 실행될 명령을 지정할 수 있습니다.

다음 예에서 `xargs`는 표준 입력에 지정된 폴더 집합에서 `ls -ld` 명령을 실행합니다.

```
$ xargs ls -ld
/home
/tmp
/root
<CTRL+D>
drwxr-xr-x. 9 root root 4096  5 avril 11:10 /home
dr-xr-x---. 2 root root 4096  5 avril 15:52 /root
drwxrwxrwt. 3 root root 4096  6 avril 10:25 /tmp
```

실제로 `xargs` 명령은 `ls -ld /home /tmp /root` 명령을 실행했습니다.

실행할 명령이 `find` 명령과 같이 여러 인수를 허용하지 않으면 어떻게 됩니까?

```
$ xargs find /var/log -name
*.old
*.log
find: paths must precede expression: *.log
```

`xargs` 명령어는 `-name` 옵션 뒤에 여러 인수를 가진 `find` 명령어를 실행하려고 시도했으나, 이로 인해 `find` 에서 오류가 발생했습니다.

```
$ find /var/log -name "*.old" "*.log"
find: paths must precede expression: *.log
```

이 경우 `xargs` 명령어를 강제로 `find` 명령어를 여러 번 실행해야 합니다(표준 입력으로 입력된 한 줄당 한 번씩 입력됨). `-L` 옵션 다음에 **정수**를 사용하면 한 번에 명령으로 처리할 최대 항목 수를 지정할 수 있습니다.

```
$ xargs -L 1 find /var/log -name
*.old
/var/log/dmesg.old
*.log
/var/log/boot.log
/var/log/anaconda.yum.log
/var/log/anaconda.storage.log
/var/log/anaconda.log
/var/log/yum.log
/var/log/audit/audit.log
/var/log/anaconda.ifcfg.log
/var/log/dracut.log
/var/log/anaconda.program.log
<CTRL+D>
```

두 인수를 동일한 줄에 지정하려면 `-n 1` 옵션을 사용합니다:

```
$ xargs -n 1 find /var/log -name
*.old *.log
/var/log/dmesg.old
/var/log/boot.log
/var/log/anaconda.yum.log
/var/log/anaconda.storage.log
/var/log/anaconda.log
/var/log/yum.log
/var/log/audit/audit.log
/var/log/anaconda.ifcfg.log
/var/log/dracut.log
/var/log/anaconda.program.log
<CTRL+D>
```

검색을 기반으로 한 `tar`를 사용한 백업 사례 연구:

```
$ find /var/log/ -name "*.log" -mtime -1 | xargs tar cvfP /root/log.tar
$ tar tvfP /root/log.tar
-rw-r--r-- root/root      1720 2017-04-05 15:43 /var/log/boot.log
-rw-r--r-- root/root    499270 2017-04-06 11:01 /var/log/audit/audit.log
```

`xargs` 명령어의 특징은 입력 인수를 호출된 명령어의 끝에 배치한다는 것입니다. 위의 예시와 같이 파일들이 전달되면 이는 아카이브에 추가할 파일 목록을 형성하는 데 매우 잘 작동합니다.

`cp` 명령의 예를 들어 파일 목록을 디렉토리에 복사하려는 경우 해당 파일 목록이 명령 끝에 추가됩니다. 그러나, `cp` 명령은 이 명령의 끝에 있어야 합니다. 이렇게 하려면 `-I` 옵션을 사용하여 입력 인수를 줄의 끝이 아닌 다른 곳에 배치해야 합니다.

```
$ find /var/log -type f -name "*.log" | xargs -I % cp % /root/backup
```

`-I` 옵션을 사용하면 `xargs`에 대한 입력 파일을 배치할 문자(위 예제의 `%` 문자) 를 지정할 수 있습니다.

## `yum-utils` 패키지

`yum-utils` 패키지는 다양한 작성자가 `yum`용으로 빌드한 유틸리티 모음으로, 사용하기 쉽고 강력합니다.

!!! 참고 사항

    Rocky Linux 8에서 `yum`이 `dnf`로 대체된 반면, 패키지 이름은 `yum-utils`로 유지되며 `dnf-utils`로도 설치할 수 있습니다. 이들은 DNF 위에 CLI shim으로 구현된 고전적인 YUM 유틸리티로 `yum-3`와 하위 호환성을 유지합니다.

다음은 이러한 유틸리티의 몇 가지 예입니다:

* `repoquery` 명령

`repoquery` 명령은 리포지토리의 패키지를 쿼리하는 데 사용됩니다.

사용 예:

  * 패키지의 종속성(설치되었거나 설치되지 않은 소프트웨어 패키지일 수 있음)을 표시합니다. 이는 `dnf deplist <package-name>`에 해당합니다.
    ```
    repoquery --requires <package-name>
    ```

  * 설치된 패키지에서 제공한 파일 표시합니다.(설치되지 않은 패키지에서는 작동하지 않음), 이는 `rpm -ql <package-name>`에 해당합니다.

    ```
    $ repoquery -l yum-utils
    /etc/bash_completion.d
    /etc/bash_completion.d/yum-utils.bash
    /usr/bin/debuginfo-install
    /usr/bin/find-repos-of-install
    /usr/bin/needs-restarting
    /usr/bin/package-cleanup
    /usr/bin/repo-graph
    /usr/bin/repo-rss
    /usr/bin/repoclosure
    /usr/bin/repodiff
    /usr/bin/repomanage
    /usr/bin/repoquery
    /usr/bin/reposync
    /usr/bin/repotrack
    /usr/bin/show-changed-rco
    /usr/bin/show-installed
    /usr/bin/verifytree
    /usr/bin/yum-builddep
    /usr/bin/yum-config-manager
    /usr/bin/yum-debug-dump
    /usr/bin/yum-debug-restore
    /usr/bin/yum-groups-manager
    /usr/bin/yumdownloader
    …
    ```

* `yumdownloader` 명령:

`yumdownloader` 명령은 리포지토리에서 RPM 패키지를 다운로드합니다.  `dnf download --downloadonly --downloaddir ./  package-name`과 동일합니다.

!!! 참고 사항

    이 명령은 몇 rpm의 로컬 저장소를 빠르게 구축하는 데 매우 유용합니다!

예시: `yumdownloader`는 _samba_ rpm 패키지와 모든 종속성을 다운로드합니다.

```
$ yumdownloader --destdir /var/tmp --resolve samba
or
$ dnf download --downloadonly --downloaddir /var/tmp  --resolve  samba
```

| 옵션          | 설명                        |
| ----------- | ------------------------- |
| `--destdir` | 다운로드한 패키지는 지정된 폴더에 저장됩니다. |
| `--resolve` | 패키지 종속성도 다운로드합니다.         |

## `psmisc` 패키지

`psmisc` 패키지에는 시스템 프로세스를 관리하기 위한 유틸리티가 포함되어 있습니다:

* `pstree`: `pstree` 명령은 시스템의 현재 프로세스를 트리와 같은 구조로 표시합니다.
* `killall`: `killall` 명령은 이름으로 식별된 모든 프로세스에 킬 신호를 보냅니다.
* `fuser`: `fuser` 명령은 지정된 파일 또는 파일 시스템을 사용하는 프로세스의 `PID`를 식별합니다.

예시:

```
$ pstree
systemd─┬─NetworkManager───2*[{NetworkManager}]
        ├─agetty
        ├─auditd───{auditd}
        ├─crond
        ├─dbus-daemon───{dbus-daemon}
        ├─firewalld───{firewalld}
        ├─lvmetad
        ├─master─┬─pickup
        │        └─qmgr
        ├─polkitd───5*[{polkitd}]
        ├─rsyslogd───2*[{rsyslogd}]
        ├─sshd───sshd───bash───pstree
        ├─systemd-journal
        ├─systemd-logind
        ├─systemd-udevd
        └─tuned───4*[{tuned}]
```

```
# killall httpd
```

`/etc/httpd/conf/httpd.conf` 파일에 액세스하는 프로세스를 종료합니다(옵션 `-k`).

```
# fuser -k /etc/httpd/conf/httpd.conf
```

## `watch` 명령

`watch` 명령은 정기적으로 명령을 실행하고 그 결과를 단말기에 전체 화면으로 표시합니다.

`-n` 옵션을 사용하면 각 명령 실행 간격(초)을 지정할 수 있습니다.

!!! 참고 사항

    `watch`명령을 종료하려면 다음 키를 입력해야 합니다: <kbd>CTRL</kbd>+<kbd>C</kbd> 에서 프로세스를 종료합니다.

예시:

* 5초마다 `/etc/passwd` 파일의 끝을 표시합니다:

```
$ watch -n 5 tail -n 3 /etc/passwd
```

결과:

```
Every 5,0s: tail -n 3 /etc/passwd                                                                                                                                rockstar.rockylinux.lan: Thu Jul  1 15:43:59 2021

sssd:x:996:993:User for sssd:/:/sbin/nologin
chrony:x:995:992::/var/lib/chrony:/sbin/nologin
sshd:x:74:74:Privilege-separated SSH:/var/empty/sshd:/sbin/nologin
```

* 폴더의 파일 수 모니터링:

```
$ watch -n 1 'ls -l | wc -l'
```

* 시계 표시:

```
$ watch -t -n 1 date
```
