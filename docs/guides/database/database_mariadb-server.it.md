# Server di Database MariaDB

## Prerequisiti

* Un server Rocky Linux
* Competenza con un editor a riga di comando (stiamo usando _vi_ in questo esempio)
* Un livello di comfort elevato con l'emissione di comandi dalla riga di comando, la visualizzazione dei log e altri compiti generali di amministratore di sistema
* Una comprensione dei database _mariadb-server_ è utile
* Tutti i comandi sono eseguiti come utente root o _sudo_

## Introduzione

Il _mariadb-server_ e il suo client _mariadb_ sono le alternative open source a _mysql-server_ e _mysql_, e condividono la struttura dei comandi. _mariadb-server_ può essere trovato in esecuzione su molti server web, dovuto al popolare [CMS Wordpress](https://wordpress.org/) che lo richiede. Questo database, però, ha molti altri usi.

Se volete usare questo insieme ad altri strumenti per rafforzare un server web, fate riferimento alla guida [Irrobustire il Webserver Apache](../web/apache_hardened_webserver/index.md).

## Installare mariadb-server

Dobbiamo installare _mariadb-server_:

`dnf install mariadb-server`

## Proteggere mariadb-server

Per rafforzare la sicurezza di _mariadb-server_ abbiamo bisogno di eseguire uno script, ma prima di farlo, dobbiamo abilitare e avviare mariadb:

`systemctl enable mariadb`

E poi:

`systemctl start mariadb`

Poi, eseguite questo comando:

`mysql_secure_installation`

Questo porta a una finestra di dialogo:

```
NOTE: RUNNING ALL PARTS OF THIS SCRIPT IS RECOMMENDED FOR ALL MariaDB
      SERVERS IN PRODUCTION USE!  PLEASE READ EACH STEP CAREFULLY!

In order to log into MariaDB to secure it, we'll need the current
password for the root user.  If you've just installed MariaDB, and
you haven't set the root password yet, the password will be blank,
so you should just press enter here.

Enter current password for root (enter for none): 
```

Poiché questa è una nuova installazione, non c'è una password di root impostata. Quindi basta premere invio qui.

La parte successiva del dialogo continua:

```
OK, successfully used password, moving on...

Setting the root password ensures that nobody can log into the MariaDB
root user without the proper authorisation.

Set root password? [Y/n] 
```

È' assolutamente _necessario_ avere una password di root impostata. Dovrete capire cosa dovrebbe essere e documentarlo in un gestore di password da qualche parte in modo da poterlo richiamare se necessario. Iniziate premendo 'Enter' per accettare il valore predefinito "Y". Questo farà apparire la finestra di dialogo della password:

```
New password: 
Re-enter new password:
```

Inserisci la password scelta e poi confermala inserendola di nuovo. Se questo ha successo, otterrete la seguente finestra di dialogo:

```
Password updated successfully!
Reloading privilege tables..
 ... Success!
```

Il prossimo dialogo riguarda l'utente anonimo:

```
By default, a MariaDB installation has an anonymous user, allowing anyone
to log into MariaDB without having to have a user account created for
them.  This is intended only for testing, and to make the installation
go a bit smoother.  You should remove them before moving into a
production environment.

Remove anonymous users? [Y/n] 
```

La risposta qui è "Y", quindi basta premere 'Invio' per accettare l'impostazione predefinita.

La finestra di dialogo procede alla sezione che si occupa di permettere all'utente root di accedere da remoto:

```
... Success!

Normally, root should only be allowed to connect from 'localhost'.  This
ensures that someone cannot guess at the root password from the network.

Disallow root login remotely? [Y/n]
```

root dovrebbe essere necessario solo localmente sulla macchina. Quindi accettate anche questo default premendo 'Invio'.

La finestra di dialogo si sposta poi sul database 'test' che è installato automaticamente con _mariadb-server_:

```
... Success!


By default, MariaDB comes with a database named 'test' that anyone can
access.  This is also intended only for testing, and should be removed
before moving into a production environment.

Remove test database and access to it? [Y/n] 
```

Di nuovo, la risposta qui è quella predefinita, quindi basta premere 'Invio' per rimuoverla.

Infine, la finestra di dialogo ti chiede se vuoi ricaricare i privilegi:

```
- Dropping test database...
 ... Success!
 - Removing privileges on test database...
 ... Success!

Reloading the privilege tables will ensure that all changes made so far
will take effect immediately.

Reload privilege tables now? [Y/n] 
```

Anche in questo caso, basta premere 'Invio' per farlo. Se tutto va bene, dovreste ricevere questo messaggio:

```
 ... Success!

Cleaning up...

All done!  If you've completed all of the above steps, your MariaDB
installation should now be secure.

Thanks for using MariaDB!
```

MariaDB dovrebbe ora essere pronto all'uso.

## Conclusione

Un server di database, come _mariadb-server_, può essere usato per molti scopi. A causa della popolarità del CMS Wordpress, si trova spesso sui server web. Prima di eseguire il database in produzione, tuttavia, è una buona idea rafforzare la sua sicurezza. 

