---
title: 패키지 디브랜딩
---

# Rocky 패키지 디브랜딩 방법

Rocky Linux 배포용 패키지의 브랜드를 제거하는 방법을 설명합니다.


일반적인 방법

먼저, Rocky Linux 배포를 위해 패키지 내에서 변경해야 할 파일을 확인하세요. 이들은 텍스트 파일, 이미지 파일 또는 기타 파일일 수 있습니다. 해당 파일들을 확인하기 위해 git.centos.org/rpms/PACKAGE/을 살펴볼 수 있습니다.

이들 파일에 대한 대체 파일을 개발하세요. 하지만 Rocky 브랜딩이 적용된 파일로 대체해야 합니다. 특정 유형의 텍스트에 따라 차이(diff)/패치(patch) 파일도 필요할 수 있습니다. 이는 대체되는 내용에 따라 다릅니다.

대체 파일은 https://git.rockylinux.org/patch/PACKAGE/ROCKY/_supporting/ 아래에 배치하세요. 구성 파일(패치 적용 방법 지정)은 https://git.rockylinux.org/patch/PACKAGE/ROCKY/CFG/*.cfg에 있습니다.

참고: 탭이 아닌 스페이스를 사용하세요. Srpmproc이 패키지를 Rocky로 가져오려고 하면 https://git.rockylinux.org/patch/PACKAGE에서 수행한 작업을 보고, ROCKY/CFG/*.cfg 아래의 구성 파일을 읽어 저장된 브랜딩 해제 패치를 적용합니다.


[디브랜딩 위키 페이지](https://wiki.rockylinux.org/team/release_engineering/debranding/)에서 가져온 내용입니다.
