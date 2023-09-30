---
title: 보안 서버 - SFTP
author: Steven Spencer
contributors: Ezequiel Bruni
tested_with: 8.5, 8.6, 9.0
tags:
  - security
  - file transfer
  - sftp
  - ssh
  - web
  - multisite
---

# 보안 서버 - SSH Lock Down 절차로 SFTP 설정하기

## 소개

SSH 프로토콜 자체가 안전하다는 점에서 이미 보안 서버용 SFTP(openssh-server 패키지의 일부)에 대한 문서를 별도로 갖는 것은 이상하게 느껴질 수 있습니다. 당신이 생각하는 대로입니다. 하지만 대부분의 시스템 관리자는 모두에게 SSH를 열고 SFTP를 구현하길 원하지 않습니다. 이 문서에서는 SSH 액세스를 제한하면서 SFTP에 대한 change root jail<sup>1</sup>을 구현하는 방법을 설명합니다.

SFTP change root jail을 생성하는 데 관한 많은 문서들이 있지만, 대부분은 여러 웹 사이트가 있는 서버의 웹 디렉토리에 액세스하는 사용 사례를 고려하지 않습니다. 이 문서는 이와 관련하여 다룹니다. 이 사용 사례에 해당하지 않는 경우 이 개념을 다른 상황에 사용하기 쉽습니다.

또한 SFTP를 위한 change root jail 문서를 작성할 때 시스템 관리자가 SSH를 통해 제공하는 대상을 최소화하기 위해 해야 할 다른 작업에 대해 논의하는 것이 필요하다고 생각합니다. 이러한 이유로 이 문서는 네 부분으로 나누어져 있습니다:

1. 첫 번째 부분은 전체 문서에 사용할 일반 정보를 다룹니다.
2. 두 번째 부분은 change root jail 설정을 다루며, 여기서 멈추기로 결정한다면 완전히 괜찮습니다.
3. 세 번째 부분은 시스템 관리자를 위한 공개/개인 키 SSH 액세스를 설정하고 원격 암호 기반 인증을 비활성화하는 방법을 다룹니다.
4. 마지막으로 이 문서의 네 번째 부분은 원격 root 로그인을 비활성화하는 방법에 대해 다룹니다.

모든 이러한 단계를 수행하면 고객에게 안전한 SFTP 액세스를 제공하고 동시에 포트 22(SSH 액세스를 위해 예약된 포트)가 해커에 의해 침해될 가능성을 최소화할 수 있습니다.

!!! !!!참고 "<sup>1</sup> 초보자를 위한 루트 jail 변경:"

    change root(또는 chroot) jail은 컴퓨터에서 프로세스와 그 하위 프로세스가 수행할 수 있는 작업을 제한하는 방법입니다. 이를 통해 컴퓨터에서 특정 디렉토리/폴더를 선택하고 그것을 주어진 프로세스나 프로그램의 "루트" 디렉토리로 만들 수 있습니다.
    
    이후, 해당 프로세스나 프로그램은 *해당 폴더와 그 하위 폴더에만* 액세스할 수 있습니다.

!!! 팁 "Rocky Linux 8.6용 업데이트"

    이 문서는 버전 8.6에서 새로운 변경 사항을 포함하여 업데이트되었습니다. 8.6을 사용하는 경우 아래의 "8.6 -" 접두사가 있는 특정 섹션들이 있습니다. 명확성을 위해, Rocky Linux 8.5에 대한 섹션은 "8.5 - " 접두사가 있습니다. 접두사가 지정되지 않은 섹션을 제외하고 이 문서는 두 버전의 OS에 모두 적용됩니다.

## Part 1: 일반 정보

### 가정 및 규칙

우리는 다음과 같이 가정합니다:

* 명령 줄에서 명령을 실행하는 데 익숙합니다.
* `vi`(여기에서 사용), `nano`(나노), `micro`(마이크로) 등의 명령줄 편집기를 사용할 수 있습니다.
* 기본적인 Linux 명령어를 이해하고, 그것에 따라 잘 따라갈 수 있습니다.
* 멀티사이트 웹 사이트가 다음과 같이 설정되어 있다고 가정합니다: [Apache Multisite](../web/apache-sites-enabled.md)
* 서버에 이미 "httpd"(Apache)가 설치되어 있습니다.

!!! !!!

    이러한 개념을 모든 서버 설정 및 모든 웹 데몬에 적용할 수 있습니다. 우리는 여기서 Apache를 가정하고 있지만 Nginx에도 사용할 수 있습니다.

### 사이트, 사용자, 관리자

여기에 모든 것은 허구입니다. 실제 사람이나 사이트와의 유사성은 완전히 우연한 일치입니다:

**사이트:**

* mybrokenaxel = (site1.com) user = mybroken
* myfixedaxel = (site2.com) user = myfixed

**관리자**

* Steve Simpson = ssimpson
* Laura Blakely = lblakely

