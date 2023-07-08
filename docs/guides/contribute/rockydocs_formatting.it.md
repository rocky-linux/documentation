---
title: Formattazione di Rocky Docs
author: Steven Spencer
contributors: Krista Burdine, tianci li, Ezequiel Bruni, Franco Colussi
tags:
  - contribute
  - formatting
---

# Formattazione di Rocky Docs - Introduzione

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

## Ammonimenti

Le ammonizioni sono speciali "scatole" visive che consentono di richiamare l'attenzione su fatti importanti e di evidenziarli in modo da farli risaltare rispetto al resto del testo. I tipi di ammonimenti sono i seguenti:

| tipo                | Descrizione                                                              |
| ------------------- | ------------------------------------------------------------------------ |
| note                | restituisce un riquadro di testo blu                                     |
| abstract            | restituisce un riquadro di testo blu chiaro                              |
| info                | restituisce un riquadro di testo blu-verde                               |
| tip                 | restituisce un riquadro di testo blu-verde (icona leggermente più verde) |
| success             | rende una casella di testo verde                                         |
| question            | restituisce un riquadro di testo verde chiaro                            |
| warning             | restituisce un riquadro di testo arancione                               |
| failure             | restituisce un riquadro di testo rosso chiaro                            |
| danger "Pericolo"   | restituisce un riquadro di testo di testo rosso                          |
| bug                 | restituisce un riquadro di testo testo rosso                             |
| example             | restituisce un riquadro di testo rossa                                   |
| quote               | restituisce un riquadro di testo grigia                                  |
| custom <sub>1</sub> | restituisce sempre un riquadro di testo di testo blu                     |
| custom <sub>2</sub> | utilizza un titolo personalizzato all'interno di un altro tipo           |

Non ci sono limiti ai tipi di ammonizioni che si possono usare, come indicato in custom <sub>1</sub> di cui sopra. Un titolo personalizzato può essere aggiunto a uno qualsiasi degli altri tipi di ammonimento per ottenere la scatola colorata che si desidera per un specifico ammonimento, come osservato in custom <sub>2</sub> sopra.

Un'ammonimento viene sempre inserito in questo modo:

```
!!! admonition_type

    text of admonition
```

Il testo del corpo dell'ammonizione deve essere rientrato di quattro (4) spazi rispetto al margine iniziale. È facile vedere dove è in questo caso, perché si allineerà sempre sotto la prima lettera del tipo di ammonimento. La riga in più tra il titolo e il corpo non verrà visualizzata, ma è necessaria per il corretto funzionamento del nostro motore di traduzione (Crowdin).

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

    Un tipo custom  <sub>1</sub>. Qui abbiamo usato "custom" come nostro tipo di ammonimento. Di nuovo, questo risulterà sempre in blu.

!!! warning "titolo personalizzato"

    Un tipo custom <sub>2</sub>. Ecco il nostro secondo articolo della lista. Poiché abbiamo usato l'indentazione (sopra), viene visualizzato con la prossima sequenza di numerazione (in altre parole, 2), ma se avessimo inserito l'elemento 1 senza l'indentazione (nel paragrafo successivo e nel codice), allora questo sarebbe apparso di nuovo come elemento 1, che non è ciò che vogliamo.

    ```
    !!! warning "titolo personalizzato"
    ```

### Ammonimenti Espandibili

Se un'ammonimento ha un contenuto molto lungo, considerate la possibilità di utilizzare un'ammonizione espandibile. Questo viene trattato come un normale ammonimento, ma inizia con tre punti interrogativi, anziché con tre punti esclamativi. Si applicano tutte le altre regole degli ammonimenti. Un ammonimento espandibile assomiglia a questo:

??? warning "Avvertenze sul contenuto"

    Si tratta di un avviso, con poco contenuto. Per questo si dovrebbe usare un'ammonimento normale, ma questo è solo un esempio!

Che si presenta così nell'editor:

```
??? warning "Avvertenze sul contenuto"

    Si tratta di un avviso, con poco contenuto. Per questo si dovrebbe usare un'ammonimento normale, ma questo è solo un esempio!
```

## Contenuto a schede all'interno di un documento

Il contenuto della scheda è formattato in modo simile alle ammonimenti. Invece di tre punti esclamativi o tre punti interrogativi, inizia con tre segni uguali. Tutta la formattazione dell'ammonimento (4 spazi, ecc.) si applica a questo contenuto. Ad esempio, la documentazione potrebbe richiedere una procedura diversa per una diversa versione di Rocky Linux. Quando si usa il contenuto a schede per le versioni, la release più recente di Rocky Linux deve essere la prima. Al momento della stesura del presente documento, il codice è 9.0:

