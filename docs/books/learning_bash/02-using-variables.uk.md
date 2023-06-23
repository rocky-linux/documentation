---
title: Bash - використання змінних
author: Antoine Le Morvan
contributors: Steven Spencer
tested_with: 8.5
tags:
  - освіта
  - сценарій bash
  - bash
---

# Bash - використання змінних

У цьому розділі ви дізнаєтеся, як використовувати змінні у ваших сценаріях bash.

****

**Цілі**: В цьому розділі ви дізнаєтеся як:

:heavy_check_mark: Зберігати інформацію для подальшого використання;  
:heavy_check_mark: Видаляти та блокувати змінні;  
:heavy_check_mark: Використовувати змінні середовища;  
:heavy_check_mark: Замінювати команди.

:checkered_flag: **linux**, **сценарій**, **bash**, **змінна**

**Знання**: :star: :star:  
**Складність**: :star:

**Час для читання**: 10 хвилин

****

## Зберігання інформації для подальшого використання

Як і в будь-якій мові програмування, сценарій оболонки використовує змінні. Вони використовуються для зберігання інформації в пам’яті для повторного використання під час виконання сценарію.

Змінна створюється, коли отримує свій вміст. Вона залишається дійсною до кінця виконання сценарію або за чітким запитом автора сценарію. Оскільки сценарій виконується послідовно від початку до кінця, неможливо викликати змінну до її створення.

Вміст змінної можна змінити під час сценарію, оскільки змінна продовжує існувати до завершення сценарію. Якщо вміст видаляється, змінна залишається активною, але нічого не містить.

Поняття типу змінної в сценарії оболонки можливо, але використовується дуже рідко. Вмістом змінної завжди є символ або рядок.

```
#!/usr/bin/env bash

#
# Author : Rocky Documentation Team
# Date: March 2022
# Version 1.0.0: Save in /root the files passwd, shadow, group, and gshadow
#

# Global variables
FILE1=/etc/passwd
FILE2=/etc/shadow
FILE3=/etc/group
FILE4=/etc/gshadow

# Destination folder
DESTINATION=/root

# Clear the screen
clear

# Launch the backup
echo "Starting the backup of $FILE1, $FILE2, $FILE3, $FILE4 to $DESTINATION:"

cp $FILE1 $FILE2 $FILE3 $FILE4 $DESTINATION

echo "Backup ended!"
```

Цей сценарій використовує змінні. Ім'я змінної має починатися з літери, але може містити будь-яку послідовність літер або цифр. За винятком підкреслення "_", спеціальні символи використовувати не можна.

Відповідно до домовленості, змінні, створені користувачем, мають назву в нижньому регістрі. Цю назву слід вибирати обережно, щоб вона не була надто ухильною чи надто складною. Однак змінну можна назвати великими літерами, як у цьому випадку, якщо це глобальна змінна, яку програма не повинна змінювати.

Символ `=` призначає вміст змінній:

```
variable=value
rep_name="/home"
```

Перед або після знака `=` немає пробілу.

Після створення змінної її можна використовувати, додавши до неї префікс долара $.

```
file=file_name
touch $file
```

Рекомендується захищати змінні лапками, як у прикладі нижче:

```
file=file name
touch $file
touch "$file"
```

Оскільки вміст змінної містить пробіл, перший `дотик` створить 2 файли, а другий `дотик` створить файл, ім’я якого міститиме пробіл.

Щоб ізолювати назву змінної від решти тексту, ви повинні використовувати лапки або дужки:

```
file=file_name
touch "$file"1
touch ${file}1
```

**Рекомендується систематичне використання фігурних дужок.**

Використання апострофів перешкоджає інтерпретації спеціальних символів.

```
message="Hello"
echo "This is the content of the variable message: $message"
Here is the content of the variable message: Hello
echo 'Here is the content of the variable message: $message'
Here is the content of the variable message: $message
```

## Видалення та блокування змінних

Команда `unset` дозволяє видалити змінну.

Приклад:

```
name="NAME"
firstname="Firstname"
echo "$name $firstname"
NAME Firstname
unset firstname
echo "$name $firstname"
NAME
```

