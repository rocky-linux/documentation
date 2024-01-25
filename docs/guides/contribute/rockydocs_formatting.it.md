---
title: Formattazione del documento
author: Steven Spencer
contributors: tianci li, Ezequiel Bruni, Krista Burdine, Ganna Zhyrnova
tags:
  - contribute
  - formatting
---

# Introduzione

Questa guida mette in evidenza le opzioni di formattazione più avanzate, tra cui ammonizioni, elenchi numerati, tabelle e altro ancora.

Un documento può contenere o meno uno di questi elementi. Se ritenete che il vostro documento possa beneficiare di una formattazione speciale, questa guida vi aiuterà.

!!! note "Una nota sulle Intestazioni"

    Le intestazioni non sono caratteri speciali di formattazione, ma sintassi standard di markdown. Includono una **singola** voce di primo livello:

    ```
    # Questo è il Primo Livello
    ```


    e un numero qualsiasi di valori di sottovoci, dai livelli 2 a 6:

    ```
    ## Un livello 2 heading
    ### Un livello 3 heading
    #### Un livello 4 heading
    ##### Un livello 5 heading
    ###### Un livello 6 heading
    ```


    La chiave è che si possono usare tutti i titoli dal 2 al 6, ma solo **UNO** di livello 1. Mentre il documento viene visualizzato correttamente con più di un'intestazione di livello 1, l'indice generato automaticamente per il documento, che appare sul lato destro, **NON** viene visualizzato correttamente (o talvolta per niente) con più di un'intestazione. Tienilo a mente quando scrivi i tuoi documenti.

!!! warning "Una nota sugli elementi HTML supportati"

    Ci sono elementi HTML che sono tecnicamente supportati in markdown. Alcuni di questi sono descritti in questo documento, dove non esiste una sintassi markdown che li sostituisca. Questi tag HTML supportati dovrebbero essere usati raramente, perché i linters di markdown potrebbero segnalarli in un documento. Per esempio:

    * Inline HTML [nome elemento]

    Se dovete usare un elemento HTML supportato, cercate di trovare un altro modo per scrivere il vostro documento che non utilizzi questi elementi. Se dovete usarli, è comunque consentito.

## Ammonimenti

Gli ammonimenti sono speciali "riquadri" visivi che consentono di richiamare l'attenzione su fatti importanti e di metterli in evidenza. Di seguito sono elencati i tipi di ammonimenti:

| tipo                | Descrizione                                                                |
| ------------------- | -------------------------------------------------------------------------- |
| note                | visualizza il testo in un riquadro blu                                     |
| abstract            | visualizza il testo in un riquadro azzurro                                 |
| info                | visualizza il testo in un riquadro blu-verde                               |
| tip                 | visualizza il testo in un riquadro blu-verde (icona leggermente più verde) |
| success             | visualizza il testo in un riquadro verde                                   |
| question "Domanda"  | visualizza il testo in un riquadro verde chiaro                            |
| warning             | visualizza il testo in un riquadro arancione                               |
| failure             | visualizza il testo in un riquadro rosso chiaro                            |
| danger "Pericolo"   | visualizza il testo in un riquadro rosso                                   |
| bug                 | visualizza il testo in un riquadro rosso                                   |
| example             | visualizza il testo in un riquadro viola                                   |
| quote               | visualizza il testo in una casella grigia                                  |
| custom <sub>1</sub> | visualizza sempre il testo in un riquadro blu                              |
| custom <sub>2</sub> | visualizza il testo nel colore del riquadro della tipologia prescelta      |

Gli ammonimenti sono illimitati, come si può notare in custom <sub>1</sub> sopra. È possibile aggiungere un titolo personalizzato a qualsiasi tipo di ammonimento per ottenere il colore del riquadro desiderato per un ammonimento specifico, come indicato nel precedente custom <sub>2</sub> personalizzato.

Un'ammonimento viene sempre inserito in questo modo:

```text
!!! admonition_type "titolo personalizzato, se presente".

    testo dell'ammonimento
```

Il testo del corpo dell'ammonimento deve avere un rientro di quattro (4) spazi dal margine iniziale. È facile capire dove si trova, perché sarà sempre allineato sotto la prima lettera del tipo di ammonimento. La riga in più tra il titolo e il corpo non verrà visualizzata, ma il nostro motore di traduzione (Crowdin) ne ha bisogno per funzionare correttamente.

