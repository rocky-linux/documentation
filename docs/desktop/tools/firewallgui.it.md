---
title: Firewall GUI App
author: Ezequiel Bruni
contributors: Steven Spencer, Ganna Zhyrnova
---

## Introduzione

Si vuole gestire un firewall senza ricorrere alla riga di comando? Esiste un'ottima applicazione specificamente costruita per `firewalld`, il firewall utilizzato in Rocky Linux, ed è disponibile su Flathub. Questa guida mostrerà come renderlo rapidamente operativo e le basi dell'interfaccia.

Non tratteremo tutto ciò che `firewalld` o la GUI possono fare, ma dovrebbe essere sufficiente per iniziare.

## Presupposti

Per questa guida, si presume che l'utente disponga di quanto segue:

 - Un'installazione di Rocky Linux con ambiente desktop grafico
 - `sudo` o accesso come admin
 - Una comprensione di base di come funziona `firewalld`

!!! note "Nota"

```
Ricordate che, anche se questa applicazione vi semplifica la vita se preferite usare una GUI, dovrete comunque comprendere i concetti di base di `firewalld`. È necessario conoscere le porte, le zone, i servizi, le fonti, ecc.

Se non vi è chiaro qualcosa, consultate la [Guida per i principianti a `firewalld`](../../guides/security/firewalld-beginners.md) e leggete in particolare le zone, per capire cosa fanno.
```

## Installazione dell'applicazione

Accedere all'applicazione Software Center e cercare "Firewall". Si tratta di un pacchetto nativo nel repository Rocky Linux e si chiama "Firewall", quindi dovrebbe essere facile da trovare.

![Firewall in Software Center](images/firewallgui-01.png)

Nel repository è `firewall-config` ed è installabile con il solito comando:

```bash
sudo dnf install firewall-config
```

Quando si apre l'applicazione, viene richiesta la password. Sarà richiesta ogni volta che si eseguono operazioni sensibili.

## Modalità di configurazione

La prima cosa da tenere presente è la modalità di configurazione, selezionabile nel menu a discesa in alto nella finestra. Le scelte possibili sono Runtime e Permanent.

![il menu a discesa della modalità di configurazione si trova nella parte superiore della finestra](images/firewallgui-02.png)

L'apertura di porte, l'aggiunta di servizi consentiti e qualsiasi altra modifica apportata in modalità Runtime sono _temporanee_ e non danno accesso a tutte le funzionalità. Al riavvio o quando si ricarica manualmente il firewall, tali modifiche scompariranno. È l'ideale quando si ha bisogno di apportare una modifica rapida per svolgere un singolo compito o se si desidera testare le modifiche prima di renderle permanenti.

Una volta aperta, ad esempio, una porta nella zona Pubblica, si può andare su `Options > Runtime To Permanent` per salvare le modifiche.

La modalità permanente è più rischiosa, ma abilita tutte le funzioni. Consente la creazione di nuove zone, la configurazione individuale dei servizi, la gestione delle interfacce di rete e l'aggiunta di IPSet (in altre parole, set di indirizzi IP che possono o non possono contattare il computer o il server).

Dopo aver apportato le modifiche permanenti, andare su `Options > Reload Firewalld` per attivarle correttamente.

## Gestione delle interfacce/connessioni

Nel pannello all'estrema sinistra, denominato "Active Bindings", si trovano le connessioni di rete e si aggiunge manualmente un'interfaccia di rete. Se si scorre indietro, si vedrà la mia connessione Ethernet (eno1). La zona “pubblica” è ben protetta per impostazione predefinita e comprende la connessione di rete.

Nella parte inferiore del pannello si trova il pulsante "Change Zone", che consente di assegnare il collegamento a un'altra zona. In Permanent mode, è anche possibile creare zone personalizzate.

![a screenshot featuring the Active Bindings panel on the left of the window](images/firewallgui-03.png)

## Gestire le Zone

Nella prima scheda del pannello di destra si trova il menu Zona. Qui è possibile aprire e chiudere porte, attivare o disattivare servizi, aggiungere indirizzi IP attendibili per il traffico in entrata (si pensi alle reti locali), attivare il port forwarding, aggiungere rich rules e altro ancora.

Per la maggior parte degli utenti desktop di base, questo è il punto in cui si trascorrerà la maggior parte del tempo, e le sotto-tabelle più importanti di questo pannello saranno quelle per la configurazione dei servizi e delle porte.

!!! note "Nota"

```
Installare le applicazioni e i servizi dal repository. Alcune di esse (di solito quelle progettate per l'uso su desktop) abiliteranno automaticamente i servizi pertinenti o apriranno le porte appropriate. Tuttavia, se ciò non dovesse accadere, è possibile seguire i passaggi seguenti per fare tutto manualmente.
```

### Aggiunta di un servizio a una Zone

I servizi sono applicazioni popolari e servizi in background come “firewalld” e supportati di default. È possibile attivarli in modo rapido e semplice scorrendo l'elenco e facendo clic sulla casella di controllo corrispondente.

Ora, se avete installato KDE Connect\* per sincronizzare il vostro desktop con altri dispositivi e volete consentirlo attraverso il vostro firewall in modo che funzioni, dovrete farlo:

1. Per prima cosa, selezionare la zona che si desidera modificare. Per questo esempio, è sufficiente utilizzare la zona pubblica predefinita.
2. Scorrere l'elenco e selezionare “kdeconnect”.
3. Se siete in modalità di configurazione Runtime, non dimenticate di fare clic su “Runtime to Permanent” e “Reload Firewalld” nel menu delle opzioni.

\* Disponibile nel repository EPEL.

![una schermata con la scheda Zone nel pannello di destra e il sottopannello Servizi](images/firewallgui-04.png)

Altri servizi popolari nell'elenco sono HTTP e HTTPS per l'hosting di siti web, SSH per consentire l'accesso tramite terminale da altri dispositivi, Samba per l'hosting per la condivisione di file compatibili con Windows e molti altri.

Tuttavia, non tutti i programmi sono presenti nell'elenco e potrebbe essere necessario aprire una porta manualmente.

### Aprire le porte di una Zone

Aprire porte per applicazioni specifiche è abbastanza semplice. Basta leggere la documentazione per conoscere le porte necessarie.

1. Anche in questo caso, selezionare la zona che si desidera modificare.
2. Andare alla scheda Porte nel pannello a destra.
3. Cliccare sul pulsante `Add`.
4. Compilare il campo di testo con la/e porta/e da aprire. Verificare quale protocollo è necessario per l'applicazione e quale protocollo di rete utilizza (ad esempio, TCP/UDP, ecc.).
5. Fare clic su OK e utilizzare le opzioni “Runtime to Permanent” e “Reload Firewalld”.

![un'immagine della schermata che mostra il pannello secondario Porte e la finestra a comparsa in cui è possibile inserire il numero di porta secondo le necessità](images/firewallgui-05.png)

## Conclusione

Se si vuole esercitarsi con il firewall, si dovrebbe leggere di più sui fondamenti di `firewalld`. È inoltre possibile utilizzare la scheda “Services” nella parte superiore del pannello destro (accanto a “Zone”) per configurare esattamente il funzionamento dei servizi o controllare l'accesso di altri computer autorizzati a parlare con il proprio con IPSet e Sorgenti.

Oppure potete aprire la porta per il vostro server Jellyfin e continuare la vostra giornata. `firewalld` è uno strumento incredibilmente potente e l'applicazione Firewall può aiutare a scoprirne le capacità in modo semplice per i neofiti.