Команда `readonly` або `typeset -r` блокує змінну.

Приклад:

```
name="NAME"
readonly name
name="OTHER NAME"
bash: name: read-only variable
unset name
bash: name: read-only variable
```

!!! Примітка

    `set -u` на початку сценарію зупинить виконання сценарію, якщо використовуються неоголошені змінні.

## Використання змінних середовищ

**Змінні середовища** та **системні змінні** – це змінні, які використовуються системою для її роботи. За згодою імена пишуться великими літерами.

Як і всі змінні, вони можуть відображатися під час виконання сценарію. Навіть якщо це категорично не рекомендується, їх також можна змінити.

Команда `env` відображає всі використані змінні середовища.

Команда `set` відображає всі використані системні змінні.

Серед десятків змінних середовища розглянемо деякі цікаві для використання в сценарії оболонки:

| Змінні                         | Опис                                                               |
| ------------------------------ | ------------------------------------------------------------------ |
| `HOSTNAME`                     | Ім'я хоста машини.                                                 |
| `USER`, `USERNAME` і `LOGNAME` | Ім'я користувача, підключеного до сеансу.                          |
| `PATH`                         | Шлях для пошуку команд.                                            |
| `PWD`                          | Поточний каталог, оновлюється щоразу, коли виконується команда cd. |
| `HOME`                         | Каталог входу.                                                     |
| `$$`                           | Ідентифікатор процесу виконання сценарію.                          |
| `$?`                           | Код повернення останньої виконаної команди.                        |

Команда `export` дозволяє експортувати змінну.

Змінна дійсна лише в середовищі процесу сценарію оболонки. Щоб **дочірні процеси** сценарію могли знати змінні та їхній вміст, їх потрібно експортувати.

Зміна змінної, експортованої в дочірньому процесі, не може бути відстежена до батьківського процесу.

!!! примітка

    Без будь-яких параметрів команда `export` відображає назву та значення експортованих змінних у середовищі.

## Заміна команд

Можна зберегти результат команди в змінній.

!!! Примітка

    Ця операція дійсна лише для команд, які повертають повідомлення в кінці свого виконання.

Синтаксис для підвиконання команди наступний:

```
variable=`command`
variable=$(command) # Preferred syntax
```

Приклад:

```
$ day=`date +%d`
$ homedir=$(pwd)
```

З огляду на все, що ми щойно бачили, наш сценарій резервного копіювання може виглядати наступним чином:

```
#!/usr/bin/env bash

#
# Author : Rocky Documentation Team
# Date: March 2022
# Version 1.0.0: Save in /root the files passwd, shadow, group, and gshadow
# Version 1.0.1: Adding what we learned about variables
#

# Global variables
FILE1=/etc/passwd
FILE2=/etc/shadow
FILE3=/etc/group
FILE4=/etc/gshadow

# Destination folder
DESTINATION=/root

## Readonly variables
readonly FILE1 FILE2 FILE3 FILE4 DESTINATION

# A folder name with the day's number
dir="backup-$(date +%j)"

# Clear the screen
clear

# Launch the backup
echo "****************************************************************"
echo "     Backup Script - Backup on ${HOSTNAME}                      "
echo "****************************************************************"
echo "The backup will be made in the folder ${dir}."
echo "Creating the directory..."
mkdir -p ${DESTINATION}/${dir}

echo "Starting the backup of ${FILE1}, ${FILE2}, ${FILE3}, ${FILE4} to ${DESTINATION}/${dir}:"

cp ${FILE1} ${FILE2} ${FILE3} ${FILE4} ${DESTINATION}/${dir}

echo "Backup ended!"

# The backup is noted in the system event log:
logger "Backup of system files by ${USER} on ${HOSTNAME} in the folder ${DESTINATION}/${dir}."
```

Запуск нашого сценарію резервного копіювання:

```
$ sudo ./backup.sh
```

дасть нам:

```
****************************************************************
     Backup Script - Backup on desktop                      
****************************************************************
The backup will be made in the folder backup-088.
Creating the directory...
Starting the backup of /etc/passwd, /etc/shadow, /etc/group, /etc/gshadow to /root/backup-088:
Backup ended!
```