## Part 2: SFTP 루트 변경 Jail

### 설치

설치는 간단합니다. 이미 설치되어 있을 것으로 예상되는 openssh-server를 설치해야 합니다. 다음 명령을 입력하여 확인합니다:

```
dnf install openssh-server
```

### 설정

#### 디렉터리

* 디렉토리 경로 구조는 `/var/www/sub-domains/[ext.domainname]/html`이며, 이 경로의 `html` 디렉토리는 SFTP 사용자를 위한 change root jail이 될 것입니다.

구성 디렉토리를 생성합니다:

```
mkdir -p /etc/httpd/sites-available
mkdir -p /etc/httpd/sites-enabled
```

웹 디렉터리 생성합니다:

```
mkdir -p /var/www/sub-domains/com.site1/html
mkdir -p /var/www/sub-domains/com.site2/html
```
이 디렉토리들의 소유권은 아래에 있는 스크립트 응용 프로그램에서 처리하겠습니다.

### `httpd` 구성

내장된 `httpd.conf` 파일을 수정하여 `/etc/httpd/sites-enabled` 디렉토리의 구성 파일을 로드해야 합니다. 이것은 `httpd.conf` 파일의 맨 아래에 한 줄을 추가하여 수행합니다.

선호하는 편집기로 파일을 편집합니다. 여기서는 `vi`를 사용하고 있습니다:

```
vi /etc/httpd/conf/httpd.conf
```
그리고 파일의 맨 아래에 다음을 추가합니다:

```
Include /etc/httpd/sites-enabled
```
그런 다음 파일을 저장하고 종료합니다.

### 웹사이트 구성

We need two sites created. `/etc/httpd/sites-available`에 구성을 만든 다음 `../sites-enabled`에 연결합니다:

```
vi /etc/httpd/sites-available/com.site1
```

!!! note "참고사항"

    우리는 여기에서 예제로 HTTP 프로토콜만 사용합니다. 실제 웹 사이트는 HTTPS 프로토콜 구성, SSL 인증서 및 가능한 경우 더 많은 구성이 필요할 것입니다.

```
<VirtualHost *:80>
        ServerName www.site1.com
        ServerAdmin username@rockylinux.org
        DocumentRoot /var/www/sub-domains/com.site1/html
        DirectoryIndex index.php index.htm index.html
        Alias /icons/ /var/www/icons/


    CustomLog "/var/log/httpd/com.site1.www-access_log" combined
    ErrorLog  "/var/log/httpd/com.site1.www-error_log"

        <Directory /var/www/sub-domains/com.site1/html>
                Options -ExecCGI -Indexes
                AllowOverride None

                Order deny,allow
                Deny from all
                Allow from all

                Satisfy all
        </Directory>
</VirtualHost>
```
그런 다음 파일을 저장하고 종료합니다.

```
vi /etc/httpd/sites-available/com.site2
```

```
<VirtualHost *:80>
        ServerName www.site2.com
        ServerAdmin username@rockylinux.org
        DocumentRoot /var/www/sub-domains/com.site2/html
        DirectoryIndex index.php index.htm index.html
        Alias /icons/ /var/www/icons/


    CustomLog "/var/log/httpd/com.site2.www-access_log" combined
    ErrorLog  "/var/log/httpd/com.site2.www-error_log"

        <Directory /var/www/sub-domains/com.site2/html>
                Options -ExecCGI -Indexes
                AllowOverride None

                Order deny,allow
                Deny from all
                Allow from all

                Satisfy all
        </Directory>
</VirtualHost>
```
그런 다음 파일을 저장하고 종료합니다.

두 개의 구성 파일이 생성되면 `/etc/httpd/sites-enabled`에서 다음과 같이 링크합니다.

```
ln -s ../sites-available/com.site1
ln -s ../sites-available/com.site2
```
이제 `httpd` 프로세스를 활성화하고 시작합니다:

```
systemctl enable --now httpd
```

### 사용자 생성

우리의 예제 환경에서는 사용자가 아직 설정되지 않았다고 가정합니다. 관리자 사용자로 시작합니다. 여기서 우리 프로세스의 이 시점에서는 여전히 root 사용자로 로그인하여 다른 사용자를 추가하고 원하는 대로 설정할 수 있습니다. 사용자를 설정하고 테스트한 후에는 root 로그인을 제거할 것입니다.

#### 관리자

```
useradd -g wheel ssimpson
useradd -g wheel lblakely
```
사용자를 "wheel" 그룹에 추가하여 `sudo` 액세스 권한을 부여합니다.

여전히 `sudo` 액세스에 대한 암호가 필요합니다. 이를 우회할 수 있는 방법이 있지만 모두 안전하지는 않습니다. 사실, 서버에서 `sudo`를 사용하여 보안 문제가 발생하면 전체 설정에 대한 훨씬 더 큰 문제가 있습니다. 두 관리자의 암호를 안전한 암호로 설정합니다.

