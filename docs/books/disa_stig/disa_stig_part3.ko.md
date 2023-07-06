---
title: DISA Apache 웹 서버 STIG
author: Scott Shinn
contributors: Steven Spencer
tested_with: 8.6
tags:
  - DISA
  - STIG
  - 보안
  - 기업
---

# 소개

이 시리즈의 파트1에서는 기본 RHEL8 DISA STIG를 적용하여 웹 서버를 구축하는 방법을 다루었고, 파트2에서는 OpenSCAP 도구로 STIG 준수를 테스트하는 방법을 배웠습니다. 이제 우리는 실제로 시스템에서 무언가를 수행하고, 간단한 웹 애플리케이션을 만들고 DISA 웹 서버 STIG를 적용해보겠습니다: https://www.stigviewer.com/stig/web_server/

먼저 여기에서 어떤 내용을 다루는지 비교해보겠습니다. RHEL 8 DISA STIG는 매우 특정한 플랫폼을 대상으로 하기 때문에 해당 컨트롤은 해당 컨텍스트에서 이해하고 테스트하고 적용하기에 꽤 쉽습니다.  애플리케이션 STIG는 여러 플랫폼에서 이식 가능해야 하므로 여기에 포함된 내용은 다양한 Linux 배포판(RHEL, Ubuntu, SuSE 등)**에서 작동하기 위해 범용적입니다. . 이는 OpenSCAP과 같은 도구를 사용하여 구성을 감사하고 복구할 수 없다는 것을 의미합니다. 우리는 이를 수동으로 수행해야 합니다. 해당 STIG는 다음과 같습니다.

* Apache 2.4 V2R5 - 서버; 웹 서버 자체에 적용됩니다
* Apache 2.4 V2R5 - 사이트; 웹 응용 프로그램/웹 사이트에 적용됩니다

이 가이드에서는 정적 콘텐츠만 제공하는 간단한 웹 서버를 생성합니다. 우리는 이곳에서 수행하는 변경 사항을 기반 이미지로 사용하고, 나중에 더 복잡한 웹 서버를 구축할 때 이 기반 이미지를 사용할 수 있습니다.

## Apache 2.4 V2R5 서버 빠른 시작

시작하기 전에 파트 1을 다시 참조하고 DISA STIG 보안 프로필을 적용해야 합니다. 이를 0 단계라고 생각해 봅시다.

1.) `apache` 및 `mod_ssl` 설치

```
    dnf install httpd mod_ssl
```

2.) 구성 변경

```
    sed -i 's/^\([^#].*\)**/# \1/g' /etc/httpd/conf.d/welcome.conf
    dnf -y remove httpd-manual
    dnf -y install mod_session

    echo “MaxKeepAliveRequests 100” > /etc/httpd/conf.d/disa-apache-stig.conf
    echo “SessionCookieName session path=/; HttpOnly; Secure;” >>  /etc/httpd/conf.d/disa-apache-stig.conf
    echo “Session On” >>  /etc/httpd/conf.d/disa-apache-stig.conf
    echo “SessionMaxAge 600” >>  /etc/httpd/conf.d/disa-apache-stig.conf
    echo “SessionCryptoCipher aes256” >>  /etc/httpd/conf.d/disa-apache-stig.conf
    echo “Timeout 10” >>  /etc/httpd/conf.d/disa-apache-stig.conf
    echo “TraceEnable Off” >>  /etc/httpd/conf.d/disa-apache-stig.conf
    echo “RequestReadTimeout 120” >> /etc/httpd/conf.d/disa-apache-stig.conf

    sed -i “s/^#LoadModule usertrack_module/LoadModule usertrack_module/g” /etc/httpd/conf.modules.d/00-optional.conf
    sed -i "s/proxy_module/#proxy_module/g" /etc/httpd/conf.modules.d/00-proxy.conf
    sed -i "s/proxy_ajp_module/#proxy_ajp_module/g" /etc/httpd/conf.modules.d/00-proxy.conf
    sed -i "s/proxy_balancer_module/#proxy_balancer_module/g" /etc/httpd/conf.modules.d/00-proxy.conf
    sed -i "s/proxy_ftp_module/#proxy_ftp_module/g" /etc/httpd/conf.modules.d/00-proxy.conf
    sed -i "s/proxy_http_module/#proxy_http_module/g" /etc/httpd/conf.modules.d/00-proxy.conf
    sed -i "s/proxy_connect_module/#proxy_connect_module/g" /etc/httpd/conf.modules.d/00-proxy.conf
```

  3.) 방화벽 정책 업데이트 및 `httpd` 시작

