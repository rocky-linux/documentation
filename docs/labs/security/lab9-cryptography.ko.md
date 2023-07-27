
# Lab 9: 암호화

## 목표

이 실습을 완료한 후에는 다음을 수행할 수 있습니다.

- 데이터와 통신을 보호하기 위해 암호화 개념을 적용합니다.

실습 완료에 소요되는 예상 시간: 120분



## 공통 암호화 용어 및 정의

### Cryptography (암호화)

일반적인 일상적인 사용에서 암호화는 비밀 문자로 쓰는 행위 또는 기술입니다. 기술 용어로는 수학을 사용하여 데이터를 암호화하고 복호화하는 과학으로 정의될 수 있습니다.

### Cryptanalysis (암호해독)

암호해독은 암호화 메커니즘을 해롭게 만드는 방법에 대한 연구입니다. 이는 코드를 해독, 암호 해독, 및 인증 체계를 위반하며 일반적으로 암호화 프로토콜을 깨는 것과 관련된 과학입니다.

### Cryptology (암호학)

암호학과 암호해독을 결합한 학문을 암호학이라고 합니다. 암호학은 암호화 방법의 수학적 기초를 연구하는 수학의 한 분야입니다.

### Encryption (암호화)

암호화는 적절한 지식(예: 키) 없이는 읽기 거의 불가능한 형식으로 데이터를 변환하는 것입니다. 그 목적은 정보를 의도되지 않은 사람들로부터 숨겨 개인 정보를 보호하는 것입니다.

### Decryption (복호화)

복호화는 암호화의 반대로, 암호화된 데이터를 이해 가능한 형태로 변환하는 것입니다.

### Cipher (암호)

암호화 및 복호화 방법을 의미합니다.

해시 함수 (Digest 알고리즘)

암호 해시 함수는 디지털 서명을 만들 때 메시지 다이제스트를 계산하는 데 사용됩니다. 해시 함수는 메시지의 비트를 가능한 해시 값들 중에서 균등하게 분포시키는 방식으로 고정 크기의 해시 값으로 압축합니다. 암호 해시 함수는 특정 해시 값에 대한 메시지를 찾는 것이 극도로 어렵도록 이 작업을 수행합니다. 가장 잘 알려진 해시 함수 중 일부는 다음과 같습니다.

**a)** - **SHA-1 (Secure Hash Algorithm)** -미국 정부에서 발표한 암호 해시 알고리즘입니다. 임의 길이 문자열로부터 160 비트 해시 값을 생성합니다. 매우 좋은 알고리즘이라고 여겨집니다.

**b)**- **MD5 (Message Digest Algorithm 5)** -  RSA 연구소에서 개발된 암호 해시 알고리즘입니다. 임의 길이 바이트 문자열을 128 비트 값으로 해시화하는 데 사용될 수 있습니다.

### 알고리즘

알고리즘은 문제 해결 절차를 단계별로 설명하는 것으로, 한정된 단계 수를 통해 문제를 해결하기 위한 기술적으로 수립된 반복 계산 절차입니다. 기술적으로 알고리즘은 한정된 단계 수를 거쳐 결과에 도달해야 합니다. 알고리즘의 효율성은 문제 해결을 위해 필요한 기본 단계 수로 측정할 수 있습니다. 두 가지 종류의 키 기반 알고리즘이 있습니다. 이들은 다음과 같습니다.

**a) **-- **대칭 암호화 알고리즘 (비밀 키)**

대칭 알고리즘은 암호화와 복호화에 동일한 키를 사용합니다(또는 복호화 키가 암호화 키에서 쉽게 유도됩니다). 비밀 키 알고리즘은 암호화와 복호화에 동일한 키를 사용합니다(또는 하나가 다른 키에서 쉽게 유도될 수 있습니다). 이는 데이터 암호화에 더 직관적인 접근 방식으로, 공개 키 암호화보다 수학적으로 복잡하지 않습니다. 대칭 알고리즘은 스트림 암호와 블록 암호로 나눌 수 있습니다. 스트림 암호는 한 번에 하나의 비트만 암호화할 수 있으며, 블록 암호는 여러 비트(현대 암호에서 일반적으로 64 비트)를 하나의 단위로 암호화합니다. 대칭 알고리즘은 비대칭 알고리즘에 비해 컴퓨터에서 실행 속도가 훨씬 빠릅니다.

대칭 알고리즘의 예로는 AES, 3DES, Blowfish, CAST5, IDEA 및 Twofish가 있습니다.

**b) --비대칭 알고리즘 (공개 키 알고리즘)**

반면에 비대칭 알고리즘은 암호화와 복호화에 서로 다른 키를 사용하며, 복호화 키는 암호화 키에서 유도할 수 없습니다. 비대칭 암호는 암호화 키를 공개할 수 있어 누구나 키로 암호화할 수 있지만, (복호화 키를 아는) 올바른 수신자만 메시지를 복호화할 수 있습니다. 암호화 키는 공개 키로도 불리며, 복호화 키는 개인 키 또는 비밀 키로도 불립니다.

RSA는 아마도 가장 잘 알려진 비대칭 암호화 알고리즘입니다.

### 디지털 서명

디지털 서명은 문서를 특정 키의 소유자에게 연결합니다. 디지털 서명은 메시지가 실제로 주장한 송신자로부터 온 것임을 확인하는 데 사용됩니다.

문서의 디지털 서명은 문서와 서명자의 개인 키를 기반으로 한 정보입니다. 일반적으로 해시 함수와 개인 서명 함수(서명자의 개인 키로 암호화)를 사용하여 생성됩니다. 디지털 서명은 암호화된 작은 데이터로, 일부 비밀 키를 사용하여 생성되었으며, 해당 비밀 키를 사용하여 서명이 실제로 해당 비밀 키를 사용하여 생성되었는지를 확인할 수 있는 공개 키가 있습니다.

