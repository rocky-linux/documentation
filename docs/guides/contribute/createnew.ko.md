---
title: GitHub에서 새 문서 만들기
author: Ezequiel Bruni
contributors: Grammaresque
tags:
  - 기여하기
  - 문서
---

# GitHub에서 새 문서를 만드는 방법

_승인을 위해 원고 작성한 문서를 제출할 준비가 되었다면, 다음의 간단한 단계를 따르십시오._


## GitHub GUI 사용

GitHub의 웹 GUI로 거의 모든 작업을 완료할 수 있습니다. 다음은 로컬 컴퓨터에서 만든 파일을 Rocky Linux 문서 GitHub 저장소에 추가하는 예시입니다.



1. GitHub 계정에 로그인합니다.
2. Rocky Linux 설명서 저장소([https://github.com/rocky-linux/documentation](https://github.com/rocky-linux/documentation))로 이동합니다.
3. "Main" 브랜치에 있어야 하므로 가운데 부분에 있는 드롭다운 레이블을 확인하여 현재 위치를 확인하세요. 실제로 여러분의 문서는 "Main" 브랜치에 최종적으로 들어가지 않을 수 있지만, 관리자가 나중에 논리적으로 들어맞는 위치로 이동시킬 것입니다.
4. 페이지 우측 상단에 있는 "Fork" 버튼을 클릭하여 문서의 복사본을 생성합니다.
5. 포크된 복사본의 가운데에는 녹색 "Code" 드롭다운 왼쪽에 "Add file" 버튼이 있습니다. 이 버튼을 클릭하고 "Upload files" 옵션을 선택하세요.
6. 이로써 파일을 여기로 드래그 앤 드롭하거나 컴퓨터에서 찾아서 업로드할 수 있습니다. 원하는 방법을 사용하세요.
7. 파일을 업로드한 후, 다음으로 해야 할 일은 Pull Request를 생성하는 것입니다. 이 요청은 상위 관리자에게 새 파일(또는 파일들)을 마스터 브랜치에 병합하고자 한다는 것을 알려줍니다.
8. 화면 왼쪽 상단에 있는 "Pull Request"를 클릭합니다.
9. "Write" 섹션에 간단한 메시지를 작성하여 관리자들에게 무엇을 수행했는지 알려주세요(새 문서, 개정, 제안 변경 등). 그리고 변경 사항을 제출하세요.


## Git 명령줄에서

로컬 컴퓨터에서 Git을 실행하는 것을 선호하는 경우, [Rocky Linux Documentation](https://github.com/rocky-linux/documentation) 리포지토리를 복제하고 변경한 다음 나중에 변경 사항을 커밋할 수 있습니다. 간단하게 하려면 위의 **GitHub GUI 사용** 접근 방식을 사용하여 1~3단계를 실행한 후 다음을 수행하세요.



1. 저장소를 Git clone하세요: git clone https://github.com/your_fork_name/documentation.git https://github.com/your_fork_name/documentation.git
2. 이제 컴퓨터에서 디렉터리에 파일을 추가합니다.
3. 예: mv /home/myname/help.md /home/myname/documentation/
4. 그 다음, 해당 파일 이름에 대해 Git add를 실행하세요.
5. 예: git add help.md
6. 이제 변경 사항을 위해 git commit을 실행하세요.
7. 예: git commit -m "help.md 파일 추가"
8. 다음으로 포크된 저장소에 변경 사항을 push 합니다: git push https://github.com/your_fork_name/documentation main
9. 그 다음, 위의 단계 6과 7을 반복하세요: Pull Request를 생성하세요. 이 요청은 상위 관리자들에게 새 파일(또는 파일들)을 마스터 브랜치에 병합하고자 한다는 것을 알려줍니다. 화면 상단 좌측에 있는 "Pull Request"를 클릭하세요.

PR 내부의 요청된 수정과 설명을 확인하세요. 
