---
title: Markdown Demo
author: Steven Spencer
contributors: Wale Soyinka, Tony Guntharp
tested_with: 8.5
tags:
  - sample
  - crowdin
  - markdown
---

# Sommario

## Background

- Utilizzare [Markdown](https://daringfireball.net/projects/markdown).
- Conoscenza di markdown.

Questa guida illustra i tag Markdown più diffusi utilizzati su [https://docs.rockylinux.org](https://docs.rockylinux.org) e include il tag admonitions, che non fa parte dei tag Markdown standard.

## La Demo

> Questo è un esempio di citazione. Ben formattato.

A volte si vedono cose come _questo_.

Che ne dite di una piccola **faccina in grassetto**

Il più delle volte si tratta di un testo diretto come questo.

A volte, è necessario mostrare un <codice>comando</codice>

O comandi multipli:

```bash
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

### Avvertenze

Le avvertenze, anch'esse richiamate, sono un'ottima scelta per inserire contenuti collaterali senza interrompere significativamente il flusso del documento. Materiale per MkDocs fornisce diversi tipi di ammonimenti e consente l'inclusione e l'annidamento di contenuti arbitrari.

!!! TIP

    Le matite e le spillatrici sono di vecchia concezione.

#### Utilizzo

Le ammonizioni seguono una sintassi semplice: un blocco inizia con `!!!`, seguito da una parola chiave usata come qualificatore di tipo. Il contenuto del blocco segue sulla riga successiva, rientrando di quattro spazi:

!!! note

    Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla et euismod
    nulla. Curabitur feugiat, tortor non consequat finibus, justo purus auctor
    massa, nec semper lorem quam in massa.

#### Modifica del titolo

Per impostazione predefinita, il titolo sarà uguale al qualificatore di tipo nel caso del titolo. Tuttavia, è possibile modificarlo aggiungendo una stringa quotata contenente Markdown valido (inclusi collegamenti, formattazione, ...) dopo il qualificatore di tipo:

!!! note "Phasellus posuere in sem ut cursus"

    Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla et euismod
    nulla. Curabitur feugiat, tortor non consequat finibus, justo purus auctor
    massa, nec semper lorem quam in massa.

Spesso, quando un comando ha più opzioni o è necessario elencarne di specifiche, si può usare una tabella per identificare le cose:

| Strumento | Uso                                              | Ulteriori informazioni                                           |
| --------- | ------------------------------------------------ | ---------------------------------------------------------------- |
| matita    | scrittura o stampa                               | spesso sostituito con una penna                                  |
| penna     | scrittura o stampa                               | spesso sostituito con una stilo                                  |
| stylus    | scrittura o stampa su un dispositivo elettronico | a volte sostituito da una tastiera                               |
| tastiera  | scrittura o stampa su un dispositivo elettronico | mai sostituito - usato fino a quando è pieno di briciole di cibo |
| notepad   | prendi appunti                                   | sostituto per una memoria talvolta difettosa                     |
