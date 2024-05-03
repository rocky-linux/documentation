---
title: bash - Script Stub
author: Steven Spencer
contributors: Ezequiel Bruni
---

# Bash - Script Stub

저는 이전에 일했던 곳에서 다양한 언어를 아는 뛰어난 프로그래머가 있었습니다. 그는 스크립트로 무엇인가를 수행하는 방법에 대한 질문이 있을 때 항상 찾아가는 사람이었습니다. 결국, 그는 스크립트 예제로 채워진 작은 스텁 파일을 만들었는데, 이를 필요에 맞게 편집하여 사용할 수 있었습니다. 나중에는 이러한 루틴에 익숙해져서 스텁을 보지 않아도 될 정도로 능숙해졌지만, 이는 좋은 학습 도구이자 다른 사람들에게 유용할 수 있는 것입니다.

## 실제 스텁

스텁은 잘 문서화되어 있지만, 이것은 절대적으로 모든 스크립트를 다루는 것은 아닙니다! 추가할 수 있는 루틴이 더 많이 있을 수 있습니다. **귀하**가 이 스텁에 잘 맞는 예제가 있다면 언제든지 변경해 추가해 주세요.

```
#!/bin/sh

# 경로를 내보내면 해당 경로에 있는 명령에 대해 전체 경로를 입력하지 않아도 됩니다. export PATH="$PATH:/bin:/usr/bin:/usr/local/bin"


# 프로그램 디렉토리의 절대 경로를 결정하고 저장합니다.
# 주의! bash에서 ' '은 문자열 자체를 나타내지만 " "은 약간 다릅니다. $, ` `, \는 각각 변수 값을 호출하고 명령을 참조하며 이스케이프 문자를 나타냅니다. # 스크립트와 동일한 디렉토리에 위치합니다. PGM=`basename $0`               # 프로그램 이름
CDIR=`pwd`                  # 프로그램이 실행된 디렉토리 저장

PDIR=`dirname $0`
cd $PDIR
PDIR=`pwd`

# 프로그램이 파일 이름을 인수로 받는 경우 이렇게 하면 처음 위치로 돌아갑니다.
# (상대 경로를 사용하여 파일 참조 작업이 올바르게 작동하도록 필요합니다.) cd $CDIR

# 특정 사용자에 의해 스크립트가 실행되어야 하는 경우 이를 사용합니다. runby="root"
iam=`/usr/bin/id -un`
if [ $iam != "$runby" ]
then
    echo "$PGM : program must be run by user \"$runby\""
    exit
fi

# 누락된 매개변수를 확인합니다.
# 누락된 경우 사용법 메시지를 표시하고 종료합니다. if [ "$1" = "" ]
then
    echo "$PGM : parameter 1 is required"
    echo "Usage: $PGM param-one"
    exit
fi

# 데이터를 입력 받습니다 (이 경우 "Y"가 기본값인 yes/no 응답):

/bin/echo -n "Do you wish to continue? [y/N] "
read yn
if [ "$yn" != "y" ] && [ "$yn" != "Y" ]
then
    echo "Cancelling..."
    exit;
fi

# 스크립트가 한 번에 한 개만 실행되어야 하는 경우 다음 블록을 사용합니다.
# 잠금 파일이 있는지 확인합니다.  없으면 생성합니다.
# 이미 존재하는 경우 오류 메시지를 표시하고 종료합니다. LOCKF="/tmp/${PGM}.lock"
if [ ! -e $LOCKF ]
then
    touch $LOCKF
else
    echo "$PGM: cannot continue -- lock file exists"
    echo
    echo "To continue make sure this program is not already running, then delete the"
    echo "lock file:"
    echo
    echo "    rm -f $LOCKF"
    echo
    echo "Aborting..."
    exit 0
fi

script_list=`ls customer/*`

for script in $script_list
do
    if [ $script != $PGM ]
    then
        echo "./${script}"
    fi
done

# 잠금 파일 제거

rm -f $LOCKF
```

## 결론

스크립팅은 시스템 관리자의 친구입니다. 스크립트를 사용하여 특정 작업을 빠르게 처리할 수 있습니다. 이 스텁은 모든 스크립트 루틴을 담고 있는 것은 아니지만, 일반적인 사용 예제를 제공합니다.