디지털 서명을 생성하고 확인하는 여러 가지 방법이 자유롭게 제공되지만 가장 널리 알려진 알고리즘은 RSA 공개 키 알고리즘입니다.

### 암호 프로토콜

암호화는 여러 수준에서 작동합니다. 하나의 수준에서는 블록 암호와 공개 키 암호 시스템과 같은 알고리즘이 있습니다. 이를 기반으로 프로토콜을 얻고, 프로토콜을 기반으로 응용 프로그램(또는 다른 프로토콜)을 찾을 수 있습니다. 아래는 암호 프로토콜을 사용하는 일반적인 일상적인 응용 프로그램의 목록입니다. 이러한 프로토콜은 하위 수준의 암호 알고리즘 위에 구축됩니다.

i.) 도메인 이름 서버 보안 (DNSSEC - Domain Name Server Security)

이것은 안전한 분산 이름 서비스를 위한 프로토콜입니다. 현재 인터넷 드래프트로 제공됩니다.

ii.) 보안 소켓 레이어 (SSL - Secure Socket Layer)

SSL은 안전한 웹 연결을 위해 사용되는 두 가지 프로토콜 중 하나입니다(다른 하나는 SHTTP입니다). 웹 보안은 신용 카드 번호와 같은 민감한 정보가 인터넷을 통해 전송되는 양이 증가함에 따라 중요해지고 있습니다.

iii.) 보안 하이퍼텍스트 전송 프로토콜 (SHTTP - Secure Hypertext Transfer Protocol)

이것은 웹 거래에 대한 더 많은 보안을 제공하기 위한 또 다른 프로토콜입니다.

iv) 전자 메일 보안 및 관련 서비스

**GnuPG** - GNU Privacy Guard는 RFC2440에서 설명된 제안된 OpenPGP 인터넷 표준과 호환됩니다.

v) SSH2 프로토콜

이 프로토콜은 인터넷의 요구에 유연하며 현재 SSH2 소프트웨어에서 사용됩니다. 이 프로토콜은 터미널 세션과 TCP 연결을 보호하는 데 사용됩니다.

다음 연습에서는 암호화 프로토콜을 사용하는 두 가지 특정 응용 프로그램인 GnuPG 및 OpenSSH를 검사합니다.

## 연습문제 1

### GnuPG

GnuPG (GNU Privacy Guard)은 공개 키 암호화와 디지털 서명을 위한 프로그램 세트입니다. 이 도구들은 데이터를 암호화하고 디지털 서명을 생성하는 데 사용할 수 있습니다. 또한 고급 키 관리 기능도 포함되어 있습니다. GnuPG는 공개 키 암호화를 사용하여 사용자가 안전하게 통신할 수 있도록 합니다.

다음 연습은 일반 사용자로서 수행합니다. 예를 들어 사용자 "ying"으로 로그인합니다.

새로운 키 쌍을 생성하려면 다음을 수행합니다.

1. "ying" 사용자로 시스템에 로그인합니다.

2. 시스템에 GnuPG 패키지가 설치되어 있는지 확인합니다. 다음 명령을 입력합니다:

`[ying@serverXY ying]$ rpm -q gnupg`

gnupg-\*.\*

만약 설치되어 있지 않다면, 관리자에게 설치해 달라고 요청하세요.

3. 홈 디렉토리에서 모든 숨겨진 디렉토리를 나열하고 기록합니다.

4. 이제 키링에 있는 키 목록을 확인합니다. 다음 명령어를 입력하세요:

`[ying@serverXY ying]$ gpg --list-keys`

!!! 참고:

    아직 키링에 키가 없어야 합니다. 하지만 위의 명령은 처음에 성공적으로 새로운 키 쌍을 생성할 수 있는 기본 환경을 만들어 줄 것입니다.

홈 디렉토리의 숨겨진 디렉토리를 다시 나열합니다. 새로 추가된 디렉토리의 이름은 무엇인가요?

5. gpg 프로그램을 사용하여 새로운 키 쌍을 생성합니다. 다음과 같이 입력합니다:

```
[ying@serverXY ying\]$ gpg --gen-key

......................................

gpg: keyring \`/home/ying/.gnupg/secring.gpg' created

gpg: keyring \`/home/ying/.gnupg/pubring.gpg' created

Please select what kind of key you want:

 (1) DSA and ElGamal (default)

 (2) DSA (sign only)

 (5) RSA (sign only)

Your selection? 1
```

 생성할 키 유형에 대한 프롬프트에서 기본값을 사용합니다.(DSA 및 ElGamal). 1을 입력하세요.

!!! 주의사항 및 경고

    옵션 (1)은 두 개의 키 쌍을 생성합니다. DSA 키 쌍은 주 키 쌍으로 사용되며, 디지털 서명을 위한 것입니다. 그리고 부속 ELGamel 키 쌍은 데이터 암호화를 위한 것입니다.

6. 1024 비트의 ELG-E 키 쌍을 생성합니다. 아래 프롬프트에서 기본값을 그대로 사용합니다:

DSA 키 쌍에는 1024비트가 있습니다.

새 ELG-E 키 쌍을 생성하려고 합니다.

 최소 키 크기는 768비트입니다.

 기본 키 크기는 1024비트입니다.

 가장 높은 권장 키 크기는 2048비트입니다.

어떤 키 크기를 원하십니까? (1024) 1024

7. 키의 유효 기간을 1년으로 설정합니다. 아래 프롬프트에서 "1y"를 입력합니다:

키의 유효 기간을 지정하십시오.

 0 = 키가 만료되지 않음

<n> = 키가 n일 후에 만료됨

<n>w = 키가 n주 후에 만료됨

<n>m = 키가 n개월 후에 만료됨

