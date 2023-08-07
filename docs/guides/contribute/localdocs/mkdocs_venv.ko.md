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

Rocky Linux의 문서를 작성하는 프로세스 중 하나는 게시 전에 새 문서가 올바르게 표시되는지 확인하는 것입니다.

이 안내서의 목적은 이 작업을 전용 로컬 python 환경에서 수행하는 몇 가지 제안을 제공하는 것입니다.

Rocky Linux의 문서는 일반적으로 다른 형식으로 변환되는 Markdown 언어를 사용하여 작성됩니다. Markdown은 구문이 간결하며 기술 문서 작성에 특히 적합한 언어입니다.

우리의 경우, 문서는 MkDocs라는 애플리케이션을 사용하여 `HTML`로 변환되며, 이 애플리케이션은 정적 사이트를 빌드하는 작업을 처리합니다. 개발자들이 사용하는 애플리케이션은 [MkDocs](https://www.mkdocs.org/)입니다.

파이썬 애플리케이션을 개발하는 과정에서 발생하는 문제 중 하나는 개발에 사용하는 파이썬 인스턴스를 시스템 인터프리터와 격리시키는 것입니다. 이 격리는 파이썬 애플리케이션을 설치하는 데 필요한 모듈과 호스트 시스템에 설치된 모듈 사이의 호환성 문제를 방지하기 위한 것입니다.

이미 파이썬 인터프리터를 격리하기 위해 **컨테이너**를 사용하는 훌륭한 안내서가 있습니다. 그러나 이러한 안내서는 다양한 컨테이너화 기술에 대한 지식을 전제로 합니다.

이 가이드에서는 이러한 분리를 위해 Rocky Linux의 *python* 패키지에 포함된 특별히 개발된 모듈인 *python* `venv` 모듈을 사용합니다. 이 모듈은 Python 버전 3.6 이후의 모든 새 버전에서 사용할 수 있습니다. 이를 통해 시스템의 파이썬 인터프리터를 직접 격리시킬 수 있습니다. 따라서 새로운 "**시스템**"을 설치하고 구성할 필요가 없습니다.

### 요구 사항

- Rocky Linux가 실행 중인 상태
- *python* 패키지가 올바르게 설치됨
- 커맨드 라인에 대한 익숙함
- 활발한 인터넷 접속

## 환경 준비

환경은 두 개의 필수 Rocky Linux GitHub 저장소를 포함하고 있으며, 가상 환경에서 python을 초기화하고 실행할 폴더를 제공하는 루트 폴더를 제공합니다.

먼저, 다른 모든 것을 포함할 폴더를 생성하고 이에 따라 MkDocs가 실행될 **env** 폴더도 만듭니다.

```bash
mkdir -p ~/lab/rockydocs/env
```

### Python 가상 환경

MkDocs가 실행될 파이썬을 생성하려면 특별히 이 목적으로 개발된 모듈인 python`venv` 모듈을 사용하세요. 이를 사용하여 가상 환경을 생성하면 시스템에 설치된 환경에서 파생된 완전히 격리되고 독립된 가상 환경이 생성됩니다.

이를 통해 Rocky Linux 문서를 실행하는 데 `MkDocs`에 필요한 패키지만 포함된 별도의 폴더에서 인터프리터의 사본을 갖게 됩니다.

방금 폴더(*rockydocs*)로 이동하고 다음을 명령을 사용하여 가상 환경을 생성하세요.

```bash
cd ~/lab/rockydocs/
python -m venv env
```

이 명령은 **env** 폴더에 시스템의 *python* 트리와 비슷한 일련의 폴더와 파일을 포함합니다.

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

보시다시피, 가상 환경에서 사용하는 python 인터프리터는 여전히 시스템에서 사용 가능한 인터프리터인 `python -> /usr/bin/python`입니다. 가상화 프로세스는 인스턴스를 격리하는 데만 관여합니다.

#### 가상 환경 활성화

구조에 나열된 파일 중 여러 파일 이름에는 해당 목적을 제공하는 여러 개의 **activate** 파일이 있습니다. 각 파일의 접미사는 관련된 *셸*을 나타냅니다.

활성화는 이 파이썬 인스턴스를 시스템 인스턴스와 분리하고 간섭없이 문서 개발을 수행할 수 있도록 합니다. 가상 환경으로 활성화하려면 *env* 폴더로 이동하고 다음 명령을 실행하세요.

```bash
[rocky_user@rl9 rockydocs]$ cd ~/lab/rockydocs/env/
[rocky_user@rl9 env]$ source ./bin/activate
```

*activate* 명령은 *bash* 셸(기본 셸)인 경우에는 접미사를 사용하지 않았습니다. 이제 *쉘 프롬프트*는 다음과 같아야 합니다.

```bash
(env) [rocky_user@rl9 env]$
```

처음 부분 *(env)*은 이제 가상 환경에 있다는 것을 나타냅니다. 이 시점에서 해야 할 첫 번째 작업은 pip를 업데이트하는 것입니다. **pip**는 MkDocs를 설치하는 데 사용되는 python 모듈 관리자입니다. 이렇게 하려면 다음 명령을 사용하십시오.

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

활성화 해제 후 터미널 프롬프트가 시스템 *프롬프트*로 복귀된 것을 볼 수 있습니다. *MkDocs* 설치 및 후속 명령 실행 전에 항상 프롬프트를 주의 깊게 확인하는 것이 좋습니다. 이렇게 함으로써 불필요하고 원치 않는 글로벌 응용 프로그램 설치 및 `MkDocs serve` 실행을 방지할 수 있습니다.

### 저장소 다운로드

이제 가상 환경을 만드는 방법과 관리하는 방법을 살펴보았으므로 필요한 모든 것을 준비할 차례입니다.

Rocky Linux 문서의 로컬 버전을 구현하려면 두 개의 저장소(문서 저장소 [documentation](https://github.com/rocky-linux/documentation) 및 사이트 구조 저장소 [docs.rockylinux.org](https://github.com/rocky-linux/docs.rockylinux.org))가 필요합니다. 이들을 다운로드하는 작업은 Rocky Linux GitHub에서 수행됩니다.

먼저, 사이트 구조 저장소부터 시작하며 이를 **rockydocs** 폴더에 복제합니다.

```bash
cd ~/lab/rockydocs/
git clone https://github.com/rocky-linux/docs.rockylinux.org.git
```

이 폴더에는 로컬 문서를 빌드하는 데 사용할 두 개의 파일이 있습니다. 이 폴더에는 로컬 문서를 빌드하는 데 사용되는 설정 파일인 **mkdocs.yml**과 *mkdocs*를 설치하는 데 필요한 모든 파이썬 패키지가 포함된 **requirement.txt** 파일이 두 개 있습니다.

완료되면 documentation 저장소를 다운로드하세요.

```bash
git clone https://github.com/rocky-linux/documentation.git
```

이 시점에서 **rockydocs** 폴더에 다음과 같은 구조가 있을 것입니다.

```text
rockydocs/
├── env
├── docs.rockylinux.org
├── documentation
```

구조를 요약하면 **env** 폴더는 *MkDocs* 엔진이 되며, **docs.rockylinux.org**은 **documentation**에 포함된 데이터를 표시하는 컨테이너로 사용됩니다.

### MKDocs 설치

앞에서 언급했듯이, Rocky Linux 개발자들은 MkDocs의 사용자 정의 인스턴스를 올바르게 실행하기 위해 필요한 모듈 목록이 포함된 **requirement.txt** 파일을 제공합니다. 이 파일을 사용하여 한 번의 작업으로 필요한 모든 것을 설치합니다.

먼저 python 가상 환경으로 들어가세요.

```bash
[rocky_user@rl9 rockydocs]$ cd ~/lab/rockydocs/env/
[rocky_user@rl9 env]$ source ./bin/activate
(env) [rocky_user@rl9 env]$
```

다음으로, 다음 명령을 사용하여 MkDocs와 모든 구성 요소를 설치하세요.

```bash
(env) [rocky_user@rl9 env]$ python -m pip install -r ../docs.rockylinux.org/requirements.txt
```

모든 것이 원활하게 진행되었는지 확인하려면 사용 가능한 명령을 설명하는 MkDocs 도움말을 호출할 수 있습니다.

```bash
(env) [rocky_user@rl9 env]$ mkdocs -h
Usage: mkdocs [OPTIONS] COMMAND [ARGS]...

  MkDocs - Project documentation with Markdown.

옵션:
  -V, --version 버전을 표시하고 종료
  -q, --quiet 무음 경고
  -v, --verbose 상세 출력 활성화
  -h, --help 이 메시지를 표시하고 종료

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

모든 것이 계획대로 작동했다면 가상 환경을 종료하고 필요한 연결을 준비하십시오.

```bash
(env) [rocky_user@rl9 env]$ deactivate
[rocky_user@rl9 env]$
```

### 문서 연결

이제 필요한 모든 것이 준비되었으므로 documentation 저장소를 *docs.rockylinux.org* 컨테이너 사이트 내에 연결해야 합니다. *mkdocs.yml*에서 정의한 설정에 따라서입니다.

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

이 파일에는 로컬화, 기능 관리 및 테마 관리에 필요한 모든 설정이 포함되어 있습니다.

사이트의 UI 개발자는 [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/) 테마를 선택했으며, 기본 MkDocs 테마보다 많은 기능과 사용자 정의 기능을 제공합니다.

다음 명령을 실행하세요.

```bash
[rocky_user@rl9 rockydocs]$ cd ~/lab/rockydocs/env/
[rocky_user@rl9 rockydocs]$ source ./bin/activate
(env) [rocky_user@rl9 env]$ mkdocs serve -f ../docs.rockylinux.org/mkdocs.yml
```

터미널에서 사이트 구축이 시작되는 것을 볼 수 있습니다. MkDocs가 발견한 누락된 링크 또는 기타 오류를 표시할 것입니다.

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

지정된 주소 (http://1127.0.0.1:8000)에서 브라우저를 열면 로컬 문서 사이트가 실행됩니다. 사이트는 기능과 구조에서 온라인 사이트를 완벽히 반영하므로 페이지의 모양과 사이트에 미치는 영향을 평가할 수 있습니다.

MkDocs는 `docs_dir` 경로로 지정된 폴더의 파일 변경을 확인하고, `documentation/docs`에서 새 페이지를 삽입하거나 기존 페이지를 수정하면 자동으로 새 정적 사이트 빌드를 생성합니다.

MkDocs가 정적 사이트를 빌드하는 데 걸리는 시간이 몇 분이 될 수 있으므로, 페이지를 저장하거나 삽입하기 전에 작성한 페이지를 주의 깊게 검토하는 것이 권장됩니다. 예를 들어, 구두점을 잊어버렸다면 사이트를 빌드하는 데 시간이 걸리는 것을 피할 수 있습니다.

### 개발 환경 종료

새 페이지의 표시가 만족스럽다면 개발 환경을 종료할 수 있습니다. 먼저 *MkDocs*를 종료하고, 그 다음에 python 가상 환경을 비활성화해야 합니다. *MkDocs*를 종료하려면 <kbd>CTRL</kbd> + <kbd>C</kbd>키 조합을 사용하고, 앞에서 본대로 python 가상 환경을 비활성화하려면 `deactivate` 명령을 호출해야 합니다.

```bash
...
INFO     -  [22:32:41] Serving on http://127.0.0.1:8000/
^CINFO     -  Shutting down...
(env) [rocky_user@rl9 env]$
(env) [rocky_user@rl9 env]$ deacticate
[rocky_user@rl9 env]$
```

## 결론 및 최종 생각

로컬 개발 사이트에서 새 페이지를 확인함으로써 작업이 항상 온라인 문서 사이트와 일치함을 확신할 수 있습니다. 이는 기여를 최적화하기 위해 문서 사이트의 일관성에도 큰 도움이 됩니다.

문서 일치는 또한 문서 사이트 관리자들에게 큰 도움이 되며, 이로써 콘텐츠의 정확성에만 집중하면 됩니다.

마지막으로, 컨테이너화를 사용하지 않고도 "깨끗한" MkDocs 설치 요구 사항을 충족하는 방법을 제공하는 것으로 결론짓을 수 있습니다.
