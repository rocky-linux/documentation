---
title: Форматування документів
author: Steven Spencer
contributors: tianci li, Ezequiel Bruni, Krista Burdine, Ganna Zhyrnova
tags:
  - contribute
  - форматування
---

## Вступ

У цьому посібнику описано додаткові параметри форматування, зокрема попередження, нумеровані списки, таблиці тощо.

Документ може або не повинен містити жодного з цих елементів. Якщо ви вважаєте, що спеціальне форматування допоможе вашому документу, цей посібник має допомогти.

!!! note "Примітка про заголовки"

    Заголовки не є спеціальними символами форматування; скоріше це стандартний markdown синтаксис. Вони містять **один** заголовок першого рівня:
    
    `     # Це перший рівень     `
    
    
    і будь-яка кількість значень підзаголовків, рівні від 2 до 6:
    
    `     ## Заголовок рівня 2      ### Заголовок рівня 3      #### Заголовок рівня 4      ##### Заголовок 5 рівня      ###### Заголовок 6 рівня     `
    
    
    Ключовим тут є те, що ви можете використовувати скільки завгодно заголовків із 2–6, але лише **ОДИН** заголовок рівня 1. Хоча документ відображатиметься правильно з кількома заголовками рівня 1, автоматично створений зміст документа, який з’являється праворуч, **НЕ** відображатиметься правильно (або іноді взагалі) із кількома заголовками. Майте це на увазі під час написання документів.
    
    Ще одна важлива примітка щодо заголовка рівня 1: якщо мета `title:` використовується, то це буде типовий заголовок рівня 1. Ви не повинні додавати ще один. Наприклад, мета заголовка цього документа:
    
    `     ---     title: Document Formatting     `
    
    
    Таким чином, найпершим доданим заголовком є ​​«Вступ» на рівні 2.
    
    `     ## Вступ     `

!!! warning "Примітка про підтримувані елементи HTML"

    Існують елементи HTML, які технічно підтримуються у розмітці. Деякі з них описані в цьому документі, де не існує синтаксису розмітки, який би їх замінив. Ці підтримувані HTML-теги слід використовувати рідко, оскільки лінтери розмітки скаржаться на них у документі. Наприклад:
    
    \* Inline HTML [element name]
    
    Якщо вам потрібно використовувати підтримуваний елемент HTML, подивіться, чи можете ви знайти інший спосіб написати свій документ, який не використовуватиме ці елементи. Якщо ви повинні їх використовувати, це все одно дозволено.

!!! info "Примітка про посилання"

    Посилання – це не спеціальне форматування, а стандартні методи посилання на інші документи (внутрішні посилання) або зовнішні веб-сторінки. Однак є один тип посилання, який не слід використовувати під час створення документів для Rocky Linux, і це прив’язка або посилання на місце в тому самому документі.
    
    Якір працює на вихідній мові для Rocky Linux (англійська), але щойно їх перекладає наш інтерфейс Crowdin, вони ламаються на цих мовах. Це відбувається через те, що прийнятний прив’язка у markdown, яка не містить елементів HTML, використовує заголовок для створення посилання:
    
    `     ## Заголовок          текст          Посилання [на заголовок](#-заголовок)     `
    
    
    Це посилання можна знайти, навівши курсор миші на постійне посилання у створеному документі, але це, по суті, заголовок із «#» і заголовок у нижньому регістрі, розділений тире (-).
    
    Коли документ перекладається, перекладається заголовок, АЛЕ посилання знаходиться за межами того, що Crowdin дозволяє перекладати, тому воно залишається в оригінальному (англійському) стані.
    
    Якщо вам знадобиться використовувати прив’язку, подивіться на свій документ і подивіться, чи реорганізація вмісту не зробить прив’язку непотрібною. Просто знайте, що якщо ви використовуєте прив’язку у щойно створеному документі, ця прив’язка розірветься після перекладу цього документа.

## Застереження