<n>y = 키가 n년 후에 만료됨

키가 유효합니까? (0) 1y

8. 프롬프트에 표시된 만료 날짜를 수락하려면 "y"를 입력합니다:

정확합니까 (y/n)? y

9. 키를 식별하는 데 사용할 사용자 ID를 생성합니다:

키를 식별하려면 사용자 ID가 필요합니다. 소프트웨어가 사용자 ID를 생성합니다.

실명, 의견 및 이메일 주소에서 이 형식으로:

"Firstname Lastname (any comment) &lt;yourname@serverXY&gt;"

Real name: Ying Yang\[ENTER\]

Comment : my test\[ENTER\]

Email address: ying@serverXY \[ENTER\]

확인 프롬프트에서 "o"(확인)를 입력하여 올바른 값을 수락합니다.

이 USER-ID를 선택하셨습니다.

"Ying Yang (my test) &lt;ying@serverXY&gt;"

Change (N)ame, (C)omment, (E)mail or (O)kay/(Q)uit? O

10. 다음 프롬프트에서 잊지 않을 암호를 선택합니다:

Enter passphrase: \*\*\*\*\*\*\*\*

Repeat passphrase: \*\*\*\*\*\*\*\*

## 연습문제 2

### 키 관리

gpg 프로그램은 키 관리에도 사용됩니다.

키 목록 나열

1. Ying 사용자로 시스템에 로그인한 상태입니다. 키링에 키를 표시합니다. 다음 명령어를 입력하세요:

[ying@serverXY ying\]$  gpg --list-keys

gpg: WARNING: using insecure memory!

/home/ying/.gnupg/pubring.gpg

-----------------------------

pub 1024D/1D12E484 2003-10-16 Ying Yang (my test) &lt;ying@serverXY&gt;

sub 1024g/1EDB00AC 2003-10-16 \[expires: 2004-10-15\]

2. "insecure memory - 안전하지 않은 메모리"에 대한 다소 성가신 "“warning”"를 억제하려면 다음 옵션을 추가하십시오.

 개인 gpg 구성 파일에. 다음 명령어를 입력하세요:

[ying@serverXY ying\]$ echo "no-secmem-warning" &gt;&gt; ~/.gnupg/gpg.conf

3. 명령을 실행하여 키를 다시 나열하십시오. 변경 사항이 적용되는지 확인하십시오.

4. 서명과 함께 키를 나열합니다. 다음을 입력하세요:

[ying@serverXY ying\]$ gpg --list-sigs

/home/ying/.gnupg/pubring.gpg


5. 비밀 키만 나열하십시오. 다음을 입력하세요:

[ying@serverXY ying\]$ gpg --list-secret-keys

/home/ying/.gnupg/secring.gpg

-----------------------------

sec 1024D/1D12E484 2003-10-16 Ying Yang (my test) &lt;ying@serverXY&gt;

ssb 1024g/1EDB00AC 2003-10-16

6. 키 지문(fingerprint)을 표시합니다. 다음을 입력하세요:

\[ying@serverXY ying\]$ ***gpg --fingerprint***

/home/ying/.gnupg/pubring.gpg

-----------------------------

pub 1024D/1D12E484 2003-10-16 Ying Yang (my test) &lt;ying@serverXY&gt;

 Key fingerprint = D61E 1538 EA12 9049 4ED3 5590 3BC4 A3C1 1D12 E484

sub 1024g/1EDB00AC 2003-10-16 \[expires: 2004-10-15\]

<span id="anchor-2"></span>해지 인증서

해지 인증서는 누군가가 귀하의 비밀 키를 알게 되거나 암호를 잊어버린 경우 키를 해지하는 데 사용됩니다. 그들은 또한 다른 다양한 기능에 유용합니다.

인증서 폐기 생성하기

1. 여전히 사용자 ying으로 로그인된 상태에서 폐기 인증서를 생성합니다. 폐기 인증서는 표준 출력에

 표시됩니다. 다음 명령어를 입력하세요:

[ying@serverXY ying\]$*** gpg --gen-revoke ying@serverXY***

안내에 따라 계속 진행하고, 암호를 입력하라는 메시지가 표시되면 암호를 입력하세요.

2. 이제 폐기 인증서를 "revoke.asc"라는 이름의 ASCII 형식의 파일로 저장합니다.

 “revoke.asc”. 다음과 같이 입력합니다:

[ying@serverXY ying\]$*** gpg --output revoke.asc --gen-revoke ying@serverXY***

3. 폐기 인증서를 안전한 장소에 보관하고 하드 복사본을 만드는 것이 좋습니다.

공개 키 내보내기

암호화, 서명 및 복호화와 관련된 모든 작업의 목적은 사람들이 가능한 안전한 방식으로 서로 통신하기를 원하기 때문입니다.

그렇기 때문에 아마도 너무 명백해서 말하지 않아도 될 것이지만, 다음을 명시해야 합니다:

공개 키 기반 암호 시스템을 사용하여 다른 사람과 통신하려면 공개 키를 교환해야 합니다.

또는 최소한 공개적으로 액세스할 수 있는 장소에서 공개 키를 사용할 수 있도록 하십시오(게시판, 웹 페이지, 키 서버, 라디오, T.V, 전자 메일을 통한 스팸 등 ... )

공개 키 내보내기

1. 이진 형식으로 공개 키를 "ying-pub.gpg"라는 파일로 내보냅니다. 다음 명령어를 입력하세요:

[ying@serverXY ying\]$ ***gpg --output ying-pub.gpg --export &lt;your\_key’s\_user\_ID&gt;***

!!! 참고:

    &lt;your\_key’s\_user\_ID&gt;를 자신의 키를 올바르게 식별하는 문자열로 대체하세요. 이 예제 시스템에서는 다음 중 하나일 수 있습니다.
    
    ying@serverXY, ying, yang
    
    OR
    
    The actual key ID - 1D12E484

