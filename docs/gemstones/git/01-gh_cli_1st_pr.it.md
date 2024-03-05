---
title: Primo contributo alla documentazione di Rocky Linux tramite CLI
author: Wale Soyinka
contributors: null
tags:
  - GitHub
  - Rocky Linux
  - Contribution
  - Pull Request
  - CLI
---

## Introduzione

Questa Gemma spiega come contribuire al progetto di documentazione Rocky Linux utilizzando solo l'interfaccia a riga di comando (CLI). Copre la creazione di un fork del repository la prima volta e la creazione di una richiesta di pull.
Nel nostro esempio utilizzeremo la creazione di un nuovo documento Gemstone.

## Descrizione del problema

I collaboratori possono preferire o avere la necessità di eseguire tutte le azioni tramite la CLI, dal fork dei repository all'invio di richieste di pull per la prima volta.

## Prerequisiti

- Un account Github
- `git` e `GitHub CLI (gh)` installati sul proprio sistema
- Un file markdown pronto per la pubblicazione

## Passi della soluzione

1. **Fork del repository usando GitHub CLI**:
   Fare il fork del repository upstream sul proprio account.
   ```bash
   gh repo fork https://github.com/rocky-linux/documentation --clone
   ```

2. **Andare alla directory del repository**:
   ```bash
   cd documentation
   ```

3. **Aggiungere il repository Upstream**:
   ```bash
   git remote add upstream https://github.com/rocky-linux/documentation.git
   ```

4. **Creare un Nuovo Ramo**:
   Creare un nuovo ramo per il proprio contributo. Digitare:
   ```bash
   git checkout -b new-gemstone
   ```

5. **Aggiungere il nuovo documento**:
   Utilizzate il vostro editor di testo preferito per creare e modificare il file contenente il vostro nuovo contributo.
   Per questo esempio, creeremo un nuovo file chiamato `gemstome_new_pr.md` e lo salveremo nella cartella `docs/gemstones/`.

6. **Effettuare il commit delle modifiche**:
   Eseguire il commit del nuovo file. Digitare:
   ```bash
   git add docs/gemstones/gemstome_new_pr.md
   git commit -m "Add new Gemstone document"
   ```

7. **Spingere nel proprio fork**:
   Inviare le modifiche al proprio fork/copia del repo della documentazione di Rocky Linux. Digitare:
   ```bash
   git push origin new-gemstone
   ```

8. **Creare una richiesta di pull**:
   Creare una richiesta di pull al repository upstream.
   ```
   gh pr create --base main --head wsoyinka:new-gemstone --title "New Gemstone: Creating PRs via CLI" --body "Guide on how to contribute to documentation using CLI"
   ```

## Informazioni aggiuntive (facoltative)

- Usare `gh pr list` e `gh pr status` per monitorare lo stato delle richieste di pull.
- Esaminare e seguire le linee guida per il contributo del progetto della documentazione di Rocky Linux.

## Conclusione

Seguendo questi passaggi, dovreste essere in grado di creare con successo il vostro primo PR e contribuire al repository della documentazione di Rocky Linux interamente tramite la CLI!
