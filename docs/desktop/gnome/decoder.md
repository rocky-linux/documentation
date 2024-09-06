---
title: Decoder
author: Christine Belzie
contributors: Steven Spencer, Ganna Zhyrnova 
---

## Introduction

Do you need a QR code for your website, application, or social media profiles? Check out Decoder! The application lets you create, save, and export QR codes.

## Assumptions

This guide assumes you have the following:

- Rocky Linux
- Flatpak
- FlatHub

## Installation Process

1. Go to the [Flathub website](https://flathub.org/), type "Decoder" in the search bar, and click on **Install**. ![Screenshot of the install button highlighted by a red rectangle](images/01_decoder.png)

    ![manual install script and run script](images/decoder_install.png)

2. Copy the manual install script and run it in a terminal:

    ```bash
    flatpak install flathub com.belmoussaoui.Decoder
    ```

3. Finally, copy the run command and run that in your terminal:

    ```bash
    flatpak run com.belmoussaoui.Decoder
    ```

## How to Create a QR Code

Two types of QR codes are available. Choose the option that best suits your needs:

- [Text](#text)
- [Wifi](#wifi)

### Text

![Screenshot of the test, description and URL, and Create buttons](images/02_decoder-text.png)

1. Click on the **Text** button
2. Add a link to your desired website and add a description if you want one
3. Click on **Create**

    ![Screenshot of the Save and Export screen with arrows](images/03_decoder-text.png)

4. Click on **Save**
5. Click on **Export**

### Wifi

![Screenshot showing all of the Wifi options with numbers and arrows](images/01_decoder-wifi.png)

1. Click on the **Wifi** button
2. Add the network name
3. Add the password
4. Select if the network is hidden or not hidden
5. Select the encryption algorithm used
6. Click on **Export**
7. Click on **Save**

### How to Scan a QR code

In addition to creating and generating QR codes, you can use Decoder to scan QR codes you saved on your computer. Do the following:

![Screenshot of a red circle on a grey button that has the word "Scan" written in black.](images/01_decoder-scan.png)

1. Click on **Scan**

    ![Screenshot of the rectangular button with the words "From a Screenshot" written in white.](images/02_decoder-scan.png)

2. Click on  **From a Screenshot**

    ![Screenshot of grey square surrounding options menu, and red square surrounding the "Take a Screenshot button"](images/03_decoder-scan.png)

3. Pick your desired effects and click on **Take a Screenshot**

    ![Screenshot of a red arrow pointing at a blue button that has the word "Share" written in white](images/04_decoder-scan.png)

4. Click on **Share**
5. Scan the QR code with your mobile device

!!! note

    To scan a QR code directly from your computer, you must grant the app access to your computer's camera.

## Conclusion

Whether it is to share a restaurant's Wi-Fi with friends, grow your business, or network with other professionals at a conference, Decoder can ease creating and scanning QR codes. Are you eager to learn more about this application or have more ideas for it? [Submit an issue to its repository at GitLab](https://gitlab.gnome.org/World/decoder/-/issues).