2. 공개 키를 "ying-pub.asc"라는 파일로 내보냅니다. 이번에는 ASCII-armored

 형식으로 생성합니다. 다음 명령어를 입력하세요:

[ying@serverXY ying\]$***gpg --output ying-pub.asc --armor --export ying@serverXY ***

3. cat 명령어를 사용하여 ying의 공개 키의 이진 버전(ying-pub.gpg)을 확인합니다.

4.   (터미널을 재설정하려면 "reset"을 입력하세요)

5. cat 명령어를 사용하여 ying의 공개 키의 ASCII 버전(ying-pub.asc)을 확인합니다.

6. ASCII 버전이 웹 페이지에 게시하거나 스팸 등에 더 적합한 것을 알 수 있습니다.

## 연습문제 3

### 디지털 서명

서명 생성 및 검증은 암호화 및 복호화와는 다른 공개/개인 키 쌍을 사용하는 작업입니다. 서명은 서명자의 개인 키를 사용하여 생성됩니다. 서명은 해당하는 공개 키를 사용하여 검증할 수 있습니다.

파일에 디지털 서명 생성하기

1. "Hello All"이라는 텍스트가 포함된 "secret-file.txt"라는 파일을 생성합니다. 다음 명령어를 입력하세요:

\[ying@serverXY ying\]$ ***echo "Hello All" &gt; secret1.txt***

2. cat 명령어를 사용하여 파일의 내용을 확인합니다. file 명령어를 사용하여 파일의 종류를 확인합니다.

3. 이제 디지털 서명으로 파일에 서명합니다. 다음 명령어를 입력하세요:

\[ying@serverXY ying\]$ ***gpg -s secret1.txt***

암호구를 입력하라는 메시지가 표시되면 암호구를 입력하세요.

위 명령어는 압축되고 서명이 첨부된 "secret1.txt.gpg"라는 파일을 생성합니다. 해당 파일에 대해 "file" 명령어를 실행하여 확인합니다. cat을 사용하여 파일을 확인합니다. 

4. 서명이 된 "secret1.txt.gpg" 파일의 서명을 확인합니다. 다음 명령어를 입력하세요:

\[ying@serverXY ying\]$ ***gpg --verify secret1.txt.gpg***

gpg: Signature made Thu 16 Oct 2003 07:29:37 AM PDT using DSA key ID 1D12E484

gpg: Good signature from "Ying Yang (my test) &lt;ying@serverXY&gt;"

5. "Hello All"이라는 텍스트가 포함된 새로운 파일 secret2.txt를 생성합니다.

6. secret2.txt 파일에 서명을 추가하지만 이번에는 ASCII-armored 형식으로 파일을 생성합니다. 다음 명령어를 입력하세요:

\[ying@serverXY ying\]$ ***gpg -sa secret2.txt***

ASCII-armored 형식의 파일인 "secret2.txt.asc"가 현재 디렉터리에 생성됩니다.

7. cat 명령어를 사용하여 위에서 생성된 ASCII-armored 파일의 내용을 확인합니다.

8. "hello dude"라는 텍스트가 포함된 "secret3.txt"라는 파일을 생성합니다. 다음 명령어를 입력하세요:

\[ying@serverXY ying\]$*** echo "hello dude" &gt; secret3.txt***

9. 생성한 파일의 서명을 파일의 내용에 추가합니다. 다음 명령어를 입력하세요:

\[ying@serverXY ying\]$ ***gpg --clearsign secret3.txt***

이 명령은 ASCII-armored 서명으로 래핑된 압축되지 않은 파일(secret3.txt.asc)을 생성합니다.

생성된 파일의 서명을 검증하는 명령어를 메모하세요.

10. 원하는 페이저로 파일을 열어 내용을 확인하세요. 파일에 입력한 텍스트를 읽을 수 있나요?

아래의 "연습 4"를 계속하기 전에 파트너가 위의

"연습 -1, 2, 3" 전체를 수행했는지 확인하십시오.

파트너가 없는 경우. 사용자 YING의 계정을 로그오프하고 사용자 "me"로 시스템에 로그인합니다.

그런 다음 사용자 "me"로 "연습-1,2,3" 전체를 반복합니다.

이후에 "연습문제 4"를 수행할 수 있습니다. "serverPR"에서의 사용자 ying에 대한 모든 참조를 localhost의 사용자 "me"로 바꾸세요.

다음 연습문제에서 파트너로서 "me@serverXY" 또는

"ying@serverPR" 사용자를 선택할 수 있습니다.

## 연습문제 4

이 연습문제에서는 "신뢰의 웹"이라고 불리는 "Web of Trust"를 사용하여 다른 사용자와의 실제 통신을 시작합니다.

공개 키 가져오기

1. 사용자 ying으로 시스템에 로그인하세요.

2. ASCII-armored 형식의 공개 키 파일(ying-pub.asc)을 파트너(또는 me@serverXY 또는 ying@serverPR)에게 제공하세요.

참고:

이 작업을 수행하는 다양한 방법이 있습니다. 예를 들어, 이메일, 복사하여 붙여넣기, scp, ftp, 디스켓에 저장 등이 있습니다.

가장 효율적인 방법을 선택하세요.

3. 파트너에게 자신의 공개 키 파일을 제공해도록 요청하세요.

4. 상대방의 공개 키가 현재 디렉터리에 "me-pub.asc"라는 이름의 파일에 저장되어 있다고 가정합니다.

 해당 키를 키링에 가져오세요. 다음 명령어를 입력하세요:

\[ying@serverXY ying\]$ ***gpg --import me-pub.asc***

gpg: key 1D0D7654: public key "Me Mao (my test) &lt;me@serverXY&gt;" imported

