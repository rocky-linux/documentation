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

    이 절차가 마지막으로 테스트된 Rocky Linux 버전은 8.5입니다. 이 프로시저의 대부분은 Asterisk에서 직접 소스 빌드하고 Rocky Linux의 간단한 개발 도구 세트를 사용하기 때문에 모든 버전에서 작동할 것으로 예상됩니다. 문제가 발생하는 경우 알려주시면 감사하겠습니다!

# Rocky Linux에 Asterisk 설치

**Asterisk는 무엇인가요?**

Asterisk는 통신 응용 프로그램을 구축하기 위한 오픈 소스 프레임워크입니다. 또한 Asterisk는 일반적인 컴퓨터를 통신 서버로 변환하며, IP PBX 시스템, VoIP 게이트웨이, 회의 서버 및 기타 사용자 정의 솔루션에도 사용됩니다. Asterisk는 전 세계의 소규모 및 대규모 기업, 콜센터, 운송사 및 정부 기관에서 사용되고 있습니다.

Asterisk는 무료 및 오픈 소스이며 [Sangoma](https://www.sangoma.com/)가 후원하고 있습니다. Sangoma는 Asterisk를 내부적으로 사용하는 상용 제품도 제공하며, 경험과 예산에 따라 이러한 제품을 사용하는 것이 직접 빌드하는 것보다 더 유익할 수도 있습니다. 이에 대한 결정은 당신과 당신의 조직만이 알 수 있습니다.

이 가이드는 관리자가 자체적으로 많은 양의 연구를 수행해야 한다는 점을 고려해야 합니다. 통신 서버를 설치하는 것은 어려운 프로세스는 아니지만, 운영하는 것은 꽤 복잡할 수 있습니다. 이 가이드를 통해 서버를 설정할 수 있지만, 실제로 운영에 사용하려면 추가 작업이 필요합니다.

## 필요 사항

이 가이드를 완료하려면 다음과 같은 기술과 도구가 필요합니다:

* Rocky Linux가 설치된 컴퓨터
* 구성 파일 수정 및 명령 실행에 대한 편한 수준의 숙련도
* 명령 줄 편집기 사용 방법 (여기에서는 `vi`를 사용하지만 좋아하는 편집기로 대체할 수 있습니다.)
* root 액세스 권한이 필요하며, 이상적으로는 터미널에서 root 사용자로 로그인해야 합니다.
* Fedora의 EPEL 저장소
* 사용자가 _sudo_ 권한을 가진 사용자를 가정하여 여기서 제시하는 모든 명령은 _sudo_ 권한이 있는 사용자로 실행되어야 합니다. 그러나 설정 및 빌드 프로세스는 `sudo -s`로 실행됩니다.
* Asterisk의 최신 빌드를 가져오려면 `curl` 또는 `wget`을 사용해야 합니다. 이 가이드는 `wget`을 사용하지만 이를 사용하려면 적절한 `curl` 문자열로 자유롭게 대체할 수 있습니다.

## Rocky Linux 업데이트 및 `wget` 설치

```
sudo dnf -y update
```

이 명령을 실행하면 마지막 업데이트 또는 설치 이후에 출시되거나 업데이트된 모든 패키지로 서버가 최신 상태가 됩니다. 그런 다음 실행하세요:

```
sudo dnf install wget
```

## 호스트 이름 설정

호스트 이름을 Asterisk에 사용할 도메인으로 설정합니다.

```
sudo hostnamectl set-hostname asterisk.example.com
```

## 필요한 저장소 추가

먼저 EPEL (Enterprise Linux용 추가 패키지)를 설치합니다.

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

## Asterisk 설치하기

### Asterisk Build 다운로드 및 구성

이 스크립트를 다운로드하기 전에 최신 버전을 사용하는지 확인하세요. [Asterisk 다운로드 링크](http://downloads.asterisk.org/pub/telephony/asterisk/)에 가서 최신 Asterisk 빌드를 확인하고 링크 위치를 복사합니다. 그런 다음 링크 위치를 복사합니다. 이 문서 작성 당시 최신 빌드는 다음과 같습니다.

```    
wget http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-20-current.tar.gz 
tar xvfz asterisk-20-current.tar.gz
cd asterisk-20.0.0/
```

`install_prereq`` 스크립트를 실행하기 전에 (그리고 나머지 명령) 최고 사용자 또는 루트 사용자로 로그인해야 합니다. 이 단계에서는 임시로 _sudo_를 계속 사용하는 것이 훨씬 쉽습니다. 프로세스를 진행하는 동안에는 나중에 _sudo_를 빠져 나갈 것입니다:

```
sudo -s
contrib/scripts/install_prereq install
```

스크립트가 완료되면 다음과 같은 메시지를 볼 수 있어야 합니다:

```
#############################################
## install completed successfully
#############################################
```

필요한 패키지가 모두 설치된 이후, 다음 단계는 Asterisk를 구성하고 빌드하는 것입니다:

```
./configure --libdir=/usr/lib64 --with-jansson-bundled=yes
```

구성이 문제 없이 실행된다면 큰 ASCII Asterisk 로고와 함께 아래와 같은 메시지가 나타날 것입니다.

```
configure: Package configured for:
configure: OS type  : linux-gnu
configure: Host CPU : x86_64
configure: build-cpu:vendor:os: x86_64 : pc : linux-gnu :
configure: host-cpu:vendor:os: x86_64 : pc : linux-gnu :
```

### Asterisk 메뉴 옵션 설정 [추가 옵션]

이는 관리자가 개별적으로 연구해야 할 단계 중 하나입니다. 사용할 수도 있고 사용하지 않을 수도 있는 많은 메뉴 옵션이 있습니다. 다음 명령을 실행하여 다음 메뉴 선택 화면으로 이동합니다:

```
make menuselect
```

메뉴 선택 화면으로 이동합니다.

![menuselect screen](../images/asterisk_menuselect.png)

이 옵션을 주의 깊게 살펴보고 요구 사항에 따라 선택하세요. 앞서 말한 대로 이 작업은 추가적인 공부가 필요할 수 있습니다.

### Asterisk 빌드 및 설치하기

빌드하려면 다음 명령을 연속적으로 실행합니다:

```
make
make install
```

문서 설치는 필수적이지 않지만, 통신 서버 전문가가 아닌 경우에는 설치하는 것이 좋습니다:

```
make progdocs
```

다음으로 기본 PBX를 설치하고 구성합니다. 기본 PBX는 매우 기본적입니다! PBX가 원하는대로 작동하도록 하기 위해 추후 변경을 할 가능성이 높습니다.

```
make basic-pbx
make config
```

## Asterisk 구성

### 사용자 & 그룹 생성하기

Asterisk를 위한 특정 사용자가 필요합니다. 지금 만드는 것이 좋습니다.

```
groupadd asterisk
useradd -r -d /var/lib/asterisk -g asterisk asterisk
chown -R asterisk.asterisk /etc/asterisk /var/{lib,log,spool}/asterisk /usr/lib64/asterisk
restorecon -vr {/etc/asterisk,/var/lib/asterisk,/var/log/asterisk,/var/spool/asterisk}
```

작업의 대부분이 완료되었으므로 `sudo -s` 명령으로 나갈 수 있습니다. 이로 인해 나머지 명령의 대부분은 다시 _sudo_ 를 사용해야 합니다.

```
exit
```

### 기본 사용자 & 그룹 설정하기

```
sudo vi /etc/sysconfig/asterisk
```

아래의 두 줄의 주석을 제거하고 저장하세요.

```
AST_USER="asterisk"
AST_GROUP="asterisk"
```

```
sudo vi /etc/asterisk/asterisk.conf
```

아래의 두 줄의 주석을 제거하고 저장하세요.

```
runuser = asterisk ; The user to run as. rungroup = asterisk ; The group to run as.
```

### Asterisk 서비스 구성하기

```
sudo systemctl enable asterisk
```

### 방화벽 구성하기

이 예제는 Rocky Linux에서 기본적으로 사용되는 `firewalld`를 사용합니다. 여기에서는 SIP 포트를 모두에게 열고, Asterisk 문서에서 권장하는 대로 10000-20000 포트의 RTP(Realtime Transport Protocol - 실시간 전송 프로토콜)를 모두에게 열려고 합니다.

기타 서비스(HTTP/HTTPS)에 대한 방화벽 규칙을 추가적으로 필요로 할 수 있으며, 이 경우 고유한 IP 주소로 제한하는 것이 좋습니다. 이는 이 문서의 범위를 벗어나는 내용입니다.

```
sudo firewall-cmd --zone=public --add-service sip --permanent
sudo firewall-cmd --zone=public --add-port=10000-20000/udp --permanent
```

`firewalld` 명령을 영구적으로 적용되도록 했으므로 서버를 재부팅해야 합니다. 다음을 사용하여 이 작업을 수행합니다.

```
sudo shutdown -r now
```

## 테스트

### Asterisk 콘솔

테스트를 위해 Asterisk 콘솔에 연결해 보겠습니다.

```
sudo asterisk -r
```

위 명령을 실행하면 Asterisk 명령줄 클라이언트로 들어갑니다. 기본 Asterisk 정보가 표시된 후에는 다음과 같은 프롬프트가 나타납니다.

```
asterisk*CLI>
```

콘솔의 자세함(Verbosity)을 변경하려면 다음 명령을 사용하세요.

```
core set verbose 4
```

위 명령을 실행하면 Asterisk 콘솔에서 다음과 같이 표시됩니다.

```bash
Console verbose는 OFF였으며 현재는 4입니다.
```

### 샘플 End-Point 인증 표시

Asterisk 명령줄 클라이언트 프롬프트에서 다음 명령을 입력하세요.

```
pjsip show auth 1101
```

이렇게 하면 SIP 클라이언트를 연결하는 데 사용할 수 있는 사용자 이름과 암호 정보가 반환됩니다.

## 결론

위의 단계를 통해 서버가 실행되게 됩니다. 그러나 구성을 완료하고 장치를 연결하며 추가적인 문제 해결은 별도로 진행해야 합니다.

Asterisk 통신 서버를 운영하는 것은 많은 시간과 노력이 필요하며 어떤 관리자도 추가적인 연구가 필요할 수 있습니다. Asterisk를 구성하고 사용하는 방법에 대한 자세한 정보는 [Asterisk 위키](https://wiki.asterisk.org/wiki/display/AST/Getting+Started)를 참조하세요.
