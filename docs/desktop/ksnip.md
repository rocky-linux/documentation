---
title: Annotating Screenshots with Ksnip
author: Joseph Brinkman
tested_with: 9.4
tags:
  - Desktop
  - Screenshot utility
---

# Annotating Screenshots with Ksnip

## Prerequisites and assumptions
- Rocky 9.4 Workstation
- Sudo privileges 

## Introduction

Ksnip is a screenshot utility feature rich with tools for annotating screenshots. This guide will focus on installing Ksnip and its annotation tools. 

## Install Ksnip

Before installing Ksnip, first update `dnf`:

```bash
sudo dnf update -y
```

Now, install Ksnip:

```bash
sudo dnf install ksnip -y
```

## Open an image

1. Open Ksnip
2. Click `File > Open`
3. Select the image you want to annotate


## Annotate an image with Ksnip

Ksnip has handy and intuitive tools to annotate screenshots. This section will cover how to first open an image in Ksnip, then a run-down of the toolbar.

### Select

The `Select` tool is used to make a selection. Click an item to select it or click and drag to make a selection. 

### Duplicate

The `Duplicate` tool is used to duplicate a selection. Click and drag to make a selection. Then click and drag the selection to move or further transform it.

### Arrow

The `Arrow` tool is used to create arrows. Click and drag to create an arrow.

### Double Arrow

The `Double Arrow` tool is used to create double-sided arrows. Click and drag to create a double-sided arrow. 

### Line

The `Line` tool is used to create straight lines. Click and drag to create a line.

### Pen

The `Pen` tool is used to make strokes that resemble a pen. Click and move the cursor across the screenshot to use the Pen. There are customization options to change the style and stroke of the Pen in the top toolbar. 

### Marker Pen

The `Marker Pen` tool is used to make strokes that resemble a highlighter. Hold click and move drag the cursor across the screenshot to use the Marker Pen. There are customization options to change the opacity in the top toolbar.

### Marker Rectangle

The `Marker Rectangle` tool is the Marker Pen tool, but when you click and drag your cursor, the Marker Rectangle tool will fill the rectangular selection. There are customization options to change the opacity in the top toolbar.

### Marker Ellipse

The `Marker Ellipse` tool is the Marker Pen tool, but when you left-click and drag your cursor, the Marker Ellipse tool will fill the ellipse made from the selection. There are customization options to change the opacity in the top toolbar.

### Text

The `Text` tool is used to annotate a screenshot with text. Click anywhere on the image and begin typing to use the Text tool. There are customization options in the top toolbar to change the border, color, font-family, font-size, font-style, and opacity of your text.

### Text Pointer

The `Text Pointer` tool is used to annotate a screenshot with text attached to a pointer. The pointer is supposed to bring attention to the text, similar to the Text Arrow tool.

### Text Arrow

The `Text Arrow` tool is used to annotate a screenshot with text attached to an arrow. The pointer is supposed to bring attention to the text, similar to the Text Pointer tool.

### Number

The `Number` tool is used to annotate a screenshot with a numbered shape. Click anywhere on the image to place a numbered shape. There are customization options in the top toolbar to change the color, width, and opacity. 

### Number Pointer

The `Number Pointer` tool is used to annotate a screenshot with a numbered shape attached to a pointer. Click anywhere on the image to place a numbered shape attached to a pointer. There are customization options in the top toolbar to change the color, width, and opacity. 

### Number Arrow

The `Number Arrow` tool is used to annotate a screenshot with a numbered shape attached to a pointer. Click anywhere on the image to place a numbered shape attached to an arrow. There are customization options in the top toolbar to change the color, width, and opacity. 


### Blur

The `Blur` tool is used to blur a selection. Left-click and drag anywhere on the screenshot to make a selection that will be blurred. 

### Pixelate

The `Pixelate` tool is used to pixelate a selection. Left-click and drag anywhere on the screenshot to make a selection that will be pixelated.

### Rectangle

The `Rectangle` tool is used to make a rectangle from a selection. Left-click and drag anywhere on the screenshot to make a selection that a rectangle will be placed. There are customization options in the top toolbar to change the color, width, and opacity. 


### Ellipse

The `Ellipse` tool is used to make an ellipse from a selection. Left-click and drag anywhere on the screenshot to make a selection where an ellipse will be placed. There are customization options in the top toolbar to change the color, width, and opacity.


### Sticker

The `Sticker` tool is used to place a sticker/emoji on a screenshot. The sticker is placed where the user clicks the image.

## Conclusion

Ksnip is an excellent utility for annotating screenshots. While it can also be used to take screenshots, the main focus of this guide is the annotation capabilities and tools provided by Ksnip. 

Checkout the [Ksnip GitHub Repo](https://github.com/ksnip/ksnip){target="_blank"} to learn more about this excellent screenshot utility. 


