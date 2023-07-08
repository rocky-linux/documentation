---
title: Creare un nuovo documento in GitHub
author: Ezequiel Bruni
contributors: Grammaresque, Franco Colussi
tags:
  - contributing
  - documentation
---

# Come creare un nuovo documento in GitHub

_Quando siete pronti a presentare la documentazione scritta originale per l'approvazione, seguite questi semplici passaggi:_


## Con la GUI di GitHub

È possibile completare quasi tutte le operazioni dalla GUI web di GitHub. Ecco un esempio di aggiunta di un file creato sulla propria macchina locale al repository GitHub della documentazione di Rocky Linux.



1. Accedere al proprio account GitHub.
2. Accedere al repository della documentazione Rocky Linux all'indirizzo [https://github.com/rocky-linux/documentation.](https://github.com/rocky-linux/documentation)
3. Dovreste essere nel ramo " Main ", quindi controllate l'etichetta a discesa nella sezione centrale per essere sicuri di esserlo. Il documento potrebbe non finire nel ramo "Main", ma gli amministratori lo sposteranno in un secondo momento nella posizione più logica.
4. Sul lato destro della pagina, fate clic sul pulsante "Fork", che creerà la vostra copia della documentazione.
5. Al centro della pagina, nella copia fork, appena a sinistra del menu a tendina verde "Code", c'è il pulsante "Add file" (Aggiungi file). Fare clic su questo punto e scegliere l'opzione "Upload files".
6. In questo modo è possibile trascinare e rilasciare i file o sfogliarli sul computer. Utilizzate pure il metodo che preferite.
7. Una volta caricato il file, la cosa successiva da fare è creare una richiesta di Pull Request. Questa richiesta fa sapere agli amministratori upstream che si ha un nuovo file (o più file) che si desidera unire al master.
8. Fare clic su "Pull Request" nell'angolo superiore sinistro dello schermo.
9. Scrivete un breve messaggio nella sezione "Write" per informare gli amministratori di ciò che avete fatto. (Nuovo documento, revisione, modifica suggerita, ecc.) e poi inviare la modifica.


## Dalla riga di comando di Git

Se si preferisce eseguire Git localmente sul proprio computer, è possibile clonare il repository [Rocky Linux Documentation](https://github.com/rocky-linux/documentation), apportare le modifiche e quindi eseguire il commit delle modifiche in seguito. Per semplificare le cose, eseguire i passaggi 1-3 utilizzando l'approccio **Con la GUI di GitHub** di cui sopra, quindi:



1. Clonare il repository su Git: git clone https://github.com/your_fork_name/documentation.git
2. Ora, sul vostro computer, aggiungete i file alla directory.
3. Esempio: mv /home/myname/help.md /home/myname/documentation/
4. Quindi, eseguire Git add per quel nome di file.
5. Esempio: git add help.md
6. Ora, eseguire git commit per le modifiche apportate.
7. Esempio: git commit -m "Added il file help.md"
8. Quindi, spingere le modifiche al repository fork: git push https://github.com/your_fork_name/documentation main
9. Quindi, ripetere i passaggi 6 e 7 di cui sopra: Creare una richiesta di Pull Request. Questa richiesta fa sapere agli amministratori upstream che si ha un nuovo file (o più file) che si desidera unire al ramo master. Fare clic su "Pull Request" nell'angolo superiore sinistro dello schermo.

Si consiglia di controllare i commenti all'interno della PR per le revisioni e i chiarimenti richiesti. 
