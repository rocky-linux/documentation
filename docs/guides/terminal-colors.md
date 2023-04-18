---
title: Terminal Colors
author: David Hensley (NezSez)
contributors:
date: 
tested with: RL 8.7, CentOS Stream 9
tags:
  - Colors
  - Terminals
---

# How To Properly Set Terminal Colors

## Introduction:
  There are various scenarios for getting colors to display in terminals, but doing so correctly, so as to not cause problems in other scenarios is a bit tricky and not well documented.
  It has not been uncommon for me to get a default darkblue foreground font color on a black background which can be very difficult to read when using certain setups and terminals.
  Following this guide will allow me to properly display and read colorized text depending on the terminal app I'm actually using without messing up other terminal apps which I might use in other scenarios.
  As an example, I may use `PuTTY` to `ssh` into a server from a MS Windows workstation that I don't normally use, or `Terminal` on a MacOS box I need to use temporarily or for convienence.
  Another use case is when I have to use a terminal (possibly an actual console) on another unix type like Solaris, and the remote `sshd`is not setup to accept environment variables passed to it.
  

## Prerequsites:

## Special Terminology:

## Process:
  1. Stuff here
  2. and here
  3. etc

## Dependencies:
  Verified versions of software, libraries used/required

## Going Further:
  Links for additional customizations

## Conclusions:
  This all is a bit of tedious work, but worth it in the end for consistency, reliability, flexibility, and being able to read text especially when remoted in.

---
## Glossary:

## REFERENCES:
1. Footnotes/Reference links (URLs, manpage websites, etc)
2. Links to scripts, code and custom programs (for posterity in some cases if the originals might disappear )

---

Use truecolor for consistency of colors across apps/terminal emulators:
  (could adjust system /etc/profile stuff to conditionally check and set these where appropriate, and submit PR to upstream CentOS/RHEL/RockyLinux etc)
	
Show current relevant settings:
  do these in shell/terminal and within tmux (tmux/screen/terminator can alter values here):
    `echo $TERM ; echo $COLORTERM ; tput colors ; infocmp -L | grep max_colors`
	
See if tmux has current truecolor overrides for the TERM in use:
	  `tmux info | grep Tc` (or `grep -g || -sa`)
	  There may or may not be a .tmux.conf file in your home dir; is the default per user conf file, but is not typically created by default unless the user/admin makes it.
	    if not you can generate one by redirecting a dump of current compiled in settings used to a file:
          `~/.tmux.conf`

  PuTTY in MS Windows:
	  System menu (upper left corner of current PuTTY window)->Change Settings->
	  Load saved session:
	    Connection->Data->Terminal-type string and "Environment Variables" (for some truecolor settings)

  Vim:
	  In vim:
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
      

Set system wide:
  TERM:
  
  tmux: compiled in defaults can be redirected to a file
    `~/.tmux.conf` is the default per user conf file, but is not typically created by default unless the user/admin makes it.
	  
  Vim:
    `/etc/vimrc`
	
