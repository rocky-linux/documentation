---
title: Робочий стіл MATE
author: lillolollo, Steven Spencer
contributors: Steven Spencer, Serge, Ganna Zhyrnova
tested_with: 8.5, 8.6, 9.0
tags:
  - mate
  - робочий стіл
---

# Середовище робочого столу MATE

Створене для розгалуження та продовження GNOME2 на хвилі дещо ворожого сприйняття GNOME3, народилося робоче середовище MATE. MATE має лояльних послідовників, які зазвичай негайно встановлюють його на свою ОС. MATE можна встановити на багатьох версіях Linux, включаючи Rocky Linux.

Ця процедура допоможе вам почати працювати з MATE на Rocky Linux.

## Передумови

* Комп’ютер (ноутбук або робоча станція) з екраном і всім необхідним.
* Бажання запустити робочий стіл MATE замість стандартного GNOME.

=== "9"

    ## 9: Вступ
    
    Команда розробників Rocky Linux 9 спростила встановлення MATE та інших популярних робочих середовищ, включивши живі образи. Для тих, хто може не знати, що це таке, живий образ – це завантажувальний образ, який завантажує ОС без встановлення. Після завантаження ви можете встановити його на дисковод вашої машини та використовувати. На додаток до інструкцій щодо живого образу, ми включили інструкції для тих із вас, хто хоче встановити MATE після встановлення ОС.
    
    ## 9: MATE з Live Image
    
    ### 9: Отримайте, перевірте та запишіть живий образ MATE
    
    Першим кроком до інсталяції є завантаження живого образу та запис його на DVD або флешку USB. Як було зазначено раніше, образ буде завантажувальний, як і будь-який інший інсталяційний носій для Linux. Ви можете знайти останній образ MATE у розділі завантаження для Rocky Linux 9 [живі зображення](https://dl.rockylinux.org/pub/rocky/9.3/live/x86_64/). Зауважте, що це конкретне посилання передбачає x86_64 як вашу архітектуру, і на момент написання цієї статті це єдина архітектура, для якої доступний цей живий образ. Завантажте живий образ і файли контрольної суми. 
    
    Тепер перевірте зображення за допомогою файлу CHECKSUM за допомогою наступного
    (зверніть увагу, це приклад! Переконайтеся, що назва вашого зображення та файли CHECKSUM збігаються):

    ```
    sha256sum -c CHECKSUM --ignore-missing Rocky-9.1-MATE-x86_64-20221124.0.iso.CHECKSUM
    ```


    Якщо все піде добре, ви повинні отримати це повідомлення:

    ```
    Rocky-9.1-MATE-x86_64-20221124.0.iso: OK
    ```


    Якщо контрольна сума для файлу повертає ОК, тепер ви готові записати образ ISO на носій. Ця процедура відрізняється залежно від вашої ОС, носія та інструментів. Ми припускаємо, що ви знаєте, як записати зображення на свій носій.
    
    ### 9: Завантаження
    
    Знову ж таки, це залежить від машини, BIOS, ОС тощо. Ви повинні переконатися, що ваша машина налаштована на завантаження будь-якого носія (DVD або USB) як першого завантажувального пристрою. У разі успіху ви побачите цей екран:
    
    ![mate_boot](images/mate_boot.png)
    
    Якщо так, то ви на вірному шляху! Якщо ви хочете протестувати носій, спочатку виберіть цей параметр або введіть **S**, щоб **запустити Rocky Linux Mate 9.0**.
    
    Пам’ятайте, це живе зображення. Завантаження на перший екран займе деякий час. Не панікуйте, просто почекайте! Коли живий образ завантажиться, ви побачите цей екран:
    
    ![mate-live](images/mate_live.png)
    
    ### 9: Встановлення MATE
    
    На цьому етапі ви можете використовувати середовище MATE і перевірити, чи воно вам подобається. Коли ви вирішите, що хочете використовувати його назавжди, двічі клацніть опцію **Встановити на жорсткий диск**.
    
    Це почне знайомий процес встановлення для тих, хто встановив Rocky Linux. На наступному екрані ми виділили речі, які ви *можете* захотіти змінити.
    
    ![mate_install](images/mate_install.png)

    1. **Keyboard**. Подивіться на цей параметр і переконайтеся, що він відповідає розкладці клавіатури, яку ви використовуєте.
    2. **Time & Date** – переконайтеся, що вона відповідає вашому часовому поясу.
    3. **Installation Destination**. Вам потрібно буде натиснути цей параметр, навіть якщо це потрібно для прийняття того, що вже є.
    4. **Network & Host Name**. Переконайтеся, що тут є те, що ви хочете. Поки мережа ввімкнена, ви завжди можете змінити це пізніше, якщо знадобиться.
    5. **Root Password** – встановіть пароль адміністратора. Не забудьте зберегти це в безпечному місці (менеджер паролів), головним чином, якщо ви не використовуєте його часто.
    6. **User Creation** – обов’язково створіть принаймні одного користувача. Якщо ви хочете, щоб користувач мав права адміністратора, не забудьте встановити цей параметр під час створення користувача.
    7. **Begin Installation** – коли всі параметри встановлено або перевірено, натисніть цю опцію.

    Коли ви виконаєте крок 7, процес інсталяції має почати інсталяцію пакетів, як на знімку екрана нижче:

    ![mate_install_2](images/mate_install_2.png)

    Після завершення інсталяції на жорсткий диск ви побачите такий екран:

    ![mate_install_final](images/mate_install_final.png)

    Натисніть **Finish Installation**.

    У цей момент ОС перезавантажиться. Видаліть завантажувальний носій, і коли ОС з’явиться вперше, з’явиться екран ліцензійної угоди:

    ![eula](images/eula.png)

    Поставте прапорець **Я приймаю ліцензійну угоду**, а потім натисніть **Готово**. Це приведе вас до останнього екрана, що стосується встановлення. На цьому екрані натисніть **Завершити налаштування**.

    ![mate_finish](images/mate_finish.png)

    Далі ви отримаєте екран входу з користувачем, якого ви створили вище. Введіть свій пароль, який переведе вас на робочий стіл MATE:

    ![mate_desktop](images/mate_desktop.png)


    ## 9: MATE після встановлення ОС

    MATE також можна встановити після встановлення ОС. Це вимагає ще кількох кроків, але це не складний процес. Просто дотримуйтесь цих інструкцій.


    ### 9: Увімкнення репозиторіїв

    Вам потрібні репозиторій CRB і репозиторій EPEL. Увімкніть їх зараз:

    ```
    sudo dnf config-manager --set-enabled crb
    sudo dnf install epel-release
    ```

    Запустіть `dnf upgrade`, щоб переконатися, що всі активовані репозиторії зчитуються в системі.


    ### 9: Встановлення пакетів

    Наступне, що нам потрібно, це багато пакунків. Ви можете встановити їх, просто скопіювавши та вставивши наступне в командний рядок на вашому комп’ютері:

    ```
    sudo dnf install NetworkManager-adsl NetworkManager-bluetooth NetworkManager-libreswan-gnome NetworkManager-openvpn-gnome NetworkManager-ovs NetworkManager-ppp NetworkManager-team NetworkManager-wifi NetworkManager-wwan adwaita-gtk2-theme alsa-plugins-pulseaudio atril atril-caja atril-thumbnailer caja caja-actions caja-image-converter caja-open-terminal caja-sendto caja-wallpaper caja-xattr-tags dconf-editor engrampa eom firewall-config gnome-disk-utility gnome-epub-thumbnailer gstreamer1-plugins-ugly-free gtk2-engines gucharmap gvfs-fuse gvfs-gphoto2 gvfs-mtp gvfs-smb initial-setup-gui libmatekbd libmatemixer libmateweather libsecret lm_sensors marco mate-applets mate-backgrounds mate-calc mate-control-center mate-desktop mate-dictionary mate-disk-usage-analyzer mate-icon-theme mate-media mate-menus mate-menus-preferences-category-menu mate-notification-daemon mate-panel mate-polkit mate-power-manager mate-screensaver mate-screenshot mate-search-tool mate-session-manager mate-settings-daemon mate-system-log mate-system-monitor mate-terminal mate-themes mate-user-admin mate-user-guide mozo network-manager-applet nm-connection-editor p7zip p7zip-plugins pluma seahorse seahorse-caja xdg-user-dirs-gtk
    ```

    Це встановить необхідні пакунки та всі залежності.

    Також встановіть ligtdm-settings і ligtdm:

    ```
    sudo dnf install lightdm-settings lightdm
    ```


    ### 9: Останні кроки

    Якщо перед установкою MATE у вашій системі був встановлений Gnome або інший робочий стіл, ви повинні бути готові до перезавантаження зараз. Якщо робочий стіл не встановлено, вам потрібно буде використати таку команду, щоб установити графічну ціль:

    ```
    sudo systemctl set-default graphical.target
    ```

    Потім перезавантажте

    ```
    sudo reboot
    ```

    Коли система перезавантажиться, клацніть своє ім’я користувача, але перш ніж вводити пароль, клацніть значок шестірні в нижньому правому куті екрана та виберіть MATE зі списку робочого столу. Потім увійдіть, і у вас має бути повнофункціональний робочий стіл MATE. Майбутні входи повинні пам'ятати ваш вибір.

=== "8"

    ## 8: Встановіть Rocky Linux Minimal
    
    Під час встановлення Rocky Linux ми використовували такі набори пакетів:

    * Minimal
    * Standard


    ## 8: Увімкнення репозиторіїв

    Вам потрібні репозиторій CRB і репозиторій EPEL. Увімкніть їх зараз:

    ```
    sudo dnf config-manager --set-enabled powertools
    sudo dnf install epel-release
    ```

    Щоб встановити репозиторій EPEL, дайте відповідь «Y».

    Запустіть `dnf update`, щоб переконатися, що всі активовані репозиторії зчитуються в системі.


    ## 8: Встановлення пакетів

    Наступне, що нам потрібно, це багато пакунків. Ви можете встановити їх, просто скопіювавши та вставивши наступне в командний рядок на вашому комп’ютері:

    ```
    sudo dnf install NetworkManager-adsl NetworkManager-bluetooth NetworkManager-libreswan-gnome NetworkManager-openvpn-gnome NetworkManager-ovs NetworkManager-ppp NetworkManager-team NetworkManager-wifi NetworkManager-wwan abrt-desktop abrt-java-connector adwaita-gtk2-theme alsa-plugins-pulseaudio atril atril-caja atril-thumbnailer caja caja-actions caja-image-converter caja-open-terminal caja-sendto caja-wallpaper caja-xattr-tags dconf-editor engrampa eom firewall-config gnome-disk-utility gnome-epub-thumbnailer gstreamer1-plugins-ugly-free gtk2-engines gucharmap gvfs-afc gvfs-afp gvfs-archive gvfs-fuse gvfs-gphoto2 gvfs-mtp gvfs-smb initial-setup-gui libmatekbd libmatemixer libmateweather libsecret lm_sensors marco mate-applets mate-backgrounds mate-calc mate-control-center mate-desktop mate-dictionary mate-disk-usage-analyzer mate-icon-theme mate-media mate-menus mate-menus-preferences-category-menu mate-notification-daemon mate-panel mate-polkit mate-power-manager mate-screensaver mate-screenshot mate-search-tool mate-session-manager mate-settings-daemon mate-system-log mate-system-monitor mate-terminal mate-themes mate-user-admin mate-user-guide mozo network-manager-applet nm-connection-editor p7zip p7zip-plugins pluma seahorse seahorse-caja xdg-user-dirs-gtk
    ```

    Це встановить необхідні пакунки та всі залежності.

    Встановіть lightdm-settings і lightdm також:

    ```
    sudo dnf install lightdm-settings lightdm
    ```


    ## 8: Останні кроки

    Тепер, коли ми встановили все необхідне, ми повинні встановити мінімальну інсталяцію для завантаження в графічний інтерфейс користувача (GUI). Ми можемо зробити це, ввівши:

    ```
    sudo systemctl set-default graphical.target
    ```

    Тепер просто тримайте кулаки та перезавантажте:

    ```
    sudo reboot
    ```

    Далі клацніть своє ім’я користувача на екрані, але перш ніж ввести пароль і увійти, клацніть значок шестірні ліворуч від опції «Увійти». Виберіть «MATE» із доступних варіантів робочого столу, після чого ви зможете ввести свій пароль і увійти. Подальші входи запам'ятають ваш вибір.

## Висновок

Деякі люди незадоволені новішими реалізаціями GNOME або віддають перевагу старішому вигляду та роботі MATE GNOME 2. Встановлення MATE у Rocky Linux забезпечить дружню, стабільну альтернативу для цих людей. Для Rocky Linux 9.0 розробники зробили весь процес дуже легким за допомогою доступного живого образу.
