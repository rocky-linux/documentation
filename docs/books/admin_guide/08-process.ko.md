---
title: 프로세스 관리
---

# 프로세스 관리

이 페이지에서는 프로세스 작업 방법을 배웁니다.

****

**목표**: 이 문서에서는 미래의 Linux 관리자가 다음을 수행하는 방법을 배웁니다.

:heavy_check_mark: 프로세스의 `PID` 및 `PPID` 인식   
:heavy_check_mark: 프로세스 보기 및 검색 :heavy_check_mark: 프로세스 관리

:checkered_flag: **프로세스**, **linux**

**지식**: :star: :star:   
**복잡성**: :star:

**소요 시간**: 20분

****

## 개요

운영 체제는 프로세스로 구성됩니다. 이러한 프로세스는 특정한 순서로 실행되며 서로 관련되어 있습니다. 사용자 환경에 초점을 맞춘 프로세스와 하드웨어 환경에 초점을 맞춘 프로세스의 두 가지 범주가 있습니다.

프로그램이 실행되면 시스템은 프로그램 데이터와 코드를 메모리에 배치하고 **런타임 스택**을 생성하여 프로세스를 생성합니다. 따라서 프로세스는 프로그램의 인스턴스로, 연관된 프로세서 환경(순서 카운터, 레지스터 등)과 메모리 환경을 갖습니다.

각 프로세스에는 다음이 있습니다.

* a _PID_: _**P**rocess **ID**entifier_, 고유한 프로세스 식별자;
* a _PPID_: _**P**arent **P**rocess **ID**entifier_, 부모 프로세스의 고유 식별자.

연속적인 계열화를 통해 `init` 프로세스는 모든 프로세스의 부모입니다.

* 프로세스는 항상 부모 프로세스에 의해 생성됩니다.
* 부모 프로세스는 여러 자식 프로세스를 가질 수 있습니다.

프로세스 간에 부모/자식 관계가 있습니다. 자식 프로세스는 부모 프로세스가 _fork()_ 원시 함수를 호출하고 자신의 코드를 복제하여 생성한 결과입니다. 자식의 _PID_는 대화할 수 있도록 부모 프로세스로 반환됩니다. 각 자식에는 부모의 식별자인 _PPID_를 가지고 있습니다.

_PID_ 번호는 실행 당시의 프로세스를 나타냅니다. 프로세스가 완료되면 다른 프로세스에서 번호를 다시 사용할 수 있습니다. 동일한 명령을 여러 번 실행하면 매번 다른 _PID_가 생성됩니다.<!-- TODO !\[Parent/child relationship between processes\](images/FON-050-001.png) -->!!!

<!-- TODO !\[Parent/child relationship between processes\](images/FON-050-001.png) -->

!!! !!!

    프로세스를 _threads_와 혼동해서는 안 됩니다. 각 프로세스에는 고유한 메모리 컨텍스트(자원 및 주소 공간)가 있으며 동일한 프로세스의 _threads_는 이 동일한 컨텍스트를 공유합니다.

## 프로세스 보기

`ps` 명령은 실행 중인 프로세스의 상태를 표시합니다.
```
ps [-e] [-f] [-u login]
```

예시:
```
# ps -fu root
```

| 옵션         | 설명                |
| ---------- | ----------------- |
| `-e`       | 모든 프로세스를 표시합니다.   |
| `-f`       | 추가 정보를 표시합니다.     |
| `-u` login | 사용자의 프로세스를 표시합니다. |

일부 추가 옵션:

| 옵션                    | 설명                       |
| --------------------- | ------------------------ |
| `-g`                  | 그룹의 프로세스를 표시합니다.         |
| `-t tty`              | 터미널에서 실행 중인 프로세스를 표시합니다. |
| `-p PID`              | 프로세스 정보를 표시합니다.          |
| `-H`                  | 정보를 트리 구조로 표시합니다.        |
| `-I`                  | 추가 정보를 표시합니다.            |
| `--sort COL`          | 열에 따라 결과를 정렬합니다.         |
| `--headers`           | 터미널의 각 페이지에 헤더를 표시합니다.   |
| `--format "%a %b %c"` | 출력 표시 형식을 사용자 지정합니다.     |