Set per user:
  TERM:
    COLORTERM

  PuTTY:
    Connection->Data->Terminal-type string (also "Environment Variables" for some truecolor settings)
	  "Terminal-type string" set to: putty-256color
	  "Environment Variables" add:
	  "Variable": COLORTERM
		"Value"    : truecolor (or 24bit)

  Vim:
    If you have the settings you want within vim you can save them:
	  `:mkvimrc <filename>`(or `:mkv <filename>`, both default to '.vimrc' in cwd(_vimrc in windows, in gvim)
	  `:mkv!` will override existing file
    
	There are some caveats regarding maps, abbreviations, autocmds etc; see note at bottom of
	`:h mkv` (lists `:mk[exrc]` too) `":mkvimrc"`, `":mkexrc"` and `":mksession"`
    See https://vimfandom.com/wiki/Open_vimrc_file
	:so $VIMRUNTIME/syntax/colortest.vim can be used to check colors display

Testing term colors:
  Show current TERM setting:
    `set | grep -i term`
	`tset -q`
	`echo $TERM`
	`infocmp | head`

  Show extra relavent vars:
    `echo $COLORTERM`

  In vim:	`:echo $guitermcolors` (short verion is `:echo &tgc`)
	
https://github.com/termstandard/colors

sh
  ```
  
  [ "$COLORTERM" = truecolor ] || [ "$COLORTERM" = 24bit ]
  bash / zsh:
  [[ $COLORTERM =~ ^(truecolor|24bit)$ ]]
  
  ```

To set ssh to pass an env var:
  `ssh -o SendEnv=COLORTERM`
  `$ infocmp | grep colors`

  ```

     colors#256, cols#80, it#8, lines#24, pairs#256,

  ```

number of available colors for the current $TERM value is:
  `tput colors`
  I show only up to 256 colors unless I set 'export TERM=xterm-direct' so far.

Show a given color:
             ESC
			   |    RGB Color
			   |    |                               Return ESC to normal value
			   |	  |                                      |
  printf "\x1b[31m16 Color Pallete \x1b[0m\n"
  printf "\x1b[38;5;48m256 Color Pallete\x1b[0m\n"  <--uses older " " style (the `5`)
  printf "\x1b[38;2;10;100;250mTRUECOLOR\x1b[0m\n"  <--uses new rgb format (the `2`)
  
  NOTE: the `\x1b[0m` escapes the use of the previous color (31) so that term doesn't continue to use that color
                Some term defs use : as IFS rather than ;
				
Show a systems' terminfo lists:
  ls -l /usr/share/terminfo/<first-letter-of-term-name>/
  
Putty's terminal type (Connection->Data->Terminal-type string) to 
  putty-256color, xterm-256color, or xterm-direct (for 24bit) or screen-direct, tmux-trucolor, tmux-256color



Click on the System menu at the upper left corner of the PuTTY window.
Select Change Settings > Window > Colours. In the box that says "Select a colour to adjust", choose ANSI Blue and click the Modify Button. Slide the black arrow on the right up until you see a lighter shade of blue that you like. Click OK. Perform the same steps for ANSI Blue Bold so you can have a perceptible difference between the two. When you're finished, click Apply.



#!/usr/bin/env bash
# Based on: (https://github.com/termstandard/colors) and https://unix.stackexchange.com/a/404415/395213

```
  
awk -v term_cols="${width:-$(tput cols || echo 80)}" -v term_lines="${height:-1}" 'BEGIN{
    s="/\\";
    total_cols=term_cols*term_lines;
    for (colnum = 0; colnum<total_cols; colnum++) {
            r = 255-(colnum*255/total_cols);
            g = (colnum*510/total_cols);
            b = (colnum*255/total_cols);
            if (g>255) g = 510-g;
                    printf "\033[48;2;%d;%d;%dm", r,g,b;
                    printf "\033[38;2;%d;%d;%dm", 255-r,255-g,255-b;
                    printf "%s\033[0m", substr(s,colnum%2+1,1);
                    if (colnum%term_cols==term_cols) printf "\n";
   }
   printf "\n";
}'

```

Within vim:
  `:so $VIMRUNTIME/syntax/colortest.vim`

---
  
tmux:
  Make list of the default options used when no conf file is found:
  NOTE: some of these settings will depend on the env when launched, so TERM, COLORTERM used could affect them

  With tmux running:
    `tmux show-environment`
    `tmux show-options -g`

Ex: using `putty-256color`, `ssh`, no `COLORTERM` set :
  `show-environment`:
  
  ```
  
  -DISPLAY
  -KRB5CCNAME
  -SSH_AGENT_PID
  -SSH_ASKPASS
  -SSH_AUTH_SOCK
  SSH_CONNECTION=192.168.1.140 63313 192.168.1.150 22
  -WINDOWID
  -XAUTHORITY
  
  ```

`show-options -g`:


From the tmux wiki FAQ:

How do I use a 256 colour terminal?
  Provided the underlying terminal supports 256 colours, it is usually sufficient to add one of the following to ~/.tmux.conf:
      set -g default-terminal "screen-256color"
	Or:
	  set -g default-terminal "tmux-256color"
  And make sure that TERM outside tmux also shows 256 colours, or use the tmux -2 flag.

How do I use RGB colour?
  tmux must be told that the terminal outside supports RGB colour. This is done by specifying the RGB or Tc terminfo(5) flags. RGB is the official flag, Tc is a tmux extension.
  With tmux 3.2 and later this can be added with the terminal-features option:
      set -as terminal-features ",gnome*:RGB"
	Or for any tmux version the terminal-overrides option:
	  set -as terminal-overrides ",gnome*:Tc"

  Within tmux itself, colours may be specified in hexadecimal, for example bg=#ff0000.

---
  
Document 24bit-truecolor terminal setup
https://github.com/termstandard/colors

NOTE: Make sure your modifications will work as you go without making permanent changes, so you will not mess up the following:
  console : The actual, physical display attached via TTY to the machine
            this might use fbterm (a term emulator for the console) which can load *after* the main bootstrap is completed
  Xwindows: Xresources files and default terms launched (konsole/KDE, gterminal/GNOME,XFCE, xterm etc)
  tmux/screen on localhost, or via remote login
  Remote Terminals: PuTTY/Windows Terminal (WT) and ssh configs (on server and workstation)
  
  'tput colors' will show current TERM number of colors (if all vars are inherited/passed and setup correctly)
  'echo $TERM' (may not be properly set, inherited/exported on given system)
  terminal definitions:
    'infocmp -I <term>' shows lotta startup/capabilities info from the terminfo db (-C for termcap)
      
    xterm-256color
    screen-256color
    putty-256color
    tmux-256color
    xterm-direct

  'echo $COLORTERM'
    should be `"COLORTERM=truecolor"` for VTE, konsole, and mac iTerm2

  some terminal software will also recognize "=24bit" (like S-lang lib based ones)

  'tset -q' will show what <> thinks is the terminal in use
  'reset' (from tset actually) will reload term settings
  `echo $LS_COLORS`
  `dircolors -p` shows the current colors database entries for LS_COLORS environment variable
    Output commands to set the LS_COLORS environment variable

  scripts to use to test/show settings
    NOTE: there is 8, 256, and then there is having more colors but limited to those number at a time
	            in the current "pallette"
	Info:
	  https://tintin.mudhalla.net/info/truecolor/
	  

  Confs/settings for:
    tmux, putty, putty in MS windows to enable 256 and 24bit-truecolor
	vi/vim/nvim (nvchad?)
	  https://vi.stackexchange.com/questions/13458/make-vim-show-all-the-colors
	  `:echo &t_Co`  shows current color #s
		`:let &t_Co=256` will set it to 256 (what's the equiv for truecolor/24bit?)
		`:t_Co=16777216` set it to truecolor, but shouldn't have to do this once you are setup properly
		:so $VIMRUNTIME/syntax/colortest.vim
		:runtime syntax/colortest.vim
		`:h xterm-true-color` <- display vim help on this subject
		'termguicolors' option needs to be set (same as `:se tgc`)
		Sometimes setting 'termguicolors' is not enough and one has to set the t_8f
          and t_8b options explicitly. Default values of these options are
		  `"^[[38;2;%lu;%lu;%lum"` and `"^[[48;2;%lu;%lu;%lum"` respectively, but it is only
		  set when `$TERM` is set to `xterm`. Some terminals accept the same sequences, but
		  with all semicolons replaced by colons (this is actually more compatible, but
		  less widely supported):
		    `let &t_8f = "\<Esc>[38:2:%lu:%lu:%lum"`
			  `let &t_8b = "\<Esc>[48:2:%lu:%lu:%lum"`
		  These options contain printf strings, with printf() (actually, its C
		  equivalent hence l modifier) invoked with the t_ option value and three
		  unsigned long integers that may have any value between 0 and 255 (inclusive)
		  representing red, green and blue colors respectively.

		termguicolors
		  (`:so` is short for `:source` , if you tab on that path it will autoinsert
		    `/usr/share/vim/vim80/syntax/colortest.vim` on RL 8.7)
		  This will open a file showing various fg/bg colors printed out and displayed in the current colorscheme, pallette and color limits
		  
	ncurses/curses settings?

256 color:
  https://en.wikipedia.org/wiki/File:Xterm_256color_chart.svg

Listing 256 and truecolor/24bit capable terms on a given system:
  `find /usr/share/terminfo/ -type f -print | grep -i 256color`
  `find /usr/share/terminfo/ -type f -print | grep -i color-`
  `find /usr/share/terminfo/ -type f -print | grep -i -- -color` <- Yes, the -- is needed to escape the `-color` cause you are searching for that dash
  `find /usr/share/terminfo/ -type f -print | grep -i -direct`
  
In a current term:
  'infocmp' will show you the info of the current $TERM you are set to
  
  ```
  
    colors#0x1000000 = truecolor or 24bit or 16777216
    colors#0x100         = 256colors
  
  ```
	  
  `infocmp -L | grep colors` (or grep max_colors) will show max_colors#0x1000000
  `infocmp -D` will show you the current locations of the terminfo databases used
  `toe` will usually show nothing as it searches /etc/terminfo which is usually empty unless sysadmin
      has set paths there.
  `toe -ha` will show all terms defined and which database locations they are defined in
  `toe -a` shows all defined entries (same as -ha on RL and CentOS Stream)

May need to use/query term/terminfo capabilities like ‘setb24’, ‘setf24’, or 'RGB' (newer) to enable 24-bit direct color mode is used
  See:
    https://www.gnu.org/software/emacs/manual/html_node/efaq/Colors-on-a-TTY.html
	

The linux kernel uses the standard System V terminfo database for setting terminal capabilities.
BSD systems use the termcap database.

Needed software/packages/modules: Dependencies:
  `dnf provides showrgb` -> rgb-1.0.6-41.el9.x86_64 : X color name database from EPEL repo
  `dnf info coreutils` (need version 9.1 or greater)
  `dnf info ncurses-term` (not installed by default in CentOS Stream 9 or RL 8/9) adds some extra TERM defs in infoterm
  `dnf info termbg.x86_64` : Terminal background color detection
	`dnf info rgb.x86_64` : X color name database

	   Tmux:
	     sets term to `screen` which is 8 bit, need to generate a tmux.conf and set -g -sa term defs, possibly Tc settings as well
  
  ---
  
  sshd setup for $COLORTERM :
  test switch can be used to "Check the validity of the configuration file, output the effective configuration to stdout
  and then exit." (source sshd man page).
  as root: `sshd -T` or `sshd -T | sort`
               `sshd -T | sort | grep -i <keyword>`
  (the settings are not in alphabetical order, one can use sshd -T | sort to quickly look for one setting,
  or just grep the setting)
  If using grep, add the -i option because the mixed case used in the config. file is not preserved.
  The option names given by -T are in all lowercase
  
  To pass/accept/propogate COLORTERM (possibly guitermcolors for vim?):
    AcceptEnv in sshd_config(5) and SendEnv in ssh_config(5)
	
	You can specify multiple environment variables on one line with AcceptEnv,
	and you can even give the option multiple times if you want.
	For example:
	  AcceptEnv LANG LC_CTYPE LC_NUMERIC LC_TIME LC_COLLATE LC_MONETARY LC_MESSAGES
	  AcceptEnv LC_PAPER LC_NAME LC_ADDRESS LC_TELEPHONE LC_MEASUREMENT
	  AcceptEnv LC_IDENTIFICATION LC_ALL LANGUAGE
	  AcceptEnv XMODIFIERS
	
	The man page also stated this:
	  Multiple environment variables may be separated by whitespace or spread across multiple AcceptEnv directives.
	
  Client side:
    `ssh foo@host "FOO=foo BAR=bar doz"`
	Regarding security, note than anybody with access to the remote machine will be able to see the environment variables passed to any running process.
	If you want to keep that information secret it is better to pass it through stdin:
	  `cat secret_info | ssh foo@host remote_program`
	
	There is a specific case where if your client terminal doesn't set a color TERM but instead sets COLORTERM.
	On your client machine, add SendEnv COLORTERM into /etc/ssh/ssh_config
	on the server, add AcceptEnv COLORTERM into /etc/ssh/sshd_config.
	Reload sshd (service sshd reload) and reconnect.

---

1) find valid test to show 8bit(256) vs 24bit(truecolor)
2) test term settings with the test
3) test exporting the definitions (subshells)
4) test these inheritances in tmux
5) finalize config; make sure it doesn't mess with 'linux' console, or other terms/software

