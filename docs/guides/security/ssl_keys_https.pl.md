---
title: Generowanie Kluczy SSL
author: Steven Spencer
contributors: Ezequiel Bruni, markooff
tested with: 8.5
tags:
  - security
  - ssl
  - openssl
---
  
# Generowanie Kluczy SSL

## Wymagania

* Komputer (stację roboczą) oraz serwer z systemem Rocky Linux (OK, Linux, ale przecież będziesz chciał mieć Rocky Linux, prawda ?)
* Zainstalowany _OpenSSL_ na maszynie, na której będziesz generować prywatny klucz oraz CSR, jak również na serwerze, gdzie będziesz finalnie instalował swój klucz i certyfikaty
* Umiejętności komfortowej pracy w konsoli
* Będą pomocne: wiedza i znajomośc komend SSL i OpenSSL


## Wstęp

Niemal wszystkie współczesne strony webowe _powinny_ mieć podłączony pod siebie certyfikat SSL (secure socket layer). Ta procedura przeprowadzi Cię przez proces generowania klucza prywatnego dla Twojej strony, a później, wygenerowania CSR (certificate signing request), który będzie Ci potrzebny do zakupienia samego certyfikatu.

## Generowanie klucza prywatnego

Dla niewtajemniczonych, klucze prywatne SSL mogą mieć różne wielkości, mierzone w bitach, które w zasadzie determinują jak trudne do złamania będą to klucze.

Od 2021, zalecana długość klucza dla strony webowej wynosi 2048 bitów. Możesz wprawdzie ją zwiększyć, ale podwajając długość klucza z 2048 do 4096 podniesiesz poziom bezpieczeństwa tylko o ok. 16%, natomiast taki klucz zajmuje więcej miejsca oraz spowokuje większe obciążenia CPU podczas jego przetwarzania.

Taki krok spowolni tylko działanie Twojej strony nie dając Ci żadnej znaczącej poprawy bezpieczeństwa. Dlatego na razie zaleca się pozostanie przy kluczu długości 2048 bitów  aczkolwiek dobrze jest śledzić na bierząco wszelkie zmiany w tym zakresie.

Zaczynając, upewnijmy się że OpenSSL jest zainstalowany na obu maszynach, stacji roboczej oraz serwerze:

`dnf install openssl`

Jeśli pakiet OpenSSL nie był dotąd zainstalowany po wydaniu tego polecenia system operacyjny pobierze i zainstaluje go wraz ze wszystkimi zależnościami.

Naszą przykładową domeną niech będzie ourownwiki.com. Musisz pamiętać że musisz ją wykupić i zarejestrować zanim zaczniesz zabawę z SSL. Możesz zrobić to z pomocą jednej z szeregu firm rejestrującej domeny.

Jeśli nie posiadasz własnego serwera DNS (Domain Name System), możesz użyć serwerów DNS Twojego providera. DNS tłumaczy nazwę domenową na ciąg cyfr (adres IP w wersji IPv4 lub IPv6) który rozumie Internet. Twoja strona strona jest hostowana na serwerze pod konkretnym adresem IP.

A więc wygenerujmy klucz używając do tego openssl:

`openssl genrsa -des3 -out ourownwiki.com.key.pass 2048`

Zauważcie, nazwaliśmy od razu nasz klucz nadając mu także rozszerszenie .pass . Jak tylko wykonamy tą komendę program poprosi nas o podanie hasła (passphrase). Tutaj sugestia - podajmy krótkie hasło które zapamiętamy, gdyż i tak za chwilę będziemy go usuwać.

```
Enter pass phrase for ourownwiki.com.key.pass:
Verifying - Enter pass phrase for ourownwiki.com.key.pass:
```

Nastepnie, usuńmy to hasło. Powód takiego działania jest prosty, jeśli tego nie zrobimy to nasz serwer po każdorazowym restarcie podczas ładowania nszego klucza będzie prosił o hasło.

Możemy nie móc za każdym razem go wprowadzać, albo nawet nie mieć wtedy dostępnej konsoli. Dlatego usuwamy go żeby uniknąć takich sytuacji.

