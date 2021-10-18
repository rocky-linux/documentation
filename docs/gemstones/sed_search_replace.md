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

Using `sed` for search and replace is my personal preference because you can use a delimiter of your choice, which makes replacing things like web links with “/” in them very handy. The default examples for in place editing using `sed` show things like this example:

`sed -i 's/search_for/replace_with/g' /path/filename`

But what if you are searching for strings that will contain "/" in them? If the forward slash was the only option available as a delimiter, then we would have to escape each forward slash before we could use it in the search. That's where `sed` excels over other tools, because the delimiter is changeable on-the-fly (no need to specify that you are changing it anywhere). As stated, if we are looking for things with "/" in them, we can easily do that by changing the delimiter to "|". Here's an example of looking for a link using this method:

`sed -i 's|search_for/with_slash|replace_string|g' /path/filename`

You can use any single-byte character for the delimiter with the exception of backslash, newline, and "s". For instance, this works too:

`sed -i 'sasearch_forawith_slashareplace_stringag' /path/filename` where "a" is the delimiter, and the search and replace still works. For safety, you can specify a backup while searching and replacing, which is handy for making sure the changes you are making with `sed` are what you _really_ want. This gives you a recovery option from the backup file:

`sed -i.bak s|search_for|replacea_with|g /path/filename`

Which will create an unedited version of `filename` called `filename.bak`

You can also use full quotes instead of single quotes if you like:

`sed -i "s|search_for/with_slash|replace_string|g" /path/filename`

## Options Explained

|Option | Explanation                                                   |
|-------|---------------------------------------------------------------|
| i     | edit file in place                                            |
| i.ext | create a backup with whatever the extension is (ext here)     |
| s     | specifies search                                              |
| g     | specifies to replace globally, in other words all occurrences |

## Multiple files

Unfortunately, `sed` doesn't have an in-line looping option like `perl`. To loop through multiple files, you would need to combine your `sed` command within a script. Here's an example of doing that.

First, generate a list of files that your script will use, which can be entered at the command line:

`find /var/www/html  -name "*.php" > phpfiles.txt`

Next, create a script to use this `phpfiles.txt`:

```
#!/bin/bash

for file in `cat phpfiles.txt`
do
        sed -i.bak 's|search_for/with_slash|replace_string|g' $file
done
```
The script loops through all of the files created in `phpfiles.txt`, creates a backup of each file, and executes the search and replace string globally.  Once you have verified that your search and replace has completed successfully and your changes are what you want, you can delete all of the backup files.

## Other reading and examples

* `sed` [manual page](https://linux.die.net/man/1/sed)
* `sed` [additional examples](https://www.linuxtechi.com/20-sed-command-examples-linux-users/)
* `sed` & `awk` [O'Reilly Book](https://www.oreilly.com/library/view/sed-awk/1565922255/)

## Conclusion

`sed` is a powerful tools and works very well for search and replace functions, particularly where the delimiter needs to be flexible.
