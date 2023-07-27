---
title: Nginx 다중 사이트
author: Ezequiel Bruni
contributors: Steven Spencer
tested_with: 8.5
tags:
  - web
  - nginx
  - multisite
---

# Rocky Linux에서 다중 웹사이트를 위한 Nginx 설정하는 방법

## 소개

Rocky Linux에서 Nginx 다중 사이트 설정에 대한 가이드입니다. 초보자를 위한 팁으로 시작하겠습니다. 나머지는 이미 알고 있는 내용이므로 아래로 스크롤하시면 됩니다.

안녕하세요 초보자 분들! Nginx의 한 가지 *주요* 기능은 한 서버 또는 여러 서버의 여러 웹사이트 및 앱으로의 트래픽을 한 곳에서 효율적으로 관리할 수 있다는 점입니다. 이 기능을 "리버스 프록시"라고 하며, Nginx가 상대적으로 쉽게 이를 구현할 수 있는 이유 중 하나입니다.

여기에서는 단일 Nginx 설치에서 여러 웹사이트를 관리하는 방법을 간단하고 체계적으로 소개하겠습니다. 이 방법을 사용하면 변경 사항을 빠르고 쉽게 적용할 수 있습니다.

아파치에 대한 유사한 설정을 찾는 경우 [이 가이드](apache-sites-enabled.md)를 참조하세요.

*많은* 상세한 내용을 설명할 예정이지만, 전체 과정은 기본적으로 몇 개의 폴더를 설정하고 몇 개의 작은 텍스트 파일을 만드는 것입니다. 이 가이드에서는 복잡한 웹사이트 설정을 사용하지 않으므로 커피 한 잔 들이키면서 즐겁게 따라오세요. 한 번 익힌 후에는 몇 분만에 완료할 수 있습니다. 이건 쉬워요.\*

\* "쉬워요"라는 값에 따라 다를 수 있습니다.

## 전제 조건 및 가정

다음이 필요합니다:

* 이미 Nginx가 설치된 인터넷에 연결된 Rocky Linux 서버입니다. 아직 설치하지 않은 경우 [ Nginx 설치 가이드](nginx-mainline.md)를 먼저 따라하십시오.
* 명령 줄에서 작업하고, `nano`와 같은 터미널 기반 텍스트 편집기에 익숙해야 합니다.

    !!! 팁 "급한 경우"
  
        ... Filezilla나 WinSCP와 같은 도구와 GUI 기반 텍스트 편집기를 사용하여 이러한 단계의 대부분을 수행할 수도 있지만, 이 튜토리얼에서는 Nerdy한 방법을 사용하겠습니다.

* 테스트 웹사이트 중 하나를 서버에 가리키는 도메인이 적어도 하나 필요합니다. 나머지 웹사이트에는 두 번째 도메인이나 서브도메인을 사용할 수 있습니다.

    !!! !!!
  
        로컬 서버에서 이 모든 작업을 수행하는 경우 호스트 파일을 필요에 따라 조정하여 시뮬레이션된 도메인 이름을 생성하십시오. 아래에 지침이 나와 있습니다.

* Nginx를 베어 메탈 서버 또는 일반 VPS에서 실행하고 SELinux가 실행 중인 것으로 가정합니다. 모든 지침은 기본적으로 SELinux와 호환됩니다.
* *모든 명령은 root로 실행해야 합니다*. 즉, root 사용자로 로그인하거나 `sudo`를 사용해야 합니다.

## 폴더 및 테스트 사이트 설정하기

### 웹사이트 폴더
먼저, 웹사이트 파일을 위한 몇 개의 폴더가 필요합니다. Nginx를 처음 설치하면 "데모" 웹사이트 파일이 `/usr/share/nginx/html`에 있습니다. 하나의 사이트만 호스팅하는 경우에는 문제가 없지만, 여러 사이트를 호스팅할 것입니다. 일단 `html` 디렉토리를 무시하고 상위 폴더로 이동합니다:

```bash
cd /usr/share/nginx
```

