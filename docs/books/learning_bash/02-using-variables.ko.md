---
title: Bash - 변수 사용
author: Antoine Le Morvan
contributors: Steven Spencer
tested_with: 8.5
tags:
  - 교육
  - bash 스크립팅
  - bash
---

# Bash - 변수 사용

이 장에서는 bash 스크립트에서 변수를 사용하는 방법을 배웁니다.

****

**목적**: 이 문서에서는 다음을 수행하는 방법에 대해 알아볼 것 입니다:

:heavy_check_mark: 나중에 사용할 수 있도록 정보 저장;  
:heavy_check_mark: 변수 삭제 및 잠금;  
:heavy_check_mark: 환경 변수 사용;  
:heavy_check_mark: 대체 명령;

:checkered_flag: **linux**, **스크립트**, **bash**, **변수**

**지식**: :star: :star:  
**복잡성**: :star:

**읽는 시간**: 10 분

****

## 나중에 사용하기 위해 정보 저장

모든 프로그래밍 언어와 마찬가지로 쉘 스크립트는 변수를 사용합니다. 스크립트 중에 필요에 따라 재사용할 정보를 메모리에 저장하는 데 사용됩니다.

변수는 콘텐츠를 수신할 때 생성됩니다. 스크립트 실행이 끝날 때까지 또는 스크립트 작성자의 명시적인 요청이 있을 때까지 유효합니다. 스크립트는 처음부터 끝까지 순차적으로 실행되기 때문에 변수가 생성되기 전에 호출하는 것은 불가능합니다.

변수는 스크립트가 끝날 때까지 계속 존재하므로 스크립트 중에 변수의 내용을 변경할 수 있습니다. 콘텐츠가 삭제되면 변수는 활성 상태로 유지되지만 아무 것도 포함하지 않습니다.

쉘 스크립트에서 변수 유형의 개념은 가능하지만 거의 사용되지 않습니다. 변수의 내용은 항상 문자 또는 문자열입니다.

```
#!/usr/bin/env bash

#
# Author : Rocky Documentation Team
# Date: March 2022
# Version 1.0.0: Save in /root the files passwd, shadow, group, and gshadow
#

# global variables 전역 변수
FILE1=/etc/passwd
FILE2=/etc/shadow
FILE3=/etc/group
FILE4=/etc/gshadow

# Destination folder 대상 폴더
DESTINATION=/root

# Clear the screen 화면 지우기
clear

# Launch the back up 백업 시작
echo "Starting the backup of $FILE1, $FILE2, $FILE3, $FILE4 to $DESTINATION:"

cp $FILE1 $FILE2 $FILE3 $FILE4 $DESTINATION

echo "Backup ended!"
```

이 스크립트는 변수를 사용합니다. 변수 이름은 문자로 시작해야 하지만 일련의 문자나 숫자를 포함할 수 있습니다. 밑줄 "_"을 제외한 특수 문자는 사용할 수 없습니다.

관례적으로 사용자가 생성한 변수는 이름이 소문자입니다. 이 이름은 너무 애매하거나 복잡하지 않도록 주의해서 선택해야 합니다. 그러나 변수는 프로그램에서 수정해서는 안 되는 전역 변수인 경우 이 경우와 같이 대문자로 이름을 지정할 수 있습니다.

문자 `=`는 콘텐츠를 변수에 할당합니다.

```
variable=value
rep_name="/home"
```

`=` 기호 앞이나 뒤에 공백이 없습니다.

변수가 생성되면 접두사로 달러 $를 붙여서 사용할 수 있습니다.

```
file=file_name
touch $file
```

아래 예와 같이 변수를 따옴표로 보호하는 것이 좋습니다.

```
file=file name
touch $file
touch "$file"
```

변수의 내용에 공백이 포함되어 있으므로 첫 번째 `touch`는 2개의 파일을 생성하고 두 번째 `touch`는 이름에 공백이 포함된 파일을 생성합니다.

나머지 텍스트에서 변수 이름을 분리하려면 따옴표나 중괄호를 사용해야 합니다.

```
file=file_name
touch "$file"1
touch ${file}1
```

**중괄호의 체계적인 사용을 권장합니다.**

아포스트로피를 사용하면 특수 문자를 해석할 수 없습니다.

```
message="Hello"
echo "This is the content of the variable message: $message"
Here is the content of the variable message: Hello
echo 'Here is the content of the variable message: $message'
Here is the content of the variable message: $message
```

## 변수 삭제 및 잠그기

`unset` 명령을 사용하면 변수를 삭제할 수 있습니다.

예시:

```
name="NAME"
firstname="Firstname"
echo "$name $firstname"
NAME Firstname
unset firstname
echo "$name $firstname"
NAME
```

