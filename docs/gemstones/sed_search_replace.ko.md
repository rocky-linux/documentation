---
title: sed - 검색 및 변경
author: Steven Spencer
---

# `sed` 검색 및 변경

`sed`는 "stream editor"를 나타내는 명령입니다.

## 규칙

* `path`: 실제 경로입니다. 예: `/var/www/html/`
* `filename`: 실제 파일 이름입니다. 예: `index.php`

## `sed` 사용

검색 및 대체를 위해`sed`를 사용하는 것은 개인적인 선호도입니다. 왜냐하면 웹 링크와 같이 "/"를 포함한 항목을 대체할 때 원하는 구분자를 사용할 수 있기 때문입니다. `sed`를 사용한 인라인 편집의 기본 예시는 다음과 같습니다:

`sed -i 's/search_for/replace_with/g' /path/filename`

그러나 "/"가 포함된 문자열을 검색해야하는 경우 어떻게 해야 할까요? 만약 슬래시(/)가 구분자로 유일한 옵션이라면 검색에 사용하기 전에 각각의 슬래시를 이스케이프해야 합니다. 여기서 `sed`가 다른 도구보다 우수한 이유입니다. 왜냐하면 구분자를 변경할 수 있기 때문에 구분자를 어디에서나 지정할 필요가 없습니다. 앞서 언급한 것처럼 "/"를 포함한 항목을 찾으려면 구분자를 "|"로 변경하면 됩니다. 다음은 이 방법을 사용하여 링크를 찾는 예시입니다:

`sed -i 's|search_for/with_slash|replace_string|g' /path/filename`

구분자로는 백슬래시, 개행 문자, "s"를 제외한 임의의 한 바이트 문자를 사용할 수 있습니다. 예를 들어 다음과 같이도 작동합니다:

`sed -i 'sasearch_forawith_slashareplace_stringag' /path/filename` 기서 "a"는 구분자이며, 검색과 대체는 여전히 작동합니다. 안전을 위해 검색 및 대체 시 백업을 지정할 수 있으며, 이는 `sed`를 사용하여 수행하는 변경 사항이 _실제로_ 원하는 대로인지 확인하는 데 유용합니다. 이렇게 하면 백업 파일에서 복원 옵션이 제공됩니다: `sed -i.bak s|search_for|replacea_with|g /path/filename`

`sed -i.bak s|search_for|replacea_with|g /path/filename`

이 명령은 `filename`을 `filename.bak`으로 백업된 편집되지 않은 버전을 생성합니다.

따옴표 대신 큰 따옴표를 사용할 수도 있습니다:

`sed -i "s|search_for/with_slash|replace_string|g" /path/filename`

## 옵션 설명

| 옵션    | 설명                             |
| ----- | ------------------------------ |
| i     | 파일을 직접 편집합니다.                  |
| i.ext | 확장자가 무엇이든 백업을 생성합니다(ext here). |
| s     | 검색을 지정합니다.                     |
| g     | 전역적으로 또는 모든 발생을 대체합니다.         |

## 여러 파일

안타깝게도 `sed`에는 `perl`과 같은 인라인 루핑 옵션이 없습니다. 여러 파일을 반복하려면 스크립트 내에서 `sed` 명령을 결합해야 합니다. 다음은 그 예시입니다.

먼저, 스크립트에서 사용할 파일 목록을 생성합니다. 다음과 같이 명령 줄에서 수행합니다:

`find /var/www/html  -name "*.php" > phpfiles.txt`

다음으로 이 `phpfiles.txt`를 사용할 스크립트를 생성합니다:

```
#!/bin/bash

for file in `cat phpfiles.txt`
do
        sed -i.bak 's|search_for/with_slash|replace_string|g' $file
done
```
이 스크립트는 `phpfiles.txt`에서 생성된 모든 파일을 반복하고 각 파일의 백업을 만들며 검색 및 대체 문자열을 전역적으로 실행합니다. 변경 사항이 원하는 대로 확인되면 모든 백업 파일을 삭제할 수 있습니다.

## 기타 참고 자료와 예시

* `sed` [메뉴얼 페이지](https://linux.die.net/man/1/sed)
* `sed` [추가 예시](https://www.linuxtechi.com/20-sed-command-examples-linux-users/)
* `sed` & `awk` [O'Reilly 책](https://www.oreilly.com/library/view/sed-awk/1565922255/)

## 결론

`sed`는  구분자가 유연해야 하는 검색 및 대체 기능에 특히 잘 작동하는 강력한 도구입니다.
