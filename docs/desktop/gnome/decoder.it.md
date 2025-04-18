---
title: Decoder
author: Christine Belzie
contributors: Steven Spencer, Ganna Zhyrnova
---

## Introduzione

Avete bisogno di un codice QR per il vostro sito web, la vostra applicazione o i vostri profili sui social media? Scopri Decoder! L'applicazione consente di creare, salvare ed esportare codici QR.

## Presupposti

Questa guida presuppone che si disponga di quanto segue:

- Rocky Linux
- Flatpak
- FlatHub

## Processo dell'installazione

1. Andate sul [sito web di Flathub](https://flathub.org/), digitate "Decoder" nella barra di ricerca e fate clic su **Install**. ![Screenshot of the install button highlighted by a red rectangle](images/01_decoder.png)

    ![manual install script and run script](images/decoder_install.png)

2. Copiare lo script di installazione manuale ed eseguirlo in un terminale:

    ```bash
    flatpak install flathub com.belmoussaoui.Decoder
    ```

3. Infine, copiate il comando run ed eseguitelo nel vostro terminale:

    ```bash
    flatpak run com.belmoussaoui.Decoder
    ```

## Come creare un codice QR

Sono disponibili due tipi di codici QR. Scegliete l'opzione più adatta alle vostre esigenze:

- [Text](#text)
- [Wifi](#wifi)

### Text

![Screenshot of the test, description and URL, and Create buttons](images/02_decoder-text.png)

1. Fare clic sul pulsante **Text**

2. Aggiungete un link al sito web desiderato e aggiungete una descrizione, se la desiderate

3. Cliccare su **Create**

    ![Screenshot of the Save and Export screen with arrows](images/03_decoder-text.png)

4. Cliccare su **Save**

5. Cliccare su **Export**

### Wifi

![Screenshot showing all of the Wifi options with numbers and arrows](images/01_decoder-wifi.png)

1. Fare clic sul pulsante **Wifi**
2. Aggiungere il nome della rete
3. Aggiungere la password
4. Selezionare se la rete è nascosta o non nascosta
5. Selezionare l'algoritmo di crittografia utilizzato
6. Cliccare su **Export**
7. Cliccare su **Save**

### Come scansionare un codice QR

Oltre a creare e generare codici QR, è possibile utilizzare Decoder per scansionare i codici QR salvati sul computer. Fate quanto segue:

![Screenshot of a red circle on a grey button that has the word "Scan" written in black.](images/01_decoder-scan.png)

1. Cliccare su **Scan**

    ![Screenshot of the rectangular button with the words "From a Screenshot" written in white.](images/02_decoder-scan.png)

2. Fare clic su **From a Screenshot**

    ![Screenshot of grey square surrounding options menu, and red square surrounding the "Take a Screenshot button"](images/03_decoder-scan.png)

3. Scegliete gli effetti desiderati e cliccate su **Take a Screenshot**

    ![Screenshot of a red arrow pointing at a blue button that has the word "Share" written in white](images/04_decoder-scan.png)

4. Cliccare su **Share**

5. Scansionate il codice QR con il vostro dispositivo mobile

!!! note "Nota"

```
Per scansionare un codice QR direttamente dal computer, è necessario concedere all'applicazione l'accesso alla fotocamera del computer.
```

## Conclusione

Che si tratti di condividere il Wi-Fi di un ristorante con gli amici, di far crescere la propria attività o di fare rete con altri professionisti durante una conferenza, Decoder semplifica la creazione e la scansione dei codici QR. Siete desiderosi di saperne di più su questa applicazione o avete altre idee in merito? [Submit an issue to its repository at GitLab](https://gitlab.gnome.org/World/decoder/-/issues).