`for ((x=0; x<=255; x++));do echo -e "${x}:\033[38;5;${x}mcolor\033[000m";done`

Terminal:
    Show current $TERM:
	    `echo $TERM`
	    `tset -q`
	  
	Show current number of colors:
		`tput colors`
	Set TERM:
	  RHEL: TERM defs are in /usr/share/terminfo/
	  Others: /usr/lib/terminfo/ , /usr/share/misc/
		`export TERM=xterm-256color`
	  In X resources files: ~/.Xresources
	    XTerm.termName: (xterm-256color , xterm-direct , xterm-direct2 , xterm-24)
		
Vim:

	Show current number of colors to use:
		`:echo &t_Co`
	Show which colorscheme is currently in use:
		`:colorscheme`
		`:let colors_name`
	See list of available colorschemes:
		`:colorscheme (ctrl-d)`
	Choose among the installed colorschemes:
		`:colorscheme<space> tab`(tab thru the list)
		
		`:runtime syntax/colortest.vim`

https://en.wikipedia.org/wiki/ANSI_escape_code#SGR_(Select_Graphic_Rendition)_parameters

ASCII escape:
`\x1b`
`\033`
in shell: `\e = echo -e = Escape character: ^[`
  Bash: 3 ways to print them:
   `echo -e`, `printf`, and `$'...'`.
   The last one is the easiest:
	   `tmpname="Color:"; tmpname=$tmpname$'\033[34m(Test)\e[0m' ; echo "$tmpname"`
		 `Hello(Test)`
		 `unset tmpname`

