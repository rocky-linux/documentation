---
title: Valuta
author: Christine Belzie
contributors: Steven Spencer, Ganna Zhyrnova
---

## Einleitung

Wenn Sie häufig reisen oder ins Ausland ziehen, vereinfachen Sie Ihre Finanzplanung mit Valuta. Diese Anwendung rechnet schnell zwei Währungen um.

## Vorbedingungen

Für diese Anleitung benötigen Sie Folgendes:

- Rocky Linux
- Flatpak
- FlatHub

## Installationsanweisungen

![Screenshot of the Valuta page on Flathub with the blue install button highlighted in a red square](images/01_valuta.png)

1. Gehen Sie zu [Flathub.org] (https://flathub.org), geben Sie `Valuta` in die Suchleiste ein und klicken Sie auf **Install**

    ![manual install script and run script](images/valuta-install.png)

2. Kopieren Sie das manuelle Skript in Ihr Terminal:

    ```bash
    flatpak install flathub io.github.idevecore.Valuta
    ```

3. Führen Sie anschließend das manuelle Installationsskript in Ihrem Terminal aus:

    ```bash
    flatpak run flathub io.github.idevecore.Valuta
    ```

## Wie funktioniert es?

Um `Valuta` zu verwenden, gehen Sie wie folgt vor:

1. Wählen Sie im Dropdown-Menü Ihr Land aus und geben Sie den Betrag ein, den Sie ausgeben möchten.

    ![Screenshot of Valuta app showing 1000 USD in the input field, with a grey arrow pointing down to a grey box showing 1000 USD](images/02_valuta.png)

2. Wählen Sie aus dem Dropdown-Menü das Land aus, in das Sie reisen. Der umgerechnete Betrag wird automatisch angezeigt.

![Screenshot showing a grey arrow pointing upward to a green box displaying the converted amount, 899.52 EUR](images/03_valuta.png)

## Zusammenfassung

Ob für den Urlaub oder eine Geschäftsreise, `Valuta` vereinfacht den Währungsumtausch. Möchten Sie mehr erfahren oder Ideen zur Verbesserung teilen? [Ein Issue im Valuta-Repository bei GitHub einreichen](https://github.com/ideveCore/valuta/issues).
