---
title: Funt
author: Steven Spencer, markooff
contributors:
tested with: 8.5, 8.6
tags:
  - proxy
  - proxy
---

# Serwer proxy funtów

!!! ważny "Funt brakujący w EPEL-9"

    Od tego pisania, Rocky Linux 9.0 nie może być zainstalowany z repozytorium EPEL. Chociaż istnieją źródła dla pakietów SRPM, nie możemy zweryfikować integralności tych źródeł. Z tego powodu nie zalecamy instalacji serwera proxy Pound na Rocky Linux 9.0 w tym momencie. Może to ulec zmianie, jeśli EPEL ponownie zabierze funt.  Należy użyć tej procedury specjalnie dla Rocky Linux 8.5 lub 8.6.

## Wstęp

Funt jest serwerem sieciowym agnostycznym odwróconym proxy i ładuje balancer, który jest bardzo łatwy w konfiguracji i zarządzaniu. Nie korzysta z samej usługi internetowej, ale słucha w portach serwisów internetowych (http, http).

Teraz jest wiele opcji serwera proxy, niektóre z nich odnoszą się do tych stron dokumentacji. Istnieje dokument dotyczący użycia [HAProxy tutaj](haproxy_apache_lxd.md) i w innych dokumentach pojawiły się odniesienia do używania Nginx dla odwrotnego proxy.

Usługi równoważenia obciążenia są całkiem użyteczne dla zajętego środowiska serwera internetowego. Wiele serwerów proxy, w tym wspomniany wcześniej HAProxy, może być używanych dla wielu typów usług.

W przypadku funtu można go użyć tylko do usług sieciowych, ale jest to dobre w tym, co robi.

## Wymagania i założenia

Do stosowania tej procedury stosuje się następujące minimalne wymogi:

* Pragnienie wczytywania równowagi pomiędzy kilkoma stronami internetowymi lub chęć poznania nowego narzędzia robią to samo.
* Możliwość wykonywania poleceń jako główny użytkownik lub użycie `sudo` , aby tam dotrzeć.
* Znajomość edytora wiersza poleceń. Używamy tutaj `vi` lub `vim` , ale możesz zastąpić go w twoim ulubionym edytorze.
* Komfort ze zmianą portów nasłuchiwanych na kilku typach serwerów internetowych.
* Zakładamy, że zarówno serwery Nginx, jak i Apache są już zainstalowane.
* Zakładamy, że używasz serwerów Rocky Linux lub kontenerów dla wszystkich tutaj.
* Podczas gdy tworzymy wszystkie rodzaje instrukcji dotyczących `https` poniżej, ten przewodnik dotyczy tylko usługi `http`. Aby poprawnie wykonać `https`, musisz skonfigurować swój serwer funtowy z prawdziwym certyfikatem autoryzacji certyfikatów.

!!! Wskazówka

    Jeśli nie masz zainstalowanego żadnego z tych serwerów, możesz to zrobić w środowisku kontenerowskim (LXD lub Docker) lub na nagim metalu, i wciągnąć je i uruchomić. Do celów tej procedury wystarczy zainstalować je wraz z odpowiednimi pakietami oraz włączyć i uruchomić usługi. Nie będziemy w żaden sposób modyfikować ich w znaczący sposób.

    ```
    dnf -y install nginx && system włącz --now nginx
    ```


    lub

    ```
    dnf -y install httpd && system włącz --now httpd
    ```

## Konwencje

Do tej procedury będziemy używać dwóch serwerów internetowych (znanych jako serwery back-end), z których jeden uruchamia Nginx (192. 68.1.111) i jeden biegły Apache (192.168.1.108).

Nasz serwer funtów (192.168.1.103) będzie uważany za bramę.

We will be switching our listen ports on both of the back end servers to 8080 for the Nginx server and 8081 for the Apache server. Wszystko zostanie szczegółowo omówione poniżej, więc na chwilę obecną nie trzeba się o nie martwić.

