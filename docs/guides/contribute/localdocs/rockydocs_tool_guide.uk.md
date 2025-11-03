---
title: Метод сценарію RockyDocs
author: Wale Soyinka
contributors: Ganna Zhyrnova
update: 11-Sep-2025
---

# Запуск локальної копії веб-сайту docs.rockylinux.org за допомогою скрипта RockyDocs

У цьому документі описано використання автоматизованого скрипта `rockydocs.sh` для відтворення та запуску ідентичної робочій копії всього вебсайту docs.rockylinux.org на вашому локальному комп'ютері.

Скрипт RockyDocs пропонує сучасний автоматизований підхід, який усуває складність ручного налаштування, що зустрічається в інших методах, водночас забезпечуючи точну поведінку у виробничому середовищі.

Запуск локальної копії веб-сайту документації може бути корисним у таких випадках:

- Ви автор документації та хочете попередньо побачити, як саме ваш контент виглядатиме на вебсайті
- Ви хочете протестувати свій внесок локально в кількох версіях Rocky Linux (8, 9 та 10)
- Ви зацікавлені у вивченні або внеску в інфраструктуру документації
- Вам потрібно перевірити, чи правильно відображається ваш контент за допомогою селектора версій та навігації.

## Передумови

Скрипт RockyDocs автоматично обробляє більшість залежностей, але вам знадобиться:

- Система Linux або macOS (Windows з WSL2 має працювати)
- `git` встановлено на вашій системі
- Або Python 3.8+ з `pip`, АБО Docker (скрипт підтримує обидва середовища)
- Близько 2 Гб вільного місця на диску для повного середовища

Скрипт автоматично перевірить та встановить інші необхідні інструменти, такі як `mkdocs`, `mike` та різні плагіни.

## Налаштування середовища контенту

1. Перейдіть до каталогу, де ви хочете працювати з документацією Rocky Linux. Ми називатимемо це вашим каталогом робочої області.

    ```bash
    mkdir -p ~/rocky-projects
    cd ~/rocky-projects
    ```

2. Клонуйте офіційний репозиторій документації Rocky Linux:

    ```bash
    git clone https://github.com/rocky-linux/documentation.git
    cd documentation
    ```

   Тепер у вас є репозиторій контенту з автоматизованим скриптом `rockydocs.sh`.

## Параметри швидкого запуску зі скриптом RockyDocs

Скрипт RockyDocs пропонує кілька варіантів робочого процесу для задоволення потреб різних учасників. Оберіть варіант, який найкраще відповідає вашому робочому процесу написання та рецензування.

!!! note "Розуміння триетапного процесу"
    **Налаштування** (одноразове): Створює середовище збірки з віртуальним середовищем Python та встановлює інструменти MkDocs. Також встановлює мовну конфігурацію (мінімальну або повну), яка використовуватиметься для всіх наступних розгортань. Це створює окремий каталог робочої області для файлів збірки, зберігаючи при цьому чистоту вашого репозиторію контенту.

    **Deploy**: Збирає всі версії Rocky Linux (8, 9, 10) у повноцінний веб-сайт із версіями, використовуючи Майка та конфігурацію мови, встановлену під час налаштування. Це створює багатоверсійну структуру, яку ви бачите на docs.rockylinux.org.
    
    **Serve**: Запускає локальний веб-сервер для попереднього перегляду ваших змін. Статичний режим обслуговує попередньо створені файли (ідентичні робочим), тоді як режим реального часу забезпечує автоматичне перезавантаження під час редагування вмісту.

## Налаштування розташування робочого простору

За замовчуванням скрипт створює робочу область у `../rockydocs-workspaces/` відносно вашого репозиторію контенту. Ви можете налаштувати це розташування за допомогою опції `--workspace`:

```bash
# Use a custom workspace location
./rockydocs.sh --setup --venv --workspace ~/my-docs-workspace

# The script remembers your choice for future commands
./rockydocs.sh --deploy
./rockydocs.sh --serve --static
```

