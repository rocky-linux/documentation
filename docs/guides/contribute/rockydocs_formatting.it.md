---
title: Formattazione di Rocky Docs
author: Steven Spencer
contributors: tianci li, Ezequiel Bruni, Franco Colussi
update: 04-mar-2022
---

# Formattazione di Rocky Docs - Introduzione

Nell'ultimo anno, molte cose sono cambiate con la documentazione Rocky. Questa guida ha lo scopo di aiutare i collaboratori a familiarizzare con le nostre opzioni di formattazione più avanzate: inclusi gli ammonimenti le liste numerate, le tabelle e altro.

Per essere chiari, un documento può o non può avere bisogno di contenere uno di questi elementi. Se pensate che il vostro documento ne trarrà beneficio, allora questa guida dovrebbe aiutarvi.

## Ammonimenti

Gli ammonimenti sono speciali "scatole" visive che permettono di richiamare l'attenzione su fatti importanti e di evidenziarli in modo da farli risaltare dal resto del testo. I tipi di ammonimenti sono i seguenti:

| tipo                | Descrizione                                                    |
| ------------------- | -------------------------------------------------------------- |
| attention           | rende una casella di testo arancione chiaro                    |
| caution             | rende una casella di testo arancione chiaro                    |
| danger              | rende una casella di testo rossa                               |
| error               | rende una casella di testo rossa                               |
| hint                | rende una casella di testo verde                               |
| important           | rende una casella di testo verde                               |
| note                | rende una casella di testo blu                                 |
| tip                 | rende una casella di testo verde                               |
| warning             | rende una casella di testo arancione                           |
| custom <sub>1</sub> | rende sempre una casella di testo blu                          |
| custom <sub>2</sub> | utilizza un titolo personalizzato all'interno di un altro tipo |

Quindi non c'è limite ai tipi di ammonimenti che si possono usare, come indicato nel custom <sub>1</sub> di cui sopra. Un titolo personalizzato può essere aggiunto a uno qualsiasi degli altri tipi di ammonimento per ottenere la scatola colorata che si desidera per un specifico ammonimento, come osservato in custom <sub>2</sub> sopra.

Un'ammonimento viene sempre inserito in questo modo:

```
!!! tipo_ammonimento

    testo dell'ammonimento
```

Il corpo del testo dell'ammonimento deve essere rientrato di quattro (4) spazi dal margine iniziale. È facile vedere dove è in questo caso, perché si allineerà sempre sotto la prima lettera del tipo di ammonimento. La linea extra tra il titolo e il corpo non verrà visualizzata, ma è necessaria al nostro motore di traduzione (Crowdin) per funzionare correttamente.

Qui ci sono esempi di ogni tipo di ammonimento e come appariranno nel vostro documento:

!!! attention

    testo

!!! caution

    testo

!!! danger

    testo

!!! error

    testo

!!! hint

    testo

!!! important

    testo

!!! note

    testo

!!! tip

    testo

!!! warning

    testo

!!! custom                        

    Un tipo custom <sub>1</sub>. Qui abbiamo usato "custom" come nostro tipo di ammonimento. Di nuovo, questo risulterà sempre in blu.

!!! warning "titolo personalizzato"

    Un tipo custom <sub>2</sub>. Qui abbiamo modificato il tipo di ammonimento "warning" con un'intestazione personalizzata. Ecco come si presenta:

    ```
    !!! warning "titolo personalizzato"
    ```

## Liste numerate

Le liste numerate sembrano facili da creare e da usare, e una volta che ci si prende la mano, lo sono davvero. Se hai solo una singola lista di elementi senza complessità, allora questo tipo di formato funziona bene:

```
1. Elemento 1

2. Elemento 2

3. Elemento 3
```

1. Elemento 1

2. Elemento 2

3. Elemento 3

Se hai bisogno di aggiungere blocchi di codice, linee multiple o anche paragrafi di testo a una lista numerata, allora il testo dovrebbe essere indentato con quegli stessi quattro (4) spazi che abbiamo usato negli ammonimenti.

Non puoi usare i tuoi occhi per allinearli sotto l'elemento numerato, tuttavia, poichè questo è uno spazio vuoto. Se stai usando un buon editor di markdown, puoi impostare il valore di tabulazione a quattro (4), che renderà la formattazione del tutto un po' più facile.