Color prompt example: default is: `[\u@\h \W]\$`
  `PS1="\[\e[0m\e[38;5;39m\]\u@\h \[\e[38;5;11m\]\d \[\e[38;5;10m\]\@ \[\e[38;5;208m\]\w\n\[\e[m\] $ "`
  (export in .bashrc if you want permanently)

https://linuxgazette.net/issue65/padala.html :
in terminal/shell: (using ANSI codes?)
`<ESC>[{attr};{fg};{bg}m`
  Ex: `echo "^[[0;31;40mIn Color"` <--red text
      `echo "^[[0;37;40m"`         <--return to normal
(to print <ESC> press CTRL+V and then the ESC key, or CTRL+V CTRL-[)
 ("CTRL+V ESC" is also the way to embed an escape character in a document in vim.)
 
  {attr} is one of following
	0	Reset All Attributes (return to normal mode)
	1	Bright (Usually turns on BOLD)
	2 	Dim
	3	Underline
	5	Blink
	7 	Reverse
	8	Hidden

{fg} is one of the following
	30	Black
	31	Red
	32	Green
	33	Yellow
	34	Blue
	35	Magenta
	36	Cyan
	37	White

{bg} is one of the following
	40	Black
	41	Red
	42	Green
	43	Yellow
	44	Blue
	45	Magenta
	46	Cyan
	47	White

Show database TERM gets color info from:
  `echo $LS_COLORS`
  `dircolors --print-database`
  
Show various color/font options of current TERM:
  `msgcat --color=test` <- does not have that flag on RL 8.7 or CentOS Stream 9

For truecolor:

```

      |-- ESC char: \e, \033, \x1b
      | |-- [ = define a sequence
      | |  |-- Forground/background: 38=FG, 48=BG            --|
      | |  |  |-- Color:2=truecolor (24bit); 5=256 (8bit)    --|-- SGR code
		  |	|  |  |                                              --|
		  | |  |  |             |-- SGR Code                     --|
print "\e[38;2;R;G;Bm" <-- R,G,B each between 0-255 for red, green, and blue color intensities.

```

To print text in orange (#FF7700)
  `"\e[38;2;255;127;0m"` <--why this is not 255;119;0 ?
  `"\033[0m"`            <-- reset to default values

Code                       Effect               Note
\e [                       CSI        Control Sequence Indicator
CSI n m                    ANSICOLOR 	ANSI color code (Select Graphic Rendition(SGR))
CSI 38 ; 5 ; n m           256COLOR   Foreground 8 bit 256 color code
CSI 48 ; 5 ; n m           256COLOR   Background 8 bit 256 color code
CSI 38 ; 2 ; r ; g ; b m   TRUECOLOR  Foreground 24 bit rgb color code
CSI 48 ; 2 ; r ; g ; b m   TRUECOLOR  Background 24 bit rgb color code

in scripts:
  `26,65s/\[3/\\x1b\[3/`
  `26,65s/\"\,/\\x1b\[0m\"\,/`

  For lines 26-65:
  `26,65s/\[3/\\x1b\[3/g`
