---
title: Terminal Colors
author: David Hensley (NezSez)
contributors:
date: 
tested with: RL 8.7, CentOS Stream 9
tags:
  - Colors
  - Terminals
  - truecolor
  - tmux
  - vim
---

# How To Properly Set Terminal Colors

## Introduction:
  There are various scenarios for getting colors to display in terminals, but doing so correctly, so as to not cause problems in other scenarios is a bit tricky and not well documented.
  It has not been uncommon for me to get a default darkblue foreground font color on a black background which can be very difficult to read when using certain setups and terminals.
  Following this guide will allow me to properly display and read colorized text depending on the terminal app I'm actually using without messing up other terminal apps which I might use in other scenarios.
  As an example, I may use `PuTTY` to `ssh` into a server from a MS Windows workstation that I don't normally use, or `Terminal` on a MacOS box I need to use temporarily or for convienence.
  Another use case is when I have to use a terminal (possibly an actual console) on another unix type like Solaris, and the remote `sshd`is not setup to accept environment variables passed to it.
  Several factors infuence the final outcomes such as how your shell gets initialized (interactive vs forked/exec child, and thus which configs get loaded and which ENV's get set),
  which actual terminal (possibly hardwired display/kbd) or terminal emulator software you are using, TTY vs PTY (psuedo-terminal), display/monitor capabilities, keyboard in use (physical and software),
  terminal multiplexers(sp?) (gnu screen and tmux for example) add additional layers of complexity.
  
## Prerequsites:
   Ncurses libs >= 1.9 is needed for truecolor/24Bit
   

## Special Terminology:

## Process:
  1. Determine which particular setup you'd like to verify or adjust first
       Pick one particular set you'd like to get working. Once you figure out the proper settings you can iterate over other pathways and scenarios and easily adjust them.
	   Don't try to adjust user, system files, or all user's configs on a multi-user system all in one go. Verify and test the one scenario you are adjusting and later
	   you can expand it to other pathways, workflows, and perhaps system-wide config changes. Start small, keep it simple, one thing at a time, and build up a stable system as you go.
  2. Determine the current state of your setup:
  * Which Terminal are you using?
      `echo $TERM`, `infocmp -L |grep -i TERM`, `set | grep -i term`, `tset -q`, or `infocmp | head`
	How many colors does your current setup allow for?
	  `tput colors` or `infocmp -L | grep -i max_colors`
	See if COLORTERM is set:
	  `echo $COLORTERM`
	  COLORTERM should be set to `truecolor` or for some terminal emulators `24bit`
	
  * Are you setting up locally, or remotely connecting to another machine where you want the settings to work?
      `sshd` and `ssh` have `AcceptEnv` and `SendEnv` variables that may need to be setup to pass COLORTERM for example:
	  You can pass these on cli, or as Environment Variables.
	  To set ssh client to pass an env var from cli:
	    `ssh -o SendEnv=COLORTERM`
	  
	  PuTTY:
	    System menu (upper left corner of current PuTTY window)->Change Settings->
	    Load saved session:
	      Connection->Data->Terminal-type string and "Environment Variables" (for some truecolor settings)
		
  * Are you using a multiplexor like tmux or gnu screen which also needs to also be configured?
      tmux:
	    tmux.conf
		See if tmux has current truecolor overrides for the TERM in use:
	      `tmux info | grep Tc` or `grep -g || -sa`
	    Tmux in many distributions does not create per users (as in ~/$HOME/<username>/.tmux.conf) files even once run, so there may or may not be a .tmux.conf file in your home dir.
		`~/.tmux.conf` is the default per user conf file, but is not typically created by default unless the user/admin makes it.
	    If you do not have a conf file, but need to create one in order to adjust settings, you can generate one by redirecting a dump of the current running tmux settings, including your changes and the compiled in settings used, to a file:
          `~/.tmux.conf`
		  
	  GNU screen:
	    screen.conf
  3. Determine what your systems are capable of:
       Show a systems' terminfo lists:
	     `ls -l /usr/share/terminfo/<first-letter-of-term-name>/`
		 
  4. Common Utility Software:
    * DIRCOLORS, LS_COLORS,
	  Show database TERM gets color info from:
       `echo $LS_COLORS`
       `dircolors --print-database`

	* Vi/VIM:
	    Check if vim has `guitermcolors` set:
		  `:echo $guitermcolors` (short verion `:echo &tgc`)
		If you have the settings you want within vim you can save them:
		  `:mkvimrc <filename>`(short form `:mkv <filename>`, both default to '.vimrc' in cwd(_vimrc in windows, in gvim)
	      `:mkv!` will override existing file
    
	    There are some caveats regarding maps, abbreviations, autocmds etc; see note at bottom of
	      `:h mkv` (lists `:mk[exrc]` too) `":mkvimrc"`, `":mkexrc"` and `":mksession"`
        See https://vimfandom.com/wiki/Open_vimrc_file
	    `:so $VIMRUNTIME/syntax/colortest.vim` can be used to check colors display
	    `:runtime syntax/colortest.vim`

	    `:version`

        ```

        system vimrc file: "/etc/vimrc"
        user vimrc file: "$HOME/.vimrc"
        2nd user vimrc file: "~/.vim/vimrc"
        user exrc file: "$HOME/.exrc"
        defaults file: "$VIMRUNTIME/defaults.vim"
        fall-back for $VIM: "/etc"
        f-b for $VIMRUNTIME: "/usr/share/vim/vim80"

        ```

      `:echo expand('~')`
      `:echo $HOME`
      `:echo $VIM`
      `:echo $VIMRUNTIME`
      `:echo $MYVIMRC` (only set if it detects a .vimrc during startup, $MYGVIMRC if gvim)
    
    These would be listed if using gvim as well:
    [ system gvimrc file: "$VIM/gvimrc" (in gvim, windows?)]
    [ user gvimrc file: "$HOME/.gvimrc" (_gvimrc in windows)]
	
		Show current number of colors to use:
		`:echo &t_Co`
	Show which colorscheme is currently in use:
		`:colorscheme`
		`:let colors_name`
	See list of available colorschemes:
		`:colorscheme (ctrl-d)`
	Choose among the installed colorschemes:
		`:colorscheme<space> tab`(tab thru the list)

	* Emacs:


## Dependencies:
  Ncurses libs >= 1.9 is needed for full truecolor/24Bit support

## Going Further:
  Colorschemes
  Vi/Vmin/Nvim colorschemes
  Emacs
  Microsoft Windows Terminals
    Windows Terminal
	Powershell
	CMD
  MacOS Terminals
    Terminal App
	iTerm2

## Conclusions:
  This all is a bit of tedious work, but worth it in the end for consistency, reliability, flexibility, and being able to easily read text especially when remoted in.

---
## Glossary:
ANSI
ASCII
PTY
terminfo
termcap
terminal
terminal emulator
terminal multiplexor(sp?)
Truecolor
RGB
TTY


## REFERENCES:
1. [XVilka's Termstandard Colors](https://github.com/termstandard/colors)
2. [Thomas E. Dickey's XTerm](https://invisible-island.net/xterm/xterm.html]
3. [open_vimrc_file](https://vimfandom.com/wiki/Open_vimrc_file)
4. Links to scripts, code and custom programs (for posterity in some cases if the originals might disappear )
