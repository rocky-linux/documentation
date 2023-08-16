---
title: Marksman
author: Franco Colussi
contributors: Steven Spencer
tested with: 8.8, 9.2
tags:
  - nvchad
  - editor
  - markdown
---

# Marksman - code assistant

When drafting your document for Rocky Linux can be useful a tool that allows you to easily enter the symbols needed to define the *markdown* language tags; this will allow you to write faster and reduce the possibility of distracting errors.

NvChad/Neovim already includes text widgets that aid in writing such as the repetition of the most frequently used words indexed by frequency of entry, the new options included by this language server will enrich these widgets.

[Marksman](https://github.com/artempyanykh/marksman) integrates with your editor to help you write and maintain your Markdown documents using the [LSP protocol](https://microsoft.github.io/language-server-protocol/), thereby providing features such as completion, goto definition, reference searching, name refactoring, diagnostics, and more.

## Objectives

- increase the productivity of NvChad in writing Markdown code
- produce documents that conform to the rules of the Markdown language
- refine their knowledge regarding language

## Requirements and Skills

- A basic knowledge of the Markdown language, recommended reading the [Markdown Guide](https://www.markdownguide.org/)
- NvChad on the machine in use with the [Template Chadr](./template_chadrc.md) properly installed

**Difficulty level** :star:

**Reading time:** 20 minutes

## Installation of Marksman

Installation of the language server does not involve any particular problems since it is natively available in **Mason**. It is possible to install it directly from the *statusline* with the command:

`:MasonInstall marksman`

The command will open the *Mason* interface and directly install the required language server. Once the installation of the binary is finished you can close the *Mason* screen with the <kbd>q</kbd> key.

Its installation, however, does not yet involve its integration into the editor; this is enabled by editing the `custom/configs/lspconfig.lua` file of the *Chadrc Template*.

## Integration into the editor

!!! note "LSP in NvChad"

    The integration of language servers into NvChad is provided by the [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) plugin, this plugin greatly simplifies their inclusion in the NvChad configuration.

If during the editor installation you chose to also install the *Template Chadrc* this will have created in your `custom/configs` folder the file *lspconfig.lua*.

This file takes care of entering the calls needed to use the language servers and also allows you to specify the ones you have installed. To integrate *marksman* into the editor's language server configuration you will need to edit the *local servers* string by adding your new LSP.

Open your NvChad on the file with the command:

```bash
nvim ~/.config/nvim/lua/custom/configs/lspconfig.lua
```

And edit the *local servers* string, which will look as follows when the edit is complete:

```lua
local servers = { "html", "cssls", "tsserver", "clangd", "marksman" }
```

Save the file and close the editor with the `:wq` command.

To check if the language server is properly activated open a markdown file in your NvChad and use the command `:LspInfo` to view the language servers applied to that file, within the summary there should be something like:

```text
 Client: marksman (id: 2, bufnr: [11, 156])
 	filetypes:       markdown
 	autostart:       true
 	root directory:  /home/your_user/your_path/your_directory
 	cmd:             /home/your_user/.local/share/nvim/mason/bin/marksman server
 
 Configured servers list: cssls, tsserver, clangd, html, yamlls, lua_ls, marksman
```

This indicates that the *marksman* server has been activated for the open file, started automatically `autostart: true` since it is recognized as a markdown file `filetypes: markdown`. The other information indicates the path to the executable used for the code check `cmd:` and that this is used in `marksman server` mode, also that the root directory `your_directory` is used for the checks.

!!! note "Root folder"

    The concept of a "root folder" is important in the use of a language server in that in order to perform controls on the document, such as links to other files or images for example, it must have a "global view" of the project. We can say that "*root folders*" can be equated with the "*Projects*" found in graphics IDEs.

    The *root directory* also called the "*working directory*" used by the editor for the open file can be viewed with the `:pwd` command and in case it does not match the desired one it can be changed with the `:lcd` command, this command reassigns the *working directory* only to that buffer without changing any settings of the other buffers open in the editor.

## Use of marksman

Once you have completed all the steps to enter it the language server will be activated whenever the editor is opened on a *markdown* file, by entering `INSERT` mode you will have upon typing certain characters new options in the widgets that will help you in writing the document, in the screenshot below you can see some of the markdown snippets available in these widgets.

![Marksman Snippets](./images/marksman_snippets.png)

## Main keys

The language server provides a number of shortcuts that activate writing assistance; this includes quick insertion of Markdown tags, creation of links, and insertion of images into the document. A non-exhaustive list of characters that activate the various snippets will be provided below.

These snippets are displayed within widgets that also contain other shortcuts; navigation of the widget to select those provided by *marksman* is done with the <kbd>Tab</kbd> key.


| Key | Snippets |
|--------------- | --------------- |
| <kbd>h</kbd> | Allows for quick entry of title headings (*h1* to *h6*), for example, entering *h4* and pressing enter will insert four hash marks and a space and the cursor will already be in place to enter your title |
| <kbd>b</kbd> | Typing this character activates the ability to use the shortcut for entering bold text by inserting four asterisks and placing the cursor in the middle making writing the **bold** part much faster |
| <kbd>i</kbd> | As with the previous character, it allows you to select quick insertion of *italic* text by entering two asterisks and placing the cursor in between.   |
| <kbd>bi</kbd> | This key inserts six asterisks by placing the cursor in the middle for writing text in ***bold and italics*** |
| <kbd>img</kbd> | This key inserts the markdown structure for inserting an image into the document in the format `![alt text](path)`. Note that writing the path can be done using the autocomplete provided by the server.   |
| <kbd>link</kbd> | This key creates the markdown tag structure for a `[text](url)` link. Again, if the link refers to a file in the **working directory** you will be able to use autocomplete and the server will check the correctness of the reference.    |
| <kbd>list</kbd> | Typing this key allows the entry of a list of three items to begin the creation of a numbered or unordered list |
| <kbd>q</kbd> | This character allows the insertion of the tag for a citation `>` followed by a space and positions the cursor for writing the citation |
| <kbd>s</kbd> | This character activates numerous possibilities including inserting four tildes and placing the cursor in the middle for writing text ~~strikethrough~~ |
| <kbd>sup</kbd> | The key inserts the *superscript* tag. Trademark<sup>TM |
| <kbd>sub</kbd> | The key inserts the *subscript* tag. Notes<sub>1 |
| <kbd>table</kbd> | This key enables quick creation of a table structure and allows you to choose from many starting structures |
| <kbd>code</kbd> | Inserts a block of code inline by placing two backticks at the position where the cursor is located by placing it in the center of the two backticks. |
| <kbd>codeblock</kbd> | Inserts three lines, two of which have triple backticks and one blank where you insert your code blocks. Note that it also inserts the string *language* which is to be compiled with the language you used in the block.

!!! note "Code block statement"

    Markdown code rules recommend always declaring the code used in the block even in the absence of highlighting features for proper interpretation. If the code within it is too generic, it is recommended to use "text" for its declaration.

The activation keys for Markdown tagging shortcuts also include other combinations that you will have a chance to discover as you use the language server.

## Conclusion

Although not strictly necessary, this language server can over time become a great companion in your documentation writing for Rocky LInux.

By using it and consequently memorizing the main keys for inserting Markdown code symbols it will enable effectively faster writing by allowing you to focus your attention on the content.

