---
title: Rocky 미러 추가
contributors: Amin Vakil, Steven Spencer
---

# 공용 미러를 Rocky의 미러 관리자에 추가하는 방법

## 공용 미러에 대한 최소 요구 사항

우리는 항상 새로운 공개 미러를 환영합니다. 그러나 이러한 미러는 잘 유지되고 24/7 데이터 센터와 같은 환경에서 호스팅되어야 합니다. 가능한 대역폭은 최소 1 GBit/s 이상이어야 합니다. 우리는 IPv4와 IPv6를 모두 지원하는 미러를 선호합니다. 동적 DNS를 사용하여 구성된 미러는 제출하지 마십시오. 미러가 적은 지역에서 제공되는 경우 속도가 느려도 수락할 수 있습니다.

또한 Cloudflare 등의 Anycast-CDN에 호스팅된 미러는 제출하지 마십시오. 이는 `dnf`에서 가장 빠른 미러를 선택하는 데 있어서 최적의 성능을 얻지 못할 수 있습니다.

미국의 수출 규제 대상 국가에서는 공개 미러를 수용할 수 없습니다. 해당 국가의 목록은 여기에서 확인할 수 있습니다 : [https://www.bis.doc.gov/index.php/policy-guidance/country-guidance/sanctioned-destinations](https://www.bis.doc.gov/index.php/policy-guidance/country-guidance/sanctioned-destinations)

이 문서(2022년 말)를 기준으로 현재 및 과거의 모든 Rocky Linux 릴리스를 미러링하는 데 필요한 스토리지 공간은 약 2TB입니다.

우리의 마스터 미러는 `rsync://msync.rockylinux.org/rocky/mirror/pub/rocky/`입니다. 처음 동기화할 때는 가까운 미러를 사용하세요. 모든 공식 미러는 [여기](https://mirrors.rockylinux.org)에서 찾을 수 있습니다.

앞으로 우리는 공식 공개 미러에 대한 액세스를 공식 마스터 미러로 제한할 수 있습니다. 따라서 개인 미러를 운영 중이라면 근처의 공개 미러로부터 `rsync`를 고려해주세요. 또한 로컬 미러가 동기화 속도가 더 빠를 수 있습니다.

## 미러 설정하기

미러를 주기적으로 동기화하도록 cron 작업을 설정하고 시간이 되지 않은 때에 동기화가 되도록 해주세요. 그러나 시간이 지남에 따라 부하가 분산되도록 시간을 동기화해야 합니다. 변경 사항의 변경만 체크하고 이 `fullfiletimelist-rocky` 파일이 변경되었을 때에만 전체 동기화를 수행하는 경우에는 1시간마다 동기화할 수 있습니다.

다음은 몇 가지 crontab 예제입니다:

```
50 */6  * * * /path/to/your/rocky-rsync-mirror.sh > /dev/null 2>&1

#이 설정은 미러를 2:25, 6:25, 10:25, 14:25, 18:25, 22:25에 동기화합니다. 25 2,6,10,14,18,22 * * * /path/to/your/rocky-rsync-mirror.sh > /dev/null 2>&1

#이 설정은 매 시간 정각 15분에 미러를 동기화합니다.
#우리의 예제 스크립트를 사용하는 경우에만 사용하세요. 15 * * * * /path/to/your/rocky-rsync-mirror.sh > /dev/null 2>&1
```

간단한 동기화를 위해 다음 `rsync` 명령을 사용할 수 있습니다:

```
rsync -aqH --delete source-mirror destination-dir
```
새로운 릴리스를 푸시할 때 동시에 두 개 이상의 `rsync` 작업이 실행되지 않도록 잠금 메커니즘을 사용하는 것도 고려해보세요.

필요한 경우 잠금 및 전체 동기화를 구현하는 예제 스크립트를 사용하고 수정할 수도 있습니다. [https://github.com/rocky-linux/rocky-tools/blob/main/mirror/mirrorsync.sh](https://github.com/rocky-linux/rocky-tools/blob/main/mirror/mirrorsync.sh) )에서 확인할 수 있습니다.

잠재적인 문제를 피하기 위해 첫 번째 완전한 동기화 후 미러가 정상적으로 동작하는지 확인하세요. 가장 중요한 것은 모든 파일과 디렉토리가 동기화되었는지, cron 작업이 제대로 작동하는지, 미러가 공개 인터넷에서 접근 가능한지 확인하는 것입니다. 방화벽 규칙을 재확인하세요! http에서 https로의 리디렉션을 강제하지 마세요.

미러 설정에 대한 질문이 있으면 https://chat.rockylinux.org/rocky-linux/channels/infrastructure 에 가입하세요.

작업을 마치면 다음 섹션으로 이동하여 공개 미러로 제안하세요!

## 필요한 것
* https://accounts.rockylinux.org/의 계정

## 사이트 만들기

Rocky의 Mirror Manager에 접근하려면 여기를 클릭하세요: https://mirrors.rockylinux.org/mirrormanager/

Rocky는 Fedora의 Mirror Manager를 사용하여 커뮤니티 미러를 구성합니다.

성공적인 로그인 후, 프로필이 오른쪽 상단에 표시됩니다. 드롭다운을 선택한 다음 "My sites"를 클릭하세요.

새 페이지가 로드되며 해당 계정의 모든 사이트가 나열됩니다. 처음에는 비어 있습니다. "Register a new site"를 클릭하세요.

새 페이지가 로드되며 중요한 수출 규정 성명서가 표시됩니다. 그런 다음 다음 정보를 작성하세요.

* "Site Name"
* ""Site Password" - `report_mirrors` 스크립트에서 사용되며 원하는 값을 사용할 수 있습니다.
* "Organization URL" - 회사/학교/조직 URL 예: https://rockylinux.org/
* "Private" - 이 상자를 선택하면 미러가 공개적으로 사용되지 않습니다.
* "User active" - 이 상자를 선택해 사이트를 일시적으로 비활성화하면 공개 목록에서 제거됩니다.
* "All sites can pull from me?" - 목록에 따로 추가하지 않고도 모든 미러 사이트에서 나를 끌어올 수 있도록 허용합니다.
* "다운스트림 사이트 관리자를 위한 설명. 종속성 루프를 방지하려면 여기에 동기화 소스를 포함하십시오."

"Submit"을 클릭하면 기본 미러 페이지로 돌아갑니다.

## 사이트 구성

주요 미러 페이지에서 드롭다운을 선택한 다음 "My sites"를 클릭하세요.

계정 사이트 페이지가 로드되고 사이트가 나열됩니다. 해당 사이트를 클릭하여 정보 사이트로 이동하세요.

지난 섹션에서와 같은 모든 옵션이 다시 나열됩니다. 페이지 아래에는 세 가지 새로운 옵션이 있습니다: Admins, Hosts, and Delete site. "Hosts [add]"를 클릭하세요.

## 새 호스트 만들기

사이트에 적합한 다음 옵션을 작성하십시오.

* "Host name" - 필수: 공개 엔드 사용자에 의해 볼 수 있는 서버의 완전한 도메인 이름(FQDN)
* "User active" - 이 상자를 선택해 호스트를 일시적으로 비활성화하면 공개 목록에서 제거됩니다.
* "Country" - 필수: 2자리 ISO 국가 코드
* "Bandwidth" - 필수: 정수 Mbps(Megabits/초), 이 호스트가 제공할 수 있는 대역폭
* "Private" - 예: 공개에 제공되지 않는 내부 개인 미러
* "Internet2" - Internet2를 사용하는 경우 선택
* "Internet2 clients" - 비공개인 경우에도 Internet2 클라이언트를 제공합니다.
* "ASN - Autonomous System Number, BGP 라우팅 테이블에 사용됩니다. ISP인 경우에만 입력하세요.
* "ASN Clients?" - 동일한 ASN에서 모든 클라이언트를 제공합니다. ISP, 기업 또는 학교에 사용되며 개인 네트워크에는 사용하지 마세요.
* "Robot email" - 이메일 주소, 상위 콘텐츠 업데이트에 대한 알림을 받을 수 있습니다.
* "Comment" - 텍스트, 공개 엔드 사용자가 미러에 대해 알아야 할 다른 내용
* "Max connections" - 클라이언트 당 최대 병렬 다운로드 연결, metalinks를 통해 제안됩니다.

"Create"를 클릭하면 호스트에 대한 정보 사이트로 리디렉션됩니다.

## 호스트 업데이트

정보 사이트 하단에는 이제 "Hosts" 옵션 옆에 호스트 제목이 표시됩니다. 이름을 클릭하여 호스트 페이지를 로드하세요. 이전 단계의 모든 옵션이 다시 나열됩니다. 페이지 하단에는 새로운 옵션이 있습니다.

* "Site-local Netblocks": 엔드 사용자를 사이트 특정 미러로 안내하는 데 사용되는 Netblock입니다. 예를 들어 대학은 자신의 넷블록을 나열하고 미러 리스트 CGI는 국가 로컬 미러 대신 대학 로컬 미러를 반환합니다. 형식은 18.0.0.0/255.0.0.0, 18.0.0.0/8, IPv6 접두사/길이 또는 DNS 호스트 이름 중 하나입니다. 값은 공용 IP 주소여야 합니다(RFC1918 사설 주소는 사용하지 마세요). ISP이거나 공용 라우팅 가능한 넷블록을 소유하고 있는 경우에만 사용하세요

* "Peer ASNs":  인접한 네트워크의 엔드 사용자를 미러로 안내하는 데 사용됩니다. 예를 들어 대학은 피어 ASNs를 나열하고 미러 리스트 CGI는 국가 로컬 미러 대신 대학 로컬 미러를 반환합니다. 피어 ASNs를 만들려면 MirrorManager 관리자 그룹에 속해야 합니다.

* "Countries Allowed": 일부 미러는 자신의 국가의 엔드 사용자만 서비스해야 합니다. 해당 경우에는 엔드 사용자가 속한 국가의 2자리 ISO 코드를 나열하세요. 미러 리스트 CGI는 이를 준수합니다.

* "Categories Carried": 호스트는 소프트웨어 카테고리를 제공합니다. Fedora 카테고리 예제로는 Fedora와 Fedora Archive가 있습니다.

"Categories Carried" 아래의 "[add]" 링크를 클릭하십시오.

### 카테고리 제공

카테고리에서 "Rocky Linux"를 선택한 다음 "Create"를 클릭하여 URL 페이지를 로드하세요. 그런 다음 "Add host category URL" 페이지를 로드하려면 "[add]"를 클릭하세요. 한 가지 옵션이 있습니다. 지원하는 각 미러 프로토콜에 대해 필요에 따라 반복하세요.

* "URL" - 최상위 디렉토리를 가리키는 URL(rsync, https, http)

예시:
* `http://rocky.example.com`
* `https://rocky.example.com`
* `rsync://rocky.example.com`


## 마무리

작성이 완료되면 다음 미러 갱신 시점에 사이트가 미러 목록에 표시됩니다.
