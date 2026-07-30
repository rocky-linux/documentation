---
title: Grep command
author: tianci li
contributors:
tags:
  - grep
---

# `grep` 명령어

`grep` 명령어는 하나 또는 여러 파일의 내용을 필터링하는 데 사용됩니다. 이 명령 도구의 여러 변형이 있으며, `egrep (grep -E)` 및 `fgrep (grep -f)`와 같은 것이 있습니다. 다루지 않은 정보에 대해서는 [여기에서 `grep` 메뉴얼](https://www.gnu.org/software/grep/manual/ "grep manual")을 참조하십시오.

`grep` 명령어의 사용법은 다음과 같습니다:

```text
grep [OPTIONS] PATTERN [FILE...]
grep [OPTIONS] -e PATTERN ... [FILE...]
grep [OPTIONS] -f FILE ... [FILE...]
```

옵션은 주로 네 가지 부분으로 나뉩니다:

- 매치 제어
- 출력 제어
- 컨텐츠 라인 컨트롤
- 디렉토리 또는 파일 제어

매치 제어：

| 옵션                                        | description                                        |
| ----------------------------------------- | -------------------------------------------------- |
| -E (--extended-regexp) | ERE 활성화                                            |
| -P (--perl-regexp)     | PCRE 활성화                                           |
| -G (--basic-regexp)    | 기본적으로 BRE 활성화                                      |
| -e (--regexp=PATTERN)  | 패턴 맞추기에서는 여러 개의 -e 옵션을 지정할 수 있습니다. |
| -i                                        | 무시 케이스                                             |
| -w                                        | 전체 단어 정확히 일치                                       |
| -f FILE                                   | FILE에서 패턴을 한 줄씩 가져옵니다.             |
| -x                                        | 전체 줄을 대상으로한 패턴 매칭                                  |
| -v                                        | 일치하지 않는 내용 행을 선택하세요.               |

출력 제어:

| 옵션     | description                                                                          |
| :----- | :----------------------------------------------------------------------------------- |
| -m NUM | 처음 몇 개의 일치 결과 출력                                                                     |
| -n     | 출력에 라인 번호 표시                                                                         |
| -H     | 여러 파일의 파일 내용을 짝 맞출 때, 줄의 처음에 파일 이름을 표시합니다. 기본 설정입니다. |
| -h     | 여러 파일의 파일 내용을 일치할 때, 라인 시작 부분에 파일 이름 표시하지 않음                                         |
| -o     | 일치하는 콘텐츠만 출력하고 전체 라인을 출력하지 않음                                                        |
| -q     | 정상 정보 출력하지 않음                                                                        |
| -s     | 오류 메시지 출력하지 않음                                                                       |
| -r     | 디렉토리에 대한 재귀적 매칭                                                                      |
| -c     | 사용자 콘텐츠 기반으로 각 파일에 일치하는 라인 수 출력                                                      |

콘텐트 라인 제어:

| 옵션     | description                                  |
| :----- | :------------------------------------------- |
| -B NUM | 일치하는 라인 이전의 NUM 줄의 선행 컨텍스트 출력                |
| -A NUM | 매칭된 줄 뒤의 NUM 줄의 컨텍스트를 출력합니다. |
| -C NUM | 출력 컨텍스트의 NUM 줄 출력                            |

디렉토리 또는 파일 제어:

| 옵션                                          | description                                                                                                                                                                                                                                                                                                                             |
| :------------------------------------------ | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| --include=FILE_PATTERN | FILE_PATTERN과 일치하는 파일만 검색. 파일 이름에 대한 와일드카드 문자 지원: \*, ?, [], [^], [-], {..}, {,}       |
| --exclude=FILE_PATTERN | FILE_PATTERN과 일치하는 파일 및 디렉토리 제외. 파일 이름에 대한 와일드카드 문자 지원: \*, ?, [], [^], [-], {..}, {,} |
| --exclude-dir=PATTERN                       | 지정된 디렉토리 이름 제외. 디렉토리 이름에 대한 와일드카드 문자 지원: \*, ?, [], [^], [-], {..}, {,}                                     |
| --exclude-from=FILE                         | 파일 내용에서 지정된 디렉토리 제외.                                                                                                                                                                                                                                                                                                    |

## 사용 사례

1. -f 옵션과 -o 옵션

    ```bash
    Shell > cat /root/a
    abcdef
    123456
    338922549
    24680
    hello world
    
    Shell > cat /root/b
    12345
    test
    world
    aaaaa
    
    # 파일 b의 각 라인을 일치 패턴으로 처리하고 파일 a와 일치하는 라인을 출력합니다.
    Shell > grep -f /root/b /root/a
    123456
    hello world
    
    Shell > grep -f /root/b /root/a -o
    12345
    world
    ```

2. 여러 패턴 일치 (옵션 -e 사용)

    ```bash
    Shell > echo -e "a\nab\nbc\nbcde" | grep -e 'a' -e 'cd'
    a
    ab
    bcde
    ```

   or:

    ```bash
    Shell > echo -e "a\nab\nbc\nbcde" | grep -E "a|cd"
    a
    ab
    bcde
    ```

3. 설정 파일에서 공백 라인과 주석 라인 제거

    ```bash
    Shell > grep -v -E "^$|^#" /etc/chrony.conf
    server ntp1.tencent.com iburst
    server ntp2.tencent.com iburst
    server ntp3.tencent.com iburst
    server ntp4.tencent.com iburst
    driftfile /var/lib/chrony/drift
    makestep 1.0 3
    rtcsync
    keyfile /etc/chrony.keys
    leapsectz right/UTC
    logdir /var/log/chrony
    ```

4. 일치하는 모든 결과 중 상위 5개 출력

    ```bash
    Shell > seq 1 20 | grep -m 5 -E "[0-9]{2}"
    10
    11
    12
    13
    14
    ```

   or:

    ```bash
    Shell > seq 1 20 | grep -m 5  "[0-9]\{2\}"
    10
    11
    12
    13
    14
    ```

5. -B 옵션과 -A 옵션

    ```bash
    Shell > seq 1 20 | grep -B 2 -A 3 -m 5 -E "[0-9]{2}"
    8
    9
    10
    11
    12
    13
    14
    15
    16
    17
    ```

6. -C 옵션

    ```bash
    Shell > seq 1 20 | grep -C 3 -m 5 -E "[0-9]{2}"
    7
    8
    9
    10
    11
    12
    13
    14
    15
    16
    17
    ```

7. -c 옵션

    ```bash
    Shell > cat /etc/ssh/sshd_config | grep  -n -i -E "port"
    13:# 포트를 SELinux 시스템에서 변경하려면 다음과 같이 말해야 합니다.
    15:# semanage port -a -t ssh_port_t -p tcp #PORTNUMBER
    17:#Port 22
    99:# 경고: 'UsePAM no'는 RHEL에서 지원되지 않으며 여러 문제를 일으킬 수 있습니다.
    105:#GatewayPorts no
    
    Shell > cat /etc/ssh/sshd_config | grep -E -i "port" -c
    5
    ```

8. -v 옵션

    ```bash
    Shell > cat /etc/ssh/sshd_config | grep -i -v -E "port" -c
    140
    ```

9. 디렉토리 내에서 문자열과 일치하는 파일 필터링 (하위 디렉토리의 파일 제외)

    ```bash
    Shell > grep -i -E "port" /etc/n*.conf -n
    /etc/named.conf:11:     listen-on port 53 { 127.0.0.1; };
    /etc/named.conf:12:     listen-on-v6 port 53 { ::1; };
    /etc/nsswitch.conf:32:# winbind                 Use Samba winbind support
    /etc/nsswitch.conf:33:# wins                    Use Samba wins support
    ```

10. 디렉토리 내에서 문자열과 일치하는 파일 필터링 (하위 디렉토리의 파일 또는 디렉토리 포함 또는 제외)

    여러 파일을 포함하는 구문:

    ```bash
    Shell > grep -n -i -r -E  "port" /etc/ --include={0..20}_*
    /etc/grub.d/20_ppc_terminfo:26:export TEXTDOMAIN=grub
    /etc/grub.d/20_ppc_terminfo:27:export TEXTDOMAINDIR=/usr/share/locale
    /etc/grub.d/20_linux_xen:26:export TEXTDOMAIN=grub
    /etc/grub.d/20_linux_xen:27:export TEXTDOMAINDIR="${datarootdir}/locale"
    /etc/grub.d/20_linux_xen:46:# Default to disabling partition uuid support to maintian compatibility with
    /etc/grub.d/10_linux:26:export TEXTDOMAIN=grub
    /etc/grub.d/10_linux:27:export TEXTDOMAINDIR="${datarootdir}/locale"
    /etc/grub.d/10_linux:47:# Default to disabling partition uuid support to maintian compatibility with

    Shell > grep -n -i -r -E  "port" /etc/ --include={{0..20}_*,sshd_config} -c
    /etc/ssh/sshd_config:5
    /etc/grub.d/20_ppc_terminfo:2
    /etc/grub.d/10_reset_boot_success:0
    /etc/grub.d/12_menu_auto_hide:0
    /etc/grub.d/20_linux_xen:3
    /etc/grub.d/10_linux:3
    ```

    만약 단일 디렉토리를 제외하려면 다음 구문을 사용합니다:

    ```bash
    Shell > grep -n -i -r -E  "port" /etc/ --exclude-dir=selin[u]x
    ```

    다수의 디렉토리를 제외하려면 다음과 같은 구문을 사용합니다:

    ```bash
    Shell > grep -n -i -r -E  "port" /etc/ --exclude-dir={selin[u]x,"profile.d",{a..z}ki,au[a-z]it}
    ```

    단일 파일을 제외하려면 다음과 같은 구문을 사용합니다:

    ```bash
    Shell > grep -n -i -r -E  "port" /etc/ --exclude=sshd_config
    ```

    다수의 파일을 제외하려면 다음과 같은 구문을 사용합니다:

    ```bash
    Shell > grep -n -i -r -E  "port" /etc/ --exclude={ssh[a-z]_config,*.conf,services}
    ```

    동시에 여러 파일과 디렉토리를 제외하려면 다음과 같은 구문을 사용합니다:

    ```bash
    Shell > grep -n -i -r -E  "port" /etc/ --exclude-dir={selin[u]x,"profile.d",{a..z}ki,au[a-z]it} --exclude={ssh[a-z]_config,*.conf,services,[0-9][0-9]*}
    ```

11. 현재 컴퓨터의 모든 IPv4 주소 세기

    ```bash
    Shell > ip a | grep -o  -E "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" | grep -v -E "127|255"
    192.168.100.3
    ```