이 튜토리얼에서 테스트를 위한 도메인은 `site1.server.test`와 `site2.server.test`이며, 이에 해당하는 웹사이트 폴더의 이름을 사용할 것입니다. 필요한 경우 이 도메인을 자신이 사용하는 도메인으로 변경하시기 바랍니다. 그러나 (여기서는 Smarter People<sup>TM</sup>에게서 배운 꿀팁이 있습니다), 도메인 이름을 "역순"으로 작성할 것입니다.

예: "yourwebsite.com"은 `com.yourwebsite`라는 이름의 폴더에 들어갑니다. 실제로 이 폴더 이름을 원하는 대로 *직접* 지정할 수도 있지만, 아래에서 이 방법의 장점에 대해 설명하겠습니다.

일단 폴더를 생성하세요:

```bash
mkdir -p test.server.site1/html
mkdir -p test.server.site2/html
```

위 명령은 예를 들어 `test.server.site1` 폴더를 생성하고 그 안에 `html`이라는 폴더를 만듭니다. 그곳에 웹 서버를 통해 제공할 실제 파일을 넣을 것입니다. (대신 "webroot" 또는 이와 유사한 이름을 사용할 수도 있습니다.)

이렇게 하면 공개하고 싶지 *않은* 웹사이트 관련 파일을 상위 디렉토리에 둘 수 있습니다.

!!! note "참고 사항"

    `-p` 플래그는 `mkdir` 명령에게 방금 정의한 경로에 없는 폴더를 생성하도록 지시하여 각 폴더를 하나씩 만들지 않아도 되도록 합니다.

테스트를 위해 "웹사이트" 자체를 매우 간단하게 유지합니다. 첫 번째 폴더에 원하는 텍스트 편집기로 HTML 파일을 생성하세요:

```bash
nano test.server.site1/html/index.html
```

다음 HTML 코드를 복사하여 붙여넣으세요:

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Site 1</title>
</head>
<body>
    <h1>This is Site 1</h1>
