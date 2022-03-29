---
title: brandvägg för nybörjare
author: Ezequiel Bruni
contributors: Steven Spencer
update: 16-Feb-2022
---

# `brandvägg` för nybörjare

## Introduktion

För länge sedan var jag lite nybörjare datoranvändare som hörde att ha en brandvägg var *tänkt* att vara super bra. Det skulle låta mig bestämma vad som kom in, och vad fick ut av min dator, eller hur? Men det verkade mest att stoppa mina videospel från att komma åt internet; Jag var *inte* en lycklig camper.

Naturligtvis, om du är här, har du förmodligen en bättre uppfattning om vad en brandvägg är och vad den gör än jag gjorde. Men om din brandvägg erfarenhet innebär att tala om för Windows Defender att ja, för kärleken till allt som är heligt, din nya app är tillåten att använda internet, oroa dig inte. Det står "för nybörjare" upp på toppen, jag har dig.

Med andra ord bör mina nördar vara medvetna om att det kommer att finnas en hel del förklaringar till inkomst.

Så låt oss tala om vad vi är här för. `brandvägg` är standard-brandväggsappen paketerad med Rocky Linux, och den är utformad för att vara ganska enkel att använda. Du behöver bara veta lite om hur brandväggar fungerar, och inte vara rädd för att använda kommandoraden.

Här får du lära dig:

* Själva grunderna i hur `brandvägg` fungerar
* Hur du använder `brandvägg` för att begränsa eller tillåta inkommande och utgående anslutningar
* Hur man tillåter endast personer från vissa IP-adresser eller platser att logga in på din maskin på distans
* Hur man hanterar några `brandvägg`-specifika funktioner som Zoner.

Detta är *inte* avsett att vara en komplett eller uttömmande guide.

### En anteckning om att använda kommandoraden för att hantera din brandvägg

