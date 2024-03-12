---
title: Document Formatting
author: Steven Spencer
contributors: tianci li, Ezequiel Bruni, Krista Burdine, Ganna Zhyrnova
tags:
  - contribute
  - formatting
---

# Introduction

This guide highlights our more advanced formatting options, including admonitions, numbered lists, tables, and more.

A document may or may not need to contain any of these elements. If you feel your document will benefit from special formatting, then this guide should help.

!!! note "A Note About Headings"

    Headings are not special formatting characters; rather they are standard markdown syntax. They include a **single** level one heading:

    ```
    # This is Level one
    ```

    and any number of sub-heading values, levels 2 through 6:

    ```
    ## A Level 2 heading
    ### A Level 3 heading
    #### A Level 4 heading
    ##### A Level 5 heading
    ###### A Level 6 heading
    ```

    The key here is that you can use as many of the 2 through 6 headings as necessary, but only **ONE** level 1 heading. While the document will appear correct with more than one level 1 heading, the automatically generated table of contents for the document that appears on the right-hand side will **NOT** display correctly (or sometimes at all) with more than one. Keep this in mind when writing your documents.

!!! warning "A note about supported HTML elements"

    There are HTML elements that are technically supported in markdown. Some of these are described in this document where no markdown syntax exists to replace them. These supported HTML tags should be used rarely, because markdown linters will complain about them in a document. For example:

    * Inline HTML [element name]

    If you need to use a supported HTML element, see if you can find another way to write your document that will not use these elements. If you must use them, it is still allowed.

## Admonitions

Admonitions are special visual "boxes" that allow you to call attention to important facts and highlight them. Following are types of admonitions:

| type      | Description                                               |
|-----------|-----------------------------------------------------------|
| note      | displays text in a blue box                                   |
| abstract  | displays text in a light blue box                             |
| info      | displays text in a blue-green box                             |
| tip       | displays text in a blue-green box (icon slightly greener)     |
| success   | displays text in a green box                                  |
| question  | displays text in a light green box                            |
| warning   | displays text in a orange box                                 |
| failure   | displays text in a light red box                              |
| danger    | displays text in a red box                                    |
| bug       | displays text in a red box                                    |
| example   | displays text in a purple box                                 |
| quote     | displays text in a grey box                                   |
| custom ^1^ | always displays text in a blue box                  |
| custom ^2^ | displays text in the color of the box of the chosen type |

Admonitions are limitless, as noted in custom <sub>1</sub> above. It is possible to add a custom title to any admonition type to get the box color you want for a specific admonition, as noted in custom <sub>2</sub> above.

An admonition is always entered in this way:

```text
!!! admonition_type "custom title if any"

    text of admonition
```

The body text of the admonition must have a four (4) space indentation from the beginning margin. It is easy to see where that is because it will always line up under the first letter of the admonition type. The extra line between the title and body will not show up but our translation engine (Crowdin) needs these to function correctly.

Here are examples of each admonition type, and how they will look in your document:

!!! note

    text

!!! abstract

    text

!!! info

    text

!!! tip

    text

!!! success

    text

!!! question

    text

!!! warning

    text

!!! failure

    text

!!! danger

    text

!!! custom

    A custom^1^ type. We have used "custom" as our admonition type. Again, this will always render in blue.

!!! warning "custom title"

    A custom^2^ type. We have modified the "warning" admonition type with a custom header. Here is what that looks like:

    ```
    !!! warning "custom title"
    ```

### Expandable admonitions

If an admonition has very long content, consider an expandable admonition. It has the same characteristics of a regular admonition but starts with three question marks, rather than three exclamation marks. All the other admonition rules apply. An expandable admonition looks like this:

??? warning "Warning Content"

    This is a warning, with not very much content. You would want to use a regular admonition for this, but Hey, this is just an example!

Which looks like this in your editor:

```text
??? warning "Warning Content"
    
    This is a warning, with not very much content. You would want to use a regular admonition for this, but Hey, this is just an example!
```

## Tabbed content within a document

Formatting tabbed content is similar to admonitions. Instead of three exclamation marks or three question marks, it begins with three equal signs. All the admonition formatting (4 spaces, and so on) applies to this content. For example, a document might need a different procedure for a different Rocky Linux version. When using tabbed content for versions, the most recent release of Rocky Linux should come first. At the time of this writing that was 9.0:

=== "9.0"

    The procedure for doing this in 9.0

=== "8.6"

    The procedure for doing this in 8.6

Which would look like this in your editor:

```text
=== "9.0"

    The procedure for doing this in 9.0

=== "8.6"

    The procedure for doing this in 8.6
```

Remember that everything that falls inside of the section must continue to use the 4-space indentation until completion of the section. This is a very handy feature!

## Numbered lists

Numbered lists sound like they are easy to create and use, and once you get the hang of them, they really are. If you just have a single list of items with no complexity, then this sort of format works fine:

```text
1. Item 1

2. Item 2

3. Item 3
```

1. Item 1

2. Item 2

3. Item 3

If you need to add code blocks, multiple lines or even paragraphs of text to a numbered list, then the text must have the same four (4) space indentation that you used in the admonitions.

However, you cannot use your eyes to line them up under the numbered item because this is one space off. If you use a good markdown editor, you can set your tab value to four (4), which will make formatting everything a bit easier.

Here is an example of a multi-line numbered list with a code block thrown in for good measure:

1. When dealing with multi-line numbered lists that include code blocks or other elements, use the space indentation to get what you want.

    For example: this has the four (4) space indentation and represents a new paragraph of text. In addition, we are adding a code block in. It is also indented by the same four (4) spaces as our paragraph:

    ```bash
    dnf update
    ```

2. Here is our second listed item. Because you used the four (4) space indentation (above), it renders with the next sequence of numbering (2), but if you had entered item 1 without the indentation (in the subsequent paragraph and code), then this would show up as item 1 again, which is not what you want.

And here is how that looks as raw text:

```markdown
1. When dealing with multi-line numbered lists that include code blocks or other elements, use the space indentation to get what you want.

    For example: this has the four (4) space indentation and represents a new paragraph of text. In addition, we are adding a code block in. It is also indented by the same four (4) spaces as our paragraph:

    ```bash
    dnf update
    ```

2. Here is our second listed item. Because you used the four (4) space indentation (above), it renders with the next sequence of numbering (2), but if you had entered item 1 without the indentation (in the subsequent paragraph and code), then this would show up as item 1 again, which is not what you want.
```

## Tables

In the above case, tables help us lay out command options or admonition types and descriptions. Here is how the table in the Admonitions section was entered:

```text
| type      | Description                                               |
|-----------|-----------------------------------------------------------|
| note      | displays text in a blue box                                   |
| abstract  | displays text in a light blue box                             |
| info      | displays text in a blue-green box                             |
| tip       | displays text in a  blue-green box (icon slightly greener)    |
| success   | displays text in a  green box                                 |
| question  | displays text in a light green box                            |
| warning   | displays text in a orange box                                 |
| failure   | displays text in a light red box                              |
| danger    | displays text in a  red box                                   |
| bug       | displays text in a red box                                    |
| example   | displays text in a purple box                                 |
| quote     | displays text in a grey box                                   |
| custom^1^ | always displays text in a blue box                  |
| custom^2^ | displays text in a box with the color of the chosen type |

```

Note that it is not necessary to have each column broken down by size (as we have done in the first part of the table), but it is certainly more readable in the markdown source file. It can get confusing when you string the items together, simply by breaking the columns with the pipe character "|" wherever the natural break is, as you can see in the last item in the table.

## Block quotes

Block quotes are actually designed for quoting text from other sources to include in your documentation, but using them that way is not required. Some contributors use block quotes instead of tables, for instance, to list out some options. Examples of block quotes in markdown would be:

```text
> **an item** - A description of that item

> **another item** - Another description of that item
```

Multiple block quotes need to be separated by blank lines in the middle to indicate that they are multiple block quotes.

That ends up looking like this when the page displays:

> **an item** - A description of that item

> **another item** - Another description of  an item

When you want to hierarchically display individual referenced content, it looks like this in the editor:

```text
> JAVA
>> Python
>>> C
>>>> Go
```

The display is as follows:

> JAVA
>> Python
>>> C
>>>> Golang

When you use five spaces after the ">" symbol, it will produce some special effects, such as:

```
> Code

>     Code
```

The display is as follows:

> Code

>     Code

## Inline and block-level code blocks

