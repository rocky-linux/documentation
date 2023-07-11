---
title: Bash - 조건문 구조 if 및 case
author: Antoine Le Morvan
contributors: Steven Spencer
tested_with: 8.5
tags:
  - 교육
  - bash 스크립팅
  - bash
---

# Bash - 조건문 구조 if 및 case

****

**목적**: 이 문서에서는 다음을 수행하는 방법에 대해 알아볼 것 입니다:

:heavy_check_mark: 조건문 `if` 구문을 사용하는 방법  
:heavy_check_mark: 조건문 `case` 구문을 사용하는 방법

:checkered_flag: **linux**, **스크립트**, **bash** , **조건문 구조**

**지식**: :star: :star:  
**복잡성**: :star: :star: :star:

**소요 시간**: 20분

****

## 조건문 구조

`$?` 변수는 테스트의 결과나 명령 실행 결과를 알기 위해 사용될 수 있지만, 단순히 표시되며 스크립트의 실행에는 영향을 주지 않습니다.

하지만 조건문에서 사용할 수 있습니다. **If(만약)** 테스트가 **then(성공한다면)** 이 작업을 하고, **otherwise(그렇지 않으면)** 다른 작업을 수행합니다.

조건문 `if`의 구문은 다음과 같습니다:

```
if command
then
    command if $?=0
else
    command if $?!=0
fi
```

`if` 다음에 위치한 명령은 반환 코드(`$?`)가 평가될 것이므로 어떤 명령이든 사용할 수 있습니다. `test` 명령을 사용하여 이 테스트의 결과(파일 존재, 변수가 비어 있지 않음, 쓰기 권한 설정)에 따라 여러 작업을 정의하는 것이 편리한 경우가 많습니다.

기존 명령(`mkdir`, `tar`, ...을 사용하면 성공할 경우 수행해야 할 동작이나 실패할 경우 표시해야 할 오류 메시지를 정의할 수 있습니다.

예시:

```
if [[ -e /etc/passwd ]]
then
    echo "The file exists"
else
    echo "The file does not exist"
fi

if mkdir rep
then
    cd rep
fi
```

`else` 블록이 새로운 `if` 구조로 시작하는 경우 `else` 및 `if`를 아래처럼 `elif`로 병합할 수 있습니다.

```
[...]
else
  if [[ -e /etc/ ]]
[...]

[...]
# 위와 동등한 표현
elif [[ -e /etc ]]
[...]
```

!!! 참고 "요약"

    `if` / `then` / `else` / `fi` 구조는 if 뒤에 배치된 명령을 평가합니다.

    * 만약 이 명령의 반환 코드가 `0`(`true`)이면 셸은 `then` 뒤에 있는 명령을 실행합니다.
    * 만약 반환 코드가 `0`이 아닌 값(`false`)이라면 셸은 `else` 뒤에 있는 명령을 실행합니다.

    `else` 블록은 선택 사항입니다.

    테스트 평가가 참일 때에만 일부 작업을 수행하고 거짓일 때는 아무것도 수행하지 않는 경우가 종종 있습니다.

    단어 `fi`는  구조를 닫습니다.

`then` 블록에서 실행할 명령이 하나만 있는 경우, 더 간단한 구문을 사용할 수 있습니다.

`$?`가 `true`인 경우 실행할 명령은 `&&` 뒤에 배치하고, `$?`가 `false`인 경우 실행할 명령은 `||`(옵션) 뒤에 배치합니다.

예시:

```
[[ -e /etc/passwd ]] && echo "The file exists" || echo "The file does not exist"
mkdir dir && echo "The directory is created".
```

또한 `if`보다 가볍게 변수를 평가하고 대체할 수 있는 구조를 사용할 수도 있습니다.

다음 구문은 중괄호를 구현한 것입니다:

* 변수가 비어 있는 경우 대체 값을 표시합니다.
    ```
    ${variable:-value}
    ```
* 변수가 비어 있지 않은 경우 대체 값을 표시합니다.
    ```
    ${variable:+value}
    ```
* 변수가 비어있는 경우 변수에 새 값을 할당합니다:
    ```
    ${variable:=value}
    ```

예시:

```
name=""
echo ${name:-linux}
linux
echo $name

echo ${name:=linux}
linux
echo $name
linux
echo ${name:+tux}
tux
echo $name
linux
```

!!! 힌트

    `if`, `then`, `else`, `fi` 또는 앞에서 설명한 간단한 구문 예제를 사용할지 결정할 때에는 스크립트의 가독성을 염두에 두세요. 자신 외에 아무도 스크립트를 사용하지 않을 경우 자신에게 가장 적합한 것을 사용할 수 있습니다. 스크립트를 사용하는 사람이 단순히 본인뿐이라면 가장 효과적인 방법을 사용할 수 있습니다.그러나 다른 사람이 스크립트를 검토, 디버그 또는 추적해야 할 가능성이 있다면, 더 자체 문서화된 형식(`if`, `then` 등)을 사용하거나 스크립트를 수정하고 사용할 수 있는 사람들에게 실제로 간단한 구문이 이해될 수 있도록 스크립트를 철저히 문서화하는 것이 중요합니다. 스크립트 문서화는 *항상* 좋은 습관이며, 이 문서의 앞부분에서 여러 번 언급되었습니다.

## 대체 조건문: `case` 구조

연속적인 `if` 구조는 빠르게 복잡하고 번거로워질 수 있습니다. 동일한 변수의 평가와 관련하여 여러 분기가 있는 조건문 구조를 사용할 수 있습니다. 변수의 값은 지정되거나 가능성 목록에 속할 수 있습니다.

**와일드카드를 사용할 수 있습니다**.

`case ... in` / `esac` 구조는 `case` 뒤에 배치된 변수를 평가하고 정의된 값과 비교합니다.

첫 번째 일치하는 값에서 `)`와 `;;` 사이에 있는 명령이 실행됩니다.

평가된 변수와 제안된 값들은 문자열 또는 명령의 하위 실행 결과일 수 있습니다.

구조의 끝에 배치된 `*` 선택지는 이전에 테스트되지 않은 모든 값에 대해 실행될 작업을 나타냅니다.

조건문 case의 구문은 다음과 같습니다:

```
case $variable in
  value1)
    commands if $variable = value1
    ;;
  value2)
    commands if $variable = value2
    ;;
  [..]
  *)
    commands for all values of $variable != of value1 and value2
    ;;
esac
```

값이 변동될 수 있는 경우, 가능성을 지정하기 위해 와일드카드 `[]`를 사용하는 것이 좋습니다:

```
[Yy][Ee][Ss])
  echo "yes"
  ;;
```

`|` 문자를 사용하면 값 또는 다른 값을 지정할 수도 있습니다.

```
"yes" | "YES")
  echo "yes"
  ;;
```