=== "9.0"

    La procedura per farlo in 9.0

=== "8.6"

    La procedura per farlo in 8.6

Che si presenterebbe così nell'editor:

```
=== "9.0"

    La procedura per farlo in 9.0

=== "8.6"

    La procedura per eseguire questa operazione in 8.6
```

Tenete presente che tutto ciò che si trova all'interno della sezione deve continuare a utilizzare il rientro di 4 spazi fino al completamento della sezione. Questa è una funzione molto utile!

## Liste numerate

Le liste numerate sembrano facili da creare e da usare e, una volta che ci si è abituati, lo sono davvero. Se si dispone di un unico elenco di elementi senza alcuna complessità, questo tipo di formato va bene:

```
1. Elemento 1

2. Elemento 2

3. Elemento 3
```

1. Elemento 1

2. Elemento 2

3. Elemento 3

Se è necessario aggiungere blocchi di codice, righe multiple o addirittura paragrafi di testo a un elenco numerato, il testo deve essere rientrato con gli stessi quattro (4) spazi utilizzati per gli ammonimenti.

Tuttavia, non è possibile allinearli con gli occhi sotto l'elemento numerato, poiché questo è uno spazio in meno. Se si utilizza un buon editor di markdown, è possibile impostare il valore di tabulazione a quattro (4), il che renderà la formattazione un po' più semplice.

Ecco un esempio di elenco numerato a più righe, con un blocco di codice aggiunto per buona causa:

1. Quando si ha a che fare con elenchi numerati su più righe e che includono elementi come blocchi di codice, si può usare l'indentazione spaziale per ottenere ciò che si desidera.

    Ad esempio: questo è rientrato di quattro (4) spazi e rappresenta un nuovo paragrafo di testo. E qui aggiungiamo un blocco di codice. È inoltre rientrato degli stessi quattro (4) spazi del nostro paragrafo:

    ```
    dnf update
    ```

2. Ecco il nostro secondo articolo della lista. Poiché abbiamo usato l'indentazione (sopra), viene visualizzato con la prossima sequenza di numerazione (in altre parole, 2), ma se avessimo inserito l'elemento 1 senza l'indentazione (nel paragrafo successivo e nel codice), allora questo sarebbe apparso di nuovo come elemento 1, che non è ciò che vogliamo.

Ed ecco come appare il testo grezzo:

```markdown
1. Quando si ha a che fare con elenchi numerati su più righe e che includono elementi come blocchi di codice, si può usare l'indentazione spaziale per ottenere ciò che si desidera.

    Ad esempio: questo è rientrato di quattro (4) spazi e rappresenta un nuovo paragrafo di testo. E qui aggiungiamo un blocco di codice. È inoltre rientrato degli stessi quattro (4) spazi del nostro paragrafo:

    ```


    dnf update
    ```

2. Ecco il nostro secondo articolo della lista. Poiché abbiamo usato l'indentazione (sopra), viene visualizzato con la prossima sequenza di numerazione (in altre parole, 2), ma se avessimo inserito l'elemento 1 senza l'indentazione (nel paragrafo successivo e nel codice), allora questo sarebbe apparso di nuovo come elemento 1, che non è ciò che vogliamo.
```

## Tabelle

Le tabelle ci aiutano a disporre le opzioni di comando o, nel caso precedente, i tipi di ammonimento e le descrizioni. Ecco come viene inserita la tabella nella sezione Ammonimenti di cui sopra:

```
| type      | Description                                               |
|-----------|-----------------------------------------------------------|
| note      | restituisce una cornice di testo blu                                   |
| abstract  | restituisce una cornice di testo blu chiaro                             |
| info      | restituisce una cornice di testo verde-blu                             |
| tip       | restituisce una cornice di testo verde-blu (icona leggermente più verde)  |
| success   | restituisce una cornice di testo verde                                  |
| question  | restituisce una cornice di testo verde chiaro                            |
| warning   | restituisce una cornice di testo arancione                                |
| failure   | restituisce una cornice di testo rosso chiaro                              |
| danger    | restituisce una cornice di testo rosso                                    |
| bug       | restituisce una cornice di testo rosso                                    |
| example   | restituisce una cornice di testo viola                                 |
| quote     | restituisce una cornice di testo grigio                                   |
| custom <sub>1</sub> | restituisce sempre una cornice di testo blu                  |
| custom <sub>2</sub> | utilizza un titolo personalizzato all'interno di un altro tipo         |

```

