---
title: Using NvChad
author: Franco Colussi
contributors: Steven Spencer
tested with: 8.6, 9.0
tags:
    - nvchad
    - coding
    - editor
---

# Editing with NvChad

This chapter will introduce some NvChad-specific commands and some standard Neovim (vim) commands.  NvChad commands are set in the `nvim/lua/core/mapping.lua` file and allow keys to be used to execute sometimes very long composite commands. All sequences are started with a primary key followed by an option. The four main keys are:

- C = <kbd>Ctrl</kbd>
- leader = <kbd>Space</kbd>
- A = <kbd>Alt</kbd>
- S = <kbd>shift</kbd>

## Open a file

To open a file in our editor we can use various methods. We can simply start from the command line by indicating the file name with:

```bash
nvim /path/to/the/file
```

or open the editor with the `nvim` command.

If we use the latter method we have several possibilities. We can open the file in the buffer with the command `:e` (edit) followed by the path or by having the command followed by the <kbd>Tab</kbd> key.  This will show us all the available files and folders starting from the root of the project. It is good to remember that when we use the <kbd>Tab</kbd> key in file opening commands, we can select the file from a convenient drop-down menu. Once this drop-down menu is open, we continue to navigate within it by repeated use of the <kbd>Tab</kbd> key.

![Command :e + TAB](../images/e_tab_command.png) 

In case we just want to view the file without the ability to edit it we can use the `:view` command. This will open the file in read-only mode avoiding the possibility of making unwanted changes to critical files. We can also open a file side by side with the command ` :split ` or open it in a new *tab* with the command ` :tabedit `.

![Vsplit Open](../images/vsplit_open.png)

Thanks to the work done by the developers of NvChad we are provided with an additional way to open a file which is to use the *nvim-telescope/telescope.nvim* plugin. This plugin, when used in combination with *RipGrep*, allows us to search for the file to be opened in interactive mode. By typing the initial characters of the file we are looking for, the plugin will delete all non-matching files and present us with only those that match our search. This allows for a very smooth search and open process.

![<leader>ff](../images/leader_ff.png) 

## Working with the Editor

Once the file is open we can start editing it. To do this we need to switch to INSERT mode which is activated by pressing the <kbd>i</kbd> (insert) key. The mode indicator in the Statusline should change from NORMAL to INSERT, and the cursor placed in the buffer should also change from a colored rectangle to a `|` pipe. Now all the characters we type are inserted into the document starting from the position of the cursor. To move the cursor in INSERT mode the Nvchad developers have set up some convenient mappings which are:

- <kbd>Ctrl</kbd> + <kbd>b</kbd> to go to the beginning of the line
- <kbd>Ctrl</kbd> + <kbd>e</kbd> to go to the end of the line
- <kbd>Ctrl</kbd> + <kbd>h</kbd> to move one character to the left
- <kbd>Ctrl</kbd> + <kbd>l</kbd> to move one character to the right
- <kbd>Ctrl</kbd> + <kbd>j</kbd> to go to the next line
- <kbd>Ctrl</kbd> + <kbd>k</kbd> to go to the previous line

Learning all the combinations takes some time but once acquired they will make navigation very fast. For example, if we want to edit the end of the next line to where the cursor is positioned we can get to the end of the current line with <kbd>Ctrl</kbd> + <kbd>e</kbd> and then get to the next one with a <kbd>Ctrl</kbd> + <kbd>j</kbd> and already be in position to add the changes.

Navigation in the document can also be done using the arrow keys on the keyboard, or the mouse.

### Text Selection

Text selection can also be done with the mouse and is very convenient, but for this chapter we will use the traditional method.

To select text we need to enter the VISUAL mode. To do this we must first exit the insert mode and switch to normal mode, which is done with the <kbd>ESC</kbd> key. Once we place the cursor at the beginning of the part we want to select, we use the keys <kbd>Ctrl</kbd> + <kbd>v</kbd> to enter the V-BLOC (Visual Block) mode. Now moving with the cursor we will see that our selection will be highlighted. At this point we can work on the selected part. If we want to copy the selection to the clipboard we will use the <kbd>y</kbd> key. If we want to delete it the <kbd>d</kbd> key. Once the operation is done, the text will no longer be highlighted. For an overview of all the operations that can be performed in Visual Mode you can consult the help directly from the editor with `:help Visual-Mode`.

![Help Visual Mode](../images/help_visual_mode.png) 

### Text search

To search, the slash character <kbd>/</kbd> followed by the search key `/search_key` is used, which highlights all occurrences found. To move to the next one, the combination <kbd>/</kbd> + <kbd>Enter</kbd> is used. To move to the previous one <kbd>?</kbd> + <kbd>Enter</kbd>. Once the changes are finished, the highlighting is removed with the command `:noh` (no highlight).

![Find Command](../images/find_command.png)

Searches can be even more complex than the one illustrated above; wildcards, counters, and other options can be used. The help `:help /` can be used to consult the options.

## Saving the Document

Once the file is created or modified it is saved with the command `:w` (write) which will save the file with the current name in the location it is in, in case you want to save the file with another name or in another location just have the command follow the save path:

```text
:w /path/to/new/file_or_position
```

To save and simultaneously close the editor, the command `:wq` (write - quit) is used.

In this chapter we have introduced you to the editor. There are many more advanced features than those described here. These features can be consulted on the [Neovim help](https://neovim.io/doc/user/) page or by typing in the editor `:help`.

