---
title: 보안 FTP 서버 - vsftpd
author: Steven Spencer
contributors: Ezequiel Bruni
tested_with: 8.5, 8.6, 9.0
tags:
  - security
  - ftp
  - vsftpd
---

# 보안 FTP 서버 -  `vsftpd`

## 필요 사항

* 커맨드 라인 편집기 숙련도(이 예제에서는 `vi`를 사용함)
* 커맨드 라인에서 명령 실행, 로그 보기, 기타 시스템 관리자 업무에 대한 높은 수준의 숙련도
* PAM과 `openssl` 명령을 이해하면 도움이 됩니다.
* 모든 명령은 루트 사용자 또는 `sudo`로 실행됩니다.

## 소개

`vsftpd`는 Very Secure FTP Daemon의 약자로 (FTP는 파일 전송 프로토콜입니다). 오랫동안 사용 가능한 데몬으로, 실제로 Rocky Linux와 많은 다른 리눅스 배포판에서 기본 FTP 데몬입니다.

`vsftpd`는 PAM(Pluggable Authentication Modules)을 사용하여 가상 사용자의 사용을 허용합니다. 이러한 가상 사용자는 시스템에 존재하지 않으며 FTP를 사용하는 것 외에 다른 권한이 없습니다. 가상 사용자가 침해당하더라도 해당 사용자로서 액세스한 후에 다른 권한을 갖지 않습니다. 이 설정은 매우 안전하지만 약간의 추가 작업이 필요합니다.

!!! 팁 "`sftp` 고려"

    여기에서 `vsftpd`를 설정하는 데 사용된 보안 설정을 사용하더라도 `sftp`를 대신 고려할 수 있습니다. <code>sftp는 전체 연결 스트림을 암호화하며 이러한 이유로 더 안전합니다. `sftp`를 설정하고 SSH를 제한하는 [보안 서버 - `sftp`](sftp.md) 문서를 만들었습니다. 
    </code>

## `vsftpd` 설치

`openssl` 설치를 확인해야 합니다. 웹 서버를 실행 중인 경우 **이미 설치된 상태**일 수 있지만 확인하기 위해 다음을 실행할 수 있습니다:

```
dnf install vsftpd openssl
```

vsftpd 서비스를 활성화하려면 다음을 실행해야 합니다:

```
systemctl enable vsftpd
```

서비스를 아직 시작하지 마세요.

## `vsftpd 구성`

일부 설정을 비활성화하고 다른 설정을 활성화해야 합니다. 일반적으로 `vsftpd`를 설치하면 가장 안정적인 옵션이 이미 설정되어 있습니다. 그러나 이를 확인하는 것이 좋습니다.

구성 파일을 확인하고 필요한 경우 변경하려면 다음을 실행하세요:

```
vi /etc/vsftpd/vsftpd.conf
```

"anonymous_enable=" 줄을 찾고 "NO"로 설정되어 있고 주석 처리되지 **않았는지** 확인합니다. (이 줄을 주석 처리하면 익명 로그인이 활성화됩니다).  올바른 경우 줄은 다음과 같아야 합니다:

```
anonymous_enable=NO
```

"local_enable"이 "YES"로 설정되어 있는지 확인하세요:

```
local_enable=YES
```

로컬 루트 사용자를 위한 줄을 추가합니다. 설치 중인 서버가 웹 서버인 경우, 우리는 [Apache 웹 서버 Multi-Site 설정](../web/apache-sites-enabled.md)을 사용하고 로컬 루트가 해당 설정을 반영한다고 가정합니다. 설정이 다른 경우 또는 웹 서버가 아닌 경우 "local_root" 설정을 조정하세요:

```
local_root=/var/www/sub-domains
```

"write_enable"도 "YES"로 설정되어 있는지 확인합니다:

```
write_enable=YES
```

"chroot_local_users" 줄을 찾아 비고를 제거하세요. 아래에 표시된 것처럼 이후에 두 줄을 추가하세요:

```
chroot_local_user=YES
allow_writeable_chroot=YES
hide_ids=YES
```

이 밑에 가상 사용자를 다루는 섹션을 추가해야 합니다:

```
# 가상 사용자 설정
user_config_dir=/etc/vsftpd/vsftpd_user_conf
guest_enable=YES
virtual_use_local_privs=YES
pam_service_name=vsftpd
nopriv_user=vsftpd
guest_username=vsftpd
```

마지막으로 인터넷을 통해 전송되는 비밀번호의 암호화를 강제하는 섹션을 파일 가장 아래에 추가해야 합니다. `openssl`이 설치되어 있어야 하며 이를 위해 인증서 파일을 생성해야 합니다.

먼저 파일 가장 아래에 다음 줄을 추가하세요:

```
rsa_cert_file=/etc/vsftpd/vsftpd.pem
rsa_private_key_file=/etc/vsftpd/vsftpd.key
ssl_enable=YES
allow_anon_ssl=NO
force_local_data_ssl=YES
force_local_logins_ssl=YES
ssl_tlsv1=YES
ssl_sslv2=NO
ssl_sslv3=NO

pasv_min_port=7000
pasv_max_port=7500
```

구성을 저장합니다. (`vi`에서 <kbd>SHIFT</kbd>+<kbd>:</kbd>+<kbd>wq</kbd> 사용)

## RSA 인증서 설정

`vsftpd` RSA 인증서 파일을 생성해야 합니다. 일반적으로 서버는 4년 또는 5년 정도 운영되는 것으로 가정합니다. 서버가 이 하드웨어에서 실행되는 기간을 기준으로 인증서의 일 수를 설정하세요.

필요에 따라 일 수를 수정하고 다음 명령어 형식을 사용하여 인증서와 개인 키 파일을 생성하세요:

```
openssl req -x509 -nodes -days 1825 -newkey rsa:2048 -keyout /etc/vsftpd/vsftpd.key -out /etc/vsftpd/vsftpd.pem
```

인증서 생성 프로세스와 마찬가지로, 이 명령어를 실행하면 정보를 입력하라는 스크립트가 시작됩니다. 이는 어려운 프로세스가 아닙니다. 여러 필드를 비워둘 것입니다.

첫 번째 필드는 국가 코드 필드이며 국가의 두 글자 코드로 채우세요:

```
Country Name (2 letter code) [XX]:
```

다음은 주 또는 지방을 입력하세요. 줄임말이 아닌 전체 이름으로 입력하세요:

```
State or Province Name (full name) []:
```

다음은 위치 이름입니다. 이것은 도시 이름입니다:

```
Locality Name (eg, city) [Default City]:
```

다음은 회사 또는 조직 이름입니다. (_vi_를 사용하는 경우 `SHIFT:wq`입니다.) 이는 선택사항입니다:

```
Organization Name (eg, company) [Default Company Ltd]:
```

다음은 조직 단위 이름입니다. 서버가 특정 부서용인 경우 이 필드를 채우거나 비워둘 수 있습니다:

```
Organizational Unit Name (eg, section) []:
```

다음 필드를 채워야 하지만 어떻게 입력할지 결정할 수 있습니다. 이것은 서버의 공통 이름입니다. 예: `webftp.domainname.ext`:

```
Common Name (eg, your name or your server's hostname) []:
```

이메일 필드는 비워둘 수 있습니다:

```
Email Address []:
```

작업이 완료되면 인증서가 생성됩니다.

## <a name="virtualusers"></a>가상 사용자 설정

앞서 언급했듯이, `vsftpd`에서 가상 사용자를 사용하면 시스템 권한이 전혀 없기 때문에 훨씬 안전합니다. 이에 따라 가상 사용자를 사용하려면 사용자를 추가하고 그룹을 추가해야 합니다: 또한 그룹을 추가해야 합니다:

```
groupadd nogroup
useradd --home-dir /home/vsftpd --gid nogroup -m --shell /bin/false vsftpd
```

이 사용자는 `vsftpd.conf` 파일의 `guest_username=` 줄과 일치해야 합니다.

`vsftpd`의 구성 디렉토리로 이동하세요:

```
cd /etc/vsftpd
```

비밀번호 데이터베이스를 생성해야 합니다. 이 데이터베이스를 사용하여 가상 사용자를 인증합니다. 가상 사용자와 비밀번호를 읽을 파일을 생성해 데이터베이스를 만듭니다. 그러면 데이터베이스가 생성됩니다.

나중에 사용자를 추가할 때는 이 프로세스를 다시 반복하려고 합니다:

```
vi vusers.txt
```

사용자와 비밀번호는 줄로 구분되며, 사용자를 입력한 후 <kbd>ENTER</kbd>를 누르고 비밀번호를 입력하세요. 현재 시스템에 액세스할 수 있는 모든 사용자를 추가할 때까지 계속하세요. 예시:

```
user_name_a
user_password_a
user_name_b
user_password_b
```

텍스트 파일을 생성한 후에는 `vsftpd`가 가상 사용자에 대해 사용할 비밀번호 데이터베이스를 생성해야 합니다. 이를 위해 `db_load` 명령어를 사용합니다. `db_load`는 시스템에 로드되어 있는 `libdb-utils`에서 제공되지만 시스템에 설치되어 있지 않은 경우 다음 명령어로 간단히 설치할 수 있습니다:

```
dnf install libdb-utils
```

다음 명령어로 텍스트 파일로부터 데이터베이스를 생성하세요:

```
db_load -T -t hash -f vusers.txt vsftpd-virtual-user.db
```

 여기서 `db_load`가 수행하는 작업을 잠시 검토해 보세요:


* -T는 텍스트 파일을 데이터베이스로 쉽게 가져올 수 있도록 하는 데 사용됩니다.
* -t는 기반이 되는 액세스 방법을 지정하도록 지시합니다.
* _hash_는 지정하는 기반이 되는 액세스 방법입니다.
* -f는 지정된 파일에서 읽도록 지시합니다.
* 지정된 파일은 _vusers.txt_ 입니다.
* 그리고 생성하거나 추가하는 데이터베이스는 _vsftpd-virtual-user.db_입니다.

데이터베이스 파일의 기본 권한을 변경합니다:

```
chmod 600 vsftpd-virtual-user.db
```

그리고 "vusers.txt" 파일을 제거하세요:

```
rm vusers.txt
```

사용자를 추가할 때는 `vi`를 사용하여 다른 "vusers.txt" 파일을 생성하고 `db_load` 명령어를 다시 실행하여 사용자를 데이터베이스에 추가하세요.

## PAM 설정

`vsftpd`는 패키지를 설치하면 기본적인 pam 파일을 설치합니다. 이 파일을 자체 콘텐츠로 대체할 것입니다.  **항상** 이전 파일의 백업 복사본을 먼저 만드세요.

/root에 디렉토리에 백업 파일을 저장할 디렉토리를 만드세요:

```
mkdir /root/backup_vsftpd_pam
```

pam 파일을 이 디렉토리로 복사하세요:

```
cp /etc/pam.d/vsftpd /root/backup_vsftpd_pam/
```

원본 파일을 편집하세요:

```
vi /etc/pam.d/vsftpd
```

"#%PAM-1.0"을 제외한 모든 내용을 삭제하고 다음 라인들을 추가하세요:

```
auth       required     pam_userdb.so db=/etc/vsftpd/vsftpd-virtual-user
account    required     pam_userdb.so db=/etc/vsftpd/vsftpd-virtual-user
session    required     pam_loginuid.so
```

변경 사항을 저장하고 빠져나오세요(`vi`에서 <kbd>SHIFT</kbd>+<kbd>:</kbd>+<kbd>wq</kbd> 사용).

이렇게 하면 `vsftpd-virtual-user.db`에 정의된 가상 사용자로 로그인할 수 있으며, 로컬 로그인은 비활성화됩니다.

## 가상 사용자 구성 설정

각 가상 사용자는 자체 구성 파일을 갖습니다. 이 파일은 해당 사용자의 "local_root" 디렉토리를 지정합니다. 이 "local_root" 디렉토리의 소유권은 "vsftpd" 사용자와 "nogroup" 그룹이 있어야 합니다.

위의 [가상 사용자 설정하기](#virtualusers) 섹션을 참조하세요. 디렉토리의 소유권을 변경하려면 다음을 명령 줄에서 입력하세요:

```
chown vsftpd.nogroup /var/www/sub-domains/whatever_the_domain_name_is/html
```

가상 사용자의 구성 파일을 생성해야 합니다:

```
mkdir /etc/vsftpd/vsftpd_user_conf
vi /etc/vsftpd/vsftpd_user_conf/username
```

이 파일에는 가상 사용자의 "local_root"를 지정하는 단일 라인이 있어야 합니다:

```
local_root=/var/www/sub-domains/com.testdomain/html
```

이 경로는 `vsftpd.conf` 파일의 "Virtual User" 섹션에 지정됩니다.

## `vsftpd` 시작하기

`vsftpd` 서비스를 시작하고 서비스가 제대로 시작되는지 테스트하세요:

```
systemctl restart vsftpd
```

### `vsftpd` 테스트

FTP로 사용자의 로그인을 테스트하려면 명령 줄에서 테스트할 수도 있으며, FTP로 해당 시스템에 액세스를 테스트할 수도 있습니다. 그러나, [FileZilla](https://filezilla-project.org/)와 같은 FTP 클라이언트로 테스트하는 것이 가장 간단합니다.

_vsftpd_를 실행 중인 서버로 가상 사용자로 테스트할 때, SSL/TLS 인증서 신뢰 메시지가 표시됩니다. 이 메시지는 서버가 인증서를 사용하고 계속하기 전에 인증서를 승인하라는 요청입니다. 가상 사용자로 연결된 경우 "local_root" 폴더에 파일을 업로드할 수 있습니다.

파일을 업로드할 수 없는 경우 각 단계를 다시 확인해야 할 수도 있습니다. 예를 들어, "local_root"의 소유권 권한이 "vsftpd" 사용자와 "nogroup" 그룹으로 설정되어 있는지 확인해야 할 수 있습니다.

## 결론

`vsftpd`는 인기 있고 일반적인 FTP 서버로 독립형 서버이거나 [Apache Hardened 웹 서버](../web/apache_hardened_webserver/index.md)의 일부가 될 수 있습니다. 가상 사용자와 인증서를 사용하도록 설정하면 꽤 안전합니다.

이 절차에는 `vsftpd`를 설정하는 많은 단계가 포함되어 있습니다. 올바르게 설정하는 데 추가 시간을 소요하면 서버가 가능한 한 안전하게 유지됩니다.
