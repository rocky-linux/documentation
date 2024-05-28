---
title: perl - Search and Replace
author: Steven Spencer
tags:
  - perl
  - search
---

# `perl` Search and Replace

Sometimes you need to quickly search and replace strings in a file or group of files. There are many ways to do this, but this method uses `perl`

To search for and  replace a particular string across multiple files in a directory, the command would be:

```bash
perl -pi -w -e 's/search_for/replace_with/g;' ~/Dir_to_search/*.html
```

For a single file that might have multiple instances of the string, you can specify the file:

```bash
perl -pi -w -e 's/search_for/replace_with/g;' /var/www/htdocs/bigfile.html
```

This command uses vi syntax for search and replace to find any occurrence of a string and replace it with another string across a single or multiple files of a particular type. Useful for replacing html/php link changes embedded in those types of files, and many other things.

## Options Explained

|Option | Explanation                                                   |
|-------|---------------------------------------------------------------|
| `-p`     | places a loop around your script                              |
| `-i`     | edit file in place                                            |
| `-w`     | prints out warning messages in case something goes wrong      |
| `-e`     | allows a single line of code entered on the command line      |
| `-s`     | specifies search                                              |
| `-g`     | specifies to replace globally, in other words all occurrences |

## Conclusion

A simple way to replace a string in either one or many files using `perl`.
