---
title: '# SSL 키 생성'
author: Steven Spencer
contributors: Ezequiel Bruni
tested_with: 8.5
tags:
  - security
  - ssl
  - openssl
---
  
# # SSL 키 생성

## 전제 조건

* Rocky Linux를 실행하는 워크스테이션과 서버
* _OpenSSL_은 개인 키와 CSR을 생성할 시스템과 최종적으로 키와 인증서를 설치할 서버에 설치됩니다.
* 명령줄에서 편안하게 명령을 실행할 수 있습니다.
* 유용한 정보: SSL 및 OpenSSL 명령에 대한 지식


## 소개

거의 모든 웹 사이트는 오늘날 SSL(보안 소켓 레이어) 인증서를 실행해야 합니다. 이 절차에서는 웹 사이트의 개인 키를 생성하고 이를 사용하여 새 인증서를 구매하기 위해 사용할 CSR(인증서 서명 요청)을 생성하는 방법을 안내합니다.

## 개인 키 생성

초보자를 위해 SSL 비공개 키는 크랙하기 어려운 다른 크기(비트 단위)를 가질 수 있으며, 이는 기본적으로 크랙하기 어려운 정도를 결정합니다.

2021년 기준으로 웹 사이트의 권장 비공개 키 크기는 여전히 2048 비트입니다. 더 높은 크기로 갈 수 있지만, 2048 비트에서 4096 비트로 키 크기를 두 배로 늘리는 것은 보안이 약 16% 더 강력해지는 것뿐입니다. 키를 저장하는 데 더 많은 공간이 필요하며, 키를 처리할 때 더 높은 CPU 부하를 발생시킵니다.

이는 중요한 보안성을 얻지 못한 채 웹 사이트 성능을 저하시키므로 현재 권장 사항을 항상 확인하세요. 지금은 2048 키 크기를 고수하고 항상 현재 권장되는 키 크기를 확인하십시오.

먼저 OpenSSL이 워크스테이션과 서버 모두에 설치되어 있는지 확인해봅시다:

`dnf install openssl`

설치되지 않은 경우 시스템에서 자동으로 설치하고 필요한 종속성을 설치합니다.

우리의 예시 도메인은 example.com입니다. 도메인을 사전에 구매하고 등록해야 함을 염두에 두세요. 도메인은 여러 "등록기"를 통해 구입할 수 있습니다.

자체 DNS(Domain Name System)를 실행하고 있지 않은 경우 동일한 공급업체를 DNS 호스팅에도 사용할 수 있습니다. DNS는 지정된 도메인을 인터넷이 이해하는 숫자(IP 주소, IPv4 또는 IPv6)로 변환합니다. 이러한 IP 주소는 웹 사이트가 실제로 호스팅되는 위치입니다.

다음으로, OpenSSL을 사용하여 키를 생성해 봅시다:

`openssl genrsa -des3 -out example.com.key.pass 2048`

키 이름에 .pass 확장자를 사용했습니다. 그 이유는 이 명령을 실행하자마자 암호를 입력하라는 요청이 나타나기 때문입니다. 곧바로 제거하게 될 간단한 암호를 입력하세요:

```
Enter pass phrase for example.com.key.pass:
Verifying - Enter pass phrase for example.com.key.pass:
```

다음으로, 그 암호를 제거해 봅시다. 이것은 키를 로드하고 있기 때문에 웹 서버가 재시작하고 키를 로드할 때마다 그 암호를 입력해야 하는 것을 피하기 위해서입니다.

혹시나 암호를 입력할 여유가 없거나, 더 나쁜 경우, 그 암호를 입력할 준비가 되어 있지 않을 수도 있습니다. 이를 모두 피하려면 지금 제거하세요:

`openssl rsa -in example.com.key.pass -out example.com.key`

이렇게 하면 키에서 암호를 제거하기 위해 한 번 더 암호를 입력하라는 요청이 표시됩니다.

`Enter pass phrase for example.com.key.pass:`

이제 세 번째로 암호를 입력하면 키 파일에서 암호가 제거되고 example.com.key로 저장됩니다.

## CSR 생성

다음으로, 인증서 서명 요청(CSR, certificate signing request)을 생성해야 합니다.

CSR을 생성하는 동안 몇 가지 정보를 입력하라는 메시지가 표시됩니다. 이 정보들은 인증서의 X.509 속성입니다.

프롬프트 중 하나는 "Common Name (e.g., YOUR name)"을 위한 것입니다. 이 필드에는 SSL로 보호할 서버의 완전히 정규화된 도메인 이름이 입력되어야 합니다. 보호할 웹 사이트가 https://www.example.com이라면 이 프롬프트에 www.example.com을 입력해야 합니다:

`openssl req -new -key example.com.key -out example.com.csr`

그러면 대화 상자가 열립니다.

