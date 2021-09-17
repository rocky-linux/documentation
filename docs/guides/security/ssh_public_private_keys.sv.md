# SSH Publika och privata nycklar

## Förutsättningar

* En viss gnutta av bekvämligt att jobba från kommandoraden
* Rocky Linux servrar och/eller arbetsstationer med *openssh* installerat
    * Okej tekniskt, så kommer den här processen att fungera på vilket Linux system som helst med openssh installerat
* Valfritt: bekant med linux-fil och katalogbehörigheter

# Introduktion

SSH är ett protokoll som används för att komma åt en maskin från en annan, oftast via kommandoraden. med SSH, så kan du köra kommandon på fjärrdatorer och servrar, skicka filer, och generellt hantera allting du gör från en plats.

När du jobbar med flera Rocky Linux servrar på flera platser, eller om du bara försöker att spara lite tid för att snabbare få åtkomst till dessa servrar, så vill du använda SSH publika och privata nyckelpar. Nyckelpar gör det enklare att logga in i fjärrmaskiner och köra kommandon. 

Detta dokument kommer att vägleda dig genom processen för att skapa nycklarna och ställa in dina servrar för enkel åtkomst, med sagda nycklar.

### Processen för att generera nycklar

Dessa följande kommandon körs alla från kommandoraden på din Rocky Linux arbetsstation:

`ssh-keygen -t rsa`

Vilket kommer att visa följande:

```
Generating public/private rsa key pair.
Enter file in which to save the key (/root/.ssh/id_rsa):
```

Tryck på Enter för att acceptera standardplatsen. Därefter kommer systemet att visas:

`Enter passphrase (empty for no passphrase):`

Så tryck bara Enter här. Slutligen kommer den att be dig att ange lösenfrasen igen:

`Enter same passphrase again:`

Så tryck på Enter en sista gång.

Du ska nu ha ett RSA typ publikt och privat nyckelpar i din .ssh katalog:

```
ls -a .ssh/
.  ..  id_rsa  id_rsa.pub
```

Nu behöver vi skicka den publika nyckeln (id_rsa.pub) till varje maskin som vi vill att det ska gå att komma åt... men före vi gör det, så måste vi se till att vi kan använda SSH för att komma åt servern som vi kommer att skicka nyckeln till. I vårat exempel, så kommer vi att använda bara tre servrar. 

Du kan antingen komma åt dem via SSH med ett DNS-namn eller IP-adress, men i vårat exempel så kommer vi att använda DNS-namnet. Våra exempel servrar är webb, mail, och portal. För varje server, så kommer vi att försöka SSH in (nördar älskar att använda SSH som ett verb) och lämnar ett terminalfönster öppet för varje maskin:

`ssh -l root web.ourourdomain.com` 

Förutsatt att vi kan logga in utan problem på alla tre maskiner, så är nästa steg är att skicka ut våran publika nyckel till varje server:

`scp .ssh/id_rsa.pub root@web.ourourdomain.com:/root/` 

Vi upprepar detta steg på var och en av våra tre maskiner. 

På varje av dom öppna terminalfönstren, du borde du nu kunna se *id_rsa.pub* när du anger följande kommando:

`ls -a | grep id_rsa.pub` 

Om så är fallet, så är du nu redo att antingen skapa eller lägga till *authorized_keys* filen på i *.ssh* katalogen på varje server. På varje en av servrarna, ange detta kommando:

`ls -a .ssh` 

**Viktigt! Se till att du läser allt nedan noggrant. Om du inte är säker på om du kommer ha sönder någonting, så är det alltid bra att ta en säkerhetskopia av authorized_keys filen (om den existerar) på varje av maskinerna innan du fortsätter.**

Om det inte finns någon *authorized_keys* fil listad, då kommer vi skapa den genom att ange detta kommando medans vi är i våran _/root_ katalog:

`cat id_rsa.pub > .ssh/authorized_keys`

Om _authorized_keys_ existerar, då vill vi helt enkelt lägga till vår nya publika nyckel till de som redan finns där:

`cat id_rsa.pub >> .ssh/authorized_keys`

När nyckeln antingen har lagts till i _authorized_keys_, eller _authorized_keys_ filen har skapats, försök att använda SSH från din Rocky Linux-arbetsstation till servern igen. Du ska inte bli ombedd om att skriva in ett lösenord.

När du har verifierat att du kan SSHa in utan ett lösenord, ta bort id_rsa.pub filen från _/root_ katalogen på varje maskin. 

`rm id_rsa.pub`

### SSH Katalog och authorized_keys Säkerhet

På var och en av dina målmaskiner, se till att följande behörigheter tillämpas:

`chmod 700 .ssh/`
`chmod 600 .ssh/authorized_keys`



