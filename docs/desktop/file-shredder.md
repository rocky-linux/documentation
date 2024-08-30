
 ———
 title: File Shredder
 author: Christine Belzie
 contributors:
  ———
  ## Introduction

Need to remove a postcard or a PDF file that contains information like your birthday? Check out File Shredder. It is an application that permanently removes sensitive information online. 
 ## Assumptions

This guide assumes you have the following:

- Rocky Linux 
- Flatpak
- FlatHub

## Installation Process

1. Go to [Flathub's website](https://flathub.org), type "File Shredder" in the search bar, and click on **Install**
![Screenshot of the File Shredder app page on FlatHub, showing the blue install button being highlighted by a red rectangle]


Then, use the following commands  in your terminal to set up the application
```bash
flatpak install flathub com.github.ADBeverage.Raider
```
```bash 
flatpak run com.github.ADBeverage.Raider
```

## How to Use

To use File Shredder,  do the following: 
1. Drag or click on **Add file** to pick the file(s) you want to remove
![Screenshot of the File Shredder homepage, showing the add dropdown menu and drop here button being highlighted by red rectangles]


2. Click on **Shred All** 
![Screenshot of a file named Social Security appearing on top. At the bottom, there is a red button with the phrase Shred All written in white font and surrounded by a red rectangle]

## Conclusion
Whether it’s a Social Security file or a banking statement, File Shredder is the tool that makes it easy to shred files without needing to buy a shredder. Eager to learn more about or have more ideas for this application? [Submit an issue in File Shredder's repository at GitHub](https://github.com/ADBeveridge/raider/issues). 

