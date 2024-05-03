---
title: sed - Search and Replace
author: Steven Spencer
---

# `sed` - Search and Replace

`sed` is a command that stands for "stream editor."

## Conventions

* `path`: The actual path. Example: `/var/www/html/`
* `filename`: The actual filename. Example: `index.php`

## Using `sed`

Using `sed` for search and replace is my personal preference because you can use a delimiter of your choice, which makes replacing things such as web links with “/” in them very handy. The default examples for in place editing using `sed` show things like this example:

`sed -i 's/search_for/replace_with/g' /path/filename`

But what if you are searching for strings that will contain "/" in them? If the forward slash was the only option available as a delimiter? You would have to escape each forward slash before you could use it in the search. That is where `sed` excels over other tools, because the delimiter is changeable on-the-fly (no need to specify that you are changing it anywhere). As stated, if you are looking for things with "/" in them, you can do that by changing the delimiter to "|". Here's an example of looking for a link by using this method:

`sed -i 's|search_for/with_slash|replace_string|g' /path/filename`

You can use any single-byte character for the delimiter with the exception of backslash, newline, and "s". For instance, this works too:

`sed -i 'sasearch_forawith_slashareplace_stringag' /path/filename` where "a" is the delimiter, and the search and replace still works. For safety, you can specify a backup while searching and replacing, which is handy for making sure the changes you are making with `sed` are what you _really_ want. This gives you a recovery option from the backup file:

`sed -i.bak s|search_for|replacea_with|g /path/filename`

Which will create an unedited version of `filename` called `filename.bak`

You can also use full quotes instead of single quotes:

`sed -i "s|search_for/with_slash|replace_string|g" /path/filename`

## Options Explained

|Option | Explanation                                                   |
|-------|---------------------------------------------------------------|
| i     | edit file in place                                            |
| i.ext | create a backup with whatever the extension is (ext here)     |
| s     | specifies search                                              |
| g     | specifies to replace globally, or all occurrences |

## Multiple files

Unfortunately, `sed` does not have an in-line looping option like `perl`. To loop through multiple files, you need to combine your `sed` command within a script. Here's an example of doing that.

First, generate a list of files that your script will use. Do this at the command line with:

`find /var/www/html  -name "*.php" > phpfiles.txt`

Next, create a script to use this `phpfiles.txt`:

```bash
#!/bin/bash

for file in `cat phpfiles.txt`
do
        sed -i.bak 's|search_for/with_slash|replace_string|g' $file
done
```

The script loops through all of the files created in `phpfiles.txt`, creates a backup of each file, and executes the search and replace string globally. When you have verified that the changes are what you want, you can delete all of the backup files.

## Other reading and examples

* `sed` [manual page](https://linux.die.net/man/1/sed)
* `sed` [additional examples](https://www.linuxtechi.com/20-sed-command-examples-linux-users/)
* `sed` & `awk` [O'Reilly Book](https://www.oreilly.com/library/view/sed-awk/1565922255/)

## Conclusion

`sed` is a powerful tool and works very well for search and replace functions, particularly where the delimiter needs to be flexible.
