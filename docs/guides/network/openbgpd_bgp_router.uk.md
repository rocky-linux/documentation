---
title: Маршрутизатор OpenBGPD BGP
author: Neel Chauhan
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 9.3
tags:
  - мережа
---

# Маршрутизатор OpenBGPD BGP

## Вступ

Протокол Border Gateway Protocol (BGP) - це протокол маршрутизації, який об’єднує Інтернет. Таким чином ви можете переглядати цей документ незалежно від того, хто є вашим постачальником послуг Інтернету.

[OpenBGPD](http://openbgpd.org/) — це кросплатформна реалізація BGP [OpenBSD](https://www.openbsd.org/). Автор використовує його особисто у своїй мережі.

## Передумови

- Сервер, віртуальна машина або лабораторна мережа з підключенням BGP
- Номер AS із вашого [Регіонального Інтернет-реєстру](https://www.nro.net/about/rirs/)
- Власний або орендований блок IPv4 або IPv6
- Знання мережевого адміністрування

## Встановлення пакетів

Оскільки OpenBGPD немає в репозиторіях за замовчуванням, спочатку встановіть репозиторій EPEL (додаткові пакети для Enterprise Linux):

```bash
dnf install -y epel-release
```

Потім інсталюйте OpenBGPD

```bash
dnf install -y openbgpd
```

## Налаштування OpenBGPD

Почнемо зі свіжої конфігурації OpenBGPD:

```bash
rm /etc/bgpd.conf
touch /etc/bgpd.conf
chmod 0600 /etc/bgpd.conf
```

Далі додайте наступне до `/etc/bgpd.conf`:

```bash
AS YOUR_ASN
router-id YOUR_IPV4

listen on 127.0.0.1
listen on YOUR_IPV4
listen on ::1
listen on YOUR_IPV6
log updates
network IPV4_TO_ADVERTISE/MASK
network IPV6_TO_ADVERTISE/MASK

allow to ebgp prefix { IPV4_TO_ADVERTISE/MASK IPV6_TO_ADVERTISE/MASK }

neighbor PEER_IPV4 {
    remote-as               PEER_ASN
    announce IPv4           unicast
    announce IPv6           none
    local-address           YOUR_IPV4
}

neighbor PEER_IPV6 {
    remote-as               PEER_ASN
    announce IPv4           none
    announce IPv6           unicast
    local-address           YOUR_IPV6
}
```

Замініть наступну інформацію:

- **YOUR_ASN** з вашим номером AS.
- **YOUR_IPV4** з адресою IPv4 вашого сервера.
- **YOUR_IPV6** з адресою IPv6 вашого сервера.
- **PEER_ASN** із номером AS вашого провайдера.
- **PEER_IPV4** з IPv4-адресою вашого провайдера.
- **PEER_IPV6** з IPv6-адресою вашого провайдера.

Рядки вище означають наступне:

- Рядок `AS` містить ваш номер BGP AS.
- Рядок `router-id` містить ідентифікатор вашого маршрутизатора BGP. Це адреса IPv4, але може бути фіктивним значенням, якщо ви використовуєте BGP лише для IPv6.
- Рядок «listen on» вказує, які інтерфейси слухати. Ми повинні слухати всі інтерфейси, що розмовляють BGP.
- Рядки «network» додають мережі, які ми хочемо рекламувати.
- Рядок «allow to ebgp prefix» додає [RFC8212](https://datatracker.ietf.org/doc/html/rfc8212) сумісність для безпеки маршрутизації. Деякі хостингові компанії, такі як BuyVM, вимагають цього.
- Блоки `neighbor` визначають кожен вузол IPv4 та IPv6.
- Рядок `remote-as` вказує номер AS верхнього потоку.
- Рядок `announce IPv4` визначає, чи маємо ми оголошувати маршрути `unicast` IPv4 або `none`. Це має бути `none` для висхідного каналу IPv6.
- Рядок `announce IPv6` визначає, чи маємо ми оголошувати маршрути `unicast` IPv6 або `none`. Це має бути `none` для висхідного каналу IPv4.
- Рядок `local-address` — це адреса IPv4 або IPv6 вихідного каналу.

Деякі висхідні потоки можуть використовувати пароль MD5 або BGP multihop. Якщо це так, ваші «сусідні» блоки виглядатимуть так:

```bash
neighbor PEER_IPV4 {
    remote-as               PEER_ASN
    announce IPv4           unicast
    announce IPv6           none
    local-address           YOUR_IPV4
    multihop                2
    local-address           203.0.113.123
}

neighbor PEER_IPV6 {
    remote-as               PEER_ASN
    announce IPv4           none
    announce IPv6           unicast
    local-address           YOUR_IPV6
    multihop                2
    local-address           2001:DB8:1000::1
}
```

Вам потрібно буде ввімкнути IP-переадресацію, встановивши ці значення `sysctl`:

```bash
net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding = 1
```

Тепер ми повинні включити OpenBGPD і переадресацію:

```bash
sysctl -p /etc/sysctl.conf
systemctl enable --now bgpd
```

## Перевірка статусу BGP

Після ввімкнення OpenBGPD ви можете побачити статус BGP:

```bash
bgpctl show
```

Ви побачите результат:

```bash
Neighbor                   AS    MsgRcvd    MsgSent  OutQ Up/Down  State/PrfRcvd
BGP_PEER             PEER_ASN       164         68     0 00:32:04      0
```

Ви також можете переглянути оголошені маршрути BGP:

```bash
bgpctl show rib
```

Якщо працює правильно, ви повинні побачити таблицю маршрутизації BGP:

```bash
flags: * = Valid, > = Selected, I = via IBGP, A = Announced,
       S = Stale, E = Error
origin validation state: N = not-found, V = valid, ! = invalid
aspa validation state: ? = unknown, V = valid, ! = invalid
origin: i = IGP, e = EGP, ? = Incomplete

flags  vs destination          gateway          lpref   med aspath origin
AI*>  N-? YOUR_IPV4/24         0.0.0.0           100     0 i
AI*>  N-? YOUR_IPV6::/48       ::                100     0 i
```

## Висновок

Хоча спочатку BGP може здатися складним, як тільки ви його опануєте, ви зможете отримати свою частину таблиці маршрутизації Інтернету. Завдяки простоті OpenBGPD мати програмний маршрутизатор або сервер anycast ще простіше. Насолоджуйтесь!
