---
title: Annotating Screenshots with Ksnip
author: Joseph Brinkman
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 9.4
tags:
  - Desktop
  - Screenshot utility
---

## Prerequisites and assumptions

- Rocky 9.4 Workstation
- `sudo` privileges

## Introduction

Ksnip is a screenshot utility that offers many tools for annotating screenshots. This guide focuses on installing Ksnip and its annotation tools.

## Installing Ksnip

Ksnip requires the EPEL repository. If you do not have the EPEL enabled, you can do that with:

```bash
sudo dnf install epel-release
```

Then perform a system update:

```bash
sudo dnf update -y
```

Now, install Ksnip:

```bash
sudo dnf install ksnip -y
```

## Opening an image

1. Open Ksnip
2. Click `File > Open`
3. Select the image you want to annotate

![ksnip](images/ksnip.png)

## Annotating an image with Ksnip

Ksnip has handy and intuitive tools to annotate screenshots.  In the image, down the left side are the options described below.

![ksnip_open](images/ksnip_image_opened.png)

| Option | Tool | Description                                                                                         |
|--------|------| ----------------------------------------------------------------------------------------------------|
| 1  | `Select` | tool makes a selection. Click an item to select it, or click and drag to make a selection. |
| 2  | `Duplicate` | tool duplicates a selection. Click and drag to make a selection. Then click and drag the selection to move or transform it.|
| 3a | `Arrow`  | the default arrow tool, which allows you to click and drag to create an arrow from a location to a new one |
| 3b | `Double Arrow` | the second arrow option reached by clicking the down arrow next to the arrow tool. As the tools suggest, it has an arrow at both endpoints. |
| 3c | `Line`   | the third option reached by clicking the down arrow next to the arrow tool. It replaces arrows with a simple line. |
| 4  | `Pen`    | makes strokes that resemble a pen. To use the pen, click and move the cursor across the screenshot. ^1^ |
| 5a | `Marker Pen` | The default marker tool makes strokes that resemble a highlighter. To use the marker pen, hold the click and drag the cursor across the screenshot. ^1^ |
| 5b | `Marker Rectangle` | the second marker option reached by clicking the down arrow next to the marker tool. When you left-click and drag your cursor, the Marker Rectangle tool will fill the rectangle made from the selection. ^1^ |
| 5c | `Marker Elipse`  | the third marker option reached by clicking the down arrow next to the marker tool. When you left-click and drag your cursor, the Marker Elipse tool will fill the ellipse made from the selection. ^1^ |
| 6a | `Text` | The default text tool allows you to annotate the screenshot with text. ^1^ |
| 6b | `Text Pointer` | the second text option reached by clicking the down arrow next to the text tool. It attaches a pointer to draw attention to the text. ^1^ |
| 6c | `Text Arrow` | the third text option reached by clicking the down arrow next to the text tool. It attaches an arrow to draw attention to the text. ^1^ |
| 7a | `Number`  | the default number tool, adds a number to draw attention to and annotate the screenshot with numbers. ^1^ |
| 7b | `Number Pointer` | the second option reached by clicking the down arrow next to the number tool. Adds a number with a pointer to further annotate a screenshot. ^1^ |
| 7c | `Number Arrow` | the third option reached by clicking the down arrow next to the number tool. Adds a number with an arrow to further annotate a screenshot. ^1^ |
| 8a | `Blur`  | the default blur tool, which allows you to blur portions of the screenshot by left-clicking and dragging. |
| 8b | `Pixelate` | the second blur tool option reached by clicking the down arrow next to the blur tool. Pixelate anywhere on the screen by left-clicking and dragging. |
| 9a | `Rectangle` | the default rectangle tool, allows you to click and drag to create a rectangle. ^1^ |
| 9b | `Ellipse` | the second rectangle tool option, reached by clicking the down arrow next to the rectangle tool. Allows you to click and drag to create an ellipse on the screen. ^1^ |
| 10 | `Sticker` | places a sticker or emoji on a screenshot. Selecting the tool and clicking will place the sticker. |

## Conclusion

Ksnip is an excellent utility for annotating screenshots. It can also take screenshots, but this guide focuses mainly on the annotation capabilities and tools provided by Ksnip.

Check out the [Ksnip GitHub Repo](https://github.com/ksnip/ksnip){target="_blank"} to learn more about this excellent screenshot utility.

**1.** Each of the tools that have descriptions followed by ==this superscript== (^1^), have various command options available in the top menu after making the tool selection. These change the opacity, border, font, font style, and other attributes.