Qui ci sono esempi di ogni tipo di ammonimento e come appariranno nel vostro documento:

!!! note

    testo

!!! abstract

    testo

!!! info

    testo

!!! tip

    testo

!!! success

    testo

!!! question

    testo

!!! warning

    testo

!!! failure

    testo

!!! danger

    testo

!!! custom "Titolo personalizzato"

    Un tipo custom  <sub>1</sub>. Abbiamo usato " custom" come tipo di ammonimento. Di nuovo, questo risulterà sempre in blu.

!!! warning "titolo personalizzato"

    Un tipo custom <sub>2</sub>. Abbiamo modificato il tipo di ammonimento "warning" con un'intestazione personalizzata. Ecco come appare:

    ```
    !!! warning "titolo personalizzato"
    ```

### Ammonimenti espandibili

Se un ammonimento ha un contenuto molto lungo, prendete in considerazione un ammonimento espandibile. Ha le stesse caratteristiche di un ammonimento regolare, ma inizia con tre punti interrogativi, anziché con tre punti esclamativi. Si applicano tutte le altre regole degli ammonimenti. Un ammonimento espandibile assomiglia a questo:

??? warning "Avvertenze sul contenuto"

    Si tratta di un avviso, con poco contenuto. Per questo si dovrebbe usare un ammonimento normale, ma questo è solo un esempio!

Che si presenta così nell'editor:

```text
??? warning "Avvertenze sul contenuto"

    Si tratta di un avviso, con poco contenuto. Per questo si dovrebbe usare un ammonimento normale, ma questo è solo un esempio!
```

## Contenuto a schede all'interno di un documento

La formattazione dei contenuti a schede è simile a quella degli ammonimenti. Invece di tre punti esclamativi o tre punti interrogativi, inizia con tre segni uguali. Tutta la formattazione dell'ammonimento (4 spazi, ecc.) si applica a questo contenuto. Ad esempio, la documentazione potrebbe richiedere una procedura diversa per una diversa versione di Rocky Linux. Quando si usa il contenuto a schede per le versioni, la release più recente di Rocky Linux deve essere la prima. Al momento della stesura del presente documento, il codice è 9.0:

=== "9.0"

    La procedura per farlo in 9.0

=== "8.6"

    La procedura per farlo in 8.6

Che si presenterebbe così nell'editor:

```text
=== "9.0"

    La procedura per farlo in 9.0

=== "8.6"

    La procedura per eseguire questa operazione in 8.6
```

Ricordate che tutto ciò che rientra nella sezione deve continuare a utilizzare il rientro di 4 spazi fino al completamento della sezione. Questa è una funzione molto utile!

## Liste numerate

Le liste numerate sembrano facili da creare e da usare e, una volta che ci si è abituati, lo sono davvero. Se si dispone di un unico elenco di elementi senza alcuna complessità, questo tipo di formato va bene:

```text
1. Elemento 1

2. Elemento 2

3. Elemento 3
```

1. Elemento 1

2. Elemento 2

3. Elemento 3

Se è necessario aggiungere blocchi di codice, righe multiple o addirittura paragrafi di testo a un elenco numerato, il testo deve avere la stessa indentazione di quattro (4) spazi utilizzata per gli ammonimenti.

Tuttavia, non è possibile allinearli con gli occhi sotto l'elemento numerato perché questo ha uno spazio in meno. Se si utilizza un buon editor di markdown, è possibile impostare il valore di tabulazione a quattro (4), il che renderà la formattazione un po' più semplice.

Ecco un esempio di elenco numerato a più righe, con un blocco di codice aggiunto per buona norma:

1. Quando si tratta di elenchi numerati a più righe che includono blocchi di codice o altri elementi, si può usare l'indentazione spaziale per ottenere ciò che si desidera.

    Ad esempio: questo ha un rientro di quattro (4) spazi e rappresenta un nuovo paragrafo di testo. Inoltre, aggiungiamo un blocco di codice all'interno. È anche rientrato degli stessi quattro (4) spazi del nostro paragrafo:

    ```bash
    dnf update
    ```

2. Ecco il nostro secondo articolo in elenco. Poiché si è utilizzato il rientro di quattro (4) spazi (sopra), viene visualizzato con la sequenza di numerazione successiva (2), ma se si fosse inserito l'elemento 1 senza il rientro (nel paragrafo e nel codice successivi), questo verrebbe visualizzato di nuovo come elemento 1, il che non è ciò che si desidera.

