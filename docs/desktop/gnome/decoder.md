---
title: Decoder
author: Christine Belzie
contributors: 
---

## Introduction

Need a QR code for your website, application, or social media profiles? Check out  Decoder! It is an application that lets create, save, and export QR codes.

## Assumptions

This guide assumes you have the following:

- Rocky Linux
- Flatpak
- FlatHub

## Installation Process

1. Go to the [Flathub website](https://flathub.org/), type "Decoder" in the search bar, and click on **Install**. ![Screenshot of the install button highlighted by a red rectangle](images/01_decoder.png)

2. Copy the manual install script and run it in a terminal: ![manual install script](images/decoder_install.png)

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

1. Click on the **Text** button ![Screenshot of a red arrow pointing next to a grey button with the word, Scan written in black font](images/02_decoder-text.png)
2. Add a link to your desired website and add a description ![Screenshot of a red arrow pointing upwards the text box, containing the description "Check out this song" with a Youtube link next to it ](images/03_decoder-text.png)
3. Click on **Create** ![Screenshot of a red arrow pointing next to a grey button that has a QR code symbol and the word "Create" underneath it. ](images/04_decoder-text.png)
4. Click on **Save** ![Screenshot of a red arrow pointing next to a grey button that has the word "Save" written in black. ](images/05_decoder-text.png)
5. Click on **Export** ![Screenshot of a red arrow pointing next to a grey button that has the word "Export" written in black. ](images/06_decoder-text.png)

### Wifi

1. Click on the **Wifi** button ![Screenshot of a red arrow pointing at a grey button that has the word "Wifi" written in black.](images/01_decoder-wifi.png)
2. Add the name of your network, password, and pick its form of protection from the encryption algorithm dropdown menu ![Screenshot the wifi's name, password, and encryption algorithm being displayed. ](images/02_decoder-wifi.png)
3. Click on **Export** ![Screenshot of a red arrow pointing at a grey button that has the word "Export" written in black.](images/03_decoder-wifi.png)
4. Click on **Save** ![Screenshot of a red arrow pointing at a grey button that has the word "Save" written in black.](images/04_decoder-wifi.png)

!!! tip

    If your wifi network is hidden, click on the **Hidden** button.

### How to Scan a QR code

In addition to creating and generating QR codes, you can use Decoder to scan QR codes you saved on you computer. Here is how:

1. Click on **Scan** ![Screenshot of a red circle on a grey button that has the word "Scan" written in black.](images/01_decoder-scan.png)
2. Click on  **From a Screenshot** ![Screenshot of a red rectangle on a blue button that has the word "From a Screenshot" written in white.](images/02_decoder-scan.png)
3. Pick your desired effects and click on **Take a Screenshot** ![Screenshot of a grey square surrounding the options menu with a red arrow pointing towards it and the number one written on top. Next, there is a red square surrounding the "Take a Screenshot" button with a red arrow pointing upwards with the number two written underneath it.](images/03_decoder-scan.png)
4. Click on **Share** ![Screenshot of a red arrow pointing at a blue button that has the word "Share" written in white.](images/04_decoder-scan.png)
5. Scan the QR code with your mobile device

!!! note

    To scan a QR code straight from your computer, ensure that you grant the app access to your computer's camera.

## Conclusion

Whether it is to share a restaurant's Wi-Fi with friends, grow your business, or network with other professionals at a conference, Decoder can ease the process of creating and scanning QR codes. Eager to learn more about or have more ideas for this application? [Submit an issue to its repository at GitLab](https://gitlab.gnome.org/World/decoder/-/issues).