Si noti che non è necessario che ogni colonna sia suddivisa per dimensione (come abbiamo fatto nella prima parte della tabella), ma è certamente più leggibile nel file sorgente markdown. La confusione può essere maggiore quando si uniscono gli elementi, semplicemente interrompendo le colonne con il carattere pipe "|" in qualsiasi punto in cui sarebbe naturale interromperle, come si può vedere negli ultimi due elementi della tabella.

## Virgolettato

Le virgolette sono in realtà pensate per citare il testo di altre fonti da includere nella documentazione, ma non devono essere utilizzate necessariamente in questo modo. Alcuni collaboratori usano le virgolette invece delle tabelle, ad esempio per elencare alcune opzioni. Esempi di virgolette in markdown sono:

```
> **un elemento** - Una descrizione di quell'elemento

> **un'altra voce** - Un'altra descrizione di quell'elemento
```

Per evitare che le righe si sovrappongano, è necessaria una linea di "spaziatura" aggiuntiva.

Il risultato è questo quando la pagina viene visualizzata:

> **un elemento** - Una descrizione dell'elemento **un altro elemento** - Altra descrizione di un elemento

## Blocchi di codice in linea e a livello di blocco

Il nostro approccio all'uso dei blocchi di codice è piuttosto semplice. Se il `vostro codice` è abbastanza breve da poterlo (e volerlo) usare in una frase come quella appena vista, si possono usare i singoli backtick <kbd>`</kbd>, in questo modo:

```
Una frase con un "comando a scelta".
```

Qualsiasi comando che non sia usato all'interno di un paragrafo di testo (specialmente i pezzi di codice lunghi con più righe) dovrebbe essere un blocco di codice completo, definito con tripli backtick <kbd>`</kbd>:

````markdown
```bash
sudo dnf install the-kitchen-sink
```
````
La parte `bash` di questa formattazione è un identificatore di codice non essenziale, ma può essere utile per l'evidenziazione della sintassi. Naturalmente, se si sta mostrando Python, PHP, Ruby, HTML, CSS o qualsiasi altro tipo di codice, il termine "bash" deve essere cambiato in qualsiasi linguaggio si stia utilizzando.
Per inciso, se è necessario mostrare un blocco di codice all'interno di un blocco di codice, basta aggiungere un altro backtick <kbd>`</kbd> al blocco padre, in questo modo:

`````markdown
````markdown
```bash
sudo dnf install the-kitchen-sink
```
````
`````

E sì, il blocco di codice che avete appena visto ha usato cinque backtick all'inizio e alla fine per renderlo correttamente.

## Tastiera

Un altro modo per aggiungere più chiarezza possibile ai documenti è quello di rappresentare sulla tastiera i tasti che devono essere inseriti nel modo corretto. Questo viene fatto con `<kbd>key</kbd>`. Ad esempio, per rappresentare la necessità di premere il tasto escape nel documento, si userebbe `<kbd>ESC</kbd`. Quando è necessario indicare che devono essere premuti più tasti, aggiungete un `+` tra di essi, come in questo caso: `<kbd>CTRL</kbd> + <kbd>F4</kbd>`. Se i tasti devono essere premuti simultaneamente, aggiungete "simultaneamente" o "allo stesso tempo" o una frase simile alle istruzioni. Ecco un esempio di istruzione da tastiera nell'editor:

```
Un'installazione di tipo workstation (con interfaccia grafica) avvia questa interfaccia sul terminale 1. Essendo Linux multiutente, è possibile connettere più utenti più volte, su diversi **terminali fisici** (TTY) o **terminali virtuali** (PTS). I terminali virtuali sono disponibili in un ambiente grafico. Un utente passa da un terminale fisico ad un altro usando <kbd>Alt</kbd> + <kbd>Fx</kbd> dalla riga di comando o utilizzando <kbd>CTRL</kbd> + <kbd>Alt</kbd> + <kbd>Fx</kbd> in modalità grafica.
```

Ed ecco come viene visualizzato:

Un'installazione di tipo workstation (con interfaccia grafica) avvia questa interfaccia sul terminale 1. Essendo Linux multiutente, è possibile connettere più utenti più volte, su diversi **terminali fisici** (TTY) o **terminali virtuali** (PTS). I terminali virtuali sono disponibili in un ambiente grafico. Un utente passa da un terminale fisico ad un altro usando <kbd>Alt</kbd> + <kbd>Fx</kbd> dalla riga di comando o utilizzando <kbd>CTRL</kbd> + <kbd>Alt</kbd> + <kbd>Fx</kbd> in modalità grafica.