```
    firewall-cmd --zone=public --add-service=https --permanent
    firewall-cmd --zone=public --add-service=https
    firewall-cmd --reload
    systemctl enable httpd
    systemctl start httpd
```

## 세부 컨트롤 개요

여기까지 왔다면 STIG가 우리에게 무엇을 원하는지 더 알고 싶을 것입니다. 이 컨트롤의 중요성을 이해하고 어플리케이션에 어떻게 적용되는지 파악하는 것이 도움이 됩니다. 때로는 컨트롤이 기술적인 요소(X 설정을 Y로 변경) 일 수 있고, 때로는 운영적인 요소(사용 방법) 일 수도 있습니다.  일반적으로, 기술적인 컨트롤은 코드로 변경할 수 있는 것이고, 운영적인 컨트롤은 아마도 그렇지 않을 것입니다.

### 레벨

* Cat I - (HIGH) - 5개의 컨트롤
* Cat II - (MEDIUM) - 41개의 컨트롤
* Cat III - (LOW) - 1개의 컨트롤

### 유형

* 기술 - 24개의 컨트롤
* 운영 - 23개의 컨트롤

이 문서에서는 이러한 변경 사항에 대한 "이유"를 다루지 않고 기술적 제어인 경우 발생해야 하는 사항만 다루겠습니다.  운영적인 컨트롤인 경우와 같이 변경할 수 있는 것이 없는 경우 **Fix:** 필드는 없음일 것입니다. 이 경우에는 Rocky Linux 8의 기본값으로 이미 설정되어 있기 때문에 아무 것도 변경할 필요가 없습니다.

## Apache 2.4 V2R5 - 서버 세부 정보

**(V-214248)** Apache웹 서버 응용 프로그램 디렉토리, 라이브러리 및 구성 파일은 특권이 있는 사용자만 액세스할 수 있어야 합니다.

**심각도:** Cat I High  
**유형:** 운영  
**수정:** 없음, 권한이 있는 사용자만 웹서버 파일에 액세스할 수 있는지 확인하십시오.

**(V-214242)** Apache 웹 서버는 설명서, 샘플 코드, 예제 응용 프로그램 및 자습서의 설치를 제외하는 설치 옵션을 제공해야 합니다.

**심각도:** Cat I High  
**유형:** 기술  
**수정:**

```
sed -i 's/^\([^#].*\)/# \1/g' /etc/httpd/conf.d/welcome.conf
```

**(V-214253)** Apache 웹 서버는 무차별 공격의 위험을 줄이기 위해 가능한 한 많은 문자 집합을 사용하여 세션 ID를 생성해야 합니다.

**심각도:** Cat I High  
**유형:** 기술  
**수정:** 없음, Rocky Linux 8에서 기본적으로 해결됬습니다.

**(V-214273)** Apache 웹 서버 소프트웨어는 공급업체에서 지원하는 버전이어야 합니다.

**심각도:** Cat I High  
**유형:** 기술  
**수정:** 없음, Rocky Linux 8에서 기본적으로 해결됬습니다.

**(V-214271)** Apache 웹 서버를 실행하는 데 사용되는 계정은 유효한 로그인 셸과 비밀번호를 정의해서는 안 됩니다.

**심각도:** Cat I High  
**유형:** 기술  
**수정:** 없음, Rocky Linux 8에서 기본적으로 해결되었습니다.

**(V-214245)** Apache 웹 서버에서 WebDAV(Web Distributed Authoring)를 비활성화해야 합니다. **심각도:** Cat II Medium   
**유형:** 기술   
**수정:**

```
sed -i 's/^\([^#].*\)/# \1/g' /etc/httpd/conf.d/welcome.conf
```

