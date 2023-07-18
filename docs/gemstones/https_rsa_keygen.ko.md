---
title: https - RSA 키 생성
author: Steven Spencer
update: 26-Jan-2022
---

# https - RSA 키 생성

이 스크립트는 저에 의해 여러 번 사용되었습니다. openssl 명령 구조를 얼마나 자주 사용하더라도, 때로는 절차를 다시 참조해야 할 때가 있습니다. 이 스크립트를 사용하면 RSA를 사용하여 웹 사이트의 키 생성을 자동화할 수 있습니다. 이 스크립트는 2048비트 키 길이로 하드코딩되어 있습니다. 키 길이를 최소 4096비트로 설정해야 한다고 느끼는 경우에는 스크립트의 해당 부분을 변경하면 됩니다. 그러나 장기적인 키 길이의 보안성과 장치에서 웹 사이트를로드하는 데 필요한 메모리와 속도를 고려해야 함을 알아두세요.

## 스크립트

이 스크립트의 이름은 `keygen.sh`와 같이 마음에 드는 대로 지정하고, 스크립트를 실행 가능한 상태로 만들고 (`chmod +x scriptname`), 예를 들어 /usr/local/sbin과 같이 경로에 있는 디렉터리에 배치합니다.

```
#!/bin/bash
if [ $1 ]
then
      echo "generating 2048 bit key - you'll need to enter a pass phrase and verify it"
      openssl genrsa -des3 -out $1.key.pass 2048
      echo "now we will create a pass-phrase less key for actual use, but you will need to enter your pass phrase a third time"
      openssl rsa -in $1.key.pass -out $1.key
      echo "next, we will generate the csr"
      openssl req -new -key $1.key -out $1.csr
      #cleanup
      rm -f $1.key.pass
else
      echo "requires keyname parameter"
      exit
fi
```

!!! 참고 사항

    암호를 연속으로 세 번 입력해야 합니다.

## 간단한 설명

* 이 bash 스크립트는 입력해야 할 매개변수($1)인 사이트 이름(www 등 없는 이름)을 필요로 합니다. 예를 들어, "mywidget"입니다.
* 스크립트는 기본 키를 암호와 2048비트 길이로 생성합니다 (위에서 설명한대로 이를 편집하여 더 긴 4096비트 길이로 변경할 수 있음).
* 비밀번호는 키에서 즉시 제거됩니다. 이유는 웹 서버 재시작 시마다 키 비밀번호를 입력해야 하며, 재부팅 시에도 입력해야 하는데, 실제로는 문제가 될 수 있기 때문입니다.
* 그 다음 스크립트는 CSR(Certificate Signing Request)을 생성합니다. 이 CSR은 공급업체에서 SSL 인증서를 구매하는 데 사용할 수 있습니다.
* 마지막으로 정리 단계에서 이전에 생성된 비밀번호가 있는 키가 제거됩니다.
* 매개변수 없이 스크립트 이름을 입력하면 "keyname 매개변수가 필요합니다"라는 오류가 발생합니다.
* 여기서는 위치 매개변수 변수 $n을 사용합니다. $0은 명령 자체를 나타내며, $1부터 $9까지는 첫 번째부터 아홉 번째 매개변수를 나타냅니다. 숫자가 10보다 큰 경우, 중괄호를 사용해야 합니다. 예를 들어 ${10}과 같이 사용합니다.