!!! tip "Переваги робочого простору"
    - Зберігає ваш репозиторій контенту чистим від файлів збірки
    - Дозволяє кільком проектам документації спільно використовувати одне й те саме середовище збірки
    - Автоматично зберігає налаштування робочого простору для майбутніх команд
    - Інтелектуально повторно використовує існуючі репозиторії для економії місця на диску та часу клонування

    

### Варіант 1: Попередній перегляд, ідентичний виробничому (рекомендовано для остаточного перегляду)

Цей варіант забезпечує той самий досвід, що й веб-сайт docs.rockylinux.org у реальному часі, що ідеально підходить для остаточного перегляду та тестування контенту.

1. **Налаштування середовища** (одноразове налаштування):

    ```bash
    # Basic setup (creates workspace in ../rockydocs-workspaces/)
    ./rockydocs.sh --setup --venv
    
    # Alternative: Custom workspace location
    ./rockydocs.sh --setup --venv --workspace ~/my-docs-workspace
    ```

2. **Збірка всіх версій документації**:

    ```bash
    ./rockydocs.sh --deploy
    ```

3. **Запустіть вебсайт, ідентичний робочому**:

    ```bash
    ./rockydocs.sh --serve --static
    ```

       !!! tip "Статичний режим обслуговування"
               Це обслуговує попередньо створені статичні файли точно так само, як у продакшені, без перенаправлень. Ідеально підходить для перевірки того, як ваш контент виглядатиме на сайті. Коренева URL-адреса (`http://localhost:8000/`) безпосередньо надає найновіший контент, так само як і docs.rockylinux.org.

        ```
         **Примітка**: Ви повинні знову виконати `--deploy`, щоб побачити зміни вмісту, оскільки це обслуговує попередньо зібрані файли.
        ```

       !!! note "Підтримка мов"
               За замовчуванням скрипт збирає англійську та українську мовні версії для швидшого налаштування та збірки. Для повного тестування з усіма доступними мовами використовуйте прапорець `--full`:

        ```
         ```bash
         # Full language support setup (config set once)
         ./rockydocs.sh --setup --venv --full
         # Deploy uses setup's language configuration automatically
         ./rockydocs.sh --deploy
         ```
        ```

### Варіант 2: Режим живої розробки (найкраще підходить для активного письма)

Ця опція автоматично оновлює ваш браузер під час редагування файлів вмісту, що ідеально підходить для активних сеансів написання.

1. **Налаштування середовища** (одноразове налаштування):

    ```bash
    # Basic setup
    ./rockydocs.sh --setup --venv
    
    # Alternative: Custom workspace location
    ./rockydocs.sh --setup --venv --workspace ~/my-docs-workspace
    ```

2. **Збірка всіх версій документації**:

    ```bash
    ./rockydocs.sh --deploy
    ```

3. **Запустіть сервер розробки в реальному часі**:

    ```bash
    ./rockydocs.sh --serve
    ```

       !!! tip "Режим живої розробки"
               Це забезпечує перезавантаження в реальному часі: редагуйте будь-який файл Markdown у вашому каталозі `docs/` та миттєво переглядайте зміни у вашому браузері. Ідеально підходить для активного написання та редагування контенту. Зміни відображаються автоматично без необхідності повторного запуску `--deploy`.

        ```
         **Примітка**: Може включати переадресації та поведінку, яка дещо відрізняється від робочої версії. Використовуйте статичний режим для остаточної перевірки.
        ```

### Варіант 3: Режим двох серверів (найкраще з обох світів)

Ця опція дозволяє одночасно запускати два сервери, що забезпечує повну навігацію по сайту та можливості редагування контенту в реальному часі.

1. **Налаштування середовища** (одноразове налаштування):

    ```bash
    # Basic setup
    ./rockydocs.sh --setup --venv
    
    # Alternative: Custom workspace location
    ./rockydocs.sh --setup --venv --workspace ~/my-docs-workspace
    ```