**(V-214264)** 조직의 보안 인프라와 통합되도록 Apache 웹 서버를 구성해야 합니다.

**심각도:** Cat II Medium   
**유형:** 운영   
**수정:** 없음, 웹 서버 로그를 SIEM으로 전송합니다.


**(V-214243)** Apache 웹 서버는 특정 파일 유형의 서비스를 비활성화하기 위해 리소스 매핑을 설정해야 합니다.

**심각도:** Cat II 보통   
**유형:** 기술   
**수정:** 없음, Rocky Linux 8에서 기본적으로 해결되었습니다.


**(V-214240)** Apache 웹 서버는 운영에 필요한 서비스와 기능만 포함해야 합니다.

**심각도:** Cat II Medium   
**유형:** 기술   
**수정:**


```
dnf remove httpd-manual
```

**(V-214238)** 확장 모듈은 운영 Apache 웹 서버에 존재하기 전에 완전히 검토, 테스트 및 서명되어야 합니다.

**심각도:** Cat II Medium   
**유형:** 운영   
**수정:** 없음, 애플리케이션에 필요하지 않은 모든 모듈을 비활성화합니다.


**(V-214268)** Apache 웹 서버와 클라이언트 간에 교환되는 세션 쿠키와 같은 쿠키는 클라이언트 측 스크립트가 쿠키 데이터를 읽지 못하도록 쿠키 속성을 설정해야 합니다.

**심각도:** Cat II Medium   
**유형:** 기술   
**수정:**

```
dnf install mod_session 
echo “SessionCookieName session path=/; HttpOnly; Secure;” >>  /etc/httpd/conf.d/disa-apache-stig.conf
```

**(V-214269)** Apache 웹 서버는 전송된 정보의 기밀성과 무결성을 보호하기 위해 모든 내보내기 암호를 제거해야 합니다.

**심각도:** Cat II Medium   
**유형:** 기술   
**수정:** 없음, Rocky Linux 8 DISA STIG 보안 프로필에서 기본적으로 해결되었습니다.

**(V-214260)** Apache 웹 서버는 호스팅된 애플리케이션에 대한 원격 액세스를 즉시 끊거나 비활성화해야 합니다.

**심각도:** Cat II Medium   
**유형:** 운영   
**수정:** 없음, 웹 서버를 중지하는 절차입니다.

**(V-214249)** Apache 웹 서버는 호스팅된 애플리케이션과 호스팅된 Apache 웹 서버 관리 기능을 분리해야 합니다.

**심각도:** Cat II Medium   
**유형:** 운영   
**수정:** 없음, 웹 애플리케이션과 관련된 사항이며 서버와 관련된 것은 아닙니다.

**(V-214246)** Apache 웹 서버는 지정된 IP 주소와 포트를 사용하도록 구성되어야 합니다.

**심각도:** Cat II Medium   
**유형:** 운영   
**수정:** 없음, 웹 서버는 특정 IP/포트에서만 수신 대기하도록 구성되어야 합니다.

**(V-214247)** Apache 웹 서버 계정은 디렉터리 트리, 쉘 또는 기타 운영 체제 기능 및 유틸리티에 액세스하는 데 사용되는 계정은 관리 계정으로 제한되어야 합니다.

**심각도:** Cat II Medium   
**유형:** 운영   
**수정:** 없음, 웹 서버가 제공하는 모든 파일과 디렉터리는 관리자 계정이 소유해야 하며 웹 서버 사용자가 아니어야 합니다.

**(V-214244)** Apache 웹 서버는 사용되지 않는 취약한 스크립트에 대한 매핑을 제거할 수 있어야 합니다.

**심각도:** Cat II Medium   
**유형:** 운영   
**수정:** 없음, 사용되지 않는 cgi-bin 또는 기타 스크립트/ScriptAlias 매핑을 제거해야 합니다.

**(V-214263)** Apache 웹 서버는 지정된 감사 로그 서버에 특정 로그 기록 콘텐츠를 즉시 기록하지 않도록 해서는 안 됩니다.

**심각도:** Cat II Medium   
**유형:** 운영   
**수정:** 없음, SIEM 관리자와 협력하여 특정 로그 기록 콘텐츠를 감사 로그 서버에 기록할 수 있도록 설정합니다.