```
passwd ssimpson
Changing password for user ssimpson.
New password:
Retype new password:
passwd: all authentication tokens updated successfully.

passwd lblakely
Changing password for user lblakely.
New password:
Retype new password:
passwd: all authentication tokens updated successfully.
```

이제 두 관리자 사용자로 서버에 대한 ssh 액세스를 테스트합니다. 다음을 수행해야 합니다.

* `ssh`를 사용하여 관리 사용자 중 하나로 서버에 로그인합니다. 서버로 하나의 관리자 사용자로 `ssh`를 사용하여 로그인합니다.(예: `ssh lblakely@192.168.1.116` 또는 `ssh lblakely@mywebserver.com`)
* 서버에 액세스한 후 `sudo -s`를 사용하여 root에 액세스할 수 있어야 합니다. 이때 관리자 사용자의 암호를 입력합니다.

이 두 관리자에 대해 작동하면 다음 단계로 진행할 준비가 된 것입니다.

#### 웹 사용자(SFTP)

웹 사용자를 추가해야 합니다. 해당 `../html` 디렉토리 구조는 이미 존재하므로 사용자를 추가할 때 해당 디렉토리를 *생성하고 싶지는 않지만* 지정하고 싶습니다. 또한 SFTP 이외의 로그인은 허용하지 않기 때문에 로그인 거부 쉘을 사용해야 합니다.

```
useradd -M -d /var/www/sub-domains/com.site1/html -g apache -s /usr/sbin/nologin mybroken
useradd -M -d /var/www/sub-domains/com.site2/html -g apache -s /usr/sbin/nologin myfixed
```

이 명령들을 약간 살펴보겠습니다.

* `-M` 옵션은 사용자를 위한 표준 홈 디렉토리를 생성하지 *않도록* 말합니다.
* `-d`는 이후 디렉토리가 *실제* 홈 디렉토리라고 지정합니다.
* `-g`는 이 사용자가 속한 그룹이 `apache`라고 지정합니다.
* `-s`는 사용자에게 할당된 쉘이 `/usr/sbin/nologin`임을 지정합니다.
* 마지막에는 사용자의 실제 사용자 이름이 있습니다.

**참고:** Nginx 서버의 경우 `nginx`를 그룹으로 사용합니다.

Our SFTP users still need a password. 따라서 지금 각 사용자에게 안전한 암호를 설정합시다. 위에서 명령 출력을 이미 보았으므로 여기에서는 반복하지 않겠습니다.

```
passwd mybroken
passwd myfixed
```

### SSH 구성

!!! 주의

    다음 프로세스를 시작하기 전에 수정할 시스템 파일인 `/etc/ssh/sshd_config`의 백업을 만드는 것이 매우 권장됩니다. 이 파일을 깨뜨리고 원래로 돌아갈 수 없으면 심각한 문제가 발생할 수 있습니다!

    ```
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
    ```

우리는 `/etc/ssh/sshd_config` 파일을 하나 변경해야 하며 웹 디렉토리 변경 사항을 구성 파일 외부에서 할 수 있도록 템플릿을 생성하고 필요한 추가 사항을 스크립트화할 것입니다.

먼저 수동 변경을 수행해야 합니다.

```
vi /etc/ssh/sshd_config
```

파일의 맨 아래 부분에서 다음과 같은 줄이 있습니다.

```
# 하위 시스템이 없는 기본값을 재정의합니다. Subsystem     sftp    /usr/libexec/openssh/sftp-server
```

다음과 같이 읽도록 변경하고자 합니다:

```
# 하위 시스템이 없는 기본값을 재정의합니다. # Subsystem     sftp    /usr/libexec/openssh/sftp-server
Subsystem       sftp    internal-sftp
```
파일을 저장하고 종료합니다.

이전과 마찬가지로 이제 무엇을 하는지 간단히 설명하겠습니다. `sftp-server`와 `internal-sftp`는 모두 OpenSSH의 일부입니다. `internal-sftp`는 `sftp-server`와 크게 다르지 않지만 `ChrootDirectory`를 사용하여 클라이언트에 대해 다른 파일 시스템 루트를 강제하는 구성을 간단하게 만듭니다. 이것이 우리가 `internal-sftp`를 사용하려는 이유입니다.

### 템플릿과 스크립트

다음 부분에 대해 템플릿과 스크립트를 생성하는 이유는 인간의 실수를 최대한 배제하기 위함입니다. 그 이유는 단순히 사람의 실수를 최대한 피하기 위함입니다. `/etc/ssh/sshd_config` 파일 수정이 아직 끝나지 않았지만, 이러한 수정이 필요할 때마다 실수를 최소화하려고 합니다. 이 모든 것을 `/usr/local/sbin`에 생성하겠습니다.

#### 템플릿

먼저 템플릿을 만들어 보겠습니다:

```
vi /usr/local/sbin/sshd_template
```

이 템플릿은 다음과 같아야 합니다.

```
Match User replaceuser
  PasswordAuthentication yes
  ChrootDirectory replacedirectory
  ForceCommand internal-sftp
  AllowTcpForwarding no
  X11Forwarding no
```

!!! 참고사항

    'PasswordAuthentication yes'는 일반적으로 change root jail에 필요하지 않지만 우리는 나중에 다른 모든 사용자에 대해 `PasswordAuthentication`을 끄기로 할 것이므로 이 템플릿에 이 줄을 가지고 있어야 합니다.

템플릿에서 생성할 사용자 파일들을 위한 디렉토리도 만들어줍니다.

```
mkdir /usr/local/sbin/templates
```


=== "8.6 & 9.0"

    #### 8.6 & 9.0 - 스크립트 및 `sshd_config` 변경 사항
    Rocky Linux 8.6 및 9.0에서는 `sshd_config` 파일에 드롭인 구성을 허용하는 새로운 옵션이 제공됩니다. 이것은 **큰 변화**입니다. 이 변경으로 인해 이 버전에서는 `sshd_config` 파일에 하나의 추가 변경 사항을 만들고, 스크립트가 별도의 구성 파일에 sftp 변경 사항을 작성합니다. 이 새로운 변경으로 인해 보안이 더욱 개선됩니다. 안전한 방법은 좋은 방법입니다!
    
    Rocky Linux 8.6 및 9.0의 `sshd_config` 파일에 허용된 변경 사항 때문에 스크립트는 새로운 드롭인 구성 파일인 `/etc/ssh/sftp/sftp_config`를 사용합니다.
    
    우선 해당 디렉토리를 만듭니다.

    ```
    mkdir /etc/ssh/sftp
    ```


    그런 다음 `sshd_config`의 백업을 만듭니다.

    ```
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
    ```


    마지막으로 `sshd_config` 파일을 편집하고, 파일의 맨 아래로 스크롤하여 다음 줄을 추가합니다.

    ```bash
    Include /etc/ssh/sftp/sftp_config
    ```


    변경 사항을 저장하고 파일을 나가기 전에 `sshd`를 재시작해야 합니다. 그러나 스크립트에서 `sftp_config` 파일을 업데이트 한 후에도 우리가 대신 재시작할 것이므로 스크립트를 생성하고 실행하겠습니다.

    ```
    vi /usr/local/sbin/webuser
    ```


    그리고 다음 코드를 입력하세요:

    ```
    #!/bin/bash
    # 웹 사용자를 위해 SSHD 구성을 채우는 스크립트입니다.

    # 변수 설정

    tempfile="/usr/local/sbin/sshd_template"
    dompath="/var/www/sub-domains/"

    # 역방향(ext.domainname)으로 사용자 및 도메인 확인 팝업 표시:

    clear

    echo -n "Enter the web sftp user: "
    read sftpuser
    echo -n "Enter the domain in reverse. Example: com.domainname: "
    read dom
    echo -n "Is all of this correct: sftpuser = $sftpuser and domain = $dom (Y/N)? "
    read yn
    if [ "$yn" = "n" ] || [ "$yn" = "N" ]
    then
        exit
    fi
    if [ "$yn" = "y" ] || [ "$yn" = "Y" ]
    then
        /usr/bin/cat $tempfile > /usr/local/sbin/templates/$dom.txt
        /usr/bin/sed -i "s,replaceuser,$sftpuser,g" /usr/local/sbin/templates/$dom.txt
        /usr/bin/sed -i "s,replacedirectory,$dompath$dom,g" /usr/local/sbin/templates/$dom.txt
        /usr/bin/chown -R $sftpuser.apache $dompath$dom/html
    fi

    ## /etc/ssh/sftp/sftp_config를 백업합니다

    /usr/bin/rm -f /etc/ssh/sftp/sftp_config.bak

    /usr/bin/cp /etc/ssh/sftp/sftp_config /etc/ssh/sftp/sftp_config.bak

    ## 이제 새 사용자 정보를 파일에 추가합니다

    cat /usr/local/sbin/templates/$dom.txt >> /etc/ssh/sftp/sftp_config

    ## sshd 다시 시작

    /usr/bin/systemctl restart sshd

    echo " "
    echo "Please check the status of sshd with systemctl status sshd."
    echo "You can verify that your information was added by doing a more of the sftp_config"
    echo "A backup of the working sftp_config was created when this script was run: sftp_config.bak"
    ```
