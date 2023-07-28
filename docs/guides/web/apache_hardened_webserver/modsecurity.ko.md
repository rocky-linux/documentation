---
title: 웹 기반 애플리케이션 방화벽 (WAF - Web-based Application Firewall)
author: Steven Spencer
contributors: Ezequiel Bruni
tested_with: 8.8, 9.2
tags:
  - web
  - security
  - apache
  - nginx
---
  
# 웹 기반 애플리케이션 방화벽 (WAF - Web-based Application Firewall)

## 필요 사항

* Apache가 설치된 Rocky Linux 웹 서버
* 명령 줄 편집기에 대한 능숙함 (이 예시에서는 _vi_를 사용합니다).
* 명령 줄에서 명령을 실행하고 로그를 보는 등 일반적인 시스템 관리자 업무에 대한 높은 숙련도.
* 이 도구를 설치하려면 작업 모니터링 및 환경 조정도 필요합니다.
* 루트 사용자는 모든 명령을 실행하거나 `sudo`로 일반 사용자를 실행합니다.

## 소개

_mod_security_는 오픈 소스 기반의 웹 응용 프로그램 방화벽(WAF)입니다. 이것은 강화된 Apache 웹 서버 구성의 가능한 한 부분일 뿐입니다. 다른 도구와 함께 사용하거나 독립적으로 사용할 수 있습니다.

보다 강화된 보안을 위해 이것을 다른 도구와 함께 사용하려면 [Apache Hardened Web Server 가이드](index.md)를 참조하십시오. 이 문서는 해당 원본 문서에서 제시한 가정과 규칙을 모두 사용합니다. 계속하기 전에 검토하는 것이 좋습니다.