Попередження — це спеціальні візуальні «коробки», які звертають увагу на важливі факти та виділяють їх. Існують наступні типи застережень:

| тип                 | Опис                                                                              |
| ------------------- | --------------------------------------------------------------------------------- |
| note "примітка"     | відображає текст у синьому полі                                                   |
| abstract "анотація" | відображає світло-блакитне текстове поле                                          |
| info "Інформація"   | відображає синьо-зелене текстове поле                                             |
| tip "Підказка"      | відображає синьо-зелене текстове поле (значок трохи зеленіший) |
| success "Успіх"     | відображає зелене текстове поле                                                   |
| question "Питання"  | відображає світло-зелене текстове поле                                            |
| warning "Важливо"   | відображає помаранчеве текстове поле                                              |
| failure "Невдача"   | відображає світло-червоне текстове поле                                           |
| danger "Небезпечно" | відображає червоне текстове поле                                                  |
| bug "Помилка"       | відображає червоне текстове поле                                                  |
| example "Приклад"   | відображає фіолетове текстове поле                                                |
| quote "Цитата"      | відображає сіре текстове поле                                                     |
| custom ^1^          | завжди відображає синє текстове поле                                              |
| custom ^2^          | використовує спеціальну назву в іншому типі                                       |

Попередження необмежені, як зазначено в custom <sub>1</sub> вище. Додайте спеціальний заголовок до будь-якого типу попередження, щоб отримати потрібний колір рамки для конкретного попередження, як зазначено в custom <sub>2</sub> вище.

Застереження завжди вводиться таким чином:

```text
!!! тип_застереження "Заголовок застереження якщо є"

    текст застереження
```

Основний текст застереження має бути з відступом на чотири (4) інтервали від початкового поля. Легко побачити, де це, тому що він завжди вишиковується під першою літерою типу застереження. Зайвий рядок між заголовком і основним текстом не з’являтиметься, але наша система перекладу (Crowdin) має працювати правильно.

Ось приклади кожного типу застережень і того, як вони виглядатимуть у вашому документі:

!!! note

    текст

!!! abstract

    текст

!!! info

    текст

!!! tip

    текст

!!! success

    текст

!!! question

    текст

!!! warning

    текст

!!! failure

    текст

!!! danger

    текст

!!! custom "Власний заголовок"

    ```
    Спеціальний тип^1^. Тут ми використали "спеціальний" як наш тип попередження. Знову ж таки, це завжди відображатиметься синім кольором.
    ```

!!! warning "Власний заголовок"

    Спеціальний тип^2^. Ми змінили тип попередження «попередження» за допомогою спеціального заголовка. Ось як це виглядає:
    
    `     !!! warning "Власний заголовок"     `

### Попередження, що розгортаються

Якщо застереження має дуже довгий вміст, розгляньте можливість використання розгорнутого застереження. Це розглядається як звичайне застереження, але починається з трьох знаків питання, а не з трьох знаків оклику. Застосовуються всі інші правила попередження. Попередження, що розгортається, виглядає так:

??? warning ""

    Це попередження, не дуже багато змісту. Ви б хотіли використовувати для цього звичайне попередження, але це лише приклад!

Це виглядає так у вашому редакторі:

??? warning ""
    
    "Зміст попередження"
    
    Це попередження, яке не має особливого змісту. Ви б хотіли використовувати для цього звичайне попередження, але це лише приклад!

## Вміст із вкладками в документі

Вміст із вкладками форматується подібно до попереджень. Замість трьох знаків оклику чи питання, він починається трьома знаками рівності. Усе форматування попередження (4 пробіли тощо) застосовується до цього вмісту. Наприклад, для документації може знадобитися інша процедура для іншої версії Rocky Linux. Якщо для версій використовується вміст із вкладками, останній випуск Rocky Linux має бути першим. На момент написання цієї статті це було 9.0:

\=== "9.0"

    ```
    Процедура для цього в 9.0
    ```

