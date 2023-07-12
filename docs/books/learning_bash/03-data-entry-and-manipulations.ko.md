---
title: Bash - 데이터 입력 및 조작
author: Antoine Le Morvan
contributors: Steven Spencer
tested_with: 8.5
tags:
  - 교육
  - bash 스크립팅
  - bash
---

# Bash - 데이터 입력 및 조작

이 장에서는 스크립트가 사용자와 상호 작용하고 데이터를 조작하는 방법을 배웁니다.

****

**목적**: 이 문서에서는 다음을 수행하는 방법에 대해 알아볼 것 입니다:

:heavy_check_mark: 사용자로부터 입력 받기 :heavy_check_mark: 데이터 입력 조작하기 :heavy_check_mark: 스크립트 내에서 인수 사용하기  
:heavy_check_mark: 위치 매개변수 관리하기

:checkered_flag: **linux**, **스크립트**, **bash**, **변수**

**지식**: :star: :star:  
**복잡성**: :star: :star:

**소요 시간**: 10분

****

스크립트의 목적에 따라, 실행되거나 실행 중에 정보를 전달할 필요가 있을 수 있습니다. 이 정보는 스크립트가 작성될 때 알려지지 않지만, 파일에서 추출하거나 사용자에 의해 입력될 수 있습니다. 또한 스크립트 명령이 입력될 때 인수의 형태로 이 정보를 전달하는 것도 가능합니다. 이것은 많은 Linux 명령어가 동작하는 방식입니다.

## `read` 명령

`read` 명령을 사용하면 문자열을 입력하고 변수에 저장할 수 있게 해줍니다.

read 명령의 구문:

```
read [-n X] [-p] [-s] [variable]
```

아래의 첫 번째 예에서는 "name"과 "firstname"이라는 두 가지 변수를 입력하라는 메시지가 표시되지만 메시지가 표시되지 않으므로 이러한 경우임을 미리 알고 있어야 합니다. 이 특정 입력에서 각 변수 입력은 공백으로 구분됩니다.  두 번째 예제는 "name" 변수를 프롬프트 텍스트와 함께 입력하도록 요구합니다.

```
read name firstname
read -p "Please type your name: " name
```

| 옵션   | 관찰               |
| ---- | ---------------- |
| `-p` | 프롬프트 메시지를 표시합니다. |
| `-n` | 입력할 문자 수를 제한합니다. |
| `-s` | 입력을 숨깁니다.        |

`-n` 옵션을 사용할 때, 지정된 문자 수 이후에 셸은 자동으로 입력을 확인합니다. 사용자는 <kbd>ENTER</kbd> 키를 누를 필요가 없습니다.

```
read -n5 name
```

`read` 명령을 사용하면 사용자가 정보를 입력하는 동안 스크립트 실행을 중단할 수 있습니다. 사용자의 입력은 하나 이상의 미리 정의된 변수에 할당된 단어로 분류됩니다. 단어는 필드 구분 기호로 구분된 문자열입니다.

입력의 끝은 <kbd>ENTER</kbd> 키를 눌러 결정됩니다.

입력이 확인된 후, 각 단어는 사전 정의된 변수에 저장됩니다.

단어의 구분은 필드 구분 문자로 정의됩니다. 이 구분 기호는 시스템 변수 `IFS`(**Internal Field Separator**)에 저장됩니다.

```
set | grep IFS
IFS=$' \t\n'
```

기본적으로 IFS에는 공백, 탭 및 줄 바꿈이 포함됩니다.

변수를 지정하지 않고 사용할 경우, 이 명령어는 스크립트를 일시 중지시킵니다. 입력이 확인될 때 스크립트는 실행을 계속합니다.

이것은 디버깅할 때 스크립트를 일시 중지시키거나 사용자에게 <kbd>ENTER</kbd>를 눌러 계속할 것을 요구하기 위해 사용됩니다.

```
echo -n "Press [ENTER] to continue..." read
```

## `cut` 명령

cut 명령을 사용하면 파일이나 스트림에서 열을 분리하여 분리된 열을 가져올 수 있습니다.

cut 명령의 구문:

```
cut [-cx] [-dy] [-fz] file
```

cut 명령 사용 예:

```
cut -d: -f1 /etc/passwd
```

| 옵션   | 설명                     |
| ---- | ---------------------- |
| `-c` | 선택할 문자의 시퀀스 번호를 지정합니다. |
| `-d` | 필드 구분 기호를 지정합니다.       |
| `-f` | 선택할 열의 순서 번호를 지정합니다.   |

이 명령의 주요 관심사는 예를 들어 `grep` 명령 및 `|` 파이프와 같이 사용할 때 발생합니다.

* `grep` 명령은 "수직"으로 작동하여 파일의 모든 줄 중 하나를 분리합니다.
* 두 명령의 조합으로 **파일에서 특정 필드를 분리**할 수 있습니다.

예시:

```
grep "^root:" /etc/passwd | cut -d: -f3
0
```

!!! 참고사항

    동일한 필드 구분자를 사용하는 단일 구조의 설정 파일은 이 명령어 조합의 이상적인 대상입니다.

## `tr` 명령

`tr` 명령을 사용하면 문자열을 변환할 수 있습니다.

`tr` 명령어의 구문:

```
tr [-csd] String1 String2
```

| 옵션   | 관찰                                            |
| ---- | --------------------------------------------- |
| `-c` | 첫 번째 문자열에 지정되지 않은 모든 문자는 두 번째 문자열의 문자로 변환됩니다. |
| `-d` | 지정된 문자를 삭제합니다.                                |
| `-s` | 지정된 문자를 단일 단위로 줄입니다.                          |

`tr` 명령을 사용하는 예는 다음과 같습니다. `grep`을 사용하여 root의 `passwd` 파일 항목을 반환하면 다음과 같은 결과가 나타납니다.

```
grep root /etc/passwd
```
반환값:
```
root:x:0:0:root:/root:/bin/bash
```
이제 `tr` 명령을 사용하고 줄에서 "o를"를 줄입니다.

```
grep root /etc/passwd | tr -s "o"
```
다음을 반환합니다.
```
rot:x:0:0:rot:/rot:/bin/bash
```
## 파일의 이름과 경로 추출

`basename` 명령어는 경로에서 파일의 이름을 추출하는 데 사용됩니다.

`dirname` 명령어는 파일의 상위 경로를 추출하는 데 사용됩니다.

예시:

```
echo $FILE=/usr/bin/passwd
basename $FILE
```
결과는 "passwd"입니다.
```
dirname $FILE
```
결과는 "/usr/bin"입니다.

## 스크립트의 인수

`read` 명령어를 사용하여 정보를 입력하도록 요청하면 사용자가 정보를 입력할 때까지 스크립트 실행이 중단됩니다.

이 방법은 매우 사용자 친화적이지만, 스크립트가 밤에 실행되도록 예약된 경우 제한이 있습니다. 이 문제를 극복하기 위해 원하는 정보를 인수로 주입할 수 있습니다.

많은 Linux 명령이 이 원리로 작동합니다.

이 방식의 장점은 스크립트를 실행한 후에는 완료하기 위해 인간의 개입이 필요하지 않다는 것입니다.

주요 단점은 사용자가 스크립트의 구문에 대해 경고를 받아 오류를 피하기 위해 스크립트의 구문에 대해 알려져야 한다는 것입니다.

인수는 스크립트 명령어가 입력될 때 채워집니다. 인수는 공백으로 구분됩니다.

```
./script argument1 argument2
```

한번 실행된 후에는 스크립트가 입력된 인수를 미리 정의된 변수인 `위치 변수`에 입력된 인수를 저장합니다.

이러한 변수는 일반 변수와 마찬가지로 스크립트에서 사용할 수 있지만 할당할 수는 없습니다.

* 사용되지 않은 위치 변수가 존재하지만 비어 있습니다.
* 위치 변수는 항상 같은 방식으로 정의됩니다.

| 변수           | 관찰                        |
| ------------ | ------------------------- |
| `$0`         | 입력한 스크립트의 이름을 포함합니다.      |
| `$1`에서 `$9`  | 1~9번째 인수의 값을 포함합니다.       |
| `${x}`       | 9보다 큰 `x` 인수 값을 포함합니다.    |
| `$#`         | 전달된 인수의 개수를 포함합니다.        |
| `$*` 또는 `$@` | 전달된 모든 인수를 하나의 변수에 포함합니다. |