일반 Rocky Linux 저장소에서 설치한 `mod_security`의 한 가지 부족한 점은 최소한의 규칙만 포함되어 있다는 것입니다. `mod_security`규칙의 보다 광범위한 패키지를 가져오려면 [여기](https://www.netnea.com/)에서 찾을 수 있는 비용이 들지 않는 OWASP mod_security 규칙을 사용합니다. OWASP는 Open Web Application Security Project의 약자입니다. OWASP에 대한 자세한 내용은 [여기](https://owasp.org/)에서 확인할 수 있습니다.

!!! tip "팁"

    tip "팁"
        위 설명에 따라서, 이 절차는 OWASP <code>mod_security 규칙을 사용합니다. 사용하지 않는 것은 해당 사이트에서 제공하는 설정입니다. 해당 사이트에서는 mod_security와 다른 보안 관련 도구에 대한 좋은 튜토리얼도 제공하고 있습니다. 현재 작업 중인 문서는 Rocky Linux 웹 서버에서 mod_security를 하드닝하기 위해 필요한 도구와 규칙을 설치하는 데 도움이 되는 것 뿐입니다. Netnea는 보안 관련 강의를 제공하는 기술 전문가들로 구성된 팀입니다. 이 사이트의 많은 콘텐츠가 무료로 이용 가능하지만, *내부 교육이나 그룹 교육 옵션도 제공*하고 있습니다.
    </code>

## mod_security 설치

기본 패키지를 설치하려면 다음 명령을 사용하세요. 필요한 종속성도 설치됩니다. 만약 `wget`이 설치되어 있지 않다면 설치하세요.

```
dnf install mod_security wget
```

## `mod_security`규칙 설치

!!! note "참고사항"

    이 절차를 주의 깊게 따라야 합니다. Netnea의 설정은 Rocky Linux에 맞게 변경되었습니다.

1. OWASP 규칙의 현재 버전을 [이 GitHub 사이트](https://github.com/coreruleset/coreruleset)에서 확인하세요.

2. 페이지 오른쪽 상단에서 릴리스를 검색하고 최신 릴리스 태그를 클릭하세요.

3. 다음 페이지의 "Assets"에서 "Source Code (tar.gz)" 링크를 마우스 오른쪽 버튼으로 클릭하고 링크를 복사하세요.

4. 서버로 이동하여 Apache 설정 디렉토리로 이동하세요.

    ```
    cd /etc/httpd/conf
    ```

5. `wget` 명령을 사용하여 링크를 다운로드하세요. 예시:

    ```
    wget https://github.com/coreruleset/coreruleset/archive/refs/tags/v3.3.4.tar.gz
    ```

6. 파일을 압축 해제하세요.

    ```
    tar xzvf v3.3.4.tar.gz
    ```
    이렇게 하면 "coreruleset-3.3.4"와 같은 이름의 릴리스 정보가 있는 디렉토리가 생성됩니다. Example: "coreruleset-3.3.4"

7. 해당 릴리스 디렉토리에 대한 "crs"라는 심볼릭 링크를 생성하세요. 예시:

    ```
    ln -s coreruleset-3.3.4/ /etc/httpd/conf/crs
    ```

8. `tar.gz` 파일을 삭제하세요. 예시:

    ```
    rm -f v3.3.4.tar.gz
    ```

9. 임시 구성을 복사하여 시작할 때 로드되도록 하세요.

    ```
    cp crs/crs-setup.conf.example crs/crs-setup.conf
    ```
    이 파일은 수정할 수 있지만 아마도 변경할 필요가 없을 것입니다.

`mod_security` 규칙이 이제 설치되었습니다.

## 구성

규칙이 설치되었으므로 다음 단계는 `httpd`와 `mod_security`를 실행할 때 이러한 규칙을 로드하고 실행하는 것입니다.

`mod_security`는 이미 `/etc/httpd/conf.d/mod_security.conf`라는 구성 파일이 있습니다. 이 파일을 수정하여 OWASP 규칙을 포함시켜야 합니다. 이를 위해 구성 파일을 편집하세요:

```
vi /etc/httpd/conf.d/mod_security.conf
```
아래 내용을 (`</IfModule`) 태그 바로 전에 추가하세요:

```
    Include    /etc/httpd/conf/crs/crs-setup.conf

    SecAction "id:900110,phase:1,pass,nolog,\
        setvar:tx.inbound_anomaly_score_threshold=10000,\
        setvar:tx.outbound_anomaly_score_threshold=10000"

    SecAction "id:900000,phase:1,pass,nolog,\
         setvar:tx.paranoia_level=1"


    # === ModSec Core Rule Set: Runtime Exclusion Rules (ids: 10000-49999)

    # ...


    # === ModSecurity Core Rule Set Inclusion

    Include    /etc/httpd/conf/crs/rules/*.conf


    # === ModSec Core Rule Set: Startup Time Rules Exclusions

    # ...
```

삽입 모드를 빠져나가려면 <kbd>ESC</kbd>를 사용하고 변경 사항을 저장하고 종료하려면 <kbd>SHIFT</kbd>+<kbd>:</kbd>+<kbd>wq</kbd>를 입력하세요.

## `httpd` 재시작 및 `mod_security` 확인

이 시점에서 할 일은 `httpd`를 재시작하는 것뿐입니다.

```
systemctl restart httpd
```

서비스가 예상대로 시작되었는지 확인하세요.

```
systemctl status httpd
```

`/var/log/httpd/error_log`에 이와 같은 항목들이 나타나면 `mod_security`가 올바르게 로드된 것을 확인할 수 있습니다.

```
[Thu Jun 08 20:31:50.259935 2023] [:notice] [pid 1971:tid 1971] ModSecurity: PCRE compiled version="8.44 "; loaded version="8.44 2020-02-12"
[Thu Jun 08 20:31:50.259936 2023] [:notice] [pid 1971:tid 1971] ModSecurity: LUA compiled version="Lua 5.4"
[Thu Jun 08 20:31:50.259937 2023] [:notice] [pid 1971:tid 1971] ModSecurity: YAJL compiled version="2.1.0"
[Thu Jun 08 20:31:50.259939 2023] [:notice] [pid 1971:tid 1971] ModSecurity: LIBXML compiled version="2.9.13"
```

서버에서 웹 사이트에 접속하면 `/var/log/httpd/modsec_audit.log`에 OWASP 규칙 로딩이 표시됩니다:

```
Apache-Handler: proxy:unix:/run/php-fpm/www.sock|fcgi://localhost
Stopwatch: 1686249687051191 2023 (- - -)
Stopwatch2: 1686249687051191 2023; combined=697, p1=145, p2=458, p3=14, p4=45, p5=35, sr=22, sw=0, l=0, gc=0
Response-Body-Transformed: Dechunked
Producer: ModSecurity for Apache/2.9.6 (http://www.modsecurity.org/); OWASP_CRS/3.3.4.
Server: Apache/2.4.53 (Rocky Linux)
Engine-Mode: "ENABLED"
```
## 결론

OWASP 규칙이 포함된 `mod_security`는 Apache 웹 서버를 하드닝하는 데 도움이 되는 또 다른 도구입니다. 새로운 규칙을 확인하려면 주기적으로 [GitHub 사이트와 최신 공식](https://github.com/coreruleset/coreruleset) 릴리스를 확인해야 합니다.

mod_security 및 다른 하드닝 도구와 마찬가지로 잘못된 양성 반응이 발생할 수 있으므로 설치에 맞게 이 도구를 조정해야 합니다.

[Apache 강화 웹서버 가이드](index.md)에서 언급한 다른 솔루션처럼, `mod_security` 규칙을 위한 무료 및 유료 솔루션과 다른 WAF 애플리케이션도 사용할 수 있습니다. [Atomicorp의 `mod_security`](https://atomicorp.com/atomic-modsecurity-rules/) 사이트에서 이 중 하나를 검토할 수 있습니다.
