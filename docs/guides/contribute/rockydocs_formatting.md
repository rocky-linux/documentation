---
title: Rocky Docs Formatting
author: Steven Spencer
contributors: tianci li, Ezequiel Bruni, Krista Burdine
tags:
  - contribute
  - formatting
---

# Rocky Docs Formatting - Introduction

This guide highlights our more advanced formatting options, including admonitions, numbered lists, tables, and more.

A document may or may not need to contain any of these elements. If you feel that your document will benefit from special formatting, then this guide should help.

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

## Admonitions

Admonitions are special visual "boxes" that allow you to call attention to important facts and highlight them in a way that makes them stand out from the rest of the text. Admonition types are as follows:

| type      | Description                                               |
|-----------|-----------------------------------------------------------|
| note      | renders a blue text box                                   |
| abstract  | renders a light blue text box                             |
| info      | renders a blue-green text box                             |
| tip       | renders a blue-green text box (icon slightly greener)     |
| success   | renders a green text box                                  |
| question  | renders a light green text box                            |
| warning   | renders an orange text box                                |
| failure   | renders a light red text box                              |
| danger    | renders a red text box                                    |
| bug       | renders a red text box                                    |
| example   | renders a purple text box                                 |
| quote     | renders a grey text box                                   |
| custom <sub>1</sub> | always renders a blue text box                  |
| custom <sub>2</sub> | uses a custom title within another type         |

There is no limit on the types of admonitions you can use as noted in custom <sub>1</sub> above. A custom title can be added to any of the other admonition types to get the colored box you want for a specific admonition, as noted in custom <sub>2</sub> above.

An admonition is always entered in this way:

```
!!! admonition_type

    text of admonition
```

The body text of the admonition must be indented four (4) spaces from the beginning margin. It's easy to see where that is in this case, because it will always line up under the first letter of the admonition type. The extra line between the title and body will not show up but is required for our translation engine (Crowdin) to function correctly.

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

    A custom <sub>1</sub> type. Here we've used "custom" as our admonition type. Again, this will always render in blue.

!!! warning "custom title"

    A custom <sub>2</sub> type. Here we've modified the "warning" admonition type with a custom header. Here's what that looks like:

    ```
    !!! warning "custom title"
    ```

### Expandable Admonitions

If an admonition will have content that is very long, consider using an expandable admonition. This is treated the same way as a regular admonition but starts with three question marks, rather than three exclamation marks. All the other admonition rules apply. An expandable admonition looks like this:

??? warning "Warning Content"

    This is a warning, with not very much content. You'd want to use a regular admonition for this, but Hey, this is just an example!

Which looks like this in your editor:

```
??? warning "Warning Content"
    
    This is a warning, with not very much content. You'd want to use a regular admonition for this, but Hey, this is just an example!
```

## Tabbed Content within a Document

Tabbed content is formatted in a similar way to admonitions. Instead of three exclamation marks or three question marks, it begins with three equal signs. All the admonition formatting (4 spaces, etc.) applies to this content. An example of this is where documentation might need a different procedure for a different Rocky Linux version. When using tabbed content for versions, the most recent release of Rocky Linux should come first. At the time of this writing, that was 9.0:

=== "9.0"

    The procedure for doing this in 9.0

=== "8.6"

    The procedure for doing this in 8.6

Which would look like this in your editor:

```
=== "9.0"

    The procedure for doing this in 9.0

=== "8.6"

    The procedure for doing this in 8.6
```

Keep in mind that everything that falls inside of the section must continue to use the 4-space indentation until the section is completed. This is a very handy feature!

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

1. When dealing with numbered lists that are multi-line and include things like code blocks, use the space indentation to get what you want.

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

Tables help us to lay out command options, or in the above case, admonition types and descriptions. Here's how the table in the Admonitions section above is entered:

```
| type      | Description                                               |
|-----------|-----------------------------------------------------------|
| note      | renders a blue text box                                   |
| abstract  | renders a light blue text box                             |
| info      | renders a blue-green text box                             |
| tip       | renders a blue-green text box (icon slightly greener)     |
| success   | renders a green text box                                  |
| question  | renders a light green text box                            |
| warning   | renders an orange text box                                |
| failure   | renders a light red text box                              |
| danger    | renders a red text box                                    |
| bug       | renders a red text box                                    |
| example   | renders a purple text box                                 |
| quote     | renders a grey text box                                   |
| custom <sub>1</sub> | always renders a blue text box                  |
| custom <sub>2</sub> | uses a custom title within another type         |

```

Note that it isn't necessary to have each column broken down by size (as we've done in the first part of the table), but it is certainly more readable in the markdown source file. It can get confusing when you string the items together, simply by breaking the columns with the pipe character "|" wherever the natural break would be, as you can see in the last two items of the table.

## Block Quotes

Block quotes are actually designed for quoting text from other sources to include in your documentation, but they don't have to be used that way. Some contributors use block quotes instead of tables, for instance, to list out some options. Examples of block quotes in markdown would be:

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
A sentence with a `command of your choosing` in it.
```

Any command that is not used inside of a text paragraph (especially the long bits of code with multiple lines) should be a full code block, defined with triple backticks <kbd>`</kbd>:

````markdown
```bash
sudo dnf install the-kitchen-sink
```
````

The `bash` bit of that formatting is a non-essential code identifier but can help with syntax highlighting. Of course, if you're showcasing Python, PHP, Ruby, HTML, CSS, or any other kind of code, the "bash" should be changed to whatever language you're using.

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

Another way to add as much clarity to your documents as possible is to represent keys on the keyboard that must be entered in the correct manner. This is done with `<kbd>key</kbd>`. For instance, to represent that you need to hit the escape key in your document you would use `<kbd>ESC</kbd`. When you need to indicate that multiple keys must be pressed add a `+` between them like this: `<kbd>CTRL</kbd> + <kbd>F4</kbd>`. If keys need to be pressed simultaneously, add "simultaneously" or "at the same time" or some similar phrase to your instructions. Here's an example of a keyboard instruction in your editor:

```
A workstation type installation (with graphical interface) starts this interface on terminal 1. Linux being multi-user, it is possible to connect several users several times, on different **physical terminals** (TTY) or **virtual terminals** (PTS). Virtual terminals are available within a graphical environment. A user switches from one physical terminal to another using <kbd>Alt</kbd> + <kbd>Fx</kbd> from the command line or using <kbd>CTRL</kbd> + <kbd>Alt</kbd> + <kbd>Fx</kbd>.
```

And here's how that renders when displayed:

A workstation type installation (with graphical interface) starts this interface on terminal 1. Linux being multi-user, it is possible to connect several users several times, on different **physical terminals** (TTY) or **virtual terminals** (PTS). Virtual terminals are available within a graphical environment. A user switches from one physical terminal to another using <kbd>Alt</kbd> + <kbd>Fx</kbd> from the command line or using <kbd>CTRL</kbd> + <kbd>Alt</kbd> + <kbd>Fx</kbd>.

## Superscript, Subscript and Special Symbols

Superscript and subscript notation are not normal markdown, but are supported in Rocky Linux documentation via the HTML tags used for the same purpose. Superscript places text entered between the tags slightly above the normal text, while subscript places the text slightly below. Superscript is by far the more commonly used of these two in writing. Some special characters already appear in superscript without adding the tags, but you can also combine the tag to change the orientation of those characters as seen with the copyright symbol below. You can use superscript to:

* represent ordinal numbers, such as 1<sup>st</sup>, 2<sup>nd</sup>, 3<sup>rd</sup>
* copyright and trademark symbols, like <sup>&copy;</sup>, <sup>TM</sup>, or &trade;, &reg;
* as notation for references, such as this<sup>1</sup>, this<sup>2</sup> and this<sup>3</sup>

Some of the special characters, such as &copy; aren't normally superscript, while others such as &trade;, are.

Here is how all the above looks in your markdown code:

```
* represent ordinal numbers, such as 1<sup>st</sup>, 2<sup>nd</sup>, 3<sup>rd</sup>
* copyright and trademark symbols, like <sup>&copy;</sup>, <sup>TM</sup> or &trade;, &reg;
* as notation for references, such as this<sup>1</sup>, this<sup>2</sup> and this<sup>3</sup>

Some of the special characters, such as &copy; aren't normally superscript, while others such as &trade;, are.
```

As you can see, to force superscript we can use the supported HTML tags of `<sup></sup>`.

Subscript is entered with the `<sub></sub>` tags, and as noted earlier, isn't <sub>used nearly as much</sub> in writing.

### Superscript for References 

Some of you may feel the need to reference outside sources when writing documentation. If you only have a single source, you may wish to include it in your conclusion as a single link, but if you have multiples<sup>1</sup>, you can use superscript to note them in your text<sup>2</sup> and then list them at the end of your document. Note that the positioning of references should come after the "Conclusion" section.

Following the conclusion, you can have your notations in a numbered list to match the superscript, or you can enter them as links. Both examples are shown here:

1. "How Multiples Are Used In Text" by Wordy W. McWords [https://site1.com](https://site1.com)
2. "Using Superscript In Text" by Sam B. Supersecret [https://site2.com](https://site2.com)

or

[1](https://site1.com) "How Multiples Are Used In Text" by Wordy W. McWords  
[2](https://site2.com) "Using Superscript In Text" by Sam B. Supersecret  

And here's what that all looks like in your editor:

```
1. "How Multiples Are Used In Text" by Wordy W. McWords [https://site1.com](https://site1.com)
2. "Using Superscript In Text" by Sam B. Supersecret [https://site2.com](https://site2.com)

or

[1](https://site1.com) "How Multiples Are Used In Text" by Wordy W. McWords  
[2](https://site2.com) "Using Superscript In Text" by Sam B. Supersecret  

```

## Grouping Different Formatting Types

Rocky Documentation offers some elegant formatting options when combining multiple elements within another element. For instance, an admonition with a numbered list:

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

    Here we are adding a keyboard command to the list item:

    Press <kbd>ESC</kbd> for no particular reason.

2. But this item is something very important *and* has multiple paragraphs to it

    And it has an admonition in the middle of it:

    !!! warning

        Things can get a little crazy with multiple elements within different formatting types!   

As long as you keep track of the magic four (4) spaces to indent and separate these items, they will display logically and exactly the way you want them to. Sometimes that is really important.

You can even embed a table or block quote (literally any formatting item type) within another one. Here we have a numbered list, an admonition, a table and some block quote elements all bundled together:

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

        > **sugar** if caffeine isn't to your liking

        > **suffer** if all else fails, concentrate more

3. There are more examples, but the above should illustrate that everything can be nested within. Just remember the four (4) magic spaces.

Here is what this example looks like in your editor:

```

As long as you keep track of the magic four (4) spaces to separate these items, they will display logically and exactly the way you want them to. Sometimes that is really important.

You can even embed a table or block quote (literally any formatting item type) within another one. Here we have a numbered list, an admonition, a table and some block quote elements all bundled together:

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

        > **sugar** if caffeine isn't to your liking

        > **suffer** if all else fails, concentrate more

3. There are more examples, but the above should illustrate that everything can be nested within. Just remember the four (4) magic spaces.
```

## One Final Item - Comments

From time to time, you may want to add a comment to your markdown that will not display when rendered. There are a lot of reasons why you might want to do this. For instance, if you want to add a placeholder for something that will be added later, you could use a comment to mark your spot.

The best way to add a comment to your markdown is to use the square brackets "[]" around two forward slashes "//" followed by a colon and the content. This would look like this:

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

Document formatting with headings, admonitions, tables, numbered lists, and block quotes can add clarity to your document. When using admonitions, take care to pick the correct type. This can make it easier to visually see the importance of the particular admonition.

You do not *have* to use advanced formatting options. Overuse of special elements can add clutter where none is needed. Learning to use these formatting items conservatively and well can be very helpful to get your point across in a document.

Lastly, to make formatting easier, consider changing your markdown editor's TAB value to four (4) spaces.
