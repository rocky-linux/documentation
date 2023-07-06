---
title: 관리 서버 최적화
author: Antoine Le Morvan
contributors: Steven Spencer
update: 06-Dec-2021
---

# 관리 서버 최적화

이 문서에서는 Ansible 관리 서버를 최적화하기 위해 관심이 있는 구성 옵션을 검토하겠습니다.

## `ansible.cfg` 구성 파일

주석을 달기에 흥미로운 몇 가지 구성 옵션:

* `forks`:  기본값은 5로, Ansible이 원격 호스트와 통신하기 위해 병렬로 실행하는 프로세스의 수입니다. 이 수가 높을수록 Ansible은 동시에 관리할 수 있는 클라이언트가 많아지고 처리 속도가 향상됩니다. 설정할 수 있는 값은 관리 서버의 CPU/RAM 제한에 따라 다릅니다. 기본값인 `5`는 매우 작으며, Ansible 문서에 따르면 많은 사용자들이 50개 이상, 심지어 500개 이상으로 설정하는 경우가 많습니다.

* `gathering`: 이 변수는 팩트를 수집하는 정책을 변경합니다. 기본값은 `implicit`로, 팩트가 체계적으로 수집될 것이라는 의미입니다. 이 변수를 `smart`로 변경하면, 이미 수집되지 않은 경우에만 팩트를 수집합니다. 이 옵션은 팩트 캐시(아래 참조)와 결합하여 성능을 크게 향상시킬 수 있습니다.

* `host_key_checking`: 서버 보안에 주의하세요! 그러나 환경을 제어할 수 있는 경우 원격 서버의 키 제어를 비활성화하고 연결 시간을 절약할 수 있습니다. 또한 원격 서버에서 SSH 서버의 DNS 사용을 비활성화할 수도 있습니다 (`/etc/ssh/sshd_config`, 옵션 `UseDNS no`). 이 옵션은 연결 시간을 낭비하며 대부분 연결 로그에서만 사용됩니다.

* `ansible_managed`: 이 변수는 기본적으로 `Ansible 관리`를 포함하는데, 일반적으로 원격 서버에 배포되는 파일 템플릿에서 사용됩니다. 이를 통해 관리자에게 파일이 자동으로 관리되고 변경 사항이 잠재적으로 손실될 수 있다는 것을 알릴 수 있습니다. 관리자들에게 더 완전한 메시지를 제공하는 것이 흥미로울 수 있습니다. 그러나 이 변수를 변경하면 템플릿과 연결된 핸들러를 통해 데몬을 다시 시작할 수 있으므로 주의해야 합니다.

* `ssh_args = -C -o ControlMaster=auto -o ControlPersist=300s -o PreferredAuthentications=publickey`: ssh 연결 옵션을 지정합니다. 공개 키 이외의 모든 인증 방법을 비활성화하여 많은 시간을 절약할 수 있습니다. `ControlPersist` 값을 증가시켜서 성능을 향상시킬 수도 있습니다 (문서에서는 30분과 같은 값이 적합할 수 있다고 제안합니다). 클라이언트와의 연결이 더 오래 유지되고 동일한 서버에 다시 연결할 때 재사용될 수 있어 시간을 상당히 절약할 수 있습니다.

* `control_path_dir`: 연결 소켓의 경로를 지정합니다. 이 경로가 너무 길면 문제가 발생할 수 있습니다. `/tmp/.cp`와 같이 짧은 경로로 변경하는 것을 고려해보세요.

* `pipelining`: 이 값을 `True`로 설정하면 원격 모듈을 실행할 때 필요한 SSH 연결 수가 줄어들어 성능이 향상됩니다. 먼저 `sudoers` 옵션에서 `requiretty` 옵션이 비활성화되어 있는지 확인해야 합니다(문서 참조).

## 사실 캐싱

팩트 수집은 시간이 걸릴 수 있는 과정입니다. 이를 필요로하지 않는 플레이북의 경우 수집을 비활성화하는 것이 흥미로울 수 있습니다 (`gather_facts` 옵션을 통해) 또는 이러한 팩트를 일정 기간 동안 메모리에 캐시로 유지할 수 있습니다 (예: 24시간).

이러한 팩트는 간단하게 `redis` 데이터베이스에 저장할 수 있습니다.

```
sudo yum install redis
sudo systemctl start redis
sudo systemctl enable redis
sudo pip3 install redis
```

ansible 구성을 수정하는 것을 잊지 마십시오.

```
fact_caching = redis
fact_caching_timeout = 86400
fact_caching_connection = localhost:6379:0
```