2. **Збірка всіх версій документації**:

    ```bash
    ./rockydocs.sh --deploy
    ```

3. **Запустіть подвійні сервери**:

    ```bash
    ./rockydocs.sh --serve-dual
    ```

       !!! tip "Режим двох серверів"
               Це дозволяє одночасно запускати два сервери, що забезпечує найкраще з обох світів:

        ```
         - **Port 8000**: Майк обслуговує повнофункціональний селектор версій та навігацію сайтом
         - **Port 8001**: Живе поповнення MkDocs для миттєвого оновлення контенту
         
         Перемикайтеся між портами залежно від того, чи потрібне вам редагування в реальному часі (8001), чи повне тестування сайту (8000). Цей режим ідеально підходить для учасників, які хочуть як негайно отримати відгук про контент, так і повне тестування навігації сайтом.
        ```

### Варіант 4: Середовище Docker

Якщо ви надаєте перевагу контейнерним середовищам або не хочете встановлювати залежності Python локально, ви можете використовувати Docker-версії будь-якого режиму обслуговування.

!!! note "Переваги середовища Docker"
    - **Ізольоване середовище**: Жодного впливу на вашу локальну інсталяцію Python або системні залежності
    - **Узгоджені збірки**: однакове середовище контейнерів на різних машинах
    - **Легке очищення**: Просто видаліть контейнери та зображення після завершення
    - **Усі режими обслуговування**: Підтримує статичний, активний та двосерверний режими в контейнерах

1.     

    ```bash
    # Basic Docker setup
    ./rockydocs.sh --setup --docker
    
    # Alternative: Custom workspace location
    ./rockydocs.sh --setup --docker --workspace ~/my-docs-workspace
    ```

2. **Збір всіх версій в контейнери**:

    ```bash
    ./rockydocs.sh --deploy --docker
    ```

3. **Вибір режиму обслуговування Docker**:

    ```bash
    # Production-identical (static)
    ./rockydocs.sh --serve --docker --static
    
    # Live development with auto-reload
    ./rockydocs.sh --serve --docker
    
    # Dual servers (containerized)
    ./rockydocs.sh --serve-dual --docker
    ```

## Перегляньте веб-сайт вашої локальної документації

За допомогою будь-якого з цих методів ви можете переглянути свою локальну копію веб-сайту, відкривши веб-браузер, щоб:

**<http://localhost:8000>**

Ви повинні побачити:

- Повний веб-сайт документації Rocky Linux
- Повна навігація та функції пошуку
- Селектор версій у верхній панелі навігації
- Весь контент точно такий, як він відображається на сайті виробництва
- Без перенаправлення – сторінки завантажуються безпосередньо

## Доступні команди скриптів

Скрипт `rockydocs.sh` надає кілька корисних команд:

### Основні команди робочого процесу

```bash
# Setup commands (run once)
./rockydocs.sh --setup --venv --minimal     # Python virtual environment setup
./rockydocs.sh --setup --docker --minimal   # Docker containerized setup

# Deployment commands (build the site)
./rockydocs.sh --deploy --minimal           # Build all versions (venv)
./rockydocs.sh --deploy --docker --minimal  # Build all versions (Docker)

# Serving commands (start the local website)
./rockydocs.sh --serve --static             # Production-identical static server (venv)
./rockydocs.sh --serve --docker --static    # Production-identical static server (Docker)
./rockydocs.sh --serve                      # Live development server with auto-reload (venv)
./rockydocs.sh --serve --docker             # Live development server with auto-reload (Docker)
./rockydocs.sh --serve-dual                 # Dual servers: mike serve + mkdocs live reload (venv)
./rockydocs.sh --serve-dual --docker        # Dual servers: containerized version (Docker)
```

### Команди технічного обслуговування та інформації