Väl... det *finns* grafiska brandväggskonfigurationsalternativ. På skrivbordet finns `brandvägg-config` som kan installeras från repos, och på servrar kan du [installera Cockpit](https://linoxide.com/install-cockpit-on-almalinux-or-rocky-linux/) för att hjälpa dig att hantera brandväggar och ett helt gäng andra saker. **Jag kommer dock att lära dig kommandoradssättet att göra saker i den här handledningen av ett par skäl:**

1. Om du kör en server, kommer du att använda kommandoraden för de flesta av dessa saker ändå. Massor av övningar och guider för Rocky server kommer att ge kommandoraden instruktioner för brandväggshantering, och det är bäst att du förstår dessa instruktioner, snarare än att bara kopiera och klistra in vad du än ser.
2. Att förstå hur `brandvägg` kommandon fungerar kan hjälpa dig att bättre förstå hur brandväggsprogrammet fungerar. Du kan ta samma principer som du lär dig här, och har en bättre uppfattning om vad du gör om du väljer att använda ett grafiskt gränssnitt i framtiden.

## Förutsättningar och antaganden
Du behöver.

* En Rocky Linux-maskin av alla slag, lokal eller fjärrstyrd, fysisk eller virtuell
* Tillgång till terminalen, och en vilja att använda den
* Du behöver root-åtkomst, eller åtminstone möjligheten att använda `sudo` på ditt användarkonto. För enkelhetens skull antar jag att alla kommandon körs som rot.
* En grundläggande förståelse för SSH skulle inte skada för hantering av fjärrmaskiner.

## Grundläggande användning

### Systemtjänstkommandon

`brandvägg` körs som en tjänst på din maskin. Det börjar när maskinen gör det, eller det borde. Om `brandvägg` av någon anledning inte redan är aktiverat på din maskin, kan du göra det med ett enkelt kommando:

```bash
systemctl aktivera --nu brandvägg
```

Flaggan `--now` startar tjänsten så snart den är aktiverad, och låt dig hoppa över `systemctl starta brandväggen` steget.

Som med alla tjänster på Rocky Linux kan du kontrollera om brandväggen körs med:

```bash
brandvägg systemctl status
```

Att stoppa det helt och hållet:

```bash
systemctl stoppa brandvägg
```

Och för att ge tjänsten en hård omstart:

```bash
systemctl starta om brandvägg
```

### Grundläggande `brandvägg` konfigurations- och hanteringskommandon

`brandvägg` är konfigurerad med `brandvägg-cmd` kommandot. Du kan till exempel kontrollera statusen för `brandvägg` med:

```bash
brandvägg-cmd --stat
```

Efter varje *permanent* ändring av din brandvägg, måste du ladda om den för att se ändringarna. Du kan ge brandväggskonfigurationerna en "mjuk omstart" med:

```bash
brandvägg-cmd --ladda om
```

!!! Anteckning

    Om du laddar om dina konfigurationer som inte har blivit permanenta, försvinner de på dig.

Du kan se alla dina konfigurationer och inställningar samtidigt med:

```bash
brandvägg-cmd --list-all
```

Det kommandot kommer att skriva ut något som ser ut så här:

```bash
offentliga (aktiva)
  mål: standard
  icmp-block-inversion: inga
  gränssnitt: enp9s0
  källor:
  tjänster: ssh
  portar:
  protokoll:
  framåt: nej
  maskerad: nej
  framåt-portar:
  käll-portar:
  icmp-blocks:
  rika regler:
```

### Sparar dina ändringar

!!! Varning "Varning: Allvarligt, läs nästa bit."

    Som standard är alla ändringar i `firewalld`s konfiguration tillfälliga. Om du startar om hela `firewalld`-tjänsten eller startar om din maskin, Ingen av dina ändringar i brandväggen kommer att sparas om du inte gör en av två mycket specifika saker.

Det är bäst att testa alla dina ändringar en efter en, ladda om din brandvägg konfiguration när du går. På det sättet, om du av misstag låsa dig själv ur något, Du kan starta om tjänsten (eller maskinen), alla dessa ändringar försvinner som nämnts ovan.

Men när du har en fungerande konfiguration, kan du spara dina ändringar permanent med:

```bash
brandvägg-cmd --runtime-to-permanent
```

Men om du är helt säker på vad du gör, och bara vill lägga till regeln och gå vidare med ditt liv, du kan lägga till flaggan `--permanent` till valfritt konfigurationskommando:

```bash
brandvägg-cmd - permanent [resten av ditt kommando]
```

## Hantera zoner

Innan något annat måste jag förklara zoner. Zoner är en funktion som i grunden gör att du kan definiera olika uppsättningar av regler för olika situationer. Zoner är en stor del av `brandvägg` så det lönar sig att förstå hur de fungerar.

Om din maskin har flera sätt att ansluta till olika nätverk (t.ex. Ethernet och WiFi) kan du bestämma att en anslutning är mer betrodd än den andra. Du kan ställa in din Ethernet-anslutning till den "betrodda" zonen om den bara är ansluten till ett lokalt nätverk som du byggt, och sätta WiFi (som kan vara ansluten till internet) i den "offentliga" zonen med strängare begränsningar.

!!! Anteckning

    En zon kan *endast* vara i ett aktivt tillstånd om den har något av dessa två förutsättningar:

    1. Zonen är tilldelad till ett nätverksgränssnitt
    2. Zonen är tilldelad källa IP-adresser eller nätverksintervall. (Mer om detta nedan)

Standardzoner inkluderar följande (jag har tagit denna förklaring från [DigitalOceans guide till `brandvägg`](https://www.digitalocean.com/community/tutorials/how-to-set-up-a-firewall-using-firewalld-on-centos-8), som du också bör läsa):

> **droppe:** Den lägsta nivån av tillit. Alla inkommande anslutningar släpps utan svar och endast utgående anslutningar är möjliga.

> **block:** Liknar ovan, men istället för att helt enkelt släppa anslutningar, avvisas inkommande förfrågningar med ett icmp-host-förbjudet eller icmp6-adm-förbjudet meddelande.

> **public:** Representerar offentliga, opålitliga nätverk. Du litar inte på andra datorer men kan tillåta valda inkommande anslutningar från fall till fall. externt: Externa nätverk i händelse av att du använder brandväggen som port. Det är konfigurerat för NAT maskering så att ditt interna nätverk förblir privat men kan nås.

> **internt:** Den andra sidan av den yttre zonen, som används för den inre delen av en gateway. Datorerna är ganska pålitliga och vissa ytterligare tjänster finns tillgängliga.

> **dmz:** Används för datorer som ligger i en DMZ (isolerade datorer som inte har tillgång till resten av ditt nätverk). Endast vissa inkommande anslutningar är tillåtna.

> **arbete:** Används för arbetsmaskiner. Lita på de flesta datorer i nätverket. Några fler tjänster kan tillåtas.

> **hem:** En hemmiljö. Det innebär i allmänhet att du litar på de flesta andra datorer och att några fler tjänster kommer att accepteras.

> **litade på:** Lita på alla maskiner i nätverket. Den mest öppna av de tillgängliga alternativen och bör användas sparsamt.

Okej, så några av dessa förklaringar blir komplicerade, men ärligt? Den genomsnittliga nybörjaren kan få med att förstå "betrodd", "hem", och "offentlig", och när man ska använda vilken.

### Zonhanteringskommandon

Kör för att se din standardzon:

```bash
brandvägg-cmd --get-default-zone
```

För att se vilka zoner som är aktiva och göra saker, köra:

```bash
brandvägg-cmd --get-active-zoner
```

!!! Notera att en del av detta kan ha gjorts för dig."

    Om du kör Rocky Linux på en VPS, är det troligt att en grundläggande konfiguration har konfigurerats för dig. Specifikt bör du kunna komma åt servern via SSH, och nätverksgränssnittet kommer redan att ha lagts till den "offentliga" zonen.

För att ändra standardzonen:

```bash
brandvägg-cmd --set-default-zone [your-zone]
```

Lägga till ett nätverksgränssnitt i en zon:

```bash
firewall-cmd --zone=[your-zone] --add-interface=[your-network-device]
```

Ändra zonen i ett nätverksgränssnitt:

```bash
brandvägg-cmd --zone=[your-zone] --change-interface=[your-network-device]
```

Ta bort ett gränssnitt från en zon helt:

```bash
firewall-cmd --zone=[your-zone] --remove-interface=[your-network-device]
```

För att göra din egen helt nya zon med en helt egen uppsättning regler, och för att kontrollera att den har lagts till ordentligt:

```bash
brandvägg-cmd --new-zone=[your-new-zone]
brandvägg-cmd --get-zones
```

## Hantera portar

För de oinitierade är portarna (i detta sammanhang) bara virtuella ändpunkter där datorer ansluter till varandra så att de kan skicka information fram och tillbaka. Tänk på dem som fysiska Ethernet eller USB-portar på din dator, men osynliga, och du kan ha upp till 65.535 av dem alla på en gång.

Det skulle jag inte, men ni kan.

Varje port definieras av ett nummer, och vissa hamnar är reserverade för specifika tjänster och typer av information. Om du någonsin har arbetat med webbservrar för att bygga en webbplats, till exempel, kan du vara bekant med port 80 och port 443. Dessa portar möjliggör överföring av webbsidedata.

Specifikt, port 80 tillåter överföring av data via Hypertext Transfer Protocol (HTTP), och port 443 är reserverad för Hypertext Transfer Protocol Secure (HTTPS) data. *

Port 22 är reserverad för Secure Shell Protocol (SSH) som låter dig logga in och hantera andra maskiner via kommandoraden (se [vår korta guide](ssh_public_private_keys.md) på suject). helt ny fjärrserver kan bara tillåta anslutningar över port 22 för SSH, och inget annat.

Andra exempel är FTP (portar 20 och 21), SSH (port 22), och så många fler. Du kan också ställa in anpassade portar som ska användas av nya appar som du kan installera, som inte redan har ett standardnummer.

!!! Notera "Obs: Du bör inte använda portar för allt."

    För saker som SSH, HTTP/S, FTP och mer, är det faktiskt rekommenderat att lägga till dem i din brandväggszon som *tjänster*, och inte som portnummer. Jag ska visa dig hur det fungerar nedan. Som sagt, du behöver fortfarande veta hur man öppnar portar manuellt.

\* För absolut nybörjare är HTTPS i princip (mer eller mindre) samma som HTTP, men krypterad.

### Porthanteringskommandon

För det här avsnittet använder jag `--zone=public`... och portar 9001 som ett slumpmässigt exempel, eftersom det är över 9000.

För att se alla öppna portar:

```bash
brandvägg-cmd --list-portar
```

För att lägga till en port till din brandväggszon (öppna den för användning), kör du bara detta kommando:

```bash
brandvägg-cmd --zone=public --add-port=9001/tcp
```

!!! Anteckning

    Om den `/tcp`-biten:
    
    Den där `/tcp`-biten i slutet talar om för brandväggen att anslutningar kommer in över överföringskontrollprotokollet, vilket är vad du kommer att använda för de flesta server-och-hem-relaterade grejer.
    
    Alternativ som UDP är för felsökning, eller andra mycket specifika typer av saker som uppriktigt sagt inte omfattas av den här guiden. Se dokumentationen för vilken app eller tjänst du vill öppna en port för.

För att ta bort en port, vänd bara kommandot med en enda ordändring:

```bash
brandvägg-cmd --zone=offentlig --remove-port=9001/tcp
```

## Hantera tjänster

Tjänster, som ni kanske tror, är ganska standardiserade program som körs på din dator. `brandvägg` är satt upp så att det bara kan öppna vägen för de vanligaste tjänsterna när du behöver göra det.

Detta är det bästa sättet att öppna hamnarna för dessa gemensamma tjänster, och en hel del mer:

* HTTP och HTTPS: för webbservrar
* FTP: För att flytta filer fram och tillbaka (gammaldags sätt)
* SSH: För att styra fjärrmaskiner och flytta filer bacck och framåt det nya sättet
* Samba: För att dela filer med Windows-maskiner

!!! Varning

    **Ta aldrig bort SSH-tjänsten från en fjärrservers brandvägg!**
    
    Kom ihåg att SSH är vad du använder för att logga in på din server. Om du inte har ett annat sätt att komma åt den fysiska servern, eller dess skal (dvs via. en kontrollpanel som tillhandahålls av värden), ta bort SSH-tjänsten kommer att låsa dig permanent.
    
    Du behöver antingen kontakta supporten för att få tillbaka din åtkomst eller installera om operativsystemet helt och hållet.

## Service Management-kommandon

För att se en lista över alla tjänster som du kan lägga till i din brandvägg, köra:

```bash
brandvägg-cmd --get-services
```

För att se vilka tjänster du för närvarande har aktiv på din brandvägg, använd:

```bash
brandvägg-cmd --list-services
```

För att öppna en tjänst i din brandvägg (t.ex. HTTP i den offentliga zonen), använd:

```bash
firewall-cmd --zone=public --add-service=http
```

För att ta bort/stänga en tjänst på din brandvägg, ändra bara ett ord igen:

```bash
brandvägg-cmd --zone=public --remove-service=http
```

!!! Notera att du kan lägga till dina egna tjänster"

    Och anpassa heck ur dem också. Det är dock ett ämne som blir lite komplext. Bekanta dig först med `brandvägg` och gå därifrån.

## Begränsa åtkomst

Låt oss säga att du har en server, och du vill bara inte göra det offentligt. om du vill definiera bara vem som får komma åt det via SSH, eller visa några privata webbsidor/appar, kan du göra det.

Det finns ett par metoder för att åstadkomma detta. För det första, för en mer låst server, kan du välja en av de mer restriktiva zonerna, tilldela din nätverksenhet till det, lägg till SSH-tjänsten till den som visas ovan, och sedan vitlista din egen publika IP-adress såhär:

```bash
firewall-cmd --permanent --zone=trusted --add-source=192.168.1.0 [< sätt in din IP här]
```

Du kan göra det en rad IP-adresser genom att lägga till ett högre antal i slutet som så:

```bash
firewall-cmd --permanent --zone=trusted --add-source=192.168.1.0/24 [< sätt in din IP här]
```

Återigen, ändra bara `--add-source` till `--remove-source` för att ändra processen.

Men om du hanterar en fjärrserver med en webbplats på den som måste vara offentlig, och ändå bara vill öppna upp SSH för en IP-adress eller ett litet utbud av dem, har du ett par alternativ. I båda dessa exempel är det enda nätverksgränssnittet tilldelat den offentliga zonen.

Först kan du använda en "rik regel" till din offentliga zon, och det skulle se ut ungefär så här:

```bash
# firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" source address="192.168.1.0/24" service name="ssh" accept"
```

När väl den rika regeln är på plats, *gör inte* reglerna permanenta ännu. Ta först bort SSH-tjänsten från konfigurationen för offentlig zon och testa din anslutning för att se till att du fortfarande kan komma åt servern via SSH.

Din konfiguration ska nu se ut så här:

```bash
your@server ~# firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: wlp3s0
  sources:
  services: cockpit dhcpv6-client
  ports: 80/tcp 443/tcp
  protokoll:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules
        rule family="ipv4" source address="192. 68.1.0/24" servicenamn = "ssh" acceptera
```


För det andra kan man använda två olika zoner åt gången. Om du har ditt gränssnitt bundet till den offentliga zonen, du kan aktivera en andra zon (den "betrodda" zonen till exempel) genom att lägga till en källa IP eller IP-intervall till den som visas ovan. Lägg sedan till SSH-tjänsten till den betrodda zonen, och ta bort den från den offentliga zonen.

När du är klar bör utdata se ut lite så här:

```bash
ditt@server ~# firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: wlp3s0
  källor:
  tjänster: cockpit dhcpv6-client
  portar: 80/tcp 443/tcp
  protokoll:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rika regler:
din@server ~# firewall-cmd --list-all --zone=trusted
trusted (active)
  target: default
  icmp-block-inversion: no
  interfaces:
  källor: 192. 68.0.0/24
  tjänster: ssh
  portar:
  protokoll:
  framåt: nej
  maskerad: nej
  framåtriktade portar:
  källportar:
  icmp-block:
  rika regler:
```

Om du blir utlåst, starta om servern (de flesta VPS kontrollpaneler har ett alternativ för detta) och försök igen.

!!! Varning

    Dessa tekniker fungerar bara om du har en statisk IP-adress.
    
    Om du har fastnat med en internetleverantör som ändrar din IP-adress varje gång ditt modem startar om, Använd inte dessa regler (åtminstone inte för SSH) förrän du har en rättelse för det. Du kommer att låsa dig själv från din server
    
    Antingen uppgradera din internetplan/leverantör, eller få en VPN som ger dig en dedikerad IP-adress, och *aldrig, någonsin* förlorar den.
    
    Under tiden, [installera och konfigurera fail2ban](https://wiki.crowncloud.net/?How_to_Install_Fail2Ban_on_RockyLinux_8), som kan hjälpa till att skära ner på brute force-attacker.
    
    Uppenbarligen på ett lokalt nätverk som du styr (och där du kan ställa in alla maskiners IP-adress manuellt), du kan använda alla dessa regler så mycket du vill.

## Slutgiltiga anteckningar

Detta är långt ifrån en uttömmande guide, och du kan lära dig en hel del mer med [officiella `brandvägg` dokumentation](https://firewalld.org/documentation/). Det finns också praktiska app-specifika guider över hela internet som visar dig hur du ställer in din brandvägg för de specifika apparna.

För dig fans av `iptables` (om du har kommit så här långt... , [vi har en guide](firewalld.md) som beskriver några av skillnaderna i hur `brandvägg` och `iptables` fungerar. Den guiden kan hjälpa dig att räkna ut om du vill stanna med `brandvägg` eller gå tillbaka till De gamla vägarna<sup>(TM)</sup>. Det finns något att säga till The Old Ways<sup>(TM)</sup>, i detta fall.

## Slutsats

Och det är `brandvägg` med så få ord som jag kunde hantera samtidigt som jag fortfarande förklarar alla grunder. Ta det långsamt, experimentera noggrant, och gör inga regler permanenta förrän du är säker på att de fungerar.

Och du vet, ha kul. När du har grunderna ner, faktiskt inrätta en anständig, kan fungerande brandvägg ta 5-10 minuter.