gpg: Total number processed: 1

gpg: imported: 1

5. 현재 키링(key-ring)에 있는 키를 나열하고 기록합니다. 다음 명령어를 입력하세요:

\[ying@serverXY ying\]$*** gpg --list-keys***

/home/ying/.gnupg/pubring.gpg

-----------------------------

pub 1024D/1D12E484 2003-10-16 Ying Yang (my test) &lt;ying@serverXY&gt;

sub 1024g/1EDB00AC 2003-10-16 \[expires: 2004-10-15\]

pub 1024D/1D0D7654 2003-10-16 Me Mao (my test) &lt;me@serverXY&gt;

sub 1024g/FD20DBF1 2003-10-16 \[expires: 2004-10-15\]

6. 특히 사용자 ID me@serverXY와 연결된 키를 목록에 표시합니다. 다음 명령어를 입력하세요:

\[ying@serverXY ying\]$*** gpg --list-keys me@serverXY***

7. me@serverXY의 키의 지문(fingerprint)을 확인합니다. 다음 명령어를 입력하세요:

\[ying@serverXY ying\]$*** gpg --fingerprint me@serverXY***

<span id="anchor-4"></span>파일 암호화 및 복호화

파일이나 문서를 암호화하고 복호화하는 절차는 간단합니다.

사용자 ying에게 메시지를 암호화하여 전송하려면 사용자 ying의 공개 키를 사용하여 메시지를 암호화해야 합니다.

수신한 후에는 ying이 ying의 개인 키로 메시지를 복호화해야 합니다.

ying만이 ying의 공개 키로 암호화된 메시지나 파일을 복호화할 수 있습니다.

파일을 암호화하려면

1. 사용자 ying으로 시스템에 로그인한 상태에서 encrypt-sec.txt라는 파일을 생성하세요. 다음 명령어를 입력하세요:

\[ying@serverXY ying\]$ ***echo "hello" &gt; encrypt-sec.txt***

cat을 사용하여 파일의 내용을 읽을 수 있는지 확인하세요.

2. encrypt-sec.txt 파일을 암호화하여 "me" 사용자만 파일을 볼 수 있도록 하세요. 즉, me@serverXY의 공개 키

 를 사용하여 암호화해야 합니다(키링에 이미 해당 키가 있음). 다음을 입력하세요:

\[ying@serverXY ying\]$ ***gpg --encrypt --recipient me@serverXY encrypt-sec.txt***

 위 명령은 현재 디렉터리에 "encrypt-sec.txt.gpg"라는 암호화된 파일을 생성합니다.

 파일을 복호화하려면

1. 위에서 암호화한 파일은 me@serverXY를 위해 생성되었습니다.

 해당 파일을 복호화해 보세요. 다음 명령어를 입력하세요:

\[ying@serverXY ying\]$ ***gpg --decrypt encrypt-sec.txt.gpg***

gpg: encrypted with 1024-bit ELG-E key, ID FD20DBF1, created 2003-10-16

 "Me Mao (my test) &lt;me@serverXY&gt;"

gpg: decryption failed: secret key not available

2. 여기서 귀중한 교훈을 배웠습니까?

3. 생성한 암호화된 파일을 올바른 소유자가 사용할 수 있도록 하고 위의 작업을 실행하도록 합니다.

 파일을 복호화하도록 하세요. 파일을 복호화하는 데 성공했나요?

!!! 참고:

    이진 파일(프로그램 등)을 복호화할 때는 매우 주의해야 합니다. 성공적으로 파일을 복호화한 후 gpg는 파일의 내용을 표준 출력으로 전송하려고 할 것입니다.

파일을 복호화할 때는 다음과 같은 명령을 사용하는 것이 좋습니다:

\[ying@serverXY ying\]$ ***gpg --output encrypt-sec --decrypt encrypt-sec.txt.gpg***

위 명령은 출력을 "encrypt-sec"라는 파일로 보내도록 강제합니다.

이 파일은 파일(또는 내용) 유형에 적합한 프로그램을 사용하여 확인(또는 실행)할 수 있습니다.

!!! TIP

1. gpg 프로그램에서 사용되는 대부분의 명령과 옵션은 더 간단한 형식으로도 사용할 수 있습니다.

 음, 명령 줄에서 가능한 한 사용자 친화적으로요. 예:

gpg --encrypt --recipient me@serverXY encrypt-sec.txt

위 명령의 간략한 형식은 다음과 같습니다:

gpg -e -r me@serverXY encrypt-sec.txt

2. 문자열 "hello"을 암호화하고 ying@serverXY 사용자에게 ASCII 아머 메시지로 전송하려면 다음 명령어를 사용하세요:

 ying@serverXY; Use the command below:

echo "hello" | gpg -ea -r ying@serverXY | mail ying@serverXY

3. "your_file"이라는 파일을 "me@serverXY"의 공개 키로 암호화하고 디지털 서명을 사용하여 "your_file.gpg"에 기록하는 명령은 다음과 같습니다:

 사용자 ID로 ***서명***한 후(디지털 서명 사용) 아래 명령을 사용하십시오.

gpg -se -r me@serverXY your\_file

4. wwwkeys.pgp.net에는 공개로 사용 가능한 키 서버가 있습니다. 다음 명령을 사용하여 키를 업로드할 수 있습니다:

gpg --send-keys &lt;your\_real\_email\_address&gt; --keyserver wwwkeys.pgp.net

OpenSSH (www.openssh.org)

OpenSSH는 OpenBSD의 SSH (Secure SHell) 프로토콜 구현입니다.

