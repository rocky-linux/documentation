---
title: 파일 관리
---

# Ansible - 파일 관리

이 문서에서는 Ansible로 파일을 관리하는 방법을 배웁니다.

****

**목적**: 이 문서에서는 다음을 수행하는 방법에 대해 알아볼 것 입니다:

:heavy_check_mark: 파일 내용 수정하기;       
:heavy_check_mark: 대상 서버에 파일 업로드하기;   
:heavy_check_mark: 대상 서버에서 파일을 검색하기.

:checkered_flag: **ansible**, **모듈**, **파일**

**지식**: :star: :star:     
**복잡성**: :star:

**소요 시간**: 20분

****

필요에 따라 시스템 구성 파일을 수정하기 위해 다른 앤서블 모듈을 사용해야 할 수 있습니다.

## `ini_file` 모듈

INI 파일을 수정하려는 경우(`[]`와 `key=value` 쌍 사이의 섹션) 가장 쉬운 방법은 `ini_file` 모듈을 사용하는 것입니다.

!!! 참고 사항

    자세한 내용은 [여기](https://docs.ansible.com/ansible/latest/collections/community/general/ini_file_module.html)에서 확인할 수 있습니다.

이 모듈은 다음을 필요로 합니다:

* 섹션의 값
* 옵션의 이름
* 새로운 값

사용 예:

```
- name: change value on inifile
  community.general.ini_file:
    dest: /path/to/file.ini
    section: SECTIONNAME
    option: OPTIONNAME
    value: NEWVALUE
```

## `lineinfile` 모듈

특정 파일에 특정 줄이 있는지 확인하거나 파일에 한 줄을 추가하거나 수정해야 할 때는 `linefile`모듈을 사용합니다.

!!! 참고 사항

    자세한 내용은 [여기](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/lineinfile_module.html)에서 확인할 수 있습니다.

이 경우, 파일에서 수정해야 할 줄은 정규식을 사용하여 찾게 됩니다.

예를 들어 `/etc/selinux/config` 파일에서 `SELINUX=`로 시작하는 행에 `enforcing` 값이 포함하도록 확인하려면 다음과 같이 사용할 수 있습니다:

```
- ansible.builtin.lineinfile:
    path: /etc/selinux/config
    regexp: '^SELINUX='
    line: 'SELINUX=enforcing'
```

## `copy` 모듈

앤서블 서버에서 하나 이상의 호스트로 파일을 복사해야 할 때는 `copy` 모듈을 사용하는 것이 좋습니다.

!!! 참고 사항

    자세한 내용은 [여기](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/copy_module.html)에서 확인할 수 있습니다.

다음과 같이 `myflile.conf`를 한 위치에서 다른 위치로 복사합니다:

```
- ansible.builtin.copy:
    src: /data/ansible/sources/myfile.conf
    dest: /etc/myfile.conf
    owner: root
    group: root
    mode: 0644
```

## `fetch` 모듈

파일을 원격 서버에서 로컬 서버로 복사해야 하는 경우 `fetch` 모듈을 사용하는 것이 가장 좋습니다.

!!! 참고 사항

    자세한 내용은 [여기](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/fetch_module.html)에서 확인할 수 있습니다.

이 모듈은 `copy` 모듈과 반대 역할을 합니다.

```
- ansible.builtin.fetch:
    src: /etc/myfile.conf
    dest: /data/ansible/backup/myfile-{{ inventory_hostname }}.conf
    flat: yes
```

## `template` 모듈

Ansible 및 해당 `template` 모듈은 **Jinja2** 템플릿 시스템(http://jinja.pocoo.org/docs/)을 사용하여 대상 호스트에 파일을 생성합니다.

!!! 참고 사항

    자세한 내용은 [여기](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/template_module.html) 에서 확인할 수 있습니다.

예시:

```
- ansible.builtin.template:
    src: /data/ansible/templates/monfichier.j2
    dest: /etc/myfile.conf
    owner: root
    group: root
    mode: 0644
```

대상 서비스에서 허용하는 경우 유효성 검사 단계를 추가할 수 있습니다(예: `apachectl -t` 명령이 있는 apache).

```
- template:
    src: /data/ansible/templates/vhost.j2
    dest: /etc/httpd/sites-available/vhost.conf
    owner: root
    group: root
    mode: 0644
    validate: '/usr/sbin/apachectl -t'
```

## `get_url` 모듈

웹 사이트 또는 ftp에서 하나 이상의 호스트로 파일을 업로드하려면 `get_url` 모듈을 사용합니다:

```
- get_url:
    url: http://site.com/archive.zip
    dest: /tmp/archive.zip
    mode: 0640
    checksum: sha256:f772bd36185515581aa9a2e4b38fb97940ff28764900ba708e68286121770e9a
```

파일의 체크섬을 제공하면 파일이 이미 대상 위치에 있고 해당 체크섬이 제공된 값과 일치하는 경우 파일이 다시 다운로드되지 않습니다.
