---
title: Bash - Verificare le proprie conoscenze
author: Antoine Le Morvan
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 8.5
tags:
  - education
  - bash scripting
  - bash
---

# Bash - Verificare le proprie conoscenze

:heavy_check_mark: Ogni ordine deve restituire un codice di ritorno al termine della sua esecuzione:

- [ ] Vero
- [ ] Falso

:heavy_check_mark: Un codice di ritorno pari a 0 indica un errore di esecuzione:

- [ ] Vero
- [ ] Falso

:heavy_check_mark: Il codice di ritorno è memorizzato nella variabile `$@`:

- [ ] Vero
- [ ] Falso

:heavy_check_mark: Il comando test consente di:

- [ ] Verificare il tipo di file
- [ ] Testare una variabile
- [ ] Confrontare i numeri
- [ ] Confrontare il contenuto di 2 file

:heavy_check_mark: Il comando `expr`:

- [ ] Concatena 2 stringhe di caratteri
- [ ] Esegue operazioni matematiche
- [ ] Visualizza il testo sullo schermo

:heavy_check_mark: La sintassi della struttura condizionale sottostante vi sembra corretta? Spiegare perché.

```bash
if command
    command if $?=0
else
    command if $?!=0
fi
```

- [ ] Vero
- [ ] Falso

:heavy_check_mark: Cosa significa la seguente sintassi: `${variable:=value}`

- [ ] Visualizza un valore sostitutivo se la variabile è vuota
- [ ] Visualizza un valore sostitutivo se la variabile non è vuota
- [ ] Assegna un nuovo valore alla variabile se è vuota

:heavy_check_mark: La sintassi della struttura alternativa condizionale qui sotto vi sembra corretta? Spiegare perché.

```bash
case $variable in
  value1)
    commands if $variable = value1
  value2)
    commands if $variable = value2
  *)
    commands for all values of $variable != of value1 and value2
    ;;
esac
```

- [ ] Vero
- [ ] Falso

:heavy_check_mark: Quale delle seguenti non è una struttura per il looping?

- [ ] while
- [ ] until
- [ ] loop
- [ ] for
