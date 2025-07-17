---
title: Valuta
author: Christine Belzie
contributors: Steven Spencer, Ganna Zhyrnova
---

## Introduzione

Se viaggiate o vi trasferite spesso all'estero, semplificate la vostra pianificazione finanziaria con Valuta. Questa applicazione converte rapidamente due valute.

## Presupposti

Questa guida presuppone che si disponga di quanto segue:

- Rocky Linux
- Flatpak
- FlatHub

## Processo di installazione

![Screenshot of the Valuta page on Flathub with the blue install button highlighted in a red square](images/01_valuta.png)

1. Andate su [Flathub.org](https://flathub.org), digitate "Valuta" nella barra di ricerca e cliccate su **Installa**

    ![manual install script and run script](images/valuta-install.png)

2. Copiare lo script manuale nel terminale:

    ```bash
    flatpak install flathub io.github.idevecore.Valuta
    ```

3. Infine, lo script manuale nel terminale:

    ```bash
    flatpak run flathub io.github.idevecore.Valuta
    ```

## Come si usa

Per utilizzare Valuta, procedere come segue:

1. Scegliete il vostro Paese dal menu a tendina e digitate il denaro che volete spendere.

    ![Screenshot of Valuta app showing 1000 USD in the input field, with a grey arrow pointing down to a grey box showing 1000 USD](images/02_valuta.png)

2. Selezionare il Paese in cui si viaggia dal menu a discesa. L'importo convertito apparirà automaticamente.

![Screenshot showing a grey arrow pointing upward to a green box displaying the converted amount, 899.52 EUR](images/03_valuta.png)

## Conclusione

Che si tratti di una vacanza o di un viaggio di lavoro, Valuta semplifica la conversione di valuta. Volete saperne di più o condividere idee per migliorarlo? [Sottoporre un problema nel repository di Valuta su GitHub](https://github.com/ideveCore/valuta/issues).