옵션을 지정하지 않으면 `ps` 명령은 현재 터미널에서 실행 중인 프로세스만 표시합니다.

결과는 열로 표시됩니다:

```
# ps -ef
UID  PID PPID C STIME  TTY TIME      CMD
root 1   0    0 Jan01  ?   00:00/03 /sbin/init
```

| 열       | 설명           |
| ------- | ------------ |
| `UID`   | 소유자 사용자.     |
| `PID`   | 프로세스 식별자.    |
| `PPID`  | 부모 프로세스 식별자. |
| `C`     | 프로세스의 우선 순위. |
| `STIME` | 실행 날짜 및 시간.  |
| `TTY`   | 실행 터미널.      |
| `TIME`  | 처리 기간.       |
| `CMD`   | 명령이 실행됨.     |

컨트롤의 동작은 완전히 사용자 지정할 수 있습니다.

```
# ps -e --format "%P %p %c %n" --sort ppid --headers
 PPID   PID COMMAND          NI
    0     1 systemd           0
    0     2 kthreadd          0
    1   516 systemd-journal   0
    1   538 systemd-udevd     0
    1   598 lvmetad           0
    1   643 auditd          . -4
    1   668 rtkit-daemon      1
    1   670 sssd              0
```

## 프로세스 유형

사용자 프로세스:

* 사용자와 연결된 터미널에서 시작됩니다.
* 요청이나 데몬을 통해 리소스에 액세스합니다.

따라서 시스템 프로세스를 데몬이라고 합니다 (_**D**isk **A**nd **E**xecution **MON**itor_).

* 시스템에 의해 시작됩니다.
* 터미널과 연결되어 있지 않으며 시스템 사용자(종종 `root`)가 소유합니다.
* 부팅 시 로드되고 메모리에 상주하며 호출을 기다리고 있습니다.
* 일반적으로 프로세스 이름과 관련된 문자 `d`로 식별됩니다.

시스템 프로세스(_데몬_):

## 허가 및 권리

명령이 실행되면 사용자의 자격 증명이 생성된 프로세스로 전달됩니다.

따라서 기본적으로 실제 프로세스의 `UID` 및 `GID`는 **실제** `UID` 및 `GID`와 동일합니다(명령을 실행한 사용자의 `UID` 및 `GID`).

명령에 `SUID`(및/또는 `SGID`)가 설정되면 실제 `UID`(및/또는 `GID` >)는 명령의 소유자(및/또는 소유자 그룹)의 소유자가 되며 더 이상 명령을 실행한 사용자 또는 사용자 그룹의 소유자가 아닙니다. 따라서 효과적인 **UID**는 **다른** 것입니다.

파일에 액세스할 때마다 시스템은 유효 식별자에 따라 프로세스의 권한을 확인합니다.

## 프로세스 관리

실행 중인 다른 프로세스를 손상시키고 멀티태스킹을 방지하기 때문에 프로세스를 무기한 실행할 수 없습니다.

따라서 사용 가능한 총 처리 시간은 작은 범위로 나뉘며, 각 프로세스(우선 순위 포함)는 순차적인 방식으로 프로세서에 액세스합니다. 이 프로세스는 여러 상태에서 실행되는 동안 여러 상태를 취합니다.

* 준비: 프로세스의 가용성을 기다립니다.
* 실행 중: 프로세서에 액세스합니다.
* 일시 중단: I/O(입력/출력)를 기다립니다.
* 중지됨: 다른 프로세스의 신호를 기다리는 중입니다.
* 좀비: 파괴 요청;
* 죽음: 프로세스의 아버지가 아들을 죽입니다.

프로세스 순서의 끝은 다음과 같습니다:

1. 열린 파일 닫기
2. 사용된 메모리 해제
3. 부모 및 자식 프로세스에 신호 전송

부모 프로세스가 종료되면 해당 자식 프로세스를 고아라고 합니다. 그런 다음 그들을 `init` 프로세스에게 채택되어 종료됩니다.

### 프로세스의 우선순위

프로세서는 각 프로세스가 일정량의 프로세서 시간을 점유하도록 시분할로 작동합니다.

