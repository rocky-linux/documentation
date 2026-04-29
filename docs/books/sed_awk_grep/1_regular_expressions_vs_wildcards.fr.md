---
title: Expressions Régulières et Wildcards
author: tianci li
contributors:
tags:
  - Expressions régulières
  - Wildcards
---

# Expressions Régulières et Wildcards

In the GNU/Linux operating system, regular expressions and wildcards often have the same symbol (or style), so people often confuse them.

What is the difference between regular expressions and wildcards?

Similitudes :

- They have the same symbol but represent entirely different meanings.

Différences :

- Regular expressions match file content; Wildcards are typically used to match file or directory names.
- Regular expressions are typically used on commands such as `grep`, `sed`, `awk`, and so on.
- Les caractères génériques sont couramment utilisés avec des commandes telles que `cp`, `find`, `mv`, `touch`, `ls`, etc.

## Wildcards et GNU/Linux

GNU/Linux operating systems support these wildcards:

|                    style de wildcards                   | Rôle                                                                                                                                                                                                          |
| :-----------------------------------------------------: | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
|                            ?                            | Matches one character of a file or directory name.                                                                                                                                            |
|                            \*                           | Matches 0 or more arbitrary characters of a file or directory name.                                                                                                                           |
| [ ] | Matches any single character in parentheses. For example, &#91;one&#93; which means to match o or n or e.                             |
| [-] | Matches any single character within the given range in parentheses. For example, &#91;0-9&#93; matches any single number from 0 to 9. |
| [^] | "logical non" matching of a single character. For example, &#91;^a-zA-Z&#93; represents matching a single non-letter character.       |
|                           {,}                           | Non continuous matching of multiple single characters. Séparés par des virgules.                                                                                              |
|           {..}          | Tout comme &#91;-&#93;. Par exemple, {0..9} et {a..z}                                 |

Different commands have different support for wildcard styles:

- `find`: prend en charge \*, ?, [ ], [-], [^]
- `ls`: All supported
- `mkdir`: prend en charge {,} and {..}
- `touch`: prend en charge {,} and {..}
- `mv` : tous pris en charge
- `cp` : tous pris en charge

Par exemple :

```bash
Shell > mkdir -p /root/dir{1..3}
Shell > cd /root/dir1/
Shell > touch file{1,5,9}
Shell > cd 
Shell > mv /root/dir1/file[1-9]  /root/dir2/
Shell > cp /root/dir2/file{1..9} /root/dir3/
Shell > find / -iname "dir[1-9]" -a -type d
```

## Regular expressions in GNU/Linux

Two major schools of regular expressions exist due to historical development:

- POSIX :
  - BRE（basic regular expression）
  - ERE (expression régulière étendue)
  - Classe de caractères POSIX
- PCRE (Perl Compatible Regular Expressions): The most common among various programming languages.

