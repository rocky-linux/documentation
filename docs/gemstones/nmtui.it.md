---
title: nmtui - Strumento di Gestione della Rete
author: tianci li
contributors: Steven Spencer, Neil Hanlon, Franco Colussi
update: 2021-10-23
---

# Introduzione

Per gli utenti inesperti che si avvicinano per la prima volta a GNU/Linux, la prima cosa da considerare è come collegare la macchina a Internet dopo aver installato il sistema operativo. Questo articolo spiega come configurare l'indirizzo IP, la maschera di sottorete, il gateway e il DNS. Ci sono diversi modi per avere riferimenti. Che siate principianti o esperti, credo che possiate iniziare rapidamente.

## nmtui

`NetworkManager` è una suite di strumenti standard per la configurazione della rete Linux, che supporta ambienti server e desktop. Oggi le distribuzioni più diffuse lo supportano. Questo set di strumenti di configurazione di rete è adatto a Rocky Linux 8 e versioni successive. Se si desidera configurare le informazioni di rete in modo grafico (cioè con la riga di comando `nmtui` ), è sufficiente eseguire questa operazione:

```bash
shell > dnf -y install NetworkManager NetworkManager-tui
shell > nmtui
```

| NetworkManager TUI            |          |
| ----------------------------- | -------- |
| Modifica di una connessione   |          |
| Attiva una connessione        |          |
| Imposta nome host del sistema |          |
| Esci                          |          |
|                               | \<OK\> |

È possibile utilizzare il tasto <kbd>Tab</kbd> o i tasti <kbd>↑</kbd><kbd>↓</kbd><kbd>←</kbd><kbd>→</kbd> per selezionare la specifica Se si desidera modificare le informazioni di rete, selezionare **Modifica una connessione** e quindi <kbd>Invio</kbd>. Selezionare una scheda di rete diversa e scegliere **Modifica...** per modificarla.

### DHCP IPv4

Per IPv4, se si tratta di ottenere informazioni di rete con DHCP, è sufficiente selezionare *IPv4 CONFIGURATION* **&lt;Automatic&gt;**, ed eseguire nel terminale `systemctl restart NetworkManager.service`. Questo funziona nella maggior parte dei casi. In rari casi, è necessario disabilitare e abilitare la scheda di rete affinché la modifica abbia effetto. Ad esempio: `nmcli connection down ens33`, `nmcli connection up ens33`


### Correggere manualmente le informazioni di rete

Se si desidera correggere manualmente tutte le informazioni di rete IPv4, è necessario selezionare **&lt;Manuale&gt;** dopo *CONFIGURAZIONE IPv4* e aggiungerle riga per riga. Ad esempio, mi piace questo:

| Elemento   | Valore           |
| ---------- | ---------------- |
| Indirizzi  | 192.168.100.4/24 |
| Gateway    | 192.168.100.1    |
| Server DNS | 8.8.8.8          |

Quindi fare clic su \< OK \>, tornare all'interfaccia del terminale passo dopo passo ed eseguire `systemctl restart NetworkManager.service`</OK>. Allo stesso modo, in rari casi, la scheda di rete deve essere accesa e spenta per avere effetto.

## Modificare il modo in cui i file di configurazione vengono utilizzati