프로세스의 기본 우선 순위는 **0**입니다.

프로세스는 우선 순위에 따라 분류되며, 우선 순위 값은 **-20**(가장 높은 우선 순위)에서 **+19**(가장 낮은 우선 순위)까지 변동됩니다.

### 작동 모드

프로세스는 다음 두 가지 방법으로 실행할 수 있습니다.

* **synchronous - 동기적 방식**: 명령 실행 중에 사용자는 쉘에 대한 액세스를 잃습니다. 프로세스 실행이 끝나면 명령 프롬프트가 다시 나타납니다.
* **asynchronous - 비동기적 방식**: 프로세스는 백그라운드에서 처리됩니다. 명령 프롬프트가 즉시 다시 표시됩니다.

asynchronous(비동기) 모드의 제약 조건:

* 명령 또는 스크립트는 키보드 입력을 기다리지 않아야 합니다.
* 명령 또는 스크립트는 화면에 어떤 결과도 반환해서는 안 됩니다.
* 열

## 프로세스 관리 제어

### `kill` 명령

`kill` 명령은 프로세스에 중지 신호를 보냅니다.

```
kill [-signal] PID
```

예시:

```
$ kill -9 1664
````$ kill -9 1664`프로세스 중단(<kbd>CTRL</kdb> + <kdb>D</kdb>)</td> </tr></td> </tr> 

<tr>
  <td>
    <code>15</code>
  </td>
  
  <td>
    <em x-id="4">SIGTERM</em>
  </td>
  
  <td>
    프로세스의 완전한 종료
  </td>
</tr>

<tr>
  <td>
    <code>18</code>
  </td>
  
  <td>
    <em x-id="4">SIGCONT</em>
  </td>
  
  <td>
    프로세스 다시 시작
  </td>
</tr>

<tr>
  <td>
    <code>19</code>
  </td>
  
  <td>
    <em x-id="4">SIGSTOP</em>
  </td>
  
  <td>
    프로세스를 일시 중지
  </td>
</tr></tbody> </table> 

<p spaces-before="0">
  신호는 프로세스 간의 통신 수단입니다. <code>kill</code> 명령은 프로세스에 신호를 보냅니다.
</p>

<p spaces-before="0">
  !!! !!!
</p>

<pre><code>다음 명령을 입력하면 `kill` 명령에서 고려한 전체 신호 목록을 사용할 수 있습니다.
</code></pre>

<pre><code>    $ man 7 Signal
</code></pre>



<h3 spaces-before="0">
  <code>nohup</code> 명령
</h3>

<p spaces-before="0">
  <code>nohup</code>을 사용하면 연결과 독립적으로 프로세스를 실행할 수 있게 합니다.
</p>

<pre><code>nohup 명령
</code></pre>

<p spaces-before="0">
  예시:
</p>

<pre><code>$ nohup myprogram.sh 0&lt;/dev/null &
</code></pre>

<p spaces-before="0">
  <code>nohup</code>은 사용자가 로그아웃할 때 전송되는 <code>SIGHUP</code> 신호를 무시합니다.
</p>

<p spaces-before="0">
  !!! !!!
</p>

<pre><code>`nohup`은 표준 출력과 오류를 처리하지만 표준 입력은 처리하지 않으므로 이 입력을 `/dev/null`로 리디렉션합니다.
</code></pre>



<h3 spaces-before="0">
  [CTRL] + [Z]
</h3>

<p spaces-before="0">
  <kbd>CTRL</kbd> + <kbd>Z</kbd> 키를 동시에 누르면 동기 프로세스가 일시적으로 중단됩니다. 방금 일시 중지된 프로세스의 번호가 표시된 후에 프롬프트에 액세스할 수 있습니다.
</p>



<h3 spaces-before="0">
  <code>&</code> 설명
</h3>

<p spaces-before="0">
  <code>&</code> 문은 명령을 asynchronous(이 명령은 <emx-id="4">job</em>이라고 불립니다.)으로 실행하고 <em x-id="4">작업</em>의 수를 표시합니다. 프롬프트에 대한 액세스가 반환됩니다.