</body>
</html>
```

파일을 저장하고 닫은 다음 `test.server.site2` 폴더에 대해 동일한 단계를 반복하세요. 상단의 HTML 코드에서 "Site 1"을 "Site 2"로 변경합니다. 이렇게 해서 모든 것이 의도한 대로 작동하는지 확인할 수 있습니다.

테스트 웹사이트가 준비되었으니 다음으로 넘어갑니다.

### 구성 폴더

이제 Nginx 설정 폴더로 이동하여 이 가이드의 나머지 부분에서 작업할 것입니다:

```bash
cd /etc/nginx/
```

`ls` 명령을 실행하여 현재 위치에 어떤 파일과 폴더가 있는지 확인하면 여러 가지 다른 요소들이 보일 것입니다. 그 중 대부분은 오늘과 관련이 없는 것입니다. 참고할 사항은 다음과 같습니다.

* `nginx.conf`는 기본 Nginx 구성을 포함하는 파일입니다. 나중에 이를 편집할 것입니다.
* `conf.d`는 사용자 정의 구성 파일을 넣을 수 있는 디렉토리입니다. 이를 웹사이트에 *사용할 수도 있지만*, 모든 웹사이트에 적용하려는 기능별 설정에 사용하는 것이 좋습니다.
* `default.d`는 서버에서 하나의 사이트만 실행하거나 서버에 "기본" 웹사이트가 있는 경우에만 웹사이트 구성이 들어가는 디렉토리입니다. 일단 그대로 두세요.

`sites-available`과 `sites-enabled`라는 두 개의 새 폴더를 생성하려고 합니다:

```bash
mkdir sites-available
mkdir sites-enabled
```

우리가 할 일은 모든 웹사이트 구성 파일을 `sites-available` 폴더에 넣는 것입니다. 거기에서 구성 파일을 필요한 만큼 작업할 수 있습니다. 준비가 되면 `sites-enabled` 폴더로의 심볼릭 링크를 통해 파일을 활성화할 수 있습니다.

아래에서는 작동 방식을 보여드리겠습니다. 일단 폴더 생성은 완료되었습니다.

!!! Note "도메인을 역순으로 작성하는 이유:"

    간단히 말해서, 이는 명령 줄에서 탭 완성과 함께 사용할 때 특히 유용한 조직 방법이지만, GUI 기반 애플리케이션에서도 매우 유용합니다. 이는 서버에서 *많은* 웹사이트나 앱을 실행하는 사람들을 위해 설계되었습니다.
    
    기본적으로 모든 웹사이트 폴더(및 구성 파일)는 알파벳 순서대로 정리됩니다. 우선 최상위 도메인(예: .com, .org 등)으로 정렬되고, 그 다음 기본 도메인으로 정렬되며, 그 다음에는 하위 도메인으로 정렬됩니다. 긴 도메인 목록에서 원하는 항목을 좁히는 데 도움이 될 수 있습니다.
    
    또한 명령 줄 도구를 사용하여 폴더와 구성 파일을 쉽게 정렬할 수 있습니다. 특정 도메인과 연관된 모든 폴더를 나열하려면 다음과 같이 실행할 수 있습니다.

    ```bash
    ls /usr/share/nginx/ | grep com.yoursite*
    ```


    이렇게 하면 다음과 같은 결과가 출력됩니다.

    ```
    com.yoursite.site1
    com.yoursite.site2
    com.yoursite.site3
    ```

## 구성 파일 설정하기

### nginx.conf 편집

기본적으로 Rocky Linux에서 Nginx의 구현은 모든 HTTP 트래픽을 허용하고 설치 가이드에서 볼 수 있는 데모 페이지로 이동시킵니다. 그렇게 하고 싶지 않습니다. 우리는 지정한 도메인의 트래픽을 지정한 웹사이트로 보내고 싶습니다.

따라서 `/etc/nginx/` 디렉토리에서 좋아하는 텍스트 편집기로 `nginx.conf`를 엽니다.

```bash
nano nginx.conf
```

먼저 다음과 같이 보이는 줄을 찾습니다.

```
include /etc/nginx/conf.d/*.conf;
```

그리고 아래에 다음 부분을 **추가**합니다.

```
include /etc/nginx/sites-enabled/*.conf;
```

이렇게 하면 준비된 웹사이트 구성 파일이 로드됩니다.

이제 다음과 같이 보이는 섹션으로 이동하여 해시 기호 <kbd>#</kbd>로 **주석 처리**하거나 원하는 경우 삭제하세요.

```
server {
    listen       80;
    listen       [::]:80;
    server_name  _;
    root         /usr/share/nginx/www/html;

    # Load configuration files for the default server block.
    include /etc/nginx/default.d/*.conf;

    error_page 404 /404.html;
    location = /404.html {
    }

    error_page 500 502 503 504 /50x.html;
    location = /50x.html {
    }
}
```

"주석 처리됨"과 같이 표시됩니다.

```
#server {
#    listen       80;
#    listen       [::]:80;
#    server_name  _;
#    root         /usr/share/nginx/www/html;
#
#    # Load configuration files for the default server block.
#    include /etc/nginx/default.d/*.conf;
#
#    error_page 404 /404.html;
#    location = /404.html {
#    }
#
#    error_page 500 502 503 504 /50x.html;
#    location = /50x.html {
#    }
#}
```

초심자라면 주석 처리된 코드를 참고용으로 남겨두는 것이 좋습니다. 파일 하단에 이미 주석 처리된 HTTPS 코드에도 해당합니다.

파일을 저장하고 닫은 다음 다음과 같이 서버를 재시작하세요:

```bash
systemctl restart nginx
```

이제 누구도 데모 페이지를 볼 수 없게 됩니다.

### 웹사이트 구성 파일 추가하기

이제 테스트 웹사이트를 서버에 사용할 수 있도록 해봅시다. 이전에 언급한 대로, 우리는 심볼릭 링크를 사용하여 웹사이트를 원하는 대로 켜고 끌 수 있는 간단한 방법을 갖게 될 것입니다.

!!! 참고 사항

    절대 초보자를 위해 심볼릭 링크란 사실은 파일을 두 개의 폴더에 동시에 존재하는 것처럼 가장하는 방법입니다. 원본 파일(또는 "대상")을 변경하면, 연결된 모든 위치에서 변경이 발생합니다. 링크를 통해 파일을 편집하는 경우, 원본 파일이 변경됩니다.
    
    그러나 대상으로의 링크를 삭제하면 원본 파일에는 아무런 변화가 없습니다. 이 작업을 통해 웹사이트 구성 파일을 작업 디렉토리(`sites-available`)에 넣고, 그 파일들에 대한 링크를 `sites-enabled`에서 만들어 "활성화"할 수 있게 됩니다.


어떤 말인지 보여드리겠습니다. 첫 번째 웹사이트를 위한 구성 파일을 다음과 같이 만들어보세요:

```bash
nano sites-available/test.server.site1.conf
```

그런 다음 다음 코드를 붙여넣으세요. 이것은 동작하는 데 가장 간단한 Nginx 구성 중 하나로, 대부분의 정적 HTML 웹사이트에 잘 작동할 것입니다:

```
server {
    listen 80;
    listen [::]:80;

    # virtual server name i.e. domain name #
    server_name site1.server.test;

    # document root #
    root        /usr/share/nginx/test.server.site1/html;

    # log files
    access_log  /var/log/nginx/www_access.log;
    error_log   /var/log/nginx/www_error.log;

    # Directives to send expires headers and turn off 404 error logging. #
    location ~* ^.+\.(ogg|ogv|svg|svgz|eot|otf|woff|mp4|ttf|rss|atom|jpg|jpeg|gif|png|ico|zip|tgz|gz|rar|bz2|doc|xls|exe|ppt|tar|mid|midi|wav|bmp|rtf)$ {
        access_log off; log_not_found off; expires max;
    }
}
```

사실 문서 루트 이하의 모든 내용은 기술적으로 선택 사항입니다. 유용하고 권장되지만 웹사이트가 작동하는 데 절대 필요하지는 않습니다.

어쨌든, 파일을 저장하고 닫은 다음 `sites-enabled` 디렉토리로 이동하세요:

```bash
cd sites-enabled
```

이제 방금 만든 구성 파일에 대한 `sites-available` 폴더에서 심볼릭 링크를 생성하세요.:

```bash
ln -s ../sites-available/test.server.site1.conf
```

`nginx -t` 명령을 사용하여 구성을 테스트하고, 모든 것이 정상적으로 작동한다는 메시지를 받으면 서버를 다시 로드하세요:

```bash
systemctl restart nginx
```

그런 다음 브라우저를 이 첫 번째 사이트에 대한 도메인으로 이동시켜서 HTML 파일에 넣은 "This is Site 1" 메시지를 찾아보세요 (예: site1.server.test). 시스템에 `curl`이 설치되어 있다면, `curl site1.server`.test을 실행하여 터미널에서 HTML 코드가 로드되는지 확인할 수도 있습니다.

!!! note "참고 사항"

    일부 브라우저는 (가장 좋은 의도로) 서버 도메인을 주소 창에 입력할 때 HTTPS를 사용하도록 강제할 수 있습니다. HTTPS가 구성되지 않은 경우 오류가 발생합니다.
    
    이 문제를 피하려면 브라우저 주소 창에 수동으로 "http://"를 지정하십시오. 작동하지 않는 경우 캐시를 지우거나 피가 아니면 이 테스트 부분에 덜 까다로운 브라우저를 사용하십시오. [Min](https://minbrowser.org)을 추천합니다.

만약 *모든 것이 잘 되었다면*, 위에서 언급한 *단계를 반복하되 파일 이름과 구성 파일의 내용을 변경해가면서 진행하세요*. "site1"을 "site2"로 변경하고 그런 식입니다. Site 1과 Site 2에 대한 구성 파일과 심볼릭 링크를 모두 생성한 후 Nginx를 재시작하면 다음과 같아야 합니다:</p>

![두 개의 테스트 웹사이트가 나란히 있는 스크린샷](nginx/images/multisite-nginx.png)

!!! note "참고 사항"

    `ln -s` 명령의 긴 형식을 사용하여 sites-enabled 디렉토리 외부에서 링크를 만들 수도 있습니다. 이는 다음과 같이 보일 것입니다: `ln -s [source-file] [link]`.
    
    이 문맥에서는 다음과 같습니다:

    ```bash
    ln -s /etc/nginx/sites-available/test.server.site1.conf /etc/nginx/sites-enabled/test.server.site1.conf
    ```

### 웹사이트 비활성화하기

하나의 웹사이트를 일시적으로 중지하여 작업을 하고 다시 사용하려면, sites-enabled에서 심볼릭 링크를 삭제하기만 하면 됩니다:

```bash
rm /etc/nginx/sites-enabled/test.server.site1.conf
```

그런 다음 일반적으로 Nginx를 재시작하세요. 사이트를 다시 온라인으로 전환하려면 심볼릭 링크를 다시 생성하고 Nginx를 다시 시작해야 합니다.

## 선택 사항: 호스트 파일 편집

이 부분은 초보자를 위한 것입니다. 다른 사람들은 아마도 건너뛸 수 있을 것입니다.

이 섹션은 *로컬 개발 환경에서 이 안내서를 시도하는 경우에만* 해당됩니다. 즉, 테스트 서버를 워크스테이션에서 실행하거나 로컬 홈 또는 비즈니스 네트워크의 다른 컴퓨터에서 실행하는 경우입니다.

외부 도메인을 로컬 머신에 지정하는 것은 귀찮은 일이며 (그리고 무엇을 하는지 모르는 경우 위험할 수 있습니다), 로컬 네트워크에서만 작동하는 "가짜" 도메인을 설정할 수 있습니다.

가장 쉬운 방법은 컴퓨터의 hosts 파일을 사용하는 것입니다. hosts 파일은 DNS 설정을 무시할 수 있는 일반 텍스트 파일입니다. 즉, 원하는 IP 주소와 함께 도메인 이름을 수동으로 지정할 수 있습니다. 그러나 이것은 *해당 컴퓨터에서만* 작동합니다.

Mac과 Linux에서는 호스트 파일이 `/etc/` 디렉토리에 있으며 명령 줄을 통해 매우 쉽게 편집할 수 있습니다 (루트 액세스가 필요합니다). Rocky Linux 워크스테이션에서 작업 중이라고 가정하고 다음 명령을 실행하세요:

```bash
nano /etc/hosts
```

Windows에서 호스트 파일은 `C:\Windows\system32\drivers\etc\hosts` 경로에 위치해 있으며, 관리자 권한을 가진 경우 어떤 GUI 텍스트 편집기를 사용해도 됩니다.

Rocky Linux 컴퓨터에서 작업하고 있으며, 동일한 컴퓨터에서 Nginx 서버를 실행하는 경우 다음과 같이 파일을 열고 원하는 도메인/IP 주소를 정의할 수 있습니다. 작업 스테이션과 테스트 서버를 동일한 컴퓨터에서 실행하는 경우 다음과 같습니다:

```
127.0.0.1           site1.server.test
127.0.0.1           site2.server.test
```

네트워크의 다른 머신에서 Nginx 서버를 실행 중인 경우 해당 머신의 주소를 사용하십시오. 예:

```
192.168.0.45           site1.server.test
192.168.0.45           site2.server.test
```

그럼 브라우저에서 해당 도메인을 입력하여 정상적으로 작동하는지 확인할 수 있을 것입니다.

## 사이트에 대한 SSL 인증서 설정

[Let's Encrypt 및 Certbot을 사용하여 SSL 인증서를 가져오는 가이드](../security/generating_ssl_keys_lets_encrypt.md)를 확인해보세요. 해당 가이드의 지침은 잘 작동할 것입니다.

## 결론

기술적으로 대부분의 폴더/파일 구성과 명명 규칙은 선택 사항입니다. 웹사이트 구성 파일은 주로 `/etc/nginx/` 내의 임의의 위치에 있어야 하며, `nginx.conf`에서 해당 파일의 위치를 알아야 합니다.

실제 웹사이트 파일은 `/usr/share/nginx/` 내의 적절한 위치에 있어야 하며, 나머지는 선택 사항입니다.

이제 시도해보고, 과학<sup>TM</sup>을 수행하고 Nginx를 다시 시작하기 전에 `nginx -t`를 실행하여  세미콜론 또는 다른 오류를 놓치지 않았는지 확인하는 것이 좋습니다. 이는 많은 시간을 절약할 수 있습니다.
