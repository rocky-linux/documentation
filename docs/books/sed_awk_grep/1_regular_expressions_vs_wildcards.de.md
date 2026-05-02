---
title: Reguläre Ausdrücke und Wildcards
author: tianci li
contributors:
tags:
  - Reguläre Ausdrücke
  - Wildcards
---

# Reguläre Ausdrücke und Wildcards

Im GNU/Linux-Betriebssystem haben reguläre Ausdrücke und Wildcards oft das gleiche Symbol (oder den gleichen Stil), weshalb sie häufig verwechselt werden.

Was ist der Unterschied zwischen regulären Ausdrücken und Wildcards?

Gemeinsamkeiten:

- They have the same symbol but represent entirely different meanings.

Unterschiede:

- Regular expressions match file content; Wildcards are typically used to match file or directory names.
- Regular expressions are typically used on commands such as `grep`, `sed`, `awk`, and so on.
- Wildcards are typically used with commands such as `cp`, `find`, `mv`, `touch`, `ls`, and so on.

## Wildcards unter GNU/Linux

GNU/Linux operating systems support these wildcards:

|                      Wildcards-Stil                     | Rolle                                                                                                                                                                                                              |
| :-----------------------------------------------------: | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
|                            ?                            | Matches one character of a file or directory name.                                                                                                                                                 |
|                            \*                           | Matches 0 or more arbitrary characters of a file or directory name.                                                                                                                                |
| [ ] | Matches any single character in parentheses. Zum Beispiel, &#91;one&#93; das die Zeichen o oder n oder e entspricht.                       |
| [-] | Entspricht einem Zeichen innerhalb des angegebenen Bereichs in Klammern. For example, &#91;0-9&#93; matches any single number from 0 to 9. |
| [^] | Logischer „not“ Abgleich eines einzelnen Zeichen. For example, &#91;^a-zA-Z&#93; represents matching a single non-letter character.        |
|                           {,}                           | Nicht kontinuierlicher Abgleich mehrerer einzelner Zeichen. Durch Kommata getrennt.                                                                                                |
|           {..}          | Gleich wie &#91;-&#93;. Zum Beispiel {0..9} und {a..z}                                     |

Verschiedene Befehle unterstützen unterschiedliche Wildcard-Stile:

- `find`: unterstützt \*, ?, [ ], [-], [^]
- `ls`: alle Stile werden unterstützt
- `mkdir`: unterstützt {,} und {..}
- `touch`: unterstützt {,} und {..}
- `mv`: alle Stile werden unterstützt
- `cp`: alle Stile werden unterstützt

Zum Beispiel:

```bash
Shell > mkdir -p /root/dir{1..3}
Shell > cd /root/dir1/
Shell > touch file{1,5,9}
Shell > cd 
Shell > mv /root/dir1/file[1-9]  /root/dir2/
Shell > cp /root/dir2/file{1..9} /root/dir3/
Shell > find / -iname "dir[1-9]" -a -type d
```

## Reguläre Ausdrücke unter GNU/Linux

Aufgrund der historischen Entwicklung gibt es im Zusammenhang mit regulären Ausdrücken zwei Hauptschulen:

- POSIX:
  - BRE（basic regular express）
  - ERE（extend regular express）
  - POSIX character class
- PCRE (Perl-kompatible reguläre Ausdrücke): unter den verschiedenen Programmiersprachen am häufigsten verwendet.

|        | BRE |                          ERE                          | POSIX character class |                          PCRE                         |
| :----: | :-: | :---------------------------------------------------: | :-------------------: | :---------------------------------------------------: |
| `grep` |  √  | √<br/>(setzt die Option -E voraus) |           √           | √<br/>(setzt die Option -P voraus) |
|  `sed` |  √  | √<br/>(setzt die Option -r voraus) |           √           |                           ×                           |
|  `awk` |  √  |                           √                           |           √           |                           ×                           |