</p>

<p spaces-before="0">
  예시:
</p>

<pre><code>$ time ls -lR / &gt; list.ls 2&gt;/dev/null &
$ fg 1
time ls -lR / &gt; list.ls 2/dev/null
</code></pre>

<p spaces-before="0">
  <em x-id="4">작업</em> 번호는 백그라운드 처리 중에 얻어지며, <code>PID</code> 번호 뒤에 대괄호 안에 표시됩니다.
</p>



<h3 spaces-before="0">
  <code>fg</code> and <code>bg</code> 명령
</h3>

<p spaces-before="0">
  <code>fg</code> 명령은 프로세스를 포그라운드에 이동시킵니다.
</p>

<pre><code>$ time ls -lR / &gt; list.ls 2&gt; /dev/null &
[1] 15430
$
</code></pre>

<p spaces-before="0">
  <code>bg</code> 명령은 프로세스를 백그라운드로 이동시킵니다.
</p>

<pre><code>[CTRL]+[Z]
^Z
[1]+ Stopped
$ bg 1
[1] 15430
$
</code></pre>

<p spaces-before="0">
  그것이 <code>&</code> 인수로 생성되었을 때 백그라운드에 놓였는지 또는 나중에 <kbd>CTRL</kbd> +<kbd>Z</kbd> 키로 만들어졌는지에 관계없이 프로세스는 <code>fg</code> 명령과 해당 작업 번호를 사용하여 프로세스를 다시 포그라운드로 가져올 수 있습니다.
</p>



<h3 spaces-before="0">
  <code>jobs</code> 명령
</h3>

<p spaces-before="0">
  <code>jobs</code> 명령은 백그라운드에서 실행 중인 프로세스 목록을 표시하고 해당 작업 번호를 지정합니다.
</p>

<p spaces-before="0">
  예시:
</p>

<pre><code>$ jobs
[1]- Running    sleep 1000
[2]+ Running    find / &gt; arbo.txt
</code></pre>

<p spaces-before="0">
  열은 다음을 나타냅니다.
</p>

<ol start="1">
  <li>
    직업 번호;
  </li>
  
  <li>
    프로세스가 실행되는 순서
  </li>
</ol>

<ul>
  <li>
    a <code>+</code> : 이 프로세스는 <code>fg</code> 또는 <code>bg</code> 로 기본적으로 실행되는 다음 프로세스입니다.
  </li>
  <li>
    a <code>-</code> : 이 프로세스는 <code>+</code>를 취하는 다음 프로세스입니다. <code>+</code>
  </li>
</ul>

<ol start="3">
  <li>
    <em x-id="4">실행 중</em>(실행 중인 프로세스) 또는 <em x-id="4">중지됨</em>(일시 중단된 프로세스).  
  </li>
  
  <li>
    명령
  </li>
</ol>



<h3 spaces-before="0">
  <code>nice</code> and <code>renice</code> 명령
</h3>

<p spaces-before="0">
  <code>nice</code> 명령을 사용하면 우선 순위를 지정하여 명령을 실행할 수 있습니다.
</p>

<pre><code>nice 우선 순위 명령
</code></pre>

<p spaces-before="0">
  예시:
</p>

<pre><code>$ nice -n+15 find / -name "file"
</code></pre>

<p spaces-before="0">
  <code>root</code>와 달리 표준 사용자는 프로세스의 우선 순위만 낮출 수 있습니다. +0에서 +19 사이의 값만 허용됩니다.
</p>

<p spaces-before="0">
  !!! !!!
</p>

<pre><code>이 마지막 제한은 `/etc/security/limits.conf` 파일을 수정하여 사용자별 또는 그룹별로 해제할 수 있습니다.
</code></pre>

<p spaces-before="0">
  <code>renice</code> 명령을 사용하면 실행 중인 프로세스의 우선 순위를 변경할 수 있습니다.
</p>

<pre><code>renice priority [-g GID] [-p PID] [-u UID]
</code></pre>

<p spaces-before="0">
  예시:
</p>

