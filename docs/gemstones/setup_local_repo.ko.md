---
title: 로컬 Rocky 저장소 설정
author: codedude
contributors: Steven Spencer
update: 09-Dec-2021
---

# 소개

가상 머신, 실험 환경 등을 구축하기 위해 때로는 로키 저장소를 로컬로 가져와야 할 때가 있습니다. 대역폭 절약을 위해서도 유용할 수 있습니다.  이 문서에서는 `rsync`를 사용하여 로키 저장소를 로컬 웹 서버로 복사하는 방법을 안내합니다.  웹 서버 구축은 이 짧은 문서의 범위를 벗어납니다.

## 요구 사항

* 웹 서버

## 코드

```
#!/bin/bash
repos_base_dir="/web/path"

# base repo 디렉토리가 존재할 경우 동기화 시작

if [[ -d "$repos_base_dir" ]] ; then
  # 동기화 시작
  rsync  -avSHP --progress --delete --exclude-from=/opt/scripts/excludes.txt rsync://ord.mirror.rackspace.com/rocky  "$repos_base_dir" --delete-excluded
  # Rocky 8 리포지토리 키 다운로드
  if [[ -e /web/path/RPM-GPG-KEY-rockyofficial ]]; then
     exit
  else
      wget -P $repos_base_dir https://dl.rockylinux.org/pub/rocky/RPM-GPG-KEY-rockyofficial
  fi
fi
```

## 붕괴

이 간단한 셸 스크립트는 `rsync`를 사용하여 가장 가까운 미러에서 저장소 파일을 가져옵니다.  또한 텍스트 파일에 정의된 "exclude" 옵션을 활용하여 포함되지 않아야 하는 키워드를 설정합니다.  용량이 제한된 경우나 어떠한 이유로 인해 모든 파일을 가져오지 않고 싶을 때 "exclude" 를 사용하면 유용합니다.  `*`를 와일드카드 문자로 사용할 수 있습니다.  `*/ng`를 사용할 때는 주의해야 합니다. 해당 문자와 일치하는 항목은 모두 제외됩니다.  아래에 예시가 있습니다:

```
*/source*
*/debug*
*/images*
*/Devel*
8/*
8.4-RC1/*
8.4-RC1
```

# 결론
대역폭을 절약하거나 실험 환경 구축을 조금 더 쉽게 만들어 주는 간단한 스크립트입니다.
