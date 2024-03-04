---
title: RL9 - 네트워크 관리자
author: tianci li
contributors: Steven Spencer
tags:
  - networkmanager
  - RL9
---

# NetworkManager 네트워크 구성 도구 모음

2004년 레드햇은 **NetworkManager** 프로젝트를 시작했습니다. 이 프로젝트는 특히 무선 네트워크 관리를 포함한 현재 네트워크 관리의 요구에 보다 쉽게 대응할 수 있도록 리눅스 사용자를 지원하는 것을 목표로 합니다. 오늘날 이 프로젝트는 GNOME에서 관리되고 있습니다. NetworkManager의 홈페이지는 여기에서 찾을 수 있습니다: https://networkmanager.dev/

공식 소개 - NetworkManager는 표준 Linux 네트워크 구성 도구 모음입니다. 데스크톱에서 서버 및 모바일 장치에 이르기까지 다양한 네트워크 설정을 지원하며 널리 사용되는 데스크톱 환경 및 서버 구성 관리 도구와 완벽하게 통합됩니다.

제품군에는 주로 두 가지 명령줄 도구가 포함되어 있습니다:

* `nmtui`. 그래픽 인터페이스에서 네트워크를 구성합니다.

```bash
shell > dnf -y install NetworkManager NetworkManager-tui
shell > nmtui
```

| NetworkManager TUI |    |
| ------------------ | -- |
| 연결 편집              |    |
| 연결 활성화             |    |
| 시스템 호스트 이름 설정      |    |
| 종료                 |    |
|                    | OK |

* `nmcli`. 명령줄을 사용하여 순수 명령줄 또는 대화형 명령줄 중 하나를 사용하여 네트워크를 구성합니다.

```bash
Shell > nmcli connection show                                                                                                        
NAME    UUID                                  TYPE      DEVICE                                                                              
ens160  25106d13-ba04-37a8-8eb9-64daa05168c9  ethernet  ens160
```