Ecco un esempio di una lista numerata a più righe con un blocco di codice buttato dentro per buona norma:

1. Quando si ha a che fare con liste numerate che sono a più righe e includono cose come blocchi di codice, usate l'indentazione spaziale per ottenere ciò che volete.

    Per esempio: questo è rientrato di quattro (4) spazi e rappresenta un nuovo paragrafo di testo. E qui, stiamo aggiungendo un blocco di codice. È anche indentato degli stessi quattro (4) spazi del nostro paragrafo:

    ```
    dnf update
    ```

2. Ecco il nostro secondo articolo della lista. Poiché abbiamo usato l'indentazione (sopra), viene visualizzato con la prossima sequenza di numerazione (in altre parole, 2), ma se avessimo inserito l'elemento 1 senza l'indentazione (nel paragrafo successivo e nel codice), allora questo sarebbe apparso di nuovo come elemento 1, che non è ciò che vogliamo.


Ed ecco come appare come testo grezzo:

```markdown
1. Quando si ha a che fare con liste numerate che sono a più righe e includono cose come blocchi di codice, usate l'indentazione spaziale per ottenere ciò che volete.

    Per esempio: questo è rientrato di quattro (4) spazi e rappresenta un nuovo paragrafo di testo. E qui, stiamo aggiungendo un blocco di codice. È anche indentato degli stessi quattro (4) spazi del nostro paragrafo:

    ```


    dnf update
    ```

2. Ecco il nostro secondo articolo della lista. Poiché abbiamo usato l'indentazione (sopra), viene visualizzato con la prossima sequenza di numerazione (in altre parole, 2), ma se avessimo inserito l'elemento 1 senza l'indentazione (nel paragrafo successivo e nel codice), allora questo sarebbe apparso di nuovo come elemento 1, che non è ciò che vogliamo.
```

## Tabelle

Le tabelle ci aiutano a disporre le opzioni di comando, o nel caso precedente, i tipi di ammonimento e le descrizioni. Ecco come viene inserita la tabella sopra:

```
| tipo      | Descrizione                                               |
|-----------|-----------------------------------------------------------|
| attention | rende una casella di testo arancione chiaro                           |
| caution   | rende una casella di testo arancione chiaro                           |
| danger    | rende una casella di testo rossa                                    |
| error     | rende una casella di testo rossa                                    |
| hint      | rende una casella di testo verde                                  |
| important | rende una casella di testo verde                                  |
| note      | rende una casella di testo blu                                   |
| tip       | rende una casella di testo verde                                 |
| warning   | rende una casella di testo arancione                                 |
| custom <sub>1</sub> | rende sempre una casella di testo blu                  |
| custom <sub>2</sub> | utilizza un titolo personalizzato all'interno di un altro tipo       |
```

Si noti che non è necessario avere ogni colonna suddivisa per dimensione (come abbiamo fatto nella prima parte della tabella), ma è certamente più leggibile nel file sorgente markdown. Si può fare confusione quando si mettono in fila gli elementi, semplicemente interrompendo le colonne con il carattere pipe "|" ovunque ci sia un'interruzione naturale, come si può vedere negli ultimi due elementi della tabella.

## Blocco Citazioni

I blocchi di citazione sono in realtà progettati per citare testo da altre fonti da includere nella vostra documentazione, ma non devono essere usati in quel modo. Abbiamo avuto diverse persone che hanno usato i blocchi di citazione al posto delle tabelle, per esempio, per elencare alcune opzioni. Esempi di blocchi di citazione in markdown sarebbero:

```
> **un elemento** - Una descrizione di questo elemento

> **un altro elemento** - Una descrizione di un altro elemento
```
Per evitare che le linee si sovrappongano, è necessaria qui la linea extra di "spaziatura".

Che finisce per assomigliare a questo quando la pagina viene visualizzata:

> **un elemento** - Una descrizione di questo elemento

> **un altro elemento** - Una descrizione di un altro elemento

## Blocchi di Codice in Linea e a Livello di Blocco

Il nostro approccio all'uso dei blocchi di codice è piuttosto semplice. Se `il vostro codice` è abbastanza breve da poterlo (e volerlo) usare in una frase come quella che avete appena visto, usate gli apici singoli <kbd>`</kbd>, così:

```
Una frase con un `comando a vostra scelta` in essa.
```

Ogni comando che non è usato all'interno di un paragrafo di testo (specialmente i lunghi pezzi di codice con più linee) dovrebbe essere in un blocco di codice completo, definito con tripli apici <kbd>`</kbd>:

````markdown
```bash
sudo dnf install the-kitchen-sink 
```
````
La parte `bash` di quella formattazione è un identificatore di codice non essenziale, ma può aiutare a evidenziare la sintassi. Naturalmente, se stai mostrando Python, PHP, Ruby, HTML, CSS, o qualsiasi altro tipo di codice, il "bash" dovrebbe essere cambiato in base al linguaggio che stai usando.
Per inciso, se avete bisogno di mostrare un blocco di codice all'interno di un altro blocco di codice, aggiungete semplicemente un altro triplo apice <kbd>`</kbd> al blocco genitore, così:

`````markdown
````markdown
```bash
sudo dnf install the-kitchen-sink 
```
````
`````

E sì, il blocco di codice che avete appena visto ha usato cinque apici all'inizio e alla fine per renderlo correttamente.

## Tastiera

Un altro modo per assicurarsi di aggiungere quanta più chiarezza possibile ai vostri documenti è quello di rappresentare i tasti della tastiera che devono essere inseriti, nel modo corretto. Questo è fatto con `<kbd>chiave</kbd>`. Per esempio, per rappresentare che è necessario premere il tasto di escape nel vostro documento, si utilizzerebbe `<kbd>ESC</kbd`. Quando avete bisogno di indicare che devono essere premuti più tasti, aggiungete un `+` tra di loro in questo modo: `<kbd>CTRL</kbd> + <kbd>F4</kbd>` se i tasti devono essere premuti simultaneamente, aggiungete "simultaneamente" o "allo stesso tempo" o qualche frase simile alle vostre istruzioni. Ecco un esempio di un'istruzione da tastiera nel vostro editor:

```
Un'installazione di tipo workstation (con interfaccia grafica) avvia questa interfaccia sul terminale 1. Essendo Linux multiutente, è possibile collegare più utenti più volte, su diversi **terminali fisici** (TTY) o **terminali virtuali** (PTS). I terminali virtuali sono disponibili all'interno di un ambiente grafico. Un utente passa da un terminale fisico ad un altro usando <kbd>Alt</kbd> + <kbd>Fx</kbd> dalla riga di comando o utilizzando <kbd>CTRL</kbd> + <kbd>Alt</kbd> + <kbd>Fx</kbd> in modalità grafica.
```
Ed ecco come viene visualizzato:

Un'installazione di tipo workstation (con interfaccia grafica) avvia questa interfaccia sul terminale 1. Linux può essere multiutente, è possibile connettere diversi utenti più volte, in differenti **terminali fisici** (TTY) o **terminali virtuali** (PTS). I terminali virtuali sono disponibili all'interno di un ambiente grafico. Un utente passa da un terminale fisico ad un altro usando <kbd>Alt</kbd> + <kbd>Fx</kbd> dalla riga di comando o utilizzando <kbd>CTRL</kbd> + <kbd>Alt</kbd> + <kbd>Fx</kbd> in modalità grafica.

## Raggruppare Diversi Tipi di Formattazione

Le cose diventano davvero pazzesche, quando è necessario combinare più elementi all'interno di un altro. Per esempio, un ammonimento con una lista numerata:

!!! note "Nota"

    Le cose possono diventare un po' complicate quando si raggruppano le cose. Come quando:

    1. Si aggiunge un elenco numerato di opzioni all'interno di un ammonimento

    2. Oppure si aggiunge un elenco numerato con più blocchi di codice:

        ```
        dnf install some-great-package
        ```

        Che è anche all'interno di un elenco numerato in più paragrafi.

O cosa succede se hai una lista numerata, con un ammonimento aggiuntivo:

1. Questa punto è qualcosa di molto importante

    Qui stiamo aggiungendo un comando da tastiera all'elemento della lista:

    Premere <kbd>ESC</kbd> senza una ragione particolare.

2. Ma questa voce è qualcosa di molto importante e ha più paragrafi

    E c'è un ammonimento nel mezzo:

    !!! warning "Attenzione"
   
        Le cose possono diventare un po' complicate con elementi multipli all'interno di diversi tipi di formattazione!