**(V-214228)** Apache 웹 서버는 허용되는 동시 세션 요청 수를 제한해야 합니다.

**심각도:** Cat II Medium   
**유형:** 기술   
**수정:**

```
echo “MaxKeepAliveRequests 100” > /etc/httpd/conf.d/disa-apache-stig.conf
```

**(V-214229)** Apache 웹 서버는 서버 측 세션 관리를 수행해야 합니다.

**심각도:** Cat II Medium   
**유형:** 기술   
**수정:**

```
sed -i “s/^#LoadModule usertrack_module/LoadModule usertrack_module/g” /etc/httpd/conf.modules.d/00-optional.conf
```

**(V-214266)** Apache 웹 서버는 비보안 또는 불필요한 포트, 프로토콜, 모듈 및/또는 서비스의 사용을 금지하거나 제한해야 합니다.

**심각도:** Cat II Medium   
**유형:** 운영   
**수정:** 없음, 웹 사이트에서 IANA의 잘 알려진 포트(HTTP 및 HTTPS) 의 사용을 강제화해야 합니다.

**(V-214241)** Apache 웹 서버는 프록시 서버로 사용해서는 안 됩니다.

**심각도:** Cat II Medium   
**유형:** 기술   
**수정:**

```
sed -i "s/proxy_module/#proxy_module/g" /etc/httpd/conf.modules.d/00-proxy.conf
sed -i "s/proxy_ajp_module/#proxy_ajp_module/g" /etc/httpd/conf.modules.d/00-proxy.conf
sed -i "s/proxy_balancer_module/#proxy_balancer_module/g" /etc/httpd/conf.modules.d/00-proxy.conf
sed -i "s/proxy_ftp_module/#proxy_ftp_module/g" /etc/httpd/conf.modules.d/00-proxy.conf
sed -i "s/proxy_http_module/#proxy_http_module/g" /etc/httpd/conf.modules.d/00-proxy.conf
sed -i "s/proxy_connect_module/#proxy_connect_module/g" /etc/httpd/conf.modules.d/00-proxy.conf
```

**(V-214265)** Apache 웹 서버는 최소한 1초의 정밀도로 기록되는 세계 협정시(UTC)** 또는 그리니치 평균시(GMT) 에 매핑할 수 있는 로그 기록을 생성해야 합니다.

**심각도:** Cat II Medium   
**유형:** 기술   
**수정:** 없음, Rocky Linux 8에서 기본적으로 해결됬습니다.

**(V-214256)** 클라이언트에 표시되는 경고 및 오류 메시지는 Apache 웹 서버, 패치, 로드된 모듈 및 디렉터리 경로의 식별을 최소화하기 위해 수정되어야 합니다.

**심각도:** Cat II Medium   
**유형:** 운영   
**수정:** 4xx 또는 5xx HTTP 상태 코드에 대해 사용자 정의 오류 페이지를 활성화하도록 "ErrorDocument" 지시문을 사용하세요.

**(V-214237)** Apache 웹 서버의 로그 데이터와 레코드는 다른 시스템이나 미디어로 백업되어야 합니다.

**심각도:** Cat II Medium   
**유형:** 운영   
**수정:** 없음, 웹 서버 백업 절차 문서화하세요.

**(V-214236)** Apache 웹 서버의 로그 정보는 무단 수정 또는 삭제로부터 보호되어야 합니다.

**심각도:** Cat II Medium   
**유형:** 운영   
**수정:** 없음, 웹 서버 백업 절차 문서화하세요.

**(V-214261)** 호스팅 시스템의 일반 사용자 계정은 Apache 웹 서버와 관련된 보안 관련 정보와 기능에 대해서는 구별된 관리 계정을 통해서만 액세스해야 합니다.       
**심각도:** Cat II Medium   
**유형:** 운영   
**수정:** 없음, 웹 관리 도구에 대한 액세스를 시스템 관리자, 웹 관리자 또는 웹 관리자 대리인에게만 제한하세요.

