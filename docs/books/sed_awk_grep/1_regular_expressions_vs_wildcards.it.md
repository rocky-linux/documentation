---
title: Espressioni regolari e wildcards
author: Tianci Li
contributors:
tags:
  - Regular expressions
  - Wildcards
---

# Espressioni regolari e wildcards

Nel sistema operativo GNU/Linux, le espressioni regolari e le wildcard hanno spesso lo stesso simbolo (o stile), quindi, sono spesso confusi tra loro.

Qual è la differenza tra espressioni regolari e wildcard?

Analogie:

- Utilizzano lo stesso simbolo, ma hanno un significato completamente differente.

Differenze:

- Le espressioni regolari sono usate per trovare corrispondenze nel contenuto dei file; le wildcard sono tipicamente usate per individuare i nomi di file o directory.
- Le espressioni regolari sono utilizzate solitamente in comandi come `grep`, `sed`, `awk` e così via.
- Le wildcard sono invece utilizzate con comandi quali `cp`, `find`, `mv`, `touch`, `ls`, e così via.

## Wildcard su GNU/Linux

Il sistema operativo GNU/Linux supporta queste wildcard:

|                   stile delle wildcard                  | ruolo                                                                                                                                                                                                                                                          |
| :-----------------------------------------------------: | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
|                            ?                            | Corrisponde a un carattere del nome di un file o di una directory.                                                                                                                                                                             |
|                            \*                           | Abbina 0 o più caratteri qualsiasi del nome di un file o una cartella.                                                                                                                                                                         |
| [ ] | Cerca la corrispondenza di ogni singolo carattere tra le parentesi. Ad esempio, &#91;one&#93;, cerca la corrispondenza sia con 'o' oppure 'n' o 'e'.                                   |
| [-] | Cerca la corrispondenza con ogni singolo carattere all'interno dell'intervallo dato tra le parentesi. Ad esempio, &#91;0-9&#93;, cerca l'abbinamento di ogni singolo numero tra 0 e 9. |
| [^] | Indica la negazione logica nel cercare la corrispondenza di un singolo carattere. Ad esempio, &#91;^a-zA-Z&#93;, indica che un singolo carattere non deve essere alfabetico.           |
|                           {,}                           | Corrispondenza non continua di più caratteri singoli. Separati da virgole.                                                                                                                                                     |
|           {..}          | Analogo a &#91;-&#93;. Ad esempio {0..9} e {a..z}                                                                                      |

Comandi differenti prevedono diversi stili di wildcard:

- `find`: Utilizza \*, ?, [ ], [-], [^]
- `ls`: accetta tutti gli stili di wildcards
- `mkdir`: accetta {,} e {..}
- `touch`: adotta {,} e {..}
- `mv`: accetta tutti gli stili di wildcard
- `cp`: accetta tutti gli stili di wildcard

Ad esempio:

```bash
Shell > mkdir -p /root/dir{1..3}
Shell > cd /root/dir1/
Shell > touch file{1,5,9}
Shell > cd 
Shell > mv /root/dir1/file[1-9]  /root/dir2/
Shell > cp /root/dir2/file{1..9} /root/dir3/
Shell > find / -iname "dir[1-9]" -a -type d
```

## Espressioni regolari su GNU/Linux

Per ragioni storiche, esistono due scuole principali delle espressioni regolari:

- POSIX:
  - BRE（espressioni regolari di base）
  - ERE（espressioni regolari estese）
  - Classe di carattere POSIX
- PCRE (Espressioni Regolari Compatibili con Perl): La più comune tra vari linguaggi di programmazione.

|        | BRE |                         ERE                         | Classe di carattere POSIX |                         PCRE                        |
| :----: | :-: | :-------------------------------------------------: | :-----------------------: | :-------------------------------------------------: |
| `grep` |  √  | √<br/>(Richiede il parametro -E) |             √             | √<br/>(Richiede il parametro -P) |
|  `sed` |  √  | √<br/>(Richiede il parametro -r) |             √             |                          ×                          |
|  `awk` |  √  |                          √                          |             √             |                          ×                          |

