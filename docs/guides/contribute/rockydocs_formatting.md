---
title: Document Formatting
author: Steven Spencer
contributors: tianci li, Ezequiel Bruni, Krista Burdine, Ganna Zhyrnova
tags:
  - contribute
  - formatting
---

## Introduction

This guide highlights our more advanced formatting options, including admonitions, numbered lists, tables, and more.

A document might or might not need to contain any of these elements. However, if you feel your document will benefit from special formatting, this guide should help.

!!! note "A Note About Headings"

    Headings are not special formatting characters; instead, they are standard markdown syntax. They include a **single** level one heading:

    ```
    # This is Level one
    ```

    And any number of sub-heading values, levels 2 through 6:

    ```
    ## A Level 2 heading
    ### A Level 3 heading
    #### A Level 4 heading
    ##### A Level 5 heading
    ###### A Level 6 heading
    ```

    The key here is that you can use as many of the 2 through 6 headings as necessary, but only **ONE** level 1 heading. While the document will appear correct with more than one level 1 heading, the automatically generated table of contents for the document that appears on the right-hand side will **NOT** display correctly (or sometimes at all) with more than one. Keep this in mind when writing your documents.

    Another important note about the Level 1 heading: If the `title:` meta is in use, then this will be the default Level 1 heading. You should not add another one. An example is that this document's title meta is:

    ```
    ---
    title: Document Formatting
    ```

    The very first heading added, then, is "Introduction" at Level 2.

    ```
    ## Introduction
    ```

!!! warning "A note about supported HTML elements"

    There are HTML elements that are technically supported in Markdown. Some of these are described in this document, and there is no Markdown syntax to replace them. These supported HTML tags should be used rarely, because markdown linters will complain about them in a document. For example:

    * Inline HTML [element name]

    If you need to use a supported HTML element, you can see if you can find another way to write your document that will not use these elements. If you must use them, it is still allowed.

!!! info "A Note About Links"

    Links are not special formatting; they are standard methods for referencing other documents (internal links) or external web pages. However, there is one particular type of link you should not use when composing documents for Rocky Linux: an anchor, or a link to a spot in the same document.

    Anchors work in the source language for Rocky Linux (English), but as soon as our Crowdin interface translates them, they break in those languages. This happens because an acceptable anchor in markdown that does not contain HTML elements uses the header to create the link:

    ```
    ## A Header

    Some text

    A Link to [that header](#-a-header)
    ```

    This link is found by hovering your mouse over the permalink in a created document and is essentially the header with the "#" plus the header in lowercase, separated by a dash (-).

    When the document is translated, though, the header is translated, BUT the link is outside of what Crowdin allows to be translated, so it remains in its original (English) state.

    If you need to use an anchor, please review your document to see if reorganizing the content makes it unnecessary. Just know that if you use an anchor in a newly composed document, that anchor will break once translation of that document occurs.

## Admonitions

Admonitions are special visual "boxes" that call attention to important facts and highlight them. The following are types of admonitions:

| type       | Description                                               |
|------------|-----------------------------------------------------------|
| note       | displays text in a blue box                               |
| abstract   | displays text in a light blue box                         |
| info       | displays text in a blue-green box                         |
| tip        | displays text in a blue-green box (icon slightly greener) |
| success    | displays text in a green box                              |
| question   | displays text in a light green box                        |
| warning    | displays text in an orange box                            |
| failure    | displays text in a light red box                          |
| danger     | displays text in a red box                                |
| bug        | displays text in a red box                                |
| example    | displays text in a purple box                             |
| quote      | displays text in a gray box                               |
| custom ^1^ | always displays text in a blue box                        |
| custom ^2^ | displays text in the color of the box of the chosen type  |

As noted in custom <sub>1</sub> above, admonitions are limitless. Add a custom title to any admonition type to get the box color you want for a specific admonition, as noted in custom <sub>2</sub> above.

An admonition is always entered in this way:

```text
!!! admonition_type "custom title if any"

    text of admonition
```

The body text of the admonition must have a four (4) space indentation from the beginning margin. It is easy to see where that is because it will always line up under the first letter of the admonition type. The extra line between the title and body will not appear, but our translation engine (Crowdin) needs these to function correctly.

Here are examples of each admonition type and how they will look in your document:

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

If an admonition is very long, consider an expandable admonition. It has the same characteristics of a regular admonition but starts with three question marks, rather than three exclamation marks. All the other admonition rules apply. An expandable admonition looks like this:

??? warning "Warning Content"

    This is a warning with very little content. You would want to use a regular admonition for this, but Hey, this is just an example!

Which looks like this in your editor:

```text
??? warning "Warning Content"
    
    This is a warning, with not very much content. You would want to use a regular admonition for this, but Hey, this is just an example!
```

## Tabbed content within a document

Formatting tabbed content is similar to admonitions. Instead of three exclamation marks or question marks, it begins with three equal signs. All the admonition formatting (4 spaces and so on) applies to this content. For example, a document might need a different procedure based on how the operating system was installed. With the implementation of documentation versioning, tabbed content formatting should no longer be necessary to separate full version content (for instance, 9.6 and 8.10).

=== "9"

    Use this procedure if you performed your installation with the whole operating system or a Live image.

=== "9-minimal"

    Use this procedure if you installed your operating system from the minimal ISO.

Which would look like this in your editor:

```text
=== "9"


    Use this procedure if you performed your installation with the whole operating system or a Live image.

=== "9-minimal"

    Use this procedure if you installed your operating system from the minimal ISO.
 
```

Just to remind you, everything within the section must continue to use 4-space indentation until the completion of this section. This is a convenient feature!

## Numbered lists

Numbered lists sound easy to create and use, and once you get the hang of them, they are. If you have a single list of items with no complexity, then this sort of format works fine:

```text
1. Item 1

1. Item 2

1. Item 3
```

1. Item 1

1. Item 2

1. Item 3

If you need to add code blocks, multiple lines, or even paragraphs of text to a numbered list, then the text must have the same four (4) space indentation you used in the admonitions.

However, you cannot use your eyes to line them up under the numbered item because this is one space off. If you use a good markdown editor, you can set your tab value to four (4), making formatting everything easier.

Here is an example of a multi-line numbered list with a code block thrown in for good measure:

1. When dealing with multi-line numbered lists that include code blocks or other elements, use the space indentation to get what you want.

    For example: this has the four (4) space indentation and represents a new paragraph of text. In addition, we are adding a code block in. It is also indented by the same four (4) spaces as our paragraph:

    ```bash
    dnf update
    ```

1. Here is our second listed item. Because you used the four (4) space indentation (above), it renders with the next sequence of numbering (2). If you had entered item 1 without the indentation (in the subsequent paragraph and code), then this would show up as item 1 again, which is not what you want.

And here is how that looks as raw text:

```markdown
1. When dealing with multi-line numbered lists that include code blocks or other elements, use the space indentation to get what you want.

    For example: this has the four (4) space indentation and represents a new paragraph of text. In addition, we are adding a code block in. It is also indented by the same four (4) spaces as our paragraph:

    ```bash
    dnf update
    ```

1. Here is our second listed item. Because you used the four (4) space indentation (above), it renders with the next sequence of numbering (2). Still, if you had entered item 1 without the indentation (in the subsequent paragraph and code), then this would show up as item 1 again, which is not what you want.
```


!!! tip "Numbering the numbered list does not necessarily correspond to the actual number displayed."

    When including a numbered (ordered) list, the natural inclination of the author is to number them in sequence, but Markdown actually handles this task itself, and therefor numbering in sequence has no effect on the actual number shown. What matters is the formattting (spaces, indentation, and so on). As an example, these two lists are functionally the same:

    ```text
    1. This is item 1
    2. This is item 2
    ```

    and

    ```text
    1. This is item 1
    
    1. This is item 2
    ```

    Here is how they both render in markdown:

    1. This is item 1
    2. This is item 2
    
    and

    1. This is item 1
    
    1. This is item 2

    To make things more complicated visually, some editors may strip away manually added numbers and replace them with "1" BUT if you are editing a document and adding numbered list items, the same editor will helpfully number sequentially for you so that you are seeing the correct number. When saved, these editors will strip away the sequential numbers and replace them with the same "1". 

    Just be aware that if you see what you think are the removal of the numbered lists sequences by an author, that this may have happened from the editor they use and probably will not affect the markdown rendered numbered sequence.

    As further proof of this, when the author pulled this document in to add this note, the editor stripped away the numbered list items shown at the top of this section and replaced them all with 1. They still render correctly as 1, 2, 3, and so on.

## Tables

In the above case, tables help us lay out command options or admonition types and descriptions. This shows the entry of the table in the Admonitions section:

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

Note that it is not necessary to break each column by size (as we did in the first part of the table), but it is certainly more readable in the markdown source file. It can get confusing when you string the items together, simply by breaking the columns with the pipe character "|" wherever the natural break is, as you can see in the last item in the table.

