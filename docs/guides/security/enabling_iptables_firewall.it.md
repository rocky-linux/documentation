# Abilitazione Firewall iptables

## Prerequisiti

* Un ardente, inestinguibile desiderio di disabilitare l'applicazione di default _firewalld_ e abilitare _iptables_.

## Introduzione

_firewalld_ è ora il firewall predefinito su Rocky Linux. _firewalld_ **era** nient'altro che un'applicazione dinamica di _iptables_ che utilizzando i file xml caricava le modifiche senza il flushing delle regole in CentOS 7/RHEL 7.  Con CentOS 8/RHEL 8/Rocky 8, _firewalld_ è ora un wrapper intorno a _nftables_. È ancora possibile, tuttavia, installare e utilizzare direttamente _iptables_ se questa è la tua preferenza. Per installare ed eseguire direttamente _iptables_ senza _firewalld_ puoi farlo seguendo questa guida. Ciò che questa guida **non ti dirà** è come scrivere le regole per _iptables_. Si presume che se vuoi sbarazzarti di _firewalld_, devi già sapere come scrivere regole per _iptables_.

## Disabilita firewalld

Non è possibile eseguire la vecchia utility _iptables_ accanto a _firewalld_. Semplicemente non sono compatibili. Il modo migliore per aggirare questo è disabilitare _firewalld_ interamente (non c'è bisogno di rimuoverlo a meno che tu non lo voglia), e reinstallare le utilità _iptables_. Disabilitare _firewalld_ può essere fatto utilizzando questi comandi:

Stop _firewalld_:

`systemctl stop firewalld`

Disabilita _firewalld_ in modo che non si parta all'avvio:

`systemctl disabilita firewalld`

Maschera il servizio in modo che non possa essere trovato:

`systemctl mask firewalld`

## Installazione e abilitazione dei servizi iptables

Successivamente abbiamo bisogno di installare i vecchi servizi e le vecchie utility _iptables_. Ciò è fatto con quanto segue:

`dnf install iptables-services iptables-utils`

Questo installerà tutto ciò che è necessario per eseguire una regola _iptables_ impostata.

Ora abbiamo bisogno di abilitare il servizio _iptables_ per assicurarsi che parta all'avvio:

`systemctl enable iptables`

## Conclusione

È possibile tornare a utilizzare di seguito _iptables_ se si preferisce al posto di _firewalld_. Puoi tornare a usare il _firewalld_ predefinito semplicemente invertendo queste modifiche.
