---
title: Annotare le schermate con Ksnip
author: Joseph Brinkman
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 9.4
tags:
  - Desktop
  - Screenshot utility
---

## Prerequisiti e presupposti

- Rocky 9.4 Workstation
- Privilegi `sudo`

## Introduzione

Ksnip è un'utility per gli screenshot che offre molti strumenti per annotare le schermate. Questa guida si concentra sull'installazione di Ksnip e dei suoi strumenti di annotazione.

## Installazione di Ksnip

Ksnip richiede il repository EPEL. Se non avete abilitato l'EPEL, potete farlo con:

```bash
sudo dnf install epel-release
```

Eseguire quindi un aggiornamento del sistema:

```bash
sudo dnf update -y
```

Ora, si puo' installare Ksnip:

```bash
sudo dnf install ksnip -y
```

## Aprire un'immagine

1. Open Ksnip
2. Cliccare `File > Open`
3. Selezionare l'immagine da annotare

![ksnip](images/ksnip.png)

## Annotazione di un'immagine con Ksnip

Ksnip dispone di strumenti pratici e intuitivi per annotare gli screenshot.  Nell'immagine, sul lato sinistro sono presenti le opzioni descritte sotto.

![ksnip_open](images/ksnip_image_opened.png)

| Opzione | Tool               | Descrizione                                                                                                                                                                                                                                                                                                             |
| ------- | ------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1       | `Select`           | Il tool fa una selezione. Fare clic su un elemento per selezionarlo, oppure fare clic e trascinare per effettuare una selezione.                                                                                                                                                        |
| 2       | `Duplicate`        | Il tool duplica una selezione. Fare clic e trascinare per effettuare una selezione. Quindi fare clic e trascinare la selezione per spostarla o trasformarla.                                                                                                            |
| 3a      | `Arrow`            | lo strumento predefinito freccia, che consente di fare clic e trascinare per creare una freccia da una posizione a una nuova.                                                                                                                                                                           |
| 3b      | `Double Arrow`     | la seconda opzione di freccia si seleziona facendo clic sulla freccia verso il basso accanto allo strumento freccia. Come i tool suggeriscono, ha una freccia su entrambi gli estremi.                                                                                                  |
| 3c      | `Line`             | la terza opzione è selezionabile facendo clic sulla freccia verso il basso accanto allo strumento freccia. Sostituisce le frecce con una semplice linea.                                                                                                                                |
| 4       | `Pen`              | produce dei tratti che ricordano una penna. Per utilizzare la penna, fare clic e spostare il cursore sullo schermo. ^1^                                                                                                                                                                 |
| 5a      | `Marker Pen`       | Lo strumento pennarello predefinito crea dei tratti che assomigliano a un evidenziatore. Per usare il pennarello, tenere premuto il tasto e trascinare il cursore sullo schermo. ^1^                                                                                                    |
| 5b      | `Marker Rectangle` | la seconda opzione di marcatura si seleziona facendo clic sulla freccia verso il basso accanto allo strumento marcatore. Facendo clic con il pulsante sinistro del mouse e trascinando il cursore, lo strumento Rettangolo marcatore riempirà il rettangolo creato dalla selezione. ^1^ |
| 5c      | `Marker Elipse`    | la terza opzione di marcatura si seleziona facendo clic sulla freccia verso il basso accanto allo strumento marcatore. Quando si fa clic con il pulsante sinistro del mouse e si trascina il cursore, lo strumento Marker Elipse riempie l'ellisse creata dalla selezione. ^1^          |
| 6a      | `Text`             | Lo strumento di testo predefinito consente di annotare lo screenshot con del testo. ^1^                                                                                                                                                                                                                 |
| 6b      | `Text Pointer`     | la seconda opzione di testo si imposta facendo clic sulla freccia verso il basso accanto allo strumento testo. Il sistema collega un puntatore per attirare l'attenzione sul testo. ^1^                                                                                                 |
| 6c      | `Text Arrow`       | la terza opzione di testo si imposta facendo clic sulla freccia verso il basso accanto allo strumento testo. Il testo è accompagnato da una freccia per attirare l'attenzione sul testo. ^1^                                                                                            |
| 7a      | `Number`           | lo strumento numerico predefinito, aggiunge un numero per attirare l'attenzione e annotare la schermata con i numeri. ^1^                                                                                                                                                                               |
| 7b      | `Number Pointer`   | la seconda opzione è selezionabile facendo clic sulla freccia verso il basso accanto allo strumento numero. Aggiunge un numero con un puntatore per annotare ulteriormente una schermata. ^1^                                                                                           |
| 7c      | `Number Arrow`     | la terza opzione si imposta facendo clic sulla freccia verso il basso accanto allo strumento numero. Aggiunge un numero con una freccia per annotare ulteriormente una schermata. ^1^                                                                                                   |
| 8a      | `Blur`             | lo strumento di sfocatura predefinito, che consente di sfocare porzioni dello screenshot facendo clic con il tasto sinistro del mouse e trascinando.                                                                                                                                                    |
| 8b      | `Pixelate`         | la seconda opzione di sfocatura impostabile facendo clic sulla freccia verso il basso accanto allo strumento sfocatura. Pixelare un punto qualsiasi dello schermo facendo clic con il tasto sinistro del mouse e trascinando.                                                           |
| 9a      | `Rectangle`        | lo strumento rettangolo predefinito, consente di fare clic e trascinare per creare un rettangolo. ^1^                                                                                                                                                                                                   |
| 9b      | `Ellipse`          | la seconda opzione dello strumento rettangolo, si seleziona facendo clic sulla freccia verso il basso accanto allo strumento rettangolo. Consente di fare clic e trascinare per creare un'ellisse sullo schermo. ^1^                                                                    |
| 10      | `Sticker`          | inserisce un adesivo o un'emoji in uno screenshot. Selezionando lo strumento e facendo clic si posiziona l'adesivo.                                                                                                                                                                     |

## Conclusione

Ksnip è un'eccellente utility per annotare le videate. Si può anche fare screenshot, ma questa guida si concentra principalmente sulle capacità di annotazione e sugli strumenti forniti da Ksnip.

Consultare la [Ksnip GitHub Repo](https://github.com/ksnip/ksnip){target=“_blank”} per saperne di più su questa eccellente utility per gli screenshot.

**1.** Tutti gli strumenti che hanno una descrizione seguita da ==questo apice== (^1^), hanno varie opzioni di comando disponibili nel menu superiore dopo aver effettuato la selezione dello strumento. Questi modificano l'opacità, il bordo, il carattere, lo stile del carattere e altri attributi.