이것은 네트워크 연결 도구 모음인 SSH(Secure SHell) 프로토콜 스위트의 무료 버전입니다. OpenSSH는 모든 트래픽(비밀번호 포함)을 암호화하여 도청, 연결 탈취 및 기타 네트워크 수준 공격을 효과적으로 제거합니다. 또한 OpenSSH는 다양한 보안 터널링 기능과 다양한 인증 방법을 제공합니다.

이를 통해 불신하는 호스트 간에 보안 암호화 통신을 제공합니다(예: 인터넷을 통한 두 호스트 간).

서버 측 구성요소와 클라이언트 측 프로그램 모음을 모두 포함합니다.

**sshd**

서버 측에는 secure shell 데몬 (sshd)이 포함되어 있습니다. sshd는 클라이언트로부터의 연결을 수신하는 데몬입니다.

각 수신 연결에 대해 새로운 데몬을 생성합니다. 생성된 데몬은 키 교환, 암호화,

인증, 명령 실행 및 데이터 교환을 처리합니다. sshd의 매뉴얼 페이지에 따르면 sshd는 다음과 같이 작동합니다:

SSH 프로토콜 버전 2의 경우...

각 호스트는 호스트를 식별하는 호스트별 키 (RSA 또는 DSA)를 갖습니다. 데몬이 시작될 때 서버 키를 생성하지 않습니다(SSH 프로토콜 버전 1의 경우와 달리). Diffie-Hellman 키 합의를 통해 전방 보안이 제공됩니다. 이 키 합의는 공유 세션 키를 생성합니다.

세션의 나머지 부분은 현재 128비트 AES, Blowfish, 3DES, CAST128, Arcfour, 192비트 AES 또는 256비트 AES의 대칭 암호를 사용하여 암호화됩니다. 클라이언트는 서버에서 제공하는 암호화 알고리즘 중에서 사용할 알고리즘을 선택합니다. 또한 세션 무결성은 암호화된 메시지 인증 코드(hmac-sha1 또는 hmac-md5)를 통해 제공됩니다.

프로토콜 버전 2는 공개 키 기반의 사용자(PubkeyAuthentication) 또는 클라이언트 호스트(HostbasedAuthentication) 인증 방법, 전통적인 비밀번호 인증 및 도전 응답 기반 인증 방법을 제공합니다.

OpenSSH에서 구현된 SSH2 프로토콜은 "IETF secsh" 작업 그룹에 의해 표준화되었습니다.

ssh

클라이언트 프로그램 스위트에는 "ssh"라는 프로그램이 포함되어 있습니다. 이 프로그램은 원격 시스템에 로그인하거나 원격 시스템에서 명령을 실행하는 데 사용될 수 있습니다.

## 연습문제 5

### sshd

사용법: sshd \[옵션\]

옵션:

 옵션: -f 파일 구성 파일 (기본값: /etc/ssh/sshd_config)

 -d 디버깅 모드 (여러 개의 -d는 더 많은 디버깅을 의미함)

 -i inetd에서 시작됨

 -D 데몬 모드로 포크하지 않음

 -t 구성 파일과 키만 테스트

 -q 조용한 모드 (로깅 없음)

 -p 포트 지정 (기본값: 22)

 -k 초마다 서버 키 재생성 (기본값: 3600)

 -g 인증을 위한 그레이스 기간 (기본값: 600)

 -b 비트 서버 RSA 키 크기 (기본값: 768 비트)

 -h 호스트 키를 읽을 파일 (기본값: /etc/ssh/ssh_host_key)

 -u len utmp 기록을 위한 최대 호스트 이름 길이

 -6 IPv6만 사용

 -4 IPv4만 사용

 -o 옵션을 구성 파일에서 읽은 것처럼 처리

대부분의 Linux 시스템은 기본적으로 OpenSSH 서버가 구성되어 있고 일부 기본값으로 실행됩니다. sshd용 구성 파일은 일반적으로 -etc/ssh/ - 아래에 있으며 sshd\_config라고 합니다.

sshd\_config

1. 아무 페이저(pager)로 ssh 서버의 구성 파일을 열어서 확인합니다. 다음을 입력하세요:

\[root@serverXY root\]\# less /etc/ssh/sshd\_config

참고:

sshd\_config는 다소 이상한 구성 파일입니다.

