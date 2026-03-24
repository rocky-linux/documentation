---
title: Метод Python VENV
author: Franco Colussi
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 8.7, 9.1, 9.4
tags:
  - mkdocs
  - тестування
  - документація
---

# MkDocs (віртуальне середовище Python)

## Вступ

Одним із аспектів процесу створення документації для Rocky Linux є перевірка правильності відображення нового документа перед публікацією.

Метою цього посібника є надання деяких порад щодо виконання цього завдання в локальному середовищі python, призначеному виключно для цієї мети.

Документація для Rocky Linux написана з використанням мови Markdown, яка зазвичай конвертується в інші формати. Markdown має чистий синтаксис і особливо добре підходить для написання технічної документації.

У нашому випадку документація конвертується в `HTML` за допомогою застосунку на Python, який займається створенням статичного сайту. Розробники використовують програму [MkDocs](https://www.mkdocs.org/).

Одна з проблем, яка виникає під час розробки програми python, полягає в тому, щоб ізолювати примірник python, який використовується для розробки, від системного інтерпретатора. Ізоляція запобігає несумісності між модулями, необхідними для встановлення програми Python, і тими, які встановлені на хост-системі.

Вже існують чудові посібники, які використовують **контейнери** для ізоляції інтерпретатора Python. Ці посібники, однак, передбачають знання різних методів контейнеризації.

У цьому посібнику для розділення використовується модуль `venv`, що постачається з пакета _python_ Rocky Linux. Цей модуль доступний у всіх нових версіях _Python_, починаючи з версії 3.6. Це безпосередньо досягне ізоляції інтерпретатора Python у системі без необхідності встановлювати та налаштовувати нові "**системи**".

### Вимоги

- запущена копія Rocky Linux
- пакет _python_ встановлено правильно
- знайомство з командним рядком
- активне підключення до Інтернету

## Підготовка середовища

Середовище надає кореневу папку, що містить два необхідні репозиторії Rocky Linux GitHub і папку, де відбувається ініціалізація та запуск вашої копії python у віртуальному середовищі.

Спершу створіть папку, яка міститиме все інше, а також контекстно створіть папку **env**, де запускатиметься MkDocs:

```bash
mkdir -p ~/lab/rockydocs/env
```

### Віртуальне середовище Python

Щоб створити власну копію Python, де працюватиме MkDocs, використовуйте спеціально розроблений для цієї мети модуль python `venv`. Це дозволяє створити віртуальне середовище, похідне від встановленого в системі, повністю ізольоване та незалежне.

Це дозволить нам мати копію інтерпретатора в окремій папці лише з пакетами, які потрібні `MkDocs` для запуску документації Rocky Linux.

Перейдіть до щойно створеної папки (_rockydocs_) і створіть віртуальне середовище за допомогою:

```bash
cd ~/lab/rockydocs/
python -m venv env
```

Ця команда заповнить папку **env** серією папок і файлів, які імітують дерево _python_ вашої системи, показано тут:

```text
env/
├── bin
│   ├── activate
│   ├── activate.csh
│   ├── activate.fish
│   ├── Activate.ps1
│   ├── pip
│   ├── pip3
│   ├── pip3.11
│   ├── python -> /usr/bin/python
│   ├── python3 -> python
│   └── python3.11 -> python
├── include
│   └── python3.11
├── lib
│   └── python3.11
├── lib64 -> lib
└── pyvenv.cfg
```

Як бачите, інтерпретатор Python, який використовується віртуальним середовищем, все ще є тим самим, що доступний у системі `python -> /usr/bin/python`. Процес віртуалізації дбає лише про ізоляцію вашого екземпляра.

#### Активація віртуального середовища

Серед файлів, перелічених у структурі, є кілька файлів з назвою **activate**, які служать цій меті. Суфікс кожного файлу вказує на відповідну _оболонку_.

Активація відокремлює цей екземпляр python від екземпляра системи та дозволяє нам виконувати розробку документації без втручання. Щоб активувати його, перейдіть до папки _env_ та виконайте команду:

```bash
[rocky_user@rl9 rockydocs]$ cd ~/lab/rockydocs/env/
[rocky_user@rl9 env]$ source ./bin/activate
```

Команду _activate_ було виконано без будь-якого суфікса, оскільки вона стосується оболонки _bash_, оболонки Rocky Linux за замовчуванням. На цьому етапі ваш _запит оболонки_ має виглядати так:

```bash
(env) [rocky_user@rl9 env]$
```

Як бачите, початкова частина _(env)_ вказує на те, що ви зараз перебуваєте у віртуальному середовищі. Перше, що потрібно зробити на цьому етапі, це оновити **pip**, менеджер модулів Python, який використовується для встановлення MkDocs. Для цього використовуйте команду:

```bash
python -m pip install --upgrade pip
```

```bash
python -m pip install --upgrade pip
Requirement already satisfied: pip in ./lib/python3.9/site-packages (21.2.3)
Collecting pip
  Downloading pip-23.1-py3-none-any.whl (2.1 MB)
    |████████████████████████████████| 2.1 MB 1.6 MB/s
Installing collected packages: pip
  Attempting uninstall: pip
    Found existing installation: pip 21.2.3
    Uninstalling pip-21.2.3:
      Successfully uninstalled pip-21.2.3
Successfully installed pip-23.1
```

#### Деактивація середовища

Щоб вийти з віртуального середовища, скористайтеся командою _deactivate_:

```bash
(env) [rocky_user@rl9 env]$ deactivate
[rocky_user@rl9 env]$
```

Як бачите, термінальний _запит_ повернувся до системного стану після деактивації. Завжди слід уважно перевіряти запит, перш ніж запускати встановлення _MkDocs_ та наступні команди. Позначення цього параметра запобіжить непотрібним та небажаним глобальним встановленням програм і пропущеним запускам `mkdocs serve`.

### Завантаження репозиторіїв

Now that you have seen how to create your virtual environment and how to manage it, you can move on to preparing everything needed.

Для реалізації локальної версії документації Rocky Linux потрібні два репозиторії: репозиторій документації [documentation](https://github.com/rocky-linux/documentation) та репозиторій структури сайту [docs.rockylinux.org](https://github.com/rocky-linux/docs.rockylinux.org). Downloading these is done from the Rocky Linux GitHub.

Почніть зі сховища структури сайту, яке ви клонуєте в папку **rockydocs**:

```bash
cd ~/lab/rockydocs/
git clone https://github.com/rocky-linux/docs.rockylinux.org.git
```

In this folder there are two files that you are going to use for building the local documentation. Це **mkdocs.yml**, файл конфігурації, який використовується для ініціалізації MkDocs, та **requirement.txt**, який містить усі пакети Python, необхідні для встановлення _mkdocs_.

When finished, you also need to download the documentation repository:

```bash
git clone https://github.com/rocky-linux/documentation.git
```

На цьому етапі ви матимете таку структуру в папці **rockydocs**:

```text
rockydocs/
├── env
├── docs.rockylinux.org
├── documentation
```

Схематично ви можете сказати, що папка **env** буде вашим механізмом _MkDocs_, який використовуватиме **docs.rockylinux.org** як контейнер для відображення даних, що містяться в **документації**.

### Установка MkDocs

Як зазначалося раніше, розробники Rocky Linux надають файл **requirement.txt**, який містить список модулів, необхідних для належного запуску користувацького екземпляра MkDocs. You will use the file to install everything needed in a single operation.

First you enter your python virtual environment:

```bash
[rocky_user@rl9 rockydocs]$ cd ~/lab/rockydocs/env/
[rocky_user@rl9 env]$ source ./bin/activate
(env) [rocky_user@rl9 env]$
```

Next, proceed to install MkDocs and all its components with the command:

```bash
(env) [rocky_user@rl9 env]$ python -m pip install -r ../docs.rockylinux.org/requirements.txt
```

To check that everything went well, you can call up the MkDocs help, which also introduces us to the available commands:

```bash
(env) [rocky_user@rl9 env]$ mkdocs -h
Usage: mkdocs [OPTIONS] COMMAND [ARGS]...

  MkDocs - Проектна документація з Markdown.

Опції:
  -V, --version  Показує версію та вихід.
  -q, --quiet    Попередження про тишу
  -v, --verbose  Вмикає докладний вивід
  -h, --help     Показує це повідомлення та виходить.

Команди:
   build Збирає документацію MkDocs
   gh-deploy Розгортає вашу документацію на сторінках GitHub
   new Створює новий проект MkDocs
   serve Запускає вбудований сервер розробки
```

If everything has worked as planned, you can exit the virtual environment and start preparing the necessary connections.

```bash
(env) [rocky_user@rl9 env]$ deactivate
[rocky_user@rl9 env]$
```

### Приєднання документації

Тепер, коли все доступно, вам потрібно підключити репозиторій документації до сайту-контейнера _docs.rockylinux.org_. Дотримуючись налаштувань, визначених у _mkdocs.yml_:

```yaml
docs_dir: 'docs/docs'
```

Спершу потрібно створити папку **docs** на **docs.rockylinux.org**, а потім у ній пов’язати свою папку **docs** зі сховища **документації**.

```bash
cd ~/lab/rockydocs/docs.rockylinux.org
mkdir docs
cd docs/
ln -s ../../documentation/docs/ docs
```

## Запуск локальної документації

You are ready to start the local copy of the Rocky Linux documentation. Спочатку вам потрібно запустити віртуальне середовище Python, а потім ініціалізувати ваш екземпляр MkDocs з налаштуваннями, визначеними в **docs.rockylinux.org/mkdocs.yml**.

This file has all the settings for localization, feature, and theme management.

Розробники інтерфейсу користувача сайту обрали тему [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/), яка надає багато додаткових функцій і налаштувань порівняно зі стандартною темою MkDocs.

Perform the following commands:

```bash
[rocky_user@rl9 rockydocs]$ cd ~/lab/rockydocs/env/
[rocky_user@rl9 rockydocs]$ source ./bin/activate
(env) [rocky_user@rl9 env]$ mkdocs serve -f ../docs.rockylinux.org/mkdocs.yml
```

You should see in your terminal the start of site construction. The display will show any errors found by MkDocs, such as missing links or other:

```text
INFO     -  Building documentation...
INFO     -  Adding 'de' to the 'plugins.search.lang' option
INFO     -  Adding 'fr' to the 'plugins.search.lang' option
INFO     -  Adding 'es' to the 'plugins.search.lang' option
INFO     -  Adding 'it' to the 'plugins.search.lang' option
INFO     -  Adding 'ja' to the 'plugins.search.lang' option
...
...
INFO     -  Documentation built in 102.59 seconds
INFO     -  [11:46:50] Watching paths for changes:
            '/home/rocky_user/lab/rockydocs/docs.rockylinux.org/docs/docs',
            '/home/rocky_user/lab/rockydocs/docs.rockylinux.org/mkdocs.yml'
INFO     -  [11:46:50] Serving on http://127.0.0.1:8000/
```

Ваша копія сайту з документацією буде запущена після відкриття браузера за вказаною адресою [http://127.0.0.1:8000](http://127.0.0.1:8000). The copy perfectly mirrors the online site in functionality and structure, allowing you to assess the appearance and impact your page will have on the site.

MkDocs містить механізм для перевірки змін у файлах у папці, визначеній шляхом `docs_dir`, і вставлення нової сторінки або зміна існуючої в `documentation/docs` буде автоматично розпізнано та створить нову статичну збірку сайту.

Since the time for MkDocs to build the static site can be several minutes, the recommendation is to carefully review the page you are writing before saving or inserting it. This saves waiting for the site to build just because you forgot, for example, punctuation.

### Вихід із середовища розробки

Once the display of your new page meets your satisfaction, you can exit your development environment. Це передбачає спочатку вихід з _MkDocs_, а потім деактивацію віртуального середовища python. Щоб вийти з _MkDocs_, потрібно скористатися комбінацією клавіш ++ctrl++ + ++"C"++, і, як ви бачили вище, для виходу з віртуального середовища потрібно буде викликати команду `deactivate`.

```bash
...
INFO     -  [22:32:41] Serving on http://127.0.0.1:8000/
^CINFO     -  Shutting down...
(env) [rocky_user@rl9 env]$
(env) [rocky_user@rl9 env]$ deactivate
[rocky_user@rl9 env]$
```

### Створіть псевдонім для методу venv

You can create a bash alias to expedite the process of serving mkdocs with the venv method.

Виконайте наведену нижче команду, щоб додати псевдонім `venv` до вашого `.bash_profile`:

```bash
printf "# mkdocs alias\nalias venv='source $HOME/lab/rockydocs/env/bin/activate && mkdocs serve -f $HOME/lab/rockydocs/docs.rockylinux.org/mkdocs.yml'" >> ~/.bash_profile
```

Update the shell environment with your newly created alias:

```bash
source ~/.bash_profile
```

Тепер ви можете запустити `venv`, щоб створити локальний сайт розробки з mkdocs за допомогою методу venv:

```bash
venv
```

Щоб вийти з віртуального середовища, все одно потрібно виконати `deactivate`:

```bash
deactivate
```

## Висновки та заключні думки

Verifying your new pages in a local development site assures us that your work will always conform to the online documentation site, allowing us to contribute optimally.

Document compliance is also a great help to the curators of the documentation site, who then only have to deal with the correctness of the content.

In conclusion, you can say that this method allows for meeting the requirements for a "clean" installation of MkDocs without the need to resort to containerization.