## Block quotes

Block quotes are for quoting text from other sources to include in your documentation. Examples of block quotes in markdown would be:

```text
> **an item** - A description of that item

Followed by:

> **another item** - Another description of that item
```

If you are putting two quotes together, you need to separate them by other words to avoid generating a markdown error (as done above).

That ends up looking like this when the page displays:

> **an item** - A description of that item

Followed by:

> **another item** - Another description of that item

## Inline and block-level code blocks

Our approach to code blocks is pretty simple. If `your code` is short enough that you can (and want to) use it in a sentence like you just saw, use single backticks ++"`"++:

```bash
A sentence with a `command of your choosing` in it.
```

Any command that is not used inside of a text paragraph (especially the long bits of code with multiple lines) should be a full code block, defined with triple backticks ++"```"++:

````markdown
```bash
sudo dnf install the-kitchen-sink
```
````

The `bash` bit of that formatting is a markdown recommended code identifier but can help with syntax highlighting. If you showcase text, Python, PHP, Ruby, HTML, CSS, or any other code, the "bash" will change to whatever language you use.

Incidentally, if you need to show a code block within a code block, add one more backtick ++"`"++ to the parent block:

`````markdown
````markdown
```bash
sudo dnf install the-kitchen-sink
```
````
`````

Yes, the code block you just saw used five backticks at the beginning and end to make it render correctly.

### Suppressing the displayed prompt and automatic line feed

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

Another way to add as much clarity as possible to your documents is to show the correct way to enter keys on a keyboard. In markdown, do this by surrounding the key or keys with double plus signs (`++`). Do this with `++key++`. For instance, to represent that you need to hit the escape key in your document, you would use `++escape++`. When you need to indicate the pressing of multiple keys, add a `+` between them like this: `++ctrl+f4++`. For keys that aren't defined (for instance, we are indicating a mystery function key, `Fx` below), put your definition in quotes (`++ctrl+"Fx"++`). If requiring simultaneous key pressing, add "simultaneously," "at the same time," or a similar phrase to your instructions. Here is an example of a keyboard instruction in your editor:

```text
A workstation-type installation (with a graphical interface) starts this interface on terminal 1. Since Linux is multi-user, it is possible to connect several users simultaneously to different **physical terminals** (TTYs) or **virtual terminals** (PTSs). Virtual terminals are available within a graphical environment. A user switches from one physical terminal to another using ++alt+"Fx"++ from the command line or ++ctrl+alt+"Fx"++.
```

Here is how that renders when displayed:

A workstation-type installation (with a graphical interface) starts this interface on terminal 1. Since Linux is multi-user, it is possible to connect several users simultaneously to different **physical terminals** (TTYs) or **virtual terminals** (PTSs). Virtual terminals are available within a graphical environment. A user switches from one physical terminal to another using ++alt+"Fx"++ from the command line or ++ctrl+alt+"Fx"++.