Tutte le distribuzioni RHEL, sia upstream che downstream, sono configurate allo stesso modo. Il file di configurazione delle informazioni di rete è memorizzato nella directory **/etc/sysconfig/network-scripts/** e una scheda di rete corrisponde a un file di configurazione. Il file di configurazione ha molti parametri, come mostrato nella tabella seguente. Avviso! I parametri devono essere scritti in maiuscolo.

!!! warning "Attenzione"

    Nelle distribuzioni RHEL 9.x, il percorso della directory in cui è memorizzato il file di configurazione del NIC è stato modificato, ovvero **/etc/NetworkManager/system-connections/**. Vedi [quì](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/9/html-single/configuring_and_managing_networking/index) per ulteriori informazioni.

```bash
shell > ls /etc/sysconfig/network-scripts/
ifcfg-ens33
```

| Nome del parametro      | Significato                                                                                                                                                                                                                       | Esempio                             |
| ----------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------- |
| DEVICE                  | Nome del dispositivo logico del sistema                                                                                                                                                                                           | DEVICE=ens33                        |
| ONBOOT                  | È possibile scegliere se la scheda di rete si avvia automaticamente con il sistema                                                                                                                                                | ONBOOT=yes                          |
| TYPE                    | Tipo di interfaccia della scheda di rete, solitamente Ethernet                                                                                                                                                                    | TYPE=Ethernet                       |
| BOOTPROTO               | La modalità di ottenimento dell'ip può essere l'acquisizione dinamica DHCP o la configurazione manuale statica, utilizzando un indirizzo statico                                                                                  | BOOTPROTO=static                    |
| IPADDR                  | L'indirizzo ip della scheda di rete, quando BOOTPROTO=static, questo parametro avrà effetto                                                                                                                                       | IPADDR=192.168.100.4                |
| HWADDR                  | Indirizzo hardware, ovvero indirizzo MAC                                                                                                                                                                                          | HWADDR=00:0C:29:84:F6:9C            |
| NETMASK                 | Maschera di sottorete decimale                                                                                                                                                                                                    | NETMASK=255.255.255.0               |
| PREFIX=24               | Maschera di sottorete, rappresentata da numeri                                                                                                                                                                                    | PREFIX=24                           |
| gateway: 192.168.20.254 | Gateway, se ci sono più schede di rete, questo parametro può comparire una sola volta                                                                                                                                             | GATEWAY=192.168.100.1               |
| PEERDNS                 | Quando è sì, i parametri DNS definiti qui modificheranno /etc/resolv.conf; quando è no, /etc/resolv.conf non verrà modificato. Quando si utilizza DHCP, l'impostazione predefinita è sì                                           | PEERDNS=yes                         |
| DNS1                    | Il DNS primario è selezionato, ha effetto solo quando PEERDNS=no                                                                                                                                                                  | DNS1=8.8.8.8                        |
| DNS2                    | DNS alternativo, efficace solo quando PEERDNS=no                                                                                                                                                                                  | DNS2=114.114.114.114                |
| BROWSER_ONLY            | Se consentire solo i browser                                                                                                                                                                                                      | BROWSER_ONLY=no                     |
| USERCTL                 | Se gli utenti ordinari sono autorizzati a controllare il dispositivo della scheda di rete, sì significa che è consentito, no significa che non è consentito                                                                       | USERCTL=no                          |
| UUID                    | Codice di identificazione univoco universale, la funzione principale è quella di identificare l'hardware, in generale, non è necessario compilare                                                                                 |                                     |
| PROXY_METHOD            | Metodo proxy, generalmente nessuno, può essere lasciato vuoto                                                                                                                                                                     |                                     |
| IPV4_FAILURE_FATAL    | Se è sì, significa che il dispositivo sarà disabilitato dopo che la configurazione ipv4 è fallita; se è no, significa che non sarà disabilitato.                                                                                  | IPV4_FAILURE_FATAL=no             |
| IPV6INIT                | Se abilitare IPV6, sì per abilitare, no per non abilitare. Quando IPV6INIT=yes, possono essere abilitati anche i due parametri IPV6ADDR e IPV6_DEFAULTGW. Il primo rappresenta l'indirizzo IPV6 e il secondo il gateway designato | IPV6INIT=yes                        |
| IPV6_AUTOCONF           | Se utilizzare la configurazione automatica di IPV6, sì significa utilizzare; no significa non utilizzare                                                                                                                          | IPV6_AUTOCONF=yes                   |
| IPV6_DEFROUTE           | Se dare a IPV6 il percorso predefinito                                                                                                                                                                                            | IPV6_DEFROUTE=yes                   |
| IPV6_FAILURE_FATAL    | Dopo che la configurazione IPV6 è fallita, se disabilitare o meno il dispositivo                                                                                                                                                  | IPV6_FAILURE_FATAL=no             |
| IPV6_ADDR_GEN_MODE    | Genera il modello di indirizzo IPV6, i valori opzionali sono stable-privacy e eui64                                                                                                                                               | IPV6_ADDR_GEN_MODE=stable-privacy |

Dopo che il file di configurazione è stato modificato con successo, ricordarsi di riavviare il servizio della scheda di rete `systemctl restart NetworkManager.service`.

### Configurazione consigliata per IPV4

```bash
TYPE=Ethernet
ONBOOT=yes
DEVICE=ens33
USERCTL=no
BROWSER_ONLY=no
IPV6INIT=yes
IPV6_AUTOCONF=yes
IPV6_DEFROUTE=yes
IPV6_FAILURE_FATAL=no
```

### Configurazione consigliata per IPV6

```bash
TYPE=Ethernet
ONBOOT=yes
DEVICE=ens33
USERCTL=no
BROWSER_ONLY=no
IPV6INIT=yes
IPV6_AUTOCONF=yes
IPV6_DEFROUTE=yes
IPV6_FAILURE_FATAL=no
```

## Visualizzazione delle informazioni di rete

`ip a` or `nmcli device show`