!!! notatka

    Pamiętaj, aby zmienić powiązane IP na wszystkie istniejące w Państwa otoczeniu i w stosownych przypadkach zastąpić je w trakcie tej procedury.

## Instalacja serwera funtów

Aby zainstalować Funt, musimy najpierw zainstalować EPEL (Extra Packages for Enterprise Linux) i uruchomić aktualizacje na wypadek pojawienia się czegoś nowego z EPEL:

```
dnf -y install epel-release && dnf -y aktualizacja
```

Następnie po prostu zainstaluj Funt. (Tak, to jest kapitał "P"):

```
dnf -y instalacja funta
```

## Konfigurowanie funta

Teraz, gdy pakiety są zainstalowane, musimy skonfigurować Funt. Będziemy używać `vi` aby to zaktualizować, ale jeśli wolisz `nano` lub coś innego, idź dalej i zastąp to w:

```bash
vi /etc/funt.cfg
```

Plik jest skonfigurowany z domyślnymi informacjami, co sprawia, że łatwiej jest zobaczyć większość domyślnych składników Funtu:

```bash
Użytkownik "funt"
Grupa "funt"
Kontrola "/var/lib/pound/pound.cfg"

ListenHTTP
    Adres 0.0.0.
    Port 80
End

ListenHTTPS
    Adres 0. .0.0
    Port 443
    Cert "/etc/pki/tls/certs/funt. em"
End

Service
    BackEnd
        Adres 127.0.0.
        Port 8000
    Koniec

    BackEnd
        Adres 127. .0.1
        Port 8001
    Koniec
Koniec
```

### Zdobycie ściślejszego wyglądu

