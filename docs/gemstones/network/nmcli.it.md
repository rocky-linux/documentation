---
title: nmcli - Impostare la Connessione Automatica
author: wale soyinka
tags:
  - nmcli
---

# Modifica della proprietà di autoconnessione del profilo di connessione di NetworkManager

Per prima cosa utilizzate nmcli per interrogare e visualizzare il valore corrente della proprietà autoconnect per tutte le connessioni di rete su un sistema Rocky Linux. Digita:

```bash
nmcli -f name,autoconnect connection 
```

Per modificare il valore di una proprietà per una connessione di rete, utilizzare il sottocomando `modify` con `nmcli connection`. Ad esempio, per modificare il valore della proprietà autoconnect da `no` a `yes` per il profilo di connessione `ens3`, digitare:

```bash
sudo nmcli con mod ens3 connection.autoconnect yes
```

## Spiegazione dei Comandi

```bash
connection (con) : oggetto di connessione NetworkManager. 
modify (mod)           : Modifica una o più proprietà di un determinato profilo di connessione.
connection.autoconnect : L'ambiente e la proprietà (<setting>.<property>)
-f, --fields : specifica i campi da visualizzare.
```

## Note

Questo suggerimento mostra come modificare un profilo di connessione di NetworkManager esistente. È utile quando l'interfaccia di rete non viene attivata automaticamente dopo una nuova installazione di Rocky Linux o un aggiornamento del sistema. Spesso il motivo è che il valore della proprietà autoconnect è impostato su `no`. È possibile utilizzare il comando `nmcli` per modificare rapidamente il valore in `yes`.  