\=== "8.6"

    ```
    Процедура для цього в 8.6
    ```

У вашому редакторі це виглядатиме так:

```text
=== "9,0"

     Процедура для цього в 9.0

=== "8,6"

     Процедура для цього в 8.6
```

Пам’ятайте, що все, що потрапляє всередину розділу, має продовжувати використовувати 4-пробілний відступ, доки розділ не буде завершено. Це дуже зручна функція!

## Нумеровані списки

Нумеровані списки схоже на те, що їх легко створювати та використовувати, і коли ви з ними зрозумієте, це дійсно так. Якщо у вас є лише один список елементів без складності, тоді такий формат працює добре:

```text
1. Пункт 1

2. Пункт 2

3. Пункт 3
```

1. Пункт 1

2. Пункт 2

3. Пункт 3

Якщо вам потрібно додати блоки коду, кілька рядків або навіть абзаци тексту до нумерованого списку, тоді текст має бути з відступом із тими самими чотирма (4) пробілами, які використовуються в попередженнях.

Однак ви не можете використовувати очі, щоб вирівняти їх під пронумерованим пунктом, оскільки це один інтервал. Якщо ви користуєтеся хорошим редактором розміток, ви можете встановити значення табуляції на чотири (4), що спростить форматування всього.

Ось приклад багаторядкового нумерованого списку з доданим блоком коду:

1. Коли ви маєте справу з багаторядковими нумерованими списками, які включають блоки коду, використовуйте відступ пробілу, щоб отримати те, що ви хочете.

   Наприклад: це має відступ на чотири (4) пробіли та представляє новий абзац тексту. Крім того, ми додаємо блок коду. Він також має такі ж чотири (4) пробіли, як і наш абзац:

    ```bash
    dnf update
    ```

2. Ось наш другий пункт у списку. Оскільки ми використали відступ (вище), він відображається з наступною послідовністю нумерації (іншими словами, 2), але якби ми ввели елемент 1 без відступу (у наступному абзаці та коді), тоді це відображалося б як елемент 1 знову, що не те, чого ми хочемо.

І ось як це виглядає як необроблений текст:

```markdown
1. Коли ви маєте справу з багаторядковими нумерованими списками, які включають блоки коду, використовуйте відступ пробілу, щоб отримати те, що ви хочете.

    Наприклад: це має відступ на чотири (4) пробіли та представляє новий абзац тексту. Крім того, ми додаємо блок коду. Він також має такі ж чотири (4) пробіли, як і наш абзац:
    ```

2. Ось наш другий пункт у списку. Оскільки ми використали відступ (вище), він відображається з наступною послідовністю нумерації (іншими словами, 2), але якби ми ввели елемент 1 без відступу (у наступному абзаці та коді), тоді це відображалося б як елемент 1 знову, що не те, чого ми хочемо.
```

## Таблиці

У наведеному вище випадку таблиці допомагають нам розмістити параметри команд або типи та описи попереджень. Це показує запис таблиці в розділі «Застереження»:

```text
| type      | Description                                                |
|-----------|------------------------------------------------------------|
| note      | displays text in a blue box                                |
| abstract  | displays text in a light blue box                          |
| info      | displays text in a blue-green box                          |
| tip       | displays text in a  blue-green box (icon slightly greener) |
| success   | displays text in a  green box                              |
| question  | displays text in a light green box                         |
| warning   | displays text in an orange box                             |
| failure   | displays text in a light red box                           |
| danger    | displays text in a  red box                                |
| bug       | displays text in a red box                                 |
| example   | displays text in a purple box                              |
| quote     | displays text in a gray box                                |
| custom^1^ | always displays text in a blue box                         |
| custom^2^ | displays text in a box with the color of the chosen type   |

