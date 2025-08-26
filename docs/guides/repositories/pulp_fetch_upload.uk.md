---
title: Отримання та розповсюдження сховища RPM за допомогою Pulp
author: David Gomez
contributors: Steven Spencer, Ganna Zhyrnova
tested with: 9.2
tags:
  - Fetch
  - Distribute
  - RPM
  - Репозиторій
  - Pulp
---

## Вступ

Розробникам, які використовують Rocky Linux, часто потрібні різні віддалені репозиторії rpm для підтримки їх операцій. Pulp — це проект із відкритим вихідним кодом, який може допомогти розробникам задовольнити цю потребу, спрощуючи вибірку та розповсюдження різних сховищ RPM. У цьому посібнику показано простий приклад використання Pulp для отримання BaseOS і AppStream зі сховища Rocky Linux.

## Вимоги

 - Система Rocky Linux
 - Вміння запускати контейнери

## Налаштування - один контейнер

Існує багато можливих налаштувань Pulp, але для зручності у цьому посібнику використовуватиметься сценарій розгортання одного контейнера. Виберіть каталог для Pulp і створіть наступні каталоги та файли.

```bash
mkdir -p settings/certs pulp_storage pgsql containers
echo "CONTENT_ORIGIN='http://$(hostname):8080'" >> settings/settings.py
```

Якщо у вас увімкнено SELinux, виконайте наступне, щоб розгорнути Pulp. Якщо SELinux не ввімкнено, ви можете видалити суфікс `:Z` із рядків `--volume`:

```bash
$ podman run --detach \
             --publish 8080:80 \
             --name pulp \
             --volume "$(pwd)/settings":/etc/pulp:Z \
             --volume "$(pwd)/pulp_storage":/var/lib/pulp:Z \
             --volume "$(pwd)/pgsql":/var/lib/pgsql:Z \
             --volume "$(pwd)/containers":/var/lib/containers:Z \
             --device /dev/fuse \
             pulp/pulp
```

Якщо ви перейдете до `http://localhost:8080/pulp/content/`, ви побачите «Index of /pulp/content/», який наразі порожній. Ви заповните їх своїми репозиторіями до кінця цього посібника.

![empty_index](images/empty_pulp_index.png)

## Створення Pulp Remotes

Думайте про пульти Pulp як про віддалені сховища джерел. У цьому випадку віддаленими вихідними репозиторіями є BaseOS і AppStream зі сховища Rocky Linux 9.2. Ви використовуватимете ці пульти для синхронізації зі сховищами, створеними за допомогою Pulp. Перегляньте [офіційну документацію Pulp](https://pulpproject.org/), щоб дізнатися більше про правила віддаленого керування.

```bash
pulp rpm remote create --name "rocky_92_appstream_vault" --url "https://dl.rockylinux.org/vault/rocky/9.2/AppStream/x86_64/os/" --policy on_demand
pulp rpm remote create --name "rocky_92_baseos_vault" --url "https://dl.rockylinux.org/vault/rocky/9.2/BaseOS/x86_64/os/" --policy on_demand
```

## Копії сховища Pulp

Це будуть індивідуальні копії сховищ BaseOS і AppStream зі сховища Rocky Linux 9.2. Якщо ви знаєте пульт дистанційного керування, з якого хочете синхронізувати свої сховища, ви можете додати ці пульти дистанційного керування під час створення сховища. В іншому випадку, якщо ви не знаєте, які пульти дистанційного керування використовувати, або якщо ці пульти дистанційного керування можна змінити, ви можете не використовувати пульти дистанційного керування. Для цього посібника оголошення пультів відбувається під час створення сховища.

```bash
pulp rpm repository create --name "R92_AppStream_Vault" --remote "rocky_92_appstream_vault"
pulp rpm repository create --name "R92_BaseOS_Vault" --remote "rocky_92_baseos_vault"
```

## Копії Pulp Sync

!!! note

    Важливо додати «--skip-type treeinfo», інакше замість BaseOS або AppStream ви отримаєте дивну суміш обох. Ймовірно, це пов’язано з проблемою зі сховищами, які не закриті залежно. Якщо пульт дистанційного керування не було вказано раніше, ви можете додати його, інакше, якщо ви додали його під час створення, немає необхідності згадувати пульт у синхронізації, як це мається на увазі.

```bash
pulp rpm repository sync --name "R92_AppStream_Vault" --skip-type treeinfo
pulp rpm repository sync --name "R92_BaseOS_Vault" --skip-type treeinfo
```

## Pulp Publish Publications

Після того, як ваші сховища буде синхронізовано з пультів дистанційного керування, ви захочете створити публікації з цих сховищ, щоб розмістити їх у дистрибутивах. Поки що ви могли використовувати лише назви віддалених пристроїв і сховищ, однак Pulp також покладається на `hrefs`, і ви можете використовувати їх як взаємозамінні. Після створення публікації обов’язково зверніть увагу на значення `pulp_href` кожного, оскільки вони знадобляться для наступного кроку.

```bash
pulp rpm publication create --repository "R92_AppStream_Vault"
pulp rpm publication create --repository "R92_BaseOS_Vault"
```

## Pulp Create Distributions

За допомогою `pulp_href` з попереднього кроку публікації тепер ви можете подавати цей вміст до розповсюдження. Тоді цей вміст відображатиметься під `http://localhost:8080/pulp/content/` і більше не буде порожнім. Ви можете ще раз перевірити `pulp_href` публікацій за допомогою `pulp rpm publication list` і шукати `pulp_href`. Як приклад, `pulp_href` для BaseOS наведено нижче, але ваш `pulp_href` може бути іншим, тому поміняйте його відповідно.

```bash
pulp rpm distribution create --name "Copy of BaseOS 92 RL Vault" --base-path "R92_BaseOS_Vault" --publication "/pulp/api/v3/publications/rpm/rpm/0195fdaa-a194-7e9d-a6a9-e6fd4eaa7a20/"
pulp rpm distribution create --name "Copy of AppStream 92 RL Vault" --base-path "R92_AppStream_Vault" --publication "<pulp_href>"
```

Якщо ви позначите `http://localhost:8080/pulp/content/`, ви побачите свої два сховища, які є копіями сховищ Rocky Linux 9.2 AppStream і BaseOS.

![content_index](images/pulp_index_content.png)

## Висновок

Pulp може бути дуже універсальним інструментом, який використовується для отримання кількох сховищ і розповсюдження їх за потреби. Це базовий приклад, однак ви можете використовувати Pulp у різноманітних сценаріях розгортання та створювати складнішу та вдосконалену організацію сховища. Перегляньте [офіційну документацію](https://pulpproject.org/) для отримання додаткової інформації.
