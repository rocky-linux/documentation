---
title: Bash - 조건부 구조 if 및 case
author: Antoine Le Morvan
contributors: Steven Spencer
tested_with: 8.5
tags:
  - 교육
  - bash 스크립팅
  - bash
---

# Bash - 조건부 구조 if 및 case

****

**목적**: 이 문서에서는 다음을 수행하는 방법에 대해 알아볼 것 입니다:

:heavy_check_mark: 조건부 구문 `if` 사용;  
:heavy_check_mark: 조건부 구문 `case` 사용.

:checkered_flag: **linux**, **스크립트**, **bash** , **조건부 구조**

**지식**: :star: :star:  
**복잡성**: :star: :star: :star:

**소요 시간**: 20분

****

## 조건부 구조

`$?` 변수를 사용하여 테스트 결과나 명령 실행 여부를 알 수 있는 경우 표시만 가능하며 스크립트 실행에는 영향을 미치지 않습니다.

그러나 우리는 그것을 조건으로 사용할 수 있습니다. **If(만약)** 테스트가 **then(그렇다면)** 나는 이 행동을 **otherwise(그렇지 않으면)** 이 다른 작업을 수행합니다.

조건부 대안 `if`의 구문:

```
if command
then
    command if $?=0
else
    command if $?!=0
fi
```

`if` 단어 뒤에 있는 명령은 평가될 반환 코드(`$?`)이므로 모든 명령이 될 수 있습니다. `test` 명령을 사용하여 이 테스트의 결과(파일 존재, 변수가 비어 있지 않음, 쓰기 권한 설정)에 따라 여러 작업을 정의하는 것이 편리한 경우가 많습니다.

기존 명령(`mkdir`, `tar`, ...)을 사용하면 성공한 경우 수행할 작업이나 실패한 경우 표시할 오류 메시지를 정의할 수 있습니다.

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

`else` 블록이 새로운 `if` 구조로 시작하는 경우 `else` 및 `if`를 `와 병합할 수 있습니다. elif`는 아래와 같습니다.

```
[...]
else
  if [[ -e /etc/ ]]
[...]

[...]
# is equivalent to
elif [[ -e /etc ]]
[...]
```

!!! 참고 "요약"

    `if` / `then` / `else` / `fi` 구조는 if 뒤에 배치된 명령을 평가합니다.

    * 이 명령의 반환 코드가 `0`(`true`)이면 셸은 `then` 뒤에 있는 명령을 실행합니다.
    * 반환 코드가 `0`(`false`)과 다른 경우 셸은 `else` 뒤에 있는 명령을 실행합니다.

    `else` 블록은 선택 사항입니다.

    명령 평가가 참인 경우에만 일부 작업을 수행하고 거짓인 경우에는 아무것도 수행하지 않는 경우가 종종 있습니다.

    `fi`라는 단어는 구조를 닫습니다.

`then` 블록에서 실행할 명령이 하나만 있는 경우 더 간단한 구문을 사용할 수 있습니다.

`$?`가 `true`이면 실행 명령을 `&&` 뒤에 배치하고, `$?`가 `false`이면 실행 명령을 `||`(옵션) 뒤에 배치합니다.

예시:

```
[[ -e /etc/passwd ]] && echo "The file exists" || echo "The file does not exist"
mkdir dir && echo "The directory is created".
```

`if`보다 가벼운 구조로 변수를 평가하고 대체하는 것도 가능합니다.

이 구문은 중괄호를 구현합니다.

* 변수가 비어 있는 경우 대체 값을 표시합니다.
    ```
    ${variable:-value}
    ```
* 변수가 비어 있지 않으면 대체 값을 표시합니다.
    ```
    ${variable:+value}
    ```
* 비어 있는 경우 변수에 새 값을 할당합니다.
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

     `if`, `then`, `else`, `fi` 또는 설명된 간단한 구문 예제의 사용을 결정할 때는 스크립트의 가독성을 염두에 두십시오. 자신 외에 아무도 스크립트를 사용하지 않을 경우 자신에게 가장 적합한 것을 사용할 수 있습니다. 다른 사람이 귀하가 만든 스크립트를 검토, 디버그 또는 추적해야 하는 경우 더 많은 자체 문서화 형식(`if`, `then` 등)을 사용하거나 스크립트를 철저히 문서화하여 구문은 실제로 스크립트를 수정하고 사용해야 하는 사람들이 이해할 수 있습니다. 스크립트를 문서화하는 것은 어쨌든 *항상* 좋은 일입니다. 이 단원의 앞부분에서 여러 번 언급했습니다.

## 대체 조건: `case` 구조

연속적인 `if` 구조는 빠르게 무겁고 복잡해질 수 있습니다. 동일한 변수의 평가와 관련하여 여러 분기가 있는 조건부 구조를 사용할 수 있습니다. 변수의 값은 지정되거나 가능성 목록에 속할 수 있습니다.

**와일드카드를 사용할 수 있습니다**.

`case ... in` / `esac` 구조는 `case` 뒤에 배치된 변수를 평가하고 정의된 값과 비교합니다.

첫 번째 일치 항목이 발견되면 `)`와 `;;` 사이에 있는 명령이 실행됩니다.

평가된 변수와 제안된 값은 문자열이거나 명령의 하위 실행 결과일 수 있습니다.

구조의 끝에 배치된 `*` 선택은 이전에 테스트되지 않은 모든 값에 대해 실행될 작업을 나타냅니다.

조건부 대체 사례의 구문:

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

값이 변경될 수 있는 경우 와일드카드 `[]`를 사용하여 가능성을 지정하는 것이 좋습니다.

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