`openssl rsa -in ourownwiki.com.key.pass -out ourownwiki.com.key`

Ta komenda bedzie wymagać podania naszego hasła raz jeszcze po czym usunie go z klucza.

`Enter pass phrase for ourownwiki.com.key.pass:`

Teraz, po podaniu hasła po raz trzeci, zostanie ono na trwałe usuniete z naszego kluca, a on sam zapisany jako ourownwiki.com.key

## Generowanie CSR

Następnym krokiem jest wygenerowanie CSR (certificate signing request) którego użyjemy podczas zakupu naszego certyfikatu.

Podczas procesu generowania CSR będziemy proszeni o podanie szeregu informacji. Będą to arybuty X.509 dla naszego certyfikatu.

Jednym z pierwszych informacji będzie podanie "Common Name (np. Twojej nazwy)". To ważne żeby to pole zawierało FQDN (Fully Qualified Domain Name) naszej strony która ma być chroniona protokołem SSL. Jeśli strona którą zamierzamy chronić ma miec adres https://www.ourownwiki.com to w tym polu podajemy ciąg www.ourownwiki.com :

`openssl req -new -key ourownwiki.com.key -out ourownwiki.com.csr`

Ta komenda uruchomi szereg pytań:

`Country Name (2 letter code) [XX]:` wprowadź 2 literowy kod kraju gdzie będzie tTwoja strona, np."US"

`State or Province Name (full name) []:` wprowadź pełną oficjalną nazwę stanu lub prowincji, np. "Nebraska"

`Locality Name (eg, city) [Default City]:` wprowadź pełną nazwę miasta, np. "Omaha"

`Organization Name (eg, company) [Default Company Ltd]:` jeśli chcesz, możesz tu podać nazwę Organizacji które częścią jest Twoja domena, lub po prostu nacisnąc Enter i przejść dalej

`Organizational Unit Name (eg, section) []:` to pole określa dział w Organizacji gdzie będzie podlegać Twoja domena. Jak wyżej możesz pominąć naciskając Enter

`Common Name (eg, your name or your server's hostname) []:` tutaj musisz podać nazwę serwisu np. "www.ourownwiki.com"

`Email Address []:` to pole jest opcjonalne, jeśli nie chcesz go wypełnić po prostu naciśnij Enter

Nastepnie zostaniesz poproszony o podanie dodatkowych atrybutów (oba można pominąć Enterem)

```
Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:
An optional company name []:
```

Po zakończeniu podawania wszystkich atrybutów zostanie wygenerowany nasz CSR.

## Wykupywanie certyfikatu

Każdy dostawca certyfikatów powinien mieć w zasadzie tą samą procedurę. Kupujesz SSL, określasz zakres czasowy (1 lub 2 lata) na jaki ma obowiązywać a potem wgrywasz swój CSR. Żeby wyświetlić sobie zawartość CSR użyj komendy `more`, po czym skopiuj tą zawartość.

`more ourownwiki.com.csr`

Co powinno dać rezultat podobny do poniższego:

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

Powinieneś skopiować wszystko razem z liniami BEGIN CERTIFICATE REQUEST oraz END CERTIFICATE REQUEST. Następnie wklej skopiowaną zawartość w pole CSR w serwisie za pomocą którego kupujesz certyfikat SSL.

Być może będziesz musiał wykonać inne kroki weryfikacyjne, w zależności od własności domeny, używanego rejestratora itp., zanim Twój certyfikat zostanie wystawiony. Kiedy go otrzymasz, będzie razem z nim wydany certyfikat pośredni od providera (serwisu w którym kupujesz certyfikat SSL), który będziesz potrzebować razem z właściwym certyfikatem do poprawnego skonfigurowania swojego serwisu.

## Konkluzja

Podsumowując, zakup certyfikatu SSL dla Twojego serwisu webowego nie jest czymś niewiarygodnie trudnym i może być łatwo zrealizowany za pomocą powyższej procedury przez administratora systemu bądź samego serwisu.
