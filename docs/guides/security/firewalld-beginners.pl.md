---
title: firewalld dla początkujących
author: Ezequiel Bruni
contributors: Steven Spencer, markooff
update: 26-Jul-2022
---

# `firewalld` dla Początkujących

## Wstęp

Dawno temu, kiedy sam byłem początkującym użytkownikiem komputera usłyszałem że posiadanie firewalla jest czymś naprawdę super. Hmm, to da mi możliwość decydowania co wchodzi do mojego komputera i co z niego wychodzi, no nie? - pomyślałem. Ale, jak się później okazło, tak naprawdę główną 'zaletą' mojego firewalla było przeszkadzanie moim grom w dostępie do internetu. Co wcale nie czyniło mnie "szczęślitym kamperem".

Skoro trafiłeś tutaj, to pewnie masz znacznie lepsze pojęcie ode mnie sprzed lat, czym jest firewall, do czego służy i jak działa. Ale jeśli Twoje jedyne doświadczenia z firewallami sprowadzały się dotąd do mówienia Windows Deffenderowi "Tak, wiem co robię, no, daj spokój i wpuść moją wspaniałą nową aplikację do internetu!!" nie przejmuj się :) Napisałem "dla początkujących" i wiem co mówię :) Napisałem "dla początkujących" i wiem co mówię :)

Innymi słowy, moi drodzy komputerowi nerdzi, przygotujcie się na sporą dawkę wiedzy.

A więc zacznijmy od tego po co tu jesteśmy. `firewalld` jest domyślnym narzędziem w systemie pakietów Rocky Linux, i został zaprojektowany aby być maksymalnie prostym w użyciu. Jedyną wiedzą jaką potrzebujesz na starcie - to wiedzieć jak w ogólnym zarysie działają firewalle.

Z poniższego tutoriala nauczysz się:

* podstaw działania `firewalld`
* Jak używać `firewalld` do blokowania lub przepuszczania przychodzących/wychodzących połączeń
* Jak zezwolić użytkownikom z konkretnych adresów IP lub miejsc logować się do Twojego komputera zdalnie
* Jak zarządzać niektórymi właściwościami `firewalld` jak np. Zonami.

Tym niemniej, poniższy materiał *nie ma* ambicji być kompletnym i wyczerpującym temat opracowaniem.

### Informacje n/t zarządzania firewallem za pomocą konsoli (z linii poleceń)

