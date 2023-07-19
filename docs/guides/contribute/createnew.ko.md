---
title: GitHub에서 새 문서 만들기
author: Ezequiel Bruni
contributors: Grammaresque
tags:
  - 기여하기
  - 문서
---

# GitHub에서 새 문서를 만드는 방법

_승인을 위해 원본 서면 문서를 제출할 준비가 되면 다음의 간단한 단계를 따르십시오._


## GitHub GUI 사용

GitHub의 웹 GUI에서 거의 모든 작업을 완료할 수 있습니다. 다음은 Rocky Linux 설명서 GitHub 리포지토리에 로컬 컴퓨터에서 생성한 파일을 추가하는 예입니다.



1. GitHub 계정에 로그인합니다.
2. Rocky Linux 설명서 저장소([https://github.com/rocky-linux/documentation](https://github.com/rocky-linux/documentation))로 이동합니다.
3. "Main" 브랜치에 있어야 하므로 중간 섹션의 드롭다운 레이블을 확인하십시오. 문서가 최종적으로 "Main" 브랜치로 끝나지 않을 수도 있지만, 관리자는 나중에 문서를 논리적으로 적합한 위치로 이동시킬 것입니다.
4. 페이지 오른쪽에서 "Fork" 버튼을 클릭하면 문서 사본이 생성됩니다.
5. 포크된 사본 페이지 중간의 녹색 "코드" 드롭다운 바로 왼쪽에 "파일 추가" 버튼이 있습니다. 이것을 클릭하고 "파일 업로드" 옵션을 선택하십시오.
6. 이렇게 하면 여기로 파일을 끌어다 놓거나 컴퓨터에서 찾아볼 수 있습니다. 원하는 방법을 사용하십시오.
7. 파일이 업로드되면 다음으로 해야 할 일은 풀 리퀘스트를 생성하는 것입니다. 이 요청을 통해 업스트림 관리자는 마스터와 병합하려는 새 파일이 있음을 알 수 있습니다.
8. 화면 왼쪽 상단에 있는 "Pull Request"를 클릭합니다.
9. 화면 왼쪽 상단에 있는 "Pull Request"를 클릭합니다. (새 문서, 개정, 제안된 변경 등) 그런 다음 변경 사항을 제출하십시오.


## Git 명령줄에서

머신에서 로컬로 Git을 실행하려는 경우 [Rocky Linux Documentation](https://github.com/rocky-linux/documentation) 리포지토리를 복제하고 변경한 다음 나중에 변경 사항을 커밋할 수 있습니다. 간단하게 하려면 위의 **GitHub GUI 사용** 접근 방식을 사용하여 1~3단계를 실행한 후 다음을 수행하세요.



1. Git clone the repository: git clone https://github.com/your_fork_name/documentation.git
2. 이제 컴퓨터에서 디렉터리에 파일을 추가합니다.
3. 예: mv /home/myname/help.md /home/myname/documentation/
4. 다음으로 해당 파일 이름에 대해 Git add를 실행합니다.
5. 예: git add help.md
6. 이제 변경 사항에 대해 git commit을 실행합니다.
7. 예: git commit -m "help.md 파일 추가"
8. 다음으로 포크된 저장소에 변경 사항을 푸시합니다: git push https://github.com/your_fork_name/documentation main
9. 다음으로 위의 6단계와 7단계를 반복합니다: 풀 리퀘스트 만들기. 이 요청을 통해 업스트림 관리자는 마스터 브랜치와 병합하려는 새 파일이 있음을 알 수 있습니다. 화면 왼쪽 상단에 있는 "Pull Request"를 클릭합니다.

요청된 수정 및 설명에 대한 PR 내의 의견을 확인하십시오. 