## Simboli di Apice, Pedice e Speciali

Le notazioni in apice e in pedice non sono un normale markdown, ma sono supportate nella documentazione di Rocky Linux attraverso i tag HTML usati per lo stesso scopo. L'apice pone il testo inserito tra i tag leggermente al di sopra del testo normale, mentre il pedice lo pone leggermente al di sotto. L'apice è di gran lunga il più usato nella scrittura. Alcuni caratteri speciali appaiono già in apice senza l'aggiunta dei tag, ma è possibile combinare i tag per cambiare l'orientamento di tali caratteri, come si vede con il simbolo del copyright qui sotto. Si può usare l'apice per:

* rappresentano numeri ordinali, come 1<sup>st</sup>, 2<sup>nd</sup>, 3<sup>rd</sup>
* simboli di copyright e marchi, come <sup>&copy;</sup>, <sup>TM</sup>, o &trade;, &reg;
* come notazione per riferimenti, come questo<sup>1</sup>, questo<sup>2</sup> e questo<sup>3</sup>

Alcuni caratteri speciali, come &copy;, non sono normalmente apici, mentre altri, come &trade;, lo sono.

Ecco come appare tutto questo nel codice markdown:

```
* rappresentano numeri ordinali, come 1<sup>st</sup>, 2<sup>nd</sup>, 3<sup>rd</sup>
* simboli di copyright e marchi, come <sup>&copy;</sup>, <sup>TM</sup> o &trade;, &reg;
* come notazione per riferimenti, come questo<sup>1</sup>, questo<sup>2</sup> e questo<sup>3</sup>

Alcuni dei caratteri speciali, come &copy; non sono normalmente in apice, mentre altri come &trade;, sono.
```

Come si può vedere, per forzare l'apice possiamo usare i tag HTML supportati di `<sup></sup>`.

Il pedice viene inserito con il tag `<sub></sub>`, e, come già detto, non viene <sub>usato tanto</sub> nella scrittura.

### Apice per i riferimenti

Alcuni di voi potrebbero sentire la necessità di fare riferimento a fonti esterne quando scrivono la documentazione. Se avete una sola fonte, potete includerla nella conclusione come un unico link, ma se ne avete più di una<sup>1</sup>, potete usare l'apice per annotarle nel testo<sup>2</sup> e poi elencarle alla fine del documento. Si noti che il posizionamento dei riferimenti deve avvenire dopo la sezione "Conclusioni".

Dopo la conclusione, è possibile inserire le notazioni in un elenco numerato che corrisponde all'apice, oppure come link. Entrambi gli esempi sono mostrati qui:

1. "Come si usano i multipli nel testo" di Wordy W. McWords [https://site1.com](https://site1.com)
2. "Using Superscript In Text" di Sam B. Supersecret [https://site2.com](https://site2.com)

o

[1](https://site1.com) "Come si usano i multipli nel testo" by Wordy W. McWords  
[2](https://site2.com) "Utilizzo dell'apice nel testo" by Sam B. Supersecret

Ecco come si presenta il tutto nel vostro editor:

```
1. "Come si usano i multipli nel testo" by Wordy W. McWords [https://site1.com](https://site1.com)
2. "Utilizzo dell'apice nel testo" by Sam B. Supersecret [https://site2.com](https://site2.com)

o

[1](https://site1.com) "Come si usano i multipli nel testo" by Wordy W. McWords  
[2](https://site2.com) "Utilizzo dell'apice nel testo" by Sam B. Supersecret  

```

## Raggruppare diversi tipi di formattazione

La Documentazione Rocky offre alcune eleganti opzioni di formattazione quando si combinano più elementi all'interno di un altro elemento. Per esempio, un ammonimento con un elenco numerato:

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

    Premere <kbd>ESC</kbd> senza un motivo particolare.

2. Ma questo articolo è qualcosa di molto importante *e* ha più paragrafi ad esso dedicati

    E ha un ammonimento nel mezzo:

    !!! warning "Attenzione"
   
        Le cose possono diventare un po' strane con più elementi all'interno di diversi tipi di formattazione!

Se si rispettano i magici quattro (4) spazi per rientrare e separare gli elementi, questi verranno visualizzati in modo logico ed esattamente come si desidera. A volte è davvero importante.

È anche possibile incorporare una tabella o una citazione a blocchi (letteralmente qualsiasi tipo di elemento di formattazione) all'interno di un'altra. Qui abbiamo un elenco numerato, un ammonimento, una tabella e alcuni elementi di citazione a blocchi, tutti raggruppati insieme:

1. Cercare di tenere il passo con tutto ciò che accade nel documento può essere un vero compito quando si lavora con più elementi.

2. Se vi sentite sopraffatti, prendete in considerazione:

    !!! warning "importante: credo che mi faccia male la testa!"
   
        Quando si combinano più elementi di formattazione, il cervello può impazzire. Prendete in considerazione l'idea di assumere un po' di caffeina in più prima di cominciare!
       
        | tipo            |   dose giornaliera di caffeina       |
        |-----------------|----------------------------------|
        | tea             | alla fine ci arriverete |
        | coffee          | per palati esigenti        |
        | red bull        | Ha un sapore terribile, ma vi farà andare avanti! |
        | mountain dew    | eccessivamente ipnotico                       |
       
        > **zucchero** se la caffeina non è di vostro gradimento
       
        > **soffrire** se tutto il resto fallisce, concentrarsi di più

3. Ci sono altri esempi, ma quello sopra riportato dovrebbe illustrare che tutto può essere annidato all'interno. Ricordate i quattro (4) spazi magici.

Ecco come appare questo esempio nell'editor:

```

Se si rispettano i magici quattro (4) spazi per separare questi elementi, essi verranno visualizzati in modo logico ed esattamente come si desidera. A volte è davvero importante.

È anche possibile incorporare una tabella o una citazione a blocchi (letteralmente qualsiasi tipo di elemento di formattazione) all'interno di un'altra. Qui abbiamo un elenco numerato, un ammonimento, una tabella e alcuni elementi di citazione a blocchi, tutti raggruppati insieme:

1. Cercare di tenere il passo con tutto ciò che accade nel documento può essere un vero compito quando si lavora con più elementi.

2. Se vi sentite sopraffatti, prendete in considerazione!!! warning "importante: credo che mi faccia male la testa!"

        Quando si combinano più elementi di formattazione, il cervello può impazzire. Prendete in considerazione l'idea di assumere un po' di caffeina in più prima di cominciare!

        | tipo            |   dose giornaliera di caffeina       |
        |-----------------|----------------------------------|
        | tea             | alla fine ci arriverete |
        | coffee          | per palati esigenti        |
        | red bull        | Ha un sapore orribile, ma vi farà andare avanti! |
        | mountain dew    | eccessivamente ipnotico                       |

        > **zucchero** se la caffeina non è di vostro gradimento

        > **soffrire** se tutto il resto fallisce, concentrarsi di più

3. Ci sono altri esempi, ma quello sopra riportato dovrebbe illustrare che tutto può essere annidato all'interno. Ricordate i quattro (4) spazi magici.
```

## Un ultimo punto: i Commenti

Di tanto in tanto, si potrebbe voler aggiungere un commento al markdown che non verrà visualizzato quando sarà elaborato. Ci sono molte ragioni per cui si potrebbe voler fare questo. Ad esempio, se si vuole aggiungere un segnaposto per qualcosa che verrà aggiunto in seguito, si può usare un commento per contrassegnare il punto.

Il modo migliore per aggiungere un commento al markdown è usare le parentesi quadre "[]" intorno a due barre in avanti "//" seguite da due punti e dal contenuto. Il risultato sarebbe il seguente:

```

[//]: Questo è un commento da sostituire in seguito

```

Un commento dovrebbe avere una riga vuota prima e dopo il commento.

## Ulteriori Letture

* Il documento Rocky Linux [come contribuire](README.md)

* Altro sugli [ammonimenti](https://squidfunk.github.io/mkdocs-material/reference/admonitions/#supported-types)

* [Riferimento rapido Markdown](https://wordpress.com/support/markdown-quick-reference/)

* [Ulteriori riferimenti rapidi](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet) per Markdown

## Conclusione

La formattazione del documento con titoli, ammonimenti, tabelle, elenchi numerati e virgolette può aggiungere chiarezza al documento. Quando si utilizzano gli ammonimenti, fare attenzione a scegliere il tipo corretto. In questo modo è più facile capire visivamente l'importanza di una particolare ammonimento.

Non è *necessario* utilizzare le opzioni di formattazione avanzate. L'uso eccessivo di elementi speciali può aggiungere disordine dove non ce n'è bisogno. Imparare a usare questi elementi di formattazione in modo prudente e corretto può essere molto utile per far capire il proprio punto di vista in un documento.

Infine, per facilitare la formattazione, si consiglia di modificare il valore TAB dell'editor markdown in quattro (4) spazi.
