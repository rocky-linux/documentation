---
title: Comando Grep
author: tianci li
contributors:
tags:
  - grep
---

# Comando `grep`

Il comando `grep` filtra il contenuto di file singoli o multipli. Esistono alcune varianti di questo strumento di comando, come `egrep (grep -E)` e `fgrep (grep -f)`. Per le informazioni non trattate, vedere [il manuale di `grep`](https://www.gnu.org/software/grep/manual/ "grep manual").

L'uso del comando `grep` è:

```text
grep [OPTIONS] PATTERN [FILE...]
grep [OPTIONS] -e PATTERN ... [FILE...]
grep [OPTIONS] -f FILE ... [FILE...]
```

Le opzioni sono principalmente suddivise in quattro parti:

- controllo delle corrispondenze
- controllo del risultato
- controllo della linea di contenuto
- controllo di directory o file

controllo delle corrispondenze：

| opzioni                                   | descrizione                                                                         |
| ----------------------------------------- | ----------------------------------------------------------------------------------- |
| -E (--extended-regexp) | Abilita ERE                                                                         |
| -P (--perl-regexp)     | Abilita PCRE                                                                        |
| -G (--basic-regexp)    | Abilita BRE di default                                                              |
| -e (--regexp=PATTERN)  | Abbinamento del modello, possono essere specificate più opzioni -e. |
| -i                                        | Ignora maiuscole e minuscole                                                        |
| -w                                        | Abbinare con precisione l'intera parola                                             |
| -f FILE                                   | Ottenere i modelli da FILE, uno per riga                                            |
| -x                                        | Corrispondenza del modello all'intera riga                                          |
| -v                                        | Seleziona le righe di contenuto non corrispondenti                                  |

controllo del risultato:

| opzioni | descrizione                                                                                                                                                          |
| :------ | :------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| -m NUM  | Produce i primi risultati corrispondenti                                                                                                                             |
| -n      | Stampa i numeri di riga sull'output                                                                                                                                  |
| -H      | Quando si cerca di abbinare il contenuto di più file, il nome del file viene visualizzato all'inizio della riga. Questa è l'impostazione predefinita |
| -h      | Quando trova uno o più ricorrenze all'interno di più file, all'inizio di ogni riga non mostra il nome del file di appartenenza della stringa                         |
| -o      | Elenca solo il pattern ricercato in tutti i file selezionati, senza scrivere l'intera riga di appartenenza                                                           |
| -q      | Non fornisce alcuna informazione, se non lo stato di output (0 se non trova ricorrenze, 1 se ne trova almeno una)                                 |
| -s      | Non visualizza messaggi d'errore                                                                                                                                     |
| -r      | Esegue la ricerca in modo ricorsivo nelle sotto directory                                                                                                            |
| -c      | Visualizza, per ogni file, il numero di righe nelle quali trova un match                                                                                             |

gestione del contenuto delle linee:

| opzioni | descrizione                                                             |
| :------ | :---------------------------------------------------------------------- |
| -B NUM  | Visualizza il NUM di righe che precedono quella con il match ricercato  |
| -A NUM  | Visualizza il NUM di righe successive alla linea con il match ricercato |
| -C NUM  | Visualizza il NUM di righe che precedono e seguono il match ricercato   |

gestione dei file o directory:

| opzioni                                     | descrizione                                                                                                                                                                                                                                                                                                                                                                           |
| :------------------------------------------ | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| --include=FILE_PATTERN | Cerca soltanto i file con nome che corrisponda al FILE_PATTERN. I wildcard supportati per i nomi dei file sono \*, ?, [], [^], [-], {..}, {,}        |
| --exclude=FILE_PATTERN | Salta i file e le cartelle con nomi che corrispondono al FILE_PATTERN. I wildcard supportati per i nomi dei file sono \*, ?, [], [^], [-], {..}, {,} |
| --exclude-dir=PATTERN                       | Esclude il nome delle cartelle specificato in PATTERN. I wildcard supportati per i nomi delle cartelle sono \*, ?, [], [^], [-], {..}, {,}                                |
| --exclude-from=FILE                         | Esclude dalla ricerca le directory e file contenuti in FILE                                                                                                                                                                                                                                                                                                                           |

## Esempi di utilizzo

1. Opzione -f e  opzione -o

   ```bash
   Shell > cat /root/a
   abcdef
   123456
   338922549
   24680
   hello world

   Shell > cat /root/b
   12345
   test
   world
   aaaaa

   # Usa ogni riga del file b come un pattern da ricercare nel file a e mostra le corrispondenze.
   Shell > grep -f /root/b /root/a
   123456
   hello world

   Shell > grep -f /root/b /root/a -o
   12345
   world
   ```

2. Ricerca di pattern multiplo (usare l'opzione -e)

   ```bash
   Shell > echo -e "a\nab\nbc\nbcde" | grep -e 'a' -e 'cd'
   a
   ab
   bcde
   ```

   oppure:

   ```bash
   Shell > echo -e "a\nab\nbc\nbcde" | grep -E "a|cd"
   a
   ab
   bcde
   ```

3. Rimuove le righe vuote e le righe di commento dal file di configurazione

   ```bash
   Shell > grep -v -E "^$|^#" /etc/chrony.conf
   server ntp1.tencent.com iburst
   server ntp2.tencent.com iburst
   server ntp3.tencent.com iburst
   server ntp4.tencent.com iburst
   driftfile /var/lib/chrony/drift
   makestep 1.0 3
   rtcsync
   keyfile /etc/chrony.keys
   leapsectz right/UTC
   logdir /var/log/chrony
   ```

4. Visualizza i primi 5 risultati corrispondenti

   ```bash
   Shell > seq 1 20 | grep -m 5 -E "[0-9]{2}"
   10
   11
   12
   13
   14
   ```

   oppure:

   ```bash
   Shell > seq 1 20 | grep -m 5  "[0-9]\{2\}"
   10
   11
   12
   13
   14
   ```

5. Opzione -B e opzione -A

   ```bash
   Shell > seq 1 20 | grep -B 2 -A 3 -m 5 -E "[0-9]{2}"
   8
   9
   10
   11
   12
   13
   14
   15
   16
   17
   ```

6. Opzione -C

   ```bash
   Shell > seq 1 20 | grep -C 3 -m 5 -E "[0-9]{2}"
   7
   8
   9
   10
   11
   12
   13
   14
   15
   16
   17
   ```

7. Opzione -c

   ```bash
   Shell > cat /etc/ssh/sshd_config | grep  -n -i -E "port"
   13:# If you want to change the port on a SELinux system, you have to tell
   15:# semanage port -a -t ssh_port_t -p tcp #PORTNUMBER
   17:#Port 22
   99:# WARNING: 'UsePAM no' is not supported in RHEL and may cause several
   105:#GatewayPorts no

   Shell > cat /etc/ssh/sshd_config | grep -E -i "port" -c
   5
   ```

8. Opzione -v

   ```bash
   Shell > cat /etc/ssh/sshd_config | grep -i -v -E "port" -c
   140
   ```

9. Filtra i file in una cartella aventi righe corrispondenti alla stringa (Escludi i file nelle cartelle secondarie)

   ```bash
   Shell > grep -i -E "port" /etc/n*.conf -n
   /etc/named.conf:11:     listen-on port 53 { 127.0.0.1; };
   /etc/named.conf:12:     listen-on-v6 port 53 { ::1; };
   /etc/nsswitch.conf:32:# winbind                 Use Samba winbind support
   /etc/nsswitch.conf:33:# wins                    Use Samba wins support
   ```

10. Filtra i file di una directory che hanno righe corrispondenti alla stringa (include o esclude i file o le directory nelle sotto directory)

    Includere la sintassi per file multipli:

    ```bash
    Shell > grep -n -i -r -E  "port" /etc/ --include={0..20}_*
    /etc/grub.d/20_ppc_terminfo:26:export TEXTDOMAIN=grub
    /etc/grub.d/20_ppc_terminfo:27:export TEXTDOMAINDIR=/usr/share/locale
    /etc/grub.d/20_linux_xen:26:export TEXTDOMAIN=grub
    /etc/grub.d/20_linux_xen:27:export TEXTDOMAINDIR="${datarootdir}/locale"
    /etc/grub.d/20_linux_xen:46:# Default to disabling partition uuid support to maintian compatibility with
    /etc/grub.d/10_linux:26:export TEXTDOMAIN=grub
    /etc/grub.d/10_linux:27:export TEXTDOMAINDIR="${datarootdir}/locale"
    /etc/grub.d/10_linux:47:# Default to disabling partition uuid support to maintian compatibility with

    Shell > grep -n -i -r -E  "port" /etc/ --include={{0..20}_*,sshd_config} -c
    /etc/ssh/sshd_config:5
    /etc/grub.d/20_ppc_terminfo:2
    /etc/grub.d/10_reset_boot_success:0
    /etc/grub.d/12_menu_auto_hide:0
    /etc/grub.d/20_linux_xen:3
    /etc/grub.d/10_linux:3
    ```

    Se devi escludere un singola directory, utilizza la seguente sintassi:

    ```bash
    Shell > grep -n -i -r -E  "port" /etc/ --exclude-dir=selin[u]x
    ```

    Se devi escludere più cartelle, utilizza la seguente sintassi:

    ```bash
    Shell > grep -n -i -r -E  "port" /etc/ --exclude-dir={selin[u]x,"profile.d",{a..z}ki,au[a-z]it}
    ```

    Se devi escludere un singolo file, utilizza la seguente sintassi:

    ```bash
    Shell > grep -n -i -r -E  "port" /etc/ --exclude=sshd_config
    ```

    Se devi escludere più file, utilizza la seguente sintassi:

    ```bash
    Shell > grep -n -i -r -E  "port" /etc/ --exclude={ssh[a-z]_config,*.conf,services}
    ```

    Se devi escludere più file e cartelle in un unico comando, utilizza la seguente sintassi:

    ```bash
    Shell > grep -n -i -r -E  "port" /etc/ --exclude-dir={selin[u]x,"profile.d",{a..z}ki,au[a-z]it} --exclude={ssh[a-z]_config,*.conf,services,[0-9][0-9]*}
    ```

11. Conta tutti gli indirizzi IPv4 di sistema

    ```bash
    Shell > ip a | grep -o  -E "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" | grep -v -E "127|255"
    192.168.100.3
    ```
