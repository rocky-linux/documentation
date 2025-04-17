---
title: Creare un nuovo documento in GitHub
author: Ezequiel Bruni
contributors: Grammaresque, Ganna Zhyrnova
tags:
  - contributing
  - documentation
---

# Come creare un nuovo documento in GitHub

*Quando siete pronti a presentare la documentazione scritta originale per l'approvazione, seguite questi semplici passaggi:*

## Con la GUI di GitHub

È possibile completare quasi tutte le operazioni dalla GUI web di GitHub. Ecco un esempio di aggiunta di un file creato sulla propria macchina locale al repository GitHub della documentazione di Rocky Linux.

1. Accedere al proprio account GitHub.
2. Accedere al repository della documentazione Rocky Linux all'indirizzo <https://github.com/rocky-linux/documentation>.
3. Dovreste essere nel ramo " Main ", quindi controllate l'etichetta a discesa nella sezione centrale per essere sicuri di esserlo. Il documento potrebbe non finire nel ramo "Main", ma gli amministratori lo sposteranno in un secondo momento nella posizione più logica.
4. Sul lato destro della pagina, fare clic sul pulsante ++"Fork "++ per creare una copia della documentazione.
5. Al centro della pagina, nella copia biforcuta, proprio a sinistra del menu a tendina verde "Codice", si trova il pulsante ++"Aggiungi file "++. Fare clic su questo punto e scegliere l'opzione "Upload files".
6. In questo modo è possibile trascinare e rilasciare i file o sfogliarli sul computer. Utilizzate pure il metodo che preferite.
7. Una volta caricato il file, la cosa successiva da fare è creare una richiesta di Pull Request. Questa richiesta fa sapere agli amministratori upstream che si ha un nuovo file (o più file) che si vuole unire al ramo master.
8. Fare clic su `Pull Request` nell'angolo superiore sinistro dello schermo.
9. Scrivete un breve messaggio nella sezione "Write" per informare gli amministratori di ciò che avete fatto. (Nuovo documento, revisione, modifica suggerita, ecc.) e poi inviare la modifica.

## Dalla riga di comando di Git

Se si preferisce eseguire Git localmente sul proprio computer, è possibile clonare il repository [Rocky Linux Documentation](https://github.com/rocky-linux/documentation), apportare le modifiche e quindi eseguire il commit delle modifiche in seguito. Per semplificare le cose, eseguire i passaggi 1-3 utilizzando l'approccio **Con la GUI di GitHub** di cui sopra, quindi:

1. Clonare il repository con Git:

    ```text
    git clone https://github.com/your_fork_name/documentation.git
    ```

2. Ora, sul vostro computer, aggiungete i file alla directory. Esempio:

    ```bash
    mv /home/myname/help.md /home/myname/documentation/
    ```

3. Quindi, eseguire Git add per quel nome di file. Esempio:

    ```text
    git add help.md
    ```

4. Ora, eseguire git commit per le modifiche apportate. Esempio:

    ```text
    git commit -m "Added the help.md file"
    ```

5. Successivamente, si esegua il push delle modifiche al proprio repository biforcuto:

    ```text
    git push https://github.com/your_fork_name/documentation main
    ```

6. Quindi, ripetere i passaggi 6 e 7 di cui sopra: Creare una richiesta di pull. Questa richiesta fa sapere agli amministratori upstream che si ha un nuovo file (o più file) che si desidera unire al ramo master. Fare clic su `Pull Request` nell'angolo superiore sinistro dello schermo.

Si consiglia di controllare i commenti all'interno della PR per le revisioni e i chiarimenti richiesti.
