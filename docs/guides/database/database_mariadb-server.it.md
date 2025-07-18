---
title: Server di Database MariaDB
author: Steven Spencer
contributors: Ezequiel Bruni, William Perron, Ganna Zhyrnova, Joseph Brinkman
tested_with: 8.5, 8.6, 9.0, 9.2
tags:
  - database
  - mariadb
---

# Server di Database MariaDB

## Prerequisiti

- Un server Rocky Linux
- Conoscenza di un editor a riga di comando (in questo esempio si usa *vi*)
- Un livello di comfort elevato con l'immissione di comandi dalla riga di comando, la visualizzazione dei log e altri compiti generali di amministratore di sistema
- È utile la conoscenza dei database *mariadb-server*
- Eseguire tutti i comandi come root o con *sudo*

## Introduzione

Il *mariadb-server* e il suo client *mariadb* sono le alternative open source a *mysql-server* e *mysql* e condividono la struttura dei comandi. <em x-id=“3”>mariadb-server</em> è in esecuzione su molti server web, poiché è richiesto dal popolare [CMS Wordpress](https://wordpress.org/). Questo database, però, ha molti altri usi.

Se si desidera utilizzare questo insieme ad altri strumenti per il rafforzamento di un server web, consultare la guida [Apache Hardened Web Server](../web/apache_hardened_webserver/index.md).

## Installare `mariadb-server`

È necessario installare _mariadb-server_:

```bash
dnf install mariadb-server
```

## Proteggere `mariadb-server`

Per rafforzare la sicurezza di <em x-id=“3”>mariadb-server</em> è necessario eseguire uno script, ma prima è necessario abilitare e avviare mariadb:

```bash
systemctl enable --now mariadb
```

Quindi, eseguire questo comando:

```bash
mysql_secure_installation
```

!!! tip

    La versione di mariadb-server che viene abilitata per impostazione predefinita in Rocky Linux 8.5 è la 10.3.32. È possibile installare la versione 10.5.13 abilitando il modulo:

    ```bash
    dnf module enable mariadb:10.5
    ```


    E poi installare `mariadb`. A partire dalla versione 10.4.6 di MariaDB, sono disponibili comandi specifici per MariaDB che è possibile utilizzare al posto dei vecchi comandi con prefisso `mysql`. Questi includono il già citato `mysql_secure_installation`, che ora può essere richiamato con la versione MariaDB `mariadb-secure-installation`.

Viene visualizzata una finestra di dialogo:

```text
NOTE: RUNNING ALL PARTS OF THIS SCRIPT IS RECOMMENDED FOR ALL MariaDB
      SERVERS IN PRODUCTION USE!  PLEASE READ EACH STEP CAREFULLY!

In order to log into MariaDB to secure it, you will need the current
password for the root user.  If you have just installed MariaDB, and
you have not set the root password yet, the password will be blank,
so you should just press enter here.

Enter current password for root (enter for none):
```

Trattandosi di una nuova installazione, non è stata impostata alcuna password di root. Basta premere ++Invio++ qui.

La parte successiva del dialogo continua:

```text
OK, successfully used password, moving on...

Setting the root password ensures that nobody can log into the MariaDB
root user without the proper authorization.

Set root password? [Y/n]
```

È assolutamente necessario *impostare* una password di root. Ti consigliamo di stabilire quale dovrebbe essere e di annotarla in un gestore di password, in modo da poterla recuperare se necessario. Iniziare premendo ++enter++ per accettare il valore predefinito "Y". Questo farà apparire la finestra di dialogo della password:

```text
New password:
Re-enter new password:
```

Inserisci la password scelta e confermala inserendola nuovamente. Se l'operazione ha esito positivo, verrà visualizzata la seguente finestra di dialogo:

```text
Password updated successfully!
Reloading privilege tables..
 ... Success!
```

Il prossimo dialogo riguarda l'utente anonimo:

```text
By default, a MariaDB installation has an anonymous user, allowing anyone
to log into MariaDB without having to have a user account created for
them. This is intended only for testing, and to make the installation
go a bit smoother.  You should remove them before moving into a
production environment.

Remove anonymous users? [Y/n]
```

La risposta qui è "Y", quindi basta premere ++enter++ per accettare l'impostazione predefinita.

La finestra di dialogo passa alla sezione relativa all'autorizzazione dell'utente root ad accedere in remoto:

```text
... Success!

Normally, root should only be allowed to connect from 'localhost'.  This
ensures that someone cannot guess at the root password from the network.

Disallow root login remotely? [Y/n]
```

root dovrebbe essere necessario solo localmente sulla macchina. Quindi accettate anche questa impostazione predefinita premendo ++enter++.

La finestra di dialogo si sposta poi sul database 'test' che è installato automaticamente con _mariadb-server_:

```text
... Success!


By default, MariaDB comes with a database named 'test' that anyone can
access.  This is also intended only for testing, and should be removed
before moving into a production environment.

Remove test database and access to it? [Y/n]
```

Anche in questo caso, la risposta è quella predefinita, quindi basta premere ++enter++ per rimuoverla.

Infine, la finestra di dialogo chiede se si desidera ricaricare i privilegi:

```text
- Dropping test database...
 ... Success!
 - Removing privileges on test database...
 ... Success!

Reloading the privilege tables will ensure that all changes made so far
will take effect immediately.

Reload privilege tables now? [Y/n]
```

Ancora una volta, premere ++enter++ per eseguire questa operazione. Se tutto va bene, riceverai questo messaggio:

```text
 ... Success!

Cleaning up...

All done!  If you've completed all of the above steps, your MariaDB
installation should now be secure.

Thanks for using MariaDB!
```

MariaDB sarà ora pronto all'uso.

### Modifiche in Rocky 9.0

Rocky Linux 9.2 utilizza `mariadb-server-10.5.22` come versione predefinita di mariadb-server. A partire dalla versione 10.4.3, nel server viene automaticamente attivato un nuovo plugin che modifica la finestra di dialogo `mariadb-secure-installation`. Questo plugin è l'autenticazione `unix-socket`. [Questo articolo](https://mariadb.com/kb/en/authentication-plugin-unix-socket/) spiega bene la nuova funzione. Essenzialmente, l'uso dell'autenticazione unix-socket utilizza le credenziali dell'utente connesso per accedere al database. In questo modo, se l'utente root, ad esempio, accede e poi usa `mysqladmin` per creare o cancellare un database (o qualsiasi altra funzione), non è necessaria alcuna password per l'accesso. Lo stesso funziona con `mysql`. Ciò significa anche che non c'è una password da compromettere in remoto. Ciò dipende dalla sicurezza degli utenti impostati sul server per la protezione del database.

La seconda finestra di dialogo durante l'`mariadb-secure-installation`, dopo l'impostazione della password per l'utente amministrativo, è la seguente:

```text
Switch to unix_socket authentication Y/n
```

L'impostazione predefinita è "Y", ma anche se si risponde "n", con il plugin abilitato non viene richiesta una password per l'utente, almeno non dall'interfaccia della riga di comando. È possibile specificare una password o nessuna password ed entrambe funzionano:

```bash
mysql

MariaDB [(none)]>
```

```bash
mysql -p
Enter password:

MariaDB [(none)]>
```

Per ulteriori informazioni su questa funzione, consultare il link sopra riportato. Esiste un modo per disattivare questo plugin e tornare ad avere la password come campo obbligatorio, descritto in dettaglio nel link.

## Conclusione

Un server di database, come *mariadb-server*, può essere utilizzato per molti scopi. Data la popolarità del [CMS Wordpress](https://wordpress.org), è spesso presente sui server web. Prima di eseguire il database in produzione, tuttavia, è bene rafforzarne la sicurezza.
