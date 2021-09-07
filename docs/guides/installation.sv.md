---
title: Installera Rocky Linux
---

# Installera Rocky Linux

Denna guide går igenom i detalj stegen för att installera en 64-bitars version av rocky Linux distribution på ett fristående system.

****
Vi kommer att utföra en server klass installation i detta kapitel genom att använda en oprativsystems installationsavbild nerladdad från rocky projektets webbplats. Vi kommer att tackla installationen och anpassade steg i följande avsnitt.
****

## OS förutsättningar för installation

Först, så behöver du ladda ner ISO-avbilden för Rocky som vi kommer att installera.

Den senaste ISO-avbilden för den version av Rocky som vi kommer att använda för denna installation kan laddas ner härifrån:

```
https://www.rockylinux.org/download/

```

För att ladda ner ISO-avbilden direkt från en terminal skriv:

```
$ wget https://download.rockylinux.org/pub/rocky/8.4/isos/x86_64/Rocky-8.4-x86_64-minimal.iso
```

Rocky ISOs är namngavna efter följande konvention:

```
Rocky-<MAJOR#>.<MINOR#>.<ARCH>-<VARIANT>.iso
```

t.ex. `Rocky-8.4-x86_64-minimal.iso`

!!! Note "Notera"
    Rocky projektets webbplats har en lista på flera speglar som ligger över hela världen. När det är möjligt, så ska du välja en spegel som är geografiskt närmast dig. Listan över officella speglar kan hittas [här](https://mirrors.rockylinux.org/mirrormanager/mirrors).

## Verifiera installations ISO

Om du har laddat hem Rocky ISO-avbilden/avbilder på en existerande Linux distribution, så kan du använda `sha256sum` verktyget för att verifiera  att filen/filerna du har laddat ner inte är skadade på något sätt. Vi visar ett exempel på hur man verifierar sha256sum av `Rocky-8.4-x86_64-minimal.iso`.

Första ladda ner filen som innehåller dom officiella kontrollsummorna för tillgängliga ISO-avbilder. Medan du fortfarande är i mappen som innehåller den nerladdade Rocky ISO-avbilden, skriv:

```
wget http://download.rockylinux.org/pub/rocky/8.4/isos/x86_64/CHECKSUM
```

Använd `sha256sum` verktyget för att verifiera

```
sha256sum -c CHECKSUM    --ignore-missing Rocky-8.4-x86_64-minimal.iso
```

Utdatan ska inkludera:

```
Rocky-8.4-x86_64-minimal.iso: OK
```

!!! Tip
    Innan du startar installationen ordentligt, systemets Unified Extensible Firmware Interface (UEFI) eller Basic Input/Output System (BIOS) ska vara förkonfigurerat till att starta från korrekt media.

# Installationen

Låt oss börja med installationsprocessen.

Koppla in och starta från ditt installationmedia (optisk skiva, USB-sticka, och så vidare).

När du startat, så kommer du bli presenterad med en välkomstskärm.

![Rocky Linux installation splash screen](images/installation-F01.png)

Om du inte trycker på någon tangent, efter uppmaningen börjar en nedräkning, varefter installationsprocessen kommer börja med att starta den markerade `Testa detta media & installera Rocky Linux 8` ... alternativ. Du kan också trycka på <kbd>enter</kbd> för att starta processen omedelbart.

Ett snabbt mediaverifieringssteg kommer att äga rum. detta mediaverifieringssteg kan spara dig besväret av att påbörja installationen endast för att upptäcka halvvägs igenom att installationsprogrammet kommer att avbrytas på grund av dåligt installationsmedia.

Efter att mediekontrollen är klar, och mediat har framgångsrikt verifierats och kommer att vara användbart, så kommer installationsprogrammet automatiskt att fortsätta till nästa sektion.

Välj vilket språk du vill använda för att utföra installationen i denna del. För detta exempel, så kommer vi välja _Engelska (United States)_. Klicka sedan på knappen <kbd>Fortsätt</kbd>.

## Installationsöversikt

Installationsöversikts skärmen är ett allt-i-ett-område där du kan göra viktiga val om det operativsystem som ska installeras.

Denna skärm är ungefär uppdelad i följande sektioner:

- _Lokalisering_: (Tangentbord, Språkstöd, och Tid & Datum)
- Programvara: (Installationskälla och Programvaruval)
- _System_: (Installationsdestination och Nätverk & Värdnamn)

Vi fördjupar oss i vart och ett av denna sektion och gör ändringar vid behov.

## Lokaliseringssektion

Denna ssektion används för att anpassa objekt relaterade till lokalen ditt system. Detta inkluderar – Tangentbord, Språkstöd, Tid och Datum.

### Tangentbord

På vårt demo-system i den här guiden accepterar vi standardvärdet (_Engelska_ US_) och gör inga ändringar.

Men om du behöver göra några ändringar här, från _Installationsöversikt_ skärmen, klicka på <kbd>Tangentbords</kbd> alternativet för att ange tangentbordslayout på ditt system. Du kan lägga till ytterligare tangentbordslayouter om du behöver på den efterföljande skärmen och ange deras ordning.

Klicka på <kbd>Klar</kbd> när du är klar.

### Språkstöd

<kbd>Språkstöd</kbd> alternativet på _Installationsöversikt_ skärmen tillåter dig att aktivera stöd för ytterligare språk som du kan behöva på det färdiga systemet.

Vi accepterar standardvärdet (__Engelska – United States__) och gör ingen förändring . Klicka på <kbd>Klar</kbd>.

### Tid & Datum

Klicka på <kbd>Tid & Datum</kbd> alternativet på huvud _Installationsöversikt_ skärmen för att få upp en annan skärm som tillåter dig att välja vilken tidszon där maskinen är placerad. Bläddra igenom listan över regioner och städer och välj det område som ligger närmast dig.

Beroende på din installationskälla, så kan _Nätverkstid_ alternativet sättas till _PÅ eller _AV som standard. Acceptera standard _PÅ_ inställningen; detta tillåter systemet att automatiskt ställa in rätt tid genom att använda nätverkstid protokollet (NTP). Klicka på <kbd>Klar</kbd> efter du gjort några ändringar.

## Programvaruval

Under Programvaruval sektionen på _Installationsöversikt_ skärmen, så kan du välja en installationskälla samt ytterligare paket (applikationer) som ska installeras.

### Installationskälla

Eftersom vi utför vår installation med en full Rocky 8 avbild, så kommer du notera att _Lokalt media_ är automatiskt valt under installationskälla sektionen av huvud _Installationsöversikt_ skärmen. Vi accepterar de förinställda standardvärdena.

### Programvaruval

Klicka på <kbd>Programvaruval</kbd> alternativet på huvud _Installationsöversikt_ skärmen presenterar dig med en sektion av installationen där du kan välja dom exakta programvarupaketen som installeras på systemet. Dessa programvaru områden har delats in i dessa:

- _Basmiljö_ : Server, Minimal installation, Anpassat Operativ system
- _Ytterligare programvara för området Vald miljö : Då du väljer basmiljö på vänster sida presenteras en mängd relaterad ytterligare programvara som kan installeras för den valda miljön på högersida.

Välj alternativet _Minimal installation_ (grundläggande funktionalitet) istället.

Klicka på <kbd>Klar</kbd> högst upp på skärmen.

## System Sektion

Systemsektionen på _Installationsöversikt_ skärmen används för att anpassa och gör ändringar till den underliggande hårdvaran på målsystemet. Detta är vart du skapar dina hårddiskpartitioner eller volymer, specificerar vilket filsystem som ska användas, och anger nätverkskonfigurationen.

### Installationsdestination

Från _Installationsöversikt_ skärmen, klicka på <kbd>Installationsdestination</kbd> alternativet. Detta tar dig till motsvarande uppgiftsområde.

Du kommer se en skärm som visar alla dom kandiderande diskar som du har tillgängliga på målsystemet. Om du endast har en diskenhet på systemet, som på vårat exempelsystem, Då kommer du att se enheten listad under _Lokala Standarddiskar_ med en bock bredvid den. Om du klickar på diskikonen växlar du på eller av kryssmarkeringen för diskval. Vi vill ha den vald/ikryssad här.

Under _Lagringskonfigurations_ Inställningssektionen, Välj den <kbd>Automatiska</kbd> knappen.

Klicka sedan på <kbd>Klar</kbd> högst upp på skärmen.

När installationsprogrammet har kommit fram till att du har en användbar disk, så kommer du att skickas tillbaka till _Installationsöversikt_ skärmen.

### Nätverk & Värdnamn

Sista steget av installationsproceduren handlar om nätverkskonfiguration, här kan du kan konfigurera eller justera nätverksrelaterade inställningar för systemet.

!!! Note "Notera"
    Efter du klickat på <kbd>Nätverk & Värdnamn</kbd> alternativet, alla korrekt upptäckta hårdvaror för nätverksgränssnitt (t.ex. Ethernet, trådlösa nätverkskort och så vidare) kommer att listas i den vänstra rutan på nätverkskonfigurationsskärmen. Beroende på Linux-distributionen och dom specifika hårdvaruinställningarna, Ethernet enheter i har namn som ungefär som  `eth0`, `eth1`, `ens3`, `ens4`, `em1`, `em2`, `p1p1`, `enp0s3`, och såvidare.

För varje gränssnitt, så kan du antingen konfigurera det med DHCP eller genom att manuellt ange en IP-adress. Om du väljer att konfigurera manuellt, se till att ha all relevant information redo, som t.ex. IP-adress, nätmask, och såvidare.

Klicka på <kbd>Nätverk & Värdnamn</kbd> knappen på huvud  _Installationsöversikt_ skärmen öppnar den motsvarande konfigurationsskärmen. Bland annat, så har du alternativet att konfigurera värdnamnet för systemet (namnet är som standard `localhost.localdomain`).

!!! Note "Notera"
    Du kan enkelt ändra detta namnet senare efter att oprativsystemet har installerats. För nu, acceptera det angivna standardvärdet för värdnamnet.

Nästa viktiga konfigurationsuppgift är relaterad till nätverksgränssnitten på systemet. Först, verifiera att ett Ethernet-kort (eller annat nätverkskort) är listat i den vänstra rutan. Klicka på någon av dom upptäckta nätverksenheterna i den vänstra rutan för att välja den. De konfigurerbara egenskaperna för den valda nätverks adapter visas i den högra rutan på skärmen.

!!! Note "Notera"
    På våran exempelserver, så har vi fyra Ethernet-enheter (`ens3`, `ens4`, `ens5` och `ens6`), som alla är i ett anslutet tillstånd. Typ, namn, kvantitet, och tillstånd på nätverksenheterna på ditt system kan variera från de som finns i vårt exempelsystem.

Se till att omkopplaren för enheten som du vill konfigurera ändras till `PÅ` position i den högra rutan.
Vi accepterar alla standardvärden i den här sektionen.

Klicka på <kbd>Klar</kbd> och återgå till huvud _Installationsöversikt_ skärmen.

!!! Warning "Varning"
    Var uppmärksam på serverns IP-adress i denna sektion av installationsprogrammet. Om du inte har fysisk åtkomst eller enkel konsolåtkomst till systemet, Så kommer denna information komma att vara till nytta senare när du behöver ansluta till servern för att fortsätta arbeta med den.

## Installationen

När du väl är nöjd med dina val för olika installationsuppgifter, så kommer nästa fas av installationsprocessen att börja installera ordentligt.

## Användarinställningar Sektion

Denna sektion kommer att användas för att skapa ett lösenord för `root` användarkontot och också för att skapa nya administrativa eller icke-administrativa konton.

### Välj ett Root lösenord

Klicka på _Rootlösenords_ fäletet under _Använderinställningar_ för att starta _Rootlösenords _ uppgiftsskärmen. I _Rootlösenord_ textrutan, ange ett starkt lösenord för rotanvändaren.

!!! Warning "Varning"
    Denna användare är det mest privilegierade kontot på ditt system. Därför, om du väljer att använda det eller aktivera det - så är det mycket viktigt att du skyddar det här kontot med ett mycket bra lösenord.

Ange samme lösenord igen i _Bekräfta textrutan.

Klicka på <kbd>Klar</kbd>.


### Skapa ett användarkonto

Klicka sedan på fältet _Användarskapande_ under _Användarinställningar_ för att starta _Skapa en användare_ uppgiftsskärmen. Detta aktivitetsområde låter dig skapa ett privilegierat eller icke-privilegierat (icke-administrativt) användarkonto i systemet.

!!! Info
    Att skapa och använda ett icke-privilegierat konto för dagliga uppgifter i ett system är en bra systemadministrationspraxis.
    Vi kommer att skapa en vanlig användare som kan åkalla superanvändare (administratörsrättigheter) när det behövs.

Fyll i fälten på _Skapa en användare_ skärmen med följande information och klicka sedan på<kbd>Klar</kbd>:

_Fullständigt namn_:
`rockstar`

_Användarnamn_:
`rockstar`

_Gör den här användaren administratör_:
Ikryssad

_Kräv ett lösenord för att använda detta konto_:
Ikryssad

_Lösenord_:
`04302021`

_Bekräfta lösenord_:
`04302021`

### Starta installationen

När du väl är nöjd med dina val för dom olika installationsuppgifterna, klicka på starta Installationsknappen på huvud _Installationsöversikt_ skärmen. installationen kommer att startas, och installationsprogrammet visar hur installationen fortskrider.

!!! Note
    Om du får kalla fötter efter att du har klickat på starta Installationsknappen, så kan du fortfarande säkert komma tillbaka från installationen utan att förlora data (eller självförtroende). För att avsluta installationsprogrammet, Återställ helt enkelt ditt system antingen genom att klicka på Avsluta-knappen, trycka ctrl-alt-del på ditt tangentbord, eller genom att trycka på reset- eller strömknappen.

När installationen startar, så kommer olika uppgifter börja köras i bakgrunden, som att partitionera disken, formatera partitionerna eller LVM-volymerna, söka efter och lösa programberoenden, skriva operativsystemet till disk och så vidare.   ​

### Slutför installationen

Efter du har slutfört alla av de obligatoriska deluppgifterna och installationsprogrammet har gått sin runda, så kommer du att få en slutlig skärm för installationsförloppet med ett slutför meddelande.

Slutligen slutför hela proceduren genom att klicka på <kbd>Starta om System</kbd> knappen. Systemet startar om sig själv.

### Logga in

Systemet är nu färdig installerat och klart för användning. Du kommer att se den bedårande Rocky Linux-konsolen.

![Rocky Linux Välkommenskärm](images/installation-F04.png)

För att logga in på systemet, skriv `rockstar` vid inloggningsprompten och tryck på <kbd>enter</kbd>.

Vid lösenordsprompten, skriv `04302021` (rockstar’s lösenord) och tryck på <kbd>enter</kbd> (ingenting visas på skärmen och detta är normalt).

Prova att köra `whoami` kommandot efter inloggning.

![Inloggningsskärm](images/installation-F06.png)
