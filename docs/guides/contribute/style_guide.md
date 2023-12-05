---
title: Style Guide
author: Ezequiel Bruni, Krista Burdine
contributors: Steven Spencer, Ganna Zhyrnova
tags:
  - contribute
  - style guide
---

# Rocky Linux Documentation Style Guide

*Rocky Linux is the fastest-growing enterprise Linux in the world, with its documentation also growing exponentially thanks to contributors like you. Your content is welcome in any format, and the RL document stylists will help you align it with the standards set forth here.*

## Introduction

### About

*New contributions are welcome to grow this into the definitive spot on the web for information about using Rocky Linux. You can create docs in the format that makes sense to you, and the documentation team will work with you or otherwise help format it so it looks and feels like part of the Rocky family.*

This guide outlines English-language style standards to **improve readability, highlight special cases,** and **enhance translation work** across Rocky Linux documentation. For style questions not addressed in this guide, please refer to the following:

* [Merriam Webster Dictionary](https://www.merriam-webster.com/)
* [Chicago Manual of Style (CMOS), 17th ed.](https://www.chicagomanualofstyle.org/home.html)

### Contributing

For a more complete understanding of contributing, please consult our related guides:

* [Rocky Linux Contribution Guide](https://docs.rockylinux.org/guides/contribute/) for system and software requirements for getting started.
* [Rocky Linux First Time Contributors Guide](beginners.md) for an orientation to GitHub, our documentation home base.
* [Rocky Docs Formatting](rockydocs_formatting.md) for Markdown structure.

## Style Guidelines

*RL documentation aims to use clear and consistent language, for accessibility as well as to aid ongoing translation efforts.*

### Grammar and Punctuation

**Distinctives for technical writing** as outlined in the Chicago Manual of Style include the following:

* Double quotation marks (“Chicago style”) rather than single quotation marks (‘Oxford style’).
* Periods and commas go inside quotation marks “like this,” rather than “like this”.
* The em dash {shift}+{option}+{-} has no spaces before or after—like this—and is preferred for parenthetical phrases.
* Use a serial comma before the “and” in a list of three items: “Peas, mustard, and carrots.”
* Headings should be generally made in headline-style capitalization: Capitalize the first and last words, as well as all nouns, pronouns, verbs, and adverbs. If your document works better with sentence-style capitalization, perhaps because you frequently reference acronyms, make it consistent within the entire document. 
* Headings do not need a period or semicolon at the end, even with sentence-style capitalization, unless ending in an abbreviation.
* Bulleted and numbered lists: Avoid beginnning capitalization or ending punctuation, unless the item is a complete sentence.

### Voice and Tone

* **Plain language.** This can be described as a *less-conversational* style. Most of our documentation fits within this standard.
    * Avoid metaphors and idioms.
    * Say what you mean in as few words as possible.
    * Identify and avoid unnecessarily technical terms. Consider that your audience is mostly people who have some familiarity with the subject matter, but may not be subject-matter experts.
    * Exceptions to plain language:
        * A more conversational style is appropriate for documentation addressed to newcomers or beginners or for writing content like blog posts. 
        * A more formal or terse wording style is appropriate for documentation addressed to advanced users or API (Application Programming Interface) documentation. 
* **Inclusive language.**
    * Language use evolves over time. Certain words have evolved to carry negative connotations so documentation should be rewritten to use new words.
        * *Master/slave* becomes *primary/secondary* or an agreed upon organizational standard.
        * *Blacklist/whitelist* becomes *blocklist/allowlist* or an agreed upon organizational standard.
        * You may think of other relevant examples as you create documentation.
    * When speaking of a person of *unknown* or *non-binary* gender, it is now considered acceptable to use “they” as a singular pronoun.
    * When speaking of one’s capabilities, frame answers as *abilities* rather than *limitations.* For example, if you are wondering whether we have documentation about running Steam on Rocky Linux, the answer is not just “no.” Rather, “Sounds like that’s a great place for you to create something to add to our tree!”
* **Avoid contractions.** This assists with translation efforts. The exception to this is when writing something in a more conversational tone, such as blog posts or welcome instructions for new community members.

## Formatting

### Dates

When possible use the name of the month in the format {day} {Month} {year}. However, {Month} {day}, {year} is also acceptable to resolve clarity or appearance issues. Either way, to avoid confusion, write out month names rather than a series of numbers. For example: 24 January 2023, but January 24, 2023 is also acceptable—with both preferable over 1/24/2023 or 24/01/2023.

### Single-step Procedures

If you have a procedure with only one step, use a bullet rather than a number. For example:

* Implement this idea and move on.

### Graphical Interface Language

* Text instructions regarding a UI: When describing a command to be entered into a user interface, use the word “enter” rather than “put” or “type.” Use a codeblock to write out the command (i.e., set it off with backticks):

*Example Markdown text*
`In the **commit message** box, enter update_thisdoc.`

* Names of UI elements: **Bold** names of UI elements such as buttons, menu items, names of dialog boxes, and more, even if the word will not be clickable:

*Example Markdown text*
`In the **Format** menu, click **Line Spacing**.`

## Structure

### Starting content of each guide, or page/chapter of a book

* **Abstract.** A brief statement of what to expect from this page
* **Objectives.** A bulleted list of what this page will convey to the reader
* **Skills** required/learned.
* **Difficulty level.** 1 star for easy, 2 for intermediate, etc.
* **Reading time.** Divide the number of words in your document by a reading rate of 75 words per minute to determine this number.

### Admonitions

Within Markdown, admonitions are a way to put information into a box to highlight it. They are not essential to documentation, but they are a tool you may find useful. Learn more about admonitions from our [Rocky Formatting doc](rockydocs_formatting.md).

## Accessibility

*The following standards enhance accessibility for those using accommodations, such as screen readers, to access our documentation.*

### Images

* Provide text descriptions in alt-text or captions for every non-text item such as diagrams, images, or icons.
* Avoid screenshots of text when possible.
* Make alt-text meaningful, not just descriptive. For action icons, for example, enter a description of the function rather than a description of its appearance.

### Links

* Make links descriptive, so it is obvious where they will lead from the text or context. Avoid hyperlinks with names like “click here.”
* Verify that all links work as described.

### Tables

* Create tables with a logical order left to right, top to bottom.
* Avoid blank cells at the top or left of the table.
* Avoid merged cells that span multiple columns.

### Colors

* Some elements in Markdown, such as admonitions, have an assigned color to assist with visual comprehension. In general they also have an assigned name; for example, the “danger” admonition displays a red box but also has the descriptor “danger” built into the description. But when creating a custom admonition, be aware that color cannot be the only means of communicating a command or level of warning.
* Any command that includes a sensory direction, such as *above* or *below*, *color*, *size*, *visual location* on the page, etc., should also include a direction that is communicable by only text description.
* When creating a graphical element, ensure that there is enough contrast between the foreground and background colors to be easy for a screen reader to interpret.

### Headings

* Use all levels of headings without skipping any levels.
* Nest all material under headings to aid in readability.
* Remember that in Markdown only one Level One heading may be used.

## Summary

This document lays out our contribution standards, including **style guidelines,** how to **structure** your document, and ways to incorporate **inclusivity** and **accessibility** into the text. These are the standards to which we aspire. As you are able, keep these standards in mind when creating and modifying documentation.

However—and do not miss this caveat—**treat these standards as a tool, not an obstacle.** In the spirit of inclusivity and accessibility, we want to ensure your contribution has a smooth entry into the Rocky family tree. We are a friendly and helpful team of documentarians and stylists, and we will help shepherd your document into its final form.

Are you ready? Let’s get started!
