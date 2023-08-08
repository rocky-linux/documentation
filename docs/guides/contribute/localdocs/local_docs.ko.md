---
title: 로컬 문서 - 빠른
author: Lukas Magauer
contributors: Steven Spencer
tested_with: 8.6, 9.0
tags:
  - 문서
  - local server
---

# 소개

Docker 또는 LXD 없이도 로컬에서 문서 시스템을 빌드할 수 있습니다. 그러나 이 절차를 사용하려는 경우, 만약 Python 코딩을 많이 하거나 로컬에서 Python을 사용한다면, 가장 안전한 방법은 [여기](https://docs.python.org/3/library/venv.html)에 설명된대로 Python 가상 환경을 만드는 것입니다. 이렇게 하면 모든 Python 프로세스가 서로 보호되어 권장되는 방법입니다. Python 가상 환경 없이 이 절차를 사용하려고 선택한다면, 일정한 위험을 감수해야 함을 알아두시기 바랍니다.

## 절차

* docs.rockylinux.org 저장소를 복제합니다.

```
git clone https://github.com/rocky-linux/docs.rockylinux.org.git
```

* 완료되면 docs.rockylinux.org 디렉토리로 이동합니다.

```
cd docs.rockylinux.org
```

* 이제 documentation 저장소를 다음과 같이 복제합니다:

```
git clone https://github.com/rocky-linux/documentation.git docs
```

* 다음으로 mkdocs용 requirements.txt 파일을 설치합니다.

```
python3 -m pip install -r requirements.txt
```

* 마지막으로 mkdocs 서버를 실행합니다.

```
mkdocs serve
```

## 결론

이를 통해 Docker 또는 LXD 없이 문서의 로컬 복사본을 빠르고 간단하게 실행할 수 있습니다. 이 방법을 선택하는 경우, 다른 Python 프로세스를 보호하기 위해 Python 가상 환경을 설정하는 것이 좋습니다.
