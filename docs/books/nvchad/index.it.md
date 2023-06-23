---
title: Panoramica
author: Franco Colussi
contributors: Steven Spencer, Franco Colussi
tested_with: 8.7, 9.1
tags:
  - nvchad
  - coding
  - editor
---

# Introduzione

In questo libro troverete il modo di implementare Neovim, insieme a NvChad, per creare un **ambiente** di **sviluppo** **integrato** (IDE) completamente funzionale.

Dico "modi" perché ci sono molte possibilità. L'autore si concentra sull'uso di questi strumenti per la scrittura di markdown, ma se il markdown non è il vostro obiettivo, non preoccupatevi, continuate a leggere. Se non conoscete nessuno di questi strumenti (NvChad o Neovim), questo libro vi fornirà un'introduzione a entrambi e, se seguirete questi documenti, vi renderete presto conto che potete configurare questo ambiente in modo che sia di grande aiuto per qualsiasi esigenza di programmazione o di scrittura di script.

Volete un IDE che vi aiuti a scrivere i playbook di Ansible? Puoi ottenerlo! Volete un IDE per Golang? Anche questo è disponibile. Volete semplicemente una buona interfaccia per scrivere script BASH? È anche disponibile.

Grazie all'uso dei **L**anguage **S**erver **P**rotocols e dei linters, è possibile configurare un ambiente personalizzato per l'utente. La cosa migliore è che una volta configurato l'ambiente, è possibile aggiornarlo rapidamente quando sono disponibili nuove modifiche attraverso l'uso di Packer e Mason, entrambi trattati qui.

Poiché Neovim è un fork di `vim`, l'interfaccia generale sarà familiare agli utenti di `vim`. Se non siete utenti di `vim`, con questo libro imparerete rapidamente la sintassi dei comandi. Le informazioni trattate sono molte, ma è facile seguirle e, una volta completato il contenuto, si saprà abbastanza per costruire il proprio IDE per le _proprie_ esigenze con questi strumenti.

L'intento dell'autore era quello di **non** suddividere il libro in capitoli. Il motivo è che ciò implica un ordine da seguire che, nella maggior parte dei casi, non è necessario. *Si* consiglia di iniziare da questa pagina, leggere e seguire le sezioni "Software aggiuntivo", "Installare Neovim" e "Installare NvChad", ma da lì si può scegliere come procedere.

## Utilizzo di Neovim come IDE

L'installazione di base di Neovim fornisce un ottimo editor per lo sviluppo, ma non può ancora essere definito un IDE; tutte le funzionalità IDE più avanzate, anche se già preimpostate, non sono ancora attivate. Per farlo, dobbiamo passare le configurazioni necessarie a Neovim, ed è qui che NvChad ci viene in aiuto. Questo ci permette di avere una configurazione di base con un solo comando!

La configurazione è scritta in Lua, un linguaggio di programmazione molto veloce che consente a NvChad di avere tempi di avvio e di esecuzione dei comandi e dei tasti molto rapidi. Ciò è reso possibile anche dalla tecnica di `Lazy loading` utilizzata per i plugin, che li carica solo quando necessario.

L'interfaccia risulta essere molto pulita e piacevole.

Come gli sviluppatori di NvChad tengono a precisare, il progetto vuole essere solo una base su cui costruire il proprio IDE personale. La successiva personalizzazione avviene attraverso l'uso di plugin.

![NvChad UI](images/nvchad_rocky.png)

### Caratteristiche Principali

- **Progettato per essere veloce.** Dalla scelta del linguaggio di programmazione alle tecniche di caricamento dei componenti, tutto è stato progettato per ridurre al minimo i tempi di esecuzione.

- **Interfaccia attraente.** Nonostante si tratti di un'applicazione _cli_, l'interfaccia ha un aspetto moderno e bello dal punto di vista grafico, inoltre tutti i componenti si adattano perfettamente all'interfaccia utente.

- **Estremamente configurabile.** Grazie alla modularità derivata dall'applicazione di base (NeoVim), l'editor può essere adattato perfettamente alle proprie esigenze. Tenete presente, tuttavia, che quando parliamo di personalizzazione ci riferiamo alla funzionalità e non all'aspetto dell'interfaccia.

- **Meccanismo di aggiornamento automatico.** L'editor è dotato di un meccanismo (attraverso l'uso di _git_) che consente di effettuare aggiornamenti con un semplice comando `:NvChadUpdate`.

- **Powered by Lua.** La configurazione di NvChad è scritta interamente in _lua_, il che le consente di integrarsi perfettamente nella configurazione di Neovim, sfruttando tutte le potenzialità dell'editor su cui si basa.

- **Numerosi temi incorporati.** La configurazione include già un gran numero di temi da utilizzare, tenendo sempre presente che stiamo parlando di un'applicazione _cli_, i temi possono essere selezionati con il tasto `<leader> + th`.

![Temi NvChad](images/nvchad_th.png)

## Riferimenti

### Lua

#### Che cos’è Lua?

Lua è un linguaggio di scripting robusto e leggero che supporta diversi metodi di programmazione. Il nome "Lua" deriva dalla parola portoghese che significa "luna"

