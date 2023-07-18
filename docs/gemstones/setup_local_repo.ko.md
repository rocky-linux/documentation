---
title: Setup Local Rocky Repositories
author: codedude
contributors: Steven Spencer
update: 09-Dec-2021
---

# 소개

때때로 가상 머신, 랩 환경 등을 구축하기 위해 로컬 Rocky 저장소가 필요합니다. 문제가 될 경우 대역폭을 절약하는 데도 도움이 될 수 있습니다.  이 문서에서는 `rsync`를 사용하여 Rocky 리포지토리를 로컬 웹 서버에 복사하는 과정을 안내합니다.  웹 서버 구축은 이 짧은 기사의 범위를 벗어납니다.

## 요구 사항

* 웹 서버

## Code

```
#!/bin/bash
repos_base_dir="/web/path"

# 기본 repo 디렉토리가 존재하는 경우 동기화 시작
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

이 간단한 셸 스크립트는 `rsync`를 사용하여 가장 가까운 미러에서 리포지토리 파일을 가져옵니다.  또한 포함되어서는 안 되는 키워드 형식으로 텍스트 파일에 정의되어 있는 "exclude" 옵션을 사용합니다.  디스크 공간이 제한되어 있거나 어떤 이유로 든 모든 것을 원하지 않는 경우 제외가 좋습니다.  `*`를 와일드카드 문자로 사용할 수 있습니다.  `*/ng`를 사용하면 해당 문자와 일치하는 모든 항목이 제외되므로 주의하십시오.  예시는 다음과 같습니다.

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
대역폭을 절약하거나 랩 환경을 구축하는 데 도움이 되는 간단한 스크립트입니다.
