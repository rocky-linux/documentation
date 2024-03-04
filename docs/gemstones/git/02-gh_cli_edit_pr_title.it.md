---
title: Modificare o cambiare il titolo di una richiesta di pull esistente tramite CLI
author: Wale Soyinka
contributors: null
tags:
  - GitHub
  - Pull Request
  - Documentation
  - CLI
---

## Introduzione

Questa Gemma spiega come modificare o cambiare il titolo di una richiesta di pull (PR) esistente in un repository GitHub, utilizzando sia l'interfaccia web di GitHub che la CLI.

## Descrizione del problema

A volte può essere necessario modificare il titolo di un PR dopo la sua creazione per riflettere meglio i cambiamenti o le discussioni in corso.

## Prerequisiti

- Una richiesta di pull su GitHub preesistente.
- Accesso all'interfaccia web di GitHub o alla CLI con le autorizzazioni necessarie.

## Procedura

### Utilizzare la CLI di GitHub

1. **Controllare il ramo corrispondente**:
   - Assicurarsi di essere nel ramo associato al PR.
     ```bash
     git checkout branch-name
     ```

2. **Modificare il PR usando la CLI**:
   - Utilizzare il seguente comando per modificare il PR:
     ```bash
     gh pr edit PR_NUMBER --title "New PR Title"
     ```
   - Sostituire `PR_NUMBER` con il numero della richiesta di pull e `"New PR Title"` con il titolo desiderato.

## Informazioni aggiuntive (facoltative)

- La modifica del titolo di un PR non influisce sul thread di discussione o sulle modifiche al codice.
- È considerata una buona pratica informare i collaboratori se vengono apportate modifiche significative al titolo di un PR.

## Conclusione

Seguendo questi passaggi, è possibile modificare facilmente il titolo di una richiesta di pull esistente in un repository GitHub, attraverso lo strumento GitHub CLI (gh).
