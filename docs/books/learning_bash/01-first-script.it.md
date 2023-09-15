---
title: Bash - Primo script
author: Antoine Le Morvan
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 8.5
tags:
  - education
  - bash scripting
  - bash
---

# Bash - Primo script

In questo capitolo imparerete a scrivere il vostro primo script in bash.

****

**Obiettivi**: In questo capitolo imparerete a:

:heavy_check_mark: Scrivere il tuo primo script in bash;  
:heavy_check_mark: Eseguire il tuo primo script;  
:heavy_check_mark: Specificare quale shell usare con il cosiddetto shebang;

:checkered_flag: **linux**, **script**, **bash**

**Conoscenza**: :star:     
**Complessità**: :star:

**Tempo di lettura**: 10 minuti

****

## Il mio primo script

Per iniziare a scrivere uno script di shell, è conveniente utilizzare un editor di testo che supporti l'evidenziazione della sintassi.

`vim`, ad esempio, è un ottimo strumento per questo scopo.

Il nome dello script deve rispettare alcune regole:

* nessun nome di comandi esistenti;
* solo caratteri alfanumerici, cioè senza caratteri accentati o spazi;
* estensione .sh per indicare che si tratta di uno script di shell.

!!! note "Nota"

    In queste lezioni l'autore utilizza il simbolo "$" per indicare il prompt dei comandi dell'utente.

```
#!/usr/bin/env bash
#
# Autore : Team di documentazione Rocky
# Data: Marzo 2022
# Versione 1.0.0: Visualizza il testo "Hello world!"
#

# Visualizza un testo sullo schermo :
echo "Hello world!"
```

Per poter eseguire questo script, come argomento della bash:

```
$ bash hello-world.sh
Hello world !
```

O, più semplicemente, dopo avergli dato il diritto di eseguire:

```
$ chmod u+x ./hello-world.sh
$ ./hello-world.sh
Hello world !
```

!!! note "Nota"

    Per eseguire lo script, è necessario chiamarlo con `./` prima del nome quando ci si trova nella directory in cui risiede lo script. Se non si trova in quella directory, è necessario richiamarlo con l'intero percorso dello script, OPPURE collocarlo in una directory che si trova all'interno della variabile d'ambiente PATH (esempi: `/usr/local/sbin`, `/usr/local/bin`, ecc.)
    L'interprete rifiuterà di eseguire uno script presente nella directory corrente senza indicare un percorso (qui con `./` prima di esso).
    
    Il comando `chmod` deve essere passato una sola volta su uno script appena creato.

La prima riga da scrivere in qualsiasi script è quella che indica il nome del binario di shell da usare per eseguirlo. Se si vuole usare la shell `ksh` o il linguaggio interpretato `python`, si sostituisce la riga:

```
#!/usr/bin/env bash
```

con :

```
#!/usr/bin/env ksh
```

o con :

```
#!/usr/bin/env python
```

Questa prima riga si chiama "`shebang`". Inizia con i caratteri `#!` seguiti dal percorso del binario dell'interprete dei comandi da utilizzare.

!!! hint "Sullo shebang"

    Può capitare di incontrare lo "shebang" in uno script che non contiene la sezione "env" e contiene semplicemente l'interprete da usare. (Esempio: `#!/bin/bash`). Il metodo dell'autore è considerato il modo raccomandato e corretto per formattare il "shebang".
    
    Perché si raccomanda il metodo dell'autore? Perché aumenta la portabilità dello script. Se per qualche motivo l'interprete si trovasse in una directory completamente diversa, l'interprete verrebbe comunque trovato se si usasse il metodo dell'autore.

Durante il processo di scrittura, è necessario fare la revisione dello script, utilizzando in particolare i commenti:

* una presentazione generale, all'inizio, per indicare lo scopo dello script, il suo autore, la sua versione, il suo utilizzo, ecc.
* lungo il testo per aiutare a comprendere le azioni.

I commenti possono essere inseriti su una riga separata o alla fine di una riga contenente un comando.

Esempio:

```
# Questo programma visualizza la data
date # Questa riga è la riga che visualizza la data!
```
