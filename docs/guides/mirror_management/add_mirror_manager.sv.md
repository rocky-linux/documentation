---
title: Lägg till en publik spegel till Rocky's spegelhanterare
---

# Lägg till en publik spegel till Rocky's spegelhanterare

Rocky använder Fedora's spegelhanterare för att organisera gemenskapspeglar..

## Vad du behöver
* Ett konto på https://accounts.rockylinux.org/


## Skapa en sajt

Gå till Rockys Spegelhanterare här: https://mirrors.rockylinux.org/mirrormanager/

Efter en lyckad inloggning, så kommer din profil att synas uppe till höger. Välj rullgardinsmenyn och klicka sedan på "Mina sajter".

En ny sida kommer att laddas som listar alla sajter under ditt konto. Första gången kommer sidan vara tom. Klicka på "Registrera en ny sajt".

En ny sida kommer att ladda med ett viktigt uttalande om exportöverensstämmelse att läsa. Fyll sedan i följande information:
* "Sajtnamn"
* "Sajtlösenord" - används av report_mirrors skriptet, du kan välja vilket lösenord du vill ha
* "Organisation URL" - Företag/Skola/Organisation  URL t.ex. https://rockylinux.org/
* "Privat" - Om du markerar den här rutan döljs denna sajt för allmän användning.
* "Användaraktiv" - Avmarkera den här rutan för att tillfälligt inaktivera den här sajten, den tas bort från offentliga listor.
* "Alla sajta kan hämta från mig??" - Aktiverar alla spegelsajter att hämta från mig utan att uttryckligen lägga till dem i min lista.
* "Kommentarer till nedströms sajtadmins"

När du klickar på "Skicka" kommer du tillbaka till huvudspegelsidan.

## Konfigurera din sajt

Från huvudspegelsidan väljer du rullgardinsmenyn och klickar sedan på "Mina sajter".

Kontosidan laddas och webbplatsen bör listas. Klicka på den för att gå till informationssidan. 

Alla alternativ från den sista sektionen listas igen. Längst ner på sidan finns tre alternativ: Administratörer, Värdar, och Ta bort sajt. Klicka på "Värdar [lägg till]".

## Skapa en ny värd

Fyll i följande alternativ som är lämpliga för sajten:
* "Värdnamn" - kräver: FQDN för servern som det ser ut för en offentlig slutanvändare
* "Användaraktiv" - Avmarkera den här rutan för att tillfälligt inaktivera den här värden, den tas bort från offentliga listor.
* "Land" - krävs: 2-bokstävers ISO Landskod
* "Bandbredd" - krävs: heltal megabit/sek, hur mycket bandbredd denna värd kan tjäna
* "Privat" - t.ex. inte tillgänglig för allmänheten, en intern privat spegel
* "Internet2" - på Internet2 
* "Internet2 klienter" - serverar Internet2-klienter, även om de är privata
* "ASN - Autonomous System Nummer, används i BGP routingtabeller.
* "ASN Klienter? - Servera alla klienter från samma ASN. Används för ISPs, företag, eller skolor, inte personliga nätverk.
* "Robot email" - e-postadress, som kommer att få meddelanden om uppdateringar av uppströmsinnehåll
* "Kommentar" - text, allt annat du vill att en allmän slutanvändare ska veta om din spegel
* "Max anslutningar" - Maximala parallella nedladdningsanslutningar per klient, föreslagna via metalinks.

Klicka "Skapa" och du kommer att bli omdirigerad tillbaka till informationssidan för värden.

## Uppdatera värden

Längst ner på informationssidan, alternativet för "Värd" ska nu visa värdtiteln bredvid den. Klicka på namnet för att ladda värdsidan. Alla samma alternativ från föregående steg listas igen. Det finns nya alternativ längst ner.

* "Sajt-lokala nätblock":  Nätblock används för att försöka att vägleda en slutanvändare till en platsspecifik spegel. För exempel, ett universitet kan lista sina nätblock, och spegellistan CGI skulle returnera den universitets specifika spegeln istället för en landets-lokala spegel. Format är en av 18.0.0.0/255.0.0.0, 18.0.0.0/8, en IPv6 prefix/längd, eller ett DNS värdnamn. Värden måste vara publika IP-adresser (inga RFC1918-adresser i privat utrymme). 

* "Peer ASNs":  Peer ASNs används för att vägleda en slutanvändare i närliggande nätverk till vår spegel. t.ex., ett universitet kan lista deras peer ASNs, och spegellistan CGI kommer skicka den universitets-lokala spegeln snarare än en lands-lokal spegel.. Du måste vara i MirrorManager-administratörs gruppen för att skapa nya poster här.

* "Land tillåtna":  Vissa speglar måste begränsa sig till att endast betjäna slutanvändare från deras land. Om du är en av dessa, lista 2-bokstävers ISOkoder för dom länderna du vill tillåta slutanvändare att vara från. spegellistan CGI kommer att acceptera detta. 

* "Paketkategorier ":  Värdar har flera olika kategorier av programvara. Exempel på Fedora-kategorier inkluderar Fedora och Fedora arkiv 

Klicka på "[lägg till]" länken under "Paketkategorier".

### Paketkategorier

För kategorin, välj "Rocky Linux" sen klicka på "Skapa" för att ladda URL sidan. Klicka sedan på "[lägg till]" för att ladda "Lägg till värdkategori URL" sidan. Det finns ett alternativ. Upprepa efter behov för vart och ett av de protokoll som stöds av speglarna.

* "URL" - URL (rsync, https, http) pekar på den översta katalogen

Exempel:
* `http://rocky.example.com`
* `https://rocky.example.com`
* `rsync://rocky.example.com`


## Sammanfattning

När informationen är ifylld, så ska din sajt dyka upp på spegellistan så snart nästa spegeluppdatering sker.

Synkronisera din spegel från rsync://msync.rockylinux.org