Wenn Sie sich für reguläre Ausdrücke interessieren, besuchen Sie bitte [diese Website](https://www.regular-expressions.info/), um weitere nützliche Informationen zu erhalten.

### BRE

BRE (Basic Regular Expressions) ist der älteste Typ regulärer Ausdrücke, der durch den Befehl „grep“ in UNIX-Systemen und den Texteditor **ed** eingeführt wurde.

|                       Metazeichen                       | Beschreibung                                                                                                                                                                                                                                                                                                                                                                                                                                                                             | Bash-Beispiel                                                                                     |
| :-----------------------------------------------------: | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :------------------------------------------------------------------------------------------------ |
|                            \*                           | Entspricht der Häufigkeit des Vorkommens des vorherigen Zeichens, das 0 oder beliebig oft sein kann.                                                                                                                                                                                                                                                                                                                                                                     |                                                                                                   |
|                    .                    | Entspricht jedes einzelne Zeichen außer Zeilenumbrüchen.                                                                                                                                                                                                                                                                                                                                                                                                                 |                                                                                                   |
|                            ^                            | Übereinstimmung mit Zeilenanfang. Beispiel: **^h** stimmt mit Zeilen überein, die mit h beginnen.                                                                                                                                                                                                                                                                                                                                        |                                                                                                   |
|                            $                            | Übereinstimmung mit Ende der Zeile. Beispielsweise stimmt **h$** mit Zeilen überein, die mit h enden.                                                                                                                                                                                                                                                                                                                                                    |                                                                                                   |
|  [] | Entspricht beliebigen Zeichen in Klammern. Beispielsweise stimmt **[who]** mit w, h oder o überein; **[0-9]** entspricht einer Ziffer; **[0-9][a-z]** findet Zeichen, die aus einer Ziffer und einem einzelnen Kleinbuchstaben bestehen. |                                                                                                   |
| [^] | Matches any single character except for the characters in parentheses. For example - **[^0-9]** will match any single non-numeric character. **[^a-z]** findet jedes einzelne Zeichen, bei dem es sich nicht um einen Kleinbuchstaben handelt.                                                                                   |                                                                                                   |
|                            \                           | Escape-Zeichen, das verwendet wird, um die Bedeutung einiger Sondersymbole aufzuheben.                                                                                                                                                                                                                                                                                                                                                                                   | `echo -e "1.2\n122"  \\| grep -E '1\.2'`<br/>**1.2**                           |
|                       \\{n\\}                       | Matches the number of occurrences of the previous single character, n represents the number of matches.                                                                                                                                                                                                                                                                                                                                                                  | `echo -e "1994\n2000\n2222" \\| grep "[24]\{4\}"`<br/>**2222**                               |
|                       \\{n,\\}                      | Matches the previous single character at least n times.                                                                                                                                                                                                                                                                                                                                                                                                                  | `echo -e "1994\n2000\n2222" \\| grep  "[29]\{2,\}"`<br/>1**99**4<br/>**2222**                |
|                      \\{n,m\\}                      | Matches the previous single character at least n times and at most m times.                                                                                                                                                                                                                                                                                                                                                                                              | `echo -e "abcd\n20\n300\n4444" \\| grep "[0-9]\{2,4\}"`<br/>**20**<br/>**300**<br/>**4444** |

### ERE

|           Metazeichen          | Beschreibung                                                                                                      | Bash-Beispiel                                                                                                                       |
| :----------------------------: | :---------------------------------------------------------------------------------------------------------------- | :---------------------------------------------------------------------------------------------------------------------------------- |
|                +               | Matches the number of occurrences of the previous single character, which can be 1 or more times. | `echo -e "abcd\nab\nabb\ncdd"  \\| grep -E "ab+"`<br/>**ab**cd<br/>**ab**<br/>**abb**                                           |
|                ?               | Matches the number of occurrences of the previous single character, which can be 0 or 1.          | `echo -e  "ac\nabc\nadd" \\| grep -E 'a?c'`<br/>**ac**<br/>ab**c**                                                               |
| \\< | Boundary character, matching the beginning of a string.                                           | `echo -e "1\n12\n123\n1234" \\| grep -E "\<123"`<br/>**123**<br/>**123**4                                                      |
|              \\>             | Boundary character, matching the end of the string.                                               | `echo -e "export\nimport\nout"  \\| grep -E "port\>"`<br/>ex**port**<br/>im**port**                                             |
|      ()     | Combinatorial matching, that is, the string in parentheses as a combination, and then match.      | `echo -e "123abc\nabc123\na1b2c3" \\| grep -E "([a-z][0-9])+"`<br/>ab**c1**23<br/>**a1b2c3**                                     |
|              \\|              | The pipeline symbol represents the meaning of "or".                                               | `echo -e "port\nimport\nexport\none123" \\| grep -E "port\>\\|123"`<br/>**port**<br/>im**port**<br/>ex**port**<br/>one**123** |

ERE also supports characters with special meanings:

| Sonderzeichen | Beschreibung                                                                                                                          |
| :-----------: | :------------------------------------------------------------------------------------------------------------------------------------ |
|      \\w     | Äquivalent zu **[a-zA-Z0-9]**                                                     |
|      \\W     | Äquivalent zu **[^a-zA-Z0-9]**                                                    |
|      \\d     | Äquivalent zu **[0-9]**                                                           |
|      \\D     | Äquivalent zu **[^0-9]**                                                          |
|      \\b     | Äquivalent zu **\\<** oder **\\>**                                                                       |
|      \\B     | Matches non-boundary character.                                                                                       |
|      \\s     | Matches any whitespace character. Äquivalent zu **[ \f\n\r\t\v]** |
|      \\S     | Äquivalent zu **[^ \f\n\r\t\v]**                                                  |

| Leerzeichen | Beschreibung                                                                             |
| :---------: | :--------------------------------------------------------------------------------------- |
|     \\f    | Matches a single feed character. Äquivalent zu **\\x0c** und **\\cL**  |
|     \\n    | Matches individual line breaks. Äquivalent zu **\\x0a** und **\\cJ**   |
|     \\r    | Matches a single carriage return. Äquivalent zu **\\x0d** und **\\cM** |
|     \\t    | Entspricht einem einzelnen Tab. Äquivalent zu **\\x09** und **\\cI**   |
|     \\v    | Matches a single vertical tab. Äquivalent zu **\\x0b** und **\\cK**    |

### POSIX-Zeichen

Sometimes, you may see "POSIX character"(also known as "POSIX character class").
Please note that the author rarely uses the "POSIX character class", but has included this section to enhance basic understanding.

|                                          POSIX-Zeichen                                         | Äquivalent zu                                                                                                                                                                                                                                                                                      |
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

### Introducing regular expressions

Many websites exist for practicing regular expression skills online, such as:

- [regex101](https://regex101.com/)
- [oschina](https://tool.oschina.net/regex/)
- [regexr](https://regexr.com/)
- [regelearn](https://regexlearn.com/)
- [coding](https://coding.tools/regex-tester)

* [cyrilex](https://extendsclass.com/regex-tester.html)