```bash
./rockydocs.sh --status                     # Show environment status and information
./rockydocs.sh --clean                      # Clean workspace and build artifacts
./rockydocs.sh --reset                      # Reset saved configuration
./rockydocs.sh --help                       # Show detailed help information
```

## Робота з різними версіями Rocky Linux

Скрипт автоматично визначає, з якою версією ви працюєте, на основі вашої гілки git:

```bash
# Switch to different versions in your content repository
git checkout rocky-8    # Work on Rocky Linux 8 documentation
git checkout rocky-9    # Work on Rocky Linux 9 documentation
git checkout main       # Work on Rocky Linux 10 documentation

# Rebuild with your changes
./rockydocs.sh --deploy --minimal
```

Ваші зміни відобразяться у відповідній версії, коли ви переглядатимете локальний вебсайт.

## Розуміння структури папок

Скрипт RockyDocs створює чітке розділення між вашим контентом та середовищем збірки:

```
~/rocky-projects/documentation/          # Your content repository (where you edit)
├── docs/                                # Your content files (guides, books, etc.)
├── rockydocs.sh                         # The script
└── .git/                               # Your content git repository

~/rockydocs-workspaces/                  # Build workspace (created by script)
├── docs.rockylinux.org/                # Main build environment
│   ├── venv/                           # Python virtual environment
│   ├── worktrees/                      # Cached copies of doc versions
│   │   ├── main/                       # Rocky Linux 10 content cache
│   │   ├── rocky-8/                    # Rocky Linux 8 content cache  
│   │   └── rocky-9/                    # Rocky Linux 9 content cache
│   ├── site-static/                    # Static site files (for --static mode)
│   ├── content -> worktrees/main/docs  # Symlink to your current version
│   ├── mkdocs.yml                      # Build configuration
│   └── .git/                          # Local build repository
└── app -> docs.rockylinux.org          # Compatibility symlink
```

**Ключові моменти:**

- Ваше сховище контенту залишається чистим — жодних файлів збірки чи залежностей
- Робочий простір для побудови повністю окремий і його можна безпечно видалити
- Скрипт автоматично керує символічним посиланням `content` на основі вашої поточної гілки git
- Кешовані робочі дерева запобігають повторному завантаженню контенту для різних версій Rocky
- Команда `--clean` видаляє всю робочу область збірки, якщо це необхідно

## Оновлення вашого середовища

Щоб отримати останні зміни з офіційних репозиторіїв:

```bash
# This updates both the build environment and content
./rockydocs.sh --deploy --minimal
```

Скрипт автоматично отримує оновлення з усіх гілок документації Rocky Linux.

## Вирішення проблем

Якщо у вас виникли проблеми:

1. **Перевірте стан системи**:
    ```bash
    ./rockydocs.sh --status
    ```

2. **Очищення та відновлення**:
    ```bash
    ./rockydocs.sh --clean
    ./rockydocs.sh --setup --venv --minimal
    ./rockydocs.sh --deploy --minimal
    ```

3. **Отримайте детальну допомогу**:
    ```bash
    ./rockydocs.sh --help
    ./rockydocs.sh --setup --help
    ./rockydocs.sh --serve --help
    ```

## Як ваші редагування потрапляють на створений сайт

Розуміння того, як скрипт RockyDocs пов'язує ваше локальне редагування з розгорнутим веб-сайтом, допомагає пояснити, чому були прийняті певні дизайнерські рішення та як ваші зміни відображаються у створеній документації.

### Основні проблеми

Сценарій повинен виконувати три речі одночасно:

1. Дозволяють редагувати у вашому звичному локальному репозиторії
2. Зберіть кілька версій Rocky Linux (8, 9, 10) з належним контекстом git
3. Відображайте ваші живі редагування негайно в збірках

### Огляд структури каталогів

