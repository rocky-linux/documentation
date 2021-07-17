# Rocky Linux - Clau SSH Pública i Privada

## Requisits

* Cert nivell de comoditat operant des de la línia de comandes
* Servidors Linux i estacions de treball amb *openssh* instal·lat
    * D'acord, tècnicament, aquest procés podria funcionar amb qualsevol sistema Linux amb openssh instal·lat.
* Opcional: familiaritat amb els permisos d'arxius i directoris de linux

# Introducció

SSH és un protocol emprat per accedir a una màquina des d'una altra, normalment a través de la línia de comandes. Amb SSH, pots executar comandes en ordinadors i servidors remots, enviar arxius i, en general, gestionar tot el que fas des d'un sol lloc.

Quan estàs treballant amb diversos servidors Rocky Linux en múltiples ubicacions, o si simplement estàs tractant d'estalviar una mica de temps accedint en aquests servidors, voldràs utilitzar un parell de claus públiques i privades SSH. Aquest parell de claus bàsicament faciliten l'accés a màquines remotes i l'execució de comandes.

Aquest document el guiarà a través del procés de creació de les claus i la configuració dels seus servidors per un fàcil accés, amb aquestes claus.

### Procediment per a la generació de claus

Les següents comandes s'executen totes des de la línia de comandes a la seva estació de treball Rocky Linux:

`ssh-keygen -t rsa`

Que mostrarà el següent:

```
Generating public/private rsa key pair.
Enter file in which to save the key (/root/.ssh/id_rsa):
```

Premi Enter per acceptar la ubicació per defecte. A continuació el sistema mostrarà:

`Enter passphrase (empty for no passphrase):`

Per tant, només has de prémer Enter aquí. Per últim, li demanarà que torni a introduir la frase de contrasenya:

`Enter same passphrase again:`

Així que premi Enter una última vegada.

Ara hauries de tenir un parell de claus públiques i privades de tipus RSA en el teu directori .ssh:

```
ls -a .ssh/
.  ..  id_rsa  id_rsa.pub
```

Ara hem d'enviar la clau pública (id_rsa.pub) a cada màquina a la qual volem accedir... però abans de fer-ho, hem d'assegurar-nos que podem accedir por SSH als servidors als quals hem d'enviar la clau. Pel nostre exemple, utilitzarem només tres servidors.

Pots accedir a ells a través de SSH amb un nom DNS o una adreça IP, però pel nostre exemple utilitzarem el nom DNS. Els nostres servidors d'exemple son web, correu i portal. Per cada servidor, intentarem entrar per SSH (als nerds els encanta usar SSH com a verb) i deixarem una finestra de terminal oberta per cada màquina:

`ssh -l root web.ourourdomain.com` 

Suposant que podem iniciar sessió sense problemes a les tres màquines, el següent pas és enviar la nostra calu pública a cada servidor:

`scp .ssh/id_rsa.pub root@web.ourourdomain.com:/root/` 

Repeteixi aquest pas amb cada una de les nostres tres màquines. 

En cada una de les finestres de terminal obertes, hem de poder veure *id_rsa.pub* en introduir la següent comanda:

`ls -a | grep id_rsa.pub` 

Si és així, ara estem llestos per crear o afegir l'arxiu *authorized_keys* dins el directori *.ssh* de cada servidor. A cada un dels servidors, introdueixi aquesta comanda:

`ls -a .ssh` 

**Important! Assegurat de llegir curosament tot el que s'indica a continuació. Si no estàs segur de malmetre quelcom, llavors millor abans fes una còpia de seguretat d'authorized_keys (si existeix) en cada una de les màquines abans de continuar.**

Si no hi ha un arxiu *authorized_keys* a la llista, aleshores el crearem introduint aquesta comanda mentre estem en el nostre directori _/root_:

`cat id_rsa.pub > .ssh/authorized_keys`

Si _authorized_keys_ existeix, aleshores simplement voldrem afegir la nostre nova clau pública a les que ja hi són:

`cat id_rsa.pub >> .ssh/authorized_keys`

Una vegada que la clau ha sigut afegida a _authorized_keys_, o l'arxiu _authorized_keys_ a sigut creat, intenti SSH des de la seva estació de treball Rocky Linux al servidor de nou. No hauria de demanar-li una contrasenya.

Una vegada que hagi verificat que pot accedir per SSH sense contrasenya, elimini l'arxiu id_rsa.pub del directori _/root_ de cada màquina.

`rm id_rsa.pub`

### SSH Directory and authorized_keys Security

En cadascun dels seus equips de destí, asseguris de què s'apliquen els següents permisos:

`chmod 700 .ssh/`
`chmod 600 .ssh/authorized_keys`
