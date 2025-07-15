---
title: Flusso di lavoro Git per Fork e Branch
author: Wale Soyinka
contributors: Ganna Zhyrnova
tags:
  - GitHub
  - git
  - gh
  - git fetch
  - git add
  - git pull
  - git checkout
  - gh repo
---

## Flusso di lavoro Fork e Branch

In questo tipo di flusso di lavoro, i collaboratori creano un fork del repository principale sul proprio account GitHub, creano rami di funzionalità per il loro lavoro e quindi inviano contributi tramite richieste di pull da questi rami.

Questa Gemma spiega come impostare un repository locale per contribuire a un progetto GitHub. Si inizia con il fork del progetto iniziale, la creazione di un repository locale e remoto, il commit delle modifiche e la creazione di una richiesta di pull (PR) per inviare i propri contributi.

## Prerequisiti

- Un account Github.
- `git` e `GitHub CLI (gh)` installati sul sistema.
- Un fork personale del progetto su GitHub.

## Procedura

1. Se non esiste già, creare un fork del progetto usando l'utilità gh. Digita:

  ```bash
  gh repo fork rocky-linux/documentation --clone=true --remote=true
  ```

  Le opzioni utilizzate in questo comando _gh repo fork_ sono:

  - `--clone=true`: Clona il forked repository sulla macchina locale.
  - `--remote=true`: Aggiunge il repository originale come remoto, consentendo di sincronizzare gli aggiornamenti futuri.

2. Navigare nella directory del repository locale. Digita:

  ```bash
  cd documentation
  ```

3. Verificare che tutti i repo remoti siano stati configurati correttamente nel repo locale, digitare:

  ```bash
  git remote -vv
  ```

4. Recuperare le ultime modifiche dal telecomando upstream:

  ```bash
  git fetch upstream
  ```

5. Creare e fare il checkout di un nuovo ramo di funzionalità chiamato your-feature-branch:

  ```bash
  git checkout -b your-feature-branch
  ```

6. Apportare le modifiche, aggiungere nuovi file e fare il commit delle modifiche al repo locale:

  ```bash
  git add .
  git commit -m "Your commit message"
  ```

7. Sincronizzare con il ramo principale del repo remoto chiamato `upstream`:

  ```bash
  git pull upstream main
  ```

8. Spingere le modifiche al vostro Fork\*\*:

  ```bash
  git push origin your-feature-branch
  ```

9. Infine, si può creare una richiesta di pull (PR) usando l'applicazione CLI `gh`:

  ```bash
  gh pr create --base main --head your-feature-branch --title "Your PR Title" --body "Description of your changes"
  ```

  Le opzioni utilizzate in questo comando _gh pr create_ sono:

  `--base` main: Specifica il ramo di base del repository upstream in cui verranno unite le modifiche.
  `--head` your-feature-branch: Indica il ramo principale del fork che contiene le modifiche.
  `--title` "Your PR Title": Imposta il titolo della richiesta di pull.
  `--body` "Description of your changes": Fornisce una descrizione dettagliata delle modifiche apportate alla richiesta di pull.

## Conclusione

Il flusso di lavoro Fork and Branch è un'altra tecnica di collaborazione comune.
Le fasi di alto livello coinvolte sono:

1. Creare una copia del repository: Creare una copia personale del repository del progetto sul proprio account GitHub.
2. Clonare il fork: clonare il fork sulla propria macchina locale per il lavoro di sviluppo.
3. Impostare l'upstream remoto: Per rimanere aggiornati con le modifiche, aggiungere il repository del progetto originale come remoto 'upstream'.
4. Creare un ramo di funzionalità: Creare un nuovo ramo dal ramo principale aggiornato per ogni nuova funzionalità o correzione. I nomi dei rami devono descrivere la funzionalità o la correzione.
5. Fare il commit delle modifiche: Apportare le modifiche e fare il commit con messaggi di commit chiari e concisi.
6. Sincronizzazione con Upstream: Sincronizzate regolarmente il vostro ramo fork e feature con il ramo principale upstream per incorporare le nuove modifiche e ridurre i conflitti di merge.
7. Creare una richiesta di pull (PR): Spingete il ramo della funzionalità nel vostro fork su GitHub e aprite un PR per il progetto principale. Il vostro PR deve descrivere chiaramente le modifiche e collegare a tutti i temi rilevanti.
8. Rispondere al feedback: Collaborare al feedback di revisione finché il PR non viene unito o chiuso.

Benefici:

- Isola il lavoro di sviluppo in rami specifici, mantenendo pulito il ramo principale.
- In questo modo è più facile rivedere e integrare le modifiche.
- Riduce il rischio di conflitti con la base di codice in evoluzione del progetto principale.
