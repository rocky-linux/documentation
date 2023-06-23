---
title: Bash - Перевірка знань
author: Antoine Le Morvan
contributors: Steven Spencer
tested_with: 8.5
tags:
  - освіта
  - сценарій bash
  - bash
---

# Bash - Перевірка знань

:heavy_check_mark: Кожне замовлення має повертати код повернення в кінці свого виконання:

- [ ] Так
- [ ] Ні

:heavy_check_mark: Код повернення 0 вказує на помилку виконання:

- [ ] Так
- [ ] Ні

:heavy_check_mark: Код повернення зберігається у змінній `$@`:

- [ ] Так
- [ ] Ні

:heavy_check_mark: Команда test дозволяє:

- [ ] Перевірити тип файлу
- [ ] Перевірити змінну
- [ ] Порівняти числа
- [ ] Порівняти вміст 2 файлів

:heavy_check_mark: Команда `expr`:

- [ ] З’єднує 2 рядки символів
- [ ] Виконує математичні дії
- [ ] Відображає текст на екрані

:heavy_check_mark: Синтаксис наведеної нижче умовної структури здається вам правильним? Поясніть чому.

```
if command
    command if $?=0
else
    command if $?!=0
fi
```

- [ ] Так
- [ ] Ні

:heavy_check_mark: Що означає такий синтаксис: `${variable:=value}`

- [ ] Відображає значення заміни, якщо змінна порожня
- [ ] Відображення значення заміни, якщо змінна не порожня
- [ ] Призначає нове значення змінній, якщо вона порожня

:heavy_check_mark: Синтаксис наведеної нижче умовної альтернативної структури здається вам правильним? Поясніть чому.

```
case $variable in
  value1)
    commands if $variable = value1
  value2)
    commands if $variable = value2
  *)
    commands for all values of $variable != of value1 and value2
    ;;
esac
```

- [ ] Так
- [ ] Ні

:heavy_check_mark: Що з наведеного не є структурою для циклу?

- [ ] while
- [ ] until
- [ ] loop
- [ ] for