Our approach to the use of code blocks is pretty simple. If `your code` is short enough that you can (and want to) use it in a sentence like you just saw, use single backticks ++"`"++:

```bash
A sentence with a `command of your choosing` in it.
```

Any command that is not used inside of a text paragraph (especially the long bits of code with multiple lines) should be a full code block, defined with triple backticks ++"```"++:

````markdown
```bash
sudo dnf install the-kitchen-sink
```
````

The `bash` bit of that formatting is a markdown recommended code identifier but can help with syntax highlighting. If you showcase text, Python, PHP, Ruby, HTML, CSS, or any other kind of code, the "bash" will change to whatever language you use.

Incidentally, if you need to show a code block within a code block, just add one more backtick ++"`"++ to the parent block:

`````markdown
````markdown
```bash
sudo dnf install the-kitchen-sink
```
````
`````

And yes, the code block you just saw used five backticks at the beginning and end to make it render properly.

### Suppressing the displayed prompt and automatic line feed

There might be times when writing documentation where you want to show a prompt in your command, but you do not want the user to copy that prompt when they use the copy option. An application of this might be writing labs where you want to show the location with the prompt as in this example:

![copy_option](copy_option.png)

If formatted normally, the copy option will copy the prompt and the command, where copying just the command is preferable. To get around this, you can use the following syntax to tell the copy option what you want copied:

````text
``` { .sh data-copy="cd /usr/local" }
[root@localhost root] cd /usr/local
```
````

When using this method, the automatic line feed is also suppressed.

## Keyboard

Another way to add as much clarity to your documents as possible is to represent the entering of keys on a keyboard in the correct manner. In markdown, do this by surrounding the key or keys with double plus signs (`++`) Do this with `++key++`. For instance, to represent that you need to hit the escape key in your document you would use `++escape++`. When you need to indicate the pressing of multiple keys, add a `+` between them like this: `++ctrl+f4++`. For keys that aren't defined (for instance we are indicating a mystery function key, `Fx` below) put your definition in quotes (`++ctrl+"Fx"++`). If requiring the pressing of keys simultaneously, add "simultaneously" or "at the same time" or some similar phrase to your instructions. Here is an example of a keyboard instruction in your editor:

```text
A workstation type installation (with graphical interface) starts this interface on terminal 1. Linux being multi-user, it is possible to connect several users several times, on different **physical terminals** (TTY) or **virtual terminals** (PTS). Virtual terminals are available within a graphical environment. A user switches from one physical terminal to another using ++alt+"Fx"++ from the command line or using ++ctrl+alt+"Fx"++.
```

Here is how that renders when displayed:

A workstation type installation (with graphical interface) starts this interface on terminal 1. Linux being multi-user, it is possible to connect several users several times, on different **physical terminals** (TTY) or **virtual terminals** (PTS). Virtual terminals are available within a graphical environment. A user switches from one physical terminal to another using ++alt+"Fx"++ from the command line or using ++ctrl+alt+"Fx"++.

