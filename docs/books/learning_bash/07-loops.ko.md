---
title: Bash - 루프
author: Antoine Le Morvan
contributors: Steven Spencer
tested_with: 8.5
tags:
  - 교육
  - bash 스크립팅
  - bash
---

# Bash - 루프

****

**목적**: 이 문서에서는 다음을 수행하는 방법에 대해 알아볼 것 입니다:

:heavy_check_mark: 루프 사용;

:checkered_flag: **linux**, **스크립트**, **bash** , **루프**

**지식**: :star: :star:  
**복잡성**: :star: :star: :star:

**소요 시간**: 20분

****

bash 셸에서는 **루프**를 사용할 수 있습니다. 이러한 구조를 통해 정적으로 정의된 값, 동적으로 또는 조건에 따라 **명령 블록을 여러 번**(0에서 무한대까지) 실행할 수 있습니다.

* `while`
* `until`
* `for`
* `select`

어떤 루프를 사용하든 반복할 명령은 **단어** `do`와 `done` 사이에 배치됩니다.

## while 조건문 루프 구조

`while` / `do` / `done` 구조는 `while` 뒤에 배치된 명령을 평가합니다.

만약 이 명령이 참이면(`$? = 0`), `do`와 `done` 사이에 있는 명령이 실행됩니다. 그런 다음 스크립트는 명령을 다시 평가하기 위해 처음으로 돌아갑니다.

평가된 명령이 거짓이면(`$? != 0`), 쉘은 완료 후 첫 번째 명령에서 스크립트 실행을 재개합니다.

조건부 루프 구조 `while`의 구문:

```
while command
do
  command if $? = 0
done
```

`while` 조건 구조를 사용하는 예:

```
while [[ -e /etc/passwd ]]
do
  echo "The file exists"
done
```

평가된 명령이 변하지 않는 경우, 반복은 무한하게 되고 쉘이 스크립트 이후에 위치한 명령들을 결코 실행하지 않습니다. 이는 의도적일 수도 있지만, 오류일 수도 있습니다. 따라서 **반복문을 처리하는 명령에 대해 매우 주의해야 하며, 반복문을 벗어나는 방법을 찾아야 합니다**.

`while` 반복문을 벗어나려면 평가되는 명령이 더 이상 true가 아니게 되도록 해야 합니다. 이는 항상 가능하지는 않습니다.

반복문의 동작을 변경하는 명령들이 있습니다:

* `exit`
* `break`
* `continue`

## exit 명령

`exit` 명령은 스크립트 실행을 종료합니다.

`exit` 명령의 구문:

```
exit [n]
```

`exit` 명령의 구문은 다음과 같습니다:

```
bash #  "exit 1" 후에 연결이 끊어지는 것을 피하기 위해
exit 1
echo $?
1
```

`exit` 명령은 스크립트를 즉시 종료합니다. 인수로 반환 코드(`0`에서 `255`까지)를 지정할 수 있습니다. 인수가 주어지지 않으면 스크립트의 마지막 명령의 반환 코드가 `$?` 변수로 전달됩니다.

## `break` / `continue` 명령

`break` 명령을 사용하면 `done` 이후 첫 번째 명령으로 이동하여 루프를 중단할 수 있습니다.

`continue` 명령은 `done` 다음의 첫 번째 명령으로 돌아가 반복문을 다시 시작합니다.

```
while [[ -d / ]]                                                   INT ✘  17s 
do
  echo "Do you want to continue? (yes/no)"
  read ans
  [[ $ans = "yes" ]] && continue
  [[ $ans = "no" ]] && break
done
```

## `true` / `false` 명령

`true` 명령은 항상 `true`를 반환하고 `false` 명령은 항상 `false`를 반환합니다.

```
true
echo $?
0
false
echo $?
1
```

루프의 조건으로 사용되어 무한 루프를 실행하거나 이 루프를 비활성화할 수 있습니다.

예시:

```
while true
do
  echo "Do you want to continue? (yes/no)"
  read ans
  [[ $ans = "yes" ]] && continue
  [[ $ans = "no" ]] && break
done
```

## `until` 조건부 루프 구조

`until` / `do` / `done` 구조는 `until` 뒤에 배치된 명령을 평가합니다.

