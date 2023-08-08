---
title: Швидкий метод
author: Lukas Magauer
contributors: Steven Spencer
tested_with: 8.6, 9.0
tags:
  - документація
  - локальний сервер
---

# Вступ

Ви можете створити систему документації локально без Docker або LXD, якщо хочете. Однак якщо ви вирішите використовувати цю процедуру, майте на увазі, що якщо ви багато кодуєте на Python або використовуєте Python локально, найбезпечніше створити віртуальне середовище Python, [описане тут](https://docs.python.org/3/library/venv.html). Це захищає всі ваші процеси Python один від одного, що рекомендовано. Якщо ви вирішите використовувати цю процедуру без віртуального середовища Python, пам’ятайте, що ви ризикуєте.

## Процедура

* Клонуйте репозиторій docs.rockylinux.org:

```
git clone https://github.com/rocky-linux/docs.rockylinux.org.git
```

* Після завершення перейдіть до каталогу docs.rockylinux.org:

```
cd docs.rockylinux.org
```

* Тепер клонуйте сховище документації за допомогою:

```
git clone https://github.com/rocky-linux/documentation.git docs
```

* Далі встановіть файл requirements.txt для mkdocs:

```
python3 -m pip install -r requirements.txt
```

* Нарешті запустіть сервер mkdocs:

```
mkdocs serve
```

## Висновок

Це забезпечує швидкий і простий спосіб запуску локальної копії документації без Docker або LXD. Якщо ви обираєте цей метод, вам справді слід налаштувати віртуальне середовище Python, щоб захистити інші процеси Python.