=== "8.5"

    #### 8.5 - 스크립트
    
    이제 스크립트를 만들어 봅시다.

    ```
    vi /usr/local/sbin/webuser
    ```


    그리고 다음 코드를 입력합니다.

    ```
    #!/bin/bash
    # 웹 사용자를 위해 SSHD 구성을 채우는 스크립트입니다.

    # 변수 설정

    tempfile="/usr/local/sbin/sshd_template"
    dompath="/var/www/sub-domains/"

    # 역방향(ext.domainname)으로 사용자 및 도메인 확인 팝업 표시:

    clear

    echo -n "Enter the web sftp user: "
    read sftpuser
    echo -n "Enter the domain in reverse. Example: com.domainname: "
    read dom
    echo -n "Is all of this correct: sftpuser = $sftpuser and domain = $dom (Y/N)? "
    read yn
    if [ "$yn" = "n" ] || [ "$yn" = "N" ]
    then
        exit
    fi
    if [ "$yn" = "y" ] || [ "$yn" = "Y" ]
    then
        /usr/bin/cat $tempfile > /usr/local/sbin/templates/$dom.txt
        /usr/bin/sed -i "s,replaceuser,$sftpuser,g" /usr/local/sbin/templates/$dom.txt
        /usr/bin/sed -i "s,replacedirectory,$dompath$dom,g" /usr/local/sbin/templates/$dom.txt
        /usr/bin/chown -R $sftpuser.apache $dompath$dom/html
    fi

    ## /etc/ssh/sshd_config를 백업합니다

    /usr/bin/rm -f /etc/ssh/sshd_config.bak

    /usr/bin/cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

    ## 이제 새 사용자 정보를 파일에 추가합니다

    cat /usr/local/sbin/templates/$dom.txt >> /etc/ssh/sshd_config

    ## sshd 다시 시작

    /usr/bin/systemctl restart sshd

    echo " "
    echo "Please check the status of sshd with systemctl status sshd."
    echo "You can verify that your information was added to the sshd_config by doing a more of the sshd_config"
    echo "A backup of the working sshd_config was created when this script was run: sshd_config.bak"
    ```


### 최종 변경 사항 및 스크립트 주의사항¶

!!! !!!

    위의 두 스크립트를 살펴보면 기본적으로 <code>sed가 사용하는 구분 기호를 /에서 ,로 변경한 것을 알 수 있습니다. sed는 모든 단일 바이트 문자를 구분 기호로 사용할 수 있습니다. 우리가 파일에서 찾고 바꾸려는 문자열에는 여러 개의 "/" 문자가 있으며, 각각의 "/" 앞에 백슬래시 "\" 를 추가해야했습니다. 구분 기호를 변경하면 이러한 이스케이프를 할 필요가 없어져서 훨씬 쉽게 바꿀 수 있습니다.
    </code>

스크립트와 SFTP 변경 루트에 대해 몇 가지 알아야 할 사항이 있습니다. 먼저 필요한 정보를 프롬프트로 입력받고 사용자가 확인할 수 있도록 다시 출력합니다. 확인 질문에 "N"으로 답하면 스크립트가 중지되고 아무것도 수행하지 않습니다. 8.5 스크립트는 실행 전에 `sshd_config`(`/etc/ssh/sshd_config.bak`)의 백업을 만듭니다. 8.6 또는 9.0 스크립트도 `sftp_config` 파일(`/etc/ssh/sftp/sftp_config.bak`)의 백업을 만듭니다. 이렇게 하면 항목을 잘못 추가한 경우 해당 백업 파일을 복원하고 `sshd`를 재시작하여 모든 작업을 다시 원상태로 복구할 수 있습니다.

SFTP 변경 루트를 위해 `sshd_config`에서 제공된 경로가 root에 소유되어야 합니다. 따라서 경로 끝에 `html` 디렉토리를 추가할 필요가 없습니다. 사용자가 인증되면 변경 루트는 사용자의 홈 디렉토리(이 경우 `../html` 디렉토리)를 입력한 도메인으로 변경합니다. 스크립트는 `../html` 디렉토리의 소유자를 sftpuser와 apache 그룹으로 적절히 변경했습니다.

!!! 경고 "스크립트 호환성"

    Rocky Linux 8.5용으로 만든 스크립트를 8.5, 8.6 또는 9.0에서도 사용할 수 있지만, 8.6 및 9.0용 스크립트는 8.5에 사용하는 것이 불가능합니다. 8.5 버전에는 드롭인 구성 파일 옵션(`Include` 지시문)이 활성화되어 있지 않았기 때문입니다.

이제 스크립트가 생성되었으므로 실행 가능하도록 만듭니다.

```
chmod +x /usr/local/sbin/webuser
```

그리고 두 개의 테스트 도메인에 대해 스크립트를 실행합니다.

### SSH 거부 및 SFTP 액세스 테스트

먼저 다른 기기에서 호스트 기기로 SFTP 사용자 중 하나로 `SSH` 테스트를 수행합니다. 암호를 입력하면 다음과 같은 메시지를 받아야 합니다.

```
이 서비스는 sftp 연결만 허용합니다.
```
#### 그래픽 도구 테스트