A list of accepted keyboard commands [in this document](https://facelessuser.github.io/pymdown-extensions/extensions/keys/#key-map-index).

!!! note

    These keyboard shortcuts are always entered in lower case except where a custom keyboard command is used within the quotes.

## Forcing line breaks

There are times when a simple ++enter++ on the keyboard will not give you a new line in markdown. This sometimes occurs when bulleted items contain many formatting characters. The suggestion is to add a line break to better format text as well. In cases like these, you need to add two spaces to the end of the line where you want a new line.  Since spaces will not be visible in some markdown editors, this example shows the spaces being entered:

* **A bullet item with extra formatting** ++space+space++
* **Another item**

## Superscript, subscript, and special symbols

Superscript and subscript notation are supported in Rocky Linux documentation by use of the `^` for superscript and `~` for subscript. Superscript places text entered between the tags slightly above the normal text, while subscript places the text slightly below. Superscript is by far the more commonly used of these two in writing. Some special characters already appear in superscript without adding the tags. Still, you can also combine the tag to change the orientation of those characters, as seen with the copyright symbol below. You can use superscript to:

* represent ordinal numbers, such as 1^st^, 2^nd^, 3^rd^
* copyright and trademark symbols, like ^&copy;^, ^TM^, or ^&trade;^, ^&reg;&^
* as notation for references, such as this^1^, this^2^, and this^3^

Some of the special characters, such as &copy;, are generally not superscript, while others, such as &trade;, are.

Here is how all the above looks in your markdown code:

```text
* represent ordinal numbers, such as 1^st^, 2^nd^, 3^rd^
* copyright and trademark symbols, like ^&copy;^, ^TM^ or ^&trade;^, ^&reg;^
* as notation for references, such as this^1^, this^2^, and this^3^

Some special characters, such as &copy; are generally not superscript, while others such as &trade;, are.
```

To force superscript, you surround what you want superscripted with `^`.

Enter subscript by surrounding your text with the `~` tag (H~2~0 is `H~2~0`), and as noted earlier, it is not used nearly as much in writing.

### Superscript for references

Some of you may need to consult external sources when writing documentation. If you only have a single source, you can include it in your conclusion as a single link, but if you have multiples^1^, you can use superscript to note them in your text^2^ and then list them at the end of your document. Note that the positioning of references should come after the "Conclusion" section.

After the conclusion, you can list your notations in a numbered list to match the superscript or enter them as links. Shown here are both examples:

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

Another way to enhance documentation is with ==highlighting==. You can use highlighting by surrounding the text with `==`.

This looks like this in your editor:

```bash
Another way to enhance documentation is with ==highlighting==. You can use highlighting by surrounding the text with `==`. 
```

## Grouping different formatting types

Rocky documentation offers some elegant formatting options when combining multiple elements within another element. For example, an admonition with a numbered list:

!!! note

    Things can get a little crazy when you are grouping things. Like when:

    1. You add a numbered list of options within an admonition

    1. Or you add a numbered list with multiple code blocks:

        ```
        dnf install some-great-package
        ```

        Which is also within a multi-paragraph numbered list.

Or you may have a numbered list, with an additional admonition:

1. This item is very important

    Here you are adding a keyboard command to the list item:

    Press ++escape++ for no particular reason.

1. But this item is something very important *and* has multiple paragraphs to it

    And it has an admonition in the middle of it:

    !!! warning

        Things can get a little crazy when multiple elements are in different formatting types!   

If you keep track of the magic four (4) spaces to indent and separate these items, they will display logically and precisely the way you want them to. Sometimes that is really important.

You can even embed a table or block quote (literally any formatting item type) within another one. Here you have a numbered list, an admonition, a table, and some block quote elements all bundled together:

1. Trying to keep up with everything that is going on in your document can be a real task when working with multiple elements.

1. If you are feeling overwhelmed, consider:

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

1. Many examples exist, but the above illustrates that it is possible to nest everything within. Just remember the four (4) magic spaces.

Here is what this example looks like in your editor:

```text

As long as you keep track of the magic four (4) spaces to separate these items, they will display logically and precisely the way you want them to. Sometimes that is really important.

You can even embed a table or block quote (literally any formatting item type) within another one. Here, we  have a numbered list, an admonition, a table, and some block quote elements all bundled together:

1. Trying to keep up with everything that is going on in your document can be a real task when working with multiple elements.

1. If you are feeling overwhelmed, consider:

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

1. Many examples exist, but the above illustrates that it is possible to nest everything within. Just remember the four (4) magic spaces.
```

## Non-displaying characters

Some Markdown characters will not display correctly. Sometimes it is because these characters are HTML or other tag types (such as a link). There might be times when writing documentation that you **need** to display these characters to get your point across. The rule to display these characters is to escape them. Here is a table of these non-displaying character,s followed by a code block that shows the table code.

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

In actual text, you would escape the character. For example, `\|` will show the pipe symbol, `\>` will show the angle bracket symbol, `\+` will show the plus sign, `\-` will show the minus sign, and `\!` will show the exclamation mark.

You can see that if we get rid of the backticks in this sentence:

In actual text, you would escape the character. For example, \| will show the pipe symbol, \> will show the angle bracket symbol, \+ will show the plus sign, \- will show the minus sign, and \! will show the exclamation mark.

## One final item - comments

From time to time, you might want to add a comment to your markdown that will not display when rendered. Many reasons exist for this. If you want to add a placeholder for something that you are adding later, you could use a comment to mark your spot.

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

Document formatting with headings, admonitions, tables, numbered lists, and block quotes can add clarity. When using admonitions, please ensure you select the correct type. This can make it easier to see the importance of the particular admonition visually.

You do not *have* to use advanced formatting options. Overuse of special elements can add clutter. Learning to use these formatting items effectively can be very helpful for getting your point across in a document.

Lastly, to make formatting easier, consider changing your markdown editor's TAB value to four (4) spaces.
