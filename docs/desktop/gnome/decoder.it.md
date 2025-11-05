---
title: Decoder QR Code Tool
author: Wale Soyinka
contributors: Ganna Zhyrnova
tags:
  - gnome
  - desktop
  - qr code
  - flatpak
---

## Scansiona e Genera QR Code

**Decoder** è un'utilità semplice ed elegante per il desktop GNOME progettata con un unico scopo: lavorare con i codici QR. In un mondo in cui i codici QR vengono utilizzati per qualsiasi cosa, dalla condivisione delle password Wi-Fi all'accesso ai menu dei ristoranti, è essenziale disporre di uno strumento dedicato alla loro gestione.

Decoder offre due funzioni principali in un'interfaccia pulita e intuitiva:

1. **Scansione:** decodifica i codici QR utilizzando la webcam del computer o selezionando un file immagine.
2. **Generazione:** crea i tuoi codici QR da qualsiasi testo tu fornisca.

La sua stretta integrazione con il desktop GNOME lo rende parte integrante del sistema operativo.

## Installazione

Il modo consigliato per installare Decoder su Rocky Linux è come Flatpak dal repository Flathub. Questo metodo garantisce che si disponga della versione più recente dell'applicazione in un ambiente sicuro e protetto.

### 1. Abilitare Flathub

Se non lo si è ancora fatto, assicurasi di avere Flatpak installato e il remote Flathub configurato sul sistema.

```bash
# Install the Flatpak package
sudo dnf install flatpak

# Add the Flathub remote repository
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
```

### 2. Installare Decoder

Una volta abilitato Flathub, è possibile installare Decoder con un solo comando:

```bash
flatpak install flathub com.belmoussaoui.Decoder
```

## Come Utilizzare Decoder

Dopo l'installazione, è possibile avviare Decoder dalla panoramica delle attività di GNOME.

### Scansione di un codice QR

Quando si apre Decoder per la prima volta, è già pronto per eseguire la scansione. Si hanno due opzioni:

- **Scan with Camera:** clicca sull'icona della fotocamera in alto a sinistra. Apparirà una finestra che mostra le immagini riprese dalla tua webcam. Basta puntare la webcam su un codice QR per scansionarlo in tempo reale.
- **Scan from Image:** clicca sull'icona dell'immagine in alto a destra. Si aprirà una finestra di selezione file che ti consentirà di selezionare un'immagine salvata o uno screenshot contenente un codice QR.

Una volta scansionato un codice, Decoder ne analizza in modo intelligente il contenuto. Se il codice contiene l'URL di un sito web, verrà visualizzato il link con un pulsante per aprirlo nel browser web predefinito. Se contiene testo semplice, visualizzerà il testo con un comodo pulsante per copiarlo negli appunti.

### Generare un QR Code

Per creare un codice QR, cliccare sul pulsante “Genera” nella parte superiore della finestra del Decoder.

1. Apparirà una casella di testo. Basta digitare o incollare il testo che si desidera codificare in questa casella.
2. Mentre si digita, sulla destra viene generato istantaneamente un codice QR che rappresenta il testo.
3. È quindi possibile fare clic sul pulsante **“Salve as Image..”** per salvare il codice QR come file `.png`, oppure fare clic sul pulsante **“Copy to Clipboard”** per incollarlo in altre applicazioni.

Decoder è un perfetto esempio della filosofia di progettazione di GNOME: uno strumento semplice, bello e altamente efficace che svolge un compito in modo eccezionale.
