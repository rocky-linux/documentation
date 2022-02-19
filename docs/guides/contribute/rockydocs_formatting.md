---
title: Rocky Docs Formatting
author: Steven Spencer
contributors: tianci li
update: 19-Feb-2022
---

# Rocky Docs Formatting - Introduction

Over the last year, a lot has changed with Rocky documentation. This guide is meant to help contributors who want to use admonitions, numbered lists, tables, and more, get the most out of using these markdown tools. To be clear, a document may or may not need to contain any of these elements. If you feel that your document will benefit from them, then this guide should help.

## Admonitions

Admonitions allow you to call attention to important facts and highlight them in a way that makes them stick out from the rest of the text. Admonitions types are as follows:

| type      | Description                                               |
|-----------|-----------------------------------------------------------|
| attention | renders a light orange text box                           |
| caution   | renders a light orange text box                           |
| danger    | renders a red text box                                    |
| error     | renders a red text box                                    |
| hint      | renders a green text box                                  |
| important | renders a green text box                                  |
| note      | renders a blue text box                                   |
| tip       | renders a green text box                                  |
| warning   | renders a orange text box                                 |
| custom <sub>1</sub> | always renders a blue text box                  |
| custom <sub>2</sub> | uses a customer title within another type       |

So there is no limit on the types of admonitions you can use as noted in custom <sub>1</sub> above. A custom title can be added to any of the other admonition types to get the colored box you want for a specific admonition, as noted in custom <sub>2</sub> above. An admonition is always entered in this way:

```
!!! admonition_type

    text of admonition
```
The text here, must be indented four (4) spaces from the beginning margin. It's easy to see where that is in this case, because it will always line up under the first letter of the admonition type. The extra line feed will not show up, but is required for our translation engine (Crowdin) to function correctly.

The following shows examples of each admonition type and how it will format in your document:

!!! attention

    text

!!! caution

    text

!!! danger

    text

!!! error

    text

!!! hint

    text

!!! important

    text

!!! note

    text

!!! tip

    text

!!! warning

    text

!!! custom                        

    A custom  <sub>1</sub> type. Here we've used "custom" as our admonition type. Again, this will always render in blue.

!!! warning "custom title"

    A custom <sub>2</sub> type. Here we've modified the "warning" admonition type with a custom header. Here's what that looks like:

    ```
    !!! warning "custom title"
    ```

## Numbered Lists

Numbered lists sound like they are easy to create and use, and once you get the hang of them, they really are. If you just have a single list of items with no complexity, then this sort of format works fine:

```
1. Item 1

2. Item 2

3. Item 3
```

1. Item 1

2. Item 2

3. Item 3

If you need to add code blocks, multiple lines or even paragraphs of text to a numbered list, then the text should be indented with those same four (4) spaces that we used in the admonitions. You can't use your eyes to line them up under the numbered item, however, as this is one space off. If you are using a good markdown editor, you can set your tab value to four (4), which will make entering the following easier. Here's an example of a multi-line numbered list with a code block thrown in for good measure:

1. When dealing with numbered lists that are multi line and include things like code blocks, use the space indentation to get what you want.

    For example: this is indented four (4) spaces and represents a new paragraph of text. And here, we are adding a code block in. It is also indented by the same four (4) spaces as our paragraph:

    ```
    dnf update
    ```

2. Here's our second listed item. Because we used the indentation (above) it renders with the next sequence of numbering (in other words, 2), but if we had entered item 1 without the indentation (in the subsequent paragraph and code), then this would show up as item 1 again, which is not what we want.

## Tables

Another formatting item is the use of tables. Tables help us to lay out command options, or in the above case, admonition types and descriptions. Here's how the table above is entered:

```
| type      | Description                                               |
|-----------|-----------------------------------------------------------|
| attention | renders a light orange text box                           |
| caution   | renders a light orange text box                           |
| danger    | renders a red text box                                    |
| error     | renders a red text box                                    |
| hint      | renders a green text box                                  |
| important | renders a green text box                                  |
| note      | renders a blue text box                                   |
| tip       | renders a green text box                                  |
| warning   | renders a orange text box                                 |
| custom <sub>1</sub> | always renders a blue text box                  |
| custom <sub>2</sub> | uses a customer title within another type       |
```