```

Зауважте, що необов’язково розбивати кожен стовпець за розміром (як ми зробили в першій частині таблиці), але це, звичайно, легше читається у вихідному файлі розмітки. It can get confusing when you string the items together, simply by breaking the columns with the pipe character "|" wherever the natural break is, as you can see in the last item in the table.

## Block quotes

Block quotes are for quoting text from other sources to include in your documentation. Examples of block quotes in markdown would be:

```text
> **предмет** – опис цього предмета

> **інший предмет** – інший опис цього предмета
```

If you are putting two quotes together, you need to separate them by other words to avoid generating a markdown error (as done above).

That ends up looking like this when the page displays:

> **елемент** – опис цього елемента

потім:

> **інший елемент** – інший опис цього елемента

## Inline and block-level code blocks

Наш підхід до використання блоків коду досить простий. Якщо `ваш код` достатньо короткий, щоб ви могли (і хотіли) використати його в реченні, як ви щойно бачили, використовуйте одинарні зворотні лапки ++"\`"++:

```bash
A sentence with a `command of your choosing` in it.
```

Any command that is not used inside of a text paragraph (especially the long bits of code with multiple lines) should be a full code block, defined with triple backticks ++"\`\`\`"++:

````markdown
```bash
sudo dnf install the-kitchen-sink
```
````

Частина `bash` цього форматування є рекомендованим ідентифікатором коду Markdown, але може допомогти з підсвічуванням синтаксису. If you showcase text, Python, PHP, Ruby, HTML, CSS, or any other code, the "bash" will change to whatever language you use.

Incidentally, if you need to show a code block within a code block, add one more backtick ++"\`"++ to the parent block:

`````markdown
````markdown
```bash
sudo dnf install the-kitchen-sink
```
````
`````

Yes, the code block you just saw used five backticks at the beginning and end to make it render correctly.

### Придушення підказки та автоматичного переходу рядка

There might be times when writing documentation when you want to show a prompt in your command but do not want the user to copy that prompt when they use the copy option. An application of this might be writing labs where you want to show the location with the prompt, as in this example:

![copy_option](copy_option.png)

If formatted normally, the copy option will copy the prompt and the command, whereas copying just the command is preferable. To get around this, you can use the following syntax to tell the copy option what you want copied:

````text
``` { .sh data-copy="cd /usr/local" }
[root@localhost root] cd /usr/local
```
````

When using this method, the automatic line feed is also suppressed.

## Keyboard

Інший спосіб додати якомога більше ясності вашим документам - це відобразити правильний спосіб введення клавіш на клавіатурі. У markdown це робиться шляхом обведення клавіші або клавіш подвійним знаком плюс (`++`). Зробіть це за допомогою `++key++`. Наприклад, щоб показати, що вам потрібно натиснути клавішу Escape у вашому документі, ви б використали `++escape++`. Коли вам потрібно вказати на натискання кількох клавіш, додайте знак `+` між ними ось так: `++ctrl+f4++`. Для клавіш, які не визначені (наприклад, нижче ми вказуємо на таємничу функціональну клавішу `Fx`), візьміть визначення в лапки (`++ctrl+"Fx"++`). Якщо потрібно натискати клавіші одночасно, додайте до своїх інструкцій «одночасно» або «одночасно» або іншу подібну фразу. Here is an example of a keyboard instruction in your editor:

```text
Інсталяція типу робочої станції (з графічним інтерфейсом) запускає цей інтерфейс на терміналі 1. Оскільки Linux є багатокористувацькою системою, можна підключити кількох користувачів кілька разів на різних **фізичних терміналах** (TTY) або **віртуальних терміналах** (PTS). Віртуальні термінали доступні в графічному середовищі. Користувач перемикається з одного фізичного термінала на інший за допомогою ++alt+"Fx"++ з командного рядка або ++ctrl+alt+"Fx"++.
```

Here is how that renders when displayed:

A workstation-type installation (with a graphical interface) starts this interface on terminal 1. Оскільки Linux є багатокористувацьким, можна підключати кількох користувачів кілька разів до різних **фізичних терміналів** (TTY) або **віртуальних терміналів** (PTS). Virtual terminals are available within a graphical environment. A user switches from one physical terminal to another using ++alt+"Fx"++ from the command line or ++ctrl+alt+"Fx"++.

Список прийнятих команд клавіатури [у цьому документі](https://facelessuser.github.io/pymdown-extensions/extensions/keys/#key-map-index).

!!! note

    These keyboard shortcuts are always entered in lower case except where a custom keyboard command is used within the quotes.

## Forcing line breaks

There are times when a simple ++enter++ on the keyboard will not give you a new line in markdown. Іноді це трапляється, коли в маркованих елементах використовується багато символів форматування. Ви також можете додати розрив рядка до тексту в кращому форматі. In cases like these, you need to add two spaces to the end of the line where you want a new line.  Since spaces will not be visible in some markdown editors, this example shows the spaces being entered:

- **Елемент маркованого списку з додатковим форматуванням** ++пробіл+пробіл++
- **Ще один елемент**

## Верхній, нижній індекс та спеціальні символи

У документації Rocky Linux підтримуються верхні та нижні індексні нотації за допомогою символів `^` для верхнього індексу та `~` для нижнього індексу. Superscript places text entered between the tags slightly above the normal text, while subscript places the text slightly below. Superscript is by far the more commonly used of these two in writing. Деякі спеціальні символи вже з’являються в верхньому індексі без додавання тегів, але ви також можете комбінувати теги, щоб змінити орієнтацію цих символів, як показано на символі авторського права нижче. You can use superscript to:

- представити порядкові числа, наприклад 1^st^, 2^nd^, 3^rd^
- символи авторського права та торговельних марок, такі як ^&copy;^, ^TM^ або ^&trade;^, ^&reg;&^
- як позначення для посилань, наприклад так^1^, так^2^ та так^3^

Деякі спеціальні символи, такі як &copy;, зазвичай не є верхніми індексами, тоді як інші, такі як &trade;, є.

Here is how all the above looks in your markdown code:

```text
* позначають порядкові числа, такі як 1^st^, 2^nd^, 3^rd^
* символи авторського права та торговельних марок, такі як ^&copy;^, ^TM^ або ^&trade;^, ^&reg;^
* як позначення для посилань, таких як this^1^, this^2^ та this^3^

