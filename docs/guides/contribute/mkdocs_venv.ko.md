---
title: 로컬 문서 - Python VENV
author: Franco Colussi
contributors: Steven Spencer
tested_with: 8.7, 9.1
tags:
  - mkdocs
  - testing
  - 문서
---

# MkDocs (Python Virtual Enviroment)

## 소개

Rocky Linux용 문서 작성 프로세스의 측면 중 하나는 게시하기 전에 새 문서가 올바르게 표시되는지 확인하는 것입니다.

이 가이드의 목적은 이 목적만을 위한 로컬 Python 환경에서 이 작업을 수행하기 위한 몇 가지 제안을 제공하는 것입니다.

Rocky Linux용 문서는 일반적으로 다른 형식으로 변환되는 언어인 Markdown 언어를 사용하여 작성되었습니다. Markdown은 구문이 깔끔하며 특히 기술 문서 작성에 적합합니다.

우리의 경우 문서는 정적 사이트 구축을 담당하는 Python 응용 프로그램을 사용하여 `HTML`로 변환됩니다. 개발자가 사용하는 애플리케이션은 [MkDocs](https://www.mkdocs.org/)입니다.

Python 응용 프로그램을 개발하는 동안 발생하는 한 가지 문제는 시스템 인터프리터에서 개발에 사용되는 Python 인스턴스를 격리하는 것입니다. 격리는 Python 응용 프로그램을 설치하는 데 필요한 모듈과 호스트 시스템에 설치된 모듈 간의 비호환성을 방지하기 위한 것입니다. 비호환성으로 인해 로컬 사이트의 시각화 오류 또는 오작동이 발생할 수 있습니다.

Python 인터프리터를 격리하기 위해 **컨테이너**를 사용하는 훌륭한 가이드가 이미 있습니다. 그러나 이러한 가이드는 다양한 컨테이너화 기술에 대한 지식을 의미합니다.

이 가이드에서는 분리를 위해 Rocky Linux의 *python* 패키지에서 제공하는 `venv` 모듈을 사용합니다. 이 모듈은 버전 3.6 이후의 모든 새 버전의 *Python*에서 사용할 수 있습니다. 이렇게 하면 새 "**시스템**"을 설치하고 구성할 필요 없이 시스템에서 파이썬 인터프리터를 직접 격리할 수 있습니다.

### 요구 사항

- 실행 중인 Rocky Linux 사본
- *python* 패키지가 올바르게 설치됨
- 커맨드 라인에 대한 익숙함
- 활발한 인터넷 접속

## 환경 준비

환경은 두 개의 필수 Rocky Linux GitHub 리포지토리와 초기화 및 가상 환경에서 Python 복사본 실행이 발생하는 폴더를 포함하는 루트 폴더를 제공합니다.

먼저 다른 모든 것을 포함할 폴더를 만들고 상황에 따라 MkDocs가 실행될 **env** 폴더도 만듭니다.

```bash
mkdir -p ~/lab/rockydocs/env
```

### Python 가상 환경

MkDocs가 실행될 Python 사본을 만들려면 이 목적을 위해 특별히 개발된 모듈인 python `venv` 모듈을 사용하십시오. 이를 통해 시스템에 설치된 환경에서 파생된 완전히 격리되고 독립적인 가상 환경을 생성할 수 있습니다.

이렇게 하면 Rocky Linux 문서를 실행하기 위해 `MkDocs`에 필요한 패키지만 있는 인터프리터의 사본을 별도의 폴더에 저장할 수 있습니다.

방금 만든 폴더(*rockydocs*)로 이동하고 다음을 사용하여 가상 환경을 만듭니다.

```bash
cd ~/lab/rockydocs/
python -m venv env
```

이 명령은 여기에 표시된 시스템의 *python* 트리를 모방한 일련의 폴더 및 파일로 **env** 폴더를 채웁니다.

```text
env/
├── bin
│   ├── activate
│   ├── activate.csh
│   ├── activate.fish
│   ├── Activate.ps1
│   ├── pip
│   ├── pip3
│   ├── pip3.11
│   ├── python -> /usr/bin/python
│   ├── python3 -> python
│   └── python3.11 -> python
├── include
│   └── python3.11
├── lib
│   └── python3.11
├── lib64 -> lib
└── pyvenv.cfg
```

보시다시피 가상 환경에서 사용하는 파이썬 인터프리터는 여전히 시스템 `python -> /usr/bin/python`에서 사용할 수 있습니다. 가상화 프로세스는 인스턴스 격리만 처리합니다.

#### 가상 환경 활성화

구조에 나열된 파일 중에는 이 용도로 사용되는 **activate**라는 파일이 여러 개 있습니다. 각 파일의 접미사는 관련 *쉘*을 나타냅니다.

활성화는 이 Python 인스턴스를 시스템 인스턴스에서 분리하고 간섭 없이 문서 개발을 수행할 수 있도록 합니다. 활성화하려면 *env* 폴더로 이동하여 다음 명령을 실행합니다.

```bash
[rocky_user@rl9 rockydocs]$ cd ~/lab/rockydocs/env/
[rocky_user@rl9 env]$ source ./bin/activate
```

*activate* 명령은 Rocky Linux의 기본 쉘인 *bash* 쉘을 참조하기 때문에 접미사 없이 실행되었습니다. 이 시점에서 *셸 프롬프트*는 다음과 같아야 합니다.

```bash
(env) [rocky_user@rl9 env]$
```

보시다시피 초기 *(env)* 부분은 현재 가상 환경에 있음을 나타냅니다. 이 시점에서 가장 먼저 해야 할 일은 MkDocs를 설치하는 데 사용할 Python 모듈 관리자 **pip**를 업데이트하는 것입니다. 이렇게 하려면 다음 명령을 사용하십시오.

```bash
파이썬 -m pip 설치 --pip 업그레이드
```

```bash
python -m pip install --upgrade pip
Requirement already satisfied: pip in ./lib/python3.9/site-packages (21.2.3)
Collecting pip
  Downloading pip-23.1-py3-none-any.whl (2.1 MB)
    |████████████████████████████████| 2.1 MB 1.6 MB/s
Installing collected packages: pip
  Attempting uninstall: pip
    Found existing installation: pip 21.2.3
    Uninstalling pip-21.2.3:
      Successfully uninstalled pip-21.2.3
Successfully installed pip-23.1
```

#### 환경 비활성화

가상 환경을 종료하려면 *deactivate* 명령을 사용하십시오.

```bash
(env) [rocky_user@rl9 env]$ deactivate
[rocky_user@rl9 env]$
```

보시다시피 비활성화 후 터미널 *프롬프트*가 시스템 1로 되돌아갔습니다. *MkDocs* 설치 및 후속 명령을 실행하기 전에 항상 프롬프트를 주의 깊게 확인해야 합니다. *MkDocs* 설치 및 후속 명령을 실행하기 전에 항상 프롬프트를 주의 깊게 확인해야 합니다.

### 저장소 다운로드

이제 가상 환경을 만들고 관리하는 방법을 살펴보았으므로 필요한 모든 것을 준비할 수 있습니다.

Rocky Linux 문서의 로컬 버전을 구현하려면 두 개의 저장소(문서 저장소 [documentation](https://github.com/rocky-linux/documentation) 및 사이트 구조 저장소 [docs.rockylinux.org](https://github.com/rocky-linux/docs.rockylinux.org))가 필요합니다. 다운로드는 Rocky Linux GitHub에서 수행됩니다.

**rockydocs** 폴더에 복제할 사이트 구조 저장소로 시작합니다.

```bash
cd ~/lab/rockydocs/
git clone https://github.com/rocky-linux/docs.rockylinux.org.git
```

이 폴더에는 로컬 문서를 빌드하는 데 사용할 두 개의 파일이 있습니다. **mkdocs.yml**는 MkDocs를 초기화하는 데 사용되는 구성 파일이고, **requirement.txt**는 *mkdocs* 설치에 필요한 모든 파이썬 패키지가 들어 있습니다.

완료되면 설명서 리포지토리도 다운로드해야 합니다.

```bash
git clone https://github.com/rocky-linux/documentation.git
```

이 시점에서 **rockydocs** 폴더에 다음과 같은 구조가 있습니다.

```text
rockydocs/
├── env
├── docs.rockylinux.org
├── documentation
```

도식화하면 **env** 폴더가 당신의 *MkDocs* 엔진이 되어 **docs.rockylinux.org**를 컨테이너로 사용하여 **documentation** 구성에 포함된 데이터를 표시할 것이라고 말할 수 있습니다.

### MKDocs 설치

앞에서 지적했듯이 Rocky Linux 개발자는 MkDocs의 사용자 지정 인스턴스를 올바르게 실행하는 데 필요한 모듈 목록이 포함된 **requirement.txt** 파일을 제공합니다. 파일을 사용하여 단일 작업에 필요한 모든 것을 설치합니다.

먼저 파이썬 가상 환경에 들어갑니다:

```bash
[rocky_user@rl9 rockydocs]$ cd ~/lab/rockydocs/env/
[rocky_user@rl9 env]$ source ./bin/activate
(env) [rocky_user@rl9 env]$
```

다음으로 다음 명령을 사용하여 MkDocs 및 모든 구성 요소를 설치합니다.

```bash
(env) [rocky_user@rl9 env]$ python -m pip install -r ../docs.rockylinux.org/requirements.txt
```

모든 것이 잘 되었는지 확인하려면 사용 가능한 명령을 소개하는 MkDocs 도움말을 호출할 수 있습니다.

```bash
(env) [rocky_user@rl9 env]$ mkdocs -h
Usage: mkdocs [OPTIONS] COMMAND [ARGS]...

  MkDocs - Project documentation with Markdown.

옵션:
  -V, --version 버전을 표시하고 종료
  -q, --quiet 무음 경고
  -v, --verbose 상세 출력 활성화
  -h, --help 이 메시지를 표시하고 종료

Commands:
  build      Build the MkDocs documentation
  gh-deploy  Deploy your documentation to GitHub Pages
  new        Create a new MkDocs project
  serve      Run the builtin development server
```

모든 것이 계획대로 작동했다면 가상 환경을 종료하고 필요한 연결 준비를 시작할 수 있습니다.

```bash
(env) [rocky_user@rl9 env]$ deactivate
[rocky_user@rl9 env]$
```

### 문서 연결

이제 필요한 모든 것을 사용할 수 있으므로 *docs.rockylinux.org* 컨테이너 사이트 내에서 설명서 저장소를 연결하기만 하면 됩니다. *mkdocs.yml*에 정의된 설정을 따릅니다:

```yaml
docs_dir: 'docs/docs'
```

먼저 **docs.rockylinux.org**에 **docs**폴더를 만든 다음 그 안에 **documentation**리포지토리의 **docs** 폴더를 연결해야 합니다.

```bash
cd ~/lab/rockydocs/docs.rockylinux.org
mkdir docs
cd docs/
ln -s ../../documentation/docs/ docs
```

## 로컬 문서 시작

이제 Rocky Linux 문서의 로컬 복사본을 시작할 준비가 되었습니다. 먼저 Python 가상 환경을 시작한 다음 **docs.rockylinux.org/mkdocs.yml**에 정의된 설정으로 MkDocs 인스턴스를 초기화해야 합니다.

이 파일에는 현지화, 기능 관리 및 테마 관리에 필요한 모든 설정이 있습니다.

사이트의 UI 개발자는 [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/) 테마를 선택했습니다. 이 테마는 기본 MkDocs 테마에 대한 많은 추가 기능과 맞춤설정을 제공합니다.

다음 명령을 수행합니다:

```bash
[rocky_user@rl9 rockydocs]$ cd ~/lab/rockydocs/env/
[rocky_user@rl9 rockydocs]$ source ./bin/activate
(env) [rocky_user@rl9 env]$ mkdocs serve -f ../docs.rockylinux.org/mkdocs.yml
```

터미널에 사이트 구축 시작이 표시되어야 합니다. 디스플레이에는 누락된 링크 또는 기타와 같이 MkDocs에서 발견한 모든 오류가 표시됩니다.

```text
INFO     -  Building documentation...
INFO     -  Adding 'de' to the 'plugins.search.lang' option
INFO     -  Adding 'fr' to the 'plugins.search.lang' option
INFO     -  Adding 'es' to the 'plugins.search.lang' option
INFO     -  Adding 'it' to the 'plugins.search.lang' option
INFO     -  Adding 'ja' to the 'plugins.search.lang' option
...
...
INFO     -  Documentation built in 102.59 seconds
INFO     -  [11:46:50] Watching paths for changes:
            '/home/rocky_user/lab/rockydocs/docs.rockylinux.org/docs/docs',
            '/home/rocky_user/lab/rockydocs/docs.rockylinux.org/mkdocs.yml'
INFO     -  [11:46:50] Serving on http://127.0.0.1:8000/
```

지정된 주소(http://1127.0.0.1:8000)에서 브라우저를 열면 문서 사이트 사본이 실행됩니다. 사본은 기능과 구조 면에서 온라인 사이트를 완벽하게 반영하므로 페이지가 사이트에 미칠 모양과 영향을 평가할 수 있습니다.

MkDocs는 `docs_dir` 경로로 지정된 폴더의 파일에 대한 변경 사항을 확인하고 `documentation/docs`에서 새 페이지를 삽입하거나 기존 페이지를 수정하는 메커니즘을 통합합니다. 새로운 정적 사이트 빌드를 인식하고 생성합니다.

MkDocs가 정적 사이트를 구축하는 데 몇 분이 걸릴 수 있으므로 저장하거나 삽입하기 전에 작성 중인 페이지를 주의 깊게 검토하는 것이 좋습니다. 이렇게 하면 예를 들어 구두점을 잊어버려서 사이트가 구축될 때까지 기다리는 시간을 절약할 수 있습니다.

### 개발 환경 종료

새 페이지가 만족스럽게 표시되면 개발 환경을 종료할 수 있습니다. 여기에는 먼저 *MkDocs*를 종료한 다음 Python 가상 환경을 비활성화하는 작업이 포함됩니다. *MkDocs*를 종료하려면 <kbd>CTRL</kbd> + <kbd>C</kbd>키 조합을 사용해야 하며, 위에서 본 것처럼 가상 환경을 종료하려면 `deactivate`명령을 호출해야 합니다.

```bash
...
INFO     -  [22:32:41] Serving on http://127.0.0.1:8000/
^CINFO     -  Shutting down...
(env) [rocky_user@rl9 env]$
(env) [rocky_user@rl9 env]$ deacticate
[rocky_user@rl9 env]$
```

## 결론 및 최종 생각

로컬 개발 사이트에서 새 페이지를 확인하면 작업이 항상 온라인 설명서 사이트를 준수하므로 최적의 기여를 할 수 있습니다.

문서 규정 준수는 콘텐츠의 정확성만 처리하면 되는 문서 사이트의 큐레이터에게도 큰 도움이 됩니다.

결론적으로, 이 방법을 사용하면 컨테이너화에 의존할 필요 없이 MkDocs의 "깨끗한" 설치 요구사항을 충족할 수 있습니다.