위의 메시지를 *받은* 경우 다음 단계는 SFTP 액세스를 테스트하는 것입니다. 간단한 방법으로 SFTP를 지원하는 Filezilla와 같은 그래픽 FTP 애플리케이션을 사용할 수 있습니다. 이 경우 필드는 다음과 같이 보일 것입니다.

* **Host:** sftp://hostname_or_IP_of_the_server
* **Username:** (예: myfixed)
* **Password:** (SFTP 사용자의 비밀번호)
* **Port:** (기본 포트 22에서 SSH 및 SFTP를 사용하는 경우 입력할 필요가 없습니다.)

Once filled in, you can click the "Quickconnect" (Filezilla) button and you should be connected to the `../html` directory of the appropriate site. 그런 다음 "html" 디렉토리를 두 번 클릭하여 그 안에 자신을 넣고 디렉토리에 파일을 넣으십시오. 성공하면 제대로 작동하는 것입니다.

#### 명령줄 도구 테스트

물론 이 모든 작업을 SSH가 설치된 기기(대부분의 Linux 설치에서 가능함)의 명령 줄에서 수행할 수 있습니다. 연결 및 몇 가지 옵션에 대한 간단한 개요는 다음과 같습니다.

* sftp 사용자 이름 (예: myfixed@ 호스트명 또는 서버의 IP: sftp myfixed@192.168.1.116)
* 메시지가 표시되면 암호를 입력
* cd html (html 디렉토리로 변경)
* pwd (현재 html 디렉토리에 위치함을 표시)
* lpwd (로컬 작업 디렉토리를 표시)
* lcd PATH (로컬 작업 디렉토리를 원하는 위치로 변경)
* put filename (파일을 `..html` 디렉토리에 복사)