Ecco come appare il testo raw:

```markdown
1. Quando si tratta di elenchi numerati a più righe che includono blocchi di codice o altri elementi, si può usare l'indentazione spaziale per ottenere ciò che si desidera.

    Ad esempio: questo ha un rientro di quattro (4) spazi e rappresenta un nuovo paragrafo di testo. Inoltre, aggiungiamo un blocco di codice all'interno. È anche rientrato degli stessi quattro (4) spazi del nostro paragrafo:
    ```

2. Ecco il nostro secondo articolo in elenco. Poiché si è utilizzato il rientro di quattro (4) spazi (sopra), viene visualizzato con la sequenza di numerazione successiva (2), ma se si fosse inserito l'elemento 1 senza il rientro (nel paragrafo e nel codice successivi), questo verrebbe visualizzato di nuovo come elemento 1, il che non è ciò che si desidera.
```

## Tabelle

Nel caso precedente, le tabelle aiutano a disporre le opzioni di comando o i tipi di ammonimento e le relative descrizioni. Ecco com'è stata inserita la tabella nella sezione delle Ammonizioni:

```text
| tipo      | Descrizione                                               |
|-----------|-----------------------------------------------------------|
| note      | mostra il testo in una casella blu                                   |
| abstract  | mostra il testo in una casella azzurra                             |
| info      | mostra il testo in una casella verde-azzurra                             |
| tip       | mostra il testo in una casella verde-azzurra (icona lievemente più verde)    |
| success   | mostra il testo in una casella verde                                 |
| question  | mostra il testo in una casella verde chiara                            |
| warning   | mostra il testo in una casella arancione                                 |
| failure   | mostra il testo in una casella rossa chiara                              |
| danger    | mostra il testo in una casella rossa                                   |
| bug       | mostra il testo in una casella rossa                                    |
| example   | mostra il testo in una casella viola                                 |
| quote     | mostra il testo in una casella grigia                                   |
| custom <sub>1</sub> | mostra sempre il testo in una casella blu                  |
| custom <sub>2</sub> | mostra il testo in una casella del colore scelto |

```

Si noti che non è necessario che ogni colonna sia suddivisa per dimensione (come abbiamo fatto nella prima parte della tabella), ma è certamente più leggibile nel file sorgente markdown. La confusione può essere maggiore quando si mettono in fila gli elementi, semplicemente interrompendo le colonne con il carattere pipe "|" ovunque si trovi l'interruzione naturale, come si può vedere nell'ultimo elemento della tabella.

## Virgolettato

Le virgolette sono in realtà pensate per citare il testo di altre fonti da includere nella documentazione, ma non è obbligatorio usarle in questo modo. Alcuni collaboratori usano le virgolette invece delle tabelle, ad esempio per elencare alcune opzioni. Esempi di virgolette in markdown sono:

```text
> **un elemento** - Una descrizione di quell'elemento

> **altro elemento** - Un'altra descrizione di quell'elemento
```

La linea di "spaziatura" aggiuntiva è necessaria per evitare che le linee si sovrappongano.

L'aspetto finale è questo quando la pagina viene visualizzata:

> **un elemento** - Una descrizione dell'elemento **un altro elemento** - Altra descrizione di un elemento

## Blocchi di codice in linea e a livello di blocco

Our approach to the use of code blocks is pretty simple. Se `il vostro codice` è abbastanza breve da poterlo (e volerlo) usare in una riga come quella che avete appena visto, usate dei singoli backtick ++"`"++:

```bash
Una frase che contiene un "comando scelto da voi".
```

Qualsiasi comando che non sia usato all'interno di un paragrafo di testo (specialmente i pezzi di codice lunghi con più righe) dovrebbe essere un blocco di codice completo, definito con tripli backtick ++"```"++:

````markdown
```bash
sudo dnf install the-kitchen-sink
```
````
La parte `bash` di questa formattazione è un identificatore di codice raccomandato da markdown, ma può essere utile per l'evidenziazione della sintassi. Se mostrate testo, Python, PHP, Ruby, HTML, CSS o qualsiasi altro tipo di codice, il "bash" verrà modificato con il linguaggio utilizzato.
Per inciso, se è necessario mostrare un blocco di codice all'interno di un blocco di codice, basta aggiungere un altro backtick ++"`"++ al blocco genitore:

`````markdown
````markdown
```bash
sudo dnf install the-kitchen-sink
```
````
`````

E sì, il blocco di codice che avete appena visto ha usato cinque backtick all'inizio e alla fine per renderlo correttamente.

### Soppressione del prompt visualizzato e dell'avanzamento automatico di riga

In alcuni casi, durante la stesura della documentazione, si desidera mostrare un prompt nel comando, ma non si vuole che l'utente copi tale prompt quando utilizza l'opzione di copia. Un'applicazione di questo tipo potrebbe essere la scrittura di laboratori in cui si vuole mostrare la posizione con il prompt, come in questo esempio:

![copy_option](copy_option.png)

Se la formattazione è normale, l'opzione di copia copierà il prompt e il comando, mentre è preferibile copiare solo il comando. Per ovviare a questo problema, si può usare la seguente sintassi per indicare all'opzione copy ciò che si vuole copiare:

````text
``` { .sh data-copy="cd /usr/local" }
[root@localhost root] cd /usr/local
```
````
Quando si utilizza questo metodo, anche l'avanzamento automatico delle righe viene soppresso.
## Tastiera
Un altro modo per aggiungere più chiarezza possibile ai documenti è quello di rappresentare la digitazione dei tasti su una tastiera nel modo corretto. Per farlo, utilizzate `<kbd>key</kbd>`. Per esempio, per rappresentare la necessità di premere il tasto escape nel documento, si userebbe `++escape++`. Quando è necessario indicare la pressione di più tasti, aggiungete un `+` tra di essi, in questo modo: `++ctrl+f4++`. Per i tasti non definiti (ad esempio, stiamo indicando un tasto funzione misterioso, `Fx`) mettete la definizione tra virgolette (`++ctrl+"Fx"++`). Se si richiede la pressione simultanea dei tasti, aggiungere "simultaneamente" o "allo stesso tempo" o una frase simile alle istruzioni. Ecco un esempio di istruzione da tastiera nell'editor:

```text
Un'installazione di tipo workstation (con interfaccia grafica) avvia questa interfaccia sul terminale 1. Essendo Linux multiutente, è possibile connettere più utenti più volte, su diversi **terminali fisici** (TTY) o **terminali virtuali** (PTS). I terminali virtuali sono disponibili in un ambiente grafico. Un utente passa da un terminale fisico a un altro usando ++alt+"Fx"++ o dalla riga di comando utilizzando ++ctrl+alt+"Fx"++.
```

Ecco come viene visualizzato:

Un'installazione di tipo workstation (con interfaccia grafica) avvia questa interfaccia sul terminale 1. Essendo Linux multiutente, è possibile connettere più utenti più volte, su diversi **terminali fisici** (TTY) o **terminali virtuali** (PTS). I terminali virtuali sono disponibili in un ambiente grafico. Un utente passa da un terminale fisico a un altro usando ++alt+"Fx"++ o dalla riga di comando utilizzando ++ctrl+alt+"Fx"++.

