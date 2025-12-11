---
author: Steven Spencer
contributors:
---

# Voce attiva: il modo per comunicare in modo semplice e chiaro

## Voce attiva e voce passiva

In questi giorni c'è un grande dibattito sull'uso della voce attiva nella documentazione. Non dovrebbe esserci. Il motivo è che l'uso della voce attiva contribuisce a creare una documentazione diretta e chiara. Recentemente ho letto un post sui social media in cui si metteva in discussione questa realtà. Il succo della conversazione era: _“La voce passiva non sembra poi così male nella documentazione, dovrei preoccuparmene?”_ Posso assicurarti che **è** importante e che **dovresti** preoccupartene. La voce passiva è spesso ambigua e poco chiara. La voce passiva può creare confusione nella scrittura tecnica, in particolare quando il pubblico è eterogeneo e sono necessarie traduzioni. Il nostro obiettivo con la documentazione di Rocky Linux è quello di avere una documentazione eccellente, e una documentazione eccellente non include l'uso della voce passiva. Esamina questo dalla nostra “Guida allo stile”:

> Esprimere ciò che si intende dire con il minor numero di parole possibile.

L'uso della voce attiva richiede questo. Ecco un esempio d'istruzione in forma passiva:

Per la nostra piattaforma web, Apache deve essere installata utilizzando questo comando: `sudo dnf install httpd`

Mentre qui la voce attiva sarà uguale a:

Per la vostra piattaforma web, installare Apache con questo comando: `sudo dnf install httpd`

In questo esempio ci sono un paio di cose degne di nota. La frase in voce passiva ha 11 parole, mentre quella in voce attiva ne ha 9. La frase in voce attiva invita l'utente a “installare” Apache, anziché dirgli che “deve essere installato”. In entrambi gli esempi, tuttavia, l'istruzione, l'elemento più importante, è nascosta nel corpo della frase. Sebbene 9 parole rappresentino un miglioramento, possiamo fare meglio. Se si ricorda la regola “Dì ciò che intendi con il minor numero di parole possibile”, allora si consideri questo:

Installare Apache con: `sudo dnf install httpd`

Ancora una volta, si utilizza la voce attiva, ma ora con solo 3 parole invece di 9 (o 11). Inoltre, le istruzioni non potrebbero essere più chiare di così. Sono semplici e dirette. Ciò ha ripercussioni sulla traduzione e sulla struttura dei documenti. Tradurre 3 parole richiede meno sforzo ai nostri traduttori. Le istruzioni in tre parole sono chiare per i vostri lettori. Quindi è una vittoria su tutta la linea.

Quando si desidera fornire istruzioni chiare, combinare la semplificazione con la forma attiva aiuta a raggiungere l'obiettivo.

## Identificare la voce passiva

Quando ho iniziato a scrivere la documentazione per Rocky Linux nel 2021, ho iniziato con una serie di documenti che avevo scritto quando lavoravo ancora come amministratore di rete. I miei documenti erano pieni di frasi in forma passiva e, all'epoca, non riuscivo a individuarle facilmente. È stato solo alla fine del 2023 che l'editor che ho iniziato a utilizzare sia per creare che per modificare documenti ([basato su Neovim](https://neovim.io/) con [Vale](https://vale.sh/)) ha iniziato a evidenziare le frasi in forma passiva. È stato difficile allenare il mio occhio a “vedere” le frasi in forma passiva a colpo d'occhio. Non è ancora sempre facile da vedere. Ecco alcuni aspetti da tenere in considerazione per aiutare a identificare la voce passiva:

- Istruzioni che iniziano con o includono 'noi' o 'nostro'

  Questi portano quasi sempre a formulazioni che sono in primis, indirette, e spesso includono la voce passiva. Usa 'voi' o 'il vostro'  quando scrivi le istruzioni.

- Fare attenzione ai verbi come:  'era', 'erano', 'sono', 'stato', 'essere', e così via, seguiti da una frase con participio passato che di solito (ma non sempre). Esempi:

  - "fu creato"
  - "sono stati fatti i backup"
  - "sono stati manipolati"
  - "è stato recuperato"
  - "è stato installato"
  - "è nascosto"

  Ognuno di questi è un esempio di voce passiva.

- Fare attenzione alle frasi in cui l'istruzione **non** è l'elemento principale (il soggetto).

È possibile allenare l'occhio a individuarle durante la correzione di bozze, ma se ci si concentra sull'obiettivo di semplificare le istruzioni, si noterà che l'eliminazione della voce passiva avverrà senza troppa fatica. È comunque **molto** utile usare un editor che supporti l'integrazione con Vale.

## Conclusione

L'uso della voce attiva nella scrittura tecnica contribuisce a garantire istruzioni semplici e chiare. Inoltre, una maggiore semplificazione della scrittura migliora la leggibilità e la comprensibilità e facilita il lavoro di traduzione. Ricorda: “Esprimi ciò che intendi dire con il minor numero di parole possibile”.

## Ulteriori letture

- Tech Whirl - [Avoiding Passive Voice](https://techwhirl.com/avoiding-passive-voice/)
- Google Developers - [Active voice vs. passive voice](https://developers.google.com/tech-writing/one/active-voice)