만약 이 명령이 false(`$? != 0`)라면 `do` 와 `done 사이에 위치한 명령들이 실행됩니다. 스크립트는 다시 처음부터 명령을 평가하기 위해 돌아갑니다.

평가된 명령이 true(`$? = 0`)라면 쉘이 `done` 다음의 첫 번째 명령부터 스크립트의 실행을 계속합니다.

조건부 루프 구조 `until`의 구문은 다음과 같습니다:

```
until command
do
  command if $? != 0
done
```

조건부 루프 구조 `until`의 사용 예제:

```
until [[ -e test_until ]]
do
  echo "The file does not exist"
  touch test_until
done
```

## 대체 선택 구조 `select`

`select` / `do` / `done` 구조는 여러 선택지와 입력 요청이 있는 메뉴를 표시할 수 있게 해줍니다.

리스트의 각 항목은 번호가 지정된 선택지를 가지고 있습니다. 선택지를 입력하면 해당 값이 `select` 다음에 위치한 변수에 할당됩니다(이를 위해 생성된 변수).

그런 다음 이 값을 사용하여 `do`와 `done` 사이에 있는 명령을 실행합니다.

* 변수 `PS3`에는 선택지 입력을 위한 알림이 저장됩니다.
* 변수 `REPLY`는 선택지의 번호를 반환합니다.

반복문을 종료하려면 `break` 명령이 필요합니다.

!!! Note "참고 사항"

    `select` 구조는 작고 간단한 메뉴에 매우 유용합니다. 더 완전한 표시를 사용자 정의하려면 `while` 반복문에서 `echo` 와 `read` 명령을 사용해야 합니다.

조건부 반복문 구조 `select`의 구문은 다음과 같습니다:

```
PS3="Your choice:"
select variable in var1 var2 var3
do
  commands
done
```

조건부 반복문 구조 `select` 사용의 예:

```
PS3="Your choice: "
select choice in coffee tea chocolate
do
  echo "You have chosen the $REPLY: $choice"
done
```

이 스크립트를 실행하면 다음과 같이 나타납니다:

```
1) Coffee
2) Tea
3) Chocolate
Your choice : 2
You have chosen choice 2: Tea
Your choice:
```

## 리스트 값에 대한 `for` 반복문 구조

The `for` / `do` / `done`  구조는 리스트의 첫 번째 요소를 `for` 다음에 위치한 변수에 할당합니다(이를 위해 생성된 변수). 그런 다음 이 값을 사용하여 `do`와 `done` 사이에 위치한 명령들이 실행됩니다. 스크립트는 마지막 요소가 사용된 후 `done` 다음의 첫 번째 명령에서 실행을 계속합니다. `done`.

리스트 값에 대한 반복문 구조의 구문은 다음과 같습니다:

```
for variable in list
do
  commands
done
```

반복문 구조 `for`의 사용 예제:

```
for file in /home /etc/passwd /root/fic.txt
do
  file $file
done
```

`in` 뒤에 있는 목록은 하위 실행을 사용하여 값을 생성하는 모든 명령을 배치할 수 있습니다.

* 변수 `IFS`에 `$' \t\n'`이 포함된 경우 `for` 반복문은 이 명령 결과로부터 **각 단어**를 루프할 요소 목록으로 사용합니다.
* `$'\t\n'`(즉, 공백 없음)을 포함하는 `IFS` 변수를 사용하여 `for` 루프는 이 명령 결과로부터 각 줄을 사용합니다.

이는 디렉토리의 파일일 수도 있습니다. 이 경우 변수는 파일 이름에 포함된 각 단어를 값으로 사용합니다:

```
for file in $(ls -d /tmp/*)
do
  echo $file
done
```

파일일 수도 있습니다. 이 경우 변수는 탐색하는 파일에 포함된 각 단어를 값으로 사용합니다. 파일의 시작부터 끝까지:

```
cat my_file.txt
first line
second line
third line
for LINE in $(cat my_file.txt); do echo $LINE; done
first
line
second
line
third line
line
```

파일을 한 줄씩 읽으려면 `IFS` 환경 변수의 값을 수정해야 합니다.

```
IFS=$'\t\n'
for LINE in $(cat my_file.txt); do echo $LINE; done
first line
second line
third line
```
