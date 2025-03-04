---
title: Тунель IPv6 Hurricane Electric
author: Neel Chauhan
contributors: Steven Spencer
tested_with: 9.5
tags:
  - мережа
---

# Тунель IPv6 Hurricane Electric

IPv6 не потребує представлення, але, якщо ви не знаєте, це заміна більш популярного протоколу IPv4, який використовує 128-бітні шістнадцяткові адреси замість 32-бітних десяткових.

[Hurricane Electric](https://he.net) є постачальником послуг Інтернету. Серед інших своїх послуг Hurricane Electric запускає безкоштовну послугу [Tunnel Broker](https://tunnelbroker.net/), щоб забезпечити з’єднання IPv6 за мережами лише IPv4.

## Вступ

Завдяки вичерпанню IPv4 виникла потреба в розширеному просторі IP-адресації у вигляді IPv6. Однак багато мереж все ще не підтримують IPv6 через повсюдне поширення трансляції мережевих адрес (NAT). Через це Hurricane Electric пропонує тунелі IPv6.

## Передумови

- [Безкоштовний тунель Hurricane Electric IPv6](https://tunnelbroker.net/)

- Сервер Rocky Linux із загальнодоступною IP-адресою та нефільтрованим протоколом керуючих повідомлень Інтернету (ICMP).

## Отримання тунелю IPv6

Спочатку створіть обліковий запис на [tunnelbroker.net](https://tunnelbroker.net/).

Якщо у вас є обліковий запис, виберіть **Create Regular Tunnel** на бічній панелі **User Functions**:

![HE.net sidebar](../images/henet_1.png)

Потім введіть свою загальнодоступну адресу IPv4, виберіть розташування кінцевої точки та натисніть **Create Tunnel**.

## Налаштування тунелю IPv6

Хороша новина полягає в тому, що для тунелю IPv6 потрібна лише одна команда:

```bash
nmcli connect add type ip-tunnel ifname he-sit mode sit remote IPV4_SERVER ipv4.method disabled ipv6.method manual ipv6.address IPV6_CLIENT ipv6.gateway IPV6_SERVER
```

Замініть наступне деталями з порталу Hurricane Electric:

- `IPV4_SERVER` з **IPv4-адресою сервера**
- `IPV6_SERVER` з **IPv6-адресою сервера**
- `IPV6_CLIENT` з **IPv6-адресою клієнта**
