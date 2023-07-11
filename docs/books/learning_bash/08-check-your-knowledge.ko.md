---
title: Bash - 연습 문제
author: Antoine Le Morvan
contributors: Steven Spencer
tested_with: 8.5
tags:
  - 교육
  - bash 스크립팅
  - bash
---

# Bash - 연습 문제

:heavy_check_mark: 모든 명령은 실행 종료 시 반환 코드를 반환해야 합니다.

- [ ] 예
- [ ] 아니오

:heavy_check_mark: 반환 코드 0은 실행 오류를 나타냅니다.

- [ ] 예
- [ ] 아니오

:heavy_check_mark: 반환 코드는 `$@` 변수에 저장됩니다.

- [ ] 예
- [ ] 아니오

:heavy_check_mark: test 명령으로 다음을 수행할 수 있습니다.

- [ ] 파일 유형 테스트
- [ ] 변수 테스트
- [ ] 숫자 비교
- [ ] 두 파일의 내용 비교

:heavy_check_mark: `expr` 명령은 다음을 수행합니다.

- [ ] 2개의 문자열을 연결합니다.
- [ ] 수학 연산을 수행합니다.
- [ ] 화면에 텍스트 표시합니다.

:heavy_check_mark: 다음 조건부 구조의 구문이 올바른 것 같나요? 왜 그런지 설명해주세요.

```
if command
    command if $?=0
else
    command if $?!=0
fi
```

- [ ] 예
- [ ] 아니오

:heavy_check_mark: 다음 구문은 무엇을 의미합니까: `${variable:=value}`

- [ ] 변수가 비어 있으면 대체 값을 표시합니다.
- [ ] 변수가 비어 있지 않으면 대체 값 표시합니다.
- [ ] 비어 있는 경우 변수에 새 값을 할당합니다.

:heavy_check_mark: 다음 조건부 대체 구조의 구문이 올바른 것 같나요? 왜 그런지 설명해주세요.

```
case $variable in
  value1)
    commands if $variable = value1
  value2)
    commands if $variable = value2
  *)
    commands for all values of $variable != of value1 and value2
    ;;
esac
```

- [ ] 예
- [ ] 아니오

:heavy_check_mark: 다음 중 반복을 위한 구조가 아닌 것은 무엇인가요?

- [ ] while
- [ ] until
- [ ] loop
- [ ] for