RockyLinux 8.x의 경우 [여기](./nmtui.md)에서 네트워크를 구성하는 방법을 소개했습니다. `vim`을 사용하여 **/etc/sysconfig/network-script/** 디렉토리의 네트워크 카드 구성 파일을 편집하거나 `nmcli`/`nmtui`를 사용할 수 있으며 둘 다 허용됩니다.

## udev 장치 관리자의 이름 지정 규칙

RockyLinux 9.x의 경우 **/etc/sysconfig/network-scripts/** 디렉토리로 이동하면 **/etc/NetworkManager/system-connections/** 디렉토리로 이동하라는 **readme-ifcfg-rh.txt** 설명 텍스트가 있습니다.

```bash
Shell > cd /etc/NetworkManager/system-connections/  && ls 
ens160.nmconnection
```

여기서 `ens160`은 시스템의 네트워크 카드 이름을 나타냅니다. 이름이 왜 그렇게 이상하게 보이는지 궁금하실 수 있습니다. 이것은 `udev` 장치 관리자 때문입니다. 이는 다양한 네이밍 스키마를 지원합니다. 기본적으로 펌웨어, 토폴로지 및 위치 정보에 따라 고정된 이름이 할당됩니다. 이의 장점은 다음과 같습니다.

* 장치 이름은 완전히 예측 가능합니다.
* 하드웨어를 추가하거나 제거해도 장치 이름이 변경되지 않습니다.
* 결함이 있는 하드웨어는 원활하게 교체할 수 있습니다.

RHEL 9 및 해당 커뮤니티 버전 운영 체제에서는 일관된 장치 이름 지정이 기본적으로 활성화됩니다. `udev` 장치 관리자는 다음 체계에 따라 장치 이름을 생성합니다.

| 체계 | 설명                                                                                                                   | 예시              |
| -- | -------------------------------------------------------------------------------------------------------------------- | --------------- |
| 1  | 장치 이름에는 온보드 장치에 대한 펌웨어 또는 BIOS 제공 색인 번호가 통합되어 있습니다. 이 정보를 사용할 수 없거나 적용할 수 없는 경우 `udev`는 체계 2를 사용합니다.                 | eno1            |
| 2  | 장치 이름에는 펌웨어 또는 BIOS 제공 PCI Express(PCIe) 핫 플러그 슬롯 색인 번호가 통합되어 있습니다. 이 정보를 사용할 수 없거나 적용할 수 없는 경우 `udev`는 체계 3을 사용합니다. | ens1            |
| 3  | 장치 이름에는 하드웨어 커넥터의 물리적 위치가 포함됩니다. 이 정보를 사용할 수 없거나 적용할 수 없는 경우 `udev`는 체계 5를 사용합니다.                                    | enp2s0          |
| 4  | 장치 이름에는 MAC 주소가 포함됩니다. Red Hat Enterprise Linux는 기본적으로 이 체계를 사용하지 않지만 관리자는 선택적으로 사용할 수 있습니다.                         | enx525400d5e0fb |
| 5  | 기존의 예측할 수 없는 커널 명명 체계. `udev`가 다른 체계를 적용할 수 없는 경우 장치 관리자는 이 체계를 사용합니다.                                               | eth0            |

`udev` 장치 관리자는 인터페이스 유형에 따라 NIC의 접두사를 지정합니다.

* **en**은 Ethernet - 이더넷.
* **wl**은 wireless LAN (WLAN) - 무선 랜.
* **ww**은 wireless wide area network (WWAN) - 무선 광대역 네트워크.
* **ib**, InfiniBand 네트워크.
* **sl**, Serial Line Internet Protocol (slip) - 직렬 회선 인터넷 프로토콜.

접두사에 일부 접미사를 추가할 수 있습니다:

* **o** on-board_index_number
* **s** hot_plug_slot_index_number **[f]** function **[d]** device_id
* **x** MAC_address
* **[P]** domain number **p** bus **s** slot **[f]** function **[d]** device_id
* **[P]** domain number **p** buss **s** slot **[f]** function **[u]** usb port **[c]** config **[i]** interface

`man 7 systemd.net-naming-scheme`을 사용하여 더 자세한 정보를 얻을 수 있습니다.

## `nmcli` 명령(권장)

사용자는 순수 명령 줄 모드로 네트워크를 구성할 수도 있고 대화식 명령을 사용하여 네트워크를 구성할 수도 있습니다.

### `nmcli connection`

`nmcli connection` 명령은 보기, 삭제, 추가, 수정, 편집, 활성화, 비활성화 등을 할 수 있습니다.

구체적인 사용법은 `nmcli connection add --help`, `nmcli connection edit --help`, `nmcli connection modify --help` 등을 참조하십시오.

예를 들어 순수 명령 줄을 사용하여 새로운 ipv4 정적 IP 연결을 구성하고 자동으로 시작하도록 설정할 수 있습니다:

```bash
Shell > nmcli  connection  add  type  ethernet  con-name   CONNECTION_NAME  ifname  NIC_DEVICE_NAME   \
ipv4.method  manual  ipv4.address "192.168.10.5/24"  ipv4.gateway "192.168.10.1"  ipv4.dns "8.8.8.8,114.114.114.114" \
ipv6.method  disabled  autoconnect yes
```

ipv4 주소를 가져오기 위해 DHCP를 사용하는 경우 다음과 같이 설정할 수 있습니다:

```bash
Shell > nmcli  connection  add  type ethernet con-name CONNECTION_NAME  ifname  NIC_DEVICE_NAME \
ipv4.method  auto  ipv6.method  disabled  autoconnect  yes
```

위의 구성으로는 연결이 활성화되지 않습니다. 다음 작업을 수행해야 합니다:

```bash
Shell > nmcli connection up  NIC_DEVICE_NAME
```

기존 연결을 기반으로 `edit` 키워드를 통해 대화형 인터페이스를 입력하고 수정합니다.

```bash
Shell > nmcli connection  edit  CONNECTION_NAME
nmcli > help
```

`modify` 키워드를 사용하여 명령 줄에서 연결의 하나 이상의 속성을 직접 수정할 수도 있습니다. 예를 들어:

```bash
Shell > nmcli connection modify CONNECTION_NAME autoconnect yes ipv6.method dhcp
```

!!! 정보

    `nmcli` 또는 `nmtui`를 통한 작업은 임시가 아닌 영구적으로 저장됩니다.

#### 링크 집계

일부는 링크 통합을 위해 여러 네트워크 카드를 사용합니다. 초기에는 **bonding** 기술을 사용하여 7개의 작동 모드(0~6)가 있었고 본드 모드는 최대 2개의 네트워크 카드만 지원했습니다. 나중에 **teaming** 기술은 점차 대안으로 사용되며, 5가지 작업 모드가 있으며 팀 모드는 최대 8개의 네트워크 카드를 사용할 수 있습니다. bonding 과 teaming 간의 비교 링크——https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/networking_guide/sec-comparison_of_network_teaming_to_bonding

예를 들어 본딩의 0 모드는 다음과 같습니다:

```bash
Shell > nmcli  connection  add  type  bond  con-name  BOND_CONNECTION_NAME   ifname  BOND_NIC_DEVICE_NAME  mode 0  
Shell > nmcli  connection  add  type  bond-slave   ifname NIC_DEVICE_NAME1   master  BOND_NIC_DEVICE_NAME
Shell > nmcli  connection  add  type  bond-slave   ifname NIC_DEVICE_NAME2   master  BOND_NIC_DEVICE_NAME
```

## 네트워크 카드의 구성 파일(vim 등으로 수정하는 것을 권장하지 않음)

!!! warning "주의"

    `vim`이나 다른 편집자를 사용하여 이를 변경하지 않는 것이 좋습니다.

자세한 내용은 `man 5 NetworkManager.conf` 및 `man 5 nm-settings-nmcli`를 통해 확인하실 수 있습니다.

NetwrokManager 네트워크 카드의 구성 파일 내용은 초기화 스타일 키 파일입니다. 예시:

```bash
Shell > cat /etc/NetworkManager/system-connections/ens160.nmconnection                                                               
[connection]                                                                                                                                
id=ens160                                                                                                                                   
uuid=5903ac99-e03f-46a8-8806-0a7a8424497e                                                                                                   
type=ethernet                                                                                                                               
interface-name=ens160                                                                                                                       
timestamp=1670056998                                                                                                                        

[ethernet]                                                                                                                                  
mac-address=00:0C:29:47:68:D0                                                                                                               

[ipv4]                                                                                                                                      
address1=192.168.100.4/24,192.168.100.1                                                                                                     
dns=8.8.8.8;114.114.114.114;                                                                                                                
method=manual                                                                                                                               

[ipv6]                                                                                                                                      
addr-gen-mode=default                                                                                                                       
method=disabled                                                                                                                             

[proxy] 
```

* #으로 시작하는 줄과 빈 줄은 주석으로 간주됩니다.
* [ 과 ] 안에는 제목을 선언하려는 섹션이 있으며 그 아래에는 포함된 특정 키-값 쌍이 있습니다. 선언된 각 제목과 해당 키-값 쌍은 구문 세그먼트를 형성합니다.
* .nmconnection 접미사가 있는 모든 파일은 **NetworkManager**에서 사용할 수 있습니다.

**ipv4** 제목 이름에는 다음과 같은 공통 키-값 쌍이 포함될 수 있습니다.

| 키 이름           | 설명                                                                                         |
| -------------- | ------------------------------------------------------------------------------------------ |
| id             | con-name의 별칭이며, 이 이름의 값은 문자열입니다.                                                           |
| uuid           | 값이 문자열인 범용 고유 식별자입니다.                                                                      |
| type           | 이더넷, Bluetooth, vpn, vlan 등의 값을 사용할 수 있는 연결 유형입니다. `man nmcli`를 사용하여 지원되는 모든 유형을 볼 수 있습니다. |
| interface-name | 이 연결이 바인딩된 네트워크 인터페이스의 이름으로, 이 이름의 값은 문자열입니다.                                              |
| timestamp      | Unix 타임스탬프(초)입니다. 여기서 값은 1970년 1월 1일 이후의 초 수입니다.                                           |
| autoconnect    | 시스템 시작 시 자동으로 시작되는지 여부입니다. 값은 부울 유형입니다.                                                    |

**connection** 제목 이름에는 다음과 같은 공통 키-값 쌍이 포함될 수 있습니다.

| 키 이름           | 설명                                                                                                                                                                                                                                                   |
| -------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| mac-address    | MAC 물리적 주소.                                                                                                                                                                                                                                          |
| mtu            | Maximum Transmission Unit - 최대 전송 단위.                                                                                                                                                                                                                |
| auto-negotiate | 자동 협상 여부입니다. 값은 부울 유형입니다.                                                                                                                                                                                                                            |
| duplex         | 값은 반이중(half-duplex), 전이중(full-duplex)일 수 있습니다.                                                                                                                                                                                                       |
| speed          | 네트워크 카드의 전송 속도를 지정합니다. 100은 100Mbit/s입니다. **auto-negotiate=false**인 경우 **speed** 키 및 **duplex ** 키를 설정해야 합니다. **auto-negotiate=true**인 경우 사용되는 속도는 협상된 속도이며 여기에 쓰는 것은 적용되지 않습니다(이는 BASE-T 802.3 사양에만 적용 가능함); 0이 아닌 경우 **duplex** 키에 값이 있어야 합니다. |

**ethernet** 제목 이름에는 다음과 같은 공통 키-값 쌍이 포함될 수 있습니다.

| 키 이름      | 설명                                                                                |
| --------- | --------------------------------------------------------------------------------- |
| addresses | 할당된 IP 주소 assigned                                                                |
| gateway   | 인터페이스의 게이트웨이(다음 홉)                                                                |
| dns       | 사용 중인 도메인 이름 서버use                                                                |
| method    | IP로 획득하는 방법. 값은 문자열 유형입니다. 값은 auto, disabled, link-local, manual, shared일 수 있습니다. |