Note that it isn't necessary to have each column broken down by size (as we've done in the first part of the table), but it is certainly more readable in the source documentation page, than stringing the  items together, simply by breaking the columns with the pipe character "|" wherever the natural break would be, as in the last two items of the table.

## Block Quotes

Block quotes are actually designed for quoting text from other sources to include in your documentation, but they don't have to be used that way. We've had several people use block quotes instead of tables, for instance, to list out some options. Examples of block quotes in markdown would be:

```
> **an item** - A description of that item

> **another item** - Another description of that item
```
To avoid these running together, the extra line feed here is necessary.

That ends up looking like this when the page is rendered:

> **an item** - A description of that item

> **another item** - Another description of  an item

## Grouping Different Formatting Types

Thins really get crazy, when you need to combine multiple elements within another one. For instance, an admonition with a numbered list:

!!! note

    Things can get a little crazy when you are grouping things together. Like when:

    1. You add a numbered list of options within an admonition

    2. Or you add a numbered list with multiple code blocks:

        ```
        dnf install some-great-package
        ```

        Which is also within a multi-paragraph numbered list.

Or what if you have a numbered list, with an additional admonition:

1. This item is something very important

2. But this item is something very important and has multiple paragraphs to it

    And it has an admonition in the middle of it:

    !!! warning

        Things can get a little crazy with multiple elements within different formatting types!   

As long as you keep track of the magic four (4) spaces to separate these items, they will display logically and exactly the way you want them to. Sometimes that is really important.

You can even embed a table or block quote (quite literally any formatting item type) within another one. Here we have a numbered list, an admonition, a table and some block quote elements all bundled together:

1. Trying to keep up with everything that's going on in your document can be a real task when there are multiple elements to be considered.

2. If you are feeling overwhelmed, consider:

    !!! important "important: I think my brain hurts!"

        When combining multiple formatting elements, your brain can go a little crazy. Consider sucking down some extra caffeine before you begin!

        | type            |   caffeine daily allowance       |
        |-----------------|----------------------------------|
        | tea             | it will get you there eventually |
        | coffee          | for discerning taste buds        |
        | red bull        | tastes terrible - but it will keep you going!|
        | mountain dew    | over hyped                       |

        > **sugar** if caffeine isn't to your liking

        > **suffer** if all else fails, concentrate more

3. There are more examples, but I think you get that everything can be nested within. Just remember the four (4) magic spaces.

Here's what this example looks like in your editor:

```
As long as you keep track of the magic four (4) spaces to separate these items, they will display logically and exactly the way you want them to. Sometimes that is really important.

You can even embed a table or block quote (quite literally any formatting item type) within another one. Here we have a numbered list, an admonition, a table and some block quote elements all bundled together:

1. Trying to keep up with everything that's going on in your document can be a real task when there are multiple elements to be considered.

2. If you are feeling overwhelmed, consider:

    !!! important "important: I think my brain hurts!"

        When combining multiple formatting elements, your brain can go a little crazy. Consider sucking down some extra caffeine before you begin!

        | type            |   caffeine daily allowance       |
        |-----------------|----------------------------------|
        | tea             | it will get you there eventually |
        | coffee          | for discerning taste buds        |
        | red bull        | tastes terrible - but it will keep you going!|
        | mountain dew    | over hyped                       |

        > **sugar** if caffeine isn't to your liking

        > **suffer** if all else fails, concentrate more

3. There are more examples, but I think you get that everything can be nested within. Just remember the four (4) magic spaces.
```

## More Reading

* The Rocky Linux [how to contribute document](README.md)

* More on [admonitions](https://squidfunk.github.io/mkdocs-material/reference/admonitions/#supported-types)

* More on [markdown quick reference](https://wordpress.com/support/markdown-quick-reference/)

* More on [more quick references](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet)

## Conclusion

Document formatting with admonitions, tables, numbered lists, and block quotes, can add clarity to your document. When using admonitions, take care to pick the correct type. This can make it easier to visually see the importance of the admonition. Overuse of any of these elements can simply add clutter where none is needed. Learning to use these formatting items conservatively and well can be very helpful to get your point across in a document. To make formatting easier, consider changing your markdown editor's TAB value to four (4) spaces.
