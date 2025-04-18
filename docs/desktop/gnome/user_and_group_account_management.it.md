---
title: Gestione degli account di utenti e gruppi
author: Sasheeny Hubbard
contributors: Steven Spencer, Ganna Zhyrnova
tested with: 9.4
tags:
  - desktop
  - gnome
  - cockpit
---

## Introduzione

Questa guida vi insegnerà a gestire gli account degli utenti e dei gruppi su Rocky Linux 9.4 utilizzando Cockpit, uno strumento di amministrazione con interfaccia grafica basata sul web per i server Linux.

## Prerequisiti

- Accesso al sistema operativo Rocky Linux 9 con interfaccia grafica
- Privilegi amministrativi
- Pacchetto Cockpit installato e abilitato

## Cockpit

Cockpit è uno strumento di amministrazione con interfaccia grafica basato sul web per i server Linux. Pur avendo molti casi d'uso, utilizzeremo Cockpit per gestire gli account di utenti e gruppi. I vantaggi di Cockpit sono la facilità d'uso, la gestione remota, l'integrazione, il feedback in tempo reale e i cruscotti multi-server.

### Accedere a Cockpit

- Aprite il vostro browser web e digitate <https://localhost:9090> nella barra degli indirizzi

  > **Nota**: Si può anche inserire l'indirizzo esatto dalla riga di comando

  ```text
  https://localhost:9090
  ```

- Inserire il nome utente e la password e fare clic sul pulsante **Log In**

  ![img](images/user_group_acctmgt_images/1.png)

- Fare clic sul pulsante **Accesso limitato** e inserire la password per abilitare l'accesso amministrativo

  ![img](images/user_group_acctmgt_images/2.png)

## Gestione di utenti e gruppi

### Gestire l'accesso degli utenti

- Dal menu di sinistra, fare clic sulla scheda **Accounts** e poi sul pulsante **Creare un nuovo account**

  ![img](images/user_group_acctmgt_images/5.png)

- Inserire il nome dell'utente nella casella di testo **Nome completo**
  > _Si noti che il nome utente verrà popolato automaticamente in base al nome completo. Tuttavia, è possibile modificare anche i campi Nome utente e ID, se necessario._

- Inserire una password per il nuovo utente

- Cliccare su **Create**

  ![img](images/user_group_acctmgt_images/8.png)

#### Metodo CLI: gestione degli account utente

```text
sudo useradd username -md /home/username -u 1002 -s /bin/bash 
```

```text
sudo passwd username 
```

Osservare l'aggiunta del nuovo utente all'elenco degli utenti visualizzato nella scheda **Accounts**.

![img](images/user_group_acctmgt_images/9.png)

#### Metodo CLI: visualizzazione del file `passwd`

```text
cat /etc/passwd
```

### Modificare il profilo di un utente

- Fare clic sull'icona a forma di ellisse verticale per il nuovo utente, quindi fare clic su **Modifica utente**

  ![img](images/user_group_acctmgt_images/13.png)

Qui è possibile modificare le impostazioni dell'account utente, ad esempio:

- Nome e cognome
- Appartenenza al gruppo
- Impostazioni password
- Shell

  ![img](images/user_group_acctmgt_images/15.png)

Per aggiungere un utente a un gruppo, procedere come segue:

- Fare clic sull'icona a forma di ellisse verticale accanto al nuovo utente e fare clic su **Modifica utente**

- Fare clic sulla casella di testo **Gruppi** e digitare il nome del gruppo.\
  In alternativa, è possibile scorrere il menu a discesa e fare clic sul nome del gruppo che si desidera aggiungere

  ![img](images/user_group_acctmgt_images/14.png)

#### Metodo CLI: aggiunta di un utente a un gruppo

```text
sudo usermod -aG groupname username
```

Per rimuovere un utente da un gruppo:

- Fare clic sulla **x** accanto al nome del gruppo

  ![img](images/user_group_acctmgt_images/18.png)

#### Metodo CLI: rimuovere un utente da un gruppo

```text
sudo gpasswd -d username groupname
```

### Elimina account utente

Per eliminare un account utente:

- Fare clic sull'icona a forma di ellisse verticale per il nuovo utente e fare clic su **Elimina account**

  ![img](images/user_group_acctmgt_images/16.png)

Oppure

- Fare clic sul nome utente evidenziato in blu e selezionare la casella **Elimina**

  ![img](images/user_group_acctmgt_images/17.png)

  ![img](images/user_group_acctmgt_images/22.png)

#### Metodo CLI: eliminare un account utente

```text
sudo userdel -d username groupname
```

### Creazione, eliminazione e gestione degli account di gruppo

- Dalla colonna del menu a sinistra, fare clic sulla scheda **Accounts**, quindi sul pulsante **Create new group**

  ![img](images/user_group_acctmgt_images/7.png)

- Inserire il nome del gruppo nella casella di testo

> _Nota: è possibile accettare l'ID di gruppo predefinito o modificarlo con il valore numerico desiderato (ad esempio, 5001)_

- Cliccare su **Select**

  ![img](images/user_group_acctmgt_images/11.png)

#### Metodo CLI: aggiungere un nome di gruppo

```text
sudo groupadd groupname
```

Per verificare che il gruppo sia stato creato:

- Inserire il nome del gruppo nella casella di ricerca della tabella **Gruppi**

O

- Fare clic sul menu a discesa accanto a **Gruppi**

  ![img](images/user_group_acctmgt_images/12.png)

#### Metodo CLI: verifica del nome del gruppo

```text
cat /etc/group | grep groupname
```

Eliminare un gruppo:

- Fare clic sull'ellissi verticale del nuovo utente e fare clic su **Elimina gruppo**

  ![img](images/user_group_acctmgt_images/21.png)

#### Metodo CLI: eliminare il gruppo

```text
sudo groupdel groupname
```

```text
getent group | grep groupname
```

## Conclusioni

In conclusione, questa guida vi ha fornito le conoscenze necessarie per gestire con successo gli account degli utenti e dei gruppi su Rocky Linux 9.4 utilizzando Cockpit. L'interfaccia grafica di Cockpit, facile da usare e basata sul web, rende l'esecuzione delle attività amministrative più accessibile ed efficiente, consentendo di sfruttare appieno le sue caratteristiche di facile utilizzo per una gestione fluida del sistema.

---

## REFERENZE

Per installare Cockpit: <https://ciq.com/blog/how-to-administer-rocky-linux-with-cockpit/>