OK... *są* wprawdzie narzędzia graficzne służące do konfiguracji firewalla. Na desktopach (stacjach roboczych) jest narzędzie `firewall-config` które można zainstalowac bezpośrednio z repozytorium podczas gdy na serwerach możesz po prostu \[zainstalować Cockpit\] (https://linoxide.com/install-cockpit-on-almalinux-or-rocky-linux/) który jest narzędziem pomagającym w zarzadzaniu tak firewallem jak i szeregiem innych spraw. Mimo to, w tym tutorialu chciałbym Cię nauczyć metody zarządzania z poziomu konsoli, a to z kilku powodów:

1. Jeśli pracujesz na serwerze, to i tak w większości wypadków będziesz używał konsoli. Wiele tutoriali i samouczków napisanych dla serwera na platformie Rocky Linux będzie i tak operowało z użyciem konsoli przy zarządzaniu firewallem, więc lepiej żebyś zrozumiał te komendy i ich składnię zamiast potem być zmuszonym do jedynie mechanicznego kopiowania i wklejania kawałków kodu którego nie rozumiesz.
2. Poznanie jak działają polecenia `firewalld` pozwoli Ci również lepiej zrozumieć samą mechanikę działania oprogramowania typu firewall. Te same zasady, które poznasz tutaj, bedziesz mógł odnieśc i zastosować później także i w używaniu graficznych narzędzi do zarzadzania firewallami w przyszłości.

## Wymagania i założenia
Będziesz potrzebować:

* Komputera z systemem Rocky Linux, obojętnie czy będzie to maszyna fizyczna czy virtualna z dostepem zdalnym, bądź lokalnym.
* Dostępu do terminala i chęci używania go.
* Dostepu do konta root'a a w wersji minimalnej do polecenia `sudo` z poziomu Twojego konta uzytkownika. Dla ułatwienia w materiale zakładam że wszystkie komendy będą wykonywane bezpośrednio z konta root'a.
* Podstawowa wiedza na temat działania SSH będzie pomocna przy zarządzaniu zdalną maszyną.

## Podstawy używania

### Komendy do zarzadzania `firewalld` w ramach uslug systemowych (system services)

`firewalld` działa jako usługa w Twoim systemie. Zostaje uruchomiony wraz ze startem systemu, a w każdym razie powinien. Jeśli z jakiegoś powodu na Twoim systemie `firewalld` nie został aktywowany (enabled) możesz teraz zrobić to ręcznie za pomocą komendy:

```bash
systemctl enable --now firewalld
```

Flaga `--now` dodatkowo uruchamia usługę zaraz po jej zaaktywowaniu, co pozwala ominąć kolejny krok - i polecenie `systemctl start firewalld`

Tak jak w przypadku każdej innej usługi w systemie Rocky Linux, możesz zawsze sprawdzić czy firewall jest uruchomiony poleceniem:

```bash
systemctl status firewalld
```

Aby zatrzymać usługę wpisujesz:

```bash
systemctl stop firewalld
```

Oraz, aby wykonac tzw. twardy (czytaj: całkowity) restart:

```bash
systemctl restart firewalld
```

### Podstawowe komendy do konfiguracji i zarządzania `firewalld`

Zachowanie `firewalld` jest konfigurowane i kontrolowane poleceniem `firewall-cmd`. Np. możesz sprawdzić status `firewalld` komendą:

```bash
firewall-cmd --state
```

Po każdej *trwałej* modyfikacji (permanent change) konfiguracji Twojego firewalla musisz go przeładować żeby zobaczyć zmiany. Robisz to za pomocą tzw. "miękkiego restartu" wydając polecenie:

```bash
firewall-cmd --reload
```

!!! Note

    	Jesli wykonałeś przeładowanie (reload) konfiguracji firewalla bez wcześniejszego zapisania na trwałe dokonanych zmian - po takim ponownym załadowaniu konfiguracji nie będa one widoczne.

Aby wyświetlić na raz wszystkie ustawienia i całą konfigurację firewalla użyj komendy:

```bash
firewall-cmd --list-all
```

Polecenie to powinno wyświetlić wynik zbliżony do poniższego:

```bash
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp9s0
  sources:
  services: ssh
  ports:
  protocols:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

### Zapisywanie zmian

!!! Warning "Uwaga, naprawdę przeczytaj te kilka linijek!"

    Domyślnie wszystkie zmiany w konfiguracji `firewalld` są tymczasowe. Dlatego jeśli zrestartujesz usługę `firewalld` albo cały komputer, dokonane przez Ciebie zmiany nie będą zapisane - o ile nie wykonasz wcześniej jednego z dwóch poniższych kroków.

Najlepsza praktyką jest testowanie zmian w konfiguracji firewalla polecenie po poleceniu oraz wykonując przeładowanie konfiguracji firewalla (reload) po każdym udanym teście. W ten sposób jeśli w wyniku którejś z wprowadzanych zmian np. odetniesz sobie całkowicie dostęp do maszyny, wystarczy że zrestarujesz usługę albo raczej cały komputer i ta zła zmiana pójdzie po prostu w niebyt.

A kiedy będziesz już miał poporawną i sprawdzoną konfigurację, możesz zapisac ją na stałe poleceniem :

```bash
firewall-cmd --runtime-to-permanent
```

Jeśli jednak jesteś przekonany że dokładnie wiesz co robisz :) i chcesz tylko dodać jedną (sprawdzoną) regułę na stałe by móc pracować dalej, możesz zrobić to dodając flagę `--permanent` do każdej komendy konfiguracyjnej.

```bash
firewall-cmd --permanent [the rest of your command]
```

## Zarządzanie Zonami (strefami)

Zanim zaczniemy, chciałbym wyjaśnić samo pojęcie Zony (Strefy). Zony to rozwiązanie pozwalające Ci w praktyce zastosowac odmienne zestawy reguł do różnych sytuacji. Mechanizm Zon (Stref) stanowi znaczną część funkcjonalności firewalla a więc wypada poświecić mu odpowiednio dużo czasu.

Jeśli Twój komputer posiada kilka połączeń sieciowych łączących go z różnymi sieciami (np. Ethernet po kablu oraz Wifi), możesz zdecydować że jedna z nich jest siecią bardziej zaufaną i bezpieczną. Możesz np. umieścić połączenie kablowe z siecią Ethernet w strefie "zaufanej" ("Trusted" Zone) jeśli jest to sieć wyłacznie lokalna, którą sam tworzyłeś i kontrolujesz, a z drugiej strony, umiescić połączenie Wifi (które może być np. Twoim połączeniem z internetem) w strefie "publicznej" (Public Zone), w której będą obowiązywać znacznie ostrzejsze zasady kontroli ruchu.

!!! NOTE

    Strefa (Zona) może być aktywną (w stanie aktywna) *jedynie* po spełnieniu jednego z dwu poniższych warunków:
    1.

    1. Strefa jest przypisana do interfejsu sieciowego
    2. Strefa jest ma przypisany adres źródłowy IP lub zakres adresów sieciowych. (Więcej o tym w dalszej części materiału)

Domyślne Strefy (Zony) zawierają (wyjasnienie zaczerpnąłem z [ Samouczek DigitalOcean do `firewalld`](https://www.digitalocean.com/community/tutorials/how-to-set-up-a-firewall-using-firewalld-on-centos-8), do przeczytania którego także gorąco namawiam):

> **drop:** To najniższy poziom zaufania. Wszystkie połaczenia przychodzące są ubijane bez jakiejkolwiek odpowiedzi (dropped) a dozwolone są wyłącznie połączenia wychodzące

> **block:** Podobnie jak powyżej, z tą różnicą, że połączenia przychodzące są ubijane odrzucane (rejected) z jednoczesnym komunikatem icmp icmp-host-prohibited lub  icmp6-adm-prohibited w odpowiedzi.

> **public:** Ta strefa reprezentuje sieci publiczne, niezaufane. Nie mamy zaufania do innych komputerów w tych sieciach ale możemy pozwolić na wybrane połączenia przychodzące, zdefiniowane poszczególnymi regułami w naszym firewallu. zewnętrzne (external): będą to sieci zewnętrzne w sytuacji gdy używasz firewalla na Twoim routerze łączącym z siecią zewnątrzną. Zostało to przygotowane dla maskarady NAT (NAT masquerading) żeby sieci wewnętrzne (internal) mogły pozostać prywatne ale jednak w pewnym sensie dostępne z zewnątrz. (poprzez reguły NAT - przyp. markooff)

> **internal:** Druga strona strefy external, używana do obsługi ruchu wewnętrznego (internal networks). Komputery w tej sieci i tej strefie traktujemy jako niemalże godne zaufania więc udostępniamy im pewne dodatkowe usługi.

> **dmz:** Strefa (Zona) używana do obsługi ruchu dla komputerów będących w tzw. DMZ (De-Militarized Zone - przyp. markooff) Jest to izolowana sieć wewnętrzna w której komputery nie mają, z definicji, połączenia z innymi strefami naszej sieci. Wyjątkiem będą specjalnie, osobno zdefiniowane połączenia.

> Strefa używana dla normalnego ruchu komputerów w sieci roboczej (wewnątrz firmy/biura - przyp. markooff). W większości mamy zaufanie do komputerów w tej sieci, więc pewne dodatkowe usługi będą dostępne.

> **work:** Strefa używana dla normalnego ruchu komputerów w sieci roboczej (wewnątrz firmy/biura - przyp. markooff). W większości mamy zaufanie do komputerów w tej sieci, więc pewne dodatkowe usługi będą dostępne.

> **trusted:** Strefa najwyższego zaufania. Ponieważ ufamy tu z założenia wszystkim komputerom więc będzie to najbardziej "nieskrępowana" ze stref, gdzie działa najwięcej usług. Nalezy stosować tą strefę bardzo ostrożnie i oszczędnie.

OK, niektóre z tych wyjaśnień mogą brzmieć bardzo skomplikowanie, ale szczerze ? Przeciętny początkujący użytkownik - powinien poradzić sobie zapamiętując i rozumiejąc  tylko działanie stref "trusted", "home" oraz "public", oraz wiedząc kiedy zastosować którą z nich.

### Komendy do zarządzania Strefami (Zonami)

Aby wyświetlić domyślną strefę w Twoim firewallu uruchom polecenie:

```bash
firewall-cmd --get-default-zone
```

Aby wyświetlić wszystkie strefy, które są aktywne i pracują uzyj polecenia:

```bash
firewall-cmd --get-active-zones
```

!!! NOTE "Uwaga: Niektóre z ustawień dla Twojego systemu mogły zostać predefiniowane"

    Jeśli używasz Rocky Linuxa na serwerze klasy VPS jest prawdopodobnym, że na strcie podczas instalacji Twój system otrzymał z góry predefiniowane ustawienia firewalla. Np. prekonfigurowany dostęp do zarządzania przez SSH więc interfejs sieciowy musiał zostać dodany do strefy (zony) "public".

Aby zmienić strefę domyślną wykonaj:

```bash
firewall-cmd --set-default-zone [your-zone]
```

Aby dodać interfejs sieciowy do strefy (zony):

```bash
firewall-cmd --zone=[your-zone] --add-interface=[your-network-device]
```

Aby zmienić strefę dla interfejsu sieciowego:

```bash
firewall-cmd --zone=[your-zone] --change-interface=[your-network-device]
```

Aby całkowicie usunąć interfejs sieciowy ze strefy:

```bash
firewall-cmd --zone=[your-zone] --remove-interface=[your-network-device]
```

Aby utworzyc zupełnie nową strefę (zonę) z własnym zestawem reguł oraz sprawdzić że została ona utworzona poprawnie:

```bash
firewall-cmd --new-zone=[your-new-zone]
firewall-cmd --get-zones
```

## Zarządzanie portami

Dla niewtajemniczonych, porty (w tym kontekście) są wirtualnymi bramami przez które komputery łączą się ze sobą, to znaczy że mogą przez nie wysyłać i odbierać informacje. Możemy myśleć o nich trochę jak o fizycznych portach Ethernetowych czy USB w komputerze, z tą różnicą, że są niewidoczne no i że masz ich naraz aż 65.535 i możesz korzystać z nich wszystkich jednocześnie.

To znaczy Ty mógłbyś jeśli chcesz, bo ja nie zamierzam :)

Każdy port jest definiowany poprzez swój numer. Niektóre porty są zarezerwowane dla konkretnych usług i rodzaju przesyłanych nimi informacji. (Jednak to tylko pewna, mająca długą brodę :) konwencja i tradycyjne podejście do problemu - bo w zasadzie możemy przesyłać dowolne dane z wykorzystaniem dowolnego portu, nie ma tu żadnych ograniczeń stricte technologicznych to czysta konwencja i standaryzacja - przyp. markooff). Np. jeśli kiedykolwiek pracowałeś z Webserwerem i umieszczałeś na nim strony webowe będziesz pewnie dobrze kojarzył porty 80 i 443 które odpowiadają za przesył danych dla stron www.

Konkretnie port 80 odpowiada za transmisję danych z wykorzystaniem protokołu Hypertext Transfer Protocol (HTTP), natomiast port 443 jest zarezerwowany dla wymiany danych z użyciem protokołu Hypertext Transfer Protocol Secure (HTTPS). *

Z kolei port 22 jest przeznaczony dla Secure Shell protocol (SSH) który to pozwala na zdalne logowanie się do maszyny i zarządzanie nią z wykorzystaniem konsoli (zobacz też [nasz ktrótki samouczek](ssh_public_private_keys.md) w tym temacie). Świeżo postawiony zdalny serwer może zezwalać tylko na połączenia na porcie 22 dla SSH i nie ponadto.

Innymi przykładami są np. usługa FTP (standardowe porty 20 i 21), juz wspomniany tu SSH (port 22) i wiele wiele innych. Możesz także zdefiniować własne numery portów dla używania swojej aplikacji, którą zainstalujesz, a która nie ma standardowo przypisanych swoich 'własnych' numerów portów.

!!! NOTE "Uwaga: nie powinieneś zawsze bezpośrednio zarzadzać portami"

    Dla usług takich jak SSH, HTTP/S, FTP oraz tym podobnych, rekomenduje się dodawanie ich do strefy w Twoim firewallu za pomocą *usług*, a nie numerów portów. Pokaże Ci jak to zrobić w dalszej części materiału. Tym niemniej musisz wiedzieć jak zarządzać (otwierać i zamykać) porty ręcznie.

\* Dla absolutnych nowicjuszy - protokół HTTPS działa mniej więcej tak samo jak HTTP z dokładnością do szyfrowania zawartości.

### Komendy służące do zarządzania portami

Na potrzeby tej sekcji, będziemy używać `--zone=public`... i portu o numerze 9001 jako przykładowy, ponieważ to port powyżej numeru 9000 .

Aby wyświetlić listę wszystkich otwartych portów uruchamiamy:

```bash
firewall-cmd --list-ports
```

Aby dodać port do strefy `public` w firewallu używamy komendy:

```bash
firewall-cmd --zone=public --add-port=9001/tcp
```

!!! NOTE

    Troche o tym `/tcp` na końcu:
    
    Dopisek `/tcp` na końcu mówi firewallowi że połaczenie będzie nawiązywane za pomocą protokołu Transfer Control Protocol (TCP), który jest najczęściej używanym w połączeniach transmitujących istotne dane pomiędzy komputerami i serwerem.
    
    Alternatywy takie jak UDP (User Datagram Protocol - przyp. markooff) służą do celów testowych oraz przesyłu innych typów danych, co już wykracza poza zakres tematyki tego dokumentu. (Tak naprawdę protokół UDP wykorzystywany jest głównie do transmisji strumieniowych np. głosowych albo w zastosowaniach takich jak gry sieciowe w których niewielki koszt transmisji i związane z tym opóźnienie ma o wiele większe znaczenie niż weryfikacja i konsystencja danych - przyp. markooff)
    	Aby zorientować się którego protokołu do transmisji danych będzie wymagać aplikacja którą właśnie chcesz dodać zapoznaj się z jej dokumentacją.  Zapoznaj się z dokumentacją dowolnej aplikacji lub usługi, dla której chcesz otworzyć port.

Aby usunąć port, po prostu użyjemy poprzedniej komendy, z jedną zmianą:

```bash
firewall-cmd --zone=public --remove-port=9001/tcp
```

## Zarządzanie usługami (services)

Usługi, jak można sobie wyobrazić, to dość mocno ustandaryzowane programy które są uruchamiane na Twoim komputerze. `firewalld` jest skonfigurowany tak aby był w stanie obłużyć większość standardowych usług kiedy będzie to potrzebne.

Zarządzanie poprzez dodawanie usług to najlepsza z dróg otwierania portów dla takich typowych usług a także o wiele więcej.

* HTTP oraz HTTPS: dla serwerów webowych
* FTP: do przenoszenia plików (tradycyjną drogą)
* SSH: do zdalnego zarządzania maszynami a także przenoszenia plików (w nowoczesny, bezpieczny sposób)
* Samba: do udostępniania plików w sieciach Windows (opartych o protokół SMB - przyp. markooff)

!!! WARNING

    ** Nigdy nie usuwaj ani nie wyłączaj usługi SSH z konfiguracji firewalla zdalnego serwera !**
    
    Pamietaj że to SSH jest tym co pozwala Ci łączyć się zdalnie ze swoim serwerem.  Dopóki nie zapewnisz sobie innej metody fizycznego dostępu do niego albo do jego powłoki (shella) (np. poprzez panel kontrolny zarządzania jaki oferuje często firma hostingowa) usuwanie dostępu via SSH odetnie Cię od serwera na dobre. panelu sterowania dostarczonego przez hosta), usunięcie usługi SSH spowoduje zablokowanie Cię na stałe.
    
    Jedyne co Ci wtedy pozostanie to skontaktować się z działem wsparcia firmy w której wynajmujesz serwer, (i albo odtworzenie poprzedniego jego stanu z backupu, o ile go posiadasz/posiadają - przyp. markooff) albo reinstalacja systemu operacyjnego.

## Komendy do zarządzania usługami

Aby wyświetlić listę wszystkich dostępnych usług, które mógłbyś chcieć potencjalnie dodać do konfiguracji Twojego firewalla uruchom:

```bash
firewall-cmd --get-services
```

Aby zobaczyc listę usług, które zostały już dodane wykonaj:

```bash
firewall-cmd --list-services
```

Aby dodac usługe i otworzyć dla niej port (np. HTTP w strefie `public`) uruchom:

```bash
firewall-cmd --zone=public --add-service=http
```

Aby usunąć usługę i zamknąć port którego używała, zmień jedno słowo:

```bash
firewall-cmd --zone=public --remove-service=http
```

!!! NOTE "Uwaga: Możesz dodawać własne, zdefiniowane przez siebie usługi"

    Oraz skonfigurować zachowanie się firewalla dla nich. Ale jest to już dość skomplikowana sprawa. Na początek trzeba poznać dobrze `firewalld`.

## Oraniczanie dostępu

Powiedzmy że posiadamy serwer i że nie chcemy wystawiać go na świat dostępnym dla wszystkich. Chcemy określić kto dokładnie ma mieć dostęp do niego przez SSH a komu pokażemy nasze prywatne strony czy udostępnimy aplikacje. Możemy śmiało to zrobić.

W zasadzie, jest caly szereg sposobów żeby tego dokonać. Możemy po wziąć którąś z bardziej restruykcyjnych stref (zon), przypisać do niej interfejs sieciowy, potem dodać do niej usługę SSH tak, jak to pokazałem powyżej, a na koniec whitelistować nasz publiczny adres IP (z którego będziemy się łączyć do serwera), tak jak w przykładzie poniżej:

```bash
firewall-cmd --permanent --zone=trusted --add-source=192.168.1.0/24 [< tu wprowadź swój zakres adresacji IP]
```

Możemy, zamiast podawać pojedynczy adres, wprowadzić od razu cały zakres:

```bash
firewall-cmd --permanent --zone=trusted --add-source=192.168.1.0 [< tu wprowadź swój adres IP]
```

Aby odwrócić działanie komendy po prostu w poleceniu zamieniamy `--add-source` na `--remove-source` .

W innym przypadku, kiedy zarządzamy serwerem z usługą WWW która jest dostępna publicznie, a tylko chcemy otworzyć dostęp dla SSH dla jednego konkretnego adresu IP lub niewielkiego zakresu adresów IP, również będziemy mieli parę rozwiązań. W każdym przypadku podstawowy interfejs sieciowy jest już przypisany do strefy (zony) `public` .

Jako pierwsze, możemy użyć koncepcji tzw. "rich rule" w naszej publicznej strefie. Będzie to wygladać tak:

```bash
# firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" source address="192.168.1.0/24" service name="ssh" accept'
```

Kiedy już utworzyliśmy naszą "rich rule" *nie twórzmy* dalszych wpisów z opcją `--permanent` ale najpierw sprawdźmy czy wszystko działa poprawnie. (chodzi tu o dokonywanie dalszych modyfikacji tymczasowo, bo wtedy w przypadku błędu będziemy łatwo mogli cofnąć błędne wpisy i przywrócić poprawną konfigurację - przyp. markooff). Usuńmy teraz tymczasowo usługę SSH z konfiguracji strefy `public` i sprawdźmy czy mimo to możemy się nadal połączyć z do naszego serwera przez SSH (otwierając nowe połączenie bez zamyhkania aktualnie działającego! - przyp. markooff).

Na tą chwilę nasza konfiguracja powinna wyglądać tak:

```bash
your@server ~# firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: wlp3s0
  sources:
  services: cockpit dhcpv6-client
  ports: 80/tcp 443/tcp
  protocols:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
        rule family="ipv4" source address="192.168.1.0/24" service name="ssh" accept
```


Następnie, użyjmy kolejnej strefy (zony) (możemy mieć ich aktywnych więcej niż jedną naraz). Ponieważ posiadamy interfejs sieciowy przypięty do strefy `public` , aktywujemy kolejną strefę (np. `trusted`) i dodajemy jej źródłowy adres sieciowy (lub zakres adresów) tak jak to było pokazane powyżej. Następnie dodajemy usługę SSH do strefy `trusted` i jednocześnie usuwamy ją ze strefy `public` .

Po tych zmianach nasza konfiguracja bedzie wygladać mniej więcej tak:

```bash
your@server ~# firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: wlp3s0
  sources:
  services: cockpit dhcpv6-client
  ports: 80/tcp 443/tcp
  protocols:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
your@server ~# firewall-cmd --list-all --zone=trusted
trusted (active)
  target: default
  icmp-block-inversion: no
  interfaces:
  sources: 192.168.0.0/24
  services: ssh
  ports:
  protocols:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

Jeżeli po tych zmianach straciliśmy możliwość połaczenia się z naszym serwerem, wykonajmy jego zdalny restart (korzystając z panelu zarządzania VPSem - większość firm hostingowych udostępnia tego typu narzędzie) i próbujmy ponownie poprawić naszą konfigurację.

!!! WARNING

    Powyższa metoda zadziała TYLKO w sytuacji kiedy dysponujemy stałym adresem IP!
    
    Jeżeli nasz ISP nie udostępnia swoim klientom STATYCZNYCH ZEWNĘTRZNYCH adresów IP, a zamiast tego korzysta z tzw. dynamicznej rotacji adresacji IP (np. podczas kazdego restartu modemu), nie używaj tej metody, a przynajmniej (nie dla usługi SSH) dopóki nie pozbędziesz się tego problemu (np. nie wynegocjujesz, za dopłatą, zewnętrznego STATYCZNEGO adresu IP dla siebie - znaczna ilość ISP oferuje takie możliwości - przyp. markooff). Inaczej na trwałe odetniesz się od swojego serwera. Inaczej na trwałe odetniesz się od swojego serwera. 
    
    Inną możliwością jest łączenie się z internetem za pośrednictwem usługi VPN, która będzie oferować na wyjściu statyczny publiczny adres IP i nigdy go nie zmieni.
    
    W międzyczasie [zainstaluj i skonfiguruj fail2ban](https://wiki.crowncloud.net/?How_to_Install_Fail2Ban_on_RockyLinux_8), który pomoże Ci poradzić sobie z atakami typu brute-force.
    
    Oczywiście w sieci lokalnej którą kontrolujesz (i gdzie możesz nadawać każdej maszynie osobny adres IP ręcznie)(albo gdzie masz uruchomiony przez siebie serwer DHCP który kontrolujesz - przyp. markooff ), możesz używac tych reguł do woli.

## Uwagi końcowe

I to w zasadzie byłoby już wszystko jeśli chodzi o podstawy konfiguracji `firewalld` jeśli chcesz pogłębić swoją wiedzę w kwestii filtrowania ruchu polecam Ci [oficjalną dokumentację do `firewalld`](https://firewalld.org/documentation/). Możesz również znaleźć w internecie szeroką gamę manuali do poszczególnych aplikacji które pomogą Ci skonfigurować Twój firewall z pomocą tych aplikacji.

A dla Was, fanów `iptables` (jeśli już dotarliście tak daleko...), \[mamy również samouczek\] (firewalld.md) prezentujący różnice w podejściu i działaniu `firewalld` oraz `iptables`. Ten materiał może pomóc Wam zorientować się czy chcecie pozostać przy uzywaniu `firewalld` czy, może, cofnąć się wstecz i podążać według Starej Szkoły<sup>(TM)</sup> (czyli operować komendami bardziej niskopoziomowymi ale i znacznie potężniejszymi, typu `iptables`, `eftables` czy `nftables` - przyp. markooff). W takim wypadku będzie jeszcze wiele do powiedzenia .

## Konkluzja

I to by już było wszystko jeśli chodzi o `firewalld` i podstawy jego konfiguracji. Ostatnia rada: działajcie z przemyśleniem, experymentujcie ale z ostrożnością, ale - najwazniejsze - nigdy nie tworzcie żadnych reguł z parametrem `--permanent` dopóki naprawdę nie będziecie w 100% pewni jak one zadziałają!

I bawcie się przy tym dobrze. Kiedy już opanujecie dobrze podstawy tak naprawdę konfiguracja każdego przeciętnego firewalla nie powinna Wam zająć więcej niż 5-10 minut.