Finché tieni conto dei magici quattro (4) spazi per far rientrare e separare questi elementi, essi saranno visualizzati in modo logico ed esattamente come vuoi tu. A volte questo è davvero importante.

Si può anche incorporare una tabella o un blocco di citazione (letteralmente qualsiasi tipo di elemento di formattazione) all'interno di un altro. Qui abbiamo un elenco numerato, un ammonimento, una tabella e alcuni elementi di citazione in blocchi tutti insieme:

1. Cercare di stare al passo con tutto quello che succede nel vostro documento può essere un vero impegno quando ci sono più elementi da considerare.

2. Se vi sentite sopraffatti, considerate:

    !!! important "importante: credo che mi faccia male il cervello!"
   
        Quando si combinano più elementi di formattazione, il cervello può impazzire un po'. Considerate la possibilità di ingurgitare un po' di caffeina extra prima di iniziare!
       
        | tipo                |   dose giornaliera di caffeina                    |
        |---------------------|---------------------------------------------------|
        | te                  | alla fine ci arriverai                            |
        | caffè               | per palati esigenti                               |
        | red bull            | ha un sapore terribile - ma vi farà andare avanti!|
        | rugiada di montagna | troppo pompato                                    |
       
        > **zucchero** se la caffeina non è di tuo gradimento
       
        > **soffrire** se tutto il resto fallisce, concentrarsi di più

3. Ci sono altri esempi, ma credo che abbiate capito che tutto può essere annidato all'interno. Basta ricordare i quattro (4) spazi magici.

Ecco come appare questo esempio nel vostro editor:

```

Finché tieni conto dei magici quattro (4) spazi per separare questi elementi, essi saranno visualizzati in modo logico ed esattamente come vuoi tu. A volte questo è davvero importante.

Si può anche incorporare una tabella o un blocco di citazione (letteralmente qualsiasi tipo di elemento di formattazione) all'interno di un altro. Qui abbiamo un elenco numerato, un ammonimento, una tabella e alcuni elementi di citazione in blocco tutti insieme:

1. Cercare di stare al passo con tutto quello che succede nel vostro documento può essere un vero impegno quando ci sono più elementi da considerare.

2. Se vi sentite sopraffatti, considerate: important "importante: credo che mi faccia male il cervello!"

        Quando si combinano più elementi di formattazione, il cervello può impazzire un po'. Considerate la possibilità di ingurgitare un po' di caffeina extra prima di iniziare!

        | tipo                |   dose giornaliera di caffeina                    |
        |---------------------|---------------------------------------------------|
        | te                  | alla fine ci arriverai                            |
        | caffè               | per palati esigenti                               |
        | red bull            | ha un sapore terribile - ma vi farà andare avanti!|
        | rugiada di montagna | troppo pompato                                    |

 > **zucchero** se la caffeina non è di tuo gradimento

 > **soffrire** se tutto il resto fallisce, concentrarsi di più Ci sono altri esempi, ma credo che abbiate capito che tutto può essere annidato all'interno. Basta ricordare i quattro (4) spazi magici.
```

## Ulteriori Letture

* Il documento Rocky Linux [come contribuire](README.md)

* Altro sugli [ammonimenti](https://squidfunk.github.io/mkdocs-material/reference/admonitions/#supported-types)

* [Riferimento rapido Markdown](https://wordpress.com/support/markdown-quick-reference/)

* [Ulteriori riferimenti rapidi](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet) per Markdown

## Conclusione

La formattazione del documento con ammonimenti, tabelle, liste numerate e citazioni in blocco può aggiungere chiarezza al tuo documento. Quando usate gli ammonimenti, fate attenzione a scegliere il tipo corretto. Questo può rendere più facile vedere visivamente l'importanza di un particolare ammonimento.

L'uso eccessivo di uno qualsiasi di questi elementi può semplicemente aggiungere disordine dove non è necessario. Imparare a usare questi elementi di formattazione in modo corretto e sicuro può essere molto utile per far arrivare il vostro messaggio in un documento.

Infine, per facilitare la formattazione, considera di cambiare il valore TAB del tuo editor markdown a quattro (4) spazi.
