---
title: Rocky Docs Formatting
author: Steven Spencer
contributors: tianci li, Ezequiel Bruni
tags:
  - contribute
  - formatting
---

# Rocky Docs Formatting - Introduction

Over the last year, a lot has changed with Rocky documentation. This guide is meant to help contributors get familiar with our more advanced formatting options: including  admonitions, numbered lists, tables, and more.

To be clear, a document may or may not need to contain any of these elements. If you feel that your document will benefit from them, then this guide should help.

!!! note "A Note About Headings"

    Headings are not really special formatting characters, but rather standard markdown syntax. They include a **single** level one heading:

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

    The key here is that there can be as many of the 2 through 6 headings as you want to use, but only **ONE** level 1 heading. While the documentation will build with more than one level 1 heading, the automatically generated table of contents for the document that appears on the right-hand side, will **NOT** display correctly (or sometimes at all), with more than one. Keep this in mind when writing your documents.

## Admonitions

Admonitions are special visual "boxes" that allow you to call attention to important facts and highlight them in a way that makes them stick out from the rest of the text. Admonitions types are as follows:

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
| custom <sub>2</sub> | uses a custom title within another type       |

So there is no limit on the types of admonitions you can use as noted in custom <sub>1</sub> above. A custom title can be added to any of the other admonition types to get the colored box you want for a specific admonition, as noted in custom <sub>2</sub> above.

An admonition is always entered in this way:

```
!!! admonition_type

    text of admonition
```

The body text of the admonition must be indented four (4) spaces from the beginning margin. It's easy to see where that is in this case, because it will always line up under the first letter of the admonition type. The extra line between the title and body will not show up, but is required for our translation engine (Crowdin) to function correctly.

Here are examples of each admonition type, and how they will look in your document:

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

If you need to add code blocks, multiple lines or even paragraphs of text to a numbered list, then the text should be indented with those same four (4) spaces that we used in the admonitions.

You can't use your eyes to line them up under the numbered item, however, as this is one space off. If you are using a good markdown editor, you can set your tab value to four (4), which will make formatting everything a bit easier.

Here's an example of a multi-line numbered list with a code block thrown in for good measure:

1. When dealing with numbered lists that are multi line and include things like code blocks, use the space indentation to get what you want.

    For example: this is indented four (4) spaces and represents a new paragraph of text. And here, we are adding a code block in. It is also indented by the same four (4) spaces as our paragraph:

    ```
    dnf update
    ```

2. Here's our second listed item. Because we used the indentation (above) it renders with the next sequence of numbering (in other words, 2), but if we had entered item 1 without the indentation (in the subsequent paragraph and code), then this would show up as item 1 again, which is not what we want.


And here's how that looks as raw text:

```markdown
1. When dealing with numbered lists that are multi line and include things like code blocks, use the space indentation to get what you want.

    For example: this is indented four (4) spaces and represents a new paragraph of text. And here, we are adding a code block in. It is also indented by the same four (4) spaces as our paragraph:

    ```
    dnf update
    ```

2. Here's our second listed item. Because we used the indentation (above) it renders with the next sequence of numbering (in other words, 2), but if we had entered item 1 without the indentation (in the subsequent paragraph and code), then this would show up as item 1 again, which is not what we want.
```

## Tables

Tables help us to lay out command options, or in the above case, admonition types and descriptions. Here's how the table above is entered:

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

Note that it isn't necessary to have each column broken down by size (as we've done in the first part of the table), but it is certainly more readable in the markdown source file. It can get confusing when you string the items together, simply by breaking the columns with the pipe character "|" wherever the natural break would be, as you can see in the last two items of the table.

## Block Quotes

Block quotes are actually designed for quoting text from other sources to include in your documentation, but they don't have to be used that way. We've had several people use block quotes instead of tables, for instance, to list out some options. Examples of block quotes in markdown would be:

```
> **an item** - A description of that item

> **another item** - Another description of that item
```
To keep the lines from running together, the extra "spacing" line is necessary here.

That ends up looking like this when the page is rendered:

> **an item** - A description of that item

> **another item** - Another description of  an item

## Inline and Block-Level Code Blocks