|        | BRE |                        ERE                       | Classe de caractères POSIX |                       PCRE                       |
| :----: | :-: | :----------------------------------------------: | :------------------------: | :----------------------------------------------: |
| `grep` |  √  | √<br/>(nécessite l'option -E) |              √             | √<br/>(nécessite l'option -P) |
|  `sed` |  √  | √<br/>(nécessite l'option -r) |              √             |                         ×                        |
|  `awk` |  √  |                         √                        |              √             |                         ×                        |

For more on regular expressions, visit [this website](https://www.regular-expressions.info/) for more helpful information.

### BRE

BRE (Basic Regular Expression) is the oldest type of regular expression, introduced by the `grep` command in UNIX systems and the **ed** text editor.

|                      métacaractère                      | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                      | exemple bash                                                                                      |
| :-----------------------------------------------------: | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :------------------------------------------------------------------------------------------------ |
|                            \*                           | Matches the number of occurrences of the previous character, which can be 0 or any number of times.                                                                                                                                                                                                                                                                                                                                                              |                                                                                                   |
|                    .                    | Matches any single character except for line breaks.                                                                                                                                                                                                                                                                                                                                                                                                             |                                                                                                   |
|                            ^                            | Correspond au début de ligne. For example - **^h** will match lines starting with h.                                                                                                                                                                                                                                                                                                                                                             |                                                                                                   |
|                            $                            | Prend la fin de ligne EOL en considération. For example - **h$** will match lines ending in h.                                                                                                                                                                                                                                                                                                                                                   |                                                                                                   |
|  [] | Matches any single character specified in parentheses. For example - **[who]** will match w or h or o; **[0-9]** will match one digit; **[0-9][a-z]** will match characters composed of one digit and a single lowercase letter. |                                                                                                   |
| [^] | Matches any single character except for the characters in parentheses. For example - **[^0-9]** will match any single non-numeric character. **[^a-z]** will match any single character that is not a lowercase letter.                                                                                                  |                                                                                                   |
|                            \                           | Escape character, used to cancel the meaning represented by some special symbols.                                                                                                                                                                                                                                                                                                                                                                                | `echo -e "1.2\n122"  \\| grep -E '1\.2'`<br/>**1.2**                           |
|                       \\{n\\}                       | Matches the number of occurrences of the previous single character, n represents the number of matches.                                                                                                                                                                                                                                                                                                                                                          | `echo -e "1994\n2000\n2222" \\| grep "[24]\{4\}"`<br/>**2222**                               |
|                       \\{n,\\}                      | Matches the previous single character at least n times.                                                                                                                                                                                                                                                                                                                                                                                                          | `echo -e "1994\n2000\n2222" \\| grep  "[29]\{2,\}"`<br/>1**99**4<br/>**2222**                |
|                      \\{n,m\\}                      | Matches the previous single character at least n times and at most m times.                                                                                                                                                                                                                                                                                                                                                                                      | `echo -e "abcd\n20\n300\n4444" \\| grep "[0-9]\{2,4\}"`<br/>**20**<br/>**300**<br/>**4444** |

### ERE

|          métacaractère         | Description                                                                                                       | exemple bash                                                                                                                        |
| :----------------------------: | :---------------------------------------------------------------------------------------------------------------- | :---------------------------------------------------------------------------------------------------------------------------------- |
|                +               | Matches the number of occurrences of the previous single character, which can be 1 or more times. | `echo -e "abcd\nab\nabb\ncdd"  \\| grep -E "ab+"`<br/>**ab**cd<br/>**ab**<br/>**abb**                                           |
|                ?               | Matches the number of occurrences of the previous single character, which can be 0 or 1.          | `echo -e  "ac\nabc\nadd" \\| grep -E 'a?c'`<br/>**ac**<br/>ab**c**                                                               |
| \\< | Boundary character, matching the beginning of a string.                                           | `echo -e "1\n12\n123\n1234" \\| grep -E "\<123"`<br/>**123**<br/>**123**4                                                      |
|              \\>             | Boundary character, matching the end of the string.                                               | `echo -e "export\nimport\nout"  \\| grep -E "port\>"`<br/>ex**port**<br/>im**port**                                             |
|      ()     | Combinatorial matching, that is, the string in parentheses as a combination, and then match.      | `echo -e "123abc\nabc123\na1b2c3" \\| grep -E "([a-z][0-9])+"`<br/>ab**c1**23<br/>**a1b2c3**                                     |
|              \\|              | The pipeline symbol represents the meaning of "or".                                               | `echo -e "port\nimport\nexport\none123" \\| grep -E "port\>\\|123"`<br/>**port**<br/>im**port**<br/>ex**port**<br/>one**123** |

ERE also supports characters with special meanings:

| caractères spéciaux | Description                                                                                                                          |
| :-----------------: | :----------------------------------------------------------------------------------------------------------------------------------- |
|         \\w        | Équivalent à **[a-zA-Z0-9]**                                                     |
|         \\W        | Équivalent à **[^a-zA-Z0-9]**                                                    |
|         \\d        | Équivalent à **[0-9]**                                                           |
|         \\D        | Équivalent à **[^0-9]**                                                          |
|         \\b        | Équivalent à **\\<** or **\\>**                                                                         |
|         \\B        | Matches non-boundary character.                                                                                      |
|         \\s        | Matches any whitespace character. Équivalent à **[ \f\n\r\t\v]** |
|         \\S        | Équivalent à **[^ \f\n\r\t\v]**                                                  |

| Caractère blanc | Description                                                                            |
| :-------------: | :------------------------------------------------------------------------------------- |
|       \\f      | Matches a single feed character. Équivalent à **\\x0c** et **\\cL**  |
|       \\n      | Matches individual line breaks. Équivalent à **\\x0a** et **\\cJ**   |
|       \\r      | Matches a single carriage return. Équivalent à **\\x0d** et **\\cM** |
|       \\t      | Correspond à un onglet unique. Équivalent à **\\x09** et **\\cI**    |
|       \\v      | Matches a single vertical tab. Équivalent à **\\x0b** et **\\cK**    |

### Caractère POSIX

Sometimes, you may see "POSIX character"(also known as "POSIX character class").
Please note that the author rarely uses the "POSIX character class", but has included this section to enhance basic understanding.

|                                         Caractère POSIX                                        | équivalent à                                                                                                                                                                                                                                                                                       |
| :--------------------------------------------------------------------------------------------: | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
|  [:alnum:] | [a-zA-Z0-9]                                                                                                                                                                                                                                    |
|  [:alpha:] | [a-zA-Z]                                                                                                                                                                                                                                       |
|  [:lower:] | [a-z]                                                                                                                                                                                                                                          |
|  [:upper:] | [A-Z]                                                                                                                                                                                                                                          |
|  [:digit:] | [0-9]                                                                                                                                                                                                                                          |
|  [:space:] | [ \f\n\r\t\v]                                                                                                                                                                                                                                  |
|  [:graph:] | [^ \f\n\r\t\v]                                                                                                                                                                                                                                 |
|  [:blank:] | [ \t]                                                                                                                                                                                                                                          |
|  [:cntrl:] | [\x00-\x1F\x7F]                                                                                                                                                                                                                                |
|  [:print:] | [\x20-\x7E]                                                                                                                                                                                                                                    |
|  [:punct:] | [][!"#$%&'()\*+,./:;<=>?@\^_\`{\\|}~-] |
| [:xdigit:] | [A-Fa-f0-9]                                                                                                                                                                                                                                    |

### Présentation des expressions régulières

Il existe de nombreux sites Web permettant de pratiquer les compétences en expression régulière en ligne, tels que :

- [regex101](https://regex101.com/)
- [oschina](https://tool.oschina.net/regex/)
- [regexr](https://regexr.com/)
- [regelearn](https://regexlearn.com/)
- [coding](https://coding.tools/regex-tester)

* [cyrilex](https://extendsclass.com/regex-tester.html)

