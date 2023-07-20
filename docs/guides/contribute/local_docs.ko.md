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

원하는 경우 Docker 또는 LXD 없이 로컬에서 문서 시스템을 구축할 수 있습니다. 그러나 이 절차를 사용하기로 선택한 경우 Python 코딩을 많이 하거나 Python을 로컬에서 사용하는 경우 가장 안전한 방법은 Python 가상 환경 [여기](https://docs.python.org/3/library/venv.html)에 설명되어 있습니다. 이렇게 하면 모든 Python 프로세스가 서로 보호되므로 권장됩니다. Python 가상 환경 없이 이 절차를 사용하기로 선택한 경우 어느 정도의 위험을 감수하고 있다는 점에 유의하십시오.

## 절차

* docs.rockylinux.org 저장소를 복제합니다.

```
git clone https://github.com/rocky-linux/docs.rockylinux.org.git
```

* 완료되면 docs.rockylinux.org 디렉토리로 변경합니다.

```
cd docs.rockylinux.org
```

* 이제 다음을 사용하여 설명서 저장소를 복제합니다.

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

이는 Docker 또는 LXD 없이 문서의 로컬 사본을 실행하는 빠르고 간단한 방법을 제공합니다. 이 방법을 선택하면 다른 Python 프로세스를 보호하기 위해 실제로 Python 가상 환경을 설정해야 합니다.