Our approach to using code blocks is pretty simple. If `your code` is short enough that you can (and want to) use it in a sentence like you just saw, use single backticks <kbd>`</kbd>, like so:

```
A sentence with a `commmand of your choosing` in it.
```

Any command that is not used inside of a text paragraph (especially the long bits of code with multiple lines) should be a full code block, defined with triple backticks <kbd>`</kbd>:

````markdown
```bash
sudo dnf install the-kitchen-sink
```
````

The `bash` bit of that formatting is a non-essential code identifier, but can help with syntax highlighting. Of course, if you're showcasing Python, PHP, Ruby, HTML, CSS, or any other kind of code, the "bash" should be changed to whatever language you're using.

Incidentally, if you need to show a code block within a code block, just add one more backtick <kbd>`</kbd> to the parent block, like so:

`````markdown
````markdown
```bash
sudo dnf install the-kitchen-sink
```
````
`````

And yes, the code block you just saw used five backticks at the beginning and end to make it render properly.

## Keyboard

Another way to make sure that you add as much clarity to your documents as possible is to represent keys on the keyboard that must be entered, in the correct manner. This is done with `<kbd>key</kbd>`. For instance, to represent that you need to hit the escape key in your document, you would use `<kbd>ESC</kbd`. When you need to indicate that multiple keys must be pressed add a `+` between them like this: `<kbd>CTRL</kbd> + <kbd>F4</kbd>` if keys need to be pressed simultaneously, add "simultaneously" or "at the same time" or some similar phrase to your instructions. Here's an example of a keyboard instruction in your editor:

```
A workstation type installation (with graphical interface) starts this interface on terminal 1. Linux being multi-user, it is possible to connect several users several times, on different **physical terminals** (TTY) or **virtual terminals** (PTS). Virtual terminals are available within a graphical environment. A user switches from one physical terminal to another using <kbd>Alt</kbd> + <kbd>Fx</kbd> from the command line or using <kbd>CTRL</kbd> + <kbd>Alt</kbd> + <kbd>Fx</kbd>.
```
And here's how that renders when displayed:

A workstation type installation (with graphical interface) starts this interface on terminal 1. Linux being multi-user, it is possible to connect several users several times, on different **physical terminals** (TTY) or **virtual terminals** (PTS). Virtual terminals are available within a graphical environment. A user switches from one physical terminal to another using <kbd>Alt</kbd> + <kbd>Fx</kbd> from the command line or using <kbd>CTRL</kbd> + <kbd>Alt</kbd> + <kbd>Fx</kbd>.

## Grouping Different Formatting Types

Things really get crazy, when you need to combine multiple elements within another one. For instance, an admonition with a numbered list:

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

    Here we are adding a keyboard command to the list item:

    Press <kbd>ESC</kbd> for no particular reason.

2. But this item is something very important and has multiple paragraphs to it

    And it has an admonition in the middle of it:

    !!! warning

        Things can get a little crazy with multiple elements within different formatting types!   

As long as you keep track of the magic four (4) spaces to indent and separate these items, they will display logically and exactly the way you want them to. Sometimes that is really important.

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

## One Final Item - Comments

From time to time you may want to add a comment to your markdown that will not display when rendered. There are a lot of reasons why you might want to do this. For instance, if you want to add a placeholder for something that will be added later, you could use a comment to mark your spot.

The best way to add a comment to your markdown is to use the square brackets "[]" with two forward slashes "//" followed by a colon and the content. This would look like this:

```

[//]: This is a comment to be replaced later

```
A comment should have a blank line before and after the comment.

## More Reading

* The Rocky Linux [how to contribute document](README.md)

* More on [admonitions](https://squidfunk.github.io/mkdocs-material/reference/admonitions/#supported-types)

* [Markdown quick reference](https://wordpress.com/support/markdown-quick-reference/)

* [More quick references](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet) for Markdown

## Conclusion

Document formatting with admonitions, tables, numbered lists, and block quotes, can add clarity to your document. When using admonitions, take care to pick the correct type. This can make it easier to visually see the importance of the particular admonition.

Overuse of any of these elements can simply add clutter where none is needed. Learning to use these formatting items conservatively and well can be very helpful to get your point across in a document.

Lastly, to make formatting easier, consider changing your markdown editor's TAB value to four (4) spaces.