`Country Name (2 letter code) [XX]:` 여기에 사이트가 있는 국가의 두 글자 국가 코드를 입력하세요. 예: "US"

`State or Province Name (full name) []:` 여기에 주 또는 주의 전체 공식 이름을 입력하세요. 예: "Nebraska"

`Locality Name (eg, city) [Default City]:` 여기에 도시의 전체 이름을 입력하세요. 예: "Omaha"

`Organization Name (eg, company) [Default Company Ltd]:` 원한다면, 이 도메인이 속한 조직을 입력하거나 건너뛰려면 'Enter'를 누르세요.

`Organizational Unit Name (eg, section) []:` 도메인이 속하는 조직의 부서를 설명합니다. 다시 말하지만 'Enter' 키만 누르면 건너뛸 수 있습니다.

`Common Name (eg, your name or your server's hostname) []:`여기에 사이트 호스트 이름인 www.example.com을 입력해야 합니다.

`Email Address []:` 이 필드는 선택 사항입니다. 작성할지 결정하거나 'Enter'를 누르면 건너뛸 수 있습니다.

다음으로, 추가 속성을 입력하라는 요청이 표시됩니다. 이는 두 개의 'Enter'를 누르면 건너뛸 수 있습니다:

```
Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:
An optional company name []:
```

이제 CSR을 생성해야 합니다.

## 인증서 구매

각 인증서 판매업체는 기본적으로 동일한 절차를 따릅니다. SSL 및 기간(1년 또는 2년 등)을 구매한 다음 CSR을 제출합니다. 이를 위해 `more` 명령을 사용하여 CSR 파일의 내용을 복사해야 합니다.

`more example.com.csr`

그러면 다음과 같은 내용이 표시됩니다.

```
-----BEGIN CERTIFICATE REQUEST-----
MIICrTCCAZUCAQAwaDELMAkGA1UEBhMCVVMxETAPBgNVBAgMCE5lYnJhc2thMQ4w
DAYDVQQHDAVPbWFoYTEcMBoGA1UECgwTRGVmYXVsdCBDb21wYW55IEx0ZDEYMBYG
A1UEAwwPd3d3Lm91cndpa2kuY29tMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIB
CgKCAQEAzwN02erkv9JDhpR8NsJ9eNSm/bLW/jNsZxlxOS3BSOOfQDdUkX0rAt4G
nFyBAHRAyxyRvxag13O1rVdKtxUv96E+v76KaEBtXTIZOEZgV1visZoih6U44xGr
wcrNnotMB5F/T92zYsK2+GG8F1p9zA8UxO5VrKRL7RL3DtcUwJ8GSbuudAnBhueT
nLlPk2LB6g6jCaYbSF7RcK9OL304varo6Uk0zSFprrg/Cze8lxNAxbFzfhOBIsTo
PafcA1E8f6y522L9Vaen21XsHyUuZBpooopNqXsG62dcpLy7sOXeBnta4LbHsTLb
hOmLrK8RummygUB8NKErpXz3RCEn6wIDAQABoAAwDQYJKoZIhvcNAQELBQADggEB
ABMLz/omVg8BbbKYNZRevsSZ80leyV8TXpmP+KaSAWhMcGm/bzx8aVAyqOMLR+rC
V7B68BqOdBtkj9g3u8IerKNRwv00pu2O/LOsOznphFrRQUaarQwAvKQKaNEG/UPL
gArmKdlDilXBcUFaC2WxBWgxXI6tsE40v4y1zJNZSWsCbjZj4Xj41SB7FemB4SAR
RhuaGAOwZnzJBjX60OVzDCZHsfokNobHiAZhRWldVNct0jfFmoRXb4EvWVcbLHnS
E5feDUgu+YQ6ThliTrj2VJRLOAv0Qsum5Yl1uF+FZF9x6/nU/SurUhoSYHQ6Co93
HFOltYOnfvz6tOEP39T/wMo=
-----END CERTIFICATE REQUEST-----
```

"BEGIN CERTIFICATE REQUEST"와 "END CERTIFICATE REQUEST" 줄을 포함하여 모두 복사하면 됩니다. 그런 다음 이를 구매할 인증서를 입력하는 웹 사이트의 CSR 필드에 붙여넣습니다.

인증서 발급 전 소유권 확인 및 사용 중인 등록기에 따라 추가 검증 단계를 수행해야 할 수도 있습니다. 인증서가 발급되면 제공업체로부터 중간 인증서와 함께 발급되며, 이를 구성에도 사용해야 합니다.

## 결론

웹 사이트 인증서 구매를 위한 모든 구성 요소를 생성하는 것은 그다지 어렵지 않으며, 위의 절차를 따라 시스템 관리자 또는 웹 사이트 관리자가 수행할 수 있습니다.