올바른 작동을 확인하려면 `redis` 서버를 요청하는 것만으로도 충분합니다:

```
redis-cli
127.0.0.1:6379> keys *
127.0.0.1:6379> get ansible_facts_SERVERNAME
```

## Vault 사용

다양한 비밀번호와 비밀은 Ansible 소스 코드에 평문으로 저장할 수 없으며, 관리 서버나 가능한 소스 코드 관리자에 저장할 수도 없습니다.

Ansible은 암호화 관리자(`ansible-vault`) 사용하는 것을 제안합니다.

원리는 `ansible-vault` 명령을 사용하여 변수나 전체 파일을 암호화하는 것입니다.

Ansible은 실행 시 이 파일을 복호화하여 암호화 키를 파일 (예: `/etc/ansible/ansible.cfg`)에서 검색할 수 있습니다. 후자는 파이썬 스크립트 또는 기타일 수도 있습니다.

`/etc/ansible/ansible.cfg` 파일을 편집합니다.

```
#vault_password_file = /path/to/vault_password_file
vault_password_file = /etc/ansible/vault_pass
```

비밀번호를 `/etc/ansible/vault_pass` 파일에 저장하고 필요한 제한적인 권한을 할당하세요:

```
mysecretpassword
```

그런 다음, 다음 명령을 사용하여 파일을 암호화할 수 있습니다:

```
ansible-vault encrypt myfile.yml
```

`ansible-vault`에 의해 암호화된 파일은 헤더로 쉽게 식별할 수 있습니다:

```
$ANSIBLE_VAULT;1.1;AES256
35376532343663353330613133663834626136316234323964333735363333396136613266383966
6664322261633261356566383438393738386165333966660a343032663233343762633936313630
34373230124561663766306134656235386233323964336239336661653433663036633334366661
6434656630306261650a313364636261393931313739363931336664386536333766326264633330
6334
```

파일이 암호화된 후에도 다음 명령을 사용하여 편집할 수 있습니다:

```
ansible-vault edit myfile.yml
```

비밀번호 저장을 다른 비밀번호 관리자로 이동할 수도 있습니다.

예를 들어, rundeck 저장소에 저장된 비밀번호를 검색하는 경우:

```
#!/usr/bin/env python
# -*- coding: utf-8 -*-
import urllib.request
import io
import ssl

def get_password():
    '''
    :return: Vault password
    :return_type: str
    '''
    ctx = ssl.create_default_context()
    ctx.check_hostname = False
    ctx.verify_mode = ssl.CERT_NONE

    url = 'https://rundeck.rockylinux.org/api/11/storage/keys/ansible/vault'
    req = urllib.request.Request(url, headers={
                          'Accept': '*/*',
                          'X-Rundeck-Auth-Token': '****token-rundeck****'
                          })
    response = urllib.request.urlopen(req, context=ctx)

    return response.read().decode('utf-8')

if __name__ == '__main__':
    print(get_password())
```

## Windows 서버 작업

관리 서버에 다음 패키지를 설치해야 합니다.

* 패키지 관리자를 통해:

```
sudo dnf install python38-devel krb5-devel krb5-libs krb5-workstation
```

올바른 `realms`을 지정하도록 `/etc/krb5.conf` 파일을 구성합니다.

```
[realms]
ROCKYLINUX.ORG = {
    kdc = dc1.rockylinux.org
    kdc = dc2.rockylinux.org
}
[domain_realm]
  .rockylinux.org = ROCKYLINUX.ORG
```

* Python 패키지 관리자를 통해:

```
pip3 install pywinrm
pip3 install pywinrm[credssp]
pip3 install kerberos requests-kerberos
```

## IP 모듈 작업

네트워크 모듈에는 일반적으로 `netaddr` python 모듈을 필요로 합니다:

```
sudo pip3 install netaddr
```

## CMDB 생성

`ansible-cmdb`라는 도구를 사용하여 Ansible로부터 CMDB를 생성할 수 있습니다.

```
pip3 install ansible-cmdb
```

다음 명령을 사용하여 Ansible에 의해 팩트를 내보내야 합니다:

```
ansible --become --become-user=root -o -m setup --tree /var/www/ansible/cmdb/out/
```

그런 다음 global `json` 파일을 생성할 수 있습니다.

```
ansible-cmdb -t json /var/www/ansible/cmdb/out/linux > /var/www/ansible/cmdb/cmdb-linux.json
```

웹 인터페이스를 선호하는 경우:

```
ansible-cmdb -t html_fancy_split /var/www/ansible/cmdb/out/
```