<pre><code>$ renice +15 -p 1664
</code></pre>
<table spaces-before="0">
  <tr>
    <th>
      옵션
    </th>
    
    <th>
      설명
    </th>
  </tr>
  
  <tr>
    <td>
      <code>-g</code>
    </td>
    
    <td>
      프로세스 소유자 그룹의 <code>GID</code>.
    </td>
  </tr>
  
  <tr>
    <td>
      <code>-p</code>
    </td>
    
    <td>
      프로세스의 <code>PID</code>.
    </td>
  </tr>
  
  <tr>
    <td>
      <code>-u</code>
    </td>
    
    <td>
      프로세스 소유자의 <code>UID</code>.
    </td>
  </tr>
</table>

<p spaces-before="0">
  <code>renice</code> 명령은 이미 실행 중인 프로세스에서 작동합니다. 따라서 특정 프로세스뿐만 아니라 사용자 또는 그룹에 속한 여러 프로세스의 우선 순위를 변경할 수 있습니다.
</p>

<p spaces-before="0">
  !!! !!!
</p>

<pre><code>`xargs` 명령 과 결합된 `pidof` 명령을 사용하면 단일 명령에 새로운 우선 순위를 적용할 수 있습니다(자세한 내용은 Advanced Commands 코스 참조).
</code></pre>

<pre><code>    $ pidof sleep | xargs renice 20
</code></pre>



<h3 spaces-before="0">
  <code>top</code> 명령
</h3>

<p spaces-before="0">
  <code>top</code> 명령은 프로세스와 리소스 소비를 표시합니다.
</p>

<pre><code>$ top
PID  USER PR NI ... %CPU %MEM  TIME+    COMMAND
2514 root 20 0       15    5.5 0:01.14   top
</code></pre>

<table spaces-before="0">
  <tr>
    <th>
      열
    </th>
    
    <th>
      개요
    </th>
  </tr>
  
  <tr>
    <td>
      <code>PID</code>
    </td>
    
    <td>
      프로세스 식별자.
    </td>
  </tr>
  
  <tr>
    <td>
      <code>USER</code>
    </td>
    
    <td>
      소유자 사용자.
    </td>
  </tr>
  
  <tr>
    <td>
      <code>PR</code>
    </td>
    
    <td>
      프로세스 우선순위
    </td>
  </tr>
  
  <tr>
    <td>
      <code>NI</code>
    </td>
    
    <td>
      Nice 값.
    </td>
  </tr>
  
  <tr>
    <td>
      <code>%CPU</code>
    </td>
    
    <td>
      프로세서 로드.
    </td>
  </tr>
  
  <tr>
    <td>
      <code>%MEM</code>
    </td>
    
    <td>
      메모리 로드.
    </td>
  </tr>
  
  <tr>
    <td>
      <code>TIME+</code>
    </td>
    
    <td>
      프로세서 사용 시간.
    </td>
  </tr>
  
  <tr>
    <td>
      <code>COMMAND</code>
    </td>
    
    <td>
      실행된 명령.
    </td>
  </tr>
</table>

<p spaces-before="0">
  <code>top</code> 명령을 사용하면 실시간 및 대화식 모드에서 프로세스를 제어할 수 있습니다.
</p>



<h3 spaces-before="0">
  <code>pgrep</code> 과 <code>pkill</code> 명령
</h3>

<p spaces-before="0">
  <code>pgrep</code> 명령은 실행 중인 프로세스에서 프로세스 이름을 검색하고 선택 기준과 일치하는 <em x-id="4">PID</em>를 표준 출력에 표시합니다.
</p>

<p spaces-before="0">
  <code>pkill</code> 명령은 각 프로세스에 지정된 신호(기본적으로 <em x-id="4">SIGTERM</em>)를 보냅니다.
</p>

<pre><code>pgrep process
pkill [-signal] process
</code></pre>

<p spaces-before="0">
  예시:
</p>

<ul>
  <li>
    <code>sshd</code>에서 프로세스 번호 가져오기:
  </li>
</ul>

<pre><code>$ pgrep -u root sshd
</code></pre>

<ul>
  <li>
    <code>tomcat</code> 프로세스 모두 종료하기:
  </li>
</ul>

<pre><code>$ pkill tomcat
</code></pre>