Un elenco dei comandi da tastiera accettati si trova [in questo documento](https://facelessuser.github.io/pymdown-extensions/extensions/keys/#key-map-index).

!!! note "Nota"

    Queste scorciatoie da tastiera sono sempre inserite in minuscolo, tranne quando è utilizzato un comando da tastiera personalizzato, tra virgolette.

## Superscript, subscript e simboli speciali

Le notazioni in apice e in pedice non sono un normale markdown, ma sono supportate nella documentazione di Rocky Linux attraverso i tag HTML usati per lo stesso scopo. Il superscript pone il testo inserito tra i tag leggermente al di sopra del testo normale, mentre il subscript lo pone leggermente al di sotto. Superscript è di gran lunga il più usato tra questi due nella scrittura. Alcuni caratteri speciali appaiono già in apice senza l'aggiunta dei tag, ma è possibile combinare i tag per cambiare l'orientamento di tali caratteri, come si vede con il simbolo del copyright qui sotto. È possibile utilizzare il superscript per:

* rappresentano numeri ordinali, come 1<sup>st</sup>, 2<sup>nd</sup>, 3<sup>rd</sup>
* simboli di copyright e marchi, come <sup>&copy;</sup>, <sup>TM</sup>, o &trade;, &reg;
* come notazione per riferimenti, come questo<sup>1</sup>, questo<sup>2</sup> e questo<sup>3</sup>

Alcuni caratteri speciali, come &copy;, non sono normalmente apicali, mentre altri, come &trade;, lo sono.

Ecco come appare tutto questo nel codice markdown:

```text
* rappresentano i numeri ordinali, come 1<sup>°</sup>, 2<sup>°</sup>, 3<sup>°</sup>
* simboli di copyright e marchi, come <sup>&copy;</sup>, <sup>TM</sup> o &trade;, &reg;
* come notazione per i riferimenti, come questo <sup>1</sup>, questo <sup>2</sup> e questo <sup>3</sup>

Alcuni caratteri speciali, come &copy; non sono normalmente apicali, mentre altri come &trade;, lo sono.
```

Come si può vedere, per forzare l'apice possiamo usare i tag HTML supportati `<sup></sup>`.

Si inserisce il pedice con i tag `<sub></sub>` e, come notato in precedenza, non è <sub>utilizzato molto</sub> nella scrittura.

### Superscript per i riferimenti

Alcuni di voi potrebbero avere la necessità di fare riferimento a fonti esterne quando scrivono la documentazione. Se avete una sola fonte, potete includerla nella conclusione come un unico link, ma se ne avete più di una<sup>1</sup>, potete usare l'apice per annotarle nel testo<sup>2</sup> e poi elencarle alla fine del documento. Si noti che il posizionamento dei riferimenti deve avvenire dopo la sezione "Conclusioni".

Dopo la conclusione, è possibile inserire le notazioni in un elenco numerato che corrisponde all'apice, oppure come link. Entrambi gli esempi sono illustrati qui:

1. "Come si usano i multipli nel testo" di Wordy W. McWords [https://site1.com](https://site1.com)
2. "Usare l'apice nel testo" di Sam B. Supersecret [https://site2.com](https://site2.com)

o

[1](https://site1.com) "Come si usano i multipli nel testo" di Wordy W. McWords  
[2](https://site2.com) "Usare l'apice nel testo" by Sam B. Supersecret

Ecco come si presenta il tutto nel vostro editor:

```text
1. "Come si usano i multipli nel testo" di Wordy W. McWords [https://site1.com](https://site1.com)
2. "Usare l'apice nel testo" di Sam B. Supersecret [https://site2.com](https://site2.com)

o

[1](https://site1.com) "Come si usano i multipli nel testo" di Wordy W. McWords  
[2](https://site2.com) "Usare l'apice nel testo" di by Sam B. Supersecret  

```

## Raggruppare diversi tipi di formattazione

La documentazione Rocky offre alcune eleganti opzioni di formattazione quando si combinano più elementi all'interno di un altro elemento. Per esempio, un ammonimento con un elenco numerato:

!!! note "Nota"

    Le cose possono diventare un po' strane quando si raggruppano gli oggetti. Come quando:

    1. Si aggiunge un elenco numerato di opzioni all'interno di un ammonimento

    2. Oppure si aggiunge un elenco numerato con più blocchi di codice:

        ```
        dnf install some-great-package
        ```

        Che è anche all'interno di un elenco numerato di più paragrafi.

Oppure si può avere un elenco numerato, con un'ulteriore ammonimento:

1. Questo elemento è molto importante

    Qui si aggiunge un comando da tastiera all'elemento dell'elenco:

    Premere ++escape++ senza un motivo particolare.

2. Ma questo articolo è qualcosa di molto importante *e* ha più paragrafi ad esso dedicati

    E ha un ammonimento nel mezzo:

    !!! warning "Attenzione"
   
        Le cose possono diventare un po' strane con più elementi all'interno di diversi tipi di formattazione!

Se si tiene conto dei magici quattro (4) spazi per rientrare e separare questi elementi, essi verranno visualizzati in modo logico ed esattamente come lo si desidera. A volte questo è davvero importante.

È anche possibile incorporare una tabella o una citazione a blocchi (letteralmente qualsiasi tipo di elemento di formattazione) all'interno di un'altra. Qui ci sono un elenco numerato, un ammonimento, una tabella e alcuni elementi di blocco di citazione, tutti raggruppati insieme:

1. Cercare di tenere il passo con tutto ciò che accade nel documento può essere un vero compito quando si lavora con più elementi.

2. Se vi sentite sopraffatti, prendete in considerazione:

    !!! warning "importante: credo che mi faccia male la testa!"
   
        Quando si combinano più elementi di formattazione, è possibile che il cervello impazzisca. Prendete in considerazione l'idea di assumere un po' di caffeina in più prima di cominciare!
       
        | tipo            |   dose giornaliera di caffeina       |
        |-----------------|----------------------------------|
        | tea             | alla fine ci arriverete |
        | coffee          | per palati esigenti        |
        | red bull        | Ha un sapore terribile, ma vi farà andare avanti! |
        | mountain dew    | eccessivamente ipnotico                       |
       
        > **zucchero** se la caffeina non è di vostro gradimento
       
        > **soffrire** se tutto il resto fallisce, concentrarsi di più

3. Esistono molti esempi, ma quello sopra illustra come sia possibile annidare tutto all'interno. Ricordate i quattro (4) spazi magici.

Ecco come appare questo esempio nell'editor:

```text

Se si rispettano i magici quattro (4) spazi per separare questi elementi, essi verranno visualizzati in modo logico ed esattamente come si desiderano. A volte questo è davvero importante.

È anche possibile incorporare una tabella o una citazione a blocchi (letteralmente qualsiasi tipo di elemento di formattazione) all'interno di un'altra. Qui ci sono un elenco numerato, un'ammonimento, una tabella e alcuni elementi di citazione a blocchi, tutti raggruppati insieme:

1. Cercare di tenere il passo con tutto ciò che accade nel documento può essere un vero compito quando si lavora con più elementi.

2. Se vi sentite sopraffatti, prendete in considerazione:

    !!! warning "importante: credo che mi faccia male la testa!"

        Quando si combinano più elementi di formattazione, è possibile che il cervello impazzisca. Prendete in considerazione l'idea di assumere un po' di caffeina in più prima di cominciare!

        | tipo            |   dose giornaliera di caffeina       |
        |-----------------|----------------------------------|
        | tea             | alla fine ci arriverete |
        | coffee          | per palati esigenti        |
        | red bull        | Ha un sapore orribile, ma vi farà andare avanti! |
        | mountain dew    | eccessivamente ipnotico                       |

        > **zucchero** se la caffeina non è di vostro gradimento

        > **soffrire** se tutto il resto fallisce, concentrarsi di più

3. Esistono molti esempi, ma quello sopra illustra come sia possibile annidare tutto all'interno. Ricordate i quattro (4) spazi magici.
```

## Un ultimo punto - i commenti

Di tanto in tanto, si potrebbe voler aggiungere un commento al markdown che non verrà visualizzato quando sarà visualizzato. Le ragioni sono molteplici. Ad esempio, se si vuole aggiungere un segnaposto per qualcosa che verrà aggiunto in seguito, si può usare un commento per contrassegnare il punto.

Il modo migliore per aggiungere un commento al markdown è usare le parentesi quadre "[]" che circondano due slashes "//" seguite da due punti e dal contenuto. Il risultato sarebbe il seguente:

```text

[//]: Questo è un commento da sostituire in seguito

```

Un commento deve avere una riga vuota prima e dopo il commento.

## Ulteriori Letture

* Il documento Rocky Linux [come contribuire](README.md)

* Altro sugli [ammonimenti](https://squidfunk.github.io/mkdocs-material/reference/admonitions/#supported-types)

* [Riferimento rapido Markdown](https://wordpress.com/support/markdown-quick-reference/)

* [Ulteriori riferimenti rapidi](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet) per Markdown

## Conclusione

La formattazione del documento con titoli, ammonimenti, tabelle, elenchi numerati e virgolette può aggiungere chiarezza al documento. Quando si utilizzano gli ammonimenti, fare attenzione a scegliere il tipo corretto. In questo modo è più facile capire visivamente l'importanza di una particolare ammonimento.

Non è *necessario* utilizzare le opzioni di formattazione avanzate. L'uso eccessivo di elementi speciali può aggiungere disordine dove non ce n'è bisogno. Imparare a usare questi elementi di formattazione in modo prudente e corretto può essere molto utile per far capire il proprio punto di vista in un documento.

Infine, per facilitare la formattazione, si consiglia di modificare il valore TAB dell'editor markdown in quattro (4) spazi.