예시:

```
#!/usr/bin/env bash
#
# Author : Damien dit LeDub
# Date : september 2019
# Version 1.0.0 : Display the value of the positional arguments
# From 1 to 3

# 필드 구분 기호는 "," 또는 공백입니다. # Important to see the difference in $* and $@
IFS=", "

# 화면에 텍스트 표시:
echo "The number of arguments (\$#) = $#"
echo "The name of the script  (\$0) = $0"
echo "The 1st argument        (\$1) = $1"
echo "The 2nd argument        (\$2) = $2"
echo "The 3rd argument        (\$3) = $3"
echo "All separated by IFS    (\$*) = $*"
echo "All without separation  (\$@) = $@"
```

결과적으로:

```
$ ./arguments.sh one two "tree four"
The number of arguments ($#) = 3
The name of the script  ($0) = ./arguments.sh
The 1st argument        ($1) = one
The 2nd argument        ($2) = two
The 3rd argument        ($3) = tree four
All separated by IFS    ($*) = one,two,tree four
All without separation  ($@) = one two tree four
```

!!! 경고

    `$@`와 `$*`의 차이에 주의해야 합니다. 이는 인수 저장 형식에서 발생하는 차이입니다:

    * `$*` : `"$1 $2 $3 ..."` 형식으로 인수가 포함됩니다.
    * `$@` : `"$1" "$2" "$3" ...` 형식으로 인수가 포함됩니다.

    차이가 보이는 것은 `IFS` 환경 변수를 수정하는 것입니다.

### Shift 명령

shift 명령을 사용하면 위치 변수를 이동할 수 있습니다.

위치 변수에 shift 명령어가 영향을 미치는지 확인하기 위해 이전 예시를 수정해 보겠습니다:

```
#!/usr/bin/env bash
#
# Author : Damien dit LeDub
# Date : september 2019
# Version 1.0.0 : Display the value of the positional arguments
# From 1 to 3

# 필드 구분자는 "," 또는 공백입니다. # $*과 $@의 차이를 보기 위해 중요합니다. IFS=", "

# 화면에 텍스트를 표시합니다:

echo "The number of arguments (\$#) = $#"
echo "The 1st argument        (\$1) = $1"
echo "The 2nd argument        (\$2) = $2"
echo "The 3rd argument        (\$3) = $3"
echo "All separated by IFS    (\$*) = $*"
echo "All without separation  (\$@) = $@"

shift 2
echo ""
echo "-------- SHIFT 2 ----------------"
echo ""

echo "The number of arguments (\$#) = $#"
echo "The 1st argument        (\$1) = $1"
echo "The 2nd argument        (\$2) = $2"
echo "The 3rd argument        (\$3) = $3"
echo "All separated by IFS    (\$*) = $*"
echo "All without separation  (\$@) = $@"
```

결과적으로:

```
./arguments.sh one two "tree four"
The number of arguments ($#) = 3
The 1st argument        ($1) = one
The 2nd argument        ($2) = two
The 3rd argument        ($3) = tree four
All separated by IFS    ($*) = one,two,tree four
All without separation  ($@) = one two tree four

-------- SHIFT 2 ----------------

The number of arguments ($#) = 1
The 1st argument        ($1) = tree four
The 2nd argument        ($2) =
The 3rd argument        ($3) =
All separated by IFS    ($*) = tree four
All without separation  ($@) = tree four
```

보시는 바와 같이 `shift` 명령어는 인수의 위치를 "왼쪽"으로 이동시켜 처음 2개를 제거했습니다.

!!! 경고

    `shift` 명령을 사용할 때, `$#` 및 `$*` 변수도 그에 맞게 수정됩니다.

### The `set` 명령

`set` 명령은 문자열을 위치 변수로 분할합니다.

set 명령의 구문:

```
set [value] [$variable]
```

예시:

```
$ set one two three
$ echo $1 $2 $3 $#
one two three 3
$ variable="four five six"
$ set $variable
$ echo $1 $2 $3 $#
four five six 3
```

이제 이전에 보았던 위치 변수를 사용할 수 있습니다.