`readonly` 또는 `typeset -r` 명령은 변수를 잠급니다.

예시:

```
name="NAME"
readonly name
name="OTHER NAME"
bash: name: read-only variable
unset name
bash: name: read-only variable
```

!!! 참고 사항

    스크립트 시작 부분의 `set -u`는 선언되지 않은 변수가 사용되는 경우 스크립트 실행을 중지합니다.

## 환경 변수 사용

**환경 변수** 및 **시스템 변수**는 시스템이 작동하는 데 사용하는 변수입니다. 관례에 따라 이들은 대문자로 이름이 지정됩니다.

모든 변수와 마찬가지로 스크립트가 실행될 때 표시될 수 있습니다. 권장하지 않는 경우에도 수정할 수 있습니다.

`env` 명령은 사용된 모든 환경 변수를 표시합니다.

`set` 명령은 사용된 모든 시스템 변수를 표시합니다.

수십 개의 환경 변수 중에서 쉘 스크립트에서 사용하기에 흥미로운 몇 가지가 있습니다.

| 변수                             | 관찰                             |
| ------------------------------ | ------------------------------ |
| `HOSTNAME`                     | 시스템의 호스트 이름입니다.                |
| `USER`, `USERNAME` 및 `LOGNAME` | 세션에 연결된 사용자의 이름입니다.            |
| `PATH`                         | 명령을 찾는 경로입니다.                  |
| `PWD`                          | cd 명령이 실행될 때마다 업데이트되는 현재 디렉토리. |
| `HOME`                         | 로그인 디렉토리.                      |
| `$$`                           | 스크립트 실행의 프로세스 ID입니다.           |
| `$?`                           | 실행된 마지막 명령의 반환 코드.             |

`export` 명령을 사용하면 변수를 내보낼 수 있습니다.

변수는 쉘 스크립트 프로세스 환경에서만 유효합니다. 스크립트의 **자식 프로세스**가 변수와 그 내용을 알기 위해서는 내보내야 합니다.

하위 프로세스에서 내보낸 변수의 수정은 상위 프로세스로 역추적할 수 없습니다.

!!! 참고 사항

    옵션이 없으면 'export' 명령은 내보낸 변수의 이름과 값을 환경에 표시합니다.

## 대체 명령

명령의 결과를 변수에 저장할 수 있습니다.

!!! 참고 사항

    이 작업은 실행 종료 시 메시지를 반환하는 명령에만 유효합니다.

명령을 하위 실행하는 구문은 다음과 같습니다.

```
variable=`command`
variable=$(command) # 선호하는 구문
```

예시:

```
$ day=`date +%d`
$ homedir=$(pwd)
```

방금 본 모든 것을 사용하여 백업 스크립트는 다음과 같을 수 있습니다.

```
#!/usr/bin/env bash

#
# Author : Rocky Documentation Team
# Date: March 2022
# Version 1.0.0: Save in /root the files passwd, shadow, group, and gshadow
# Version 1.0.1: Adding what we learned about variables
#

# Global variables 전역 변수 
FILE1=/etc/passwd
FILE2=/etc/shadow
FILE3=/etc/group
FILE4=/etc/gshadow

# Destination folder 대상 폴더
DESTINATION=/root

## Readonly variables 읽기 전용 변수
readonly FILE1 FILE2 FILE3 FILE4 DESTINATION
 
# A folder name with the day's number 날짜가 포함된 폴더 이름
dir="backup-$(date +%j)"

# Clear the screen 화면 지우기
clear

# Launch the backup 백업 시작
echo "****************************************************************"
echo "     Backup Script - Backup on ${HOSTNAME}                      "
echo "****************************************************************"
echo "The backup will be made in the folder ${dir}."
echo "Creating the directory..."
mkdir -p ${DESTINATION}/${dir}

echo "Starting the backup of ${FILE1}, ${FILE2}, ${FILE3}, ${FILE4} to ${DESTINATION}/${dir}:"

cp ${FILE1} ${FILE2} ${FILE3} ${FILE4} ${DESTINATION}/${dir}

echo "Backup ended!"

# The backup is noted in the system event log:
logger "Backup of system files by ${USER} on ${HOSTNAME} in the folder ${DESTINATION}/${dir}."
```

백업 스크립트 실행:

```
$ sudo ./backup.sh
```

결과적으로:

```
****************************************************************
     Backup Script - Backup on desktop                      
****************************************************************
The backup will be made in the folder backup-088.
디렉토리 생성 중...
Starting the backup of /etc/passwd, /etc/shadow, /etc/group, /etc/gshadow to /root/backup-088:
Backup ended!
```
