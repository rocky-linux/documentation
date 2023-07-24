---
title: MariaDB 데이터베이스 서버
author: Steven Spencer
contributors: Ezequiel Bruni, William Perron
tested_with: 8.5, 8.6, 9.0
tags:
  - 데이터베이스
  - mariadb
---

# MariaDB 데이터베이스 서버

## 전제 조건

* Rocky Linux 서버
* 명령 줄 편집기에 능숙함(이 예에서는 _vi_를 사용함)
* 명령 줄에서 명령을 실행하고 로그를 보는 등 일반적인 시스템 관리자 역할에 대한 높은 수준의 편안함
* _mariadb-server_ 데이터베이스에 대한 이해가 도움이 됩니다.
* 모든 명령은 root 사용자 또는 _sudo_로 실행됩니다.

## 소개

_mariadb-server_와 클라이언트 _mariadb_는 _mysql-server_ 및 _mysql_에 대한 오픈 소스 대안이며 명령 구조를 공유합니다. _mariadb-server_는 인기 있는 [Wordpress CMS](https://wordpress.org/)에서 요구되기 때문에 많은 웹 서버에서 실행됩니다. 그러나 이 데이터베이스에는 많은 다른 용도가 있습니다.

웹 서버를 보호하는 다른 도구와 함께 사용하려면 [Apache 강화 웹 서버 가이드](../web/apache_hardened_webserver/index.md)를 다시 참조하세요.

## mariadb 서버 설치

_mariadb-server_를 설치해야 합니다.

`dnf install mariadb-server`

## mariadb 서버 보안

_mariadb-server_의 보안을 강화하기 위해 스크립트를 실행해야 합니다. 그러나 실행하기 전에 mariadb를 활성화하고 시작해야 합니다.

`systemctl enable mariadb`

그리고 다음을 실행합니다.

`systemctl start mariadb`

다음으로 이 명령을 실행하세요.

`mysql_secure_installation`

!!! !!!

    Rocky Linux 8.5에서 기본적으로 활성화된 mariadb-server의 버전은 10.3.32입니다. 10.5.13을 설치하려면 다음 모듈을 활성화하세요.

    ```
    dnf module enable mariadb:10.5
    ```


    그런 다음 `mariadb`를 설치하세요. MariaDB의 10.4.6 버전부터는 이전에 사용되던 `mysql`` 접두사 명령 대신 사용할 수 있는 MariaDB 특정 명령이 있습니다. 이러한 명령에는 앞서 언급한 `mysql_secure_installation`이 포함되어 있으며 이제 `mariadb-secure-installation`` 버전의 MariaDB를 사용하여 호출할 수 있습니다.

이렇게 하면 대화 상자가 나타납니다.

```
NOTE: 이 스크립트의 모든 부분을 제대로 사용하기를 모든 MariaDB
서버가 운영 환경에서 권장됩니다!  각 단계를 주의 깊게 읽어보세요!

보안을 위해 MariaDB에 로그인하려면 루트 사용자의 현재 암호가 필요합니다.  방금 MariaDB를 설치했고 루트 암호를 아직 설정하지 않은 경우 암호가 비어 있으므로 여기에서 Enter 키를 누르기만 하면 됩니다.

Enter current password for root (enter for none):
```

이것은 새로 설치한 것이므로 root 암호가 설정되지 않았습니다. 그러므로 여기에서 그냥 Enter를 누르세요.

대화 상자의 다음 부분은 계속됩니다.

```
OK, successfully used password, moving on...

Setting the root password ensures that nobody can log into the MariaDB
root user without the proper authorisation.

Set root password? [Y/n]
```

root 암호를 설정하는 것이 _좋습니다_. 이를 위해 어떤 암호를 설정할지 결정하고 필요한 경우 어딘가에 패스워드 관리자에 문서화해 놓으세요. 기본값 "Y"를 수용하려면 'Enter'를 누르세요. 이렇게 하면 암호 대화 상자가 나타납니다.

```
New password:
Re-enter new password:
```

새로 선택한 암호를 입력한 다음 다시 입력하여 확인하세요. 성공하면 다음과 같은 대화 상자가 나타납니다.

```
Password updated successfully!
Reloading privilege tables..
 ... ...
```

다음 대화는 익명 사용자를 다룹니다.

```
By default, a MariaDB installation has an anonymous user, allowing anyone
to log into MariaDB without having to have a user account created for
them.  This is intended only for testing, and to make the installation
go a bit smoother.  You should remove them before moving into a
production environment.

Remove anonymous users? [Y/n]
```

답은 여기서 "Y"이므로 기본값을 수락하려면 'Enter'를 누르세요.

대화 상자는 루트 사용자의 원격 로그인 허용을 다루는 섹션으로 진행합니다.

```
... ...

Normally, root should only be allowed to connect from 'localhost'.  This
ensures that someone cannot guess at the root password from the network.

Disallow root login remotely? [Y/n]
```

root는 기계 내부에서만 필요합니다. 따라서 'Enter'를 눌러 기본값을 수락하세요.

그런 다음 대화 상자는 _mariadb-server_와 함께 자동으로 설치되는 '테스트' 데이터베이스로 이동합니다.

```
... ...


By default, MariaDB comes with a database named 'test' that anyone can
access.  This is also intended only for testing, and should be removed
before moving into a production environment.

Remove test database and access to it? [Y/n]
```

다시 한번 답은 기본값입니다. 제거하려면 'Enter'를 누르세요.

마지막으로, 대화 상자에서 권한을 다시 로드하려고하는지 물어봅니다.

```
- Dropping test database...
 ... ...
 - Removing privileges on test database...
 ... ...

Reloading the privilege tables will ensure that all changes made so far
will take effect immediately.

Reload privilege tables now? [Y/n]
```

다시 한번 'Enter'를 누르세요. 모든 것이 잘 진행된다면 다음과 같은 메시지를 받게 될 것입니다.

```
 ... ...

Cleaning up...

All done!  If you've completed all of the above steps, your MariaDB
installation should now be secure.

Thanks for using MariaDB!
```

이제 MariaDB를 사용할 준비가 되었습니다.

### Rocky Linux 9.0 변경 사항

Rocky Linux 9.0에서는 `mariadb-server-10.5.13-2`를 기본 mariadb-server 버전으로 사용합니다. 10.4.3 버전부터는 새로운 플러그인이 서버에 자동으로 활성화되며 `mariadb-secure-installation` 대화 상자가 변경됩니다. 해당 플러그인은 `unix-socket` 인증입니다. 이 기능에 대한 설명은 [이 문서](https://mariadb.com/kb/en/authentication-plugin-unix-socket/)에서 잘 설명되어 있습니다. `unix-socket` 인증을 사용하면 로그인한 사용자의 자격 증명을 사용하여 데이터베이스에 액세스할 수 있습니다. 예를 들어 root 사용자가 로그인한 후 `mysqladmin`을 사용하여 데이터베이스를 생성하거나 삭제하는 경우(또는 다른 함수)에는 액세스에 비밀번호가 필요하지 않습니다. `mysql`에서도 동일하게 작동합니다. 또한 원격으로 암호를 노출시킬 필요도 없습니다. 이는 데이터베이스의 보호에 사용되는 서버의 사용자 보안에 따라 달라집니다.

`mariadb-secure-installation`에서 비밀번호 설정 후 두 번째 대화 상자는 다음과 같습니다.

```
Switch to unix_socket authentication Y/n
```

물론 기본값은 "Y"이지만 "n"이라고 대답하더라도 플러그인이 활성화되면 사용자에게 비밀번호를 요청하지 않습니다. 적어도 명령 줄 인터페이스에서는 암호를 지정하거나 암호를 지정하지 않아도 작동합니다.

```
mysql

MariaDB [(none)]>
```

```
mysql -p
Enter password:

MariaDB [(none)]>
```

이 기능에 대한 자세한 정보는 위의 링크를 참조하십시오. 이 플러그인을 비활성화하고 암호를 필수 필드로 다시 되돌릴 수 있는 방법도 해당 링크에서 자세히 설명되어 있습니다.

## 결론

_mariadb-server_와 같은 데이터베이스 서버는 많은 용도로 사용될 수 있습니다. Wordpress CMS의 인기로 인해 웹 서버에서 자주 찾을 수 있습니다. 그러나 데이터베이스를 실제 운영 환경에서 실행하기 전에 보안을 강화하는 것이 좋습니다.