* "Użytkownik" i "Grupa" zostały zachowane podczas instalacji
* Plik "Kontrola" nie wydaje się nigdzie używany.
* Sekcja "ListenHTTP" reprezentuje usługę `http` (Port 80) i "Adres", na której serwer proxy będzie słuchał. Zmienimy to na rzeczywisty adres IP naszego serwera funtów.
* Sekcja "ListenHTTPS" reprezentuje usługę `https` (Port 443) i "Adres", na której serwer proxy będzie słuchał. Tak jak w przypadku powyższego, zmienimy to na adres IP serwera funtów. Opcją "Certyfikat" jest samopodpisany certyfikat dostarczony przez proces instalacji funtów. Chcesz zastąpić to w środowisku produkcyjnym prawdziwym certyfikatem za pomocą jednej z następujących procedur: [Generowanie kluczy SSL](../security/ssl_keys_https.md) lub [kluczy SSL za pomocą Let's Encrypt](../security/generating_ssl_keys_lets_encrypt.md).
* Sekcja "Usługa" to miejsce, w którym serwery "BackEnd" są skonfigurowane wraz z portami nasłuchiwania. Możesz mieć tyle serwerów "BackEnd" ile potrzebujesz.

### Zmiana konfiguracji

* zmień adres IP w obu opcjach nasłuchiwania na adres IP naszego serwera funtów, 192.168.1.103
* zmień adresy IP i porty w sekcji "BackEnd" w celu dopasowania naszej konfiguracji znajdującej się w "Konwencjach" powyżej (IPs i ports)

Gdy wszystko skończysz modyfikować konfigurację, powinieneś mieć zmieniony plik, który wygląda tak:

```bash
Użytkownik "funt"
Grupa "funt"
Kontrola "/var/lib/pound/pound.cfg"

ListenHTTP
    Adres 192.168.1. 03
    Port 80
End

ListenHTTPS
    Adres 192. 68.1.103
    Port 443
    Cert "/etc/pki/tls/certs/funt. em"
End

Service
    BackEnd
        Adres 192.168.1. 11
        Port 8080
    End

    BackEnd
        Adres 192. 68.1.108
        Port 8081
    End
End
```

## Konfigurowanie Nginx do słuchania na 8080

Ponieważ ustawiliśmy port nasłuchiwania Nginx w naszej konfiguracji funta na 8080, musimy również wprowadzić tę zmianę na naszym uruchomionym serwerze Nginx. Robimy to modyfikując `nginx.conf`:

```bash
vi /etc/nginx/nginx.conf
```

Po prostu chcesz zmienić linię "nasłuchuj" na nowy numer portu:

```bash
nasłuchuj 8080 default_server;
```

Zapisz zmiany, a następnie uruchom ponownie usługę nginx:

```
systemowy restart nginx
```

## Konfigurowanie Apache do nasłuchiwania na 8081

Ponieważ ustawiliśmy port nasłuchiwania Apache w naszej konfiguracji do 8081, musimy również wprowadzić tę zmianę na naszym uruchomionym serwerze Apache. Zrobimy to, modyfikując `httpd.conf`:

```bash
vi /etc/httpd/conf/httpd.conf
```

Chcesz zmienić linię "Słuchaj" na nowy numer portu:

```bash
Słuchaj 8081
```

Zapisz zmiany i uruchom ponownie usługę httpd:

```
uruchom ponownie system httpd
```

## Testuj i wyłącz

Gdy masz swoje usługi internetowe, działasz i słuchaj właściwych portów na każdym z naszych serwerów, następnym krokiem jest uruchomienie usługi funta na serwerze funta:

```
Systemctl enable --now funt
```

!!! uwaga

    Używanie Nginx i Apache, tak jak robimy tutaj w celu demonstracji, będzie oznaczać, że serwer Nginx prawie zawsze będzie odpowiadał najpierw. Z tego względu należy skutecznie przetestować, musisz przypisać niski priorytet do serwera Nginx, abyś mógł zobaczyć oba ekrany. To mówi o szybkości Nginx nad Apache. Aby zmienić priorytet serwera Nginx, wystarczy dodać priorytet (1-9, z 9 najniższym priorytetem) w sekcji "BackEnd" dla serwera Nginx jak ten:

    ```
    BackEnd
        Adres 192.168.1.111
        Port 8080
        Priorytet 9
    koniec
    ```

Kiedy otworzysz IP serwera proxy w przeglądarce internetowej, powinieneś się zmierzyć z jednym z tych dwóch ekranów:

![Funt Nginx](images/pound_nginx.jpg)

Lub

![Aache funtów](images/pound_apache.jpg)

## Używanie alarmu

Jedno co trzeba zrobić podczas używania balansu obciążenia, takie jak funt, ma odbierać serwery produkcji w trybie offline w celu konserwacji lub mieć zapasowy "BackEnd" dla całkowitego przerwania. Wykonuje się to z deklaracją "Emergency" w pliku `pound.conf`. Możesz mieć tylko jedną deklarację "Emergency" na jedną usługę. W naszym przypadku pojawiłoby się to na końcu sekcji "Usługi" w naszym pliku konfiguracyjnym:

```
...
Usługa
    BackEnd
        Adres 192.168.1. 17
        Port 8080
    Priorytet 9
    Koniec

    BackEnd
        Adres 192. 68.1.108
        Port 8081
    Koniec
    Awaria
       Adres 192. 68.1.104
       Port 8000
   Koniec
Koniec
```

Ten serwer może wyświetlać tylko wiadomość, która mówi, "Down For Maintenance".

## Kwestie bezpieczeństwa

Problemy bezpieczeństwa nie będą rozwiązywać większości dokumentów dotyczących równoważenia obciążenia serwerów proxy. Na przykład, jeśli jest to publiczny serwer internetowy, musisz mieć otwarte usługi `http` i `https` na świecie na serwerze proxy równoważenia obciążenia. Ale co z serwerami „BackEnd”?

Dostęp do nich powinien być zapewniony wyłącznie przez ich porty z samego serwera funtów, ale ponieważ serwer Pound przekierowuje do 8080 lub 8081 na serwerach BackEnd, i ponieważ serwery BackEnd mają `http` słuchając tych kolejnych portów, możesz po prostu użyć nazw usług dla poleceń zapory na tych serwerach BackEnd.

W tej sekcji zajmiemy się tymi obawami i poleceniami `firewalld` potrzebnymi do zablokowania wszystkiego.

!!! ostrzeżenie

    Zakładamy, że masz bezpośredni dostęp do danych serwerów i nie jesteś do nich zdalny. Jeśli jesteś zdalny, zachowaj szczególną ostrożność podczas usuwania usług ze strefy `firewalld`!
    
    Możesz zablokować się z serwera przez przypadek.

### Zapora - Serwer Funtów

Dla serwera funtów, jak zauważono powyżej, chcemy zezwolić na `http` i `https` ze świata. Musisz się zastanowić, czy `ssh` musi być dozwolony ze świata, czy nie. Jeśli jesteś lokalny na serwerze, to prawdopodobnie **NIE** przypadek. Zakładamy, że serwer jest dostępny przez Twoją sieć lokalną i że masz bezpośredni dostęp do niej, więc zamkniemy `ssh` na nasze adresy IP LAN.

Aby osiągnąć powyższe, użyjemy wbudowanej zapory dla Rocky Linux, `firewalld` i `firewall-cmd` struktury poleceń. Dla uproszczenia wykorzystamy również dwie strefy zabudowane – „publiczne” i „zaufane”.

Zacznijmy od dodania naszych źródłowych adresów IP do strefy „zaufanej”. Jest to nasz łańcuch wartości (przykład: 192.168.1.0/24):

```
firewall-cmd --zone=zaufane --add-source=192.168.1.0/24 --permanent
```

Następnie dodajmy usługę `ssh` do strefy:

```
zapora-cmd --zone=zaufane --add-service=ssh --permanent
```

Po zakończeniu tego wszystkiego odświeżyć zaporę poprzez:

```
firewall-cmd --reload
```

A następnie wylistuj strefę tak, aby zobaczyć wszystko z `zaporą cmd --zone=trusted --list-all` , co powinno dać Ci coś takiego:

```bash
zaufany (aktywny) cel
  ACCEPT
  icmp-block-inversion: no
  interfejsy:
  źródła: 192.168.1. /24
  usługi: ssh
  porty:
  protokołów:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  bogate reguły:

```

Następnie musimy wprowadzić zmiany w strefie "publicznych", która domyślnie ma włączoną usługę `ssh`. To musi zostać ostrożnie usunięte (ponownie, zakładamy, że jesteś **NIE** zdalny na serwer tutaj!) z następującymi powodami:

```
zapora-cmd --zone=publiczna --remove-service=ssh --permanent
```
Musimy również dodać usługi `http` i `https`:

```
zapora-cmd --zone=publiczna --add-service=http --add-service=https --permanent
```

Następnie musimy przeładować zaporę zanim zobaczysz zmiany:

```
firewall-cmd --reload
```

A następnie wylistuj strefę publiczną z `firewall-cmd --zone=public --list-all` , która powinna pokazać Ci coś takiego:

```bash
cel publiczny
  : domyślny
  icmp-block-inversion: no
  interfejsów:
  źródła:
  usługi: cockpit dhcpv6-client http
  ports:
  protokoły:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  bogate reguły:
```

W naszym środowisku laboratorium są to jedyne zmiany, które musimy wprowadzić w naszym funcie równowagi obciążenia serwera.

### Zapora - Serwery z tyłu

Dla serwerów "BackEnd", nie musimy zezwalać na dostęp ze świata dla wszystkich, a na pewno nie dla naszych nasłuchanych portów, z których będzie korzystał bilans ładunku. Będziemy musieli zezwolić na `ssh` z adresów IP LAN oraz `http` i `https` z naszego balancera obciążenia funtów.

To całkiem to wszystko.

Ponownie dodamy usługę `ssh` do naszej strefy "zaufane", z zasadniczo tymi samymi poleceniami, które użyliśmy dla naszego serwera funtów. Następnie dodamy strefę o nazwie "saldo", którą będziemy używać dla pozostałych `http` i `https`, i ustaw źródłowe adresy IP na adresy docelowe balancera. Jesteś już zabawny?

Aby być szybkim, użyjmy wszystkich tych poleceń, które użyliśmy w strefie "zaufane" w jednym zestawie poleceń:

```
zapora-cmd --zone=zaufana --add-source=192.168.1.0/24 --permanent
zapora zapora-cmd --zone=zaufana --add-service=ssh --permanent
zapora cmd --reload
zapora-cmd --zone=zaufana --list-all
```

Następnie strefa „zaufana” powinna wyglądać tak:

```bash
zaufany (aktywny) cel
  ACCEPT
  icmp-block-inversion: no
  interfejsy:
  źródła: 192.168.1. /24
  usługi: ssh
  porty:
  protokołów:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  bogate reguły:
```

Ponownie, przetestuj regułę `ssh` z adresu IP w LAN, a następnie usuń usługę `ssh` ze strefy "publiczną". **Zapamiętaj nasze ostrzeżenie z góry i zrób to tylko wtedy, gdy masz lokalny dostęp do serwera!**

```
zapora cmd --zone=publiczna --remove-service=ssh --permanent
zapora cmd --reload
zapora cmd --zone=publiczna --list-all
```

Strefa publiczna powinna teraz wyglądać tak:

```bash
cel publiczny
  : domyślny
  icmp-block-inversion: no
  interfejsów:
  źródła:
  usługi: cockpit dhcpv6-client
  porty:
  protokoły:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  bogatych reguł:
```

Now let's add that new zone to deal with `http` and `https`. Pamiętaj, że tutaj źródłowy IP musi być tylko naszym bilansem obciążenia (w naszym przykładzie: 192.168.1.103):

!!! notatka

    Nowa strefa musi być dodana z opcją `--permanent` i nie może być używana, dopóki zapora nie zostanie ponownie załadowana. Nie zapomnij również o `--set-target=ACCEPT` dla tej strefy!

```
firewall-cmd --new-zone=balance --permanent
firewall-cmd --reload
firewall-cmd --zone=balance --set-target=ACCEPT
firewall-cmd --zone=balance --add-source=192. 68.1.103 --permanent
zapora zapora-cmd --zone=balance --add-service=http --add-service=https --permanent
zapora-cmd --reload
zapora-cmd --zone=balance --list-all
```

Wynik:

```bash
saldo (aktywne)
  cel: ACCEPT
  icmp-block-inversion: no
  interfejsów:
  źródła: 192.168.1. Usługi 03
  : http https
  porty:
  protokołów:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  bogate reguły:
```

Teraz powtórz te kroki na drugim serwerze WWW.

Po dodaniu reguł zapory do wszystkiego, przetestuj serwer funtów ponownie z przeglądarki stacji roboczej.

## Inne informacje

Istnieje *LOT* opcji, które mogą być zawarte w Twoim `funcie. onf` plik, w tym dyrektywy w sprawie komunikatów o błędach, opcje logowania, wartości czasu i czasu itp. Więcej informacji na temat tego, co jest dostępne [można znaleźć tutaj.](https://linux.die.net/man/8/pound)

Wygodnie, funt automatycznie zapisuje, jeśli jeden z serwerów "BackEnd" jest wyłączony i wyłącza go, aby usługi sieciowe mogły być kontynuowane bezzwłocznie. Automatycznie widzi je również ponownie, gdy są one z powrotem w internecie.

## Konkluzja

Funt oferuje inną opcję dla tych, którzy nie chcą używać HAProxy lub Nginx jako ładowania.

Funt jako serwer równoważenia obciążenia jest bardzo łatwy w instalacji, konfiguracji i użytkowaniu. Jak zauważono tutaj, Funt może być również używany jako zastępczy wskaźnik zastępczy i jest wiele dostępnych opcji bilansowania obciążenia.

I zawsze powinieneś pamiętać o bezpieczeństwie podczas ustawiania dowolnej usługi, w tym serwera proxy równoważącego ładunek.