전체 옵션 목록 등은 [SFTP 매뉴얼 페이지](https://man7.org/linux/man-pages/man1/sftp.1.html)를 참조하십시오.

### 웹 테스트 파일

For our dummy domains, we want to create a couple of `index.html` files that we can populate the `../html` directory with. 이 파일들을 만든 후 각 도메인의 SFTP 자격 증명을 사용하여 해당 디렉토리에 넣기만 하면 됩니다. 이 파일들은 매우 간단합니다. 그냥 사이트가 작동 중이며 SFTP 부분이 예상대로 작동하는지 확실히 볼 수 있도록 해주는 내용만 있으면 됩니다. 아래는 이 파일의 예시입니다. 물론 원하는대로 수정할 수 있습니다.

```
<!DOCTYPE html>
<html>
<head>
<title>My Broken Axel</title>
</head>
<body>

<h1>My Broken Axel</h1>
<p>A test page for the site.</p>

</body>
</html>
```

### 웹 테스트

이 파일이 예상대로 나타나고 로드되는지 확인하려면 워크스테이션의 호스트 파일을 수정하면 됩니다. Linux의 경우 `sudo vi /etc/hosts`를 실행한 다음 다음과 같이 테스트에 사용할 IP와 호스트 이름을 추가하면 됩니다.

```
127.0.0.1   localhost
192.168.1.116   www.site1.com site1.com
192.168.1.116   www.site2.com site2.com
# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
```

!!! !!!

    팁
        실제 도메인의 경우 DNS 서버를 위의 호스트로 채우는 것이 좋습니다. 그러나 이 <em x-id="3">Poor Man's DNS</em>를 사용하여 실제 DNS 서버에서 활성화되지 않은 도메인을 포함하여 모든 도메인을 테스트할 수 있습니다.

이제 웹 브라우저를 열고 주소 창에 각 도메인의 URL을 입력하여 `index.html` 파일이 정상적으로 표시되는지 확인합니다. (예: "http://site1.com") 테스트 인덱스 파일이 로드되면 모든 것이 올바르게 작동하는 것입니다.

## 3부: SSH 키 쌍을 사용한 관리 액세스

이 섹션의 [SSH 공개/개인 키](../security/ssh_public_private_keys.md) 문서에서  설명된 개념을 사용하지만, 더 나아가서 개선합니다. 처음 접하는 경우 계속하기 전에 해당 문서를 먼저 읽어보시기 바랍니다.

### 공개/개인 키 페어 생성

관리자 사용자의 작업 스테이션 중 하나(예: lblakely)에서 다음 작업을 수행합니다.

```
ssh-keygen -t rsa
```

이는 다음을 제공합니다:

```
Generating public/private rsa key pair.
Enter file in which to save the key (/home/lblakely/.ssh/id_rsa):
```

Enter 키를 눌러 해당 위치에 개인 키를 생성합니다. 그러면 다음과 같은 대화식 화면이 나타납니다.

```
Enter passphrase (empty for no passphrase):
```

여기서는 개인적으로 패스워드를 사용할 필요 여부를 결정합니다. 작성자는 항상 엔터 키를 누릅니다.

```
Enter same passphrase again:
```

이전에 입력한 패스워드를 다시 입력하거나, 패스워드를 사용하지 않으려면 엔터 키를 누릅니다.

At this point both the public and private keys have been created. 다른 시스템 관리자 예제 사용자에 대해 이 단계를 반복합니다.

### 공개 키를 SFTP 서버로 전송

다음 단계는 키를 서버로 내보내는 것입니다. 실제로 여러 서버를 관리하는 시스템 관리자는 자신의 공개 키를 담당하는 모든 서버로 전송합니다.

키가 생성되면 사용자는 `ssh-id-copy`를 사용하여 안전하게 서버에 키를 보낼 수 있습니다:

```
ssh-id-copy lblakely@192.168.1.116
```

서버는 사용자의 비밀번호를 한 번 묻고, 그런 다음 키를 authorized_keys 파일로 복사합니다. 또한 다음과 같은 메시지가 나타납니다.

```
Number of key(s) added: 1

Now try logging into the machine, with:   "ssh 'lblakely@192.168.1.116'"
and check to make sure that only the key(s) you wanted were added.
```

이 계정으로 로그인할 수 있다면 다른 관리자로도 동일한 프로세스를 반복합니다.

### 키 기반 로그인만 허용

위의 모든 작업이 계획대로 진행되고 관리자의 키가 이제 SFTP 서버에 있는 경우, 서버에서 패스워드 인증을 끄도록 합시다. 안전을 위해 의도하지 않은 결과가 발생할 경우를 대비하여 변경 사항을 쉽게 되돌릴 수 있도록 서버에 두 개의 연결이 있는지 확인하십시오.

이 단계를 수행하기 위해 다시 `sshd_config`을 수정해야 하며, 이전과 마찬가지로 파일의 백업을 먼저 만듭니다.

```
cp -f /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
```

다음으로, `sshd_config` 파일을 편집합니다.

```
vi /etc/ssh/sshd_config
```

이제 구성에서 tunneled 패스워드를 비활성화해야 합니다. 이 설정을 찾아서 다음과 같이 구성합니다.

```
PasswordAuthentication yes
```

다음과 같이 "no"로 변경합니다. 비고 처리만 하는 것은 실패하므로 기본 설정이 항상 "yes"임을 유의하세요.

```
PasswordAuthentication no
```

공개 키 인증은 기본적으로 활성화되어 있지만 파일을 확인할 때 명확히 드러나도록 하기 위해 다음 줄 앞에 있는 비고 처리를 제거합니다.

```
#PubkeyAuthentication yes
```

따라서 다음과 같이 읽습니다:

```
PubkeyAuthentication yes
```

이렇게 하면 `sshd_config` 파 파일이 자체 설명이 일정한 정도로 되도록 만들 수 있습니다.

변경 사항을 저장합니다. 손가락을 교차하고 `sshd`를 다시 시작합니다:

```
systemctl restart sshd
```

관리자 중 하나의 키로 서버에 로그인하는 것은 이전과 같이 작동해야 합니다. 그렇지 않으면 백업을 복원하고 모든 단계를 따랐는지 확인한 후 다시 시도하세요.

## Part 4: 원격 루트 로그인 비활성화

실제로 우리는 이미 기능적으로 그렇게 했습니다. 지금 루트 사용자로 서버에 로그인을 시도하면 다음과 같은 메시지가 표시됩니다.

```
root@192.168.1.116: Permission denied (publickey,gssapi-keyex,gssapi-with-mic).
```

그러나 누군가가 루트 사용자에 대한 공개/개인 키를 생성하여 해당 방법으로 서버에 접근하지 못하도록 하려고 합니다. 그러므로 마지막 단계가 필요합니다...누가 알았겠습니까!... `sshd_config` 파일에서 수행해야 합니다.

이 파일을 변경하고 있으므로, 다른 단계와 마찬가지로 계속하기 전에 파일의 백업 복사본을 만들어야 합니다.

```
cp -f /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
```

다시 말하지만 우리는 `sshd_config`를 편집하고 다음 줄을 찾아야 합니다.

```
vi /etc/ssh/sshd_config
```

그런 다음, 다음 행을 찾고 싶습니다:

```
PermitRootLogin yes
```

이를 "no"로 변경하여 다음과 같이 변경합니다.

```
PermitRootLogin no
```

그런 다음 파일을 저장하고 종료하고 `sshd`를 다시 시작합니다:

```
systemctl restart sshd
```

이제 누구든지 루트 사용자로 원격으로 'ssh'에 로그인하려고 하면 이전과 같은 거부 메시지를 받지만, **여전히** 루트를 위해 공개/개인 키 페어가 있더라도 서버에 액세스할 수 없습니다.

## 부록: 새로운 시스템 관리자

아직 논의하지 않은 하나의 주제는 새로운 시스템 관리자가 추가될 때 어떻게 해야 할지입니다. 패스워드 인증이 꺼져 있으므로 `ssh-copy-id`가 작동하지 않습니다. 이러한 상황을 위해 저자가 추천하는 방법은 다음과 같습니다. 하나 이상의 해결책이 있습니다.

### 첫 번째 솔루션 - 스니커즈 넷(Sneaker Net)

이 해결책은 서버에 물리적 액세스가 있고 서버가 물리적 하드웨어인 경우를 가정합니다.

* SFTP 서버에 사용자를 "wheel" 그룹에 추가합니다.
* 사용자에게 SSH 공개 및 개인 키를 생성하도록 지시합니다.
* USB 드라이브를 사용하여 공개 키를 드라이브에 복사하고 물리적으로 서버로 이동하여 새 시스템 관리자 `/home/[username]/.ssh` 디렉토리에 수동으로 설치합니다.

### 두 번째 솔루션 - `sshd_config` 임시 편집

이 해결책은 실수하기 쉽지만, 자주 사용되지 않기 때문에 주의해서 사용하면 괜찮습니다.

* SFTP 서버에 사용자를 "wheel" 그룹에 추가합니다.
* 키 기반 인증을 이미 사용하고 있는 다른 시스템 관리자가 `sshd_config` 파일에서 일시적으로 "PasswordAuthentication yes"로 변경하고 `sshd`를 다시 시작합니다.
* 새 시스템 관리자가 `ssh-copy-id`를 사용하여 비밀번호로 ssh 키를 서버로 복사합니다.

### 세 번째 솔루션 - 스크립트를 사용한 프로세스

이것은 저자가 가장 좋아하는 방법입니다. 위의 "두 번째 솔루션"와 동일한 작업을 수행하기 위해 이미 키 기반 액세스 권한이 있는 시스템 관리자와 `bash[script-name]`으로 실행해야 하는 스크립트를 사용합니다.

* `sshd_config` 파일을 수동으로 편집하고 다음과 같이 보여지는 `#PasswordAuthentication no` 주석 처리된 줄을 제거합니다. 이 줄은 패스워드 인증을 끄는 과정을 문서화하지만, 스크립트는 나중에 `PasswordAuthentication no`의 첫 번째 발생을 찾을 것이며, 이후에 `PasswordAuthentication yes`의 첫 번째 발생을 찾을 것이기 때문에 이 줄은 방해가 될 것입니다. 이 한 줄을 제거하면 스크립트가 정상적으로 작동합니다.
* SFTP 서버에 "quickswitch" 또는 원하는 이름으로 스크립트를 만듭니다. 이 스크립트의 내용은 다음과 같습니다.

```
#!/bin/bash
# 새 시스템 관리자 추가를 위한 스크립트

/usr/bin/cp -f /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

/usr/bin/sed -i '0,/PasswordAuthentication no/ s/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
/usr/bin/systemctl restart sshd
echo "Have the user send his keys, and then hit enter." read yn
/usr/bin/sed -i '0,/PasswordAuthentication yes/ s/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
/usr/bin/systemctl restart sshd
echo "Changes reversed"
```
스크립트 설명: 이 스크립트를 실행할 수 있도록 하기 위해 이 스크립트를 실행 가능하게 만들지 않습니다. 그 이유는 실수로 실행되지 않도록 하기 위함입니다. 이 스크립트는 `bash /usr/local/sbin/quickswitch`과 같이 실행되어야 합니다. 이 스크립트는 `sshd_config` 파일의 백업 복사본을 모든 다른 예제들과 같이 만듭니다. 그런 다음 `sshd_config` 파일을 제자리에서 편집하고 `PasswordAuthentication no`의 첫 번째 발생을 찾아 `PasswordAuthentication yes`로 변경한 다음 sshd를 다시 시작하고 사용자가 <kbd>ENTER</kbd>를 누를 때까지 기다립니다. 스크립트를 실행하는 시스템 관리자는 새 시스템 관리자와 통신하며, 새 시스템 관리자가 'ssh-copy-id'를 사용하여 키를 서버로 복사하면 스크립트를 실행하는 시스템 관리자가 ENTER를 누르면 변경 사항이 되돌려집니다.

## 결론

이 문서에서는 여러 개의 사이트 웹 서버를 더 안전하게 만들고 SFTP를 사용할 때 SSH를 통한 공격 벡터를 줄이기 위한 다양한 요소들을 다루었습니다. SFTP를 켜고 사용하는 것은 FTP를 사용하는 것보다 훨씬 더 안전합니다. 실제로 가장 *잘 보호된* FTP 서버를 사용하고 이 [VSFTPD 문서](secure_ftp_server_vsftpd.md)에서 설명한대로 가능한 한 안전하게 설정했더라도 SFTP를 사용하는 것이 더 안전합니다. 이 문서의 *모든* 단계를 구현함으로써 22번 포트 (SSH)를 공개 영역에 열어도 환경이 안전하다는 것을 확신할 수 있습니다.
