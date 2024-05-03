---
title: Метод Podman
author: Wale Soyinka
contributors: Ganna Zhyrnova
update: 13 лютого 2023 р
---

# Запуск веб-сайту docs.rockylinux.org локально для веб-розробки | Podman

У цьому документі описано, як відтворити та запустити локальну копію всього веб-сайту docs.rockylinux.org на вашій локальній машині. Запуск локальної копії веб-сайту документації може бути корисним у таких випадках:

- Вам цікаво дізнатися про аспекти веб-розробки веб-сайту docs.rockylinux.org і зробити свій внесок у них
- Ви автор і хотіли б побачити, як ваші документи відображатимуться/виглядатимуть на веб-сайті документів, перш ніж надсилати їх

## Створення середовища вмісту

1. Переконайтеся, що передумови виконано. Якщо ні, перейдіть до розділу «[Налаштування попередніх умов](#setup-the-prerequisites)», а потім поверніться сюди.

2. Змініть поточний робочий каталог у вашій локальній системі на папку, у якій ви збираєтеся писати. Ми будемо посилатися на цей каталог як `$ROCKYDOCS` в решті цього посібника. Для нашої демонстрації тут `$ROCKYDOCS` вказує на `$HOME/projects/rockydocs` у нашій демонстраційній системі.

    Створіть `$ROCKYDOCS`, якщо він ще не існує, і змініть свій робочий каталог на тип `$ROCKYDOCS`:

    ```bash
    mkdir -p $HOME/projects/rockydocs
    export ROCKYDOCS=${HOME}/projects/rockydocs
    cd  $ROCKYDOCS
    ```

3. Переконайтеся, що у вас встановлено `git` (`dnf -y install git`).  Перебуваючи в $ROCKYDOCS, використовуйте git, щоб клонувати офіційне сховище вмісту Rocky Documentation. Впишіть:

    ```bash
    git clone https://github.com/rocky-linux/documentation.git
    ```

    Тепер у вас буде папка `$ROCKYDOCS/documentation`. Ця папка є репозиторієм git і знаходиться під контролем git.

4. Також використовуйте `git`, щоб клонувати офіційне сховище docs.rockylinux.org. Впишіть:

    ```bash
    git clone https://github.com/rocky-linux/docs.rockylinux.org.git
    ```

Тепер у вас буде папка `$ROCKYDOCS/docs.rockylinux.org`. У цій папці ви можете експериментувати зі своїми внесками в веб-розробку.

## Створіть і запустіть середовище веб-розробки RockyDocs

1. Переконайтеся, що Podman запущено та працює на вашій локальній машині (це можна перевірити за допомогою `systemctl`). Перевірте, запустивши:

    ```bash
    systemctl  enable --now podman.socket
    ```

2. Створіть новий файл `docker-compose.yml` із таким вмістом:

    ```bash
    version: '2'
    services:
      mkdocs:
        privileged: true
        image: rockylinux:9.1
        ports:
          - 8001:8001
        environment:
          PIP_NO_CACHE_DIR: "off"
          PIP_DISABLE_PIP_VERSION_CHECK: "on"
        volumes:
          - type: bind
            source: ./documentation
            target: /app/docs
          - type: bind
            source: ./docs.rockylinux.org
            target: /app/docs.rockylinux.org
        working_dir: /app
        command: bash -c "dnf install -y python3 pip git && \
          ln -sfn  /app/docs   docs.rockylinux.org/docs && \
          cd docs.rockylinux.org && \
          git config  --global user.name webmaster && \
          git config  --global user.email webmaster@rockylinux.org && \
          curl -SL https://raw.githubusercontent.com/rocky-linux/documentation-test/main/docs/labs/mike-plugin-changes.patch -o mike-plugin-changes.patch && \
          git apply --reverse --check mike-plugin-changes.patch && \
          /usr/bin/pip3 install --no-cache-dir -r requirements.txt && \
          /usr/local/bin/mike deploy -F mkdocs.yml 9.1 91alias && \
          /usr/local/bin/mike set-default 9.1 && \
          echo  All done && \
          /usr/local/bin/mike serve  -F mkdocs.yml -a  0.0.0.0:8001"    
    ```

    Збережіть файл із назвою `docker-compose.yml` у робочому каталозі $ROCKYDOCS.

    Ви також можете швидко завантажити копію файлу docker-compose.yml, виконавши:

    ```bash
    curl -SL https://raw.githubusercontent.com/rocky-linux/documentation-test/main/docs/labs/docker-compose-rockydocs.yml -o docker-compose.yml
    ```

3. Нарешті використовуйте docker-compose, щоб відкрити службу. Впишіть:

    ```bash
    docker-compose  up
    ```

## Перегляньте місцевий веб-сайт docs.rockylinux.org

Якщо у вашій системі Rocky Linux працює брандмауер, переконайтеся, що порт 8001 відкритий. Впишіть:

  ```bash
  firewall-cmd  --add-port=8001/tcp  --permanent
  firewall-cmd  --reload
  ```

  Коли контейнер запущений і запущений, тепер ви зможете вказати свій веб-браузер за такою URL-адресою, щоб переглянути локальну копію сайту:

  <http://localhost:8001>

  Або

  <http://SERVER_IP:8001>

## Налаштування передумов

Встановіть і налаштуйте Podman та інші інструменти, виконавши:

```bash
sudo dnf -y install podman podman-docker git

sudo systemctl enable --now  podman.socket
```

Встановіть docker-compose і зробіть його виконуваним. Впишіть:

```bash
curl -SL https://github.com/docker/compose/releases/download/v2.16.0/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose

chmod 755 /usr/local/bin/docker-compose
```

Виправте дозволи на сокет докера. Впишіть:

```bash
sudo chmod 666 /var/run/docker.sock
```

### Примітки:

- Інструкції в цьому посібнику **НЕ** є обов’язковою умовою для авторів документації Rocky або учасників вмісту
- Все середовище працює в контейнері Podman, тому вам потрібно буде правильно налаштувати Podman на вашій локальній машині
- Контейнер створено на основі офіційного образу докерів Rocky Linux 9.1, доступного тут <https://hub.docker.com/r/rockylinux/rockylinux>
- Контейнер зберігає вміст документації окремо від веб-механізму (mkdocs)
- Контейнер запускає локальний веб-сервер, який прослуховує порт 8001.
