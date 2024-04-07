---
title: nmcli - 자동 연결 설정
author: wale soyinka
tags:
  - nmcli
---

# NetworkManager 연결 프로필 autoconnect 속성 수정

먼저 nmcli를 사용하여 Rocky Linux 시스템의 모든 네트워크 연결에 대한 autoconnect 속성의 현재 값을 쿼리하고 표시합니다. 다음 명령을 입력하세요:

```bash
nmcli -f name,autoconnect connection 
```

네트워크 연결에 대한 속성 값을 변경하려면 `nmcli 연결`과 함께 `modify` 하위 명령을 사용합니다. 예를 들어, `ens3` 연결 프로필에 대해 autoconnect 속성 값을 `no`에서 `yes`로 변경하려면 다음과 같이 입력하세요:

```bash
sudo nmcli con mod ens3 connection.autoconnect yes
```

## 명령 설명

```bash
connection (con)       : NetworkManager 연결 객체. 
modify (mod)           : 지정된 연결 프로필의 속성을 하나 이상 수정합니다.
connection.autoconnect : 설정 및 속성(<setting>.<property>)
-f, --fields           : 출력할 필드를 지정합니다.
```

## 참고 사항

이 팁은 기존의 NetworkManager 연결 프로필을 수정하는 방법을 보여줍니다. 이는 새로 설치된 Rocky Linux 시스템이나 시스템 업데이트 후에 네트워크 인터페이스가 자동으로 활성화되지 않는 경우 유용합니다. 이는 autoconnect 속성의 값이 `no`로 설정되어 있기 때문인 경우가 많습니다. `nmcli` 명령을 사용하여 값을 빠르게 `yes`로 변경할 수 있습니다.  
