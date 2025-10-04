---
title: Taking Screenshots and Recording Screencasts in GNOME
author: Wale Soyinka
contributors:
tags:
  - gnome
  - desktop
  - screenshot
  - screencast
  - guide
---

# **Taking Screenshots and Recording Screencasts in GNOME**

The modern GNOME desktop, featured in Rocky Linux, includes a powerful and seamlessly integrated tool for capturing your screen. This is not a separate application you need to install; it is a core part of the desktop shell, providing a fluid and efficient way to take screenshots and record short videos (screencasts).

This guide covers how to use both the interactive user interface and the powerful keyboard shortcuts to capture your screen content.

## **Using the Interactive Screenshot UI**

The easiest way to start is with the interactive overlay, which gives you full control over what and how you capture.

1.  **Launch the Tool:** Press the `Print Screen` (often labeled `PrtSc`) key on your keyboard. The screen will dim, and the screenshot UI will appear.

2.  **Understand the Interface:** The control panel in the middle of the screen has three main sections:
    *   **Capture Mode:** On the left, you can choose to capture a rectangular `Region`, the entire `Screen`, or a specific `Window`.
    *   **Action Toggle:** In the center, you can switch between taking a **Screenshot** (camera icon) or recording a **Screencast** (video camera icon).
    *   **Capture Button:** The large, round button on the right initiates the capture.

### **Taking a Screenshot**

1.  Ensure the action toggle is set to **Screenshot** (the camera icon).
2.  Select your capture mode: `Region`, `Screen`, or `Window`.
3.  Click the round **Capture** button.

By default, the screenshot image is automatically saved to the `Pictures/Screenshots` directory in your home folder.

### **Recording a Screencast**

1.  Set the action toggle to **Screencast** (the video camera icon).
2.  Select the area you wish to record (`Region` or `Screen`).
3.  Click the round **Capture** button to begin recording.

A red dot (â) will appear in the top-right corner of your screen, along with a timer, indicating that recording is active. To stop, simply click this red dot. The video will be automatically saved as a `.webm` file in the `Videos/Screencasts` directory in your home folder.

## **Keyboard Shortcuts for Power Users**

For even faster captures, GNOME provides a set of direct keyboard shortcuts that bypass the interactive UI.

| Shortcut | Action |
| :--- | :--- |
| `Print Screen` | Open the interactive screenshot UI. |
| `Alt + Print Screen` | Take a screenshot of the currently active window immediately. |
| `Shift + Print Screen` | Immediately start selecting a rectangular area for a screenshot. |
| `Ctrl + Alt + Shift + R` | Start and stop a recording of the entire screen. |

### **The "Copy to Clipboard" Modifier**

This is a powerful productivity feature. By adding the `Ctrl` key to any of the screenshot shortcuts, the captured image will be copied directly to your clipboard instead of being saved to a file. This is perfect for quickly pasting a screenshot into another application like a document or chat window.

*   **`Ctrl + Print Screen`**: Open the interactive UI, but the capture will go to the clipboard.
*   **`Ctrl + Alt + Print Screen`**: Copy a screenshot of the active window to the clipboard.
*   **`Ctrl + Shift + Print Screen`**: Copy a screenshot of a selected area to the clipboard.

The built-in GNOME screenshot and screencast tool is a perfect example of elegant and efficient design, providing both a simple, discoverable interface for new users and a fast, shortcut-driven workflow for power users.