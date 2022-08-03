---
title: Klucz publiczny i prywatny SSH
author: Steven Spencer
contributors: Ezequiel Bruni, markooff
tested with: 8.5
tags:
  - security
  - ssh
  - keygen
---

# Klucze Publiczne i Prywatne SSH

## Wymagania

* Pewnej znajomości zarządzania systemem z poziomu konsoli
* Serwera oraz maszyny klienckiej z systemem Rocky Linux z zainstalowanym pakietem *openssh*
    * OK, z technicznego punktu widzenia, ta metoda powinna działać na każdej dystrybucji Linuxa z zainstalowanym pakietem *openssh*
* Opcjonalnie - znajomość systemu uprawnień w systemie Linux

## Wstęp

SSH jest protokołem używanym do zdalnego łączenia się z jednej maszyny do drugiej, zwykle z poziomu konsoli. Z pomocą SSH możesz zdalnie wykonywać polecenia na serwerach, jak również przesyłać pliki, czyli w ogólności zarządzać wszystkimi swoimi zdalnymi maszynami z jednego miejsca.

Kiedy zarządzasz wieloma serwerami opartymi o Rocky Linux w wielu różnych lokalizacjach i chciałbyś zaoszczędzić trochę czasu przy łączeniu z nimi, SSH daje Ci możliwość użycia par kluczy prywatny-publiczny. Te pary kluczy ułatwiają logowanie się i pozwalają zaoszczędzić czas.

Ten dokument przeprowadzi Cię przez proces utworzenia pary kluczy oraz skonfigurowania Twoich serwerów do korzystania z nich.

## Proces generowania kluczy

Poniższe polecenia będą uruchamiane wprost w konsoli Twojej stacji roboczej:

```
ssh-keygen -t rsa
```

co wyświetli następujący wynik:

```
Generating public/private rsa key pair.
Enter file in which to save the key (/root/.ssh/id_rsa):
```

Nacisnij enter aby zaakceptować domyślną lokalizację plików. System zapyta Cię:

`Enter passphrase (empty for no passphrase):`

Więc po prostu naciśnij Enter tutaj. Ponownie zostaniemy zapytani o hasło:

`Enter same passphrase again:`

A więc naciskamy Enter po raz ostatni.

Powinieneś teraz już mieć parę kluczy RSA, prywatny oraz publiczny, w Twoim katalogu .ssh .

```
ls -a .ssh/
.  ..  ..
```

Teraz wyślemy nasz klucz publiczny (id_rsa.pub) na każdy z serwerów z którymi będziemy się łączyć. Ale najpierw zanim to zrobimy upewnijmy się że mamy dostęp przez SSH do kazdej z tych maszyn. W naszym przykładzie posłużymy się tylko trzema serwerami.

Jeśli chodzi o łączenie się z serwerami za pomocą SSH to można to zrobić albo po adresie IP albo przez nazwę (DNS), w naszym przykładzie będziemy używać nazwy DNS. Nasze przykładowe serwry będą obsługiwać usługi www, mail oraz portal. Do każdego z serwerów będziemy się SSH-ować (prawdziwi nerdzi uwielbiają używać terminu SSH jako czasownik) i zostawiać otwarte okna konsol:

`ssh -l root web.ourourdomain.com`

Zakłóżmy że możemy się bez problemów zalogować na trzy maszyny, a zatem następny krok to porozsyłanie naszego publicznego klucza po wszystkich serwerach.

`scp .ssh/id_rsa.pub root@web.ourourdomain.com:/root/`

Powtarzamy ten krok dla każdego serwera.

Teraz w kazdym z otwartych okien terminali (konsol) możemy zobaczyć nasze skopiowane pliki za pomocą komendy:

`ls -a | grep id_rsa.pub`

Jeśli tak jest (jeśli widzimy te pliki) to teraz możemy dodać nasze klucze do plików *authorized_keys* znajdujących się w katalogu .ssh konta na które się łączymy na każdym serwerze (przypomnę, że dla potrzeb tego materiału jest to konto root'a). Jeśli nie ma tam pliku *authorized_keys* tworzymy go. Na każdym z serwerów wpisz to polecenie:

`ls -a .ssh`

!!! attention "Ważne!"

    Upewnij się że zapoznałeś się z poniższymi instrukcjami dokładnie. Jeśli nie jesteś pewien kolejnego kroku, zrób najpierw kopię *authorized_keys* (jeśli istnieje) na kazdym serwerze zanim zrobisz krok dalej.

Jeśli nie powyższa komenda nie wyświetli pliku *authorized_keys* wtedy tworzymy go poleceniem (wykonanym w katalogu _/root_ ):

`cat id_rsa.pub > .ssh/authorized_keys`

A jeśli _authorized_keys_ już istnieje wtedy tylko dodajemy nasz klucz do listy zapisanych w tym pliku poleceniem:

`cat id_rsa.pub >> .ssh/authorized_keys`

Kiedy już klucze będą dodane do istniejących plików _authorized_keys_ bądź pliki _authorized_keys_ zostaną przy tej okazji utworzone spróbujmy zalogować się poprzez SSH do naszych serwerów. Jeśli wszystko przebiegło pomyślnie nie zostaniemy poproszeni o podanie hasła.

Kiedy już zweryfikujemy pomyśłnie nowy sposób logowania się, możemy bezpiecznie usunąć pliki id_rsa.pub z katalogu _/root_ każdego z serwerów poleceniem:

`rm id_rsa.pub`

## Zabezpieczenie kluczy SSH i pliku authorized_keys

Upewnijmy się że na każdym z serwerów zostaną ustawione następujące prawa dostępu:

`chmod 700 .ssh/` 
`chmod 600 .ssh/authorized_keys`