Lua è stato sviluppato all'Università Cattolica di Rio de Janeiro da Roberto Ierusalimschy, Luiz Henrique de Figueiredo e Waldemar Celes. Lo sviluppo è stato necessario perché fino al 1992 il Brasile era soggetto a rigide norme di importazione per hardware e software, quindi per pura necessità i tre programmatori hanno sviluppato il proprio linguaggio di scripting chiamato Lua.

Poiché Lua si concentra principalmente sugli script, è raramente utilizzato come linguaggio di programmazione autonomo. È invece più spesso utilizzato come linguaggio di scripting che può essere integrato (embedded) in altri programmi.

Lua è utilizzato nello sviluppo di videogiochi e motori di gioco (Roblox, Warframe...), come linguaggio di programmazione in molti programmi di rete (Nmap, ModSecurity...) e come linguaggio di programmazione in programmi industriali. Lua viene utilizzato anche come libreria che gli sviluppatori possono integrare nei loro programmi per abilitare le funzionalità di scripting agendo esclusivamente come parte integrante dell'applicazione host.

#### Come funziona Lua

Ci sono due componenti principali di Lua:

- L'interprete Lua
- La macchina virtuale Lua (VM)

Lua non viene interpretato direttamente attraverso un file Lua come altri linguaggi, ad esempio Python. Utilizza invece l'interprete Lua per compilare un file Lua in bytecode. L'interprete Lua è altamente portatile e in grado di funzionare su una moltitudine di dispositivi.

#### Caratteristiche Principali

- Velocità: Lua è considerato uno dei linguaggi di programmazione più veloci tra i linguaggi di scripting interpretati; può eseguire compiti molto impegnativi dal punto di vista delle prestazioni più velocemente della maggior parte degli altri linguaggi di programmazione.

- Dimensioni: Lua ha dimensioni davvero ridotte rispetto ad altri linguaggi di programmazione. Le dimensioni ridotte sono ideali per integrare Lua in più piattaforme, dai dispositivi embedded ai motori di gioco.

- Portabilità e integrazione: La portabilità di Lua è quasi illimitata. Qualsiasi piattaforma che supporti il compilatore C standard può eseguire Lua senza problemi. Lua non richiede complesse riscritture per essere compatibile con altri linguaggi di programmazione.

- Semplicità: Lua ha un design semplice ma fornisce potenti funzionalità. Una delle caratteristiche principali di Lua sono i meta-meccanismi, che consentono agli sviluppatori di implementare le proprie funzionalità. La sintassi è semplice e in un formato facilmente comprensibile, in modo che chiunque possa facilmente imparare Lua e utilizzarlo nei propri programmi.

- Licenza: Lua è un software libero e open-source distribuito sotto la licenza MIT. Questo permette a chiunque di utilizzarlo per qualsiasi scopo senza pagare alcuna licenza o royalty.

### Neovim

Neovim è descritto in dettaglio nella sua [pagina dedicata](install_nvim.md), quindi ci limiteremo a soffermarci sulle caratteristiche principali, che sono:

- Prestazioni: Molto veloce.

- Personalizzabile: Ampio ecosistema di plugin e temi.

- Evidenziazione della sintassi: Integrazione con Treesitter e LSP (richiede alcune configurazioni aggiuntive).

- Multipiattaforma: Linux, Windows e macOS

- Licenza: Mit: Una licenza permissiva breve e semplice con condizioni che richiedono solo la conservazione del copyright e degli avvisi di licenza.

### LSP

Che cos'è il **L**anguage **S**erver **P**rotocol?

Un server di linguaggio è una libreria di linguaggio standardizzata che utilizza una propria procedura (protocollo) per fornire il supporto a funzioni quali il completamento automatico, la definizione di goto o le definizioni di mouseover.

L'idea alla base del Language Server Protocol (LSP) è quella di standardizzare il protocollo di comunicazione tra strumenti e server, in modo che un singolo server linguistico possa essere riutilizzato in più strumenti di sviluppo. In questo modo, gli sviluppatori possono semplicemente integrare queste librerie nei loro editor e fare riferimento alle infrastrutture linguistiche esistenti, invece di personalizzare il loro codice per includerle.

### tree-sitter

[Tree-sitter](https://tree-sitter.github.io/tree-sitter/) è costituito essenzialmente da due componenti: un generatore di parser e una libreria di parsing incrementale. Può costruire un albero sintattico del file sorgente e aggiornarlo in modo efficiente a ogni modifica.

Un parser è un componente che scompone i dati in elementi più piccoli per facilitarne la traduzione in un'altra lingua o, come nel nostro caso, per passarli alla libreria di parsing. Una volta scomposto il file sorgente, la libreria di parsing analizza il codice e lo trasforma in un albero sintattico, consentendo di manipolare la struttura del codice in modo più intelligente. In questo modo è possibile migliorare (e velocizzare)

- evidenziazione della sintassi
- navigazione del codice
- refactoring
- oggetti e movimenti del testo

!!! note "LSP e complementarità tree-sitter"

    Sebbene possa sembrare che i due servizi (LSP e tree-sitter) siano ridondanti, in realtà sono complementari in quanto LSP lavora a livello di progetto mentre tree-sitter lavora solo sul file sorgente aperto.

Ora che abbiamo spiegato un po' le tecnologie utilizzate per creare l'IDE, possiamo passare al [software aggiuntivo](additional_software.md) necessario per configurare il nostro NvChad.