A list of accepted keyboard commands [in this document](https://facelessuser.github.io/pymdown-extensions/extensions/keys/#key-map-index).

!!! note

    These keyboard shortcuts are always entered in lower case except where a custom keyboard command is used within the quotes.

## Superscript, subscript and special symbols

Superscript and subscript notation are supported in Rocky Linux documentation by use of the `^` for superscript and `~` for subscript. Superscript places text entered between the tags slightly above the normal text, while subscript places the text slightly below. Superscript is by far the more commonly used of these two in writing. Some special characters already appear in superscript without adding the tags, but you can also combine the tag to change the orientation of those characters as seen with the copyright symbol below. You can use superscript to:

* represent ordinal numbers, such as 1^st^, 2^nd^, 3^rd^
* copyright and trademark symbols, like ^&copy;^, ^TM^, or ^&trade;^, ^&reg;&^
* as notation for references, such as this^1^, this^2^ and this^3^

Some of the special characters, such as &copy; are not normally superscript, while others such as &trade;, are.

Here is how all the above looks in your markdown code:

```text
* represent ordinal numbers, such as 1^st^, 2^nd^, 3^rd^
* copyright and trademark symbols, like ^&copy;^, ^TM^ or ^&trade;^, ^&reg;^
* as notation for references, such as this^1^, this^2^ and this^3^

Some of the special characters, such as &copy; are not normally superscript, while others such as &trade;, are.
```

To force superscript you surround what you want superscript with `^`.

Enter subscript by surrounding your text with the `~` tag (H~2~0 is `H~2~0`) and as noted earlier, is not used nearly as much in writing.

### Superscript for references

Some of you may feel the need to reference outside sources when writing documentation. If you only have a single source, you can include it in your conclusion as a single link, but if you have multiples^1^, you can use superscript to note them in your text^2^ and then list them at the end of your document. Note that the positioning of references should come after the "Conclusion" section.

Following the conclusion, you can have your notations in a numbered list to match the superscript, or you can enter them as links. Both examples are shown here:

1. "How Multiples Are Used In Text" by Wordy W. McWords [https://site1.com](https://site1.com)
2. "Using Superscript In Text" by Sam B. Supersecret [https://site2.com](https://site2.com)

or

[1](https://site1.com) "How Multiples Are Used In Text" by Wordy W. McWords  
[2](https://site2.com) "Using Superscript In Text" by Sam B. Supersecret  

And here is what that all looks like in your editor:

```text
1. "How Multiples Are Used In Text" by Wordy W. McWords [https://site1.com](https://site1.com)
2. "Using Superscript In Text" by Sam B. Supersecret [https://site2.com](https://site2.com)

or

[1](https://site1.com) "How Multiples Are Used In Text" by Wordy W. McWords  
[2](https://site2.com) "Using Superscript In Text" by Sam B. Supersecret  

```

## Highlighting text

Another possible way to enhance documentation is with ==highlighting==. Highlighting is handled by surrounding the text with `==`.

This looks like this in your editor:

```bash
Another possible way to enhance documentation is with ==highlighting==. Highlighting is handled by surrounding the text with `==`. 
```

## Grouping different formatting types

Rocky documentation offers some elegant formatting options when combining multiple elements within another element. For instance, an admonition with a numbered list:

!!! note

    Things can get a little crazy when you are grouping things together. Like when:

    1. You add a numbered list of options within an admonition

    2. Or you add a numbered list with multiple code blocks:

        ```
        dnf install some-great-package
        ```

        Which is also within a multi-paragraph numbered list.

Or you may have a numbered list, with an additional admonition:

1. This item is something very important

    Here you are adding a keyboard command to the list item:

    Press ++escape++ for no particular reason.

2. But this item is something very important *and* has multiple paragraphs to it

    And it has an admonition in the middle of it:

    !!! warning

        Things can get a little crazy with multiple elements within different formatting types!   

If you keep track of the magic four (4) spaces to indent and separate these items, they will display logically and exactly the way you want them to. Sometimes that is really important.

You can even embed a table or block quote (literally any formatting item type) within another one. Here you have a numbered list, an admonition, a table and some block quote elements all bundled together:

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

Here is what this example looks like in your editor:

```text

As long as you keep track of the magic four (4) spaces to separate these items, they will display logically and exactly the way you want them to. Sometimes that is really important.

You can even embed a table or block quote (literally any formatting item type) within another one. Here  have a numbered list, an admonition, a table and some block quote elements all bundled together:

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

## One final item - comments

From time to time, you may want to add a comment to your markdown that will not display when rendered. Many reasons exist for this. For instance, if you want to add a placeholder for something that will be added later, you could use a comment to mark your spot.

The best way to add a comment to your markdown is to use the square brackets "[]" around two forward slashes "//" followed by a colon and the content. This would look like this:

```text

[//]: This is a comment to be replaced later

```

A comment should have a blank line before and after the comment.

## More reading

* The Rocky Linux [how to contribute document](README.md)

* More on [admonitions](https://squidfunk.github.io/mkdocs-material/reference/admonitions/#supported-types)

* [Markdown quick reference](https://wordpress.com/support/markdown-quick-reference/)

* [More quick references](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet) for Markdown

## Conclusion

Document formatting with headings, admonitions, tables, numbered lists, and block quotes can add clarity to your document. When using admonitions, take care to pick the correct type. This can make it easier to visually see the importance of the particular admonition.

You do not *have* to use advanced formatting options. Overuse of special elements can add clutter where none is needed. Learning to use these formatting items conservatively and well can be very helpful to get your point across in a document.

Lastly, to make formatting easier, consider changing your markdown editor's TAB value to four (4) spaces.
