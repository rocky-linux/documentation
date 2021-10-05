# Aktivera iptables Brandvägg

## Prerequisites

* En brännande, osläcklig lust att inaktivera den standard _firewalld_ applikationen, och aktivera _iptables_ istället.

## Introduktion

_firewalld_ är nu standard brandväggen på Rocky Linux. _firewalld_ är inget annat än en dynamisk applikation baserad på _iptables_ som använder xml filer, och den laddar ändringar utan att spola reglerna. 

Men om du vill, använda enkel _iptables_ då det är något som du kanske är mer van med. Om det är så, är det fortfarande möjligt att använda _iptables_ utan _firewalld_ genom att följa denna guide. Denna guide kommer dock _inte_ berätta för dig är hur man skriver regler för _iptables_. 

Det antas att om du vill bli av med _firewalld_, att du redan vet hur man skriver regler för _iptables_.

## Inaktivera firewalld

Du kan inte riktigt köra det gamla _iptables_ verktygen samtidigt som  _firewalld_. De är bara inte kompatibla. Bästa sättet att komma runt detta är att inaktivera _firewalld_ helt (du behöver inte avinstallera det om du inte vill), och installera om _iptables_ verktygen. Inaktivera _firewalld_ kan göras med dessa kommandon:

Stoppa _firewalld_:

`systemctl stop firewalld`

Inaktivera _firewalld_ så det inte kommer starta vid uppstart av datorn:

`systemctl disable firewalld`

Maskera tjänsten så att den inte kan hittas:

`systemctl mask firewalld`

## Installera och aktivera iptables tjänst

Därefter måste vi installera den gamla _iptables_ tjänsten och verktyg. Detta görs med följande:

`dnf install iptables-services iptables-utils`

Detta kommer installera allting som behövs för att köra ett rakt _iptables_ regelverk.

Nu måste vi aktivera _iptables_ tjänsten för att se till att den startar direkt vid uppstart:

`systemctl enable iptables`

## Slutsats

YDu kan återgå till att använda rakt av använda _iptables_ om du trivs med det bättre istället för _firewalld_. Du kan återgå till att använda standard _firewalld_ genom att helt enkelt backa dessa förändringar.


