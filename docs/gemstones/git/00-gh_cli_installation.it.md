---
title: Installazione e configurazione di GitHub CLI su Rocky Linux
author: Wale Soyinka
tags:
  - GitHub CLI
  - gh
  - git
  - github
---

## Introduzione

Questa gemstone tratta l'installazione e la configurazione di base dello strumento GitHub CLI (gh) sul sistema Rocky Linux, per consentire agli utenti di interagire con i repository GitHub direttamente dalla riga di comando.

## Descrizione del problema

Gli utenti hanno bisogno di un modo comodo per interagire con GitHub senza lasciare l'ambiente della riga di comando.

## Prerequisiti

- Un computer con Rocky Linux in esecuzione
- Accesso ad un terminale
- Familiarità di base con le operazioni da riga di comando
- Un account Github già esistente

## Procedura

1. **Installare il repo GitHub CLI usando curl**:
   Utilizzare il comando curl per scaricare il file del repository ufficiale di `gh`. Il file scaricato deve essere salvato nella directory /etc/yum.repos.d/. Una volta scaricato, usare il comando dnf per installare `gh` dal repository. Digitare:

   ```bash
   curl -fsSL https://cli.github.com/packages/rpm/gh-cli.repo | sudo tee /etc/yum.repos.d/github-cli.repo
   sudo dnf -y install gh
   ```
2. **Verificare l'installazione**:
   Assicurarsi che `gh` sia installato correttamente. Digitare:

   ```bash
   gh --version
   ```
3. **Autenticazione con GitHub**:
   Accedere al proprio account GitHub. Digitare:

   ```bash
   gh auth login
   ```

   Seguire le istruzioni per l'autenticazione.

## Conclusione

A questo punto, sul sistema Rocky Linux 9.3 è stata installata e configurata la GitHub CLI, che consente di interagire con i repository GitHub direttamente dal terminale.

## Informazioni aggiuntive (facoltative)

- GitHub CLI fornisce vari comandi come `gh repo clone`, `gh pr create`, `gh issue list` e così via.
- Per un utilizzo più dettagliato, consultare la [documentazione ufficiale della GitHub CLI](https://cli.github.com/manual/).