**(V-214235)** 권한이 있는 사용자만 Apache 웹 서버 로그 파일에 액세스할 수 있어야 합니다.

**심각도:** Cat II Medium   
**유형:** 운영   
**수정:** 없음, 로그 파일에 캡처되는 데이터의 무결성을 보호하기 위해 감사인 그룹, 관리자 및 웹 서버 소프트웨어를 실행할 사용자에게만 로그 파일을 읽을 수 있는 권한을 부여하세요.

**(V-214234)** Apache 웹 서버는 처리 실패가 발생한 경우 정보 시스템 보안 담당자(ISSO) 및 시스템 관리자(SA) 에게 경고할 수 있는 설정이 구성된 로그 기록을 생성해야 합니다.

**심각도:** Cat II Medium   
**유형:** 운영   
**수정:** 없음, 정의된 연결 일정에 따라 Apache에서 감사 데이터를 받지 못할 때 경고가 설정되도록 SIEM 관리자와 협력하세요.

**(V-214233)** 로드 밸런서 또는 프록시 서버 뒤에 있는 Apache 웹 서버는 각 이벤트마다 로드 밸런서 또는 프록시 IP 정보가 아닌 클라이언트 IP 정보를 포함하는 로그 기록을 생성해야 합니다.

**심각도:** Cat II Medium   
**유형:** 운영   
**수정:** 없음, 들어오는 웹 트래픽이 전달되는 프록시 서버에 액세스하고 웹 트래픽이 Apache 웹 서버로 투명하게 전달되도록 설정하세요.

프록시/로드 밸런싱 설정에 따른 로깅 옵션에 대한 추가 정보는 https://httpd.apache.org/docs/2.4/mod/mod_remoteip.html을 참조하십시오.

**(V-214231)** Apache 웹 서버에 시스템 로깅이 활성화되어 있어야 합니다.

**심각도:** Cat II Medium   
**유형:** 기술   
**수정:** 없음, Rocky Linux 8에서 기본적으로 해결됬습니다.

**(V-214232)** Apache 웹 서버는 시스템 시작 및 종료, 시스템 접근, 시스템 인증 이벤트에 대해 최소한의 로그 기록을 생성해야 합니다.

**심각도:** Cat II Medium   
**유형:** 기술   
**수정:** 없음, Rocky Linux 8에서 기본적으로 해결됬습니다.

V-214251 Apache 웹 서버와 클라이언트 간에 교환되는 세션 쿠키 등은 원본 Apache 웹 서버 및 호스팅된 응용 프로그램 외부에서 쿠키 액세스를 허용하지 않는 보안 설정을 가져야 합니다.

**심각도:** Cat II Medium   
**유형:** 기술    
**수정:**

```
echo “Session On” >>  /etc/httpd/conf.d/disa-apache-stig.conf
```

**(V-214250)** Apache 웹 서버는 호스팅된 응용 프로그램 사용자 로그아웃 또는 기타 세션 종료 시 세션 식별자를 무효화해야 합니다.

**심각도:** Cat II Medium   
**유형:** 기술   
**수정:**

```
echo “SessionMaxAge 600” >>  /etc/httpd/conf.d/disa-apache-stig.conf
```

**(V-214252)** Apache 웹 서버는 브루트 포스를 통해 추측할 수 없을 정도로 충분히 긴 세션 ID를 생성해야 합니다.

**심각도:** Cat II Medium   
**유형:** 기술    
**수정:**

```
echo “SessionCryptoCipher aes256” >>  /etc/httpd/conf.d/disa-apache-stig.conf
```

**(V-214255)** Apache 웹 서버는 호스팅된 응용 프로그램의 운영 요구 사항을 처리할 수 있도록 조정되어야 합니다.

**심각도:** Cat II Medium   
**유형:** 기술   
**수정:**

```
echo “Timeout 10” >>  /etc/httpd/conf.d/disa-apache-stig.conf
```

**(V-214254)** Apache 웹 서버는 시스템 초기화, 종료 또는 중단이 실패할 경우 알려진 안전 상태로 실패해야 합니다.

**심각도:** Cat II Medium   
**유형:** 운영   
**수정:** 없음, 롤백이 필요한 경우 Apache 2.4 웹 서버에 대한 재해 복구 방법 문서 작성하세요.

