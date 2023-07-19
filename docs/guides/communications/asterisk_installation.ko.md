---
title: Asterisk 설치
contributors: Steven Spencer
tested_with: 8.5
tags:
  - asterisk
  - pbx
  - 커뮤니케이션
---

!!! 참고사항

    이 절차가 테스트된 마지막 Rocky Linux 버전은 버전 8.5였습니다. 이 절차의 대부분은 Asterisk의 소스 빌드와 Rocky Linux의 간단한 개발 도구 세트에 의존하기 때문에 모든 버전에서 작동해야 합니다. 문제가 발생하면 알려주세요!

# Rocky Linux에 Asterisk 설치

**Asterisk는 무엇입니까?**

Asterisk는 커뮤니케이션 애플리케이션 구축을 위한 오픈 소스 프레임워크입니다. 또한 Asterisk는 일반 컴퓨터를 통신 서버로 전환하고 IP PBX 시스템, VoIP 게이트웨이, 회의 서버 및 기타 맞춤형 솔루션에 전원을 공급합니다. 전 세계 소기업, 대기업, 콜센터, 통신사 및 정부 기관에서 사용합니다.

Asterisk는 무료 오픈 소스이며 [Sangoma](https://www.sangoma.com/)에서 후원합니다. Sangoma는 또한 내부적으로 Asterisk를 사용하는 상용 제품을 제공하며, 귀하의 경험과 예산에 따라 이러한 제품을 사용하는 것이 직접 롤링하는 것보다 더 유익할 수 있습니다. 당신과 당신의 조직만이 답을 알고 있습니다.

이 가이드는 관리자가 자체적으로 상당한 양의 조사를 수행하도록 요구한다는 점에 유의해야 합니다. 통신 서버를 설치하는 것은 어려운 과정이 아니지만 실행하는 것은 상당히 복잡할 수 있습니다. 이 가이드가 서버를 시작하고 실행하는 동안 프로덕션에서 사용할 수 있도록 완전히 준비되지는 않습니다.

## 필요 사항

이 가이드를 완료하려면 최소한 다음과 같은 기술과 도구가 필요합니다.

* Rocky Linux를 실행하는 머신
* 구성 파일을 수정하고 명령줄에서 명령을 내리는 데 익숙한 수준
* 명령줄 편집기 사용 방법에 대한 지식(여기서는 `vi`를 사용하고 있지만 선호하는 편집기로 자유롭게 대체할 수 있습니다.)
* root 액세스가 필요하며 이상적으로는 터미널에서 root 사용자로 로그인해야 합니다.
* Fedora의 EPEL 저장소
* 루트로 로그인하거나 _sudo_를 사용하여 루트 명령을 실행하는 기능. 여기서 모든 명령은 _sudo_ 권한이 있는 사용자를 가정하지만 구성 및 빌드 프로세스는 `sudo -s`로 실행됩니다.
* Asterisk의 최신 빌드를 가져오려면 `curl` 또는 `wget`을 사용해야 합니다. 이 가이드는 `wget`을 사용하지만 이를 사용하려면 적절한 `curl` 문자열로 자유롭게 대체할 수 있습니다.

## Rocky Linux 업데이트 및 `wget` 설치

```
sudo dnf -y update
```

이렇게 하면 마지막 업데이트 또는 설치 이후 릴리스되거나 업데이트된 모든 패키지로 서버를 최신 상태로 유지할 수 있습니다. 그런 다음, 아래 명령을 실행합니다.

```
sudo dnf install wget
```

## 호스트 이름 설정

호스트 이름을 Asterisk에 사용할 도메인으로 설정합니다.

```
sudo hostnamectl set-hostname asterisk.example.com
```

## 필요한 저장소 추가

먼저 EPEL(Enterprise Linux용 추가 패키지)을 설치합니다.

```
sudo dnf -y install epel-release
```

다음으로 Rocky Linux의 PowerTools를 활성화합니다.

```
sudo dnf config-manager --set-enabled powertools
```

## 개발 도구 설치

```
sudo dnf group -y install "Development Tools"
sudo dnf -y install git wget  
```

## Asterisk 설치

### Asterisk Build 다운로드 및 구성

이 스크립트를 다운로드하기 전에 최신 버전인지 확인하십시오. 이렇게 하려면 여기의 [Asterisk 다운로드 링크](http://downloads.asterisk.org/pub/telephony/asterisk/)로 이동하여 Asterisk의 최신 빌드를 찾으십시오. 그런 다음 링크 위치를 복사합니다. 이 문서 작성 당시 최신 빌드는 다음과 같습니다.

```    
wget http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-20-current.tar.gz 
tar xvfz asterisk-20-current.tar.gz
cd asterisk-20.0.0/
```

아래의 `install_prereq`(및 나머지 명령)를 실행하기 전에 수퍼유저 또는 루트여야 합니다. 이 시점에서 잠시 동안 영구적으로 _sudo_에 들어가는 것이 훨씬 쉽습니다. 나중에 프로세스에서 _sudo_를 다시 종료합니다.

```
sudo -s
contrib/scripts/install_prereq install
```

스크립트가 완료되면 다음이 표시되어야 합니다.

```
#############################################
## install completed successfully
#############################################
```

필요한 모든 패키지가 설치되었으므로 다음 단계는 Asterisk를 구성하고 빌드하는 것입니다.

```
./configure --libdir=/usr/lib64 --with-jansson-bundled=yes
```

구성이 문제 없이 실행된다고 가정하면 Rocky Linux에서 다음과 같이 큰 ASCII 별표 엠블럼이 표시되어야 합니다.

```
configure: Package configured for:
configure: OS type  : linux-gnu
configure: Host CPU : x86_64
configure: build-cpu:vendor:os: x86_64 : pc : linux-gnu :
configure: host-cpu:vendor:os: x86_64 : pc : linux-gnu :
```

### Asterisk 메뉴 옵션 설정 [추가 옵션]

이것은 관리자가 숙제를 해야 하는 단계 중 하나입니다. 필요하거나 필요하지 않은 많은 메뉴 옵션이 있습니다. 다음 명령 실행:

```
make menuselect
```

메뉴 선택 화면으로 이동합니다.

![menuselect screen](../images/asterisk_menuselect.png)

이러한 옵션을 주의 깊게 살펴보고 요구 사항에 따라 선택하십시오. 앞서 언급한 바와 같이 추가 숙제가 필요할 수 있습니다.

### Asterisk 빌드 및 설치

빌드하려면 다음 명령을 연속으로 실행해야 합니다.

```
make
make install
```

설명서를 설치할 필요는 없지만 통신 서버 전문가가 아닌 경우 다음과 같이 설치해야 합니다.

```
make progdocs
```

다음으로 기본 PBX를 설치하고 구성을 합니다. 기본 PBX는 그저, 아주 기본적입니다! PBX가 원하는 대로 작동하려면 앞으로 변경해야 할 수도 있습니다.

```
make basic-pbx
make config
```

## Asterisk 구성

### 사용자 & 그룹 만들기

asterisk에만 특정 사용자가 필요합니다. 지금 만들 수도 있습니다.

```
groupadd asterisk
useradd -r -d /var/lib/asterisk -g asterisk asterisk
chown -R asterisk.asterisk /etc/asterisk /var/{lib,log,spool}/asterisk /usr/lib64/asterisk
restorecon -vr {/etc/asterisk,/var/lib/asterisk,/var/log/asterisk,/var/spool/asterisk}
```

이제 대부분의 작업이 완료되었으므로 계속해서 `sudo -s` 명령을 종료합니다. 이를 위해서는 대부분의 나머지 명령이 _sudo_를 다시 사용해야 합니다.

```
exit
```

### 기본 사용자 & 그룹 설정

```
sudo vi /etc/sysconfig/asterisk
```

아래 두 줄의 주석을 제거하고 저장합니다.

```
AST_USER="asterisk"
AST_GROUP="asterisk"
```

```
sudo vi /etc/asterisk/asterisk.conf
```

아래 두 줄의 주석을 제거하고 저장합니다.

```
runuser = asterisk ; The user to run as.
rungroup = asterisk ; The group to run as.
```

### Asterisk 서비스 설정

```
sudo systemctl enable asterisk
```

### 방화벽 구성

이 예에서는 Rocky Linux의 기본값인 방화벽에 대해 `firewalld`를 사용합니다. 여기에서의 목표는 Asterisk 문서에서 권장하는 대로 전 세계에 SIP 포트를 개방하고 포트 10000-20000에서 전 세계에 RTP(실시간 전송 프로토콜)를 개방하는 것입니다.

자신의 IP 주소로 제한하려는 다른 정방향 서비스(HTTP/HTTPS)에 대한 다른 방화벽 규칙이 거의 확실하게 필요하다는 점을 명심하십시오. 이는 이 문서의 범위를 벗어납니다.

```
sudo firewall-cmd --zone=public --add-service sip --permanent
sudo firewall-cmd --zone=public --add-port=10000-20000/udp --permanent
```

`firewalld` 명령을 영구적으로 만들었으므로 서버를 재부팅해야 합니다. 다음을 사용하여 이 작업을 수행합니다.

```
sudo shutdown -r now
```

## 테스트

### Asterisk 콘솔

테스트를 위해 Asterisk 콘솔에 연결해 보겠습니다.

```
sudo asterisk -r
```

그러면 Asterisk 명령줄 클라이언트로 이동합니다. 기본 Asterisk 정보가 표시된 후 이 프롬프트가 표시됩니다.

```
asterisk*CLI>
```

콘솔의 자세한 정도를 변경하려면 다음을 사용하십시오.

```
core set verbose 4
```

Asterisk 콘솔에 다음이 표시됩니다.

```bash
Console verbose는 OFF였으며 현재는 4입니다.
```

### 샘플 End-Point 인증 표시

Asterisk 명령줄 클라이언트 프롬프트에서 다음을 입력합니다.

```
pjsip show auth 1101
```

이렇게 하면 SIP 클라이언트를 연결하는 데 사용할 수 있는 사용자 이름과 비밀번호 정보가 반환됩니다.

## 결론

위의 방법으로 서버를 시작하고 실행할 수 있지만 구성 완료, 장치 연결 및 추가 문제 해결은 사용자에게 달려 있습니다.

Asterisk 통신 서버를 실행하려면 많은 시간과 노력이 필요하며 모든 관리자가 많은 조사를 해야 합니다. Asterisk 구성 및 사용 방법에 대한 자세한 내용은 여기에서 [Asterisk Wiki](https://wiki.asterisk.org/wiki/display/AST/Getting+Started)를 참조하세요.