```
Your editing environment:
~/rocky-projects/documentation/          ← You edit here
├── docs/                               ← Your live content
├── .git/                              ← Your git repository  
└── rockydocs.sh

Build environment (separate):
../rockydocs-workspaces/docs.rockylinux.org/
├── content → (symlink target varies)   ← MkDocs reads from here
├── mkdocs.yml (docs_dir: "content")    ← Always points to symlink
├── worktrees/                          ← Cached content for other versions
│   ├── main/docs/      ← Rocky 10 cached content
│   ├── rocky-8/docs/   ← Rocky 8 cached content  
│   └── rocky-9/docs/   ← Rocky 9 cached content
└── venv/
```

### Розумна стратегія символічних посилань

Ключовим нововведенням є динамічне символічне посилання під назвою `content` у середовищі збірки. Це символічне посилання змінює свою ціль залежно від того, над чим ви зараз працюєте:

#### Коли ви редагуєте Rocky Linux 10 (основну гілку):

```bash
# Your context:
cd ~/rocky-projects/documentation
git branch  # Shows: * main

# When you run: ./rockydocs.sh --deploy
# Script creates: content → ~/rocky-projects/documentation/docs

# Result: Your live edits appear immediately in builds
```

#### Під час створення інших версій:

```bash
# Script builds Rocky 8:
# content → ../worktrees/rocky-8/docs (cached Rocky 8 content)

# Script builds Rocky 9:  
# content → ../worktrees/rocky-9/docs (cached Rocky 9 content)
```

### Чому саме цей дизайн?

**Головна гілка → Ваші активні файли:**

- Ви активно редагуєте контент Rocky Linux 10
- Перезавантаження в реальному часі: збереження файлу, перегляд змін у браузері
- Використовує історію git вашого репозиторію для точних позначок часу

**Інші гілки → Кешовані робочі дерева:**

- У вас може не бути гілок rocky-8/rocky-9 локально
- Надає повний git-контекст для кожної версії Rocky
- Дозволяє створювати всі версії без впливу на ваш робочий процес

### Приклад повного процесу збірки

```bash
# 1. You edit in your repo
cd ~/rocky-projects/documentation
echo "New troubleshooting tip" >> docs/guides/myguide.md

# 2. You deploy and serve
./rockydocs.sh --deploy
./rockydocs.sh --serve

# 3. Script creates symlink in build environment
# content → ~/rocky-projects/documentation/docs

# 4. MkDocs builds from your live files
# Your changes appear immediately in the local website
```

### Переваги цієї архітектури

1. **Миттєве відображення редагування**: Ваші зміни відображаються миттєво без необхідності повторного створення
2. **Підтримка кількох версій**: Можна зібрати всі версії Rocky з належним контекстом git
3. **Чистий поділ**: Ваш робочий процес git залишається повністю незмінним
4. **Збереження історії Git**: Кожна версія має точні позначки часу та інформацію про автора
5. **Гнучка розробка**: Перемикання гілок, скрипт адаптується автоматично

Символічне посилання діє як «розумний покажчик», за яким MkDocs слідує для пошуку контенту, тоді як скрипт динамічно перенаправляє його на основі того, над чим ви зараз працюєте. Це пояснює, чому скрипт повинен клонувати репозиторії окремо — це створює чисте середовище збірки, зберігаючи при цьому ваше середовище редагування бездоганним.

## Примітки

- Скрипт RockyDocs створює робочий простір **поза** вашим репозиторієм контенту, щоб підтримувати чистоту робочого процесу git
- Усі середовища повністю локальні — нічого не завантажується та не публікується автоматично
- Скрипт автоматично керує залежностями, конфліктами портів та очищенням
- Як віртуальне середовище Python, так і методи Docker забезпечують однакову функціональність.
- Локальний вебсайт містить ту саму тему, навігацію та функції, що й продакшн-сайт.
- Ви можете безпечно експериментувати зі змінами контенту — ваше локальне середовище повністю ізольоване
- Скрипт автоматично зберігає історію git для точного відображення позначок часу документів