**(V-214257)** Apache 웹 서버의 진단을 위해 사용되는 디버깅 및 추적 정보는 비활성화되어야 합니다.

**심각도:** Cat II Medium   
**유형:** 기술   
**수정:**

```
echo “TraceEnable Off” >>  /etc/httpd/conf.d/disa-apache-stig.conf
```

**(V-214230)** Apache 웹 서버는 원격 세션의 무결성을 보호하기 위해 암호화를 사용해야 합니다.

**심각도:** Cat II Medium   
**유형:** 기술   
**수정:**

```
sed -i "s/^#SSLProtocol.*/SSLProtocol -ALL +TLSv1.2/g" /etc/httpd/conf.d/ssl.conf
```

**(V-214258)** Apache 웹 서버는 세션에 대해 비활성 시간 제한을 설정해야 합니다.

**심각도:** Cat II Medium   
**유형:** 기술   
**수정:**

```
echo “RequestReadTimeout 120” >> /etc/httpd/conf.d/disa-stig-apache.conf
```

**(V-214270)** Apache 웹 서버는 권위 있는 소스(IATM, CTO, DTM 및 STIG 등)가 지시하는 구성된 시간 내에 보안 관련 소프트웨어 업데이트를 설치해야 합니다.

**심각도:** Cat II Medium   
**유형:** 운영   
**수정:** 없음, 최신 버전의 웹 서버 소프트웨어를 설치하고 적절한 서비스 팩과 패치를 유지하세요.

**(V-214239)** Apache 웹 서버는 호스팅된 애플리케이션에 대한 사용자 관리를 수행해서는 안 됩니다.

**심각도:** Cat II Medium   
**유형:** 기술   
**수정:** 없음, Rocky Linux 8에서 기본적으로 해결됬습니다.

**(V-214274)** Apache 웹 서버의 htpasswd 파일(있는 경우) 은 적절한 소유권 및 권한을 반영해야 합니다.

**심각도:** Cat II Medium   
**유형:** 운영    
**수정:** 없음, SA 또는 웹 관리자 계정이 "htpasswd" 파일을 소유하는지 확인합니다.  권한이 "550"으로 설정되어 있는지 확인하십시오.

**(V-214259)** Apache 웹 서버는 비보안 영역에서의 들어오는 연결을 제한해야 합니다.

**심각도:** Cat II Medium   
**유형:** 운영   
**수정:** 없음, "http.conf" 파일을 구성하여 제한을 포함하세요.   
예:

```
Require not ip 192.168.205
Require not host phishers.example.com
```

**(V-214267)** 권한이 없는 사용자가 Apache 웹 서버를 중지하지 못하도록 보호해야 합니다.

**심각도:** Cat II Medium   
**유형:** 기술   
**수정:** 없음, Rocky Linux 8에서 기본적으로 해결됬습니다.

**(V-214262)** Apache 웹 서버는 Apache 웹 서버의 로깅 요구 사항을 수용할 수 있도록 로그 기록 저장 용량을 할당하는 로깅 메커니즘을 사용해야 합니다.

**심각도:** Cat II Medium   
**유형:** 운영   
**수정:** 없음, SIEM 관리자와 협력하여 SIEM이 Apache 웹 서버의 로깅 요구 사항을 수용할 수 있도록 로그 기록 저장 용량을 할당하는지 확인하세요.

**(V-214272)** Apache 웹 서버는 DoD 보안 구성 또는 구현 지침(예: STIG, NSA 구성 가이드, CTO 및 DTM) 에 따라 보안 구성 설정으로 구성되어야 합니다.

**심각도:** Cat III Low   
**유형:** 운영   
**수정:** 없음

## 저자 소개

Scott Shinn은 Atomomicorp의 CTO이자 Rocky Linux Security 팀의 일원입니다. 그는 1995년부터 백악관, 국방부 및 정보 커뮤니티에서 연방 정보 시스템에 참여했습니다. 그 중 일부는 STIG를 생성하고 사용해야 하는 요구사항이었는데, 이에 대해 매우 유감스럽게 생각합니다.