Per saperne di più sulle espressioni regolari, si prega di prendere visione di [questo sito web](https://www.regular-expressions.info/) per maggiori informazioni.

### BRE

BRE (Espressione regolare di base) è la più vecchia tipologia di espressione regolare, fu introdotta dal comando `grep` nei sistemi UNIX e dall'editor di testo **ed**.

|                      meta-carattere                     | descrizione                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         | esempio di bash                                                                                   |
| :-----------------------------------------------------: | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :------------------------------------------------------------------------------------------------ |
|                            \*                           | Confronta il numero di occorrenze del carattere precedente, che può essere 0 o un numero qualsiasi di volte.                                                                                                                                                                                                                                                                                                                                                                                                        |                                                                                                   |
|                    .                    | Corrisponde ad un qualsiasi singolo carattere, ad eccezione delle interruzioni di riga.                                                                                                                                                                                                                                                                                                                                                                                                                             |                                                                                                   |
|                            ^                            | Trova la corrispondenza all'inizio della riga.  Ad esempio - **^h** corrisponde alle righe che iniziano con 'h'.                                                                                                                                                                                                                                                                                                                                                                                    |                                                                                                   |
|                            $                            | Trova la corrispondenza alla fine della riga.  Ad esempio - **h$** trova le righe che terminano con 'h'.                                                                                                                                                                                                                                                                                                                                                                                            |                                                                                                   |
|  [] | Cerca il risultato per ogni carattere specificato tra le parentesi. Per esempio, **[who]** cercherà le parole con 'w' o 'h' od 'o'; **[0-9]** ricerca un volere numerico da 1 a 9; **[0-9][a-z]** la corrispondenza includerà un carattere tra quelli numerici o lettere minuscole. |                                                                                                   |
| [^] | Segno di negazione logica. Cerca qualsiasi corrispondenza tranne quelli tra parentesi. Per esempio, **[^0-9]** abbinerà ogni carattere non numerico. **[^a-z]** cerca la corrispondenza i caratteri non siano una lettera minuscola.                                                                                                                        |                                                                                                   |
|                            \                           | Carattere di escape, in inglese backslash, utilizzato per annullare il significato rappresentato da alcuni simboli speciali.                                                                                                                                                                                                                                                                                                                                                                                        | `echo -e "1.2\n122"  \\| grep -E '1\.2'`<br/>**1.2**                           |
|                       \\{n\\}                       | Ricerca il numero di ripetizioni del singolo carattere che lo precede, n rappresenta il numero di ripetizioni.                                                                                                                                                                                                                                                                                                                                                                                                      | `echo -e "1994\n2000\n2222" \\| grep "[24]\{4\}"`<br/>**2222**                               |
|                       \\{n,\\}                      | Ricerca il carattere che lo precede se è ripetuto almeno n volte.                                                                                                                                                                                                                                                                                                                                                                                                                                                   | `echo -e "1994\n2000\n2222" \\| grep  "[29]\{2,\}"`<br/>1**99**4<br/>**2222**                |
|                      \\{n,m\\}                      | Ricerca il carattere che lo precede se è ripetuto almeno n volte ed un massimo di m volte.                                                                                                                                                                                                                                                                                                                                                                                                                          | `echo -e "abcd\n20\n300\n4444" \\| grep "[0-9]\{2,4\}"`<br/>**20**<br/>**300**<br/>**4444** |

### ERE

|         meta-carattere         | descrizione                                                                                                           | esempio di bash                                                                                                                     |
| :----------------------------: | :-------------------------------------------------------------------------------------------------------------------- | :---------------------------------------------------------------------------------------------------------------------------------- |
|                +               | Ricerca il numero di ripetizioni del carattere che lo precede, possono essere 1 o più volte.          | `echo -e "abcd\nab\nabb\ncdd"  \\| grep -E "ab+"`<br/>**ab**cd<br/>**ab**<br/>**abb**                                           |
|                ?               | Ricerca se un singolo carattere sia presente oppure no.                                               | `echo -e  "ac\nabc\nadd" \\| grep -E 'a?c'`<br/>**ac**<br/>ab**c**                                                               |
| \\< | Carattere boundary, ricerca il carattere all'inizio di una stringa.                                   | `echo -e "1\n12\n123\n1234" \\| grep -E "\<123"`<br/>**123**<br/>**123**4                                                      |
|              \\>             | Carattere boundary, ricerca se il carattere sia presente alla fine della stringa.                     | `echo -e "export\nimport\nout"  \\| grep -E "port\>"`<br/>ex**port**<br/>im**port**                                             |
|      ()     | Associazione combinatoria, ossia, ricerca una stringa tra le possibili combinazioni tra le parentesi. | `echo -e "123abc\nabc123\na1b2c3" \\| grep -E "([a-z][0-9])+"`<br/>ab**c1**23<br/>**a1b2c3**                                     |
|              \\|              | Il simbolo pipeline rappresenta l'operazione logica "o".                                              | `echo -e "port\nimport\nexport\none123" \\| grep -E "port\>\\|123"`<br/>**port**<br/>im**port**<br/>ex**port**<br/>one**123** |

ERE, inoltre, supporta i caratteri speciali:

| caratteri speciali | descrizione                                                                                                                        |
| :----------------: | :--------------------------------------------------------------------------------------------------------------------------------- |
|        \\w        | Equivale a **[a-zA-Z0-9]**                                                     |
|        \\W        | Equivale a **[^a-zA-Z0-9]**                                                    |
|        \\d        | Equivale a **[0-9]**                                                           |
|        \\D        | Equivale a **[^0-9]**                                                          |
|        \\b        | Equivale a **\\<** or **\\>**                                                                         |
|        \\B        | Cerca l'associazione solo con i caratteri non agli estremi.                                                        |
|        \\s        | Abbina ogni carattere whitespace. Equivale a **[ \f\n\r\t\v]** |
|        \\S        | Equivale a **[^ \f\n\r\t\v]**                                                  |

| carattere vuoto | descrizione                                                                            |
| :-------------: | :------------------------------------------------------------------------------------- |
|       \\f      | Ricerca il carattere di fine pagina. Equivale a **\\x0c** e **\\cL** |
|       \\n      | Ricerca l'interruzioni di riga. Equivale a **\\x0a** e **\\cJ**      |
|       \\r      | Ricerca il ritorno a capo. Equivale a **\\x0d** e **\\cM**           |
|       \\t      | Ricerca il carattere di tabulazione. Equivale a **\\x09** e **\cl**   |
|       \\v      | Ricerca la tabulazione verticale. Equivale a **\\x0b** e **\\cK**    |

### Carattere POSIX

Talvolta si possono incontrare i "caratteri POSIX" (anche noti come "classe di caratteri POSIX").
Si noti che l'autore utilizza raramente la “classe di caratteri POSIX”, ma ha incluso questa sezione per migliorare la comprensione di base.

|                                         Carattere POSIX                                        | equivale a                                                                                                                                                                                                                                                                                         |
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

### Introduzione alle espressioni regolari

Esistono molti siti web per fare pratica online con le espressioni regolari, come:

- [regex101](https://regex101.com/)
- [oschina](https://tool.oschina.net/regex/)
- [regexr](https://regexr.com/)
- [regelearn](https://regexlearn.com/)
- [coding](https://coding.tools/regex-tester)

* [cyrilex](https://extendsclass.com/regex-tester.html)