Деякі спеціальні символи, такі як &copy;, зазвичай не є надрядковими, тоді як інші, такі як &trade;, є.
```

Щоб примусово використовувати верхній індекс, потрібно оточувати потрібний верхній індекс символом `^`.

Введіть нижній індекс, оточивши текст тегом `~` (H~2~0 є `H~2~0`), і, як зазначалося раніше, він не так часто використовується в письмовій формі.

### Верхній індекс для посилань

Декому з вас може знадобитися посилання на зовнішні джерела під час написання документації. If you only have a single source, you can include it in your conclusion as a single link, but if you have multiples^1^, you can use superscript to note them in your text^2^ and then list them at the end of your document. Note that the positioning of references should come after the "Conclusion" section.

Після висновку ви можете мати свої позначки в пронумерованому списку відповідно до верхнього індексу, або ви можете ввести їх як посилання. Shown here are both examples:

1. "How Multiples Are Used In Text" by Wordy W. McWords [https://site1.com](https://site1.com)
2. "Using Superscript In Text" by Sam B. Supersecret [https://site2.com](https://site2.com)

or

[1](https://site1.com) "How Multiples Are Used In Text" by Wordy W. McWords  
[2](https://site2.com) "Using Superscript In Text" by Sam B. Supersecret

Here is what that all looks like in your editor:

```text
1. "How Multiples Are Used In Text" by Wordy W. McWords [https://site1.com](https://site1.com)
2. "Using Superscript In Text" by Sam B. Supersecret [https://site2.com](https://site2.com)

or

[1](https://site1.com) "How Multiples Are Used In Text" by Wordy W. McWords  
[2](https://site2.com) "Using Superscript In Text" by Sam B. Supersecret  

```

## Highlighting text

Ще один можливий спосіб покращити документацію за допомогою ==підсвічування==. You can use highlighting by surrounding the text with `==`.

This looks like this in your editor:

```bash
Ще один можливий спосіб покращити документацію – це використання ==highlighting==. Ви можете використовувати підсвічування, обрамляючи текст у `==`. 
```

## Grouping different formatting types

Rocky documentation offers some elegant formatting options when combining multiple elements within another element. For example, an admonition with a numbered list:

!!! note

    Групування елементів може призвести до певних незручностей. Наприклад, коли:
    
    1. Ви додаєте нумерований список опцій у застереженні
    
    2. Або ви додаєте нумерований список з кількома блоками коду:
    
    `     dnf install some-great-package     `
    
    Який також знаходиться всередині багатоабзацного нумерованого списку.

Or you may have a numbered list, with an additional admonition:

1. Цей елемент є дуже важливим

   Here you are adding a keyboard command to the list item:

   Press ++escape++ for no particular reason.

2. Але цей пункт дуже важливий _і_ має кілька абзаців

   And it has an admonition in the middle of it:

   !!! warning

            З кількома елементами в різних типах форматування може бути трохи складно!

Якщо ви будете стежити за магічними чотирма (4) пробілами, щоб робити відступи та розділяти ці елементи, вони відображатимуться логічно та саме так, як ви хочете. Sometimes that is really important.

You can even embed a table or block quote (literally any formatting item type) within another one. Тут у вас є пронумерований список, попередження, таблиця та деякі елементи блок-цитат, об’єднані разом:

1. Trying to keep up with everything that is going on in your document can be a real task when working with multiple elements.

2. If you are feeling overwhelmed, consider:

       !!! warning "важливо: здається, у мене болить мозок!"

        ```
         Під час поєднання кількох елементів форматування ваш мозок може трохи збожеволіти. Подумайте про те, щоб випити трохи більше кофеїну, перш ніж почати!
        
         | type            |   caffeine daily allowance       |
         |-----------------|----------------------------------|
         | tea             | it will get you there eventually |
         | coffee          | for discerning taste buds        |
         | red bull        | tastes terrible - but it will keep you going! |
         | mountain dew    | over hyped                       |
        
         > **sugar** if caffeine is not to your liking
        
         > **suffer** if all else fails, concentrate more
        ```

3. Many examples exist, but the above illustrates that it is possible to nest everything within. Just remember the four (4) magic spaces.

Here is what this example looks like in your editor:

```text

As long as you keep track of the magic four (4) spaces to separate these items, they will display logically and exactly the way you want them to. Sometimes that is really important.

You can even embed a table or block quote (literally any formatting item type) within another one. Here  have a numbered list, an admonition, a table, and some block quote elements all bundled together:

1. Trying to keep up with everything that is going on in your document can be a real task when working with multiple elements.

2. If you are feeling overwhelmed, consider:

    !!! warning "important: I think my brain hurts!"

        When combining multiple formatting elements, your brain can go a little crazy. Consider sucking down some extra caffeine before you begin!

        | type            |   caffeine daily allowance       |
        |-----------------|----------------------------------|
        | tea             | it will get you there eventually |
        | coffee          | for discerning taste buds        |
        | red bull        | tastes terrible - but it will keep you going! |
        | mountain dew    | over hyped                       |

        > **sugar** if caffeine is not to your liking

        > **suffer** if all else fails, concentrate more

3. Many examples exist, but the above illustrates that it is possible to nest everything within. Just remember the four (4) magic spaces.
```

## Non-displaying characters

У розмітці є деякі символи, які не відображаються належним чином. Іноді це тому, що ці символи є HTML або іншими типами тегів (наприклад, посилання). Під час написання документації можуть виникнути випадки, коли вам **потрібно** відобразити ці символи, щоб донести свою думку. The rule to display these characters is to escape them. Ось таблиця цих символів, що не відображаються, за якою йде блок коду, який показує код таблиці.

| символ                                                      | опис                                                                             |
| ----------------------------------------------------------- | -------------------------------------------------------------------------------- |
| \\                                                        | зворотна коса риска (використовується для екранування)        |
| \\`                                                        | зворотна галочка (використовується для блоків коду)           |
| \*                                                          | зірочка (використовується для списків)                        |
| \_                                    | підкреслення                                                                     |
| \{ \}                                                     | фігурні дужки                                                                    |
| \[ \] | дужки (використовуються для заголовків посилань)              |
| &#60; &#62;         | кутові дужки (використовуються для прямого HTML)              |
| \( \)                                  | круглі дужки (використовуються для вмісту посилання)          |
| \#                                                         | знак фунта (використовується для заголовків уцінки)           |
| &#124;                                  | риска (використовується в таблицях)                           |
| &#43;                                   | знак плюс (використовується в таблицях)                       |
| &#45;                                   | знак мінус або дефіс (використовується в таблицях і маркерах) |
| &#33;                                   | знак оклику (використовується в застереженнях і таблицях)     |

That table in code is:

```table
| symbol      | description                                       |
|-------------|---------------------------------------------------|
| \\          | backslash (used for escaping)                     |
| \`          | backtick (used for code blocks)                   |
| \*          | asterisk (used for bullets)                       |
| \_          | underscore                                        |
| \{ \}       | curly braces                                      |
| \[ \]       | brackets (used for link titles)                   |
| &#60; &#62; | angle brackets (used for direct HTML)             |
| \( \)       | parentheses (used for link content)               |
| \#          | pound sign (used for markdown headers)            |
| &#124;      | pipe (used in tables)                             |
| &#43;       | plus sign (used in tables)                        |
| &#45;       | minus sign or hyphen (used in tables and bullets) |
| &#33;       | exclamation (used in admonitions and tables)      |
```

The last code shows that certain characters require their HTML character code if used in a table.

In actual text, you would escape the character. Наприклад, `\|` покаже символ вертикальної лінії, `\>` покаже символ кутової дужки, `\+` покаже знак плюс, `\-` покаже знак мінус, а `\!` покаже знак оклику.

You can see that if we get rid of the backticks in this sentence:

In actual text, you would escape the character. Наприклад, \| покаже символ вертикальної лінії, \> покаже символ кутової дужки, \+ покаже знак плюс, \- покаже знак мінус, а \! will show the exclamation mark.

## One final item - comments

From time to time, you might want to add a comment to your markdown that will not display when rendered. Many reasons exist for this. If you want to add a placeholder for something that you are adding later, you could use a comment to mark your spot.

The best way to add a comment to your markdown is to use the square brackets "[]" around two forward slashes "//" followed by a colon and the content. This would look like this:

```text

[//]: Цей коментар буде замінено пізніше

```

A comment should have a blank line before and after the comment.

## More reading

- Rocky Linux [документ про те, як зробити внесок] (README.md)

- Більше про [застереження](https://squidfunk.github.io/mkdocs-material/reference/admonitions/#supported-types)

- [Короткий довідник з Markdown](https://wordpress.com/support/markdown-quick-reference/)

- [Більше коротких довідників](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet) для Markdown

## Conclusion

Форматування документа за допомогою заголовків, попереджень, таблиць, нумерованих списків і цитат може додати чіткості вашому документу. Використовуючи поради, подбайте про те, щоб вибрати правильний тип. Це може полегшити візуальне розуміння важливості конкретного застереження.

Вам не _потрібно_ використовувати розширені параметри форматування. Overuse of special elements can add clutter. Навчання використовувати ці елементи форматування консервативно та добре може бути дуже корисним, щоб донести свою точку зору в документі.

Lastly, to make formatting easier, consider changing your markdown editor's TAB value to four (4) spaces.
