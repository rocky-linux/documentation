---
title: Markdown Demo
author: Einstein
contributors: Dr. Ben Dover
tested_with: 8.5
tags:
  - sample
  - crowdin
  - markdown
---

# Sommario

!!! WARNING "Attenzione"

    Non prendete sul serio ciò che leggete in questo documento.

Come si può capire leggendo, si tratta di un esempio piuttosto sciocco, pensato per testare alcuni problemi di traduzione che stiamo riscontrando. Ma poiché i problemi non sono ancora stati risolti, modificheremo il file un po' qua e un po' là per vedere l'effetto che fa. È divertente scrivere però!

Questa guida illustra i tag Markdown più diffusi utilizzati su [https://docs.rockylinux.org](https://docs.rockylinux.org) e include anche il tag admonitions, che non fa parte dei tag Markdown standard.

## La Demo

> Questo è un esempio di citazione. Ben formattato.

A volte si vedono cose come _questo_.

Che ne dite di una piccola **faccina in grassetto**

Nella maggior parte dei casi, si tratta di un testo diretto come questo.

A volte è necessario mostrare un <codice>comando</codice>

O comandi multipli:

```
dnf install my_stapler
dnf update my_pencil
dnf remove my_notepad
systemctl enable my_stapler
```

Altre volte sono necessari elenchi puntati o numerati:

- Credo che tu abbia la mia cucitrice
- Ora che ci penso, non riesco nemmeno a trovare la mia bussola
- In caso contrario, per favore, restituitemi almeno la mia matita
- Ne ho decisamente bisogno

1. Non sapevo che ne avessi bisogno
2. Ecco la tua matita rotta
3. Affilare è inutile

E potrebbe essere necessario un ammonimento:

!!! SUGGERIMENTO

    Matite e cucitrici sono davvero vecchia scuola.

Spesso, quando un comando ha più opzioni o è necessario elencarne di specifiche, si può usare una tabella per identificare le cose:

| Strumento | Uso                                              | Ulteriori informazioni                                           |
| --------- | ------------------------------------------------ | ---------------------------------------------------------------- |
| matita    | scrittura o stampa                               | spesso sostituito con una penna                                  |
| penna     | scrittura o stampa                               | spesso sostituito con una stilo                                  |
| stylus    | scrittura o stampa su un dispositivo elettronico | a volte sostituito da una tastiera                               |
| tastiera  | scrittura o stampa su un dispositivo elettronico | mai sostituito - usato fino a quando è pieno di briciole di cibo |
| notepad   | prendi appunti                                   | sostituto per una memoria talvolta difettosa                     |