sshd\_config 파일의 주석 (\#)은 옵션의 기본값을 나타냅니다. 즉, 주석은 이미 컴파일된 기본값을 나타냅니다.

2. sshd_config의 매뉴얼 페이지를 참조하여 아래 옵션들이 어떤 역할을 하는지 설명하세요.

AuthorizedKeysFile

Cipher (암호)

HostKey

Port

Protocol

X11Forwarding

HostKey

3. 현재 디렉토리를 /etc/ssh/로 변경하세요.

4. 아래 디렉토리의 모든 파일을 나열하세요.

호스트 키 생성

ssh 서버에는 이미 사용 중인 호스트 키가 있습니다. 이 키들은 시스템을 처음 설치할 때 생성되었습니다. 이 연습에서는 서버에 호스트 유형 키를 생성하는 방법을 배우지만 실제로는 해당 키를 사용하지는 않을 것입니다.

서버에 호스트 키 생성하기

1. pwd 아래에 새 디렉토리를 만듭니다. Spare-key라고 부릅니다. 새 디렉터리로 이동합니다. 다음 명령어를 입력하세요:

\[root@serverXY ssh\]\# mkdir spare-keys && cd spare-keys

2. ssh-keygen 프로그램을 사용하여 다음 특성을 갖는 호스트 키를 생성하세요:

a. 키 유형은 "rsa"여야 합니다.

b. 주석이 없는 키여야 합니다.

c. 개인 키 파일의 이름은 ssh\_host\_rsa\_key여야 합니다.

d. 키에 암호를 사용하지 않아야 합니다.

 다음과 같이 입력합니다:

\[root@serverXY spare-keys\]\# ssh-keygen -q -t rsa -f ssh\_host\_rsa\_key -C '' -N ''

3. 위에서 생성한 키의 지문(fingerprint)을 확인하세요. 다음을 입력하세요:

\[root@serverXY spare-keys\]\# ssh-keygen -l -f ssh\_host\_rsa\_key

4. 주석이 없고 암호도 없는 ***dsa*** 유형의 키를“ssh\_host\_dsa\_key”라는 이름으로 생성하기 위한 명령어는 무엇인가요?

## 연습문제 6

### ssh

```
사용법:- ssh \[-l login\_name\] hostname | user@hostname \[command\]

 ssh \[-afgknqstvxACNTX1246\] \[-b bind\_address\] \[-c cipher\_spec\]

 \[-e escape\_char\] \[-i identity\_file\] \[-l login\_name\] \[-m mac\_spec\]

 \[-o option\] \[-p port\] \[-F configfile\] \[-L port:host:hostport\]

\[-R port:host:hostport\] \[-D port\] hostname | user@hostname \[command\]
```

ssh 사용하기

1. me 사용자로 serverXY에 로그인합니다.

2. ssh를 사용하여 serverPR에 연결합니다. 다음을 입력하세요:

\[me@serverXY me\]$ ***ssh serverPR***

 프롬프트가 표시되면 ying의 비밀번호를 입력하십시오. 암호를 입력할 때 "yes"를 입력하여 경고 메시지가 나오면 계속합니다.

3. 로그인 후, myexport라는 디렉토리를 생성하고 빈 파일을 만듭니다. 다음을 입력하세요:

\[me@serverPR me\]$ ***mkdir ~/myexport && touch myexport/$$***

~/myexport 아래에 생성된 임의의 파일을 기록하세요.

4. serverPR에서 로그아웃합니다. 다음을 입력하세요:

\[me@serverPR me\]$ ***exit***

이로써 serverXY의 로컬 쉘로 돌아갑니다.

5. serverPR에서 ying의 홈 디렉토리에 있는 파일 목록을 보기 위해 "ls" 명령어를 원격으로 실행합니다.

 다음 명령어를 입력하세요:

\[me@serverXY me\]$ ***ssh ying@serverPR “ls /home/ying”***

프롬프트가 표시되면 ying의 비밀번호를 입력하십시오. 암호를 입력할 때 "yes"를 입력하여 경고 메시지가 나오면 계속합니다.

6. me로서 serverXY에 로그인한 상태에서 ying 사용자로 serverPR에 로그인합니다. 다음을 입력하세요:

\[me@serverXY me\]$ ***ssh -l ying serverPR ***

 **프롬프트가 표시되면 ying의 비밀번호를 입력하십시오.**

7. "exit"를 입력하여 serverPR에서 로그아웃하고 serverXY로 돌아갑니다.

<span id="anchor-7"></span>scp

scp - secure copy = 안전한 복사 (원격 파일 복사 프로그램)

scp는 네트워크 상의 호스트 간에 파일을 복사합니다. 데이터 전송을 위해 ssh를 사용하며 ssh와 동일한 인증 및 보안을 제공합니다.

```
Usage:- scp \[-pqrvBC46\] \[-F ssh\_config\] \[-S program\] \[-P port\] \[-c cipher\]

 \[-i identity\_file\] \[-o ssh\_option\] \[\[user@\]host1:\] file1 \[...\]

 \[\[user@\]host2:\] file2
 ```

scp 사용하기

1. 여전히 serverXY에서 me 사용자로 로그인한 상태인지 확인합니다.

2. 홈 디렉토리 아래에 myimport라는 디렉토리를 생성하고 해당 디렉토리로 이동합니다.

3. serverPR의 "/home/me/myexport/" 디렉토리 아래에 있는 모든 파일을 복사합니다. 다음을 입력하세요:

\[me@serverXY myimports\]$ ***scp serverPR:/home/me/myexport .***

4. pwd의 내용을 나열 하시겠습니까?

 정말 멋지지 않았나요?

5. serverPR의 "/home/me/.gnugp/" 아래에 있는 모든 파일을 복사하는 명령어는 무엇인가요?

6. 이제 serverPR의 ying 사용자의 홈 디렉토리 아래에 있는 모든 파일을 복사합니다. 다음을 입력하세요:

\[me@serverXY myimports\]$ ***scp -r ying@serverPR:/home/ying/\* .***

## 연습문제 7

### SSH를 위한 사용자 공개 및 개인 키 생성

RSA 또는 DSA 인증을 사용하여 SSH를 사용하려는 개별 사용자는 공개 키와 개인 키 세트가 필요합니다. ssh-keygen 프로그램을 사용하여 이러한 키를 생성할 수 있습니다 (시스템에 대한 예비 키를 생성할 때와 마찬가지로).

사용자 키를 생성할 때 유일한 "권장" 차이점은 암호구를 생성하는 것입니다.

암호구는 개인 키를 파일 시스템에 저장하기 전에 개인 키를 암호화하는 데 사용되는 비밀번호입니다.

공개 키는 개인 키와 동일한 파일 이름을 가지고 확장자 ".pub"이 추가된 파일에 저장됩니다. 분실된 암호구를 복구하는 방법은 없습니다. 암호구가 분실되거나 잊혀진 경우 새 키를 생성해야 합니다.

ying의 인증 키 생성하기

1. 로컬 머신에 ying 사용자로 로그인합니다.

2. "ssh-keygen" 프로그램을 실행하여 기본 길이로 “***dsa***” 유형의 키를 생성합니다. 다음을 입력하세요:

\[ying@serverXY ying\]$ ***ssh-keygen -t dsa***

공개/개인 dsa 키 쌍을 생성합니다.

기본 파일 위치를 수락하려면 \[ENTER\] 를 누릅니다.

키를 저장할 파일 입력 (/home/ying/.ssh/id\_dsa): \[ENTER\]

암호구를 입력할 때 매우 좋은 암호구를 입력하세요. 즉, 추측하기 어려운 암호구를 입력하세요.

디렉토리 '/home/ying/.ssh'가 생성되었습니다.

동일한 암호구를 다시 입력하세요:  \*\*\*\*\*\*\*\*\*

암호구를 입력하세요(암호구를 사용하지 않으려면 엔터 키를 누르세요): \*\*\*\*\*\*\*\*\*

공개 키가 /home/ying/.ssh/id\_dsa.pub에 저장되었습니다.

신원이 /home/ying/.ssh/id\_dsa에 저장되었습니다.

키 지문은 다음과 같습니다:

61:68:aa:c2:0c:af:9b:49:4a:11:b8:aa:b5:84:18:10 ying@serverXY.example.org

3. “**~/.ssh/**” 디렉토리로 이동합니다. 디렉토리 내의 파일을 나열하세요.

4. 키의 지문을 보기 위한 "ssh-keygen" 명령어는 무엇인가요?

5. cat 명령어를 사용하여 공개 키 파일 (“**~/.ssh/id\_rsa.pub**”)의 내용을 확인하세요.

## 연습문제 8

### 공개 키를 통한 인증

지금까지 serverPR의 사용자 계정에 로그인하기 위해 암호 기반 인증 체계를 사용했습니다.

이는 성공적으로 로그인하기 위해 원격 측의 해당 계정 암호를 알고 있어야 한다는 것을 의미합니다.

이 연습에서는 serverXY의 사용자 계정과 serverPR의 ying 사용자 계정 간에 공개 키 인증을 구성합니다.

공개 키 인증 구성하기

1. 로컬 시스템에 ying 사용자로 로그인합니다.

2. “~/.ssh”  디렉토리로 이동합니다.

3. 다음과 같이 보기 어려운 명령어를 입력하세요:

\[ying@serverXY .ssh\]$ ***cat id\_dsa.pub | ssh ying@serverPR \\***

 '(cd ~/.ssh && cat - &gt;&gt; authorized\_keys && chmod 600 authorized\_keys)'

 위의 명령은 다음과 같은 동작을 수행합니다:

 a. dsa 공개 키 파일의 내용을 cat으로 읽어서 표준 출력이 아닌 파이프 ( | )로 보냅니다.

 b. serverPR의 ying 사용자로서 명령어  “***cd ~/.ssh && cat - &gt;&gt; authorized\_keys && chmod 600 authorized\_keys”*** 을 실행합니다.

 c. T이 명령의 목적은 단순히 공개 키 파일의 내용을 “/home/ying/.ssh/authorized\_keys”에 복사하고 추가하며 올바른 권한을 설정하는 것입니다.

 또는 공개 키를 공개적으로 액세스 가능한 장소(게시판, 웹 페이지, 키 서버, 라디오, TV, 이메일 스팸 등)에 제공해야 합니다

 동일한 결과를 얻을 수 있는 다른 수동 방법을 알고 있다면 해당 방법을 사용해도 됩니다.

4. 원격 시스템의  authorized\_keys 파일에 공개 키를 추가한 후,  ying으로 ssh를 통해 serverPR에 로그인을 시도합니다.

 다음을 입력하세요:

\[ying@serverXY .ssh\]$ ***ssh serverPR***

키 '/home/ying/.ssh/id\_dsa'에 대한 암호구를 입력하세요: \*\*\*\*\*\*\*\*\*\*

매우 주의깊게 확인하세요. 이번에는 비밀번호 대신 암호구를 입력받고 있습니다.

키를 생성할 때 미리 생성한 암호구를 입력하세요.

5. serverPR에 성공적으로 로그인한 후, 로그아웃합니다.

## 연습문제 9

### ssh-agent

ssh-agent는 공개 키 인증(RSA, DSA)에 사용되는 개인 키를 보관하는 프로그램입니다. ssh-agent는 X 세션 또는 로그인 세션의 시작 시점에 시작되며, 다른 창이나 프로그램은 모두 ssh-agent 프로그램의 클라이언트로 시작됩니다. 환경 변수를 사용하여 에이전트를 찾고 ssh를 사용하여 다른 시스템에 로그인할 때 자동으로 인증에 사용할 수 있습니다.

```
Usage ssh-agent \[-a bind\_address\] \[-c | -s\] \[-d\] \[command \[args ...\]\]

 ssh-agent \[-c | -s\] -k
```

이 연습에서는 공개 키 인증을 사용하여 다른 시스템에 연결할 때마다 암호구를 입력할 필요가 없도록 에이전트를 구성하는 방법을 배우게 됩니다.

1. ying 사용자로 로컬 시스템에 로그인되어 있는지 확인합니다.

2. 다음 명령을 입력하세요:

[ying@serverXY .ssh\]$ ***eval \`ssh-agent\`***

Agent pid 5623

에이전트의 PID에 주의하세요:

3. “***ssh-add***” 프로그램을 사용하여 위에서 시작한 에이전트에 키를 추가합니다. 다음을 입력하세요:

[ying@serverXY .ssh\]$ ***ssh-add***

 암호를 입력하라는 메시지가 나타나면 암호를 입력하세요.

/home/ying/.ssh/id\_dsa에 대한 암호구를 입력하세요:

Identity added: /home/ying/.ssh/id\_dsa (/home/ying/.ssh/id\_dsa)

4. 이제 ying 사용자로 serverPR에 연결합니다. 암호나 암호구를 입력하라는 메시지가 표시되지 않습니다

(즉, 모든 것이 올바르게 수행된 경우). 다음 명령어를 입력하세요:

[ying@serverXY .ssh\]$ ***ssh serverPR***

5. 즐거운 시간 보내세요!
